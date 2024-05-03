lvim.log.level = "warn"
lvim.format_on_save = false
lvim.lint_on_save = true
lvim.transparent_window = false
lvim.reload_config_on_save = true

vim.opt.updatetime = 5
vim.opt.timeoutlen = 500
vim.opt.wrap = true
vim.opt.scrolloff = 4
vim.opt.cmdheight = 0
vim.opt.number = true
vim.opt.relativenumber = false
vim.cmd [[set iskeyword+=-]]

-- to disable icons and use a minimalist setup, uncomment the following
-- lvim.use_icons = false

-- neovide settings
vim.opt.guifont = "JetBrainsMono Nerd Font Mono:h18"
vim.g.neovide_input_macos_alt_is_meta = true
vim.g.neovide_cursor_animation_length = 0.13
vim.g.neovide_cursor_trail_size = 0.07

-- remove lvim autocmds for _format_options
-- vim.api.nvim_clear_autocmds { pattern = "*", group = "_format_options" }

-- -- colorscheme settings
-- lvim.colorscheme = "gruvbox"
-- lvim.colorscheme = "jellybeans"
-- lvim.colorscheme = "ayu"
-- lvim.colorscheme = "onenord"
-- lvim.colorscheme = "system76"
-- lvim.colorscheme = "darkplus"
-- lvim.colorscheme = "tokyonight-night"
-- lvim.colorscheme = "tokyonight-day"
-- lvim.colorscheme = "github_dark_default"
lvim.colorscheme = "kanagawa"
-- lvim.colorscheme = "noctis"
-- lvim.colorscheme = "ofirkai" -- monokai.nvim
-- lvim.colorscheme = "catppuccin"
