--.--.   ,--.,--.,--.   ,--.    ,------. ,-----. ,------.      ,---.  ,--. ,--.,--.  ,--.,--.   ,--. ,-----.  ,-----. ,--. ,--.
-- \  `.'  / |  ||   `.'   |    |  .---''  .-.  '|  .--. '    '   .-' |  | |  ||  ,'.|  ||  |   |  |'  .-.  ''  .-.  '|  .'   /
--  \     /  |  ||  |'.'|  |    |  `--, |  | |  ||  '--'.'    `.  `-. |  | |  ||  |' '  ||  |.'.|  ||  | |  ||  | |  ||  .   '
--   \   /   |  ||  |   |  |    |  |`   '  '-'  '|  |\  \     .-'    |'  '-'  '|  | `   ||   ,'.   |'  '-'  ''  '-'  '|  |\   \
--    `-'    `--'`--'   `--'    `--'     `-----' `--' '--'    `-----'  `-----' `--'  `--''--'   '--' `-----'  `-----' `--' '--'

-- TODO: test
-- 0. prettier PATH settings
-- 1. nvim-dap
-- 2. nvim.refactoring -> debugging tool settings

if pcall(require, "impatient") then
  require("impatient").enable_profile()
end

require("sunwook.disable_builtin")
require("sunwook.keymaps")
require("sunwook.settings")
require("sunwook.plugins")
require("sunwook.colors")
require("sunwook.core")

vim.cmd([[colorscheme gruvbox]])
