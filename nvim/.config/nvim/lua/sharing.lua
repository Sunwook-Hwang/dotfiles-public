-- Explicit, single-buffer collaboration. No timers, filesystem polling or plugins.
-- An authenticated TCP session orders edits; text operations rebase concurrent changes.
local op = require("share_operation")
local policy = require("buffer_policy")
local M = {}
local server, client
local group = vim.api.nvim_create_augroup("flash-sharing", { clear = true })
local limit = 1024 * 1024

local function notify(message, level)
	vim.notify("FLASH share: " .. message, level or vim.log.levels.INFO)
end

local function close(handle)
	if handle and not handle:is_closing() then
		handle:close()
	end
end

-- One JSON frame per line. Bound both receive frames and outstanding socket writes.
local function channel(socket, receive, disconnected)
	local connection = { socket = socket, input = "", closed = false }
	function connection:stop(reason)
		if self.closed then
			return
		end
		self.closed = true
		close(socket)
		if disconnected then
			disconnected(reason)
		end
	end
	function connection:send(message)
		if self.closed then
			return
		end
		local frame = vim.json.encode(message) .. "\n"
		if socket:get_write_queue_size() + #frame > 4 * limit then
			self:stop("Connection cannot keep up; local text was retained")
			return
		end
		local request, err = socket:write(
			frame,
			vim.schedule_wrap(function(write_error)
				if write_error then
					self:stop(write_error)
				end
			end)
		)
		if not request then
			self:stop(err)
		end
	end
	function connection:read()
		local started, start_error = socket:read_start(vim.schedule_wrap(function(err, data)
			if self.closed then
				return
			end
			if err or not data then
				self:stop(err or "Disconnected; local text was retained")
				return
			end
			self.input = self.input .. data
			while true do
				local finish = self.input:find("\n", 1, true)
				if not finish then
					if #self.input > 2 * limit then
						self:stop("Frame is too large")
					end
					return
				end
				if finish > 2 * limit then
					self:stop("Frame is too large")
					return
				end
				local frame = self.input:sub(1, finish - 1)
				self.input = self.input:sub(finish + 1)
				local ok, message = pcall(vim.json.decode, frame)
				if ok and type(message) == "table" then
					ok, message = pcall(receive, self, message)
				else
					ok, message = false, "Invalid message"
				end
				if not ok then
					self:stop(tostring(message))
				end
				if self.closed then
					return
				end
			end
		end))
		if not started then
			self:stop(start_error)
		end
	end
	return connection
end

local function disk_content(path)
	local stat = vim.uv.fs_stat(path)
	if stat and stat.size > 2 * limit then
		return false
	end
	if vim.fn.filereadable(path) == 0 then
		return nil
	end
	return table.concat(vim.fn.readfile(path, "b"), "\n")
end

local function document_valid(text)
	assert(#text <= limit and text:sub(-1) == "\n", "Invalid shared document")
end

local function send_next(session)
	if session.connected and not session.sent and session.queue[1] then
		session.sent = true
		session.connection:send({ type = "edit", revision = session.revision, operation = session.queue[1] })
	end
end

-- Each inverse is based on the state after undoing all newer entries.
local function trim_history(history)
	while #history > 1000 or (history.bytes or 0) > 4 * limit do
		history.bytes = history.bytes - op.size(table.remove(history, 1))
	end
end

local function rebase_history(history, remote)
	for i = #history, 1, -1 do
		local previous_size = op.size(history[i])
		remote, history[i] = op.transform(remote, history[i])
		history.bytes = (history.bytes or 0) + op.size(history[i]) - previous_size
	end
	trim_history(history)
end

local function push_history(history, operation)
	history[#history + 1] = operation
	history.bytes = (history.bytes or 0) + op.size(operation)
	trim_history(history)
end

local function patch_buffer(session, operation)
	local before, after = session.text, op.apply(session.text, operation)
	document_valid(after)
	if before == after then
		return
	end
	local first, removed, inserted = op.difference(before:sub(1, -2), after:sub(1, -2))
	local positions = {}
	for _, win in ipairs(vim.fn.win_findbuf(session.buf)) do
		local cursor = vim.api.nvim_win_get_cursor(win)
		local offset = vim.api.nvim_buf_get_offset(session.buf, cursor[1] - 1) + cursor[2]
		positions[win] = op.move(offset, operation)
	end
	session.applying = true
	local row, col = op.position(before, first)
	local end_row, end_col = op.position(before, first + removed)
	local ok, err = pcall(
		vim.api.nvim_buf_set_text,
		session.buf,
		row,
		col,
		end_row,
		end_col,
		vim.split(inserted, "\n", { plain = true })
	)
	session.applying = false
	assert(ok, err)
	session.text = after
	for win, offset in pairs(positions) do
		local new_row, new_col = op.position(after, math.min(offset, #after - 1))
		vim.api.nvim_win_set_cursor(win, { new_row + 1, new_col })
	end
end

local function record(session, operation, kind)
	local inverse = op.inverse(session.text, operation)
	if kind == "undo" then
		push_history(session.redo, inverse)
	elseif kind == "redo" then
		push_history(session.undo, inverse)
	else
		push_history(session.undo, inverse)
		session.redo = {}
	end
	-- Bound disconnected edits as well as network traffic.
	if session.connected then
		session.queue[#session.queue + 1] = operation
		session.queue_bytes = session.queue_bytes + op.size(operation)
		if #session.queue > 1000 or session.queue_bytes > 4 * limit then
			vim.schedule(function()
				session.connection:stop("Too many unacknowledged edits; local text was retained")
			end)
		end
	end
end

local function undo(session, redo)
	local history = redo and session.redo or session.undo
	for _ = 1, math.max(1, vim.v.count1) do
		local operation = table.remove(history)
		if not operation then
			break
		end
		history.bytes = history.bytes - op.size(operation)
		record(session, operation, redo and "redo" or "undo")
		patch_buffer(session, operation)
	end
	send_next(session)
end

local function write_shared(session)
	local owner = server
	if not owner or owner.session ~= session then
		notify("Only the session owner saves the source file", vim.log.levels.WARN)
		return
	end
	if not session.connected or #session.queue > 0 or session.text ~= owner.text then
		notify("Wait for pending edits to synchronize before saving", vim.log.levels.WARN)
		return
	end
	if
		not vim.api.nvim_buf_is_loaded(owner.source)
		or not policy.is_source(owner.source)
		or not vim.bo[owner.source].modifiable
		or vim.api.nvim_buf_get_changedtick(owner.source) ~= owner.source_tick
		or vim.api.nvim_buf_get_name(owner.source) ~= owner.path
		or disk_content(owner.path) ~= owner.disk
	then
		notify("Source file changed outside this session; save was refused", vim.log.levels.ERROR)
		return
	end
	vim.api.nvim_buf_set_lines(owner.source, 0, -1, false, vim.split(owner.text:sub(1, -2), "\n", { plain = true }))
	owner.source_tick = vim.api.nvim_buf_get_changedtick(owner.source)
	local ok, err = pcall(vim.api.nvim_buf_call, owner.source, function()
		vim.cmd("write")
	end)
	owner.source_tick = vim.api.nvim_buf_get_changedtick(owner.source)
	owner.disk = disk_content(owner.path)
	if not ok then
		notify(tostring(err), vim.log.levels.ERROR)
		return
	end
	-- Formatting/save hooks may have changed the source; never silently diverge.
	if table.concat(vim.api.nvim_buf_get_lines(owner.source, 0, -1, false), "\n") .. "\n" ~= owner.text then
		notify("A source write hook changed the file; stop sharing before continuing", vim.log.levels.ERROR)
		M.stop()
		return
	end
	vim.bo[session.buf].modified = false
	notify("Saved " .. owner.path)
end

local function create_buffer(session, message)
	local buf = vim.api.nvim_create_buf(true, false)
	session.buf, session.text = buf, message.text
	vim.api.nvim_buf_set_name(
		buf,
		"flash-share://" .. message.session .. "/" .. session.id .. "/" .. vim.fs.basename(message.file)
	)
	vim.bo[buf].buftype, vim.bo[buf].bufhidden, vim.bo[buf].swapfile = "acwrite", "hide", false
	vim.bo[buf].undofile, vim.bo[buf].undolevels = false, -1
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(message.text:sub(1, -2), "\n", { plain = true }))
	vim.bo[buf].filetype = message.filetype
	vim.bo[buf].modified = false
	vim.b[buf].flash_shared = true
	local name = vim.api.nvim_buf_get_name(buf)
	vim.api.nvim_create_autocmd({ "BufWriteCmd", "FileWriteCmd", "FileAppendCmd" }, {
		group = group,
		buffer = buf,
		callback = function(args)
			if args.event == "BufWriteCmd" and vim.api.nvim_buf_get_name(buf) == name then
				write_shared(session)
			else
				notify(
					"Shared buffers cannot write another path; copy text into a normal buffer first",
					vim.log.levels.WARN
				)
			end
		end,
	})
	vim.keymap.set("n", "u", function()
		undo(session, false)
	end, { buffer = buf, desc = "Undo my shared edit" })
	vim.keymap.set("n", "<C-r>", function()
		undo(session, true)
	end, { buffer = buf, desc = "Redo my shared edit" })
	vim.api.nvim_buf_attach(buf, false, {
		on_bytes = function(_, _, _, row, col, start, _, _, removed, added_rows, added_col)
			if session.disabled then
				return true
			end
			if session.applying then
				return
			end
			local count = vim.api.nvim_buf_line_count(buf)
			local finish = row + added_rows
			local lines = vim.api.nvim_buf_get_lines(buf, row, math.min(finish + 1, count), true)
			if finish < count then
				lines[#lines] = lines[#lines]:sub(1, added_rows == 0 and col + added_col or added_col)
			else
				lines[#lines + 1] = ""
			end
			lines[1] = lines[1]:sub(col + 1)
			local operation = op.splice(#session.text, start, removed, table.concat(lines, "\n"))
			local ok, after = pcall(op.apply, session.text, operation)
			if ok then
				ok = pcall(document_valid, after)
			end
			if not ok then
				session.disabled = true
				vim.schedule(function()
					if vim.api.nvim_buf_is_valid(buf) then
						-- A rejected edit is already in the buffer. Never apply old inverses
						-- to that new, unsynchronized text during recovery.
						vim.keymap.del("n", "u", { buffer = buf })
						vim.keymap.del("n", "<C-r>", { buffer = buf })
						vim.bo[buf].undolevels = vim.go.undolevels
					end
					local reason = "Unsupported edit; buffer retained, sharing stopped"
					if session.connection.closed then
						notify(reason, vim.log.levels.WARN)
					else
						session.connection:stop(reason)
					end
				end)
				return
			end
			if after == session.text then
				return
			end
			record(session, operation)
			session.text = after
			if not session.send_scheduled then
				session.send_scheduled = true
				vim.schedule(function()
					session.send_scheduled = false
					send_next(session)
				end)
			end
		end,
		on_detach = function()
			vim.schedule(function()
				if client == session then
					M.stop()
				end
			end)
		end,
	})
	vim.api.nvim_set_current_buf(buf)
end

local function connect(host, port, token, owner)
	assert(not client, "Already sharing; use :FlashShareStop first")
	local socket = vim.uv.new_tcp()
	local session = { queue = {}, queue_bytes = 0, undo = {}, redo = {}, connected = false }
	client = session
	if owner then
		owner.session = session
	end
	session.connection = channel(socket, function(_, message)
		if message.type == "welcome" then
			assert(not session.connected, "Repeated welcome")
			document_valid(message.text)
			op.valid_text(message.text)
			session.id, session.revision, session.connected = message.id, message.revision, true
			create_buffer(session, message)
			notify("Connected. u/Ctrl+r undo only your edits; :FlashShareStop disconnects")
		elseif message.type == "edit" then
			assert(session.connected and message.revision == session.revision + 1, "Revision mismatch")
			if message.id == session.id then
				assert(session.sent and session.queue[1], "Unexpected acknowledgement")
				session.queue_bytes = session.queue_bytes - op.size(table.remove(session.queue, 1))
				session.sent = false
			else
				local remote = message.operation
				for i, pending in ipairs(session.queue) do
					remote, session.queue[i] = op.transform(remote, pending)
					session.queue_bytes = session.queue_bytes + op.size(session.queue[i]) - op.size(pending)
				end
				patch_buffer(session, remote)
				rebase_history(session.undo, remote)
				rebase_history(session.redo, remote)
			end
			session.revision = message.revision
			send_next(session)
		else
			error("Unknown server message")
		end
	end, function(reason)
		session.connected = false
		if client == session then
			client = nil
		end
		if session.buf and vim.api.nvim_buf_is_valid(session.buf) then
			vim.b[session.buf].flash_shared = false
		end
		if reason then
			notify(reason, vim.log.levels.WARN)
		end
	end)
	vim.uv.getaddrinfo(
		host,
		nil,
		{ socktype = "stream" },
		vim.schedule_wrap(function(err, addresses)
			if session.connection.closed then
				return
			end
			if err or not addresses or not addresses[1] then
				session.connection:stop(err or "Cannot resolve host")
				return
			end
			socket:connect(
				addresses[1].addr,
				port,
				vim.schedule_wrap(function(connect_error)
					if session.connection.closed then
						return
					end
					if connect_error then
						session.connection:stop(connect_error)
						return
					end
					session.connection:read()
					session.connection:send({ type = "hello", token = token, protocol = 1 })
				end)
			)
		end)
	)
end

function M.start(args)
	assert(not server and not client, "Already sharing; use :FlashShareStop first")
	local source = vim.api.nvim_get_current_buf()
	assert(policy.allows(source) and vim.bo[source].modifiable, "Share a normal, editable source buffer")
	assert(vim.o.encoding == "utf-8", "UTF-8 is required")
	local path = vim.api.nvim_buf_get_name(source)
	assert(path ~= "", "Save/name the source file before sharing")
	local text = table.concat(vim.api.nvim_buf_get_lines(source, 0, -1, false), "\n") .. "\n"
	document_valid(text)
	op.valid_text(text)
	local port = args[1] and tonumber(args[1]) or 0
	assert(port and port >= 0 and port <= 65535 and port == math.floor(port), "Invalid port")
	assert(#args <= 2, "Usage: FlashShare [port] [bind-address]")
	local owner = {
		text = text,
		revision = 0,
		history = {},
		history_floor = 0,
		history_bytes = 0,
		peers = {},
		next_id = 0,
		token = vim.fn.sha256(vim.uv.random(32)),
		source = source,
		source_tick = vim.api.nvim_buf_get_changedtick(source),
		path = path,
		filetype = vim.bo[source].filetype,
		disk = disk_content(path),
	}
	assert(owner.disk ~= false, "Source file on disk exceeds 2 MiB")
	local listener = vim.uv.new_tcp()
	owner.listener = listener
	local ok, err = listener:bind(args[2] or "127.0.0.1", port)
	if not ok then
		close(listener)
		error(err)
	end
	server = owner
	ok, err = listener:listen(
		8,
		vim.schedule_wrap(function(accept_error)
			if server ~= owner or accept_error then
				return
			end
			local socket = vim.uv.new_tcp()
			listener:accept(socket)
			if vim.tbl_count(owner.peers) >= 8 then
				close(socket)
				return
			end
			local peer
			peer = channel(socket, function(connection, message)
				if not connection.id then
					assert(
						message.type == "hello" and message.protocol == 1 and message.token == owner.token,
						"Authentication failed"
					)
					owner.next_id = owner.next_id + 1
					connection.id = owner.next_id
					connection:send({
						type = "welcome",
						id = connection.id,
						revision = owner.revision,
						text = owner.text,
						file = owner.path,
						filetype = owner.filetype,
						session = owner.token:sub(1, 16),
					})
					return
				end
				assert(message.type == "edit", "Unknown client message")
				local revision = message.revision
				assert(type(revision) == "number" and revision == math.floor(revision), "Invalid revision")
				assert(
					revision >= owner.history_floor and revision <= owner.revision,
					"Client is too far behind; reconnect"
				)
				local operation = message.operation
				-- Validate against its original base before transforming untrusted operations.
				local length = revision == owner.revision and #owner.text or owner.history[revision + 1].length
				op.validate(operation, length)
				for i = revision + 1, owner.revision do
					local _, rebased = op.transform(owner.history[i].operation, operation)
					operation = rebased
				end
				local after = op.apply(owner.text, operation)
				document_valid(after)
				owner.revision = owner.revision + 1
				owner.history[owner.revision] = { operation = operation, length = #owner.text }
				owner.history_bytes = owner.history_bytes + op.size(operation)
				while owner.revision - owner.history_floor > 1024 or owner.history_bytes > 4 * limit do
					owner.history_floor = owner.history_floor + 1
					owner.history_bytes = owner.history_bytes - op.size(owner.history[owner.history_floor].operation)
					owner.history[owner.history_floor] = nil
				end
				owner.text = after
				for _, member in pairs(owner.peers) do
					if member.id then
						member:send({
							type = "edit",
							id = connection.id,
							revision = owner.revision,
							operation = operation,
						})
					end
				end
			end, function()
				owner.peers[peer] = nil
			end)
			owner.peers[peer] = peer
			peer:read()
		end)
	)
	if not ok then
		M.stop()
		error(err)
	end
	owner.port = listener:getsockname().port
	local address = args[2] or "127.0.0.1"
	connect(
		address == "0.0.0.0" and "127.0.0.1" or address == "::" and "::1" or address,
		owner.port,
		owner.token,
		owner
	)
	notify("Port " .. owner.port .. ". Join: :FlashJoin <host> " .. owner.port .. " " .. owner.token)
end

function M.join(args)
	assert(#args == 3, "Usage: FlashJoin <host> <port> <token>")
	local port = tonumber(args[2])
	assert(port and port > 0 and port <= 65535 and port == math.floor(port), "Invalid port")
	connect(args[1], port, args[3])
end

function M.stop()
	local owner, session = server, client
	server, client = nil, nil
	if session then
		session.connection:stop()
	end
	if owner then
		close(owner.listener)
		for _, peer in pairs(owner.peers) do
			peer:stop()
		end
	end
	-- Shared scratch text stays available; never overwrite or destroy a source buffer.
	if owner and owner.session and owner.session ~= session then
		owner.session.connection:stop()
	end
end

function M.status()
	if not client then
		notify(server and "Server running; local client disconnected" or "Not sharing")
		return
	end
	notify(
		(server and "Owner" or "Guest")
			.. ", revision "
			.. (client.revision or 0)
			.. ", pending edits "
			.. #client.queue
	)
end

vim.api.nvim_create_autocmd("VimLeavePre", { group = group, callback = M.stop })
return M
