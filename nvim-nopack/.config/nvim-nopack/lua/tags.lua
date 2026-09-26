local shared = require("state")

-- =========================================
-- ====== CTAGS: INDEX / NAVIGATION ======
-- =========================================
-- Universal / Exuberant Ctags only. No automatic installation.
-- gd builds the project once; InsertEnter and outline index only the current file.
-- Saves replace that file's tags after 750ms; failed jobs preserve the old cache.
local ctags_checked, ctags_kind, ctags_command
local tag_work_sequence = 0
local function ctags_candidates()
	local candidates, seen = {}, {}
	local function add(path)
		if path and path ~= "" and not seen[path] then
			seen[path] = true
			candidates[#candidates + 1] = path
		end
	end
	add(vim.g.nopack_ctags)
	local executable = vim.fn.has("win32") == 1 and "ctags.exe" or "ctags"
	local separator = vim.fn.has("win32") == 1 and ";" or ":"
	for _, directory in ipairs(vim.split(vim.env.PATH or "", separator, { plain = true, trimempty = true })) do
		add(vim.fs.joinpath(directory, executable))
	end
	return candidates
end
local ctags_probe
local function ctags_available(quiet, callback)
	local candidates = ctags_candidates()
	local checked = table.concat(candidates, "\0")
	local function answer(available)
		if not available and not quiet then
			vim.notify(
				"Universal or Exuberant Ctags required; check ctags --version or g:nopack_ctags",
				vim.log.levels.WARN
			)
		end
		callback(available)
	end
	if ctags_probe and not shared.running["ctags-probe"] then
		ctags_probe, ctags_checked = nil, nil
	end
	if ctags_probe and ctags_probe.key == checked then
		ctags_probe.waiters[#ctags_probe.waiters + 1] = answer
		return
	end
	if ctags_checked == checked and not ctags_probe then
		answer(ctags_kind ~= nil)
		return
	end
	local probe = { key = checked, waiters = { answer } }
	ctags_probe = probe
	ctags_checked, ctags_kind, ctags_command = checked, nil, nil
	local index, fallback = 0, nil
	local function finish()
		if ctags_probe ~= probe then
			return
		end
		ctags_probe = nil
		if not ctags_kind and fallback then
			ctags_kind, ctags_command = "exuberant", fallback
		end
		for _, waiter in ipairs(probe.waiters) do
			waiter(ctags_kind ~= nil)
		end
	end
	local next_candidate
	next_candidate = function()
		if ctags_probe ~= probe then
			return
		end
		index = index + 1
		while candidates[index] and vim.fn.executable(candidates[index]) == 0 do
			index = index + 1
		end
		local command = candidates[index]
		if not command then
			finish()
			return
		end
		shared.run_command("ctags-probe", { command, "--options=NONE", "--version" }, {
			quiet = true,
			timeout = 2000,
			max_bytes = 65536,
			failed = next_candidate,
		}, function(version)
			if ctags_probe ~= probe then
				return
			end
			if version:find("Universal Ctags", 1, true) then
				ctags_kind, ctags_command = "universal", command
				finish()
			else
				if version:find("Exuberant Ctags", 1, true) then
					fallback = fallback or command
				end
				next_candidate()
			end
		end)
	end
	next_candidate()
end
function shared.tag_context(buf)
	if
		not vim.api.nvim_buf_is_valid(buf)
		or vim.bo[buf].buftype ~= ""
		or vim.bo[buf].filetype == "netrw"
		or vim.b[buf].nopack_large_file
	then
		return
	end
	local file = vim.api.nvim_buf_get_name(buf)
	if file == "" then
		return
	end
	file = vim.uv.fs_realpath(file) or file
	local root = shared.find_project(vim.fs.dirname(file))
	return root, file
end
local function tag_project(root)
	if not shared.tag_projects[root] then
		vim.fn.mkdir(shared.nopack_data .. "/tags", "p")
		shared.tag_projects[root] = {
			path = shared.nopack_data .. "/tags/" .. vim.fn.sha256(root),
			pending = {},
			waiters = {},
			quiet = true,
			generation = 0,
		}
	end
	return shared.tag_projects[root]
end
local function attach_tags(buf)
	local root = shared.tag_context(buf)
	local project = root and shared.tag_projects[root]
	if project then
		vim.bo[buf].tags = vim.fn.escape(project.path, " ,\\") .. "," .. vim.go.tags
	end
end
local function tag_command()
	local command = { ctags_command, "--options=NONE" }
	vim.list_extend(
		command,
		ctags_kind == "exuberant" and { "--format=2", "--extra=-q", "--tag-relative=no" }
			or { "--output-format=e-ctags", "--extras=-q", "--tag-relative=never" }
	)
	return vim.list_extend(command, {
		"--fields=+nK",
		"--sort=yes",
		"--links=no",
		"--langmap=C++:+.ipp,Python:+.pyi",
		"--languages=C,C++,Python",
		"-f",
		"-",
	})
end
function shared.tag_filename(line)
	local file = line:match("^[^\t]+\t([^\t]+)") or ""
	return (file:gsub("\\(.)", { t = "\t", r = "\r", n = "\n", ["\\"] = "\\" }))
end
local function run_tag_build(root, full, changed, after, failed, quiet)
	local project = tag_project(root)
	project.generation = project.generation + 1
	local generation = project.generation
	shared.cancel_command("ctags:" .. root)
	ctags_available(quiet, function(available)
		if shared.tag_projects[root] ~= project or project.generation ~= generation then
			return
		end
		if not available then
			if failed then
				failed()
			end
			return
		end
		local function save(output)
			-- Pure Lua/file IO runs in libuv's worker pool; only publication touches the editor.
			tag_work_sequence = tag_work_sequence + 1
			local temporary = project.path .. "." .. vim.fn.getpid() .. "." .. tag_work_sequence .. ".tmp"
			local work
			work = vim.uv.new_work(
				function(content, path, target, replaced_files, replace_all)
					local ok, err = pcall(function()
						local lines, replaced = {}, {}
						for file in replaced_files:gmatch("[^%z]+") do
							replaced[file] = true
						end
						for line in content:gmatch("[^\n]+") do
							if not line:match("^!_TAG_") then
								lines[#lines + 1] = line
							end
						end
						if not replace_all then
							local input = io.open(path, "r")
							if input then
								for line in input:lines() do
									local file = line:match("^[^\t]+\t([^\t]+)") or ""
									file = file:gsub("\\(.)", { t = "\t", r = "\r", n = "\n", ["\\"] = "\\" })
									if not line:match("^!_TAG_") and not replaced[file] then
										lines[#lines + 1] = line
									end
								end
								input:close()
							end
							table.sort(lines)
						end
						local output_file = assert(io.open(target, "w"))
						local wrote, write_err = pcall(function()
							assert(output_file:write("!_TAG_FILE_SORTED\t1\t/0=unsorted, 1=sorted/\n"))
							for _, line in ipairs(lines) do
								assert(output_file:write(line, "\n"))
							end
						end)
						local closed, close_err = output_file:close()
						assert(wrote, write_err)
						assert(closed, close_err)
					end)
					return ok, ok and "" or tostring(err)
				end,
				vim.schedule_wrap(function(ok, err)
					work = nil
					if shared.tag_projects[root] ~= project or project.generation ~= generation then
						vim.fn.delete(temporary)
						return
					end
					if ok then
						ok, err = vim.uv.fs_rename(temporary, project.path)
					end
					vim.fn.delete(temporary)
					if not ok then
						vim.notify(tostring(err), vim.log.levels.WARN)
						if failed then
							failed()
						end
						return
					end
					if full then
						project.ready = true
					end
					for _, buf in ipairs(vim.api.nvim_list_bufs()) do
						attach_tags(buf)
					end
					if after then
						after(output)
					end
				end)
			)
			work:queue(output, project.path, temporary, table.concat(changed, "\0"), full)
		end
		local function run(command, stdin)
			shared.run_command("ctags:" .. root, command, {
				cwd = root,
				stdin = stdin,
				timeout = full and 120000 or 10000,
				max_bytes = (full and 64 or 16) * 1024 * 1024,
				failed = failed,
			}, save)
		end
		if not full then
			-- Use stdin rather than argv so a burst of saves cannot exceed ARG_MAX.
			table.sort(changed)
			run(vim.list_extend(tag_command(), { "-L", "-" }), table.concat(changed, "\n") .. "\n")
		elseif vim.uv.fs_stat(root .. "/.git") then
			shared.run_command(
				"ctags:" .. root,
				{ "git", "ls-files", "-z", "--cached", "--others", "--exclude-standard" },
				{
					cwd = root,
					timeout = 30000,
					max_bytes = 16 * 1024 * 1024,
					failed = failed,
				},
				function(output)
					local sources, seen = {}, {}
					for _, file in ipairs(shared.records(output, "\0")) do
						local path = root .. "/" .. file
						if not file:find("[\r\n]") and not seen[path] and vim.fn.filereadable(path) == 1 then
							sources[#sources + 1], seen[path] = path, true
						end
					end
					if #sources == 0 then
						save("")
					else
						run(vim.list_extend(tag_command(), { "-L", "-" }), table.concat(sources, "\n") .. "\n")
					end
				end
			)
		else
			local command = tag_command()
			for _, dir in ipairs({
				".git",
				".venv",
				"venv",
				"node_modules",
				"__pycache__",
				"build",
				"build-*",
				"cmake-build-*",
				"dist",
			}) do
				command[#command + 1] = "--exclude=" .. dir
			end
			run(vim.list_extend(command, { "-R", root }))
		end
	end)
end
function shared.build_tags(root, full, files, after, failed, quiet)
	local project = tag_project(root)
	for _, file in ipairs(files or {}) do
		project.pending[file] = true
	end
	project.full = project.full or full
	project.quiet = project.quiet and quiet == true
	if after or failed then
		project.waiters[#project.waiters + 1] = { after = after, failed = failed }
	end
	if project.active or (not project.full and not next(project.pending)) then
		return
	end
	-- Snapshot this batch so saves and requests arriving during it remain queued.
	local batch = { files = project.pending, full = project.full, waiters = project.waiters, quiet = project.quiet }
	project.pending, project.waiters, project.full, project.quiet = {}, {}, false, true
	project.active = batch
	local function finish(succeeded, output)
		if shared.tag_projects[root] ~= project or project.active ~= batch then
			return
		end
		project.active = nil
		local queued = project.full or next(project.pending)
		if not succeeded then
			for file in pairs(batch.files) do
				project.pending[file] = true
			end
		end
		local generation = project.generation
		shared.finish_tag_waiters(batch.waiters, succeeded, output)
		if queued and shared.tag_projects[root] == project and project.generation == generation then
			shared.build_tags(root, false, nil, nil, nil, true)
		end
	end
	run_tag_build(root, batch.full, vim.tbl_keys(batch.files), function(output)
		finish(true, output)
	end, function()
		finish(false)
	end, batch.quiet)
end
local function request_tags(full, after, quiet)
	shared.focus_editor()
	local buf, win = vim.api.nvim_get_current_buf(), vim.api.nvim_get_current_win()
	local root, file = shared.tag_context(buf)
	if not root or file:find("[\r\n]") then
		return
	end
	shared.build_tags(root, full, { file }, after and function()
		if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == buf then
			vim.api.nvim_win_call(win, after)
		else
			vim.notify("Ctags index ready; repeat navigation in the desired file")
		end
	end, nil, quiet)
end
local function ctags_definition()
	shared.focus_editor()
	local root = shared.tag_context(vim.api.nvim_get_current_buf())
	local word = vim.fn.expand("<cword>")
	if not root or word == "" then
		return
	end
	if vim.bo.modified then
		vim.notify("Ctags uses saved files; save edits to update definitions")
	end
	local function jump()
		attach_tags(vim.api.nvim_get_current_buf())
		local tags = vim.fn.taglist("\\C^\\V" .. vim.fn.escape(word, "\\") .. "\\m$", vim.fn.expand("%:p"))
		if #tags == 0 then
			vim.notify("No definition in saved project files: " .. word)
		else
			vim.cmd("tjump " .. vim.fn.fnameescape(word))
		end
	end
	if tag_project(root).ready then
		jump()
	else
		request_tags(true, jump)
	end
end
shared.map("n", "g<C-t>", "<Cmd>pop<CR>", "Return from ctags definition")
vim.api.nvim_create_user_command("CtagsUpdate", function()
	request_tags(true)
end, {})
vim.api.nvim_create_user_command("CtagsClearAll", function()
	for root, project in pairs(shared.tag_projects) do
		shared.cancel_tag_build(root, project)
	end
	shared.tag_projects = {}
	vim.fn.delete(shared.nopack_data .. "/tags", "rf")
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		vim.b[buf].nopack_tags_requested = nil
	end
	vim.notify("Cleared all managed ctags caches")
end, {})
vim.api.nvim_create_autocmd("BufEnter", {
	callback = function(args)
		attach_tags(args.buf)
	end,
})
local function ensure_tag_completion(buf)
	if
		vim.b[buf].nopack_tags_requested
		or vim.b[buf].nopack_large_file
		or not vim.tbl_contains({ "c", "cpp", "python" }, vim.bo[buf].filetype)
		or #vim.lsp.get_clients({ bufnr = buf, method = "textDocument/completion" }) > 0
	then
		return
	end
	local root, file = shared.tag_context(buf)
	if not root or file:find("[\r\n]") then
		return
	end
	vim.b[buf].nopack_tags_requested = true
	shared.build_tags(root, false, { file }, nil, function()
		if vim.api.nvim_buf_is_valid(buf) then
			vim.b[buf].nopack_tags_requested = nil
		end
	end, true)
end
vim.api.nvim_create_autocmd({ "InsertEnter", "LspDetach" }, {
	callback = function(args)
		vim.schedule(function()
			if vim.api.nvim_buf_is_valid(args.buf) then
				ensure_tag_completion(args.buf)
			end
		end)
	end,
})
vim.api.nvim_create_autocmd("BufWritePost", {
	callback = function(args)
		local root, file = shared.tag_context(args.buf)
		local project = root and shared.tag_projects[root]
		if not project or file:find("[\r\n]") then
			return
		end
		project.pending[file] = true
		local version = {}
		project.save_version = version
		vim.defer_fn(function()
			if shared.tag_projects[root] == project and project.save_version == version then
				shared.build_tags(root, false, nil, nil, nil, true)
			end
		end, 750)
	end,
})

local function definition_target_name(item)
	local location = item.location
	local uri = location.uri or location.targetUri
	local range = location.targetSelectionRange or location.range
	if not uri or not range then
		return
	end
	local filename = vim.uri_to_fname(uri)
	local row = range.start.line
	local line
	local target_buf = vim.fn.bufnr(filename)
	if target_buf > 0 and vim.api.nvim_buf_is_loaded(target_buf) then
		line = vim.api.nvim_buf_get_lines(target_buf, row, row + 1, false)[1]
	elseif vim.fn.filereadable(filename) == 1 then
		line = vim.fn.readfile(filename, "", row + 1)[row + 1]
	end
	if not line then
		return
	end
	local ok_start, start_byte = pcall(vim.str_byteindex, line, item.encoding, range.start.character, false)
	local ok_end, end_byte = pcall(vim.str_byteindex, line, item.encoding, range["end"].character, false)
	if not ok_start or not ok_end then
		return
	end
	local name = line:sub(start_byte + 1, end_byte)
	return name:match("^[_%a][_%w]*$") and name or nil
end

-- Prefer connected providers; failed, empty or timed-out requests use saved tags.
shared.map("n", "gd", function()
	shared.focus_editor()
	local buf, win = vim.api.nvim_get_current_buf(), vim.api.nvim_get_current_win()
	local source_word = vim.fn.expand("<cword>")
	if shared.definition_requests[buf] then
		shared.definition_requests[buf]()
	end
	if #vim.lsp.get_clients({ bufnr = buf, method = "textDocument/definition" }) == 0 then
		ctags_definition()
		return
	end
	local position, tick = vim.api.nvim_win_get_cursor(win), vim.api.nvim_buf_get_changedtick(buf)
	local done, cancel = false, nil
	local function stop()
		done = true
		shared.definition_requests[buf] = nil
		if cancel then
			cancel()
		end
	end
	shared.definition_requests[buf] = stop
	local function finish(results)
		if done then
			return
		end
		stop()
		-- A late response must not redirect another window, file, or a moved cursor.
		if
			not vim.api.nvim_win_is_valid(win)
			or vim.api.nvim_get_current_win() ~= win
			or vim.api.nvim_win_get_buf(win) ~= buf
			or vim.api.nvim_buf_get_changedtick(buf) ~= tick
			or not vim.deep_equal(vim.api.nvim_win_get_cursor(win), position)
		then
			return
		end
		local locations = {}
		for id, response in pairs(results) do
			local client = vim.lsp.get_client_by_id(id)
			local result = response.result
			if client and not response.err and result and result ~= vim.NIL then
				for _, location in ipairs(vim.islist(result) and result or { result }) do
					locations[#locations + 1] = { location = location, encoding = client.offset_encoding }
				end
			end
		end
		if #locations > 1 and source_word ~= "" then
			local exact = {}
			for _, item in ipairs(locations) do
				if definition_target_name(item) == source_word then
					exact[#exact + 1] = item
				end
			end
			if #exact > 0 then
				locations = exact
			end
		end
		if #locations == 0 then
			ctags_definition()
		elseif #locations == 1 then
			vim.lsp.util.show_document(locations[1].location, locations[1].encoding, { focus = true })
		else
			vim.ui.select(locations, {
				prompt = "Definitions:",
				format_item = function(item)
					local loc = item.location
					return vim.uri_to_fname(loc.uri or loc.targetUri)
						.. ":"
						.. ((loc.range or loc.targetSelectionRange).start.line + 1)
				end,
			}, function(item)
				if item then
					vim.lsp.util.show_document(item.location, item.encoding, { focus = true })
				end
			end)
		end
	end
	cancel = vim.lsp.buf_request_all(buf, "textDocument/definition", function(client)
		return vim.lsp.util.make_position_params(win, client.offset_encoding)
	end, finish)
	vim.defer_fn(function()
		finish({})
	end, 5000)
end, "Go to definition: LSP, then ctags")
