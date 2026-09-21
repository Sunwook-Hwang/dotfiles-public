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
	guifont = "RobotoMono Nerd Font Mono,monospace:h17", -- prefer solid-dot Braille glyphs for dashboard art
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

-- Keep growth/long-line protection in addition to Snacks bigfile detection.
local protect_large_file
do
	local watched_buffers = {}
	protect_large_file = function(buf)
		if not vim.api.nvim_buf_is_loaded(buf) then
			return
		end
		if package.loaded.gitsigns then
			require("gitsigns").detach(buf)
		end
		vim.b[buf].snacks_indent = false
		vim.b[buf].snacks_scroll = false
		vim.b[buf].snacks_words = false
		pcall(vim.treesitter.stop, buf)
		vim.bo[buf].syntax = "OFF"
		vim.bo[buf].indentexpr = ""
		vim.bo[buf].autocomplete = false
		for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
			vim.lsp.buf_detach_client(buf, client.id)
		end
		for _, win in ipairs(vim.fn.win_findbuf(buf)) do
			if vim.w[win].context then
				vim.w[win].context_large_file = true
				vim.api.nvim_win_call(win, function()
					vim.fn["context#disable"]("window")
				end)
			end
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
			if vim.bo[buf].buftype ~= "" then
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
-- Sticky scope headers without language parsers; keep native scrolling keys.
vim.g.context_add_mappings = 0
vim.g.context_max_height = 8
vim.g.context_max_per_indent = 1
vim.g.context_highlight_normal = "Pmenu"
vim.g.context_highlight_border = "Comment"
vim.g.context_border_char = "─"
vim.g.context_highlight_tag = "<hide>"
vim.g.context_filetype_blacklist =
	{ "snacks_dashboard", "snacks_picker_list", "snacks_picker_input", "snacks_picker_preview", "aerial" }
vim.g.context_buftype_blacklist = { "nofile", "prompt", "terminal", "quickfix", "help" }
vim.keymap.set("n", "<leader>Ts", "<Cmd>ContextToggle<CR>", { desc = "Toggle sticky scroll" })
-- A window disabled for a large file must recover when opening a normal buffer.
vim.api.nvim_create_autocmd("BufEnter", {
	callback = function()
		if vim.w.context_large_file and not vim.b.large_file and vim.w.context then
			local context = vim.w.context
			context.enabled = vim.g.context.enabled
			context.top_line = 0
			vim.w.context = context
			vim.w.context_large_file = nil
		end
	end,
})
local packages = {
	{ src = "https://github.com/wellle/context.vim" },
	{ src = "https://github.com/folke/snacks.nvim" },
	{ src = "https://github.com/folke/persistence.nvim" },
	{ src = "https://github.com/folke/which-key.nvim" },

	{ src = "https://github.com/lewis6991/gitsigns.nvim" },
	{ src = "https://github.com/stevearc/aerial.nvim" },
	{ src = "https://github.com/Bekaboo/dropbar.nvim" },

	{ src = "https://github.com/stevearc/conform.nvim" },
	{ src = "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim" },
	{ src = "https://github.com/mason-org/mason.nvim" },
}

-- Load at startup; configure dependencies before their consumers below.
-- Update plugins with :lua vim.pack.update()
vim.pack.add(packages, { confirm = false })

-- Correct context.vim's editor-relative position synchronously after its updates.
-- Keep this integration in init.lua; no autoload overrides or deferred redraws.
local function align_context_popups()
	for source, popup in pairs(vim.g.context.popups) do
		local win = tonumber(source)
		if vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_is_valid(popup) then
			local info = vim.fn.getwininfo(win)[1]
			local row, col = info.winrow - 1 + info.winbar, info.wincol - 1
			local config = vim.api.nvim_win_get_config(popup)
			if config.relative ~= "editor" or config.row ~= row or config.col ~= col then
				vim.api.nvim_win_set_config(popup, { relative = "editor", row = row, col = col })
			end
		end
	end
end
local function setup_context_position()
	local group = vim.api.nvim_create_augroup("online-context-position", { clear = true })
	-- Register after the plugin's handlers, including its OptionSet/User filters.
	for _, event in ipairs(vim.api.nvim_get_autocmds({ group = "context.vim" })) do
		vim.api.nvim_create_autocmd(event.event, {
			group = group,
			pattern = event.pattern,
			callback = align_context_popups,
		})
	end
	-- Commands can redraw without a cursor/scroll event (including Space Ts).
	for name, command in pairs(vim.api.nvim_get_commands({ builtin = false })) do
		if name:match("^Context") and command.definition:match("^call context#") then
			vim.api.nvim_create_user_command(name, function()
				vim.cmd(command.definition)
				align_context_popups()
			end, { bar = true })
		end
	end
end

-- vim.pack sources plugin scripts after init.lua during startup.
if vim.v.vim_did_enter == 1 then
	setup_context_position()
else
	vim.api.nvim_create_autocmd("VimEnter", { once = true, callback = setup_context_position })
end

-- Snacks owns the explorer, pickers, dashboard, terminal and utility UI.
local Snacks = require("snacks")
Snacks.setup({
	bigfile = {
		enabled = true,
		size = 2 * 1024 * 1024,
		line_length = 10000,
		setup = function(ctx)
			vim.b[ctx.buf].large_file = true
			protect_large_file(ctx.buf)
		end,
	},
	quickfile = { enabled = true },
	explorer = { enabled = true },
	input = { enabled = true, icon = "" },
	notifier = {
		enabled = true,
		icons = { error = "E", warn = "W", info = "I", debug = "D", trace = "T" },
		-- Also suppress icons explicitly supplied by other plugins.
		filter = function(notification)
			notification.icon = ""
			return true
		end,
	},
	indent = {
		enabled = true,
		indent = { char = "┊" },
		scope = { enabled = false },
		animate = { enabled = false },
	},
	scroll = {
		enabled = true,
		filter = function(buf)
			return vim.bo[buf].buftype == ""
				and not vim.b[buf].large_file
				and vim.g.snacks_scroll ~= false
				and vim.b[buf].snacks_scroll ~= false
		end,
	},
	terminal = {
		win = { position = "bottom", height = 0.3, keys = { term_normal = false } },
	},
	lazygit = {
		configure = false, -- Use lazygit's own config and colors instead of the Neovim theme.
		win = {
			position = "float",
			height = 0.9,
			width = 0.9,
			backdrop = false,
			wo = { winhighlight = "Normal:Normal,NormalNC:Normal" },
		},
	},
	toggle = { which_key = false, notify = false },
	picker = {
		enabled = true,
		prompt = "> ",
		previewers = { diff = { style = "syntax" } },
		icons = {
			files = { enabled = false, dir = "", dir_open = "", file = "" },
			keymaps = { nowait = "" },
			undo = { saved = "S" },
			ui = { live = "LIVE", selected = "[x] ", unselected = "[ ] " },
			git = {
				commit = "",
				staged = "+",
				added = "+",
				deleted = "-",
				ignored = "!",
				modified = "M",
				renamed = "R",
				unmerged = "U",
				untracked = "?",
			},
			diagnostics = { Error = "E", Warn = "W", Hint = "H", Info = "I" },
			lsp = { unavailable = "X", enabled = "on", disabled = "off", attached = "attached" },
		},
		config = function(opts)
			-- Includes every kind supplied by Snacks, without a Nerd Font dependency.
			for kind in pairs(opts.icons.kinds) do
				opts.icons.kinds[kind] = kind .. " "
			end
		end,
		sources = {
			undo = {
				config = function()
					-- Snacks writes undo previews here, including on a fresh installation.
					vim.fn.mkdir(vim.fn.stdpath("cache"), "p")
				end,
				format = function(item, picker)
					local result = Snacks.picker.format.undo(item, picker)
					-- The current-entry marker is hard-coded in the upstream formatter.
					result[1][1] = item.current and "> " or "  "
					return result
				end,
			},
		},
	},
	dashboard = {
		enabled = true,
		preset = {
			header = table.concat({
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
			}, "\n"),
			keys = {
				{
					key = "f",
					desc = "Find file",
					action = function()
						Snacks.picker.files()
					end,
				},
				{
					key = "r",
					desc = "Recent files",
					action = function()
						Snacks.picker.recent()
					end,
				},
				{
					key = "p",
					desc = "Select session",
					action = function()
						require("persistence").select()
					end,
				},
				{ key = "n", desc = "New file", action = ":ene | startinsert" },
				{
					key = "c",
					desc = "Config",
					action = function()
						vim.cmd.edit(vim.fn.stdpath("config") .. "/init.lua")
					end,
				},
				{
					key = "u",
					desc = "Update plugins",
					action = function()
						vim.pack.update()
					end,
				},
				{ key = "q", desc = "Quit", action = ":qa" },
			},
		},
		formats = {
			icon = function()
				return { "", width = 0 }
			end,
		},
		sections = {
			{ section = "header" },
			{ section = "keys", gap = 1, padding = 1 },
			{ text = "https://sunwook-hwang.github.io", align = "center" },
		},
	},
})
vim.keymap.set("n", "<leader>A", function()
	Snacks.dashboard()
end, { desc = "Open dashboard" })
Snacks.toggle.indent():map("<leader>Ti")
Snacks.toggle.scroll():map("<leader>TS")

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
		keys = {
			Up = "Up",
			Down = "Down",
			Left = "Left",
			Right = "Right",
			C = "Ctrl-",
			M = "Alt-",
			D = "Cmd-",
			S = "Shift-",
			CR = "Enter",
			Esc = "Esc",
			NL = "Enter",
			BS = "Backspace",
			Space = "Space",
			Tab = "Tab",
			ScrollWheelDown = "WheelDown",
			ScrollWheelUp = "WheelUp",
			F1 = "F1",
			F2 = "F2",
			F3 = "F3",
			F4 = "F4",
			F5 = "F5",
			F6 = "F6",
			F7 = "F7",
			F8 = "F8",
			F9 = "F9",
			F10 = "F10",
			F11 = "F11",
			F12 = "F12",
		},
		breadcrumb = ">",
		separator = "->",
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
-- Snacks pickers: retain the existing search and navigation keys.
-- -------------------------------------
do
	local pickers = {
		sg = { "git_log", "Search Git commits" },
		sc = { "commands", "Search commands" },
		st = { "grep", "Search text" },
		sd = { "diagnostics", "Search diagnostics" },
		sk = { "keymaps", "Search keymaps" },
		sr = { "recent", "Search recent files" },
		t = { "grep_word", "Search word under cursor" },
		sp = { "colorschemes", "Preview colorschemes" },
		["<CR>"] = { "git_files", "Search files in current Git" },
		f = { "files", "Find files" },
		sh = { "help", "Search help" },
		["s/"] = { "grep_buffers", "Search open files" },
		u = { "undo", "Search undo history" },
	}
	for key, picker in pairs(pickers) do
		vim.keymap.set("n", "<leader>" .. key, function()
			Snacks.picker[picker[1]]()
		end, { desc = picker[2] })
	end
	vim.keymap.set("n", "<leader>sn", function()
		Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
	end, { desc = "Search Neovim files" })
end

-- LSP breadcrumbs without Treesitter or font icons.
do
	local enabled = true
	local expression = "%{%v:lua.dropbar()%}"
	local function eligible(buf, win)
		return enabled
			and vim.bo[buf].buftype == ""
			and vim.api.nvim_buf_get_name(buf) ~= ""
			and not vim.b[buf].large_file
			and vim.api.nvim_win_get_config(win).relative == ""
			and (vim.wo[win].winbar == "" or vim.wo[win].winbar == expression)
	end
	require("dropbar").setup({
		sources = { path = { preview = false } },
		icons = {
			enable = false,
			ui = { bar = { separator = " > ", extends = "..." }, menu = { indicator = "> " } },
		},
		bar = {
			enable = eligible,
			sources = function()
				local sources = require("dropbar.sources")
				return { sources.path, sources.lsp }
			end,
		},
	})
	local function refresh()
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			local buf = vim.api.nvim_win_get_buf(win)
			if eligible(buf, win) then
				vim.wo[win][0].winbar = expression
			elseif vim.wo[win].winbar == expression then
				vim.wo[win][0].winbar = ""
			end
		end
		align_context_popups()
	end
	vim.api.nvim_create_autocmd("BufWinEnter", {
		group = vim.api.nvim_create_augroup("online-dropbar", { clear = true }),
		callback = refresh,
	})
	vim.keymap.set("n", "<leader>Td", function()
		enabled = not enabled
		refresh()
	end, { desc = "Toggle breadcrumb bar" })
end

-- Persistent outline with cursor tracking in both directions.
require("aerial").setup({
	backends = { "lsp", "markdown", "asciidoc", "man" },
	layout = { default_direction = "right", max_width = { 40, 0.25 } },
	attach_mode = "global",
	autojump = true,
	close_on_select = false,
	show_guides = true,
	nerd_font = false,
	icons = { Collapsed = ">" },
})
vim.keymap.set("n", "<leader>o", "<Cmd>AerialToggle<CR>", { desc = "Toggle symbols outline" })

-- Keep a single bottom terminal even when the editor's cwd changes.
do
	local terminal_cwd
	vim.keymap.set({ "n", "t" }, "<C-t>", function()
		terminal_cwd = terminal_cwd or vim.fn.getcwd()
		Snacks.terminal.toggle(nil, { cwd = terminal_cwd, count = 1 })
	end, { desc = "Toggle bottom terminal" })
end

-- Toggle lazygit independently of the bottom shell terminal.
vim.keymap.set("n", "<leader>gg", function()
	Snacks.lazygit()
end, { desc = "Toggle lazygit" })

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
		cuda = { "clang_format" },
		python = { "ruff_format", "black", stop_after_first = true },
		javascript = { "prettierd", "prettier", stop_after_first = true },
		javascriptreact = { "prettierd", "prettier", stop_after_first = true },
		typescript = { "prettierd", "prettier", stop_after_first = true },
		typescriptreact = { "prettierd", "prettier", stop_after_first = true },
		html = { "prettierd", "prettier", stop_after_first = true },
		css = { "prettierd", "prettier", stop_after_first = true },
		scss = { "prettierd", "prettier", stop_after_first = true },
		less = { "prettierd", "prettier", stop_after_first = true },
		json = { "prettierd", "prettier", stop_after_first = true },
		jsonc = { "prettierd", "prettier", stop_after_first = true },
		yaml = { "prettierd", "prettier", stop_after_first = true },
		markdown = { "prettierd", "prettier", stop_after_first = true },
		["markdown.mdx"] = { "prettierd", "prettier", stop_after_first = true },
		graphql = { "prettierd", "prettier", stop_after_first = true },
		vue = { "prettierd", "prettier", stop_after_first = true },
		handlebars = { "prettierd", "prettier", stop_after_first = true },
		bzl = { "buildifier" },
		proto = { "buf", "clang_format", stop_after_first = true },
		sh = { "shfmt" },
		cmake = { "cmake_format" },
		tex = { "latexindent" },
		plaintex = { "latexindent" },
		rust = { "rustfmt" },
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
-- File explorer: Snacks, with the existing Git-first project root policy.
-- -------------------------------------
do
	vim.api.nvim_create_autocmd("BufEnter", {
		group = vim.api.nvim_create_augroup("online-project-root", { clear = true }),
		callback = function(args)
			local file = vim.api.nvim_buf_get_name(args.buf)
			if vim.bo[args.buf].buftype ~= "" or file == "" then
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
	vim.keymap.set("n", "<leader>e", function()
		Snacks.explorer()
	end, { desc = "Toggle file explorer" })
end

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
			keymap.set("n", "gd", function()
				Snacks.picker.lsp_definitions()
			end, opts)

			opts.desc = "References"
			keymap.set("n", "gr", function()
				Snacks.picker.lsp_references()
			end, opts)

			opts.desc = "Show LSP references"
			keymap.set("n", "gR", function()
				Snacks.picker.lsp_references()
			end, opts)

			opts.desc = "Go to declaration"
			keymap.set("n", "gD", function()
				Snacks.picker.lsp_declarations()
			end, opts)

			opts.desc = "Show LSP implementations"
			keymap.set("n", "gi", function()
				Snacks.picker.lsp_implementations()
			end, opts)

			opts.desc = "Show LSP type definitions"
			keymap.set("n", "gt", function()
				Snacks.picker.lsp_type_definitions()
			end, opts)

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
				Snacks.picker.diagnostics_buffer()
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
	local diagnostics = Snacks.toggle.diagnostics()
	vim.api.nvim_create_user_command("ToggleDiagnostics", function()
		diagnostics:toggle()
	end, {})
	diagnostics:map("<leader>lt")
end
-- -------------------------------------
-- LSP server definitions and Mason installation
-- -------------------------------------
-- Python projects use the same Git-first root discovery as init.offline.lua.
local function python_project_root(buf)
	local file = vim.api.nvim_buf_get_name(buf)
	local dir = file ~= "" and vim.fs.dirname(file) or vim.fn.getcwd()
	local root = vim.fs.root(dir, ".git")
	if root then
		return root
	end
	local marker = vim.fs.find(
		{ "CMakeLists.txt", "compile_commands.json", "Makefile", "package.json", "pyproject.toml" },
		{ path = dir, upward = true, type = "file", limit = 1 }
	)[1]
	return marker and vim.fs.dirname(marker) or dir
end

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
vim.keymap.set("n", "<leader>lv", function()
	if vim.bo.filetype ~= "python" then
		vim.notify("Open a Python file to select its environment")
		return
	end
	local root = python_project_root(0)
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
			if (client.name == "ty" or client.name == "pyright") and client.config.root_dir == root then
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
								if vim.api.nvim_buf_is_loaded(buf) and not vim.b[buf].large_file then
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
	local function show_picker()
		vim.ui.select(choices, {
			prompt = "Python environment: " .. vim.fn.fnamemodify(root, ":t"),
			format_item = function(item)
				return item.label
			end,
		}, choose)
	end
	local conda = vim.fn.exepath("conda")
	if conda == "" and vim.env.CONDA_EXE and vim.fn.executable(vim.env.CONDA_EXE) == 1 then
		conda = vim.env.CONDA_EXE
	end
	if conda == "" then
		show_picker()
		return
	end
	vim.system({ conda, "env", "list", "--json" }, { cwd = root, text = true, timeout = 5000 }, function(result)
		vim.schedule(function()
			local ok, data = pcall(vim.json.decode, result.stdout or "")
			if result.code == 0 and ok and type(data) == "table" and type(data.envs) == "table" then
				for _, env in ipairs(data.envs) do
					if type(env) == "string" then
						local path = vim.fs.normalize(env)
						add("Conda " .. vim.fs.basename(path), path .. "/bin/python")
					end
				end
			end
			show_picker()
		end)
	end)
end, { desc = "Select Python environment for this project" })

-- Prefer PATH tools; append Mason's installed executables as a fallback.
require("mason").setup({
	PATH = "append",
	ui = { icons = { package_installed = "OK", package_pending = "...", package_uninstalled = "-" } },
})
local servers = {
	clangd = {
		cmd = { "clangd" },
		filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
		root_markers = { "compile_commands.json", "compile_flags.txt", ".clangd", "CMakeLists.txt", ".git" },
	},
	mlir_lsp_server = {
		cmd = { "mlir-lsp-server" },
		filetypes = { "mlir" },
		root_markers = { "CMakeLists.txt", ".git" },
	},
	starpls = {
		cmd = { "starpls", "server" },
		filetypes = { "bzl" },
		root_markers = { "MODULE.bazel", "WORKSPACE.bazel", "WORKSPACE", "BUILD.bazel", "BUILD", ".git" },
	},
	buf_ls = {
		cmd = { "buf", "lsp", "serve" },
		filetypes = { "proto" },
		root_markers = { "buf.yaml", ".git" },
	},
	bashls = {
		cmd = { "bash-language-server", "start" },
		filetypes = { "sh" },
		root_markers = { ".git" },
	},
	neocmake = {
		cmd = { "neocmakelsp", "stdio" },
		filetypes = { "cmake" },
		root_markers = { "CMakeLists.txt", ".git" },
		init_options = { format = { enable = true }, lint = { enable = true } },
	},
	yamlls = {
		cmd = { "yaml-language-server", "--stdio" },
		filetypes = { "yaml" },
		root_markers = { ".git" },
	},
	texlab = {
		cmd = { "texlab" },
		filetypes = { "tex", "plaintex" },
		root_markers = { ".latexmkrc", "latexmkrc", ".git" },
	},
	rust_analyzer = {
		cmd = { "rust-analyzer" },
		filetypes = { "rust" },
		root_markers = { "Cargo.toml", "rust-project.json", ".git" },
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
		before_init = function(_, config)
			-- Prefer project TypeScript; use PATH/Mason's tsserver as a fallback.
			local tsserver = vim.fn.exepath("tsserver")
			if tsserver ~= "" then
				config.init_options.tsserver = { fallbackPath = tsserver }
			end
		end,
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
	if name == "ty" or name == "pyright" then
		config.on_init = function(client)
			apply_python_path(client, python_paths[client.config.root_dir])
		end
	end
	config.root_dir = function(buf, on_dir)
		if vim.b[buf].large_file or vim.fn.executable(config.cmd[1]) == 0 then
			return
		end
		local file = vim.api.nvim_buf_get_name(buf)
		if file == "" then
			return
		end
		local root = (name == "ty" or name == "pyright") and python_project_root(buf)
			or vim.fs.root(buf, config.root_markers)
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
	run_on_start = false,
	integrations = { ["mason-lspconfig"] = false, ["mason-null-ls"] = false, ["mason-nvim-dap"] = false },
	ensure_installed = {
		"bash-language-server",
		"buf",
		"buildifier",
		"cmakelang",
		"latexindent",
		"neocmakelsp",
		"rust-analyzer",
		"shfmt",
		"starpls",
		"texlab",
		"yaml-language-server",
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
		"ruff",
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

-- File renames in the Snacks explorer use Snacks.rename for LSP import updates.

-- -------------------------------------
-- Buffers: native tabline and navigation (from init.offline.lua)
-- -------------------------------------
do
	local map = function(mode, lhs, rhs, desc)
		vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, desc = desc })
	end
	local function focus_editor()
		if vim.bo.filetype ~= "aerial" and not vim.bo.filetype:match("^snacks_picker") then
			return
		end
		for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
			local buf = vim.api.nvim_win_get_buf(win)
			if vim.bo[buf].buftype == "" then
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
		focus_editor()
		local order = {}
		for index, buf in ipairs(buffers()) do
			order[buf] = index
		end
		Snacks.picker.buffers({
			sort_lastused = false,
			sort = { fields = { "score:desc", "order" } },
			transform = function(item)
				item.order = order[item.buf]
				return item.order ~= nil
			end,
		})
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
		Snacks.bufdelete({ force = force or is_terminal, wipe = true })
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
						Snacks.bufdelete({ buf = b, force = is_terminal, wipe = true })
					end
				end
			end
		end, "Close " .. side .. " buffers (keep modified)")
	end
end

-- -------------------------------------
-- Statusline: native renderer from init.offline.lua
-- -------------------------------------
do
	local function set_git_mode_highlight()
		local mode = vim.fn.mode():sub(1, 1)
		local group = "Identifier"
		if mode == "i" then
			group = "String"
		elseif mode == "v" or mode == "V" or mode == "\22" then
			group = "Constant"
		end
		local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
		local accent = vim.api.nvim_get_hl(0, { name = group, link = false })
		local bg = (accent.reverse and accent.bg or accent.fg) or normal.fg or 0x808080
		local ctermbg = accent.cterm and accent.cterm.reverse and accent.ctermbg or accent.ctermfg
		local function luminance(color)
			local result = 0
			for i, weight in ipairs({ 0.2126, 0.7152, 0.0722 }) do
				local channel = math.floor(color / 256 ^ (3 - i)) % 256 / 255
				result = result + weight * (channel <= 0.04045 and channel / 12.92 or ((channel + 0.055) / 1.055) ^ 2.4)
			end
			return result
		end
		local background_luminance = luminance(bg)
		local function contrast(color)
			local value = luminance(color)
			return (math.max(value, background_luminance) + 0.05) / (math.min(value, background_luminance) + 0.05)
		end
		local fg, ctermfg = normal.bg or 0x000000, normal.ctermbg or 0
		if contrast(normal.fg or 0xffffff) > contrast(fg) then
			fg, ctermfg = normal.fg or 0xffffff, normal.ctermfg or 15
		end
		if contrast(fg) < 4.5 then
			fg, ctermfg =
				background_luminance > 0.179 and 0x000000 or 0xffffff, background_luminance > 0.179 and 0 or 15
		end
		vim.api.nvim_set_hl(0, "OnlineGitBranch", {
			fg = fg,
			bg = bg,
			ctermfg = ctermfg,
			ctermbg = ctermbg or normal.ctermfg or 8,
			bold = true,
			reverse = false,
			nocombine = true,
		})
	end
	local function set_online_status_highlights()
		local inactive = vim.api.nvim_get_hl(0, { name = "StatusLineNC", link = false })
		inactive.bold = false
		if inactive.cterm then
			inactive.cterm.bold = false
		end
		vim.api.nvim_set_hl(0, "StatusLineNC", inactive)
		vim.api.nvim_set_hl(0, "OnlineLspMissing", { fg = "#ffffff", bg = "#af0000", bold = true })
		vim.api.nvim_set_hl(0, "OnlineLspMissingNC", { fg = "#ffffff", bg = "#af0000", bold = false, nocombine = true })
		set_git_mode_highlight()
		for _, suffix in ipairs({ "", "NC" }) do
			local error_hl = vim.api.nvim_get_hl(0, { name = "StatusLine" .. suffix, link = false })
			if error_hl.reverse then
				error_hl.bg = error_hl.fg
			end
			if error_hl.cterm and error_hl.cterm.reverse then
				error_hl.ctermbg = error_hl.ctermfg
				error_hl.cterm.reverse = false
			end
			if error_hl.cterm then
				error_hl.cterm.nocombine = true
			end
			error_hl.nocombine = true
			error_hl.reverse, error_hl.fg, error_hl.ctermfg = false, "#ff0000", 9
			vim.api.nvim_set_hl(0, "OnlineStatusError" .. suffix, error_hl)
			local warn_hl = vim.deepcopy(error_hl)
			warn_hl.fg, warn_hl.ctermfg = "#ffd700", 220
			vim.api.nvim_set_hl(0, "OnlineStatusWarn" .. suffix, warn_hl)
		end
	end
	set_online_status_highlights()
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = vim.api.nvim_create_augroup("online-status-highlights", { clear = true }),
		callback = set_online_status_highlights,
	})
	vim.api.nvim_create_autocmd("ModeChanged", {
		group = "online-status-highlights",
		callback = function()
			set_git_mode_highlight()
			vim.cmd("redrawstatus")
		end,
	})
	vim.opt.laststatus = 2
	local language_status_visible = true
	function _G.OnlineGitStatus()
		local win = tonumber(vim.g.statusline_winid) or vim.api.nvim_get_current_win()
		local active = tonumber(vim.g.actual_curwin) or vim.api.nvim_get_current_win()
		if win ~= active then
			return ""
		end
		local branch = vim.b[vim.api.nvim_win_get_buf(win)].gitsigns_head
		local status = branch and branch ~= "" and ("[" .. branch .. "]") or ""
		if not status or status == "" then
			return ""
		end
		return "%#OnlineGitBranch# " .. status:gsub("%%", "%%%%") .. " %*"
	end
	function _G.OnlineDiagnosticStatus()
		local win = tonumber(vim.g.statusline_winid) or vim.api.nvim_get_current_win()
		local active = tonumber(vim.g.actual_curwin) or vim.api.nvim_get_current_win()
		local error_group = win == active and "OnlineStatusError" or "OnlineStatusErrorNC"
		local warn_group = win == active and "OnlineStatusWarn" or "OnlineStatusWarnNC"
		local counts = vim.diagnostic.count(vim.api.nvim_win_get_buf(win))
		local parts = {}
		for _, item in ipairs({ { "ERROR", "E:" }, { "WARN", "W:" }, { "HINT", "H:" } }) do
			local count = counts[vim.diagnostic.severity[item[1]]] or 0
			if count > 0 then
				local text = item[2] .. " " .. count
				local group = item[1] == "ERROR" and error_group or item[1] == "WARN" and warn_group
				parts[#parts + 1] = group and ("%#" .. group .. "#" .. text .. "%*") or text
			end
		end
		return table.concat(parts, " ")
	end
	function _G.OnlineLspStatus()
		if not language_status_visible then
			return ""
		end
		local win = tonumber(vim.g.statusline_winid) or vim.api.nvim_get_current_win()
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.bo[buf].buftype ~= "" then
			return ""
		end
		local names = {}
		for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
			if not client:is_stopped() then
				names[client.name:gsub("[%c]", " ")] = true
			end
		end
		local sorted = vim.fn.sort(vim.tbl_keys(names))
		local active = tonumber(vim.g.actual_curwin) or vim.api.nvim_get_current_win()
		local missing_group = win == active and "OnlineLspMissing" or "OnlineLspMissingNC"
		return #sorted > 0 and ("[LSP: " .. table.concat(sorted, ", "):gsub("%%", "%%%%") .. "]")
			or ("%#" .. missing_group .. "#[LSP X]%*")
	end
	vim.api.nvim_create_autocmd({ "LspAttach", "LspDetach" }, {
		group = vim.api.nvim_create_augroup("online-lsp-status", { clear = true }),
		callback = function()
			-- LspDetach fires before the client is removed from the buffer.
			vim.schedule(function()
				vim.cmd("redrawstatus")
			end)
		end,
	})
	local format_status_cache = {}
	vim.api.nvim_create_autocmd({ "FileType", "BufFilePost", "BufWritePost", "LspAttach", "LspDetach", "BufWipeout" }, {
		group = vim.api.nvim_create_augroup("online-format-status", { clear = true }),
		callback = function(args)
			format_status_cache[args.buf] = nil
		end,
	})
	vim.api.nvim_create_autocmd({ "DirChanged", "FocusGained" }, {
		group = "online-format-status",
		callback = function()
			format_status_cache = {}
		end,
	})
	function _G.OnlineFormatStatus()
		if not language_status_visible then
			return ""
		end
		local win = tonumber(vim.g.statusline_winid) or vim.api.nvim_get_current_win()
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.bo[buf].buftype ~= "" then
			return ""
		end
		if
			not vim.bo[buf].modifiable
			or vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf)) > 2 * 1024 * 1024
		then
			return "[FORMAT X]"
		end
		-- Conform probes executable paths and project roots; do not repeat on every redraw.
		local now = vim.uv.hrtime()
		local cached = format_status_cache[buf]
		if cached and now - cached.time < 5e9 then
			return cached.text
		end
		local formatters, lsp = require("conform").list_formatters_to_run(buf)
		local names = {}
		for _, formatter in ipairs(formatters) do
			names[vim.fn.fnamemodify(formatter.command, ":t"):gsub("[%c]", " ")] = true
		end
		if lsp then
			for _, client in ipairs(vim.lsp.get_clients({ bufnr = buf, method = "textDocument/formatting" })) do
				if not client:is_stopped() then
					names[client.name:gsub("[%c]", " ")] = true
				end
			end
		end
		local sorted = vim.fn.sort(vim.tbl_keys(names))
		local text = #sorted > 0 and ("[FORMAT: " .. table.concat(sorted, ", ") .. "]") or "[FORMAT X]"
		format_status_cache[buf] = { time = now, text = text }
		return text
	end
	function _G.OnlineStatusline()
		local win = tonumber(vim.g.statusline_winid) or vim.api.nvim_get_current_win()
		if win ~= vim.api.nvim_get_current_win() then
			return " %f %= %y "
		end
		return "%{%v:lua.OnlineGitStatus()%} %f %m%r%h %= %{%v:lua.OnlineDiagnosticStatus()%} %{%v:lua.OnlineLspStatus()%} %{v:lua.OnlineFormatStatus()} %y | %4l:%3c | %3p%% "
	end
	vim.opt.statusline = "%!v:lua.OnlineStatusline()"
	vim.keymap.set("n", "<leader>Tl", function()
		language_status_visible = not language_status_visible
		vim.cmd("redrawstatus")
	end, { desc = "Toggle LSP / formatter status" })
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
vim.cmd([[colorscheme retrobox]])

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
	cmd("au ColorScheme * hi SnacksPickerBorder ctermbg=none guibg=none")
	cmd("au ColorScheme * hi SnacksPickerList ctermbg=none guibg=none")
	cmd("let &fcs='eob: '")
end
