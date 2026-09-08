--.--.   ,--.,--.,--.   ,--.    ,------. ,-----. ,------.      ,---.  ,--. ,--.,--.  ,--.,--.   ,--. ,-----.  ,-----. ,--. ,--.
-- \  `.'  / |  ||   `.'   |    |  .---''  .-.  '|  .--. '    '   .-' |  | |  ||  ,'.|  ||  |   |  |'  .-.  ''  .-.  '|  .'   /
--  \     /  |  ||  |'.'|  |    |  `--, |  | |  ||  '--'.'    `.  `-. |  | |  ||  |' '  ||  |.'.|  ||  | |  ||  | |  ||  .   '
--   \   /   |  ||  |   |  |    |  |`   '  '-'  '|  |\  \     .-'    |'  '-'  '|  | `   ||   ,'.   |'  '-'  ''  '-'  '|  |\   \
--    `-'    `--'`--'   `--'    `--'     `-----' `--' '--'    `-----'  `-----' `--'  `--''--'   '--' `-----'  `-----' `--' '--'
--

-- =========================================
-- ============ DISABLE DEFAULTS ===========
-- =========================================
vim.g.loaded_gzip = 1
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_tar = 1
vim.g.loaded_tarPlugin = 1

vim.g.loaded_getscriptPlugin = 1
vim.g.loaded_getscript = 1
vim.g.loaded_vimball = 1
vim.g.loaded_vimballPlugin = 1
vim.g.loaded_2html_plugin = 1

vim.g.loaded_matchit = 1
vim.g.loaded_matchparen = 1
vim.g.loaded_logiPat = 1
vim.g.loaded_rrhelper = 1

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrwSettings = 1

-- =========================================
-- ============== CORE OPTIONS =============
-- =========================================
HOME_PATH = vim.loop.os_homedir()

local default_options = {
	backup = false, -- creates a backup file
	clipboard = "unnamedplus", -- allows neovim to access the system clipboard
	lazyredraw = true,
	cmdheight = 1, -- more space in the neovim command line for displaying messages
	-- colorcolumn = "90", -- fixes indentline for now
	completeopt = { "menuone", "noselect" },
	conceallevel = 0, -- so that `` is visible in markdown files
	fileencoding = "utf-8", -- the encoding written to a file
	foldmethod = "manual", -- folding, set to "expr" for treesitter based folding
	foldexpr = "", -- set to "nvim_treesitter#foldexpr()" for treesitter based folding
	guifont = "monospace:h17", -- the font used in graphical neovim applications
	hidden = true, -- required to keep multiple buffers and open multiple buffers
	hlsearch = true, -- highlight all matches on previous search pattern
	ignorecase = true, -- ignore case in search patterns
	mouse = "a", -- allow the mouse to be used in neovim
	pumheight = 10, -- pop up menu height
	showmode = true, -- we don't need to see things like -- INSERT -- anymore
	showtabline = 2, -- always show tabs
	smartcase = true, -- smart case
	smartindent = true, -- make indenting smarter again
	splitbelow = true, -- force all horizontal splits to go below current window
	splitright = true, -- force all vertical splits to go to the right of current window
	swapfile = false, -- creates a swapfile
	termguicolors = true, -- set term gui colors (most terminals support this)
	title = true, -- set the title of window to the value of the titlestring
	-- -- opt.titlestring = "%<%F%=%l/%L - nvim" -- what the title of the window will be set to
	undodir = HOME_PATH .. "/.config/undo", -- set an undo directory
	undofile = true, -- enable persistent undo
	updatetime = 10, -- faster completion
	writebackup = false, -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
	expandtab = true, -- convert tabs to spaces
	shiftwidth = 4, -- the number of spaces inserted for each indentation
	tabstop = 4, -- insert 2 spaces for a tab
	cursorline = true, -- highlight the current line
	cursorcolumn = true, -- highlight the current vertical line
	number = true, -- set numbered lines
	relativenumber = false, -- set relative numbered lines
	numberwidth = 2, -- set number column width to 2 {default 4}
	signcolumn = "yes", -- always show the sign column, otherwise it would shift the text each time
	wrap = true, -- display lines as one long line
	spell = false,
	spelllang = "en",
	background = "dark",
	scrolloff = 5, -- is one of my fav
	sidescrolloff = 8,
	ttyfast = true,
	sessionoptions = "buffers,curdir,folds,help,tabpages,winsize,winpos,terminal",
} ---  VIM ONLY COMMANDS  ---cmd "filetype plugin on"cmd('let &titleold="' .. TERMINAL .. '"')cmd "set inccommand=split"cmd "set iskeyword+=-"

---  SETTINGS  ---
vim.opt.shortmess:append("c")

for k, v in pairs(default_options) do
	vim.opt[k] = v
end

-- =========================================
-- ================ LEADER =================
-- =========================================
vim.g.mapleader = " "

-- =========================================
-- ============== KEYMAPS: BASE ============
-- =========================================
-- I hate escape
vim.keymap.set("i", "jk", "<esc>", { noremap = true, silent = true })

-- nohl
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
vim.keymap.set("i", "(", "(<C-g>u", { noremap = true, silent = true })
vim.keymap.set("i", "<", "<<C-g>u", { noremap = true, silent = true })
vim.keymap.set("i", "{", "{<C-g>u", { noremap = true, silent = true })
vim.keymap.set("i", "[", "[<c-g>u", { noremap = true, silent = true })

-- Window navigation (insert-mode alt-arrows)
vim.keymap.set("i", "<A-Up>", "<C-\\><C-N><C-w>h", { noremap = true, silent = true })
vim.keymap.set("i", "<A-Down>", "<C-\\><C-N><C-w>j", { noremap = true, silent = true })
vim.keymap.set("i", "<A-Left>", "<C-\\><C-N><C-w>k", { noremap = true, silent = true })
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

-- Substitute helpers (visual and word under cursor)
vim.keymap.set("v", "<leader>Sa", [[<ESC>:%s/<c-r>=GetVisual()<CR>/]], {
	noremap = true,
	silent = true,
	desc = "Substitute (visual) in entire file",
})
vim.keymap.set("n", "<leader>Sa", [[:%s/\<<C-r><C-w>\>/]], {
	noremap = true,
	silent = true,
	desc = "Substitute word in entire file",
})

-- Substitute from current line to end
vim.keymap.set("v", "<leader>Sf", [[<ESC>:.,$s/<c-r>=GetVisual()<CR>/]], {
	noremap = true,
	silent = true,
	desc = "Substitute (visual) to end of file",
})
vim.keymap.set("n", "<leader>Sf", [[:.,$s/\<<C-r><C-w>\>/]], {
	noremap = true,
	silent = true,
	desc = "Substitute word to end of file",
})

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

-- =========================================
-- ============ LAZY.NVIM BOOTSTRAP ========
-- =========================================
-- Install `lazy.nvim` plugin manager if missing
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

-- =========================================
-- ============ PLUGINS: SETUP =============
-- =========================================
-- NOTE: Here is where you install your plugins.
require("lazy").setup({
	-- -------------------------------------
	-- Utility: guess-indent
	-- -------------------------------------
	"NMAC427/guess-indent.nvim",

	-- -------------------------------------
	-- Git signs + hunk operations
	-- -------------------------------------
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "_" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},

			on_attach = function(bufnr)
				local gs = package.loaded.gitsigns
				local map = function(mode, lhs, rhs, desc)
					vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, noremap = true, desc = desc })
				end

				-- Hunk navigation (leader g n/p)
				map("n", "<leader>gn", function()
					gs.nav_hunk("next", { wrap = true })
				end, "Git: Next hunk")
				map("n", "<leader>gp", function()
					gs.nav_hunk("prev", { wrap = true })
				end, "Git: Prev hunk")
				-- Optional: bracket navigation
				-- map("n", "]h", function() gs.nav_hunk("next", { wrap = true }) end, "Git: Next hunk")
				-- map("n", "[h", function() gs.nav_hunk("prev", { wrap = true }) end, "Git: Prev hunk")

				-- Stage/Reset hunk (normal + visual)
				map("n", "<leader>gs", gs.stage_hunk, "Git: Stage hunk")
				map("v", "<leader>gs", function()
					gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, "Git: Stage selection")
				map("n", "<leader>gr", gs.reset_hunk, "Git: Reset hunk")
				map("v", "<leader>gr", function()
					gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
				end, "Git: Reset selection")

				-- Stage/Reset buffer
				map("n", "<leader>gS", gs.stage_buffer, "Git: Stage buffer")
				map("n", "<leader>gU", gs.undo_stage_hunk, "Git: Undo stage hunk")
				map("n", "<leader>gR", gs.reset_buffer, "Git: Reset buffer")

				-- Preview/Blame/Diff/Deleted
				map("n", "<leader>gv", gs.preview_hunk_inline, "Git: Preview hunk (inline)")
				map("n", "<leader>gb", gs.toggle_current_line_blame, "Git: Toggle inline blame")
				map("n", "<leader>gB", function()
					gs.blame_line({ full = true })
				end, "Git: Blame (full)")
				map("n", "<leader>gd", gs.diffthis, "Git: Diff against index")
				map("n", "<leader>gD", function()
					gs.diffthis("~")
				end, "Git: Diff against last commit")
				map("n", "<leader>gt", gs.toggle_deleted, "Git: Toggle deleted")

				-- Text object (hunk)
				map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Git: inner hunk")
			end,
		},
	},

	-- -------------------------------------
	-- Session management: persistence.nvim
	-- -------------------------------------
	{
		"folke/persistence.nvim",
		event = "BufReadPre",
		opts = {
			dir = vim.fn.stdpath("state") .. "/sessions/",
			options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals" },
		},
		keys = {
			{
				"<leader>pr",
				function()
					require("persistence").load()
				end,
				desc = "Restore session",
			},
			{
				"<leader>pl",
				function()
					require("persistence").load({ last = true })
				end,
				desc = "Restore last session",
			},
			{
				"<leader>pd",
				function()
					require("persistence").stop()
				end,
				desc = "Stop saving session",
			},
			{
				"<leader>pS",
				function()
					require("persistence").select()
				end,
				desc = "Select session",
			},
		},
	},

	-- -------------------------------------
	-- UI: alpha-nvim (dashboard)
	-- -------------------------------------
	{
		"goolord/alpha-nvim",
		event = "VimEnter",
		config = function()
			local ok, alpha = pcall(require, "alpha")
			if not ok then
				return
			end
			local dashboard = require("alpha.themes.dashboard")

			-- Dashboard header (ASCII art)
			dashboard.section.header.val = {
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

			-- Dashboard buttons
			dashboard.section.buttons.val = {
				dashboard.button("f", "Find file", ":Telescope find_files<CR>"),
				dashboard.button("r", "Recent files", ":Telescope oldfiles<CR>"),
				-- dashboard.button("p", "Find project", ":Telescope projects<CR>"),
				-- dashboard.button("R", "Restore Session", ":lua require('persistence').load()<CR>"),
				-- dashboard.button("L", "Last Session", ":lua require('persistence').load({ last = true })<CR>"),
				dashboard.button("p", "Select session", ":lua require('persistence').select()<CR>"),
				dashboard.button("n", "New file", ":ene | startinsert<CR>"),
				dashboard.button("c", "Config", ":e ~/.config/nvim/init.lua<CR>"),
				dashboard.button("u", "Lazy update", ":Lazy update<CR>"),
				dashboard.button("q", "Quit", ":qa!<CR>"),
			}

			-- Footer + highlights
			dashboard.section.footer.val = "https://sunwook-hwang.github.io"
			dashboard.section.footer.opts.hl = "Type"
			dashboard.section.header.opts.hl = "Include"
			dashboard.section.buttons.opts.hl = "Keyword"
			dashboard.opts.opts.noautocmd = true

			alpha.setup(dashboard.opts)

			-- Auto start dashboard on empty start
			vim.api.nvim_create_AUTOCMD = vim.api.nvim_create_autocmd
			vim.api.nvim_create_AUTOCMD("VimEnter", {
				callback = function()
					if vim.fn.argc() == 0 and vim.api.nvim_buf_get_name(0) == "" then
						require("alpha").start(true)
					end
				end,
			})
		end,
		keys = {
			{ "<leader>A", "<Cmd>Alpha<CR>", desc = "Open Alpha Dashboard" },
		},
	},

	-- -------------------------------------
	-- Clipboard over SSH: oscyank
	-- -------------------------------------
	{
		"ojroques/vim-oscyank",
		event = "VeryLazy",
		dependencies = { "ojroques/nvim-osc52" },
		config = function()
			vim.opt.clipboard = "unnamedplus"
			vim.api.nvim_create_autocmd("TextYankPost", {
				group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
				callback = function()
					vim.highlight.on_yank({ higroup = "IncSearch", timeout = 500 })
					if vim.v.event.operator == "y" and vim.v.event.regname == "" then
						vim.cmd([[OSCYankRegister]])
					end
				end,
			})
		end,
	},

	-- -------------------------------------
	-- which-key
	-- -------------------------------------
	{
		"folke/which-key.nvim",
		event = "VimEnter",
		opts = {
			delay = 0,
			icons = {
				mappings = false,
				keys = {},
			},
			spec = {
				{ "<leader>s", group = "[S]earch" },
				{ "<leader>S", group = "[S]ubstitute" },
				{ "<leader>b", group = "[B]uffer" },
				{ "<leader>T", group = "[T]oggle" },
				{ "<leader>l", group = "[L]sp & Diagnostic" },
				{ "<leader>g", group = "[G]it" },
				{ "<leader>p", group = "[P]roject" },
				-- { "<leader>d", group = "[D]ebug" },
			},
		},
	},

	-- -------------------------------------
	-- Telescope
	-- -------------------------------------
	{
		"nvim-telescope/telescope.nvim",
		event = "VimEnter",
		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
			{ "nvim-telescope/telescope-ui-select.nvim" },
		},
		config = function()
			require("telescope").setup({
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown(),
					},
				},
			})

			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")

			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>sg", builtin.git_commits, { desc = "[S]earch [G]itcommits" })
			vim.keymap.set("n", "<leader>sc", builtin.commands, { desc = "[S]earch [C]ommands" })

			vim.keymap.set("n", "<leader>st", builtin.live_grep, { desc = "[S]earch [T]ext" })
			vim.keymap.set("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
			vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [R]esume" })
			vim.keymap.set("n", "<leader>sr", builtin.oldfiles, { desc = "[S]earch [R]ecent Files" })
			vim.keymap.set("n", "<leader>t", builtin.grep_string, { desc = "Search current [T]ext under Cursor" })

			vim.keymap.set("n", "<leader>sp", function()
				builtin.colorscheme({ enable_preview = true })
			end, { desc = "[S]earch [P]alette (colorscheme)" })

			vim.keymap.set("n", "<leader><cr>", builtin.git_files, { desc = "Search Files in Current Git" })
			vim.keymap.set("n", "<leader>f", builtin.find_files, { desc = "[F]ind Files" })
			vim.keymap.set("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
			vim.keymap.set("n", "<leader>sb", builtin.buffers, { desc = "[S]earch [B]uffers" })
			vim.keymap.set("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })

			vim.keymap.set("n", "<leader>s/", function()
				builtin.live_grep({
					grep_open_files = true,
					prompt_title = "Live Grep in Open Files",
				})
			end, { desc = "[S]earch [/] in Open Files" })

			vim.keymap.set("n", "<leader>sn", function()
				builtin.find_files({ cwd = vim.fn.stdpath("config") })
			end, { desc = "[S]earch [N]eovim files" })
		end,
	},

	-- -------------------------------------
	-- toggleterm
	-- -------------------------------------
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		keys = {
			{ "<C-t>", "<Cmd>ToggleTerm<CR>", desc = "Toggle terminal" },
		},
		opts = {
			open_mapping = [[<c-t>]],
			direction = "float",
			float_opts = { border = "rounded" },
			shade_terminals = true,
			start_in_insert = true,
			persist_size = true,
		},
	},

	-- -------------------------------------
	-- undotree
	-- -------------------------------------
	{
		"jiaoshijie/undotree",
		keys = {
			{
				"<leader>Tu",
				function()
					require("undotree").toggle()
				end,
				desc = "Toggle Undotree",
			},
		},
		opts = {
			window = { winblend = 0 },
		},
	},

	-- -------------------------------------
	-- aerial symbols outline
	-- -------------------------------------
	{
		"stevearc/aerial.nvim",
		cmd = { "AerialToggle", "AerialOpen", "AerialClose", "AerialNavToggle" },
		keys = {
			{ "<leader>Tr", "<Cmd>AerialToggle<CR>", desc = "Aerial: Toggle" },
		},
		opts = {
			layout = { max_width = { 40, 0.25 } },
			show_guides = true,
			nerd_font = false,
		},
	},

	-- -------------------------------------
	-- lazygit integration
	-- -------------------------------------
	{
		"kdheepak/lazygit.nvim",
		cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile", "LazyGitFilter", "LazyGitFilterCurrentFile" },
		dependencies = { "nvim-lua/plenary.nvim" },
		keys = {
			{ "<leader>gg", "<Cmd>LazyGit<CR>", desc = "LazyGit" },
		},
		init = function()
			vim.g.lazygit_floating_window_winblend = 0
			vim.g.lazygit_floating_window_scaling_factor = 0.9
			vim.g.lazygit_floating_window_border_chars = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }
			vim.g.lazygit_floating_window_use_plenary = 0
			vim.g.lazygit_use_neovim_remote = 1
			vim.g.lazygit_use_custom_config_file_path = 0
			vim.g.lazygit_config_file_path = ""
		end,
	},

	-- -------------------------------------
	-- LSP helper: lazydev for Lua
	-- -------------------------------------
	--
	{
		"folke/lazydev.nvim",
		lazy = false,
		priority = 1000,
		opts = {
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
			},
		},
	},

	-- -------------------------------------
	-- Formatter: conform.nvim
	-- -------------------------------------
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>lf",
				function()
					require("conform").format({ async = true, timeout_ms = 5000 })
				end,
				mode = "n",
				desc = "Format buffer with Conform",
			},
		},
		opts = {
			notify_on_error = false,
			format_on_save = false,
			formatters_by_ft = {
				lua = { "stylua" },
				c = { "clang_format" },
				cpp = { "clang_format" },
				python = { "ruff", "black" },
				javascript = { "prettierd", "prettier", stop_after_first = true },
			},
		},
	},

	-- -------------------------------------
	-- Completion: blink.cmp + LuaSnip
	-- -------------------------------------
	{
		"saghen/blink.cmp",
		event = "VimEnter",
		version = "1.*",
		dependencies = {
			{
				"L3MON4D3/LuaSnip",
				version = "2.*",
				build = (function()
					if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
						return
					end
					return "make install_jsregexp"
				end)(),
				dependencies = {
					-- Add friendly-snippets here if desired
				},
				opts = {},
			},
			"folke/lazydev.nvim",
		},
		opts = {
			keymap = {
				preset = "enter",
			},
			appearance = {
				nerd_font_variant = "mono",
			},
			completion = {
				documentation = { auto_show = false, auto_show_delay_ms = 500 },
			},
			sources = {
				default = { "lsp", "path", "snippets", "lazydev" },
				providers = {
					lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
				},
			},
			snippets = { preset = "luasnip" },
			fuzzy = { implementation = "lua" },
			signature = { enabled = true },
		},
	},

	-- -------------------------------------
	-- Completion: autopairs
	-- -------------------------------------
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
		-- use opts = {} for passing setup options
		-- this is equivalent to setup({}) function
	},

	-- -------------------------------------
	-- vim-matchup
	-- -------------------------------------
	{
		"andymass/vim-matchup",
		opts = {
			treesitter = { stopline = 500 },
		},
	},

	-- -------------------------------------
	-- File explorer: nvim-tree
	-- -------------------------------------
	{
		"nvim-tree/nvim-tree.lua",
		-- dependencies = { "nvim-tree/nvim-web-devicons" },
		cmd = { "NvimTreeToggle", "NvimTreeFindFileToggle", "NvimTreeFocus" },
		keys = {
			{ "<leader>e", "<Cmd>NvimTreeFindFileToggle<CR>", desc = "NvimTree: Find file & toggle" },
		},
		opts = {
			sync_root_with_cwd = true,
			respect_buf_cwd = true,
			update_focused_file = {
				enable = true,
				update_cwd = true,
			},
			view = { adaptive_size = true },
			renderer = {
				icons = {
					glyphs = {
						default = "-",
						symlink = "~",
						folder = {
							arrow_open = "v",
							arrow_closed = ">",
							default = "+",
							open = "-",
							empty = "+",
							empty_open = "-",
							symlink = "~",
						},
						git = {
							unstaged = "!",
							staged = "+",
							unmerged = "≠",
							renamed = "→",
							untracked = "?",
							deleted = "x",
							ignored = "○",
						},
					},
				},
			},
		},
		config = function(_, opts)
			local ok, nvim_tree = pcall(require, "nvim-tree")
			if not ok then
				return
			end
			nvim_tree.setup(opts)

			-- Detect project root and sync nvim-tree root
			local function find_project_root()
				local patterns =
					{ ".git", "CMakeLists.txt", "compile_commands.json", "Makefile", "package.json", "pyproject.toml" }
				local cwd = vim.fn.expand("%:p:h")
				local home = vim.env.HOME or "~"
				while cwd and cwd ~= home do
					for _, pattern in ipairs(patterns) do
						if vim.fn.glob(cwd .. "/" .. pattern) ~= "" then
							return cwd
						end
					end
					local parent = vim.fn.fnamemodify(cwd, ":h")
					if parent == cwd then
						break
					end
					cwd = parent
				end
				return nil
			end

			local api = require("nvim-tree.api")
			vim.api.nvim_create_autocmd("BufEnter", {
				group = vim.api.nvim_create_augroup("nvim-tree-auto-root", { clear = true }),
				callback = function()
					local bt = vim.bo.filetype
					if bt == "NvimTree" then
						return
					end
					local project_root = find_project_root()
					if project_root and vim.fn.isdirectory(project_root) == 1 then
						vim.cmd("lcd " .. project_root)
						pcall(api.tree.change_root, project_root)
					end
				end,
			})
		end,
	},

	-- -------------------------------------
	-- TODO comments highlight
	-- -------------------------------------
	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},

	-- -------------------------------------
	-- Treesitter
	-- -------------------------------------
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "master",
		build = ":TSUpdate",
		main = "nvim-treesitter.configs",
		opts = {
			ensure_installed = {
				"bash",
				"c",
				"cpp",
				"diff",
				"html",
				"lua",
				"luadoc",
				"markdown",
				"markdown_inline",
				"query",
				"vim",
				"vimdoc",
			},
			auto_install = true,
			highlight = {
				enable = true,
				additional_vim_regex_highlighting = { "ruby" },
			},
			indent = { enable = true, disable = { "ruby" } },
		},
	},

	-- -------------------------------------
	-- LSP: lspconfig (+ small helpers)
	-- -------------------------------------
	{
		"neovim/nvim-lspconfig",
		lazy = false, -- load immediately so the first buffer gets LSP
		-- event = { "BufReadPre", "BufNewFile" }, -- <- remove this
		dependencies = {
			{ "antosha417/nvim-lsp-file-operations", config = true },
		},
		config = function()
			local keymap = vim.keymap
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("UserLspConfig", {}),
				callback = function(ev)
					vim.diagnostic.enable(true, { bufnr = ev.buf })
					local opts = { buffer = ev.buf, silent = true }

					opts.desc = "Go to definition"
					keymap.set("n", "gd", vim.lsp.buf.definition, opts)

					opts.desc = "References"
					keymap.set("n", "gr", vim.lsp.buf.references, opts)

					opts.desc = "Show LSP references"
					keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)

					opts.desc = "Go to declaration"
					keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

					opts.desc = "Show LSP implementations"
					keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)

					opts.desc = "Show LSP type definitions"
					keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

					opts.desc = "See available code actions"
					keymap.set({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, opts)

					opts.desc = "Go to previous diagnostic"
					keymap.set("n", "[d", function()
						vim.diagnostic.jump({ count = -1, float = false })
					end, opts)

					opts.desc = "Go to next diagnostic"
					keymap.set("n", "]d", function()
						vim.diagnostic.jump({ count = 1, float = false })
					end, opts)

					opts.desc = "Show documentation for what is under cursor"
					keymap.set("n", "K", vim.lsp.buf.hover, opts)

					opts.desc = "Restart LSP"
					keymap.set("n", "<leader>ls", ":LspRestart<CR>", opts)

					opts.desc = "Smart rename"
					keymap.set("n", "<leader>lr", vim.lsp.buf.rename, opts)

					opts.desc = "Show buffer diagnostics"
					keymap.set("n", "<leader>lD", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

					opts.desc = "Show line diagnostics"
					keymap.set("n", "<leader>ld", vim.diagnostic.open_float, opts)
				end,
			})

			-- LSP capabilities from completion engine
			local capabilities = require("blink.cmp").get_lsp_capabilities()

			-- Diagnostic config (default)
			vim.diagnostic.config({})

			-- Generic default for all servers configured below
			vim.lsp.config("*", {
				capabilities = capabilities,
			})

			-- Server-specific configs
			vim.lsp.config("svelte", {
				on_attach = function(client, _)
					vim.api.nvim_create_autocmd("BufWritePost", {
						pattern = { "*.js", "*.ts" },
						callback = function(ctx)
							client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.match })
						end,
					})
				end,
			})

			vim.lsp.config("graphql", {
				filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
			})

			vim.lsp.config("emmet_ls", {
				filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
			})

			vim.lsp.config("eslint", {
				filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
			})

			vim.lsp.config("lua_ls", {
				settings = {
					Lua = {
						diagnostics = { globals = { "vim" } },
						completion = { callSnippet = "Replace" },
					},
				},
			})

			-- Force the first buffer to (re)run FileType so LSP can attach if FileType already fired.
			if vim.bo.filetype ~= "" then
				vim.schedule(function()
					pcall(vim.api.nvim_exec_autocmds, "FileType", { buffer = 0 })
				end)
			end

			-- Diagnostics toggle (global)
			vim.diagnostic.enable(true, {})
			local function toggle_diagnostics_global()
				local enabled = vim.diagnostic.is_enabled({})
				vim.diagnostic.enable(not enabled, {})
				vim.notify(("Diagnostics: %s (global)"):format((not enabled) and "Enabled" or "Disabled"))
			end
			pcall(vim.api.nvim_create_user_command, "ToggleDiagnostics", toggle_diagnostics_global, {})
			vim.keymap.set(
				"n",
				"<leader>lt",
				"<Cmd>ToggleDiagnostics<CR>",
				{ silent = true, desc = "Toggle Diagnostics (global)" }
			)
		end,
	},
	-- -------------------------------------
	-- Mason (LSP/formatter installer)
	-- -------------------------------------
	{
		"williamboman/mason.nvim",
		dependencies = {
			"williamboman/mason-lspconfig.nvim",
			"WhoIsSethDaniel/mason-tool-installer.nvim",
		},
		config = function()
			local mason = require("mason")
			local mason_lspconfig = require("mason-lspconfig")
			local mason_tool_installer = require("mason-tool-installer")

			mason.setup({
				ui = {},
			})

			mason_lspconfig.setup({
				ensure_installed = {
					"ts_ls",
					"html",
					"cssls",
					"clangd",
					"tailwindcss",
					"svelte",
					"lua_ls",
					"graphql",
					"emmet_ls",
					"prismals",
					"pyright",
					"ty",
					"eslint",
				},
				automatic_enable = {
					exclude = { "pyright" },
				},
			})

			mason_tool_installer.setup({
				ensure_installed = {
					"prettier",
					"stylua",
					"clang-format",
					"isort",
					"black",
					"pylint",
					"eslint_d",
				},
			})
		end,
	},


	-- -------------------------------------
	-- Indent guides: indent-blankline
	-- -------------------------------------
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		event = { "BufReadPost", "BufNewFile" },
		keys = {
			{ "<leader>Ti", "<Cmd>IBLToggle<CR>", desc = "Toggle indent guides" },
		},
		opts = {
			indent = {
				char = "┊",
				tab_char = "┊",
			},
			scope = {
				enabled = true,
				show_start = false,
				show_end = false,
			},
		},
		config = function(_, opts)
			local ok, ibl = pcall(require, "ibl")
			if not ok then
				return
			end
			ibl.setup(opts)
		end,
	},

	-- -------------------------------------
	-- Buffer line: barbar.nvim
	-- -------------------------------------
	{
		"romgrk/barbar.nvim",
		init = function()
			vim.g.barbar_auto_setup = false
		end,
		config = function()
			local ok, barbar = pcall(require, "barbar")
			if not ok then
				return
			end

			barbar.setup({
				icons = {
					button = "",
					filetype = { enabled = false },
					modified = { button = "~" },
					pinned = { button = "P", filename = true },
				},
			})

			local map = function(mode, lhs, rhs, desc)
				vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, desc = desc })
			end

			map("n", "<S-l>", "<Cmd>BufferNext<CR>", "Barbar: Next buffer")
			map("n", "<S-h>", "<Cmd>BufferPrevious<CR>", "Barbar: Prev buffer")

			map("n", "<leader>bj", "<Cmd>BufferMovePrevious<CR>", "Barbar: Move buffer left")
			map("n", "<leader>bk", "<Cmd>BufferMoveNext<CR>", "Barbar: Move buffer right")

			map("n", "<A-1>", "<Cmd>BufferGoto 1<CR>", "Barbar: Goto 1")
			map("n", "<A-2>", "<Cmd>BufferGoto 2<CR>", "Barbar: Goto 2")
			map("n", "<A-3>", "<Cmd>BufferGoto 3<CR>", "Barbar: Goto 3")
			map("n", "<A-4>", "<Cmd>BufferGoto 4<CR>", "Barbar: Goto 4")
			map("n", "<A-5>", "<Cmd>BufferGoto 5<CR>", "Barbar: Goto 5")
			map("n", "<A-6>", "<Cmd>BufferGoto 6<CR>", "Barbar: Goto 6")
			map("n", "<A-7>", "<Cmd>BufferGoto 7<CR>", "Barbar: Goto 7")
			map("n", "<A-8>", "<Cmd>BufferGoto 8<CR>", "Barbar: Goto 8")
			map("n", "<A-9>", "<Cmd>BufferLast<CR>", "Barbar: Goto last")

			map("n", "<leader>c", "<Cmd>bw!<CR>", "Buffer wipeout (built-in)")
			map("n", "<leader>be", "<Cmd>BufferCloseAllButCurrent<CR>", "Barbar: Close others")
			map("n", "<leader>bw", "<Cmd>BufferWipeout<CR>", "Barbar: Wipeout current")
			map("n", "<leader>bh", "<Cmd>BufferCloseBuffersLeft<CR>", "Barbar: Close left")
			map("n", "<leader>bl", "<Cmd>BufferCloseBuffersRight<CR>", "Barbar: Close right")
			map(
				"n",
				"<leader>bm",
				"<Cmd>BufferCloseBuffersRight<CR>|<Cmd>BufferCloseBuffersLeft<CR>",
				"Barbar: Close both sides"
			)
			map("n", "<leader>bp", "<Cmd>BufferPick<CR>", "Barbar: Pick buffer")
			map("n", "<leader>bD", "<Cmd>BufferOrderByDirectory<CR>", "Barbar: Order by directory")
			map("n", "<leader>bL", "<Cmd>BufferOrderByLanguage<CR>", "Barbar: Order by language")
		end,
	},

	-- -------------------------------------
	-- Statusline: lualine
	-- -------------------------------------
	{
		"nvim-lualine/lualine.nvim",
		config = function()
			local lualine = require("lualine")

			lualine.setup({
				sections = {
					lualine_a = { "mode" },
					lualine_b = {
						{
							"branch",
							icon = "",
						},
						{
							"diff",
							symbols = {
								added = "+",
								modified = "~",
								removed = "-",
							},
						},
					},
					lualine_c = { "filename" },
					lualine_x = {},
					lualine_y = {},
					lualine_z = { "location" },
				},
				options = {
					theme = "auto",
					section_separators = "",
					component_separators = "",
					icons_enabled = false,
				},
			})
		end,
	},

	-- -------------------------------------
	-- Colorschemes (collections)
	-- -------------------------------------
	{
		"AbdelrahmanDwedar/awesome-nvim-colorschemes",
		lazy = false,
		priority = 1000,
	},
	{
		"alexkotusenko/nightgem.nvim",
		lazy = false,
		priority = 1000,
	},
})

-- =========================================
-- =========== POST-PLUGIN COMMANDS ========
-- =========================================
vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
	callback = function(args)
		local bufnr = args.buf

		local ok, stat = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
		local big = ok and stat and stat.size > (2 * 1024 * 1024)

		if not big then
			return
		end

		pcall(vim.treesitter.stop, bufnr)

		vim.bo[bufnr].syntax = "off"
		vim.bo[bufnr].filetype = vim.bo[bufnr].filetype
		vim.bo[bufnr].swapfile = false
		vim.wo[0].foldmethod = "manual"
		vim.b.matchup_matchparen_enabled = 0

		for _, client in pairs(vim.lsp.get_clients({ bufnr = bufnr })) do
			pcall(client.stop)
			pcall(vim.lsp.buf_detach_client, bufnr, client.id)
		end

		vim.notify(("Large file optimizations applied (%s)"):format(vim.api.nvim_buf_get_name(bufnr)))
	end,
})

local cmd = vim.cmd
-- trailing spaces cleanup (disabled)
-- cmd([[autocmd BufWritePre * %s/\s\+$//e]])
cmd([[filetype indent on]])
cmd([[set whichwrap+=<,>,[,],h,l]])
cmd([[set iskeyword+=-]])
-- cmd([[set langmap=ㅁa,ㅠb,ㅊc,ㅇd,ㄷe,ㄹf,ㅎg,ㅗh,ㅑi,ㅓj,ㅏk,ㅣl,ㅡm,ㅜn,ㅐo,ㅔp,ㅂq,ㄱr,ㄴs,ㅅt,ㅕu,ㅍv,ㅈw,ㅌx,ㅛy,ㅋz]])

-- =========================================
-- ============== COLORSCHEME ==============
-- =========================================
vim.cmd([[colorscheme gruvbox]])

-- =========================================
-- ============== OPTIONAL THEME ===========
-- =========================================
local display = {
	transparent_window = false,
}

if display.transparent_window then
	cmd("au ColorScheme * hi Normal ctermbg=none guibg=none")
	cmd("au ColorScheme * hi SignColumn ctermbg=none guibg=none")
	cmd("au ColorScheme * hi NormalNC ctermbg=none guibg=none")
	cmd("au ColorScheme * hi MsgArea ctermbg=none guibg=none")
	cmd("au ColorScheme * hi TelescopeBorder ctermbg=none guibg=none")
	cmd("au ColorScheme * hi NvimTreeNormal ctermbg=none guibg=none")
	cmd("let &fcs='eob: '")
end

-- =========================================
-- ============ NEOVIDE SETTINGS ===========
-- =========================================
if vim.g.neovide then
	vim.o.guifont = "JetBrainsMono Nerd Font:h18"

	-- Disable cursor animations/effects
	vim.g.neovide_cursor_animation_length = 0
	vim.g.neovide_cursor_trail_size = 0
	vim.g.neovide_cursor_vfx_mode = nil

	vim.g.neovide_scale_factor = 1.0

	local function change_scale(delta)
		local new = vim.g.neovide_scale_factor * (1 + delta)
		if new < 0.3 then
			new = 0.3
		end
		vim.g.neovide_scale_factor = new
	end

	-- Windows/Linux
	vim.keymap.set({ "n", "i", "v" }, "<C-=>", function()
		change_scale(0.10)
	end, { desc = "Zoom In (Neovide)" })
	vim.keymap.set({ "n", "i", "v" }, "<C-->", function()
		change_scale(-0.10)
	end, { desc = "Zoom Out (Neovide)" })
	vim.keymap.set({ "n", "i", "v" }, "<C-0>", function()
		vim.g.neovide_scale_factor = 1.0
	end, { desc = "Zoom Reset (Neovide)" })

	-- macOS
	vim.keymap.set({ "n", "i", "v" }, "<D-=>", function()
		change_scale(0.10)
	end, { desc = "Zoom In (Neovide macOS)" })
	vim.keymap.set({ "n", "i", "v" }, "<D-->", function()
		change_scale(-0.10)
	end, { desc = "Zoom Out (Neovide macOS)" })
	vim.keymap.set({ "n", "i", "v" }, "<D-0>", function()
		vim.g.neovide_scale_factor = 1.0
	end, { desc = "Zoom Reset (Neovide macOS)" })
end
