local shared = require("state")

-- =========================================
-- ======= FILE TREE: NETRW OPTIONS ======
-- =========================================
-- NvimTree 대체: 기본 netrw의 트리 모드와 버퍼 전용 키를 설정합니다.
-- Enter/l: 열기·접기, h: 상위 가지 접기, Space nr: 새로고침, g?: 조작 도움말.
shared.focus_editor = nil
function shared.netrw_command(command)
	local saved_lazyredraw = vim.o.lazyredraw
	vim.o.lazyredraw = true
	local ok, err = pcall(vim.cmd, command)
	vim.api.nvim_exec_autocmds("User", { pattern = "NopackNetrwRedraw", modeline = false })
	vim.o.lazyredraw = saved_lazyredraw
	if not ok then
		error(err)
	end
end

function shared.netrw_refresh()
	local root = vim.w.netrw_treetop or vim.b.netrw_curdir
	-- Drop deleted/renamed branches before netrw rereads expanded directories.
	local tree = vim.w.netrw_treedict
	if tree then
		for path in pairs(tree) do
			if vim.fn.isdirectory(path) == 0 then
				tree[path] = nil
			end
		end
		vim.w.netrw_treedict = tree
	end
	-- The refresh plug routes through BrowseChgDir, which can treat an absolute
	-- tree root as a file and open it in the editor window. Refresh in place.
	shared.netrw_command("call netrw#Call('NetrwRefresh', 1, " .. vim.fn.string(root) .. ")")
end

local function netrw_set_tree_root(path)
	if path == "" then
		path = vim.fn["netrw#Call"]("NetrwTreePath", vim.w.netrw_treetop)
	end
	-- Explicit directory syntax avoids BrowseChgDir's absolute-path file branch.
	shared.netrw_command("call netrw#SetTreetop(1, " .. vim.fn.string(path:gsub("/+$", "") .. "/") .. ")")
end

function shared.sidebar_width()
	return math.max(20, math.min(40, math.floor(vim.o.columns * 0.25)))
end
-- winfixwidth belongs to the window itself, so release it when its sidebar leaves.
function shared.fix_sidebar_width(win)
	local saved = vim.w[win].nopack_sidebar_width or { value = vim.wo[win].winfixwidth }
	saved.buf = vim.api.nvim_win_get_buf(win)
	vim.w[win].nopack_sidebar_width = saved
	vim.wo[win][0].winfixwidth = true
end
vim.api.nvim_create_autocmd("BufWinEnter", {
	group = vim.api.nvim_create_augroup("nopack-sidebar-width", { clear = true }),
	callback = function(args)
		local saved = vim.w.nopack_sidebar_width
		if saved and saved.buf ~= args.buf then
			vim.opt_local.winfixwidth = saved.value
			vim.w.nopack_sidebar_width = nil
		end
	end,
})
local function netrw_help()
	local lines = {
		"netrw file explorer · Nopack configuration",
		"",
		"Navigation / Opening",
		"  j / k             Move down / up",
		"  gg / G            First / last line",
		"  Enter / l         Expand or collapse directory / open file",
		"  h                 Collapse parent branch",
		"  -                 Go to parent directory",
		"  o / v / t         Open in horizontal split / vertical split / tab",
		"  p                 Preview file",
		"  Ctrl-h/j/k/l      Move to left / lower / upper / right window",
		"  Space e           Toggle file explorer",
		"",
		"Display / Refresh",
		"  Space nr          Refresh tree",
		"  gh                Toggle hidden files",
		"  Space nh          Edit file hiding patterns",
		"  s / r             Change sort order / reverse sorting",
		"",
		"File Operations",
		"  % / d             New file / new directory",
		"  R / D             Rename / delete",
		"  mf / mu           Toggle file mark / unmark all files",
		"  mt                Set current directory as copy/move target",
		"  mc / mm           Copy / move marked files to target",
		"",
		"g? / q / Esc: Close help · j/k: Scroll",
	}
	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].bufhidden = "wipe"
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false
	local width = math.max(1, math.min(78, vim.o.columns - 4))
	local height = math.max(1, math.min(#lines, vim.o.lines - 6))
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		row = math.max(0, math.floor((vim.o.lines - height - 2) / 2)),
		col = math.max(0, math.floor((vim.o.columns - width - 2) / 2)),
		width = width,
		height = height,
		style = "minimal",
		border = "rounded",
		title = " netrw help ",
	})
	vim.wo[win][0].wrap = true
	local function close()
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
	end
	for _, key in ipairs({ "g?", "q", "<Esc>" }) do
		vim.keymap.set("n", key, close, { buf = buf, silent = true, nowait = true, desc = "Close netrw help" })
	end
	vim.api.nvim_create_autocmd("BufLeave", {
		buffer = buf,
		once = true,
		callback = function()
			vim.schedule(close)
		end,
	})
end
local function netrw_cursor_paths()
	local parent, directory = vim.b.netrw_curdir, vim.b.netrw_curdir
	if vim.w.netrw_liststyle == 3 and vim.w.netrw_treetop then
		local ok, tree_path = pcall(vim.fn["netrw#Call"], "NetrwTreePath", vim.w.netrw_treetop)
		if ok and type(tree_path) == "string" and tree_path ~= "" then
			tree_path = vim.fs.normalize(tree_path)
			local stat = vim.uv.fs_lstat(tree_path)
			local target = stat and stat.type == "link" and vim.uv.fs_stat(tree_path)
			local parent_directory = (stat or {}).type == "directory"
				or ((target or {}).type == "directory" and not vim.fn.getline("."):find("\t -->", 1, true))
			if vim.fn.getline("."):sub(-1) == "/" then
				directory = tree_path
				parent = vim.fs.dirname(directory)
			elseif not parent_directory then
				parent, directory = vim.fs.dirname(tree_path), vim.fs.dirname(tree_path)
			else
				parent, directory = tree_path, tree_path
			end
		end
	end
	return parent, directory
end
local function netrw_at_cursor(function_name, use_directory, append_path, ...)
	local parent, directory = netrw_cursor_paths()
	local path = use_directory and directory or parent
	vim.b.netrw_curdir = path
	local args = { ... }
	local encoded = { vim.fn.string(function_name) }
	for _, arg in ipairs(args) do
		encoded[#encoded + 1] = vim.fn.string(arg)
	end
	if append_path then
		encoded[#encoded + 1] = vim.fn.string(path)
	end
	shared.netrw_command("call netrw#Call(" .. table.concat(encoded, ", ") .. ")")
end
local function netrw_cursor_path()
	local parent = netrw_cursor_paths()
	local word = vim.fn["netrw#Call"]("NetrwGetWord")
	if type(word) ~= "string" or word == "" or word == "./" or word == "../" then
		return
	end
	local path = vim.fs.joinpath(parent, (word:gsub("/+$", "")))
	if word:sub(-1) == "/" then
		return vim.uv.fs_lstat(path) and path or nil
	end
	local display = vim.fn.getline("."):match("^[^\t]*")
	local suffix
	for _, candidate in ipairs({ "*@", "@", "*" }) do
		if vim.endswith(display, word .. candidate) then
			suffix = candidate
			break
		end
	end
	local paths = vim.tbl_filter(function(candidate)
		return vim.uv.fs_lstat(candidate) ~= nil
	end, suffix and { path, path .. suffix } or { path })
	if #paths > 1 then
		vim.notify("Ambiguous Netrw name; use the terminal:\n" .. table.concat(paths, "\n"), vim.log.levels.ERROR)
		return nil, true
	end
	return paths[1]
end
local function netrw_selected_paths(first, last)
	local marked = vim.fn["netrw#Expose"]("netrwmarkfilelist")
	local paths = type(marked) == "table" and vim.deepcopy(marked) or {}
	local blocked = false
	if #paths == 0 then
		local cursor = vim.api.nvim_win_get_cursor(0)
		for row = first, last do
			vim.api.nvim_win_set_cursor(0, { row, 0 })
			local path, ambiguous = netrw_cursor_path()
			blocked = blocked or ambiguous
			if path then
				paths[#paths + 1] = path
			end
		end
		vim.api.nvim_win_set_cursor(0, cursor)
	end
	return vim.tbl_filter(function(path)
		return vim.uv.fs_lstat(path) ~= nil
	end, vim.fn.uniq(vim.fn.sort(paths))),
		blocked,
		type(marked) == "table"
end
local function netrw_delete(first, last)
	local paths, blocked, marked = netrw_selected_paths(first, last)
	if #paths == 0 then
		if not blocked then
			vim.notify("No local file selected", vim.log.levels.ERROR)
		end
		return
	end
	local label = #paths == 1 and paths[1] or ("these " .. #paths .. " items")
	if vim.fn.confirm("Delete " .. label .. "?", "&Yes\n&No", 2) ~= 1 then
		return
	end
	local failed = {}
	for _, path in ipairs(paths) do
		local stat = vim.uv.fs_lstat(path)
		if not stat or vim.fn.delete(path, stat.type == "directory" and "rf" or "") ~= 0 then
			failed[#failed + 1] = path
		end
	end
	if marked then
		vim.fn["netrw#Call"]("NetrwUnMarkFile", 1)
	end
	shared.netrw_refresh()
	if #failed > 0 then
		vim.notify("Delete failed:\n" .. table.concat(failed, "\n"), vim.log.levels.ERROR)
	end
end
local function netrw_rename(first, last)
	local paths, blocked, marked = netrw_selected_paths(first, last)
	if #paths == 0 then
		if not blocked then
			vim.notify("No local file selected", vim.log.levels.ERROR)
		end
		return
	end
	for _, old in ipairs(paths) do
		local new = vim.fn.input("Moving " .. old .. " to: ", old, "file")
		if new == "" then
			break
		end
		if
			new ~= old and (not vim.uv.fs_lstat(new) or vim.fn.confirm("Overwrite " .. new .. "?", "&Yes\n&No", 2) == 1)
		then
			if vim.fn.rename(old, new) ~= 0 then
				vim.notify("Rename failed: " .. old, vim.log.levels.ERROR)
			end
		end
	end
	if marked then
		vim.fn["netrw#Call"]("NetrwUnMarkFile", 1)
	end
	shared.netrw_refresh()
end
local function netrw_transfer(command)
	local files = vim.fn["netrw#Expose"]("netrwmarkfilelist")
	local target = vim.fn["netrw#Expose"]("netrwmftgt")
	if type(files) ~= "table" or #files == 0 or type(target) ~= "string" or vim.fn.isdirectory(target) == 0 then
		vim.notify("Mark files with mf and set a target with mt", vim.log.levels.ERROR)
		return
	end
	local argv = { command }
	if command == "cp" then
		argv[#argv + 1] = "-R"
	end
	vim.list_extend(argv, files)
	argv[#argv + 1] = target
	local result = vim.system(argv, { text = true }):wait()
	if result.code ~= 0 then
		vim.notify(vim.trim(result.stderr ~= "" and result.stderr or result.stdout), vim.log.levels.ERROR)
		return
	end
	vim.fn["netrw#Call"]("NetrwUnMarkFile", 1)
	shared.netrw_refresh()
end
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_winsize = 25
vim.g.netrw_browse_split = 4
vim.g.netrw_keepdir = 1
-- netrw reapplies these after drawing, overriding FileType window options.
vim.g.netrw_bufsettings = "noma nomod nu nobl nowrap ro nornu"
-- Reserve native helper mappings before netrw initializes any new buffer;
-- otherwise it tries to install Ctrl-h/l over the global window shortcuts.
vim.keymap.set("n", "<Plug>NopackNetrwHideEdit", "<Plug>NetrwHideEdit")
vim.keymap.set("n", "<Plug>NopackNetrwRefresh", "<Plug>NetrwRefresh")
local netrw_lines_group = vim.api.nvim_create_augroup("nopack-netrw-lines", { clear = true })
vim.api.nvim_create_autocmd("Syntax", {
	group = netrw_lines_group,
	pattern = "netrw",
	callback = function()
		vim.cmd([[syntax match Conceal /[|│]/ contained containedin=netrwTreeBar conceal cchar=┊]])
	end,
})
vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter", "WinEnter" }, {
	group = netrw_lines_group,
	callback = function()
		if vim.bo.filetype == "netrw" then
			vim.opt_local.conceallevel, vim.opt_local.concealcursor = 2, "nvic"
			shared.fix_sidebar_width(vim.api.nvim_get_current_win())
		end
	end,
})
vim.api.nvim_create_autocmd("FileType", {
	pattern = "netrw",
	callback = function(args)
		vim.w.netrw_liststyle = 3
		vim.opt_local.number = true
		vim.opt_local.relativenumber = false
		vim.opt_local.wrap = false
		vim.api.nvim_buf_create_user_command(args.buf, "Ntree", function(opts)
			netrw_set_tree_root(vim.fn.expandcmd(opts.args))
		end, { nargs = "?", complete = "dir" })
		vim.keymap.set("n", "gn", function()
			netrw_set_tree_root("")
		end, { buf = args.buf, silent = true, desc = "Set tree root to cursor directory" })
		vim.keymap.set("n", "g?", netrw_help, { buf = args.buf, silent = true, desc = "Show netrw help" })
		local function file_operation(key, function_name, use_directory, append_path, desc, ...)
			local call_args = { ... }
			vim.keymap.set("n", key, function()
				netrw_at_cursor(function_name, use_directory, append_path, unpack(call_args))
			end, { buf = args.buf, silent = true, nowait = true, desc = desc })
		end
		vim.keymap.set("n", "D", function()
			netrw_delete(vim.fn.line("."), vim.fn.line("."))
		end, { buf = args.buf, silent = true, nowait = true, desc = "Delete file" })
		vim.keymap.set("n", "<Del>", function()
			netrw_delete(vim.fn.line("."), vim.fn.line("."))
		end, { buf = args.buf, silent = true, nowait = true, desc = "Delete file" })
		vim.keymap.set("x", "D", function()
			local first, last = vim.fn.line("v"), vim.fn.line(".")
			vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false)
			netrw_delete(math.min(first, last), math.max(first, last))
		end, { buf = args.buf, silent = true, nowait = true, desc = "Delete selected files" })
		vim.keymap.set("x", "<Del>", "D", { buf = args.buf, remap = true, silent = true })
		vim.keymap.set({ "n", "x" }, "<RightMouse>", "<Cmd>normal! <LeftMouse><CR>D", {
			buf = args.buf,
			remap = true,
			silent = true,
		})
		vim.keymap.set("n", "R", function()
			netrw_rename(vim.fn.line("."), vim.fn.line("."))
		end, { buf = args.buf, silent = true, nowait = true, desc = "Rename file" })
		vim.keymap.set("x", "R", function()
			local first, last = vim.fn.line("v"), vim.fn.line(".")
			vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false)
			netrw_rename(math.min(first, last), math.max(first, last))
		end, { buf = args.buf, silent = true, nowait = true, desc = "Rename selected files" })
		vim.keymap.set("n", "%", function()
			local _, directory = netrw_cursor_paths()
			vim.fn.inputsave()
			local name = vim.fn.input("Enter filename: ")
			vim.fn.inputrestore()
			if name == "" then
				return
			end
			local path = vim.fn.isabsolutepath(name) == 1 and name or vim.fs.joinpath(directory, name)
			-- NetrwOpenFile always edits in the tree window, ignoring browse_split.
			shared.focus_editor()
			vim.cmd("edit " .. vim.fn.fnameescape(path))
		end, { buf = args.buf, silent = true, nowait = true, desc = "Create file in first editor window" })
		file_operation("d", "NetrwMakeDir", true, false, "Create directory", "")
		vim.keymap.set("n", "mf", function()
			local parent = netrw_cursor_paths()
			local path = netrw_cursor_path()
			if not path then
				return
			end
			local liststyle = vim.w.netrw_liststyle
			vim.b.netrw_curdir = parent
			vim.w.netrw_liststyle = 0
			vim.fn["netrw#Call"]("NetrwMarkFile", 1, vim.fs.basename(path))
			vim.w.netrw_liststyle = liststyle
		end, { buf = args.buf, silent = true, nowait = true, desc = "Toggle file mark" })
		local function set_target()
			local _, directory = netrw_cursor_paths()
			shared.netrw_command("call netrw#MakeTgt(" .. vim.fn.string(directory) .. ")")
		end
		vim.keymap.set(
			"n",
			"mt",
			set_target,
			{ buf = args.buf, silent = true, nowait = true, desc = "Set copy/move target" }
		)
		vim.keymap.set("n", "<Plug>NetrwCLeftmouse", function()
			vim.cmd("normal! " .. vim.keycode("<LeftMouse>"))
			set_target()
		end, { buf = args.buf, silent = true })
		vim.keymap.set("n", "mc", function()
			netrw_transfer("cp")
		end, { buf = args.buf, silent = true, nowait = true, desc = "Copy marked files" })
		vim.keymap.set("n", "mm", function()
			netrw_transfer("mv")
		end, { buf = args.buf, silent = true, nowait = true, desc = "Move marked files" })
		-- Give netrw's helpers keys without conflicting with Ctrl-h/l window movement.
		vim.keymap.set("n", "<leader>nh", function()
			shared.netrw_command("normal " .. vim.api.nvim_replace_termcodes("<Plug>NetrwHideEdit", true, false, true))
		end, { buf = args.buf, silent = true, desc = "Edit tree hide patterns" })
		vim.keymap.set("n", "<Plug>NetrwRefresh", shared.netrw_refresh, { buf = args.buf, silent = true })
		-- netrw's substring hasmapto() check also matches the HideEdit alias.
		vim.keymap.set("n", "a", "<Plug>NetrwHide_a", { buf = args.buf, silent = true })
		vim.keymap.set(
			"n",
			"<leader>nr",
			shared.netrw_refresh,
			{ buf = args.buf, silent = true, desc = "Refresh tree" }
		)
		for _, direction in ipairs({ "h", "j", "k", "l" }) do
			vim.keymap.set("n", "<C-" .. direction .. ">", "<C-w>" .. direction, {
				buf = args.buf,
				silent = true,
				desc = "Move to " .. direction .. " window",
			})
		end
		for _, key in ipairs({ "<CR>", "l" }) do
			vim.keymap.set("n", key, function()
				shared.netrw_command(
					"normal " .. vim.api.nvim_replace_termcodes("<Plug>NetrwLocalBrowseCheck", true, false, true)
				)
			end, {
				buf = args.buf,
				silent = true,
				desc = "Toggle directory / open file",
			})
		end
		vim.keymap.set("n", "h", function()
			shared.netrw_command(
				"normal " .. vim.api.nvim_replace_termcodes("<Plug>NetrwTreeSqueeze", true, false, true)
			)
		end, {
			buf = args.buf,
			silent = true,
			desc = "Collapse parent directory",
		})
	end,
})
