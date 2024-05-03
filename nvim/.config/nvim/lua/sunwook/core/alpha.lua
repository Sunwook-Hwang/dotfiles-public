local status_ok, alpha = pcall(require, "alpha")
if not status_ok then
	return
end

local dashboard = require("alpha.themes.dashboard")
dashboard.section.header.val = {
  -- "",
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
  -- ⠀⠀⠀⡐⠀⠀⠀⠀⠀⠀⠀⠈⠳⣄⠀⠘⢆⠀⡇⢸⠀⡎⡠⡖⢄⢹⢸⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  -- ⠀⢠⠊⠀⠀⠀⠀⠀⢀⠄⠂⠀⠀⠈⢦⠀⠀⠙⢧⣸⠀⣏⠑⠓⠬⢾⢸⠀⠀⠀⠀⡇⠀⠉⠁⠤⢀⠀⠄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  -- ⠐⠁⠀⠀⠀⠀⠀⡐⠁⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠘⢆⠈⠉⡗⠲⠼⢸⠀⠀⠀⠀⡏⠁⠐⠂⢄⠀⠑⠀⠘⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  -- ⠀⠀⠀⠀⠀⠀⠐⠀⠀⠀⠀⠀⠀⠀⠈⡆⠀⠀⠀⠀⢸⠉⠑⠓⠦⣤⣸⡀⣀⡤⠖⠁⠀⠀⠀⡠⠀⠀⠀⢈⠀⢊⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  -- ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠃⠀⠀⠀⠀⠘⠀⠀⠀⠀⠀⠙⠛⠀⠀⠀⠀⠒⠀⠁⠀⠐⠒⠉⠁⠊⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
  -- ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀  ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
}

dashboard.section.buttons.val = {
	dashboard.button("f", "  Find file", ":Telescope find_files <CR>"),
	dashboard.button("r", "  Recently used files", ":Telescope oldfiles <CR>"),
	-- dashboard.button("SPC f p", "  Load Session", ":OpenSession!<CR>"),
	dashboard.button("p", "  Find project", ":Telescope projects <CR>"),
	-- dashboard.button("SPC f t", "  Find text", ":Telescope live_grep <CR>"),
	dashboard.button("c", "  Configuration", ":e ~/.config/nvim/init.lua <CR>"),
	dashboard.button("n", "  New file", ":ene <BAR> startinsert <CR>"),
	dashboard.button("u", "  Update", ":PackerSync<CR>"),
	dashboard.button("q", "  Quit Neovim", ":qa!<CR>"),
}

dashboard.section.footer.val = "sunwook-hwang.github.io"

dashboard.section.footer.opts.hl = "Type"
dashboard.section.header.opts.hl = "Include"
dashboard.section.buttons.opts.hl = "Keyword"

dashboard.opts.opts.noautocmd = true
-- vim.cmd([[autocmd User AlphaReady echo 'ready']])
alpha.setup(dashboard.opts)

-- vim.g.dashboard_default_executive = "telescope"
-- vim.g.dashboard_custom_section = {
--   a = {
--     description = { "  Find File               SPC f f" },
--     command = "Telescope find_files",
--   }, b = {
--     description = { "  Recently Used Files     SPC f r" },
--     command = "Telescope oldfiles",
--   },
--   c = {
--     description = { "  Load Session            SPC f p" },
--     command = ":OpenSession!",
--   },
--   d = {
--     description = { "  Find Word               SPC f t" },
--     command = "Telescope live_grep",
--   },
--   e = {
--     description = { "  Settings                SPC f ;" },
--     command = ":e ~/.config/nvim/init.lua",
--   },
-- }
