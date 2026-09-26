local shared = require("state")

-- Neovim 0.12+ 전용. 사용자 플러그인 경로를 제외하고 설치본의 기본 런타임만 사용합니다.
vim.opt.packpath = { vim.env.VIMRUNTIME }
-- Keep the installation's parser directory as well as its runtime scripts.
vim.opt.runtimepath = vim.tbl_filter(function(path)
	return path == shared.config_root or path == vim.env.VIMRUNTIME or path:match("/lib[^/]*/nvim$") ~= nil
end, vim.opt.runtimepath:get())

-- Choose compatibility paths once at startup, not on every editor event.
-- The legacy API references below are used only when the new API is absent.
shared.highlight_yank = vim.hl.hl_op or vim.hl.on_yank
shared.set_window_width = nil
if vim.api.nvim_win_resize then
	shared.set_window_width = function(win, width)
		vim.api.nvim_win_resize(win, width, -1, {})
	end
else
	-- Neovim 0.12 does not provide nvim_win_resize().
	shared.set_window_width = vim.api.nvim_win_set_width
end

-- =========================================
-- ============== CORE OPTIONS =============
-- =========================================
shared.nopack_data = vim.fn.stdpath("data") .. "/nopack"
-- Keep existing sessions and undo files when adopting the nopack name.
local legacy_data = vim.fn.stdpath("data") .. "/offline"
if vim.fn.isdirectory(legacy_data) == 1 and vim.fn.isdirectory(shared.nopack_data) == 0 then
	if vim.fn.rename(legacy_data, shared.nopack_data) ~= 0 then
		shared.nopack_data = legacy_data
	end
end
vim.fn.mkdir(shared.nopack_data .. "/undo", "p")
shared.is_ssh = vim.env.SSH_CONNECTION ~= nil or vim.env.SSH_TTY ~= nil

-- Use PATH first, then existing Mason installations; never install tools here.
function shared.resolve_tool(name)
	local path = vim.fn.exepath(name)
	if path ~= "" then
		return path
	end
	local installed = vim.fn.stdpath("data") .. "/mason/bin/" .. name
	return vim.fn.executable(installed) == 1 and installed or ""
end

local default_options = {
	backup = false, -- do not retain a backup after writing
	clipboard = shared.is_ssh and "" or "unnamedplus", -- SSH copies through the yank hook below; local desktops use their provider
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
	guifont = "RobotoMono Nerd Font Mono,monospace:h17", -- prefer solid-dot Braille glyphs for dashboard art
	hidden = true, -- required to keep multiple buffers and open multiple buffers
	hlsearch = true, -- highlight all matches on previous search pattern
	ignorecase = true, -- ignore case in search patterns
	mouse = "a", -- allow the mouse to be used in neovim
	pumheight = 10, -- pop up menu height
	showmode = true, -- show the active input mode
	showtabline = 2, -- always show tabs
	smartcase = true, -- smart case
	smartindent = false, -- let filetype indent rules handle '#' lines normally
	splitbelow = true, -- force all horizontal splits to go below current window
	splitright = true, -- force all vertical splits to go to the right current window
	swapfile = false, -- do not create swap files
	termguicolors = true, -- set term gui colors (most terminals support this)
	title = true, -- set the title of window to the value of the titlestring
	undodir = shared.nopack_data .. "/undo", -- enable persistent undo
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

-- Runtime UI changes use vim.wo[win][0] / vim.opt_local, never window defaults.
-- Numbering is window-local; ordinary navigation only touches the entered window.
local function show_line_numbers(win)
	if not vim.api.nvim_win_is_valid(win) then
		return
	end
	local buf = vim.api.nvim_win_get_buf(win)
	if vim.bo[buf].buftype == "" or vim.bo[buf].filetype == "netrw" then
		if not vim.wo[win].number then
			vim.wo[win][0].number = true
		end
		if vim.wo[win].relativenumber then
			vim.wo[win][0].relativenumber = false
		end
		if vim.wo[win].statuscolumn ~= "" then
			vim.wo[win][0].statuscolumn = ""
		end
	end
end
vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter", "FileType", "VimEnter", "SessionLoadPost" }, {
	group = vim.api.nvim_create_augroup("nopack-line-numbers", { clear = true }),
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
