local shared = require("state")

-- =========================================
-- =========== NATIVE DASHBOARD ==========
-- =========================================
local dashboard_header = {
	"",
	"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⡀⠀⠀⠀⠀⠀⡀⢀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
	"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠼⠤⠤⠤⠤⠤⣧⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
	"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡸⢸⠀⠀⠀⠀⠀⠀⡟⠀⣾⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
	"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⠃⢸⠘⢏⠉⠉⠉⡽⡇⠀⢹⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
	"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⠃⠀⢸⢠⠘⡆⠀⡸⠁⡇⡀⢸⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
	"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡰⠃⠀⡖⡞⣚⣆⣹⣼⣁⣀⢳⠓⠚⢹⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
	"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡴⠁⠀⠀⡇⣧⠀⢀⡜⢳⡀⠀⢸⠀⠀⠀⢣⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
	"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠜⠁⠀⠀⠀⡇⡟⢲⡞⠒⠒⢳⣺⢸⠀⠀⠀⠈⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
	"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡠⠋⠀⠀⠀⠀⠀⡇⡷⠃⡇⠀⠀⠀⢹⣸⠀⠀⠀⠀⠘⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
	"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠞⠁⠀⠀⠀⠀⠀⣠⢿⢓⣒⣓⣀⣀⣀⡞⠛⡖⠒⠢⠀⠀⡟⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
	"⠀⠀⠀⠀⠀⠀⠀⠀⣠⠞⠁⠀⠀⠀⠀⠀⣠⠞⢹⢸⢸⠀⠀⠀⠀⠀⡇⠀⠘⢦⢰⠀⠀⡇⠘⣆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
	"⠀⠀⠀⠀⠀⢀⡤⠊⠁⠀⠀⠀⠀⠀⣠⠞⠁⠀⢸⢸⠘⠒⠲⠒⠒⠒⡇⠀⠀⠀⠳⡄⠀⡇⠀⠈⢆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
	"⠀⢀⣠⠴⠊⠁⠀⠀⠀⠀⠀⢀⡤⡎⠁⠀⠀⠀⢸⢸⠀⠀⢀⠀⠀⠀⡇⠀⠀⠀⢀⠈⢦⡗⠀⠀⠈⢣⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡗⠒⡁⠀⠀⠀⠀⠀⠀⠀",
	"⠈⠁⠀⠀⠀⠀⠀⠀⢀⡠⠖⠁⠀⡇⠀⠀⠀⠀⠚⣾⠒⣒⠚⣢⠀⢰⠓⠒⠒⠒⠺⠀⠀⣟⢆⠀⠀⠀⡟⣄⠀⠀⠀⠀⠀⠀⠀⠀⢀⣾⣑⡞⣹⡄⠀⠀⠀⠀⠀⠀",
	"⠀⠀⠀⠀⢀⣀⡤⠚⠁⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⣿⢰⠀⠀⠀⠀⢸⢰⠀⠀⠀⠀⡇⠀⡇⠀⠙⠢⣄⡇⠈⠣⡀⠀⠀⠀⠀⣀⡴⣋⢼⡏⠠⢻⠘⢄⠀⠀⠀⠀⠀",
	"⢀⠤⠔⠊⠉⠀⡇⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⣿⠘⠒⠒⢲⠒⢺⢸⠀⠀⠀⠀⡇⠀⡇⠀⠀⠀⠀⡏⠑⠒⢺⠓⠲⠶⡟⠓⠉⡇⢸⣇⣠⢸⠀⠀⡗⠦⣀⠀⠀",
	"⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⣿⠀⠀⠀⢸⠀⢸⢸⠀⠀⠀⠀⡅⠀⣇⣀⣀⣀⠀⡇⠀⠠⢼⠤⠤⣤⣧⣤⣤⣧⣼⣧⣼⢸⠤⠤⠇⣀⣈⣉⡁",
	"⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⢀⣀⣿⠀⠤⠤⠼⠔⢺⢸⠀⠀⠀⠀⣏⣀⠧⡤⡤⣖⢒⣷⣚⡻⠭⠯⠭⠗⠒⠓⠒⠛⢻⣏⣹⢸⠉⠉⠁⠀⠐⠒⠂",
	"⠀⠀⠀⠀⠀⠀⡇⠀⠀⣀⡀⠤⠤⡗⠒⠈⠉⠁⠀⢸⠀⠀⠀⣀⣠⣼⢸⠀⠀⠀⠀⣇⠦⠽⠚⠒⠉⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⡟⢻⢸⣀⠀⠀⠀⠀⠀⠀",
	"⠀⠀⢀⣀⠤⠔⡗⠉⠁⠀⠀⠀⠀⡇⠀⠀⠀⢀⡠⣼⠖⡘⢍⠰⡡⢺⢸⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠀⢀⠁⠀⠸⠇⠸⠼⠀⠈⠆⠢⠄⠀⠀",
	"⠐⠉⠁⠀⠀⠀⡇⠀⠀⠀⠀⠀⢀⣧⠤⠖⠋⢽⣠⢃⠞⣈⡶⠜⠒⢹⢸⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⠔⡠⠌⢁⡐⠒⢒⡠⠀⢓⡈⠄⠀⠀⠀",
	"⠀⠀⠀⠀⠀⠀⡇⠀⢀⡠⠔⠚⡍⠰⠎⣠⠒⣢⡥⢾⠋⠁⠀⠀⠀⢸⢸⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
	"⠈⠉⢦⡀⠀⣀⠧⠚⠉⠒⠒⠒⠃⢀⣴⠗⠋⠁⡇⢸⠀⠐⠂⠢⠤⢼⢸⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
	"⠀⠀⠀⢣⠈⠉⠉⠉⠉⠻⣉⡶⠖⠋⠀⠀⠀⠀⡇⢸⠀⠸⡉⠏⢐⣾⢸⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
	"⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⣖⠒⠒⠠⡀⠀⠀⡇⢸⠀⠀⡱⠈⠁⣼⢸⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀",
}
local dashboard_namespace = vim.api.nvim_create_namespace("nopack-dashboard")

local dashboard_win
local function open_dashboard()
	if dashboard_win and vim.api.nvim_win_is_valid(dashboard_win) then
		vim.api.nvim_set_current_win(dashboard_win)
		return
	end
	local source = vim.api.nvim_get_current_win()
	local source_buf = vim.api.nvim_win_get_buf(source)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].filetype = "nopack_dashboard"
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "win",
		win = source,
		row = 0,
		col = 0,
		width = vim.api.nvim_win_get_width(source),
		height = vim.api.nvim_win_get_height(source),
		style = "minimal",
		border = "none",
	})
	dashboard_win = win
	vim.wo[win][0].winblend = 0
	vim.wo[win][0].winhighlight = "Normal:Normal,NormalFloat:Normal,EndOfBuffer:EndOfBuffer"
	vim.wo[win][0].cursorline = true
	vim.wo[win][0].cursorlineopt = "line"
	vim.wo[win][0].list = false
	vim.wo[win][0].wrap = false
	local group = vim.api.nvim_create_augroup("nopack-dashboard-window", { clear = true })
	local closed = false
	local function source_is_empty()
		return vim.api.nvim_win_is_valid(source)
			and vim.api.nvim_win_get_buf(source) == source_buf
			and #vim.fn.getbufinfo({ buflisted = 1 }) == 1
			and vim.api.nvim_buf_get_name(source_buf) == ""
			and not vim.bo[source_buf].modified
			and vim.api.nvim_buf_line_count(source_buf) == 1
			and vim.api.nvim_buf_get_lines(source_buf, 0, 1, false)[1] == ""
	end
	local function close()
		if closed then
			return
		end
		closed = true
		vim.api.nvim_del_augroup_by_id(group)
		dashboard_win = nil
		local focused = vim.api.nvim_get_current_win() == win
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
		if focused and vim.api.nvim_win_is_valid(source) then
			vim.api.nvim_set_current_win(source)
		end
	end
	vim.keymap.set("n", "<Esc>", close, { buf = buf, nowait = true, desc = "Close dashboard" })
	vim.api.nvim_create_autocmd("QuitPre", {
		group = group,
		buffer = buf,
		callback = function()
			if vim.api.nvim_get_current_win() == win and source_is_empty() then
				vim.schedule(function()
					if not vim.api.nvim_win_is_valid(win) and source_is_empty() then
						vim.cmd("quit")
					end
				end)
			end
		end,
	})
	vim.api.nvim_create_autocmd("WinClosed", {
		group = group,
		pattern = { tostring(win), tostring(source) },
		callback = close,
	})
	vim.api.nvim_create_autocmd("WinLeave", {
		group = group,
		buffer = buf,
		callback = function()
			vim.schedule(close)
		end,
	})
	-- A direct :edit belongs in the editor, never in the dashboard's float.
	vim.api.nvim_create_autocmd("BufEnter", {
		group = group,
		callback = function(args)
			if vim.api.nvim_get_current_win() == win and args.buf ~= buf then
				close()
				if vim.api.nvim_win_is_valid(source) then
					vim.api.nvim_win_set_buf(source, args.buf)
				end
			end
		end,
	})

	local entries = {
		{
			"f",
			"Find file",
			function()
				shared.find_files(shared.project_root(), "Find files")
			end,
		},
		{
			"r",
			"Recent files",
			function()
				local files = vim.tbl_filter(function(file)
					return file ~= "" and vim.fn.filereadable(file) == 1
				end, vim.v.oldfiles)
				shared.open_picker("Recent files", { items = shared.file_items(files) })
			end,
		},
		{ "p", "Select session", shared.select_session },
		{
			"n",
			"New file",
			function()
				vim.cmd.enew()
				vim.cmd.startinsert()
			end,
		},
		{
			"c",
			"Config",
			function()
				vim.cmd.edit(vim.fn.fnameescape(vim.fn.stdpath("config") .. "/init.lua"))
			end,
		},
		{
			"q",
			"Quit",
			function()
				vim.cmd("qa")
			end,
		},
	}
	local button_rows = {}
	local function render()
		local width = vim.api.nvim_win_get_width(win)
		local lines = { "", "" }
		local header_start = #lines
		local header_width = 0
		for _, line in ipairs(dashboard_header) do
			header_width = math.max(header_width, vim.fn.strdisplaywidth(line))
		end
		local header_left = math.max(0, math.floor((width - header_width) / 2))
		for _, line in ipairs(dashboard_header) do
			lines[#lines + 1] = string.rep(" ", header_left) .. line
		end
		lines[#lines + 1] = ""
		lines[#lines + 1] = ""

		button_rows = {}
		for _, entry in ipairs(entries) do
			local button_width = math.min(50, width)
			local gap = math.max(1, button_width - vim.fn.strdisplaywidth(entry[2]) - vim.fn.strdisplaywidth(entry[1]))
			local text = entry[2] .. string.rep(" ", gap) .. entry[1]
			local left = math.max(0, math.floor((width - vim.fn.strdisplaywidth(text)) / 2))
			lines[#lines + 1] = string.rep(" ", left) .. text
			button_rows[entry[1]] = { row = #lines, left = left }
			lines[#lines + 1] = ""
		end
		local footer = "https://sunwook-hwang.github.io"
		lines[#lines + 1] = string.rep(" ", math.max(0, math.floor((width - vim.fn.strdisplaywidth(footer)) / 2)))
			.. footer
		vim.bo[buf].modifiable = true
		vim.api.nvim_buf_clear_namespace(buf, dashboard_namespace, 0, -1)
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
		vim.bo[buf].modifiable = false

		for index = 1, #dashboard_header do
			vim.api.nvim_buf_add_highlight(buf, dashboard_namespace, "Include", header_start + index - 1, 0, -1)
		end
		for _, button in pairs(button_rows) do
			vim.api.nvim_buf_add_highlight(buf, dashboard_namespace, "Keyword", button.row - 1, button.left, -1)
		end
		vim.api.nvim_buf_add_highlight(buf, dashboard_namespace, "Type", #lines - 1, 0, -1)
	end
	render()
	local function activate(entry)
		if vim.api.nvim_get_current_buf() ~= buf then
			return
		end
		close()
		if vim.api.nvim_win_is_valid(source) then
			vim.api.nvim_set_current_win(source)
		end
		shared.focus_editor()
		entry[3]()
	end
	for _, entry in ipairs(entries) do
		local selected = entry
		vim.keymap.set("n", entry[1], function()
			activate(selected)
		end, { buf = buf, nowait = true, silent = true, desc = selected[2] })
	end
	local moving = false
	local function selection_index()
		local row = vim.api.nvim_win_get_cursor(win)[1]
		local nearest, distance = 1, math.huge
		for index, entry in ipairs(entries) do
			local candidate = button_rows[entry[1]].row
			if math.abs(candidate - row) < distance then
				nearest, distance = index, math.abs(candidate - row)
			end
		end
		return nearest
	end
	local function select_entry(index)
		index = (index - 1) % #entries + 1
		local button = button_rows[entries[index][1]]
		moving = true
		vim.api.nvim_win_set_cursor(win, { button.row, button.left + 3 })
		moving = false
	end
	for _, spec in ipairs({ { "j", 1 }, { "<Down>", 1 }, { "k", -1 }, { "<Up>", -1 } }) do
		local key, delta = spec[1], spec[2]
		vim.keymap.set("n", key, function()
			select_entry(selection_index() + delta)
		end, {
			buf = buf,
			nowait = true,
			silent = true,
			desc = delta > 0 and "Next dashboard item" or "Previous dashboard item",
		})
	end
	vim.keymap.set("n", "<CR>", function()
		activate(entries[selection_index()])
	end, { buf = buf, nowait = true, silent = true, desc = "Open dashboard item" })
	vim.api.nvim_create_autocmd("CursorMoved", {
		buffer = buf,
		callback = function()
			if not moving and vim.api.nvim_get_current_buf() == buf then
				local index = selection_index()
				if vim.api.nvim_win_get_cursor(win)[1] ~= button_rows[entries[index][1]].row then
					select_entry(index)
				end
			end
		end,
	})
	vim.api.nvim_create_autocmd({ "VimResized", "WinResized" }, {
		group = group,
		callback = function()
			if closed or not vim.api.nvim_win_is_valid(source) then
				return
			end
			local selected = selection_index()
			local width = vim.api.nvim_win_get_width(source)
			local height = vim.api.nvim_win_get_height(source)
			if vim.api.nvim_win_get_width(win) == width and vim.api.nvim_win_get_height(win) == height then
				return
			end
			vim.api.nvim_win_set_config(win, {
				width = width,
				height = height,
			})
			render()
			select_entry(selected)
		end,
	})
	select_entry(1)
end

shared.map("n", "<leader>A", open_dashboard, "Open dashboard")
vim.api.nvim_create_autocmd("VimEnter", {
	callback = function()
		if
			vim.fn.argc() == 0
			and vim.api.nvim_buf_get_name(0) == ""
			and vim.bo.buftype == ""
			and vim.api.nvim_buf_line_count(0) == 1
			and vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] == ""
		then
			open_dashboard()
		end
	end,
})
