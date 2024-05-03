HOME_PATH = vim.loop.os_homedir()

local ls = require("luasnip")

ls.config.set_config({
  history = true,
  region_check_events = "CursorMoved,CursorHold,InsertEnter",
  delete_check_events = "InsertLeave",
  enable_autosnippets = true,
  -- ext_opts = {
  -- 	[type.choiceNode] = {
  -- 		active = {
  -- 			virt_text = { { "<--", "Error" } },
  -- 		},
  -- 	},
  -- },
})

vim.o.runtimepath = vim.o.runtimepath .. "," .. HOME_PATH .. "/.config/nvim/my-snippets/"
require("luasnip/loaders/from_vscode").lazy_load()
