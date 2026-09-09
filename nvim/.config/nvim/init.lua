--.--.   ,--.,--.,--.   ,--.    ,------. ,-----. ,------.      ,---.  ,--. ,--.,--.  ,--.,--.   ,--. ,-----.  ,-----. ,--. ,--.
-- \  `.'  / |  ||   `.'   |    |  .---''  .-.  '|  .--. '    '   .-' |  | |  ||  ,'.|  ||  |   |  |'  .-.  ''  .-.  '|  .'   /
--  \     /  |  ||  |'.'|  |    |  `--, |  | |  ||  '--'.'    `.  `-. |  | |  ||  |' '  ||  |.'.|  ||  | |  ||  | |  ||  .   '
--   \   /   |  ||  |   |  |    |  |`   '  '-'  '|  |\  \     .-'    |'  '-'  '|  | `   ||   ,'.   |'  '-'  ''  '-'  '|  |\   \
--    `-'    `--'`--'   `--'    `--'     `-----' `--' '--'    `-----'  `-----' `--'  `--''--'   '--' `-----'  `-----' `--' '--'
--

if vim.fn.has("nvim-0.12") == 0 then
	error("This configuration requires Neovim 0.12 or newer")
end

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
	lazyredraw = false,
	cmdheight = 1, -- more space in the neovim command line for displaying messages
	-- colorcolumn = "90", -- fixes indentline for now
	completeopt = { "menu", "menuone", "noselect", "popup", "fuzzy" },
	autocompletedelay = 150,
	complete = { ".", "w", "b", "t" },
	pumborder = "rounded",
	conceallevel = 0, -- so that `` is visible in markdown files
	fileencoding = "utf-8", -- the encoding written to a file
	foldmethod = "manual",
	foldexpr = "",
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
	updatetime = 250, -- CursorHold/write delay; completion uses autocompletedelay
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
vim.keymap.set("i", "<", "<<C-g>u", { noremap = true, silent = true })

-- Native pairs for file buffers; prompt input and large files stay literal.
local insert_pairs = { ["("] = ")", ["["] = "]", ["{"] = "}", ["'"] = "'", ['"'] = '"', ["`"] = "`" }
local function pair_escaped(text)
	return #(text:match("\\+$") or "") % 2 == 1
end
local function pair_mapping(key, callback, description)
	local plug = "<Plug>(native-pair-" .. key:byte() .. ")"
	-- Flush preceding typed characters before inspecting the cursor and buffer.
	vim.keymap.set("i", key, "<Ignore>" .. plug, { desc = description })
	vim.keymap.set("i", plug, callback, { expr = true })
end
for opening, closing in pairs(insert_pairs) do
	pair_mapping(opening, function()
		if vim.bo.buftype ~= "" or vim.b.large_file then
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
			if vim.bo.buftype == "" and not vim.b.large_file then
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
	if vim.bo.buftype == "" and not vim.b.large_file then
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

-- Large-file protection from init.offline.lua, registered before plugin callbacks.
do
	local watched_buffers = {}
	local function protect_large_file(buf)
		if not vim.api.nvim_buf_is_loaded(buf) then
			return
		end
		if package.loaded.gitsigns then
			require("gitsigns").detach(buf)
		end
		if package.loaded.ibl and require("ibl").initialized then
			require("ibl").setup_buffer(buf, { enabled = false })
		end
		pcall(vim.treesitter.stop, buf)
		vim.bo[buf].syntax = "OFF"
		vim.bo[buf].indentexpr = ""
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
		if vim.b[buf].large_file or not vim.api.nvim_buf_is_loaded(buf) then
			return
		end
		local count = vim.api.nvim_buf_line_count(buf)
		local large = count > 50000 or vim.api.nvim_buf_get_offset(buf, count) > 2 * 1024 * 1024
		if not large then
			first, last = math.max(0, math.min(first, count)), math.max(0, math.min(last, count))
			-- Fetch bounded batches, not a byte-offset lookup for every line.
			for start = first, last - 1, 512 do
				for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, start, math.min(start + 512, last), false)) do
					if #line > 10000 then
						large = true
						break
					end
				end
				if large then
					break
				end
			end
		end
		if large then
			vim.b[buf].large_file = true
			protect_large_file(buf)
		end
	end
	local function queue_large_file_check(buf, first, last, added)
		local state = watched_buffers[buf]
		if not state or vim.b[buf].large_file then
			return
		end
		state.first = math.min(state.first or first, first)
		-- Positive shifts conservatively extend the pending range; deletions are
		-- clamped at execution time. No changed line is lost during a paste burst.
		state.last = math.max(state.last and (state.last + math.max(0, added or 0)) or last, last)
		if state.pending then
			return
		end
		state.pending = true
		vim.schedule(function()
			if watched_buffers[buf] ~= state then
				return
			end
			state.pending = false
			local start, finish = state.first, state.last
			state.first, state.last = nil, nil
			if vim.api.nvim_buf_is_loaded(buf) then
				check_large_file(buf, start, finish)
			end
		end)
	end
	vim.api.nvim_create_autocmd("BufReadPre", {
		callback = function(args)
			local stat = vim.uv.fs_stat(vim.api.nvim_buf_get_name(args.buf))
			vim.b[args.buf].large_file = stat and stat.size > 2 * 1024 * 1024 or false
		end,
	})
	vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile", "FileType", "BufWinEnter" }, {
		callback = function(args)
			local buf = args.buf
			if vim.bo[buf].buftype ~= "" or vim.bo[buf].filetype == "NvimTree" then
				return
			end
			if not watched_buffers[buf] then
				watched_buffers[buf] = {}
				local attached = vim.api.nvim_buf_attach(buf, false, {
					on_lines = function(_, changed_buf, _, first, old_last, new_last)
						queue_large_file_check(changed_buf, first, new_last, new_last - old_last)
					end,
					on_reload = function(_, reloaded_buf)
						queue_large_file_check(reloaded_buf, 0, math.huge)
					end,
					on_detach = function(_, detached_buf)
						watched_buffers[detached_buf] = nil
					end,
				})
				if attached then
					-- Check once before FileType plugins attach; edits are batched below.
					check_large_file(buf, 0, math.huge)
				else
					watched_buffers[buf] = nil
				end
			end
			if vim.b[buf].large_file then
				protect_large_file(buf)
			end
		end,
	})
end

-- =========================================
-- ============ NATIVE PACKAGES ============
-- =========================================
-- Build native dependencies after installs/updates.
vim.api.nvim_create_autocmd("PackChanged", {
	group = vim.api.nvim_create_augroup("nvim-pack-build", { clear = true }),
	callback = function(ev)
		if ev.data.kind ~= "install" and ev.data.kind ~= "update" then
			return
		end
		local name = ev.data.spec.name
		local build
		if name == "telescope-fzf-native.nvim" then
			build = { "make" }
		end
		if build then
			local result = vim.system(build, { cwd = ev.data.path, text = true }):wait()
			if result.code ~= 0 then
				error(("Build failed for %s:\n%s\n%s"):format(name, result.stdout, result.stderr))
			end
		end
	end,
})

local packages = {
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/nvim-telescope/telescope-ui-select.nvim" },
	{ src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },
	{ src = "https://github.com/NMAC427/guess-indent.nvim" },
	{ src = "https://github.com/lewis6991/gitsigns.nvim" },
	{ src = "https://github.com/folke/persistence.nvim" },
	{ src = "https://github.com/goolord/alpha-nvim" },
	{ src = "https://github.com/folke/which-key.nvim" },
	{ src = "https://github.com/nvim-telescope/telescope.nvim" },
	{ src = "https://github.com/jiaoshijie/undotree" },
	{ src = "https://github.com/stevearc/aerial.nvim" },
	{ src = "https://github.com/stevearc/conform.nvim" },
	{ src = "https://github.com/nvim-tree/nvim-tree.lua" },
	{ src = "https://github.com/folke/todo-comments.nvim" },
	{ src = "https://github.com/williamboman/mason.nvim" },
	{ src = "https://github.com/lukas-reineke/indent-blankline.nvim" },
	{ src = "https://github.com/nvim-lualine/lualine.nvim" },
	{ src = "https://github.com/AbdelrahmanDwedar/awesome-nvim-colorschemes" },
}
if vim.fn.executable("make") == 1 then
	table.insert(packages, { src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim" })
end

-- Load at startup; configure dependencies before their consumers below.
-- Update plugins with :lua vim.pack.update()
vim.pack.add(packages, { confirm = false })

-- =========================================
-- ============ PLUGINS: SETUP =============
-- =========================================
-- -------------------------------------
-- Git signs + hunk operations
-- -------------------------------------
require("gitsigns").setup({
	signs = {
		add = { text = "+" },
		change = { text = "~" },
		delete = { text = "_" },
		topdelete = { text = "‾" },
		changedelete = { text = "~" },
	},

	on_attach = function(bufnr)
		if vim.b[bufnr].large_file then
			return false
		end
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
})

-- -------------------------------------
-- Session management: persistence.nvim
-- -------------------------------------
require("persistence").setup({
	dir = vim.fn.stdpath("state") .. "/sessions/",
	options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals" },
})

vim.keymap.set("n", "<leader>pr", function()
	require("persistence").load()
end, { desc = "Restore session" })

vim.keymap.set("n", "<leader>pl", function()
	require("persistence").load({ last = true })
end, { desc = "Restore last session" })

vim.keymap.set("n", "<leader>pd", function()
	require("persistence").stop()
end, { desc = "Stop saving session" })

vim.keymap.set("n", "<leader>pS", function()
	require("persistence").select()
end, { desc = "Select session" })

-- -------------------------------------
-- UI: alpha-nvim (dashboard)
-- -------------------------------------
do
	local alpha = require("alpha")
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
		dashboard.button("u", "Update plugins", ":lua vim.pack.update()<CR>"),
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

	vim.keymap.set("n", "<leader>A", "<Cmd>Alpha<CR>", { desc = "Open Alpha Dashboard" })
end

-- -------------------------------------
-- Clipboard over SSH: native OSC52 copy, with the system paste provider unchanged
-- -------------------------------------
do
	local copy_osc52 = require("vim.ui.clipboard.osc52").copy("+")
	vim.opt.clipboard = "unnamedplus"
	vim.api.nvim_create_autocmd("TextYankPost", {
		group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
		callback = function()
			vim.hl.on_yank({ higroup = "IncSearch", timeout = 500 })
			if vim.v.event.operator == "y" and vim.v.event.regname == "" then
				local lines = vim.deepcopy(vim.v.event.regcontents)
				if vim.v.event.regtype == "V" then
					lines[#lines + 1] = ""
				end
				copy_osc52(lines)
			end
		end,
	})
end

-- -------------------------------------
-- which-key
-- -------------------------------------
require("which-key").setup({
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
})

-- -------------------------------------
-- Telescope
-- -------------------------------------
do
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
end

-- -------------------------------------
-- Split terminal (from init.offline.lua)
-- -------------------------------------
-- Ctrl-t toggles the same shell in a bottom split; keep it out of the buffer list.
do
	local terminal
	local function terminal_running(buf)
		local job = vim.bo[buf].channel
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
	vim.keymap.set(
		{ "n", "t" },
		"<C-t>",
		toggle_terminal,
		{ noremap = true, silent = true, desc = "Toggle bottom terminal" }
	)
end

-- -------------------------------------
-- undotree
-- -------------------------------------
require("undotree").setup({
	window = { winblend = 0 },
})

vim.keymap.set("n", "<leader>Tu", function()
	require("undotree").toggle()
end, { desc = "Toggle Undotree" })

-- -------------------------------------
-- aerial symbols outline
-- -------------------------------------
require("aerial").setup({
	backends = { "lsp", "markdown", "asciidoc", "man" },
	layout = { max_width = { 40, 0.25 } },
	show_guides = true,
	nerd_font = false,
})

vim.keymap.set("n", "<leader>Tr", "<Cmd>AerialToggle<CR>", { desc = "Aerial: Toggle" })

-- Bound Git status output as in init.offline.lua.
local function bounded_system(command, opts, callback)
	local stdout, stderr, bytes, error_bytes = {}, {}, 0, 0
	local process, failure
	opts.stdout = function(err, data)
		if err then
			failure = tostring(err)
		elseif data and not failure then
			bytes = bytes + #data
			if bytes > 2 * 1024 * 1024 then
				failure = "Command output exceeds 2 MiB"
			else
				stdout[#stdout + 1] = data
			end
		end
		if failure and process then
			process:kill(9)
		end
	end
	opts.stderr = function(err, data)
		data = err and tostring(err) or data
		if data and error_bytes < 8192 then
			data = data:sub(1, 8192 - error_bytes)
			stderr[#stderr + 1] = data
			error_bytes = error_bytes + #data
		end
	end
	process = vim.system(command, opts, function(result)
		result.stdout = table.concat(stdout)
		result.stderr = failure or table.concat(stderr)
		if failure then
			result.code = 1
		end
		callback(result)
	end)
	return process
end

-- -------------------------------------
-- Git status: bottom read-only split (from init.offline.lua)
-- -------------------------------------
do
	local job, request
	vim.keymap.set("n", "<leader>gg", function()
		local name = vim.api.nvim_buf_get_name(0)
		local dir = vim.bo.filetype == "NvimTree" and vim.fn.getcwd()
			or (vim.bo.buftype == "" and name ~= "" and vim.fs.dirname(name))
		if not dir then
			for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
				local buf = vim.api.nvim_win_get_buf(win)
				local file = vim.api.nvim_buf_get_name(buf)
				if vim.bo[buf].buftype == "" and file ~= "" then
					dir = vim.fs.dirname(file)
					break
				end
			end
		end
		local root = vim.fs.root(dir or vim.fn.getcwd(), ".git")
		if not root then
			vim.notify("Current file is not in a Git project")
			return
		end
		if job then
			job:kill(15)
		end
		local current = {}
		request = current
		job = bounded_system(
			{ "git", "--no-pager", "status", "--short", "--branch", "--untracked-files=normal" },
			{ cwd = root, text = true, timeout = 5000 },
			vim.schedule_wrap(function(result)
				if request ~= current then
					return
				end
				job = nil
				if result.code ~= 0 then
					vim.notify("Git status failed: " .. result.stderr, vim.log.levels.WARN)
					return
				end
				vim.cmd("botright new")
				vim.bo.buftype = "nofile"
				vim.bo.buflisted = false
				vim.bo.bufhidden = "wipe"
				vim.bo.swapfile = false
				vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(result.stdout, "\n", { trimempty = true }))
				vim.bo.filetype = "git"
				vim.bo.modifiable = false
			end)
		)
	end, { noremap = true, silent = true, desc = "Git status" })
end

-- -------------------------------------
-- Formatting: conform.nvim (manual)
-- -------------------------------------
require("conform").setup({
	notify_on_error = false,
	default_format_opts = { lsp_format = "fallback" },
	formatters_by_ft = {
		lua = { "stylua" },
		c = { "clang_format" },
		cpp = { "clang_format" },
		python = { "ruff_format", "black", stop_after_first = true },
		javascript = { "prettierd", "prettier", stop_after_first = true },
	},
})
vim.keymap.set("n", "<leader>lf", function()
	local buf = vim.api.nvim_get_current_buf()
	if vim.bo[buf].buftype ~= "" or not vim.bo[buf].modifiable then
		vim.notify("Open an editable file before formatting")
		return
	end
	if vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf)) > 2 * 1024 * 1024 then
		vim.notify("Formatting skipped: file exceeds 2 MiB")
		return
	end
	require("conform").format({ bufnr = buf, async = true })
end, { desc = "Format buffer with Conform" })

-- =========================================
-- ======== COMPLETION / SNIPPETS ========
-- =========================================
-- Native completion and snippets; LSP automatic popup is enabled on attach.
-- Ctrl-Space: request, Ctrl-n/p: select, Enter: accept, Tab/Shift-Tab: snippet/completion.
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
		and vim.bo[buf].filetype ~= "NvimTree"
		and not vim.b[buf].large_file
		and #vim.lsp.get_clients({ bufnr = buf, method = "textDocument/completion" }) == 0
end
local pending_completion = {}
vim.api.nvim_create_autocmd({ "BufEnter", "FileType", "LspDetach" }, {
	callback = function(args)
		if pending_completion[args.buf] then
			return
		end
		pending_completion[args.buf] = true
		vim.schedule(function()
			pending_completion[args.buf] = nil
			if vim.api.nvim_buf_is_loaded(args.buf) then
				buffer_completion(args.buf)
			end
		end)
	end,
})

-- -------------------------------------
-- File explorer: nvim-tree
-- -------------------------------------
do
	local opts = {
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
	}

	local nvim_tree = require("nvim-tree")
	nvim_tree.setup(opts)

	-- Match offline project discovery; DirChanged already synchronizes nvim-tree.
	vim.api.nvim_create_autocmd("BufEnter", {
		group = vim.api.nvim_create_augroup("nvim-tree-auto-root", { clear = true }),
		callback = function(args)
			local file = vim.api.nvim_buf_get_name(args.buf)
			if vim.bo[args.buf].buftype ~= "" or file == "" or vim.bo[args.buf].filetype == "NvimTree" then
				return
			end
			local dir = vim.fs.dirname(file)
			local root = vim.fs.root(dir, ".git")
			if not root then
				local marker = vim.fs.find(
					{ "CMakeLists.txt", "compile_commands.json", "Makefile", "package.json", "pyproject.toml" },
					{ path = dir, upward = true, type = "file", limit = 1 }
				)[1]
				root = marker and vim.fs.dirname(marker)
			end
			if root and vim.fn.getcwd() ~= root then
				vim.cmd.lcd(vim.fn.fnameescape(root))
			end
		end,
	})

	vim.keymap.set("n", "<leader>e", "<Cmd>NvimTreeFindFileToggle<CR>", { desc = "NvimTree: Find file & toggle" })
end

-- -------------------------------------
-- TODO comments highlight
-- -------------------------------------
require("todo-comments").setup({ signs = false })

-- -------------------------------------
-- LSP: native client and buffer mappings
-- -------------------------------------
do
	local keymap = vim.keymap
	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("UserLspConfig", {}),
		callback = function(ev)
			local client = vim.lsp.get_client_by_id(ev.data.client_id)
			if vim.b[ev.buf].large_file then
				vim.lsp.buf_detach_client(ev.buf, client.id)
				return
			end
			if client:supports_method("textDocument/completion") then
				local completion = client.server_capabilities.completionProvider
				completion.triggerCharacters = completion.triggerCharacters or {}
				-- Also open completion while typing identifiers, not just after server punctuation.
				for char in ("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"):gmatch(".") do
					if not vim.tbl_contains(completion.triggerCharacters, char) then
						table.insert(completion.triggerCharacters, char)
					end
				end
				vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
				vim.bo[ev.buf].autocomplete = false
			end
			vim.diagnostic.enable(true, { bufnr = ev.buf })
			local opts = { buffer = ev.buf, silent = true }

			opts.desc = "Go to definition"
			keymap.set("n", "gd", vim.lsp.buf.definition, opts)

			opts.desc = "References"
			keymap.set("n", "gr", vim.lsp.buf.references, opts)

			opts.desc = "Show LSP references"
			keymap.set("n", "gR", vim.lsp.buf.references, opts)

			opts.desc = "Go to declaration"
			keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

			opts.desc = "Show LSP implementations"
			keymap.set("n", "gi", vim.lsp.buf.implementation, opts)

			opts.desc = "Show LSP type definitions"
			keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)

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
			keymap.set("n", "<leader>ls", "<Cmd>lsp restart<CR>", opts)

			opts.desc = "Smart rename"
			keymap.set("n", "<leader>lr", vim.lsp.buf.rename, opts)

			opts.desc = "Show buffer diagnostics"
			keymap.set("n", "<leader>lD", function()
				vim.diagnostic.setloclist({ open = true })
			end, opts)

			opts.desc = "Show line diagnostics"
			keymap.set("n", "<leader>ld", vim.diagnostic.open_float, opts)
		end,
	})

	-- Diagnostic config (default)
	vim.diagnostic.config({})

	-- Generic default for all servers configured below
	vim.lsp.config("*", {
		capabilities = vim.tbl_deep_extend("force", vim.lsp.protocol.make_client_capabilities(), {
			workspace = {
				fileOperations = {
					didCreate = true,
					willCreate = true,
					didRename = true,
					willRename = true,
					didDelete = true,
					willDelete = true,
				},
			},
		}),
	})

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
end
-- -------------------------------------
-- LSP server definitions and Mason installation
-- -------------------------------------
-- Native configs replace nvim-lspconfig. Mason only installs executables and sets PATH.
require("mason").setup({ ui = {} })
local servers = {
	clangd = {
		cmd = { "clangd" },
		filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
		root_markers = { "compile_commands.json", "compile_flags.txt", ".clangd", "CMakeLists.txt", ".git" },
	},
	ty = { cmd = { "ty", "server" }, filetypes = { "python" }, root_markers = { "pyproject.toml", "ty.toml", ".git" } },
	pyright = {
		cmd = { "pyright-langserver", "--stdio" },
		filetypes = { "python" },
		root_markers = { "pyrightconfig.json", "pyproject.toml", ".git" },
	},
	lua_ls = {
		cmd = { "lua-language-server" },
		filetypes = { "lua" },
		root_markers = { ".luarc.json", ".luarc.jsonc", ".git" },
		settings = {
			Lua = {
				runtime = { version = "LuaJIT" },
				diagnostics = { globals = { "vim" } },
				completion = { callSnippet = "Replace" },
				workspace = {
					checkThirdParty = false,
					library = vim.list_extend(vim.api.nvim_get_runtime_file("lua", true), { "${3rd}/luv/library" }),
				},
			},
		},
	},
	ts_ls = {
		cmd = { "typescript-language-server", "--stdio" },
		filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
		root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
		init_options = { hostInfo = "neovim" },
	},
	html = {
		cmd = { "vscode-html-language-server", "--stdio" },
		filetypes = { "html" },
		root_markers = { "package.json", ".git" },
		init_options = {
			provideFormatter = true,
			embeddedLanguages = { css = true, javascript = true },
			configurationSection = { "html", "css", "javascript" },
		},
	},
	cssls = {
		cmd = { "vscode-css-language-server", "--stdio" },
		filetypes = { "css", "scss", "less" },
		root_markers = { "package.json", ".git" },
		init_options = { provideFormatter = true },
		settings = { css = { validate = true }, scss = { validate = true }, less = { validate = true } },
	},
	tailwindcss = {
		cmd = { "tailwindcss-language-server", "--stdio" },
		filetypes = {
			"html",
			"css",
			"scss",
			"javascript",
			"javascriptreact",
			"typescript",
			"typescriptreact",
			"svelte",
		},
		root_markers = {
			"tailwind.config.js",
			"tailwind.config.cjs",
			"tailwind.config.mjs",
			"tailwind.config.ts",
			"postcss.config.js",
			"postcss.config.mjs",
			"postcss.config.cjs",
			"package.json",
		},
		workspace_required = true,
	},
	svelte = {
		cmd = { "svelteserver", "--stdio" },
		filetypes = { "svelte" },
		root_markers = { "svelte.config.js", "svelte.config.ts", "package.json", ".git" },
		on_attach = function(client, buf)
			vim.api.nvim_create_autocmd("BufWritePost", {
				group = vim.api.nvim_create_augroup("svelte-changes-" .. client.id, { clear = true }),
				pattern = { "*.js", "*.ts" },
				callback = function(ctx)
					if client:is_stopped() then
						return true
					end
					client:notify("$/onDidChangeTsOrJsFile", { uri = vim.uri_from_fname(ctx.match) })
				end,
			})
		end,
	},
	graphql = {
		cmd = { "graphql-lsp", "server", "-m", "stream" },
		filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
		root_markers = {
			".graphqlrc",
			".graphqlrc.json",
			".graphqlrc.yaml",
			".graphqlrc.yml",
			".graphqlrc.js",
			".graphqlrc.ts",
			"graphql.config.js",
			"graphql.config.ts",
			"graphql.config.yml",
			"graphql.config.yaml",
			"graphql.config.json",
		},
		workspace_required = true,
	},
	emmet_ls = {
		cmd = { "emmet-ls", "--stdio" },
		filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
		root_markers = { ".git" },
	},
	prismals = {
		cmd = { "prisma-language-server", "--stdio" },
		filetypes = { "prisma" },
		settings = { prisma = { prismaFmtBinPath = "" } },
		root_markers = { "schema.prisma", "package.json", ".git" },
	},
	eslint = {
		cmd = { "vscode-eslint-language-server", "--stdio" },
		filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
		root_markers = {
			"eslint.config.js",
			"eslint.config.mjs",
			"eslint.config.cjs",
			"eslint.config.ts",
			"eslint.config.mts",
			"eslint.config.cts",
			".eslintrc",
			".eslintrc.json",
			".eslintrc.js",
			".eslintrc.cjs",
			".eslintrc.yml",
			".eslintrc.yaml",
		},
		workspace_required = true,
		settings = {
			validate = "on",
			useESLintClass = false,
			experimental = {},
			format = true,
			quiet = false,
			codeActionOnSave = { enable = false, mode = "all" },
			onIgnoredFiles = "off",
			rulesCustomizations = {},
			run = "onType",
			problems = { shortenToSingleLine = false },
			nodePath = "",
			workingDirectory = { mode = "auto" },
			codeAction = {
				disableRuleComment = { enable = true, location = "separateLine" },
				showDocumentation = { enable = true },
			},
		},
		before_init = function(_, config)
			config.settings.workspaceFolder =
				{ uri = vim.uri_from_fname(config.root_dir), name = vim.fs.basename(config.root_dir) }
		end,
		handlers = {
			["eslint/openDoc"] = function(_, result)
				if result then
					vim.ui.open(result.url)
				end
				return {}
			end,
			["eslint/confirmESLintExecution"] = function()
				return 4
			end,
			["eslint/probeFailed"] = function()
				vim.notify("ESLint probe failed", vim.log.levels.WARN)
				return {}
			end,
			["eslint/noLibrary"] = function()
				vim.notify("ESLint library not found in project", vim.log.levels.WARN)
				return {}
			end,
		},
	},
}
for name, config in pairs(servers) do
	config.root_dir = function(buf, on_dir)
		if vim.b[buf].large_file or vim.fn.executable(config.cmd[1]) == 0 then
			return
		end
		local file = vim.api.nvim_buf_get_name(buf)
		if file == "" then
			return
		end
		local root = vim.fs.root(buf, config.root_markers)
		if (name == "ts_ls" or name == "eslint") and vim.fs.root(buf, { "deno.json", "deno.jsonc", "deno.lock" }) then
			return
		end
		if root or not config.workspace_required then
			on_dir(root or vim.fs.dirname(file))
		end
	end
	vim.lsp.config(name, config)
end
local function enable_servers()
	for name, config in pairs(servers) do
		-- Keep pyright installed but disabled, matching the previous configuration.
		if name ~= "pyright" and not vim.lsp.is_enabled(name) and vim.fn.executable(config.cmd[1]) == 1 then
			vim.lsp.enable(name)
		end
	end
end
require("mason-registry"):on("package:install:success", vim.schedule_wrap(enable_servers))
require("mason-tool-installer").setup({
	integrations = { ["mason-lspconfig"] = false, ["mason-null-ls"] = false, ["mason-nvim-dap"] = false },
	ensure_installed = {
		"typescript-language-server",
		"html-lsp",
		"css-lsp",
		"clangd",
		"tailwindcss-language-server",
		"svelte-language-server",
		"lua-language-server",
		"graphql-language-service-cli",
		"emmet-ls",
		"prisma-language-server",
		"pyright",
		"ty",
		"eslint-lsp",
		"prettier",
		"stylua",
		"clang-format",
		"isort",
		"black",
		"pylint",
		"eslint_d",
	},
})
enable_servers()

-- nvim-tree operations use native LSP requests/notifications to keep imports in sync.
do
	local api = require("nvim-tree.api")
	local events = {
		WillRenameNode = "willRename",
		NodeRenamed = "didRename",
		WillCreateFile = "willCreate",
		FileCreated = "didCreate",
		FolderCreated = "didCreate",
		WillRemoveFile = "willDelete",
		FileRemoved = "didDelete",
		FolderRemoved = "didDelete",
	}
	for event, operation in pairs(events) do
		api.events.subscribe(api.events.Event[event], function(data)
			local path = vim.fs.normalize(data.old_name or data.fname or data.folder_name)
			local folder = data.folder_name ~= nil or vim.fn.isdirectory(data.new_name or path) == 1
			local entry = data.old_name
					and { oldUri = vim.uri_from_fname(path), newUri = vim.uri_from_fname(data.new_name) }
				or { uri = vim.uri_from_fname(path) }
			local method = "workspace/" .. operation .. "Files"
			for _, client in ipairs(vim.lsp.get_clients({ method = method })) do
				local registration = vim.tbl_get(client.server_capabilities, "workspace", "fileOperations", operation)
				local in_workspace = false
				local roots = client.workspace_folders
					or (client.root_dir and { { uri = vim.uri_from_fname(client.root_dir) } } or {})
				for _, root in ipairs(roots) do
					local dir = vim.fs.normalize(vim.uri_to_fname(root.uri)):gsub("/$", "")
					if path == dir or vim.startswith(path, dir .. "/") then
						in_workspace = true
						break
					end
				end
				local matches = false
				for _, filter in ipairs(registration and registration.filters or {}) do
					local pattern = filter.pattern
					if
						(not filter.scheme or filter.scheme == "file")
						and (not pattern.matches or pattern.matches == (folder and "folder" or "file"))
					then
						local case = pattern.options and pattern.options.ignoreCase and "\\c" or "\\C"
						local regex = vim.regex(case .. vim.fn.glob2regpat(pattern.glob))
						if regex:match_str(path) or (folder and regex:match_str(path .. "/")) then
							matches = true
							break
						end
					end
				end
				if in_workspace and matches then
					local params = { files = { entry } }
					if operation:sub(1, 4) == "will" then
						local response, err = client:request_sync(method, params, 5000)
						if response and response.result and response.result ~= vim.NIL then
							vim.lsp.util.apply_workspace_edit(response.result, client.offset_encoding)
						elseif err or (response and response.err) then
							vim.notify(
								"LSP file operation failed: " .. vim.inspect(err or response.err),
								vim.log.levels.WARN
							)
						end
					else
						client:notify(method, params)
					end
				end
			end
		end)
	end
end
-- -------------------------------------
-- Indent guides: indent-blankline
-- -------------------------------------
do
	local opts = {
		indent = {
			char = "┊",
			tab_char = "┊",
		},
		scope = {
			enabled = false, -- Scope detection requires Treesitter.
			show_start = false,
			show_end = false,
		},
	}

	local ibl = require("ibl")
	ibl.setup(opts)

	vim.keymap.set("n", "<leader>Ti", "<Cmd>IBLToggle<CR>", { desc = "Toggle indent guides" })
end

-- -------------------------------------
-- Buffers: native tabline and navigation (from init.offline.lua)
-- -------------------------------------
do
	local map = function(mode, lhs, rhs, desc)
		vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, desc = desc })
	end
	local function focus_editor()
		if vim.bo.filetype ~= "NvimTree" and vim.bo.filetype ~= "aerial" then
			return
		end
		for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
			local buf = vim.api.nvim_win_get_buf(win)
			if vim.bo[buf].buftype == "" and vim.bo[buf].filetype ~= "NvimTree" then
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
	function _G.NativeTabline()
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
			items[#items + 1] = hl
				.. " "
				.. i
				.. ":"
				.. name:gsub("%%", "%%%%")
				.. (vim.bo[b].modified and " + " or " ")
		end
		tabline_cache = table.concat(items) .. "%#TabLineFill#"
		return tabline_cache
	end
	vim.opt.tabline = "%!v:lua.NativeTabline()"
	local function invalidate_tabline()
		tabline_cache = nil
	end
	local tabline_events = { "BufAdd", "BufDelete", "BufEnter", "BufFilePost", "TermOpen" }
	if vim.fn.has("nvim-0.13") == 0 then
		-- In 0.12, OptionSet alone does not cover modified changes caused by editing.
		tabline_events[#tabline_events + 1] = "BufModifiedSet"
	end
	vim.api.nvim_create_autocmd(tabline_events, {
		callback = invalidate_tabline,
	})
	vim.api.nvim_create_autocmd("OptionSet", {
		pattern = { "buflisted", "buftype", "modified" },
		callback = invalidate_tabline,
	})

	-- =========================================
	-- ======= BUFFER PICKER / KEYMAPS =======
	-- =========================================
	-- Use the existing selection UI for the same ordered buffer list.
	local function pick_buffer()
		vim.ui.select(buffers(), {
			prompt = "Buffers",
			format_item = function(buf)
				local name = vim.api.nvim_buf_get_name(buf)
				return buf .. ": " .. (name ~= "" and vim.fn.fnamemodify(name, ":~:.") or "[No Name]")
			end,
		}, function(buf)
			if buf and vim.api.nvim_buf_is_valid(buf) then
				select_buffer(buf)
			end
		end)
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
					and (
						side == "all"
						or (side == "left" and position < index)
						or (side == "right" and position > index)
					)
				then
					local is_terminal = vim.bo[b].buftype == "terminal"
					if is_terminal or not vim.bo[b].modified then
						vim.api.nvim_buf_delete(b, { force = is_terminal })
					end
				end
			end
		end, "Close " .. side .. " buffers (keep modified)")
	end
end

-- -------------------------------------
-- Statusline: lualine
-- -------------------------------------
do
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
			lualine_x = {
				{ "diagnostics", sources = { "nvim_diagnostic" }, always_visible = false },
			},
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
end
-- =========================================
-- =========== POST-PLUGIN COMMANDS ========
-- =========================================

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
