-- Standalone offline config: Neovim 0.12+, no third-party plugins/downloads.
-- Try: nvim -u /path/to/init.offline.lua
-- Only bundled runtime plugins (netrw, matchit, etc.) are loaded.
--
-- Sections: runtime -> options -> base keys -> display -> completion -> tree
--           -> buffers -> project root -> async jobs -> picker -> searches
--           -> undo/whitespace -> terminal -> sessions -> Git -> formatting
--           -> ctags fallback -> LSP -> diagnostics -> large files -> Treesitter.
-- 서버/포맷터 명령은 LSP / FORMATTING의 테이블에서 수정합니다.
-- <leader>는 Space. 각 기능의 제목 아래에 주요 키와 실행 조건을 적었습니다.
-- =========================================
-- ========== RUNTIME / VERSION ==========
-- =========================================
-- Neovim 0.12+ 전용. 사용자 플러그인 경로를 제외하고 설치본의 기본 런타임만 사용합니다.
if vim.fn.has("nvim-0.12") == 0 then
	error("This offline config requires Neovim 0.12 or newer")
end
vim.opt.packpath = { vim.env.VIMRUNTIME }
-- Keep the installation's parser directory as well as its runtime scripts.
vim.opt.runtimepath = vim.tbl_filter(function(path)
	return path == vim.env.VIMRUNTIME or path:match("/lib[^/]*/nvim$") ~= nil
end, vim.opt.runtimepath:get())

-- =========================================
-- ============== CORE OPTIONS =============
-- =========================================
local offline_data = vim.fn.stdpath("data") .. "/offline"
vim.fn.mkdir(offline_data .. "/undo", "p")

-- Portable LSP/formatter launchers may be kept with this configuration.
-- Search this directory before PATH and Mason. Override with g:offline_tools_dir.
local offline_tools_dir = vim.g.offline_tools_dir or (vim.fn.stdpath("config") .. "/lsp/bin")
local function resolve_tool(name)
	local bundled = offline_tools_dir .. "/" .. name
	if vim.fn.executable(bundled) == 1 then
		return bundled
	end
	return vim.fn.exepath(name)
end

local default_options = {
	backup = false, -- do not retain a backup after writing
	clipboard = "", -- use local registers on headless servers
	lazyredraw = false, -- keep normal redraws; do not defer display updates
	cmdheight = 1, -- more space in the neovim command line for displaying messages
	completeopt = { "menu", "menuone", "noselect", "popup", "fuzzy" },
	autocompletedelay = 150,
	complete = { ".", "w", "b", "t" },
	pumborder = "rounded",
	winborder = "rounded",
	conceallevel = 0, -- so that `` is visible in markdown files
	fileencoding = "utf-8", -- the encoding written to a file
	foldmethod = "manual", -- folds are controlled manually
	foldexpr = "", -- no plugin-provided fold expression
	guifont = "monospace:h17", -- the font used in graphical neovim applications
	hidden = true, -- required to keep multiple buffers and open multiple buffers
	hlsearch = true, -- highlight all matches on previous search pattern
	ignorecase = true, -- ignore case in search patterns
	mouse = "a", -- allow the mouse to be used in neovim
	pumheight = 10, -- pop up menu height
	showmode = true, -- show the active input mode
	showtabline = 2, -- always show tabs
	smartcase = true, -- smart case
	smartindent = true, -- make indenting smarter again
	splitbelow = true, -- force all horizontal splits to go below current window
	splitright = true, -- force all vertical splits to go to the right of current window
	swapfile = false, -- do not create swap files
	termguicolors = true, -- set term gui colors (most terminals support this)
	title = true, -- set the title of window to the value of the titlestring
	undodir = offline_data .. "/undo", -- set an undo directory
	undofile = true, -- enable persistent undo
	updatetime = 250, -- idle time before CursorHold
	writebackup = false, -- do not create a temporary backup while writing
	expandtab = true, -- convert tabs to spaces
	shiftwidth = 4, -- the number of spaces inserted for each indentation
	tabstop = 4, -- display tabs at four-column stops
	cursorline = true,
	cursorlineopt = "line,number", -- highlight the current row and its line number
	cursorcolumn = true, -- highlight the current column to form a crosshair
	number = true, -- set numbered lines
	relativenumber = false, -- set relative numbered lines
	numberwidth = 2, -- set number column width to 2 {default 4}
	signcolumn = "yes", -- always show the sign column, otherwise it would shift the text each time
	wrap = true, -- wrap long lines at the window edge
	spell = false,
	spelllang = "en",
	background = "dark",
	scrolloff = 5, -- keep context above and below the cursor
	sidescrolloff = 8,
	ttyfast = true,
	sessionoptions = "buffers,curdir,folds,help,tabpages,winsize,winpos,terminal",
}

-- Apply the shared editor options before configuring window-local behavior.
vim.opt.shortmess:append("c")

for k, v in pairs(default_options) do
	vim.opt[k] = v
end

-- Numbering is window-local; ordinary navigation only touches the entered window.
local function show_line_numbers(win)
	if not vim.api.nvim_win_is_valid(win) then
		return
	end
	local buf = vim.api.nvim_win_get_buf(win)
	if vim.bo[buf].buftype == "" or vim.bo[buf].filetype == "netrw" then
		if not vim.wo[win].number then
			vim.wo[win].number = true
		end
		if vim.wo[win].relativenumber then
			vim.wo[win].relativenumber = false
		end
		if vim.wo[win].statuscolumn ~= "" then
			vim.wo[win].statuscolumn = ""
		end
	end
end
vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter", "FileType", "VimEnter", "SessionLoadPost" }, {
	group = vim.api.nvim_create_augroup("offline-line-numbers", { clear = true }),
	callback = function(args)
		if args.event == "FileType" then
			-- Apply after filetype plugins, only to windows displaying this buffer.
			vim.schedule(function()
				for _, win in ipairs(vim.fn.win_findbuf(args.buf)) do
					show_line_numbers(win)
				end
			end)
		elseif args.event == "VimEnter" or args.event == "SessionLoadPost" then
			for _, win in ipairs(vim.api.nvim_list_wins()) do
				show_line_numbers(win)
			end
		else
			show_line_numbers(vim.api.nvim_get_current_win())
		end
	end,
})

-- =========================================
-- ================ LEADER =================
-- =========================================
vim.g.mapleader = " "

-- =========================================
-- ============== KEYMAPS: BASE ============
-- =========================================
-- Leave Insert mode with jk
vim.keymap.set("i", "jk", "<esc>", { noremap = true, silent = true })

-- Native pairs for file buffers; prompt input and large files stay literal.
local insert_pairs = { ["("] = ")", ["["] = "]", ["{"] = "}", ["'"] = "'", ['"'] = '"', ["`"] = "`" }
local function pair_escaped(text)
	return #(text:match("\\+$") or "") % 2 == 1
end
local function pair_mapping(key, callback, description)
	local plug = "<Plug>(offline-pair-" .. key:byte() .. ")"
	-- Flush preceding typed characters before inspecting the cursor and buffer.
	vim.keymap.set("i", key, "<Ignore>" .. plug, { desc = description })
	vim.keymap.set("i", plug, callback, { expr = true })
end
for opening, closing in pairs(insert_pairs) do
	pair_mapping(opening, function()
		if vim.bo.buftype ~= "" or vim.b.offline_large_file then
			return opening
		end
		local line, col = vim.api.nvim_get_current_line(), vim.api.nvim_win_get_cursor(0)[2]
		local before, after = line:sub(1, col), line:sub(col + 1, col + 1)
		if pair_escaped(before) then
			return opening
		end
		if opening == closing and after == closing then
			return "<C-g>U<Right>"
		end
		if after:match("[%w_]") or (opening == "'" and before:match("[%w_]$")) then
			return opening
		end
		return opening .. closing .. "<C-g>U<Left>"
	end, "Insert " .. opening .. closing .. " pair")
	if opening ~= closing then
		pair_mapping(closing, function()
			if vim.bo.buftype == "" and not vim.b.offline_large_file then
				local line, col = vim.api.nvim_get_current_line(), vim.api.nvim_win_get_cursor(0)[2]
				if line:sub(col + 1, col + 1) == closing and not pair_escaped(line:sub(1, col)) then
					return "<C-g>U<Right>"
				end
			end
			return closing
		end, "Skip closing " .. closing)
	end
end
pair_mapping("<BS>", function()
	if vim.bo.buftype == "" and not vim.b.offline_large_file then
		local line, col = vim.api.nvim_get_current_line(), vim.api.nvim_win_get_cursor(0)[2]
		if
			col > 0
			and insert_pairs[line:sub(col, col)] == line:sub(col + 1, col + 1)
			and not pair_escaped(line:sub(1, col - 1))
		then
			return "<BS><Del>"
		end
	end
	return "<BS>"
end, "Delete an empty pair")

-- Clear search highlighting
vim.keymap.set("n", "<ESC>", ":nohl<CR>", { noremap = true, silent = true })

-- Increment/decrement
vim.keymap.set("n", "+", "<C-a>", { noremap = true, silent = true })
vim.keymap.set("n", "-", "<C-x>", { noremap = true, silent = true })

-- Terminal mode exit (double ESC)
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Add undo break-points
vim.keymap.set("i", ",", ",<c-g>u", { noremap = true, silent = true })
vim.keymap.set("i", ".", ".<c-g>u", { noremap = true, silent = true })
vim.keymap.set("i", ";", ";<c-g>u", { noremap = true, silent = true })
vim.keymap.set("i", "<", "<<C-g>u", { noremap = true, silent = true })

-- Window navigation (insert-mode alt-arrows)
vim.keymap.set("i", "<A-Up>", "<C-\\><C-N><C-w>k", { noremap = true, silent = true })
vim.keymap.set("i", "<A-Down>", "<C-\\><C-N><C-w>j", { noremap = true, silent = true })
vim.keymap.set("i", "<A-Left>", "<C-\\><C-N><C-w>h", { noremap = true, silent = true })
vim.keymap.set("i", "<A-Right>", "<C-\\><C-N><C-w>l", { noremap = true, silent = true })

-- Move line/block with Alt-j/k
vim.keymap.set("i", "<A-j>", "<ESC>:m .+1<CR>==gi", { noremap = true, silent = true })
vim.keymap.set("i", "<A-k>", "<ESC>:m .-2<CR>==gi", { noremap = true, silent = true })
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==", { noremap = true, silent = true })
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==", { noremap = true, silent = true })
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv-gv", { noremap = true, silent = true })
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv-gv", { noremap = true, silent = true })

-- Save
vim.keymap.set("i", "<C-s>", "<ESC><cmd>w<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-s>", ":w<CR>", { noremap = true, silent = true })

-- Better window movement (normal mode)
vim.keymap.set("n", "<C-h>", "<C-w>h", { noremap = true, silent = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { noremap = true, silent = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { noremap = true, silent = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { noremap = true, silent = true })

-- Resize with arrows
vim.keymap.set("n", "<S-Up>", ":resize -5<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<S-Down>", ":resize +5<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<S-Left>", ":vertical resize -5<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<S-Right>", ":vertical resize +5<CR>", { noremap = true, silent = true })

-- Leader mappings (yank/paste behavior tweaks)
vim.keymap.set("n", "x", [["_x]], { noremap = true, silent = true })
vim.keymap.set("v", "p", [["_dP]], { noremap = true, silent = true })
vim.keymap.set("v", "P", [["_dP]], { noremap = true, silent = true })

-- Search navigation keeps viewport centered
vim.keymap.set("n", "n", "nzzzv", { noremap = true, silent = true })
vim.keymap.set("n", "N", "Nzzzv", { noremap = true, silent = true })

-- Diff all windows
vim.keymap.set("n", "<leader>w", ":windo diffthis<CR>", {
	noremap = true,
	silent = true,
	desc = "Diff all windows",
})

-- Select entire file
vim.keymap.set("n", "<leader>a", "gg<S-v>G", {
	noremap = true,
	silent = true,
	desc = "Select entire file",
})

-- Substitute helpers: preserve registers and escape selected text literally.
for suffix, range in pairs({ Sa = "%", Sf = ".,$" }) do
	vim.keymap.set("n", "<leader>" .. suffix, ":" .. range .. "s/\\<<C-r><C-w>\\>/", { desc = "Substitute word" })
	vim.keymap.set("x", "<leader>" .. suffix, function()
		local saved = vim.fn.getreginfo('"')
		local zero = vim.fn.getreginfo("0")
		vim.cmd("normal! y")
		local pattern = vim.fn.escape(vim.fn.getreg('"'), [[\/]]):gsub("\n", [[\n]])
		vim.fn.setreg("0", zero)
		vim.fn.setreg('"', saved)
		local keys = ":" .. range .. "s/\\V" .. pattern .. "/"
		vim.api.nvim_feedkeys(keys, "ni", true)
	end, { desc = "Substitute selection" })
end

-- Keep selection when indenting
vim.keymap.set("v", "<", "<gv", { noremap = true, silent = true })
vim.keymap.set("v", ">", ">gv", { noremap = true, silent = true })

-- Yank highlight
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

-- The original OSCYank integration copied default yanks to the SSH client's clipboard.
if vim.env.SSH_CONNECTION or vim.env.SSH_TTY then
	vim.api.nvim_create_autocmd("TextYankPost", {
		group = vim.api.nvim_create_augroup("offline-ssh-yank", { clear = true }),
		callback = function()
			if vim.v.event.operator == "y" and vim.v.event.regname == "" then
				local payload = table.concat(vim.v.event.regcontents, "\n")
					.. (vim.v.event.regtype == "V" and "\n" or "")
				if #payload > 100000 then
					vim.notify("OSC52 yank skipped: selection exceeds 100 KB", vim.log.levels.WARN)
					return
				end
				require("vim.ui.clipboard.osc52").copy("+")(vim.v.event.regcontents)
			end
		end,
	})
end

-- =========================================
-- ======= DISPLAY / DEFAULT THEME =======
-- =========================================
-- 기본 테마·상태줄·명령줄 완성. 버퍼 목록(tabline)은 BUFFERS에서 설정합니다.
vim.cmd("filetype plugin indent on")
vim.cmd("syntax enable")
vim.cmd("colorscheme retrobox")
vim.opt.whichwrap:append("<,>,[,],h,l")
vim.opt.iskeyword:append("-")
-- Keep :find / Tab completion from recursively walking an entire server.
vim.opt.path = { ".", "" }
vim.opt.wildmenu = true
vim.opt.wildmode = "longest:full,full"
vim.opt.wildignore:append({ "*/.git/*", "*/node_modules/*", "*/__pycache__/*" })
vim.opt.laststatus = 2
vim.opt.statusline =
	" %f %m%r%h %{get(b:, 'offline_git_status', '')} %= %{v:lua.vim.diagnostic.status()} %y | %l:%c | %p%% "
-- 내장 renderer로 들여쓰기 가이드 표시: 텍스트/커서 이동마다 extmark를 재생성하지 않습니다.
-- 선행 공백에만 shiftwidth 간격으로 선을 표시하며, 비어 있는 줄까지 이어주지는 않습니다.
vim.opt.list = true
vim.opt.listchars = { tab = "│ ", lead = " ", leadmultispace = "│   ", trail = ".", extends = ">", precedes = "<" }
local function update_indent_guides()
	if vim.bo.buftype ~= "" or vim.bo.filetype == "netrw" then
		vim.opt_local.listchars:remove("leadmultispace")
		return
	end
	local width = vim.fn.shiftwidth()
	vim.opt_local.listchars:append({ leadmultispace = "│" .. string.rep(" ", width - 1) })
end
local indent_group = vim.api.nvim_create_augroup("offline-indent-guides", { clear = true })
vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter" }, {
	group = indent_group,
	callback = update_indent_guides,
})
vim.api.nvim_create_autocmd("OptionSet", {
	group = indent_group,
	pattern = { "shiftwidth", "tabstop", "vartabstop" },
	callback = update_indent_guides,
})
-- =========================================
-- ======= FILE TREE: NETRW OPTIONS ======
-- =========================================
-- NvimTree 대체: 기본 netrw의 트리 모드와 버퍼 전용 키를 설정합니다.
-- Enter/l: 열기·접기, h: 상위 가지 접기, Space nr: 새로고침, Ctrl-h/j/k/l: 창 이동.
local function netrw_command(command)
	local saved_lazyredraw = vim.o.lazyredraw
	vim.o.lazyredraw = true
	local ok, err = pcall(vim.cmd, command)
	vim.api.nvim_exec_autocmds("User", { pattern = "OfflineNetrwRedraw", modeline = false })
	vim.o.lazyredraw = saved_lazyredraw
	if not ok then
		error(err)
	end
end

local function sidebar_width()
	return math.max(20, math.min(40, math.floor(vim.o.columns * 0.25)))
end
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_winsize = 25
vim.g.netrw_browse_split = 4
vim.g.netrw_keepdir = 1
-- netrw reapplies these after drawing, overriding FileType window options.
vim.g.netrw_bufsettings = "noma nomod nu nobl nowrap ro nornu"
vim.api.nvim_create_autocmd("FileType", {
	pattern = "netrw",
	callback = function(args)
		local win = vim.api.nvim_get_current_win()
		vim.schedule(function()
			if vim.api.nvim_win_is_valid(win) and vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "netrw" then
				vim.api.nvim_win_set_width(win, sidebar_width())
				vim.api.nvim_set_option_value("winfixwidth", true, { win = win })
			end
		end)
		vim.w.netrw_liststyle = 3
		vim.opt_local.number = true
		vim.opt_local.relativenumber = false
		vim.opt_local.wrap = false
		-- Give netrw's helpers keys without conflicting with Ctrl-h/l window movement.
		vim.keymap.set("n", "<leader>nh", function()
			netrw_command("normal " .. vim.api.nvim_replace_termcodes("<Plug>NetrwHideEdit", true, false, true))
		end, { buf = args.buf, silent = true })
		vim.keymap.set("n", "<Plug>OfflineNetrwRefresh", "<Plug>NetrwRefresh", { buf = args.buf })
		vim.keymap.set("n", "<leader>nr", function()
			netrw_command("Explore " .. vim.fn.fnameescape(vim.w.netrw_treetop or vim.b.netrw_curdir))
		end, { buf = args.buf, silent = true, desc = "Refresh tree" })
		for _, direction in ipairs({ "h", "j", "k", "l" }) do
			vim.keymap.set("n", "<C-" .. direction .. ">", "<C-w>" .. direction, {
				buf = args.buf,
				silent = true,
				desc = "Move to " .. direction .. " window",
			})
		end
		for _, key in ipairs({ "<CR>", "l" }) do
			vim.keymap.set("n", key, function()
				netrw_command("normal " .. vim.api.nvim_replace_termcodes("<Plug>NetrwLocalBrowseCheck", true, false, true))
			end, {
				buf = args.buf,
				silent = true,
				desc = "Toggle directory / open file",
			})
		end
		vim.keymap.set("n", "h", function()
			netrw_command("normal " .. vim.api.nvim_replace_termcodes("<Plug>NetrwTreeSqueeze", true, false, true))
		end, {
			buf = args.buf,
			silent = true,
			desc = "Collapse parent directory",
		})
	end,
})

-- =========================================
-- ============ KEYMAP HELPER ============
-- =========================================
-- 이후 공통 키맵에 silent와 설명을 붙이는 작은 헬퍼입니다.
local function map(mode, lhs, rhs, desc)
	vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc })
end

-- =========================================
-- ======== COMPLETION / SNIPPETS ========
-- =========================================
-- Blink 대체: 내장 LSP 완성과 스니펫. LSP 자동 팝업 활성화는 아래 LSP attach에서 합니다.
-- Ctrl-Space: 요청, Ctrl-n/p: 선택, Enter: 선택 확정, Tab/Shift-Tab: 스니펫·후보 이동.
vim.keymap.set("i", "<C-Space>", function()
	if #vim.lsp.get_clients({ bufnr = 0, method = "textDocument/completion" }) > 0 then
		vim.lsp.completion.get()
	else
		vim.api.nvim_feedkeys(vim.keycode("<C-n>"), "n", false)
	end
end, { desc = "Complete from LSP or buffer" })
vim.keymap.set("i", "<CR>", function()
	return vim.fn.pumvisible() == 1 and vim.fn.complete_info().selected >= 0 and "<C-y>" or "<CR>"
end, { expr = true, desc = "Accept selected completion / newline" })
for key, direction in pairs({ ["<Tab>"] = 1, ["<S-Tab>"] = -1 }) do
	vim.keymap.set({ "i", "s" }, key, function()
		if vim.snippet.active({ direction = direction }) then
			vim.snippet.jump(direction)
		elseif vim.fn.pumvisible() == 1 then
			vim.api.nvim_feedkeys(vim.keycode(direction == 1 and "<C-n>" or "<C-p>"), "n", false)
		else
			vim.api.nvim_feedkeys(vim.keycode(key), "n", false)
		end
	end, { desc = "Snippet tabstop / completion / " .. key })
end
-- Buffers without completion providers use words/tags; connected providers use the async engine.
local function buffer_completion(buf)
	vim.bo[buf].autocomplete = vim.bo[buf].buftype == ""
		and vim.bo[buf].filetype ~= "netrw"
		and not vim.b[buf].offline_large_file
		and #vim.lsp.get_clients({ bufnr = buf, method = "textDocument/completion" }) == 0
end
vim.api.nvim_create_autocmd({ "BufEnter", "FileType", "LspDetach" }, {
	callback = function(args)
		vim.schedule(function()
			if vim.api.nvim_buf_is_valid(args.buf) then
				buffer_completion(args.buf)
			end
		end)
	end,
})

-- =========================================
-- ====== FILE TREE: TOGGLE / REVEAL =====
-- =========================================
-- Space e: 프로젝트 루트의 트리를 열고 현재 파일까지 펼칩니다.
-- 프로젝트 탐색 함수는 PROJECT ROOT에서 정의되며 키 실행 시 호출됩니다.
local project_root
local function reveal_tree_file(relative)
	local parts = vim.split(relative, "/", { plain = true, trimempty = true })
	local parent_line = 1
	for depth, name in ipairs(parts) do
		local directory = depth < #parts
		local label = string.rep("| ", depth) .. name .. (directory and "/" or "")
		local found
		local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
		for row = parent_line + 1, #lines do
			if depth > 1 and lines[row]:sub(1, depth * 2) ~= string.rep("| ", depth) then
				break
			end
			if lines[row] == label then
				found = row
				break
			end
		end
		if not found then
			return
		end
		vim.api.nvim_win_set_cursor(0, { found, 0 })
		if directory then
			local child_prefix = string.rep("| ", depth + 1)
			if not lines[found + 1] or lines[found + 1]:sub(1, #child_prefix) ~= child_prefix then
				local open = vim.api.nvim_replace_termcodes("<Plug>NetrwLocalBrowseCheck", true, false, true)
				netrw_command("normal " .. open)
			end
		end
		parent_line = found
	end
	vim.cmd("normal! zz")
end

vim.keymap.set("n", "<leader>e", function()
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "netrw" then
			if #vim.api.nvim_tabpage_list_wins(0) > 1 then
				vim.api.nvim_win_close(win, false)
			else
				-- Starting with `nvim .` leaves only netrw: make it a sidebar.
				vim.cmd("botright vnew")
				vim.api.nvim_win_set_width(win, sidebar_width())
				vim.api.nvim_set_option_value("winfixwidth", true, { win = win })
				vim.g.netrw_chgwin = vim.fn.winnr()
			end
			return
		end
	end
	local file = vim.bo.buftype == "" and vim.api.nvim_buf_get_name(0) or ""
	local root = project_root():gsub("/+$", "")
	local existing_buffers = {}
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		existing_buffers[buf] = true
	end
	netrw_command("Lexplore " .. vim.fn.fnameescape(root == "" and "/" or root))
	if file ~= "" then
		reveal_tree_file(file:sub(#root + 2))
	end
	-- netrw's tree setup can abandon an intermediate unnamed buffer.
	-- Remove only empty, hidden buffers created by this particular opening.
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if
			not existing_buffers[buf]
			and vim.api.nvim_buf_get_name(buf) == ""
			and vim.bo[buf].buftype == ""
			and not vim.bo[buf].modified
			and #vim.fn.win_findbuf(buf) == 0
			and vim.deep_equal(vim.api.nvim_buf_get_lines(buf, 0, -1, false), { "" })
		then
			vim.api.nvim_buf_delete(buf, {})
		end
	end
end, { silent = true, nowait = true, desc = "Toggle file explorer" })

-- =========================================
-- ========= EDITOR WINDOW TARGET ========
-- =========================================
-- 트리에서 파일/버퍼를 선택할 때 결과를 표시할 편집 창을 확보합니다.
local function focus_editor()
	if vim.bo.filetype ~= "netrw" and vim.bo.filetype ~= "offline_outline" then
		return
	end
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.bo[buf].buftype == "" and vim.bo[buf].filetype ~= "netrw" then
			vim.api.nvim_set_current_win(win)
			return
		end
	end
	vim.cmd("botright vnew")
end

local function select_buffer(buf)
	focus_editor()
	vim.api.nvim_set_current_buf(buf)
end

-- =========================================
-- ========== BUFFERS / TABLINE ==========
-- =========================================
-- Barbar 대체: 표시 순서를 이동·번호 선택·좌우 닫기에서 함께 사용합니다.
-- Shift-h/l, [b/]b: 이동; Alt-1..9: 선택; Space bj/bk: 재배열; bD/bL: 정렬.
-- Space c: 강제 닫기; bw: 미저장 보호; bm/be/bh/bl: 다른·왼쪽·오른쪽 버퍼 정리.
local buffer_order = {}
local tabline_cache
local function buffers()
	local seen = {}
	buffer_order = vim.tbl_filter(function(buf)
		local keep = vim.api.nvim_buf_is_valid(buf)
			and vim.bo[buf].buflisted
			and (vim.bo[buf].buftype == "" or vim.bo[buf].buftype == "terminal")
		if keep then
			seen[buf] = true
		end
		return keep
	end, buffer_order)
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if
			not seen[buf]
			and vim.bo[buf].buflisted
			and (vim.bo[buf].buftype == "" or vim.bo[buf].buftype == "terminal")
		then
			buffer_order[#buffer_order + 1] = buf
		end
	end
	return buffer_order
end
local function buffer_index(buf)
	for i, candidate in ipairs(buffers()) do
		if candidate == buf then
			return i
		end
	end
	return 1
end
-- Listed buffers in the top bar; numbers match Alt-1..8 (Alt-9 = last).
function _G.OfflineTabline()
	if tabline_cache then
		return tabline_cache
	end
	local items = {}
	for i, b in ipairs(buffers()) do
		local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(b), ":t")
		if name == "" then
			name = "[No Name]"
		end
		local hl = b == vim.api.nvim_get_current_buf() and "%#TabLineSel#" or "%#TabLine#"
		items[#items + 1] = hl .. " " .. i .. ":" .. name:gsub("%%", "%%%%") .. (vim.bo[b].modified and " + " or " ")
	end
	tabline_cache = table.concat(items) .. "%#TabLineFill#"
	return tabline_cache
end
vim.opt.tabline = "%!v:lua.OfflineTabline()"
local function invalidate_tabline()
	tabline_cache = nil
end
vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete", "BufEnter", "BufFilePost", "BufModifiedSet", "TermOpen" }, {
	callback = invalidate_tabline,
})
vim.api.nvim_create_autocmd("OptionSet", {
	pattern = { "buflisted", "buftype" },
	callback = invalidate_tabline,
})

-- =========================================
-- ======= BUFFER PICKER / KEYMAPS =======
-- =========================================
-- Space bp/sb는 아래 공통 picker를 사용합니다. 선언만 먼저 두고 구현은 PICKER에 둡니다.
local open_picker, active_picker
local function pick_buffer()
	local items = {}
	for _, b in ipairs(buffers()) do
		local name = vim.api.nvim_buf_get_name(b)
		items[#items + 1] = {
			bufnr = b,
			filename = name ~= "" and name or nil,
			label = b .. ": " .. (name ~= "" and vim.fn.fnamemodify(name, ":~:.") or "[No Name]"),
		}
	end
	open_picker("Buffers", { items = items })
end
for key, command in pairs({ ["<S-l>"] = "bnext", ["<S-h>"] = "bprevious", ["]b"] = "bnext", ["[b"] = "bprevious" }) do
	map("n", key, function()
		focus_editor()
		local items = buffers()
		local index = buffer_index(vim.api.nvim_get_current_buf())
		local delta = command == "bnext" and 1 or -1
		if #items > 0 then
			select_buffer(items[(index + delta - 1) % #items + 1])
		end
	end, command == "bnext" and "Next buffer" or "Previous buffer")
end
for key, delta in pairs({ bj = -1, bk = 1 }) do
	map("n", "<leader>" .. key, function()
		focus_editor()
		local index = buffer_index(vim.api.nvim_get_current_buf())
		local target = math.max(1, math.min(#buffer_order, index + delta))
		local buf = table.remove(buffer_order, index)
		table.insert(buffer_order, target, buf)
		invalidate_tabline()
		vim.cmd("redrawtabline")
	end, "Move buffer in displayed order")
end
for key, field in pairs({ bD = "directory", bL = "language" }) do
	map("n", "<leader>" .. key, function()
		buffers()
		table.sort(buffer_order, function(a, b)
			local left = field == "directory" and vim.fn.fnamemodify(vim.api.nvim_buf_get_name(a), ":h")
				or vim.bo[a].filetype
			local right = field == "directory" and vim.fn.fnamemodify(vim.api.nvim_buf_get_name(b), ":h")
				or vim.bo[b].filetype
			return left == right and a < b or left < right
		end)
		invalidate_tabline()
		vim.cmd("redrawtabline")
	end, "Order buffers by " .. field)
end
local function close_current_buffer(force)
	local is_terminal = vim.bo.buftype == "terminal"
	if vim.bo.modified and not is_terminal and not force then
		vim.notify("Unsaved changes: save the buffer before closing")
		return
	end
	vim.api.nvim_buf_delete(0, { force = force or is_terminal })
end
map("n", "<leader>c", function()
	close_current_buffer(true)
end, "Force wipe current buffer (original binding)")
map("n", "<leader>bw", function()
	close_current_buffer(false)
end, "Wipe buffer (protect unsaved files)")
map("n", "<leader>bp", pick_buffer, "Pick buffer")
map("n", "<leader>sb", pick_buffer, "Search buffers")
for i = 1, 9 do
	map("n", "<A-" .. i .. ">", function()
		local items = buffers()
		local b = items[i == 9 and #items or i]
		if b then
			select_buffer(b)
		end
	end, "Go to buffer " .. i)
end
for key, side in pairs({ be = "all", bm = "all", bh = "left", bl = "right" }) do
	map("n", "<leader>" .. key, function()
		focus_editor()
		local current = vim.api.nvim_get_current_buf()
		local index = buffer_index(current)
		for position, b in ipairs(buffers()) do
			if
				b ~= current
				and (side == "all" or (side == "left" and position < index) or (side == "right" and position > index))
			then
				local is_terminal = vim.bo[b].buftype == "terminal"
				if is_terminal or not vim.bo[b].modified then
					vim.api.nvim_buf_delete(b, { force = is_terminal })
				end
			end
		end
	end, "Close " .. side .. " buffers (keep modified)")
end

-- =========================================
-- ======= PROJECT ROOT / CWD SYNC =======
-- =========================================
-- Git 루트 우선, 없으면 가장 가까운 프로젝트 마커, 없으면 현재 파일 폴더.
-- 트리·검색·LSP가 같은 기준을 쓰며 BufEnter에서 편집 창의 lcd와 트리를 맞춥니다.
local function find_project(dir)
	local git_root = vim.fs.root(dir, ".git")
	if git_root then
		return git_root, true, true
	end
	local marker = vim.fs.find(
		{ "CMakeLists.txt", "compile_commands.json", "Makefile", "package.json", "pyproject.toml" },
		{ path = dir, upward = true, type = "file", limit = 1 }
	)[1]
	return marker and vim.fs.dirname(marker) or dir, false, marker ~= nil
end

-- Use the current file/tree's Git root, independent of where Neovim was launched.
project_root = function()
	local dir = vim.bo.filetype == "netrw" and (vim.w.netrw_treetop or vim.b.netrw_curdir)
		or (vim.bo.buftype == "" and vim.api.nvim_buf_get_name(0) ~= "" and vim.fn.expand("%:p:h"))
	if not dir then
		for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
			local buf = vim.api.nvim_win_get_buf(win)
			local name = vim.api.nvim_buf_get_name(buf)
			if vim.bo[buf].buftype == "" and vim.bo[buf].filetype ~= "netrw" and name ~= "" then
				dir = vim.fn.fnamemodify(name, ":h")
				break
			end
		end
	end
	dir = dir or vim.fn.getcwd()
	return find_project(dir)
end

-- The original config shares project cwd between file navigation, tree and searches.
local syncing_project = false
vim.api.nvim_create_autocmd("BufEnter", {
	group = vim.api.nvim_create_augroup("offline-project-context", { clear = true }),
	callback = function()
		if
			syncing_project
			or vim.bo.buftype ~= ""
			or vim.bo.filetype == "netrw"
			or vim.api.nvim_buf_get_name(0) == ""
		then
			return
		end
		local root, _, recognized = project_root()
		if not recognized then
			return
		end
		local file = vim.api.nvim_buf_get_name(0)
		syncing_project = true
		if vim.fn.getcwd() ~= root then
			vim.cmd("lcd " .. vim.fn.fnameescape(root))
		end
		for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
			if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "netrw" then
				local ok, err = pcall(vim.api.nvim_win_call, win, function()
					local top = vim.w.netrw_treetop or vim.b.netrw_curdir or ""
					if top:gsub("/+$", "") ~= root:gsub("/+$", "") then
						netrw_command("Explore " .. vim.fn.fnameescape(root))
					end
					reveal_tree_file(file:sub(#root + 2))
				end)
				if not ok then
					vim.notify(tostring(err), vim.log.levels.WARN)
				end
			end
		end
		syncing_project = false
	end,
})

-- =========================================
-- ========= ASYNC COMMAND RUNNER ========
-- =========================================
-- 검색·Git·외부 포맷터 공통 실행부. 같은 key의 새 요청은 이전 작업을 취소합니다.
-- 기본 제한: 5초 / stdout 2 MiB. 검색은 부분 결과 허용, 포맷팅·diff는 완성된 결과만 적용.
-- :OfflineCancel: 실행 중인 명령과 picker 취소.
local running = {}
local tag_projects = {}
local definition_requests = {}
local outline, cancel_outline
local function stop_command_timer(task)
	if task.timer then
		task.timer:stop()
		if not task.timer:is_closing() then
			task.timer:close()
		end
		task.timer = nil
	end
end
local function cancel_command(key)
	local task = running[key]
	if task then
		task.cancelled = true
		stop_command_timer(task)
		task.chunks = nil
		if task.process then
			task.process:kill(9)
		end
		running[key] = nil
	end
end
local function cancel_commands()
	if outline and cancel_outline then
		cancel_outline(outline)
	end
	for _, project in pairs(tag_projects) do
		project.generation = project.generation + 1
	end
	for buf, cancel in pairs(definition_requests) do
		definition_requests[buf] = nil
		cancel()
	end
	for key in pairs(running) do
		cancel_command(key)
	end
end
vim.api.nvim_create_user_command("OfflineCancel", function()
	cancel_commands()
	if active_picker then
		active_picker.close()
	end
end, {})
vim.api.nvim_create_autocmd("VimLeavePre", { callback = cancel_commands })
local function run_command(key, argv, opts, callback)
	cancel_command(key)
	local task = { chunks = {}, bytes = 0, errors = "", limited = false }
	running[key] = task
	local limit = opts.max_bytes or 2 * 1024 * 1024
	local ok, process = pcall(vim.system, argv, {
		cwd = opts.cwd,
		stdin = opts.stdin,
		stdout = function(err, data)
			if err then
				task.errors = tostring(err)
			end
			if not data or task.cancelled or task.limited then
				return
			end
			local remaining = limit - task.bytes
			task.chunks[#task.chunks + 1] = data:sub(1, remaining)
			task.bytes = task.bytes + math.min(#data, remaining)
			if #data > remaining then
				task.limited = true
				if task.process then
					task.process:kill(9)
				end
			end
		end,
		stderr = function(err, data)
			local message = data or (err and tostring(err)) or ""
			task.errors = (task.errors .. message):sub(1, 8192)
		end,
	}, function(result)
		vim.schedule(function()
			stop_command_timer(task)
			if task.cancelled then
				return
			end
			running[key] = nil
			if task.limited and not opts.partial then
				task.chunks = nil
				if not opts.quiet then
					vim.notify(key .. ": time/output limit exceeded; result discarded", vim.log.levels.WARN)
				end
				if opts.failed then
					opts.failed()
				end
				return
			end
			if not task.limited and result.code ~= 0 and not (opts.no_match and result.code == 1) then
				task.chunks = nil
				if not opts.quiet then
					vim.notify(
						key .. ": " .. (task.errors ~= "" and task.errors or "command failed (" .. result.code .. ")"),
						vim.log.levels.WARN
					)
				end
				if opts.failed then
					opts.failed()
				end
				return
			end
			if task.limited then
				vim.notify(key .. ": limit reached; partial results", vim.log.levels.WARN)
			end
			local output = table.concat(task.chunks)
			task.chunks = nil
			callback(output, task.limited)
		end)
	end)
	if not ok then
		running[key] = nil
		if not opts.quiet then
			vim.notify(key .. ": " .. tostring(process), vim.log.levels.WARN)
		end
		if opts.failed then
			opts.failed()
		end
		return
	end
	task.process = process
	task.timer = vim.defer_fn(function()
		task.timer = nil
		if running[key] == task and not task.cancelled then
			task.limited = true
			process:kill(9)
		end
	end, opts.timeout or 5000)
end

-- =========================================
-- ====== RESULT PARSING / QUICKFIX ======
-- =========================================
-- 명령 출력은 줄 또는 NUL 단위로 분리합니다. 잘린 출력의 마지막 불완전 항목은 버립니다.
-- Quickfix는 picker에서 Ctrl-q로 명시적으로 내보낼 때 사용합니다.
local function records(output, separator, limited, maximum)
	local items, offset = {}, 1
	while not maximum or #items < maximum do
		local boundary = output:find(separator, offset, true)
		if not boundary then
			if not limited and offset <= #output then
				items[#items + 1] = output:sub(offset)
			end
			break
		end
		items[#items + 1] = output:sub(offset, boundary - 1)
		offset = boundary + #separator
	end
	return items
end
local function show_results(items, title)
	vim.fn.setqflist({}, " ", { title = title, items = items })
	if #items == 0 then
		vim.notify("No results: " .. title)
		return
	end
	focus_editor()
	vim.cmd("botright copen")
	vim.bo.buflisted = false
	vim.opt_local.wrap = false
end
-- =========================================
-- ========== PICKER: SHARED UI ==========
-- =========================================
-- Telescope 대체 공통 UI: 입력 -> 결과 필터/갱신 -> 미리보기 -> 원래 편집 창에 선택 적용.
-- Ctrl-n/p·Tab: 후보 이동, Enter: 선택, Esc: 취소, Ctrl-q: quickfix.
-- 후보 표시 최대 200개. 디스크 미리보기는 앞 64 KiB, 좁은 화면에서는 미리보기 생략.
open_picker = function(title, opts)
	opts = opts or {}
	if active_picker then
		active_picker.close()
	end
	local origin = vim.api.nvim_get_current_win()
	focus_editor()
	local target = vim.api.nvim_get_current_win()
	local width = math.max(24, math.min(vim.o.columns - 4, 120))
	local height = math.max(4, math.min(vim.o.lines - 8, 22))
	local row, col =
		math.max(0, math.floor((vim.o.lines - height - 4) / 2)), math.max(0, math.floor((vim.o.columns - width) / 2))
	local list_width = (width >= 70 or opts.preview) and math.floor(width * 0.48) or width
	local state = { items = {}, matches = {}, index = 1, generation = 0, closed = false, windows = {}, buffers = {} }
	-- -------------------------------------
	-- Create prompt / result / preview windows
	-- -------------------------------------
	local function pane(role, pane_row, pane_col, pane_width, pane_height, enter)
		local buf = vim.api.nvim_create_buf(false, true)
		vim.b[buf].offline_picker_role = role
		vim.bo[buf].bufhidden = "wipe"
		local win = vim.api.nvim_open_win(buf, enter, {
			relative = "editor",
			row = pane_row,
			col = pane_col,
			width = pane_width,
			height = pane_height,
			style = "minimal",
			border = "rounded",
			title = role == "query" and title or role,
		})
		vim.wo[win].wrap = false
		state.windows[#state.windows + 1] = win
		state.buffers[#state.buffers + 1] = buf
		return buf, win
	end
	local list_buf, list_win = pane("results", row + 3, col, list_width, height, false)
	local preview_buf, preview_win
	if list_width < width then
		preview_buf, preview_win = pane("preview", row + 3, col + list_width + 2, width - list_width - 2, height, false)
	end
	local query_buf, query_win = pane("query", row, col, width, 1, true)
	vim.wo[list_win].cursorline = true
	vim.wo[list_win].cursorlineopt = "line"
	local group = vim.api.nvim_create_augroup("offline-picker", { clear = true })
	local function fill(buf, lines)
		if not vim.api.nvim_buf_is_valid(buf) then
			return
		end
		vim.bo[buf].modifiable = true
		vim.api.nvim_buf_set_lines(buf, 0, -1, false, #lines > 0 and lines or { "No matches" })
		vim.bo[buf].modifiable = false
	end
	-- -------------------------------------
	-- Preview: discard responses for an older selection
	-- -------------------------------------
	local preview_generation = 0
	local function preview(item)
		preview_generation = preview_generation + 1
		local version = preview_generation
		if not preview_buf then
			return
		end
		if opts.preview then
			if item then
				opts.preview(item, preview_buf, preview_win)
			end
			return
		end
		fill(preview_buf, { "" })
		if not item then
			return
		end
		local function display(lines)
			if state.closed or version ~= preview_generation then
				return
			end
			local line = math.max(1, item.lnum or 1)
			local first = line <= #lines and math.max(1, line - 8) or 1
			local chunk = {}
			for i = first, math.min(#lines, first + height - 1) do
				chunk[#chunk + 1] = i .. "  " .. lines[i]
			end
			fill(preview_buf, chunk)
		end
		local buf = item.bufnr or (item.filename and vim.fn.bufnr(item.filename)) or -1
		if buf > 0 and vim.api.nvim_buf_is_loaded(buf) then
			local first = math.max(0, (item.lnum or 1) - 9)
			local lines = vim.api.nvim_buf_get_lines(buf, first, first + height, false)
			local chunk = {}
			for i, line in ipairs(lines) do
				chunk[i] = (first + i) .. "  " .. line:sub(1, 500)
			end
			fill(preview_buf, chunk)
		elseif item.filename then
			local uv = vim.uv
			uv.fs_open(item.filename, "r", 438, function(err, fd)
				if err or not fd then
					return
				end
				uv.fs_read(fd, 65536, 0, function(_, data)
					uv.fs_close(fd)
					vim.schedule(function()
						if state.closed or version ~= preview_generation then
							return
						end
						if not data or data:find("\0", 1, true) then
							fill(preview_buf, { "No text preview" })
							return
						end
						display(vim.split(data, "\n", { plain = true }))
					end)
				end)
			end)
		elseif item.text then
			fill(preview_buf, vim.split(item.text, "\n", { plain = true }))
		end
	end
	-- -------------------------------------
	-- Render and filter candidates
	-- -------------------------------------
	local function select_item()
		state.index = math.max(1, math.min(state.index, #state.matches))
		vim.api.nvim_win_set_cursor(list_win, { state.index, 0 })
		preview(state.matches[state.index])
		if opts.highlight then
			opts.highlight(state.matches[state.index])
		end
	end
	local function draw()
		if state.closed then
			return
		end
		local lines = {}
		for _, item in ipairs(state.matches) do
			lines[#lines + 1] = item.label:gsub("[%c]", " ")
		end
		fill(list_buf, lines)
		select_item()
	end
	local function filter()
		local query = vim.api.nvim_buf_get_lines(query_buf, 0, 1, false)[1] or ""
		state.matches = query == "" and vim.list_slice(state.items, 1, 200)
			or vim.fn.matchfuzzy(state.items, query, { key = "label", limit = 200 })
		state.index = 1
		draw()
	end
	function state.set_items(items)
		if state.closed then
			return
		end
		state.items = items
		if opts.live then
			state.matches = vim.list_slice(items, 1, 200)
			state.index = 1
			draw()
		else
			filter()
		end
	end
	-- -------------------------------------
	-- Close lifecycle: cancel work, restore focus, invoke cancellation once
	-- -------------------------------------
	function state.close(accepted)
		if state.closed then
			return
		end
		state.closed = true
		if opts.cancel then
			opts.cancel()
		end
		if not accepted and opts.on_cancel then
			opts.on_cancel()
		end
		vim.cmd("stopinsert")
		vim.api.nvim_del_augroup_by_id(group)
		for _, win in ipairs(state.windows) do
			if vim.api.nvim_win_is_valid(win) then
				vim.api.nvim_win_close(win, true)
			end
		end
		if vim.api.nvim_win_is_valid(origin) then
			vim.api.nvim_set_current_win(origin)
		end
		if active_picker == state then
			active_picker = nil
		end
	end
	-- -------------------------------------
	-- Accept only the selected item into the original editor window
	-- -------------------------------------
	local function accept()
		if vim.api.nvim_get_current_win() == list_win then
			state.index = vim.api.nvim_win_get_cursor(list_win)[1]
		end
		local item = state.matches[state.index]
		if not item then
			return
		end
		state.close(true)
		if vim.api.nvim_win_is_valid(target) then
			vim.api.nvim_set_current_win(target)
		end
		if item.action then
			item.action()
			return
		end
		if item.bufnr and vim.api.nvim_buf_is_valid(item.bufnr) then
			vim.api.nvim_set_current_buf(item.bufnr)
		elseif item.filename then
			vim.cmd("edit " .. vim.fn.fnameescape(item.filename))
		end
		if item.lnum then
			local line = math.min(item.lnum, vim.api.nvim_buf_line_count(0))
			vim.api.nvim_win_set_cursor(0, { math.max(1, line), math.max(0, (item.col or 1) - 1) })
			vim.cmd("normal! zz")
		end
	end
	local function move(delta)
		if #state.matches == 0 then
			return
		end
		state.index = (state.index + delta - 1) % #state.matches + 1
		select_item()
	end
	for _, buf in ipairs(state.buffers) do
		for _, key in ipairs({ "<Esc>", "<C-c>" }) do
			vim.keymap.set({ "n", "i" }, key, state.close, { buf = buf, nowait = true })
		end
		if opts.preview and preview_win then
			for _, key in ipairs({ "<C-f>", "<C-b>" }) do
				vim.keymap.set({ "n", "i" }, key, function()
					vim.api.nvim_win_call(preview_win, function()
						vim.cmd.normal({ args = { vim.keycode(key == "<C-f>" and "<C-d>" or "<C-u>") }, bang = true })
					end)
				end, { buf = buf, desc = "Scroll undo preview" })
			end
		end
		vim.keymap.set({ "n", "i" }, "<CR>", accept, { buf = buf })
		for _, key in ipairs({ "<C-n>", "<Down>", "<Tab>" }) do
			vim.keymap.set({ "n", "i" }, key, function()
				move(1)
			end, { buf = buf })
		end
		for _, key in ipairs({ "<C-p>", "<Up>", "<S-Tab>" }) do
			vim.keymap.set({ "n", "i" }, key, function()
				move(-1)
			end, { buf = buf })
		end
		vim.keymap.set({ "n", "i" }, "<C-q>", function()
			local items = state.matches
			state.close(true)
			show_results(items, title)
		end, { buf = buf, desc = "Send matches to quickfix" })
	end
	-- -------------------------------------
	-- Debounce input and refresh static or live search results
	-- -------------------------------------
	vim.api.nvim_create_autocmd({ "TextChangedI", "TextChanged" }, {
		group = group,
		buf = query_buf,
		callback = function()
			state.generation = state.generation + 1
			local generation = state.generation
			if opts.live then
				if opts.cancel then
					opts.cancel()
				end
				state.items, state.matches, state.index = {}, {}, 1
				draw()
			end
			vim.defer_fn(function()
				if state.closed or generation ~= state.generation then
					return
				end
				if opts.live then
					opts.live(vim.api.nvim_buf_get_lines(query_buf, 0, 1, false)[1] or "", state, generation)
				else
					filter()
				end
			end, 120)
		end,
	})
	vim.api.nvim_create_autocmd("WinClosed", {
		group = group,
		pattern = tostring(query_win),
		callback = function()
			state.close()
		end,
	})
	active_picker = state
	state.set_items(opts.items or {})
	vim.cmd("startinsert")
	return state
end
-- =========================================
-- ====== PICKER: SELECT / LOCATIONS =====
-- =========================================
-- vim.ui.select와 LSP·진단 위치 목록을 공통 picker에 연결합니다.
-- 선택/취소 콜백은 한 번만 실행하고 원래 편집 창으로 복귀합니다.
vim.ui.select = function(items, opts, callback)
	opts = opts or {}
	local choices = {}
	for i, item in ipairs(items) do
		choices[i] = {
			label = opts.format_item and opts.format_item(item) or tostring(item),
			action = function()
				callback(item, i)
			end,
		}
	end
	open_picker(opts.prompt or "Select", {
		items = choices,
		on_cancel = function()
			callback(nil, nil)
		end,
	})
end
local function location_picker(title, locations)
	local root = project_root()
	local items = {}
	for _, item in ipairs(locations) do
		local filename = item.filename or (item.bufnr and vim.api.nvim_buf_get_name(item.bufnr)) or ""
		local label = filename:sub(1, #root + 1) == root .. "/" and filename:sub(#root + 2) or filename
		items[#items + 1] = {
			filename = filename,
			bufnr = item.bufnr,
			lnum = item.lnum,
			col = item.col,
			text = item.text,
			label = label .. ":" .. (item.lnum or 1) .. " " .. (item.text or ""),
		}
	end
	open_picker(title, { items = items })
end
-- =========================================
-- ============ SEARCH: FILES ============
-- =========================================
-- Space f: 프로젝트 파일, Space sn: 설정 파일, Space sr: 최근 파일.
-- find 결과를 비동기로 수집한 뒤 내장 matchfuzzy로 좁힙니다. Git 파일 키는 GIT에 있습니다.
local function file_items(files, root)
	local items = {}
	for _, file in ipairs(files) do
		if file ~= "" then
			local label = root and file:sub(1, #root + 1) == root .. "/" and file:sub(#root + 2)
				or vim.fn.fnamemodify(file, ":~:.")
			items[#items + 1] = { filename = file, lnum = 1, label = label }
		end
	end
	return items
end
local function cancel_search()
	cancel_command("search")
end
local function file_picker(title, root, command)
	local picker = open_picker(title, { cancel = cancel_search })
	run_command("search", command, {
		cwd = root,
		partial = true,
		failed = function()
			picker.set_items({})
		end,
	}, function(output, limited)
		local files = records(output, "\0", limited, 10000)
		for i, file in ipairs(files) do
			if file:sub(1, 1) ~= "/" then
				files[i] = root .. "/" .. file
			end
		end
		picker.set_items(file_items(files, root))
	end)
	return picker
end

local function find_files(root, title)
	file_picker(title, root, {
		"find",
		root,
		"-type",
		"d",
		"(",
		"-name",
		".git",
		"-o",
		"-name",
		"node_modules",
		"-o",
		"-name",
		"__pycache__",
		"-o",
		"-name",
		".venv",
		"-o",
		"-name",
		"venv",
		"-o",
		"-name",
		"build",
		"-o",
		"-name",
		"build-*",
		"-o",
		"-name",
		"cmake-build-*",
		"-o",
		"-name",
		"dist",
		")",
		"-prune",
		"-o",
		"-type",
		"f",
		"-print0",
	})
end
map("n", "<leader>f", function()
	find_files(project_root(), "Find files")
end, "Find files: fuzzy picker")
map("n", "<leader>sn", function()
	find_files(vim.fn.stdpath("config"), "Neovim files")
end, "Find config files")
map("n", "<leader>sr", function()
	local files = vim.tbl_filter(function(file)
		return file ~= "" and vim.fn.filereadable(file) == 1
	end, vim.v.oldfiles)
	open_picker("Recent files", { items = file_items(files) })
end, "Recent files")
-- =========================================
-- ======= SEARCH: EDITOR METADATA =======
-- =========================================
-- Space sc/sh/sk/sp: 명령·도움말·키맵·테마. 테마 미리보기 취소 시 원래 테마를 복구합니다.
local function command_picker(title, kind, action)
	local items = {}
	for _, name in ipairs(vim.fn.getcompletion("", kind)) do
		items[#items + 1] = {
			label = name,
			action = function()
				action(name)
			end,
		}
	end
	open_picker(title, { items = items })
end
map("n", "<leader>sc", function()
	command_picker("Commands", "command", function(name)
		vim.api.nvim_feedkeys(":" .. name .. " ", "n", true)
	end)
end, "Search commands")
map("n", "<leader>sh", function()
	command_picker("Help", "help", function(name)
		vim.cmd("help " .. vim.fn.fnameescape(name))
	end)
end, "Search help")
map("n", "<leader>sp", function()
	local original = vim.g.colors_name or "default"
	local items = {}
	for _, name in ipairs(vim.fn.getcompletion("", "color")) do
		items[#items + 1] = {
			label = name,
			action = function()
				vim.cmd("colorscheme " .. name)
			end,
		}
	end
	open_picker("Colorschemes", {
		items = items,
		highlight = function(item)
			if item then
				vim.cmd("colorscheme " .. item.label)
			end
		end,
		on_cancel = function()
			vim.cmd("colorscheme " .. original)
		end,
	})
end, "Preview and choose colorscheme")
map("n", "<leader>sk", function()
	local items = {}
	for _, mode in ipairs({ "n", "i", "x", "t" }) do
		for _, source in ipairs({
			{ scope = "[global]", mappings = vim.api.nvim_get_keymap(mode) },
			{ scope = "[buffer]", mappings = vim.api.nvim_buf_get_keymap(0, mode) },
		}) do
			for _, key in ipairs(source.mappings) do
				items[#items + 1] = {
					label = mode
						.. " "
						.. source.scope
						.. " "
						.. key.lhs
						.. "  "
						.. (key.desc or key.rhs or "Lua callback"),
				}
			end
		end
	end
	open_picker("Keymaps", { items = items })
end, "Search keymaps")
-- =========================================
-- ======= SEARCH: TEXT / LIVE GREP ======
-- =========================================
-- Space st: 입력마다 정규식 검색; Space t: 커서 단어를 고정 검색 후 결과 필터.
-- Space s/: 열린 파일의 디스크 내용만 검색. rg 우선, 없으면 grep 사용.
-- 새 입력은 이전 작업을 취소하여 오래된 검색 결과가 뒤늦게 표시되지 않게 합니다.
local function search(text, paths, root, fixed, callback)
	if not text or text == "" then
		return
	end
	local use_rg = vim.fn.executable("rg") == 1
	local argv
	if use_rg then
		argv = {
			"rg",
			"--vimgrep",

			"--smart-case",
			"--max-columns",
			"300",
			"--max-columns-preview",
			"--max-filesize",
			"2M",
			"--glob",
			"!.git/**",
			"--glob",
			"!node_modules/**",
			"--glob",
			"!__pycache__/**",
			"--",
			text,
		}
	else
		argv = {
			"grep",
			"-r",
			"-n",
			"-H",
			"-I",
			fixed and "-F" or "-E",
			"--exclude-dir=.git",
			"--exclude-dir=node_modules",
			"--exclude-dir=__pycache__",
		}
		if not text:find("%u") then
			argv[#argv + 1] = "-i"
		end
		vim.list_extend(argv, { "-e", text, "--" })
	end
	if use_rg and fixed then
		table.insert(argv, 2, "--fixed-strings")
	end
	vim.list_extend(argv, paths)
	run_command("search", argv, {
		cwd = root,
		partial = true,
		no_match = true,
		failed = function()
			callback({})
		end,
	}, function(output, limited)
		local items = {}
		for _, line in ipairs(records(output, "\n", limited, 10000)) do
			local filename, lnum, col, content
			if use_rg then
				filename, lnum, col, content = line:match("^(.-):(%d+):(%d+):(.*)$")
			else
				filename, lnum, content = line:match("^(.-):(%d+):(.*)$")
				col = "1"
			end
			if filename and #items < 10000 then
				items[#items + 1] = {
					filename = filename,
					lnum = tonumber(lnum),
					col = tonumber(col),
					text = content:sub(1, 300),
					label = filename:sub(1, #root + 1) == root .. "/"
							and (filename:sub(#root + 2) .. ":" .. lnum .. " " .. content:sub(1, 200))
						or line:sub(1, 300),
				}
			end
		end
		callback(items)
	end)
end

local function text_picker(open_only, word)
	local root = project_root()
	local paths = { root }
	if open_only then
		paths = {}
		for _, buf in ipairs(buffers()) do
			local name = vim.api.nvim_buf_get_name(buf)
			if vim.bo[buf].buftype == "" and name ~= "" then
				paths[#paths + 1] = name
			end
		end
	end
	local function update(text, picker, generation)
		cancel_search()
		if text == "" or #paths == 0 then
			if not picker.closed and (not generation or generation == picker.generation) then
				picker.set_items({})
			end
			return
		end
		search(text, paths, root, word ~= nil, function(items)
			if not picker.closed and (not generation or generation == picker.generation) then
				picker.set_items(items)
			end
		end)
	end
	local picker = open_picker(word and ("Word: " .. word) or (open_only and "Grep open files" or "Live grep"), {
		cancel = cancel_search,
		live = not word and update or nil,
	})
	if word then
		update(word, picker)
	end
end
map("n", "<leader>st", function()
	text_picker(false)
end, "Live grep: update while typing")
map("n", "<leader>t", function()
	text_picker(false, vim.fn.expand("<cword>"))
end, "Find cursor word, then refine matches")
map("n", "<leader>s/", function()
	text_picker(true)
end, "Live grep in open files")
-- =========================================
-- ========== UNDO / WHITESPACE ==========
-- =========================================
-- Replay a copy of the undo history in the preview; only Enter changes the source.
local function undo_picker()
	focus_editor()
	local source = vim.api.nvim_get_current_buf()
	if vim.bo[source].buftype ~= "" or not vim.bo[source].modifiable then
		vim.notify("Undo history is available for editable file buffers", vim.log.levels.WARN)
		return
	end
	if vim.o.columns < 44 then
		vim.notify("Undo preview requires at least 44 terminal columns", vim.log.levels.WARN)
		return
	end
	local tree, entries = vim.fn.undotree(), {}
	local function collect(branch)
		for _, entry in ipairs(branch) do
			entries[#entries + 1] = entry
			if entry.alt then
				collect(entry.alt)
			end
		end
	end
	collect(tree.entries)
	if #entries == 0 then
		vim.notify("No undo history for this buffer yet", vim.log.levels.INFO)
		return
	end
	table.sort(entries, function(a, b)
		return a.seq > b.seq
	end)
	entries[#entries + 1] = { seq = 0 }
	local tick = vim.api.nvim_buf_get_changedtick(source)
	local lines = vim.api.nvim_buf_get_lines(source, 0, -1, false)
	local syntax, path = vim.bo[source].syntax, vim.fn.tempname()
	local items, ready, shown = {}, false, nil
	for _, entry in ipairs(entries) do
		local seq = entry.seq
		items[#items + 1] = {
			seq = seq,
			label = string.format(
				"#%-5d %s%s%s",
				seq,
				seq == 0 and "Initial state" or vim.fn.strftime("%m-%d %H:%M:%S", entry.time),
				entry.save and " [saved]" or "",
				seq == tree.seq_cur and " [current]" or ""
			),
			action = function()
				if not vim.api.nvim_buf_is_valid(source) or vim.api.nvim_buf_get_changedtick(source) ~= tick then
					vim.notify("Buffer changed while browsing undo history; reopen the list", vim.log.levels.WARN)
					return
				end
				vim.api.nvim_set_current_buf(source)
				vim.cmd.undo(seq)
			end,
		}
	end
	local ok, err = pcall(function()
		vim.cmd("silent wundo! " .. vim.fn.fnameescape(path))
		open_picker("Undo · Enter: apply · Esc: cancel", {
			items = items,
			preview = function(item, buf, win)
				vim.api.nvim_win_call(win, function()
					if not ready then
						vim.bo[buf].modifiable = true
						vim.bo[buf].undofile = false
						vim.bo[buf].undolevels = 1000
						vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
						vim.cmd("silent rundo " .. vim.fn.fnameescape(path))
						vim.bo[buf].syntax = syntax
						vim.wo[win].number = true
						ready = true
					end
					if shown ~= item.seq then
						vim.bo[buf].modifiable = true
						vim.cmd("silent undo " .. item.seq)
						vim.bo[buf].modifiable = false
						vim.cmd("normal! zz")
						vim.api.nvim_win_set_config(win, { title = "State #" .. item.seq .. " · Ctrl-f/b: scroll" })
						shown = item.seq
					end
				end)
			end,
		})
	end)
	-- The preview has its own in-memory undo tree once rundo has completed.
	vim.fn.delete(path)
	if not ok then
		if active_picker then
			active_picker.close()
		end
		vim.notify("Unable to preview undo history: " .. tostring(err), vim.log.levels.ERROR)
	end
end
map("n", "<leader>Tu", undo_picker, "Preview undo states (Enter to apply)")
-- Space Ti: 내장 들여쓰기 가이드와 탭·후행 공백 표시 토글.
map("n", "<leader>Ti", "<Cmd>set list!<CR>", "Toggle indent guides / whitespace markers")

-- =========================================
-- ============ SPLIT TERMINAL ===========
-- =========================================
-- Ctrl-t: Space gg와 같은 크기의 하단 split에 같은 셸 작업을 다시 엽니다.
-- 터미널 버퍼는 일반 버퍼 순환에서 제외하고, 종료된 셸만 정리합니다.
local terminal
local function terminal_running(buf)
	local job = vim.b[buf].terminal_job_id
	if type(job) ~= "number" or job <= 0 then
		return false
	end
	local ok, status = pcall(vim.fn.jobwait, { job }, 0)
	return ok and status[1] == -1
end
local function toggle_terminal()
	if
		terminal
		and vim.api.nvim_buf_is_valid(terminal)
		and vim.bo[terminal].buftype == "terminal"
		and not terminal_running(terminal)
	then
		vim.api.nvim_buf_delete(terminal, { force = true })
		terminal = nil
	end
	if terminal and vim.api.nvim_buf_is_valid(terminal) then
		local win = vim.fn.bufwinid(terminal)
		if win ~= -1 then
			vim.cmd("stopinsert")
			vim.api.nvim_win_close(win, true)
			return
		end
	end
	if terminal and vim.api.nvim_buf_is_valid(terminal) then
		vim.cmd("botright sbuffer " .. terminal)
	else
		vim.cmd("botright new")
		terminal = vim.api.nvim_get_current_buf()
		vim.bo.bufhidden = "hide"
		vim.bo.buflisted = false
		vim.fn.jobstart(vim.o.shell, { term = true })
	end
	vim.cmd("startinsert")
end
map({ "n", "t" }, "<C-t>", toggle_terminal, "Toggle bottom terminal")

-- =========================================
-- =========== PROJECT SESSIONS ==========
-- =========================================
-- Persistence 대체: Space pr/pl/pS/pd = 현재 프로젝트 복원/마지막 복원/선택/저장 중지.
-- stdpath(data)/offline/sessions에 저장. 세션은 미저장 편집 내용의 백업이 아닙니다.
local session_dir = offline_data .. "/sessions/"
vim.fn.mkdir(session_dir, "p")
local save_session = true
local function session_path(root)
	return session_dir .. vim.fn.sha256(root or vim.fn.getcwd()) .. ".vim"
end
local function write_session()
	if not save_session or vim.fn.argc() == 0 and #buffers() == 1 and vim.api.nvim_buf_get_name(0) == "" then
		return
	end
	local root = vim.fn.getcwd()
	local path = session_path(root)
	vim.cmd("mksession! " .. vim.fn.fnameescape(path))
	vim.fn.writefile({ root }, path .. ".root")
	vim.fn.writefile({ path }, session_dir .. "last")
end
local function restore_session(path)
	if path and vim.fn.filereadable(path) == 1 then
		vim.cmd("source " .. vim.fn.fnameescape(path))
	else
		vim.notify("No saved session")
	end
end
map("n", "<leader>pr", function()
	restore_session(session_path())
end, "Restore directory session")
map("n", "<leader>pl", function()
	local last = session_dir .. "last"
	restore_session(vim.fn.filereadable(last) == 1 and vim.fn.readfile(last)[1] or nil)
end, "Restore last session")
map("n", "<leader>pd", function()
	save_session = false
end, "Stop saving session")
map("n", "<leader>pS", function()
	vim.ui.select(vim.fn.glob(session_dir .. "*.vim", false, true), {
		prompt = "Sessions:",
		format_item = function(path)
			local metadata = path .. ".root"
			if vim.fn.filereadable(metadata) == 1 then
				local roots = vim.fn.readfile(metadata, "", 1)
				if roots[1] and roots[1] ~= "" then
					return roots[1]
				end
			end
			local directory
			for _, line in ipairs(vim.fn.readfile(path)) do
				local local_directory = line:match("^lcd (.+)$")
				if local_directory then
					return local_directory
				end
				directory = directory or line:match("^cd (.+)$")
			end
			return directory or path
		end,
	}, restore_session)
end, "Select session")
vim.api.nvim_create_autocmd("VimLeavePre", {
	callback = function()
		pcall(write_session)
	end,
})

-- =========================================
-- ====== GIT: FILES / STATUS / DIFF =====
-- =========================================
-- 설치된 git으로 현재 프로젝트를 조회합니다. 네트워크 명령은 실행하지 않습니다.
-- Space Enter: 추적 파일 picker; sg/gg: 로그/상태; gd/gD: index/HEAD 좌우 diff.
-- Space gn/gp: diff 이동; gB: 저장된 파일의 현재 줄 blame.
-- 상태줄: 브랜치와 현재 파일의 index/worktree 상태(XY). 미저장 편집은 기존 %m으로 표시.
-- 화면을 그릴 때는 버퍼 캐시만 읽고, 파일 진입·저장·터미널 복귀 시 비동기로 갱신합니다.
-- netrw Git signs: XY is index/worktree status; ** aggregates mixed children.
local netrw_git_namespace = vim.api.nvim_create_namespace("offline-netrw-git")
local netrw_git_timer = -1
local netrw_git_updated = -1000
local netrw_git_cache = {}
local netrw_git_drawn = {}
local netrw_git_snapshots = {}

local function netrw_git_top(win, buf)
	return vim.w[win].netrw_treetop or vim.b[buf].netrw_curdir or ""
end

local function netrw_git_statuses(root, output)
	local statuses = {}
	local entries = vim.split(output, "\0", { plain = true, trimempty = true })
	local index = 1
	while index <= #entries do
		local record = entries[index]
		local xy = record:sub(1, 2)
		local path = (root:gsub("/+$", "") .. "/" .. record:sub(4)):gsub("/+$", "")
		index = index + (xy:find("[RC]") and 2 or 1)
		while path ~= root and path ~= vim.fs.dirname(path) do
			statuses[path] = statuses[path] and statuses[path] ~= xy and "**" or xy
			path = vim.fs.dirname(path)
		end
	end
	return statuses
end

local function draw_netrw_git(win, buf, top, statuses)
	if
		not vim.api.nvim_win_is_valid(win)
		or vim.api.nvim_win_get_buf(win) ~= buf
		or vim.bo[buf].filetype ~= "netrw"
		or netrw_git_top(win, buf) ~= top
	then
		return
	end
	netrw_git_cache[top] = statuses
	local tick = vim.api.nvim_buf_get_changedtick(buf)
	local drawn = netrw_git_drawn[buf]
	if drawn and drawn.top == top and drawn.tick == tick and drawn.statuses == statuses then
		return
	end
	netrw_git_drawn[buf] = { top = top, tick = tick, statuses = statuses }
	local existing = {}
	for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(buf, netrw_git_namespace, 0, -1, { details = true })) do
		existing[mark[1]] = mark
	end
	local parents = { [0] = top:gsub("/+$", "") }
	for row, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
		local indent = vim.fn.matchstr(line, [[^\%([|│] \)\+]])
		local depth = vim.fn.strchars(indent) / 2
		if depth > 0 and parents[depth - 1] then
			local name = line:sub(#indent + 1):gsub("\t %-%->.*$", ""):gsub("/$", "")
			local path = parents[depth - 1] .. "/" .. name
			-- netrw appends type markers; preserve literal suffixes on real filenames.
			if path:find("[@*=|]$") and not statuses[path] and vim.fn.getftype(path) == "" then
				path = path:gsub("[@*=|]$", "")
			end
			parents[depth] = path
			local xy = statuses[path]
			if xy then
				local highlight = (xy:find("U") or xy == "AA" or xy == "DD") and "ErrorMsg"
					or xy == "**" and "Directory"
					or xy:find("D") and "DiffDelete"
					or xy:find("[A?]") and "DiffAdd"
					or "DiffChange"
				local text = xy:gsub(" ", ".")
				local previous = existing[row]
				existing[row] = nil
				if not previous or previous[2] ~= row - 1 or previous[4].sign_text ~= text then
					vim.api.nvim_buf_set_extmark(buf, netrw_git_namespace, row - 1, 0, {
						id = row,
						sign_text = text,
						sign_hl_group = highlight,
						priority = 20,
					})
				end
			end
		end
	end
	for id in pairs(existing) do
		vim.api.nvim_buf_del_extmark(buf, netrw_git_namespace, id)
	end
end

local function redraw_netrw_git()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.bo[buf].filetype == "netrw" then
			local top = netrw_git_top(win, buf)
			draw_netrw_git(win, buf, top, netrw_git_cache[top] or {})
		end
	end
end

local function refresh_netrw_git()
	netrw_git_timer = -1
	netrw_git_updated = vim.uv.now()
	local projects = {}
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.bo[buf].filetype == "netrw" then
			local top = netrw_git_top(win, buf)
			local root = vim.fs.root(top, ".git")
			if not root or vim.fn.isdirectory(top) == 0 then
				draw_netrw_git(win, buf, top, {})
			else
				projects[root] = true
			end
		end
	end
	for root in pairs(projects) do
		local key = "git-tree:" .. root
		-- One job and one status snapshot for every visible tree in this project.
		if running[key] then
			if netrw_git_timer == -1 then
				netrw_git_timer = vim.fn.timer_start(1000, refresh_netrw_git)
			end
		else
			local function draw_project(statuses)
				for _, win in ipairs(vim.api.nvim_list_wins()) do
					local buf = vim.api.nvim_win_get_buf(win)
					if vim.bo[buf].filetype == "netrw" then
						local top = netrw_git_top(win, buf)
						if vim.fs.root(top, ".git") == root then
							draw_netrw_git(win, buf, top, statuses)
						end
					end
				end
			end
			run_command(key, {
				"git", "--no-optional-locks", "status", "--porcelain=v1", "-z", "--untracked-files=all",
			}, {
				cwd = root,
				quiet = true,
				failed = function()
					netrw_git_snapshots[root] = nil
					draw_project({})
				end,
			}, function(output)
				local snapshot = netrw_git_snapshots[root]
				if not snapshot or snapshot.output ~= output then
					snapshot = { output = output, statuses = netrw_git_statuses(root, output) }
					netrw_git_snapshots[root] = snapshot
				end
				draw_project(snapshot.statuses)
			end)
		end
	end
end

local function queue_netrw_git()
	if netrw_git_timer == -1 then
		local delay = math.max(100, 1000 - (vim.uv.now() - netrw_git_updated))
		netrw_git_timer = vim.fn.timer_start(delay, refresh_netrw_git)
	end
end

local netrw_git_group = vim.api.nvim_create_augroup("offline-netrw-git", { clear = true })
vim.api.nvim_create_autocmd("BufWipeout", {
	group = netrw_git_group,
	callback = function(args)
		netrw_git_drawn[args.buf] = nil
	end,
})
vim.api.nvim_create_autocmd("FileType", {
	group = netrw_git_group,
	pattern = "netrw",
	callback = queue_netrw_git,
})
vim.api.nvim_create_autocmd({ "BufWinEnter", "BufWritePost", "FocusGained", "ShellCmdPost", "TermLeave", "TermClose" }, {
	group = netrw_git_group,
	callback = queue_netrw_git,
})
vim.api.nvim_create_autocmd("TextChanged", {
	group = netrw_git_group,
	callback = function()
		if vim.bo.filetype == "netrw" then
			redraw_netrw_git()
		end
	end,
})
vim.api.nvim_create_autocmd("User", {
	group = netrw_git_group,
	pattern = "OfflineNetrwRedraw",
	callback = redraw_netrw_git,
})
vim.api.nvim_create_autocmd("VimLeavePre", {
	group = netrw_git_group,
	callback = function()
		vim.fn.timer_stop(netrw_git_timer)
	end,
})

local function refresh_git_status(buf)
	if not vim.api.nvim_buf_is_loaded(buf) then
		return
	end
	local key = "git-status:" .. buf
	cancel_command(key)
	local file = vim.api.nvim_buf_get_name(buf)
	local root = vim.bo[buf].buftype == "" and file ~= "" and vim.fs.root(vim.fs.dirname(file), ".git")
	if not root or vim.fn.executable("git") == 0 then
		vim.b[buf].offline_git_status = nil
		return
	end
	run_command(key, {
		"git",
		"--no-optional-locks",
		"--literal-pathspecs",
		"status",
		"--porcelain=v2",
		"--branch",
		"--no-ahead-behind",
		"-z",
		"--",
		file,
	}, { cwd = root, quiet = true }, function(output)
		if not vim.api.nvim_buf_is_loaded(buf) or vim.api.nvim_buf_get_name(buf) ~= file then
			return
		end
		local branch, oid, xy
		for record in output:gmatch("[^%z]+") do
			branch = record:match("^# branch.head (.+)$") or branch
			oid = record:match("^# branch.oid (.+)$") or oid
			xy = record:match("^[12u] (%S+) ") or (record:sub(1, 2) == "? " and "??") or xy
		end
		if branch == "(detached)" then
			branch = "HEAD@" .. (oid or ""):sub(1, 7)
		end
		local status = branch and ("[git:" .. branch .. (xy and " " .. xy or "") .. "]") or ""
		if vim.b[buf].offline_git_status ~= status then
			vim.b[buf].offline_git_status = status
			vim.cmd("redrawstatus")
		end
	end)
end
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "FocusGained", "TermLeave", "TermClose" }, {
	group = vim.api.nvim_create_augroup("offline-git-status", { clear = true }),
	callback = function(args)
		if args.event == "TermLeave" or args.event == "TermClose" then
			for _, buf in ipairs(vim.api.nvim_list_bufs()) do
				if vim.fn.bufwinid(buf) ~= -1 then
					refresh_git_status(buf)
				end
			end
		else
			refresh_git_status(args.buf)
		end
	end,
})
local function git(args, callback, opts)
	local root, is_git = project_root()
	if not is_git then
		vim.notify("Current file is not in a Git project")
		return
	end
	opts = opts or {}
	opts.cwd = root
	run_command(opts.key or "git", vim.list_extend({ "git", "--no-pager" }, args), opts, callback)
end
local function show_output(lines, filetype, vertical)
	vim.cmd(vertical and "rightbelow vnew" or "botright new")
	vim.bo.buftype = "nofile"
	vim.bo.buflisted = false
	vim.bo.bufhidden = "wipe"
	vim.bo.swapfile = false
	vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
	vim.bo.filetype = filetype
	vim.bo.modifiable = false
end
map("n", "<leader><CR>", function()
	local root, is_git = project_root()
	if not is_git then
		vim.notify("Current file is not in a Git project")
		return
	end
	file_picker("Git files", root, { "git", "ls-files", "-z" })
end, "Git files: fuzzy picker")
map("n", "<leader>sg", function()
	git({ "log", "-50", "--oneline" }, function(output)
		show_output(records(output, "\n"), "git")
	end)
end, "Git commits")
map("n", "<leader>gg", function()
	git({ "status", "--short", "--branch", "--untracked-files=normal" }, function(output)
		show_output(records(output, "\n"), "git")
	end)
end, "Git status")
for key, revision in pairs({ gd = ":", gD = "HEAD:" }) do
	map("n", "<leader>" .. key, function()
		local file, buf, win =
			vim.api.nvim_buf_get_name(0), vim.api.nvim_get_current_buf(), vim.api.nvim_get_current_win()
		if vim.bo.buftype ~= "" or file == "" then
			vim.notify("Open a tracked file first")
			return
		end
		local root = project_root()
		local relative = file:sub(#root + 2)
		local ft = vim.bo.filetype
		git({ "show", revision .. relative }, function(output)
			if not vim.api.nvim_win_is_valid(win) or vim.api.nvim_win_get_buf(win) ~= buf then
				return
			end
			vim.api.nvim_set_current_win(win)
			vim.cmd("diffthis")
			show_output(records(output, "\n"), ft, true)
			vim.cmd("diffthis")
		end)
	end, "Diff against " .. revision .. " (:diffoff! to finish)")
end
map("n", "<leader>gn", "]c", "Next diff hunk")
map("n", "<leader>gp", "[c", "Previous diff hunk")
map("n", "<leader>gB", function()
	local file = vim.api.nvim_buf_get_name(0)
	if vim.bo.buftype ~= "" or file == "" then
		vim.notify("Open a tracked file first")
		return
	end
	local line = tostring(vim.fn.line("."))
	git({ "blame", "-L", line .. "," .. line, "--", file }, function(output)
		show_output(records(output, "\n"), "git")
	end)
end, "Blame current line (saved file)")

-- =========================================
-- ======== GIT: LINE CHANGE SIGNS =======
-- =========================================
-- 현재 버퍼(미저장 내용 포함)를 index와 비교하여 + / ~ / - 표시. stage/reset은 하지 않습니다.
-- 입력 후 200ms debounce. 미추적·바이너리·256 KiB 초과 파일은 제외합니다.
-- 혼합 구간의 수정/추가 구분은 내용 유사도 추정이며 실제 편집 이력 복원은 아닙니다.
local git_signs = vim.api.nvim_create_namespace("offline-git-signs")
local git_sign_versions = {}
local git_base_cache = {}
-- A diff hunk gives counts, not which inserted lines replace the removed lines.
-- Align mixed hunks by content so an inserted blank does not steal a change sign.
local function changed_lines(old, new, hunk, budget)
	local a, m, b, n = unpack(hunk)
	local changed = {}
	if m == 0 or n == 0 then
		return changed, budget
	end
	local simple = m == n or m * n > budget
	if not simple then
		for i = a, a + m - 1 do
			simple = simple or #old[i] > 256
		end
		for j = b, b + n - 1 do
			simple = simple or #new[j] > 256
		end
	end
	if simple then
		for j = 0, n - 1 do
			changed[j] = true
		end
		return changed, budget
	end
	local costs, steps = { [0] = {} }, {}
	for j = 0, n do
		costs[0][j] = j
	end
	for i = 1, m do
		costs[i], steps[i] = { [0] = i }, {}
		for j = 1, n do
			local left, right = old[a + i - 1], new[b + j - 1]
			local prefix, suffix, length = 0, 0, math.min(#left, #right)
			while prefix < length and left:byte(prefix + 1) == right:byte(prefix + 1) do
				prefix = prefix + 1
			end
			while suffix < length - prefix and left:byte(#left - suffix) == right:byte(#right - suffix) do
				suffix = suffix + 1
			end
			local similarity = (prefix + suffix) / math.max(1, #left, #right)
			local pair_cost = left == right and 0 or 1.8 - similarity
			if (left:match("^%s*$") ~= nil) ~= (right:match("^%s*$") ~= nil) then
				pair_cost = 1.95
			end
			local best, step = costs[i - 1][j - 1] + pair_cost, "pair"
			if costs[i][j - 1] + 1 < best then
				best, step = costs[i][j - 1] + 1, "add"
			end
			if costs[i - 1][j] + 1 < best then
				best, step = costs[i - 1][j] + 1, "delete"
			end
			costs[i][j], steps[i][j] = best, step
		end
	end
	local i, j = m, n
	while i > 0 and j > 0 do
		local step = steps[i][j]
		if step == "pair" then
			changed[j - 1] = true
			i, j = i - 1, j - 1
		elseif step == "add" then
			j = j - 1
		else
			i = i - 1
		end
	end
	return changed, budget - m * n
end
local function queue_git_signs(buf, invalidate)
	if invalidate then
		git_base_cache[buf] = nil
	end
	git_sign_versions[buf] = (git_sign_versions[buf] or 0) + 1
	local version = git_sign_versions[buf]
	local key = "git-signs:" .. buf
	cancel_command(key)
	if not vim.api.nvim_buf_is_loaded(buf) then
		return
	end
	local function clear_signs()
		if git_sign_versions[buf] == version and vim.api.nvim_buf_is_loaded(buf) then
			vim.api.nvim_buf_clear_namespace(buf, git_signs, 0, -1)
		end
	end
	-- Keep existing signs during debounce/IO; replace them only with a current result.
	vim.defer_fn(function()
		if git_sign_versions[buf] ~= version or not vim.api.nvim_buf_is_loaded(buf) then
			return
		end
		local file = vim.api.nvim_buf_get_name(buf)
		-- Bound the native diff work as well as the asynchronous Git output.
		local limit = 256 * 1024
		if
			vim.bo[buf].buftype ~= ""
			or vim.b[buf].offline_large_file
			or file == ""
			or vim.fn.executable("git") == 0
			or vim.api.nvim_buf_line_count(buf) > 20000
			or vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf)) > limit
		then
			clear_signs()
			return
		end
		local root, is_git
		vim.api.nvim_buf_call(buf, function()
			root, is_git = project_root()
		end)
		if not is_git then
			clear_signs()
			return
		end
		local tick = vim.api.nvim_buf_get_changedtick(buf)
		local current = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
		if vim.bo[buf].endofline then
			current = current .. "\n"
		end
		local function apply_base(base)
			if
				git_sign_versions[buf] ~= version
				or not vim.api.nvim_buf_is_loaded(buf)
				or vim.api.nvim_buf_get_changedtick(buf) ~= tick
				or vim.api.nvim_buf_get_name(buf) ~= file
			then
				return
			end
			if base:find("\0", 1, true) or current:find("\0", 1, true) then
				clear_signs()
				return
			end
			local count = vim.api.nvim_buf_line_count(buf)
			local old, new = vim.split(base, "\n", { plain = true }), vim.split(current, "\n", { plain = true })
			if #old > 20001 then
				clear_signs()
				return
			end
			local hunks = vim.text.diff(base, current, { result_type = "indices", algorithm = "myers" })
			clear_signs()
			local signs = 0
			for _, hunk in ipairs(hunks) do
				signs = signs + math.max(1, hunk[4])
				if signs > 2000 then
					return
				end
			end
			local budget = 4096
			for _, hunk in ipairs(hunks) do
				local removed, start, added = hunk[2], hunk[3], hunk[4]
				local changed
				changed, budget = changed_lines(old, new, hunk, budget)
				for offset = 0, math.max(1, added) - 1 do
					local text = added == 0 and "-" or (changed[offset] and "~" or "+")
					if added > 0 and removed > added and offset == added - 1 then
						text = "~-"
					end
					local line = math.max(1, math.min(count, start + offset))
					vim.api.nvim_buf_set_extmark(buf, git_signs, line - 1, 0, {
						sign_text = text,
						sign_hl_group = added == 0 and "DiffDelete" or (changed[offset] and "DiffChange" or "DiffAdd"),
						priority = 5,
					})
				end
			end
		end
		local cached = git_base_cache[buf]
		if cached and cached.file == file and cached.root == root then
			if cached.base then
				apply_base(cached.base)
			else
				clear_signs()
			end
			return
		end
		run_command(key, { "git", "--no-pager", "show", ":./" .. file:sub(#root + 2) }, {
			cwd = root,
			max_bytes = limit,
			quiet = true,
			failed = function()
				if git_sign_versions[buf] == version then
					git_base_cache[buf] = { file = file, root = root, base = false }
					clear_signs()
				end
			end,
		}, function(base)
			if git_sign_versions[buf] == version then
				git_base_cache[buf] = { file = file, root = root, base = base }
				apply_base(base)
			end
		end)
	end, 200)
end
vim.api.nvim_create_autocmd(
	{
		"BufEnter",
		"BufWritePost",
		"TextChanged",
		"TextChangedI",
		"FocusGained",
		"ShellCmdPost",
		"TermLeave",
		"TermClose",
	},
	{
		group = vim.api.nvim_create_augroup("offline-git-signs", { clear = true }),
		callback = function(args)
			if
				args.event == "FocusGained"
				or args.event == "ShellCmdPost"
				or args.event == "TermLeave"
				or args.event == "TermClose"
			then
				git_base_cache = {}
				for _, win in ipairs(vim.api.nvim_list_wins()) do
					queue_git_signs(vim.api.nvim_win_get_buf(win))
				end
			else
				queue_git_signs(args.buf, args.event ~= "TextChanged" and args.event ~= "TextChangedI")
			end
		end,
	}
)
vim.api.nvim_create_autocmd("BufWipeout", {
	group = "offline-git-signs",
	callback = function(args)
		git_sign_versions[args.buf] = nil
		git_base_cache[args.buf] = nil
		local key = "git-signs:" .. args.buf
		cancel_command(key)
	end,
})

-- =========================================
-- ============== FORMATTING =============
-- =========================================
-- Conform 대체: lsp/bin → PATH에서 외부 도구를 찾아 비동기 실행, 없으면 LSP 포맷팅 시도.
-- Python은 Ruff를 우선하고, 없으면 Black을 사용합니다. 저장 시 자동 포맷팅은 없습니다.
-- 외부 결과는 변경된 줄 구간만 적용하며 실행 중 버퍼 수정/삭제 시 버립니다.
local formatters = {
	lua = { { "stylua", "--stdin-filepath", "%", "-" } },
	c = { { "clang-format", "--assume-filename=%" } },
	cpp = { { "clang-format", "--assume-filename=%" } },
	python = {
		{ "ruff", "format", "--stdin-filename", "%", "-" },
		{ "black", "--quiet", "--stdin-filename", "%", "-" },
	},
	javascript = { { "prettier", "--stdin-filepath", "%" } },
}
map("n", "<leader>lf", function()
	if vim.bo.buftype ~= "" or not vim.bo.modifiable then
		vim.notify("Open an editable file before formatting")
		return
	end
	local buf = vim.api.nvim_get_current_buf()
	local tick = vim.api.nvim_buf_get_changedtick(buf)
	local file = vim.api.nvim_buf_get_name(buf)
	if vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf)) > 2 * 1024 * 1024 then
		vim.notify("Formatting skipped: file exceeds 2 MiB")
		return
	end
	local root = project_root()
	local candidates = formatters[vim.bo.filetype]
	if not candidates then
		vim.lsp.buf.format({ async = true })
		return
	end
	local command
	for _, candidate in ipairs(candidates) do
		local executable = resolve_tool(candidate[1])
		if executable ~= "" then
			command = vim.deepcopy(candidate)
			command[1] = executable
			break
		end
	end
	if not command then
		vim.notify("Formatter missing; trying LSP")
		vim.lsp.buf.format({ async = true })
		return
	end
	local original_endofline = vim.bo[buf].endofline
	local input = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
		.. (original_endofline and "\n" or "")
	local function apply(content)
		if
			not vim.api.nvim_buf_is_valid(buf)
			or not vim.bo[buf].modifiable
			or vim.api.nvim_buf_get_changedtick(buf) ~= tick
		then
			vim.notify("Buffer changed during formatting; result discarded")
			return
		end
		local edits = vim.text.diff(input, content, { result_type = "indices" })
		local lines = records(content, "\n")
		for i = #edits, 1, -1 do
			local old_start, old_count, new_start, new_count = unpack(edits[i])
			local start = old_count == 0 and old_start or old_start - 1
			if i < #edits then
				vim.api.nvim_buf_call(buf, function()
					vim.cmd("undojoin")
				end)
			end
			vim.api.nvim_buf_set_lines(
				buf,
				start,
				start + old_count,
				false,
				vim.list_slice(lines, new_start, new_start + new_count - 1)
			)
		end
		vim.bo[buf].endofline = original_endofline
	end
	local args = vim.tbl_map(function(arg)
		return (arg:gsub("%%", function()
			return file
		end))
	end, command)
	run_command("format:" .. buf, args, { stdin = input, cwd = root }, apply)
end, "Format asynchronously with installed tool or LSP")

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
	add(vim.g.offline_ctags)
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
				"Universal or Exuberant Ctags required; check ctags --version or g:offline_ctags",
				vim.log.levels.WARN
			)
		end
		callback(available)
	end
	if ctags_probe and not running["ctags-probe"] then
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
		run_command("ctags-probe", { command, "--options=NONE", "--version" }, {
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
local function tag_context(buf)
	if
		not vim.api.nvim_buf_is_valid(buf)
		or vim.bo[buf].buftype ~= ""
		or vim.bo[buf].filetype == "netrw"
		or vim.b[buf].offline_large_file
	then
		return
	end
	local file = vim.api.nvim_buf_get_name(buf)
	if file == "" then
		return
	end
	file = vim.uv.fs_realpath(file) or file
	local root = find_project(vim.fs.dirname(file))
	return root, file
end
local function tag_project(root)
	if not tag_projects[root] then
		vim.fn.mkdir(offline_data .. "/tags", "p")
		tag_projects[root] = { path = offline_data .. "/tags/" .. vim.fn.sha256(root), pending = {}, generation = 0 }
	end
	return tag_projects[root]
end
local function attach_tags(buf)
	local root = tag_context(buf)
	local project = root and tag_projects[root]
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
local function tag_filename(line)
	local file = line:match("^[^\t]+\t([^\t]+)") or ""
	return (file:gsub("\\(.)", { t = "\t", r = "\r", n = "\n", ["\\"] = "\\" }))
end
local function build_tags(root, full, files, after, failed, quiet)
	local project = tag_project(root)
	project.generation = project.generation + 1
	local generation = project.generation
	cancel_command("ctags:" .. root)
	for _, file in ipairs(files or {}) do
		project.pending[file] = true
	end
	local changed = full and {} or vim.tbl_keys(project.pending)
	if not full and #changed == 0 then
		return
	end
	ctags_available(quiet, function(available)
		if tag_projects[root] ~= project or project.generation ~= generation then
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
					if tag_projects[root] ~= project or project.generation ~= generation then
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
						project.ready, project.pending = true, {}
					else
						for _, file in ipairs(changed) do
							project.pending[file] = nil
						end
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
			run_command("ctags:" .. root, command, {
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
			run_command("ctags:" .. root, { "git", "ls-files", "-z", "--cached", "--others", "--exclude-standard" }, {
				cwd = root,
				timeout = 30000,
				max_bytes = 16 * 1024 * 1024,
				failed = failed,
			}, function(output)
				local sources, seen = {}, {}
				for _, file in ipairs(records(output, "\0")) do
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
			end)
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
local function request_tags(full, after, quiet)
	focus_editor()
	local buf, win = vim.api.nvim_get_current_buf(), vim.api.nvim_get_current_win()
	local root, file = tag_context(buf)
	if not root or file:find("[\r\n]") then
		return
	end
	build_tags(root, full, { file }, after and function()
		if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == buf then
			vim.api.nvim_win_call(win, after)
		else
			vim.notify("Ctags index ready; repeat navigation in the desired file")
		end
	end, nil, quiet)
end
local function ctags_definition()
	focus_editor()
	local root = tag_context(vim.api.nvim_get_current_buf())
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
map("n", "g<C-t>", "<Cmd>pop<CR>", "Return from ctags definition")
vim.api.nvim_create_user_command("CtagsUpdate", function()
	request_tags(true)
end, {})
vim.api.nvim_create_user_command("CtagsClearAll", function()
	for root, project in pairs(tag_projects) do
		project.generation = project.generation + 1
		cancel_command("ctags:" .. root)
	end
	tag_projects = {}
	vim.fn.delete(offline_data .. "/tags", "rf")
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		vim.b[buf].offline_tags_requested = nil
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
		#vim.lsp.get_clients({ bufnr = buf, method = "textDocument/completion" }) > 0
		or vim.b[buf].offline_tags_requested
		or vim.b[buf].offline_large_file
		or not vim.tbl_contains({ "c", "cpp", "python" }, vim.bo[buf].filetype)
	then
		return
	end
	local root, file = tag_context(buf)
	if not root or file:find("[\r\n]") then
		return
	end
	vim.b[buf].offline_tags_requested = true
	build_tags(root, false, { file }, nil, function()
		if vim.api.nvim_buf_is_valid(buf) then
			vim.b[buf].offline_tags_requested = nil
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
		local root, file = tag_context(args.buf)
		local project = root and tag_projects[root]
		if not project or file:find("[\r\n]") then
			return
		end
		project.pending[file] = true
		cancel_command("ctags:" .. root)
		project.generation = project.generation + 1
		local generation = project.generation
		vim.defer_fn(function()
			if project.generation == generation then
				build_tags(root, false)
			end
		end, 750)
	end,
})

-- Prefer connected providers; failed, empty or timed-out requests use saved tags.
map("n", "gd", function()
	focus_editor()
	local buf, win = vim.api.nvim_get_current_buf(), vim.api.nvim_get_current_win()
	if definition_requests[buf] then
		definition_requests[buf]()
	end
	if #vim.lsp.get_clients({ bufnr = buf, method = "textDocument/definition" }) == 0 then
		ctags_definition()
		return
	end
	local position, tick = vim.api.nvim_win_get_cursor(win), vim.api.nvim_buf_get_changedtick(buf)
	local done, cancel = false, nil
	local function stop()
		done = true
		definition_requests[buf] = nil
		if cancel then
			cancel()
		end
	end
	definition_requests[buf] = stop
	local function finish(results)
		if done then
			return
		end
		stop()
		-- A late response must not redirect a different file or a moved cursor.
		if
			not vim.api.nvim_win_is_valid(win)
			or vim.api.nvim_win_get_buf(win) ~= buf
			or vim.api.nvim_buf_get_changedtick(buf) ~= tick
			or not vim.deep_equal(vim.api.nvim_win_get_cursor(win), position)
		then
			return
		end
		vim.api.nvim_win_call(win, function()
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
		end)
	end
	cancel = vim.lsp.buf_request_all(buf, "textDocument/definition", function(client)
		return vim.lsp.util.make_position_params(win, client.offset_encoding)
	end, finish)
	vim.defer_fn(function()
		finish({})
	end, 5000)
end, "Go to definition: LSP, then ctags")

-- =========================================
-- ======= LSP: SERVER DEFINITIONS =======
-- =========================================
-- Neovim 0.12 내장 클라이언트. 아래 목록의 실행 파일이 이미 설치되어 있어야 합니다.
-- stdpath(config)/lsp/bin → PATH → 기존 stdpath(data)/mason/bin 순서.
-- Mason 로드·자동 설치는 하지 않습니다.
local servers = {
	{ cmd = { "clangd" }, ft = { "c", "cpp", "objc", "objcpp", "cuda" } },
	{ alternatives = { { "ty", "server" }, { "pyright-langserver", "--stdio" } }, ft = { "python" } },
	{ cmd = { "lua-language-server" }, ft = { "lua" }, settings = { Lua = { diagnostics = { globals = { "vim" } } } } },
	{
		cmd = { "typescript-language-server", "--stdio" },
		ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	},
	{ cmd = { "vscode-html-language-server", "--stdio" }, ft = { "html" } },
	{ cmd = { "vscode-css-language-server", "--stdio" }, ft = { "css", "scss", "less" } },
	{
		cmd = { "tailwindcss-language-server", "--stdio" },
		markers = { "tailwind.config.js", "tailwind.config.cjs", "tailwind.config.mjs", "tailwind.config.ts" },
		dependency = "tailwindcss",
		ft = { "html", "css", "javascriptreact", "typescriptreact", "svelte" },
	},
	{ cmd = { "svelteserver", "--stdio" }, ft = { "svelte" } },
	{ cmd = { "graphql-lsp", "server", "-m", "stream" }, ft = { "graphql" } },
	{
		cmd = { "emmet-ls", "--stdio" },
		ft = { "html", "css", "javascriptreact", "typescriptreact" },
		markers = { ".emmet.json", "emmet.json" },
	},
	{ cmd = { "prisma-language-server", "--stdio" }, ft = { "prisma" } },
	{
		cmd = { "vscode-eslint-language-server", "--stdio" },
		markers = {
			"eslint.config.js",
			"eslint.config.mjs",
			"eslint.config.cjs",
			"eslint.config.ts",
			".eslintrc",
			".eslintrc.json",
			".eslintrc.js",
			".eslintrc.cjs",
			".eslintrc.yml",
			".eslintrc.yaml",
		},
		dependency = "eslint",
		ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
	},
}
-- =========================================
-- ====== PYTHON: INTERPRETER PICKER ======
-- =========================================
-- Space lv: 현재 프로젝트의 Python LSP 분석 환경 선택. 재실행 전까지 프로젝트별로 기억합니다.
-- 가상환경을 생성하거나 셸/포맷터 PATH를 바꾸지 않습니다. symlink 경로는 그대로 보존합니다.
local python_paths = {}
local function apply_python_path(client, path)
	client.settings = vim.deepcopy(client.settings)
	if client.name == "ty" then
		client.settings.ty = client.settings.ty or {}
		client.settings.ty.configuration = client.settings.ty.configuration or {}
		local configuration = client.settings.ty.configuration
		configuration.environment = configuration.environment or {}
		configuration.environment.python = path
		if not next(configuration.environment) then
			configuration.environment = vim.empty_dict()
		end
	else
		client.settings.python = client.settings.python or vim.empty_dict()
		client.settings.python.pythonPath = path
	end
	client.config.settings = client.settings
end
map("n", "<leader>lv", function()
	if vim.bo.filetype ~= "python" then
		vim.notify("Open a Python file to select its environment")
		return
	end
	local root = project_root()
	local choices, seen = {}, {}
	local function add(label, path)
		if path and path ~= "" and not seen[path] and vim.fn.executable(path) == 1 then
			seen[path] = true
			choices[#choices + 1] = { label = label .. ": " .. path, path = path }
		end
	end
	add("Selected", python_paths[root])
	add("Project .venv", root .. "/.venv/bin/python")
	add("Project venv", root .. "/venv/bin/python")
	add("Active venv", vim.env.VIRTUAL_ENV and vim.env.VIRTUAL_ENV .. "/bin/python")
	add("Active Conda", vim.env.CONDA_PREFIX and vim.env.CONDA_PREFIX .. "/bin/python")
	add("PATH python", vim.fn.exepath("python"))
	add("PATH python3", vim.fn.exepath("python3"))
	choices[#choices + 1] = { label = "Enter Python path...", manual = true }
	choices[#choices + 1] = { label = "Automatic (project settings / inherited PATH)" }
	local function select_path(path)
		local changed = python_paths[root] ~= path
		python_paths[root] = path
		local attached, restarting = false, false
		for _, client in ipairs(vim.lsp.get_clients()) do
			if (client.name == "ty" or client.name == "pyright-langserver") and client.config.root_dir == root then
				attached = true
				if changed then
					if client.name == "ty" then
						-- Restart ty so versions without didChangeConfiguration also reload imports.
						local buffers = vim.tbl_keys(client.attached_buffers)
						local config = vim.deepcopy(client.config)
						client:stop(true)
						local id = vim.lsp.start(config, { attach = false })
						if id then
							for _, buf in ipairs(buffers) do
								if vim.api.nvim_buf_is_loaded(buf) and not vim.b[buf].offline_large_file then
									vim.lsp.buf_attach_client(buf, id)
								end
							end
						end
						restarting = id ~= nil
					else
						apply_python_path(client, path)
						client:notify("workspace/didChangeConfiguration", { settings = client.settings })
					end
				end
			end
		end
		vim.notify(
			"Python: "
				.. (path or "automatic")
				.. (restarting and " (restarting ty)" or (attached and "" or " (applies when Python LSP attaches)"))
		)
	end
	local function choose(item)
		if not item then
			return
		end
		if not item.manual then
			select_path(item.path)
			return
		end
		vim.ui.input({ prompt = "Python executable or venv directory: ", completion = "file" }, function(path)
			if not path or path == "" then
				return
			end
			path = vim.fs.normalize(path)
			if path:sub(1, 1) ~= "/" then
				path = vim.fs.normalize(root .. "/" .. path)
			end
			if vim.fn.isdirectory(path) == 1 then
				path = path .. "/bin/python"
			end
			if vim.fn.executable(path) ~= 1 then
				vim.notify("Python executable not found: " .. path, vim.log.levels.WARN)
				return
			end
			select_path(path)
		end)
	end
	local function items()
		return vim.tbl_map(function(choice)
			return {
				label = choice.label,
				action = function()
					choose(choice)
				end,
			}
		end, choices)
	end
	local picker = open_picker("Python environment: " .. vim.fn.fnamemodify(root, ":t"), {
		items = items(),
		cancel = function()
			cancel_command("conda-envs")
		end,
	})
	local conda = vim.fn.exepath("conda")
	if conda == "" and vim.env.CONDA_EXE and vim.fn.executable(vim.env.CONDA_EXE) == 1 then
		conda = vim.env.CONDA_EXE
	end
	if conda ~= "" then
		run_command("conda-envs", { conda, "env", "list", "--json" }, { cwd = root, quiet = true }, function(output)
			if picker.closed then
				return
			end
			local ok, result = pcall(vim.json.decode, output)
			if not ok or type(result) ~= "table" or type(result.envs) ~= "table" then
				return
			end
			for _, env in ipairs(result.envs) do
				if type(env) == "string" then
					local path = vim.fs.normalize(env)
					add("Conda " .. vim.fs.basename(path), path .. "/bin/python")
				end
			end
			picker.set_items(items())
		end)
	end
end, "Select Python environment for this project")
-- =========================================
-- ==== LSP: COMPLETION / BUFFER KEYS ====
-- =========================================
-- 서버 연결 시 자동완성과 파일 버퍼 전용 키를 설정합니다.
-- gd/gr/gD/K: 직접 이동·조회; gR/gi/gt: picker; Space la/lr/Tr: 액션·이름 변경·심볼.
local function attach(client, buf)
	if vim.b[buf].offline_large_file then
		vim.lsp.buf_detach_client(buf, client.id)
		return
	end
	-- gd handles provider selection; native tag operations must read the ctags file.
	vim.bo[buf].tagfunc = ""
	if client:supports_method("textDocument/completion") then
		-- Use server-defined triggers; Ctrl-Space requests completion explicitly.
		vim.lsp.completion.enable(true, client.id, buf, { autotrigger = true })
		vim.bo[buf].autocomplete = false
	end
	local actions = {
		gr = "references",
		gD = "declaration",
		K = "hover",
		["<leader>lr"] = "rename",
	}
	-- Direct jumps stay direct; the original Telescope mappings remain selectable lists.
	for key, method in pairs({ gR = "references", gi = "implementation", gt = "type_definition" }) do
		vim.keymap.set("n", key, function()
			local opts = {
				on_list = function(list)
					location_picker(method, list.items)
				end,
			}
			if method == "references" then
				vim.lsp.buf.references(nil, opts)
			else
				vim.lsp.buf[method](opts)
			end
		end, { buf = buf, desc = "Select LSP " .. method })
	end
	for key, action in pairs(actions) do
		vim.keymap.set("n", key, vim.lsp.buf[action], { buf = buf, desc = "LSP: " .. action })
	end
	vim.keymap.set({ "n", "x" }, "<leader>la", vim.lsp.buf.code_action, { buf = buf, desc = "Code action" })
end
-- =========================================
-- ======== LSP: RESOLVE / ENABLE ========
-- =========================================
-- 실행 파일 탐색 후 vim.lsp.config/enable로 해당 언어 파일에 연결합니다.
-- 큰 파일은 연결하지 않습니다. Space ls는 현재 버퍼의 클라이언트만 재시작합니다.
local function lsp_executable(name)
	local executable = resolve_tool(name)
	if executable == "" then
		local installed = vim.fn.stdpath("data") .. "/mason/bin/" .. name
		if vim.fn.executable(installed) == 1 then
			executable = installed
		end
	end
	return executable
end
-- Auxiliary servers need project evidence; primary language servers also support standalone files.
local function project_uses_server(server, dir)
	if not server.markers or vim.fs.root(dir, server.markers) then
		return true
	end
	if not server.dependency then
		return false
	end
	for _, path in ipairs(vim.fs.find("package.json", { path = dir, upward = true, type = "file", limit = math.huge })) do
		local file = io.open(path, "r")
		if file then
			local content = file:read(65536)
			file:close()
			local ok, package = pcall(vim.json.decode, content or "")
			if ok and type(package) == "table" then
				for _, field in ipairs({ "dependencies", "devDependencies", "peerDependencies" }) do
					if type(package[field]) == "table" and package[field][server.dependency] then
						return true
					end
				end
				if server.dependency == "eslint" and package.eslintConfig then
					return true
				end
			end
		end
	end
	return false
end
for _, server in ipairs(servers) do
	local spec, executable
	for _, candidate in ipairs(server.alternatives or { server.cmd }) do
		local path = lsp_executable(candidate[1])
		if path ~= "" then
			spec, executable = candidate, path
			break
		end
	end
	if spec then
		local name = spec[1]
		local command = vim.deepcopy(spec)
		command[1] = executable
		vim.lsp.config(name, {
			cmd = command,
			filetypes = server.ft,
			settings = server.settings,
			on_init = function(client)
				if client.name == "ty" or client.name == "pyright-langserver" then
					-- Apply once before workspace/configuration and didOpen, including pending starts.
					apply_python_path(client, python_paths[client.config.root_dir])
				end
			end,
			on_attach = attach,
			root_dir = function(buf, on_dir)
				if vim.b[buf].offline_large_file then
					return
				end
				local file = vim.api.nvim_buf_get_name(buf)
				if file == "" or not project_uses_server(server, vim.fs.dirname(file)) then
					return
				end
				on_dir((find_project(vim.fs.dirname(file))))
			end,
		})
		vim.lsp.enable(name)
	end
end
map("n", "<leader>ls", "<Cmd>lsp restart<CR>", "Restart current buffer LSP clients")
-- =========================================
-- ========== CODE OUTLINE / LSP + CTAGS ==========
-- =========================================
-- Space Tr: 현재 파일의 함수·클래스 계층을 오른쪽 사이드바로 토글합니다.
-- Enter: 해당 위치 이동, r: 새로고침, q/Space Tr: 닫기, Ctrl-h/j/k/l: 창 이동.
-- 열린 동안 파일 전환·저장·LSP 연결 시만 갱신합니다. 매 키 입력마다 요청하지 않습니다.
local function outline_text(state, lines)
	if not vim.api.nvim_buf_is_valid(state.buf) then
		return
	end
	vim.bo[state.buf].modifiable = true
	vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, lines)
	vim.bo[state.buf].modifiable = false
end
cancel_outline = function(state)
	state.version = state.version + 1
	if state.cancel then
		state.cancel()
		state.cancel = nil
	end
end
local function ctags_outline(state)
	local version, buf = state.version, state.source
	state.items = {}
	local root, file = tag_context(buf)
	if not root then
		outline_text(state, { "Ctags unavailable or file exceeds size limits" })
		return
	end
	if file:find("[\r\n]") then
		return
	end
	local stat = vim.uv.fs_stat(file)
	local stamp = stat and (stat.size .. ":" .. stat.mtime.sec .. ":" .. stat.mtime.nsec)
	if stamp and state.ctags_file == file and state.ctags_stamp == stamp then
		state.items = state.ctags_items
		outline_text(state, state.ctags_lines)
		return
	end
	outline_text(state, { "Indexing saved file..." })
	build_tags(root, false, { file }, function(output)
		if outline ~= state or state.version ~= version or not vim.api.nvim_buf_is_valid(buf) then
			return
		end
		local items = {}
		for _, line in ipairs(records(output, "\n")) do
			if not line:match("^!_TAG_") and tag_filename(line) == file then
				local name = line:match("^([^\t]+)")
				local row = tonumber(line:match("\tline:(%d+)"))
				local kind = line:match(';"\t([^\t]+)') or ""
				local scope = ""
				for _, field in ipairs({ "class", "struct", "namespace", "union", "enum", "function", "scope" }) do
					scope = line:match("\t" .. field .. ":([^\t]+)") or scope
				end
				if row then
					local depth = scope == "" and 0 or #vim.split(scope:gsub("::", "."), ".", { plain = true })
					items[#items + 1] = {
						lnum = row,
						label = string.rep("  ", depth)
							.. name
							.. " ["
							.. kind
							.. "]"
							.. (scope == "" and "" or " (" .. scope .. ")"),
					}
				end
			end
		end
		table.sort(items, function(a, b)
			return a.lnum < b.lnum
		end)
		state.items = items
		local lines = #items > 0 and vim.tbl_map(function(item)
			return item.label
		end, items) or { "No symbols in saved file" }
		state.ctags_file, state.ctags_stamp = file, stamp
		state.ctags_items, state.ctags_lines = items, lines
		outline_text(state, lines)
	end, function()
		if outline == state and state.version == version then
			outline_text(state, { "Ctags indexing failed", "Press r to retry" })
		end
	end)
end
local function refresh_outline(state)
	cancel_outline(state)
	local version, buf = state.version, state.source
	state.items = {}
	if not vim.api.nvim_buf_is_loaded(buf) then
		outline_text(state, { "Source buffer closed" })
		return
	end
	local clients = vim.lsp.get_clients({ bufnr = buf, method = "textDocument/documentSymbol" })
	if #clients == 0 then
		ctags_outline(state)
		return
	end
	-- Use one provider to avoid duplicate symbols when several LSP clients attach.
	table.sort(clients, function(a, b)
		return a.id < b.id
	end)
	local client = clients[1]
	local tick = vim.api.nvim_buf_get_changedtick(buf)
	outline_text(state, { "Loading symbols..." })
	local ok, request = client:request("textDocument/documentSymbol", {
		textDocument = { uri = vim.uri_from_bufnr(buf) },
	}, function(err, symbols)
		vim.schedule(function()
			if outline ~= state or state.version ~= version then
				return
			end
			state.cancel = nil
			if not vim.api.nvim_buf_is_loaded(buf) then
				return
			end
			if vim.api.nvim_buf_get_changedtick(buf) ~= tick then
				outline_text(state, { "File changed; save or press r" })
				return
			end
			if err or symbols == nil or symbols == vim.NIL or #symbols == 0 then
				ctags_outline(state)
				return
			end
			local lines, items = {}, {}
			local function collect(nodes, depth)
				for _, symbol in ipairs(nodes) do
					local location = symbol.location
						or { uri = vim.uri_from_bufnr(buf), range = symbol.selectionRange or symbol.range }
					local kind = vim.lsp.protocol.SymbolKind[symbol.kind] or "Symbol"
					lines[#lines + 1] = string.rep("  ", depth) .. kind .. " " .. symbol.name:gsub("[%c]", " ")
					items[#items + 1] = { location = location, range = symbol.range or location.range }
					if symbol.children then
						collect(symbol.children, depth + 1)
					end
				end
			end
			collect(symbols ~= vim.NIL and symbols or {}, 0)
			state.items, state.encoding = items, client.offset_encoding
			outline_text(state, #lines > 0 and lines or { "No symbols in this file" })
			if vim.api.nvim_win_is_valid(state.win) and vim.api.nvim_win_is_valid(state.source_win) then
				local row, selected = vim.api.nvim_win_get_cursor(state.source_win)[1] - 1, 1
				for i, item in ipairs(items) do
					if item.range.start.line <= row and item.range["end"].line >= row then
						selected = i
					end
				end
				vim.api.nvim_win_set_cursor(state.win, { selected, 0 })
			end
		end)
	end, buf)
	if not ok then
		ctags_outline(state)
		return
	end
	state.cancel = function()
		client:cancel_request(request)
	end
	vim.defer_fn(function()
		if outline == state and state.version == version and state.cancel then
			cancel_outline(state)
			ctags_outline(state)
		end
	end, 5000)
end
map("n", "<leader>Tr", function()
	if outline then
		vim.api.nvim_win_close(outline.win, true)
		return
	end
	focus_editor()
	if vim.bo.buftype ~= "" or vim.api.nvim_buf_get_name(0) == "" then
		vim.notify("Open a code file to view its outline")
		return
	end
	local state = {
		source = vim.api.nvim_get_current_buf(),
		source_win = vim.api.nvim_get_current_win(),
		version = 0,
		items = {},
	}
	state.buf = vim.api.nvim_create_buf(false, true)
	vim.bo[state.buf].bufhidden = "wipe"
	vim.bo[state.buf].filetype = "offline_outline"
	state.win = vim.api.nvim_open_win(state.buf, true, {
		split = "right",
		win = state.source_win,
		width = sidebar_width(),
	})
	outline = state
	vim.wo[state.win].winfixwidth = true
	vim.wo[state.win].number = false
	vim.wo[state.win].relativenumber = false
	vim.wo[state.win].signcolumn = "no"
	vim.wo[state.win].wrap = false
	vim.wo[state.win].cursorline = true
	vim.wo[state.win].cursorlineopt = "line"
	vim.wo[state.win].cursorcolumn = false
	vim.wo[state.win].winbar = " Outline: "
		.. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(state.source), ":t"):gsub("%%", "%%%%")
	vim.keymap.set("n", "q", function()
		vim.api.nvim_win_close(state.win, true)
	end, { buf = state.buf, desc = "Close outline" })
	vim.keymap.set("n", "r", function()
		refresh_outline(state)
	end, { buf = state.buf, desc = "Refresh outline" })
	vim.keymap.set("n", "<CR>", function()
		local item = state.items[vim.api.nvim_win_get_cursor(state.win)[1]]
		if not item then
			return
		end
		if vim.api.nvim_win_is_valid(state.source_win) then
			vim.api.nvim_set_current_win(state.source_win)
		else
			focus_editor()
		end
		if item.location then
			vim.lsp.util.show_document(item.location, state.encoding, { focus = true })
		elseif vim.api.nvim_buf_is_valid(state.source) then
			vim.cmd("normal! m'")
			vim.api.nvim_win_set_buf(0, state.source)
			vim.api.nvim_win_set_cursor(0, { math.min(item.lnum, vim.api.nvim_buf_line_count(state.source)), 0 })
		end
		vim.cmd("normal! zvzz")
	end, { buf = state.buf, desc = "Jump to symbol" })
	vim.api.nvim_create_autocmd("WinClosed", {
		pattern = tostring(state.win),
		once = true,
		callback = function()
			cancel_outline(state)
			if outline == state then
				outline = nil
			end
		end,
	})
	refresh_outline(state)
end, "Toggle code outline")
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "LspAttach", "LspDetach" }, {
	callback = function(args)
		local state = outline
		if
			not state
			or vim.bo[args.buf].buftype ~= ""
			or vim.bo[args.buf].filetype == "netrw"
			or vim.api.nvim_win_get_tabpage(state.win) ~= vim.api.nvim_get_current_tabpage()
		then
			return
		end
		if args.event == "BufEnter" then
			state.source, state.source_win = args.buf, vim.api.nvim_get_current_win()
			vim.wo[state.win].winbar = " Outline: "
				.. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(args.buf), ":t"):gsub("%%", "%%%%")
		end
		if args.buf == state.source then
			vim.schedule(function()
				if outline == state then
					refresh_outline(state)
				end
			end)
		end
	end,
})

-- =========================================
-- ============= DIAGNOSTICS =============
-- =========================================
-- Space ld/lD/sd: 현재 줄/버퍼 목록/전체 목록. [d/]d: 이동, Space lt: 표시 토글.
map("n", "<leader>ld", vim.diagnostic.open_float, "Line diagnostics")
map("n", "<leader>lD", function()
	location_picker("Buffer diagnostics", vim.diagnostic.toqflist(vim.diagnostic.get(0)))
end, "Select buffer diagnostic")
map("n", "<leader>sd", function()
	location_picker("Diagnostics", vim.diagnostic.toqflist(vim.diagnostic.get()))
end, "Select diagnostic")
map("n", "[d", function()
	vim.diagnostic.jump({ count = -1 })
end, "Previous diagnostic")
map("n", "]d", function()
	vim.diagnostic.jump({ count = 1 })
end, "Next diagnostic")
local diagnostics_enabled = true
map("n", "<leader>lt", function()
	diagnostics_enabled = not diagnostics_enabled
	vim.diagnostic.enable(diagnostics_enabled)
end, "Toggle diagnostics")

-- =========================================
-- ========== LARGE FILE GUARDS ==========
-- =========================================
-- 2 MiB / 50,000줄 / 한 줄 10,000바이트 초과 시 무거운 기능을 중지합니다.
-- 최초 읽기와 편집한 줄만 검사합니다. 보호는 파일을 다시 읽을 때까지 유지합니다.
local watched_buffers = {}
local function protect_large_file(buf)
	if not vim.api.nvim_buf_is_loaded(buf) then
		return
	end
	local file = vim.api.nvim_buf_get_name(buf)
	file = vim.uv.fs_realpath(file) or file
	local root = file ~= "" and find_project(vim.fs.dirname(file))
	local project = root and tag_projects[root]
	if project and project.pending[file] then
		project.pending[file] = nil
		project.generation = project.generation + 1
		cancel_command("ctags:" .. root)
		if next(project.pending) then
			build_tags(root, false)
		end
	end
	pcall(vim.treesitter.stop, buf)
	vim.bo[buf].syntax = "OFF"
	vim.bo[buf].autocomplete = false
	for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
		vim.lsp.buf_detach_client(buf, client.id)
	end
	for _, win in ipairs(vim.fn.win_findbuf(buf)) do
		vim.wo[win].foldmethod = "manual"
		vim.wo[win].cursorcolumn = false
		vim.wo[win].cursorline = false
		vim.wo[win].wrap = false
	end
end
local function check_large_file(buf, first, last)
	if vim.b[buf].offline_large_file then
		return
	end
	local count = vim.api.nvim_buf_line_count(buf)
	local large = count > 50000 or vim.api.nvim_buf_get_offset(buf, count) > 2 * 1024 * 1024
	if not large then
		local offset = vim.api.nvim_buf_get_offset(buf, first)
		for line = first + 1, last do
			local next_offset = vim.api.nvim_buf_get_offset(buf, line)
			if next_offset - offset > 10001 then
				large = true
				break
			end
			offset = next_offset
		end
	end
	if large then
		vim.b[buf].offline_large_file = true
		-- Buffer-change callbacks hold textlock; detach clients and update windows afterwards.
		vim.schedule(function()
			protect_large_file(buf)
		end)
	end
end
vim.api.nvim_create_autocmd("BufReadPre", {
	callback = function(args)
		local stat = vim.uv.fs_stat(vim.api.nvim_buf_get_name(args.buf))
		vim.b[args.buf].offline_large_file = stat and stat.size > 2 * 1024 * 1024 or false
	end,
})
vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "FileType", "BufWinEnter" }, {
	callback = function(args)
		local buf = args.buf
		if vim.bo[buf].buftype ~= "" or vim.bo[buf].filetype == "netrw" then
			return
		end
		if not watched_buffers[buf] then
			watched_buffers[buf] = vim.api.nvim_buf_attach(buf, false, {
				on_lines = function(_, changed_buf, _, first, _, last)
					check_large_file(changed_buf, first, last)
				end,
				on_reload = function(_, reloaded_buf)
					check_large_file(reloaded_buf, 0, vim.api.nvim_buf_line_count(reloaded_buf))
				end,
				on_detach = function(_, detached_buf)
					watched_buffers[detached_buf] = nil
				end,
			})
			check_large_file(buf, 0, vim.api.nvim_buf_line_count(buf))
		end
		if vim.b[buf].offline_large_file then
			protect_large_file(buf)
		end
	end,
})

-- =========================================
-- ========= TREESITTER / SYNTAX =========
-- =========================================
-- 설치본에 포함된 언어 파서가 있으면 내장 Treesitter를 사용합니다.
-- 없으면 기본 syntax를 유지하며 외부 파서·쿼리 다운로드는 하지 않습니다.
vim.api.nvim_create_autocmd("FileType", {
	callback = function(args)
		if vim.bo[args.buf].buftype ~= "" or vim.b[args.buf].offline_large_file then
			return
		end
		local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
		if lang and pcall(vim.treesitter.language.add, lang) then
			pcall(vim.treesitter.start, args.buf, lang)
		end
	end,
})
