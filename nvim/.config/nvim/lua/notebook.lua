-- Optional # %% execution. No kernel, scan, or timer exists before a cell is run.
local policy = require("buffer_policy")
local shared = require("state")
local M = {}
local sessions = {}
local launch

local function source()
	return vim.b.flash_jupyter_source or vim.api.nvim_get_current_buf()
end

local function render(session, text)
	text = text:gsub("\27%[[%d;]*m", ""):gsub("\r\n", "\n"):gsub("\r", "\n"):gsub("%z", "")
	local output = session.output
	if not output or not vim.api.nvim_buf_is_valid(output) then
		output = vim.api.nvim_create_buf(false, true)
		session.output = output
		vim.bo[output].bufhidden = "hide"
		vim.bo[output].swapfile = false
		vim.b[output].flash_jupyter_source = session.buf
		vim.api.nvim_buf_set_name(output, "flash://jupyter/" .. session.buf)
		vim.keymap.set("n", "q", function()
			local win = vim.api.nvim_get_current_win()
			shared.focus_editor()
			vim.api.nvim_win_close(win, true)
		end, { buffer = output, silent = true, desc = "Close cell output" })
	end
	local lines = { session.label or "Jupyter", "" }
	vim.list_extend(lines, vim.split(text, "\n", { plain = true }))
	vim.bo[output].modifiable = true
	vim.api.nvim_buf_set_lines(output, 0, -1, false, lines)
	vim.bo[output].modifiable = false
end

function M.show()
	local session = sessions[source()]
	if not session or not session.output or not vim.api.nvim_buf_is_valid(session.output) then
		vim.notify("Jupyter: run a cell first")
		return
	end
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if vim.api.nvim_win_get_buf(win) == session.output then
			return
		end
	end
	shared.focus_editor()
	local win = vim.api.nvim_open_win(session.output, false, {
		split = "below",
		win = vim.api.nvim_get_current_win(),
		height = math.max(1, math.min(12, math.floor(vim.api.nvim_win_get_height(0) / 3))),
	})
	vim.wo[win].number = false
	vim.wo[win].relativenumber = false
	vim.wo[win].signcolumn = "no"
	vim.wo[win].wrap = true
end

local function send(session, request)
	vim.fn.chansend(session.job, vim.json.encode(request) .. "\n")
end

launch = function(session)
	local python = vim.g.flash_jupyter_python or vim.fn.exepath("python3")
	if python == "" then
		python = vim.fn.exepath("python")
	end
	if type(python) ~= "string" or vim.fn.executable(python) ~= 1 then
		vim.notify("Jupyter: put Python on PATH or set vim.g.flash_jupyter_python", vim.log.levels.ERROR)
		session.busy = false
		return
	end
	local file = vim.api.nvim_buf_get_name(session.buf)
	local cwd = file ~= "" and vim.fs.dirname(file) or vim.fn.getcwd()
	local pending, errors = "", ""
	session.ready, session.closing = false, false
	session.job = vim.fn.jobstart({ python, "-u", shared.config_root .. "/python/jupyter_bridge.py", cwd }, {
		on_stdout = function(_, data)
			pending = pending .. table.concat(data, "\n")
			while pending:find("\n", 1, true) do
				local boundary = pending:find("\n", 1, true)
				local line = pending:sub(1, boundary - 1)
				pending = pending:sub(boundary + 1)
				local ok, message = pcall(vim.json.decode, line)
				if ok and not session.closing then
					if message.type == "ready" then
						session.ready = true
						if session.code then
							send(session, { action = "run", code = session.code })
							session.code = nil
						else
							render(session, "Kernel ready: " .. message.python)
						end
					elseif message.type == "done" then
						session.busy = false
						render(session, message.text ~= "" and message.text or "[No output]")
					elseif message.type == "fatal" or message.type == "error" then
						session.busy, session.code = false, nil
						if message.type == "fatal" then
							session.ready = false
						end
						render(session, message.text)
						vim.notify("Jupyter: " .. message.text, vim.log.levels.ERROR)
					end
				end
			end
		end,
		on_stderr = function(_, data)
			errors = (errors .. table.concat(data, "\n")):sub(-8192)
		end,
		on_exit = function(_, code)
			local closing, restart = session.closing, session.restart
			session.job, session.ready, session.busy, session.code = nil, false, false, nil
			session.closing, session.restart = false, false
			if restart and vim.api.nvim_buf_is_loaded(session.buf) then
				launch(session)
			elseif not closing and code ~= 0 then
				vim.notify("Jupyter exited: " .. errors, vim.log.levels.ERROR)
			end
		end,
	})
	if session.job <= 0 then
		session.job, session.busy, session.code = nil, false, nil
		vim.notify("Jupyter: failed to start Python", vim.log.levels.ERROR)
	end
end

function M.run()
	local buf = vim.api.nvim_get_current_buf()
	if not policy.allows(buf) or vim.bo[buf].filetype ~= "python" then
		vim.notify("Jupyter: run cells from a normal Python buffer", vim.log.levels.WARN)
		return
	end
	local session = sessions[buf]
	if session and (session.busy or session.closing or (session.job and not session.ready)) then
		vim.notify("Jupyter: kernel is busy or starting; wait or interrupt", vim.log.levels.WARN)
		return
	end
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	local row = vim.api.nvim_win_get_cursor(0)[1]
	local first, last, marker = 1, #lines, ""
	for index, line in ipairs(lines) do
		if line:match("^%s*#%s*%%%%") then
			if index <= row then
				first, marker = index + 1, line
			else
				last = index - 1
				break
			end
		end
	end
	if marker:lower():find("[markdown]", 1, true) then
		vim.notify("Jupyter: Markdown cells are not executable")
		return
	end
	local code = table.concat(vim.list_slice(lines, first, last), "\n")
	if not code:find("%S") then
		vim.notify("Jupyter: empty cell")
		return
	end
	session = session or { buf = buf }
	sessions[buf] = session
	session.label = (vim.fs.basename(vim.api.nvim_buf_get_name(buf)) or "Python")
		.. " · lines "
		.. first
		.. "–"
		.. last
	session.busy = true
	render(session, "Running…")
	M.show()
	if session.ready then
		send(session, { action = "run", code = code })
	else
		session.code = code
		launch(session)
	end
end

function M.interrupt()
	local session = sessions[source()]
	if session and session.job and not session.closing then
		send(session, { action = "interrupt" })
	end
end

local function stop(session, restart)
	if not session then
		return
	end
	session.restart = restart
	if session.job then
		if not session.closing then
			session.closing = true
			send(session, { action = "stop" })
			vim.fn.chanclose(session.job, "stdin")
		end
	elseif restart then
		launch(session)
	end
end

function M.stop()
	stop(sessions[source()], false)
end
function M.restart()
	local session = sessions[source()]
	if session then
		render(session, "Restarting kernel…")
		stop(session, true)
	end
end

vim.api.nvim_create_autocmd({ "BufUnload", "BufWipeout" }, {
	callback = function(args)
		local session = sessions[args.buf]
		if session then
			stop(session, false)
			sessions[args.buf] = nil
			if session.output and vim.api.nvim_buf_is_valid(session.output) then
				vim.api.nvim_buf_delete(session.output, { force = true })
			end
		end
	end,
})
vim.api.nvim_create_autocmd("VimLeavePre", {
	callback = function()
		local jobs = {}
		for _, session in pairs(sessions) do
			stop(session, false)
			if session.job then
				jobs[#jobs + 1] = session.job
			end
		end
		-- Let the bridge reap its kernel before Neovim terminates child jobs.
		if #jobs > 0 then
			vim.fn.jobwait(jobs, 3000)
		end
	end,
})
for _, entry in ipairs({
	{ "Jr", "FlashCell", M.run, "Run Python cell" },
	{ "Jo", "FlashCellOutput", M.show, "Show cell output" },
	{ "Ji", "FlashKernelInterrupt", M.interrupt, "Interrupt Python kernel" },
	{ "JR", "FlashKernelRestart", M.restart, "Restart Python kernel" },
	{ "Jq", "FlashKernelStop", M.stop, "Stop Python kernel" },
}) do
	vim.keymap.set("n", "<leader>" .. entry[1], entry[3], { silent = true, desc = entry[4] })
	vim.api.nvim_create_user_command(entry[2], entry[3], { desc = entry[4] })
end
return M
