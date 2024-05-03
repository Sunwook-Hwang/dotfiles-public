-- keymappings [view all the defaults by pressing <leader>Lk]

-- add your own keymapping
-- unmap a default keymapping
-- vim.keymap.del("n", "<C-Up>")
lvim.leader = " "

lvim.keys.normal_mode["<C-s>"] = ":w<cr>"
lvim.keys.insert_mode["<C-s>"] = "<esc><cmd>w<cr>"
lvim.keys.normal_mode["<tab>"] = "<Plug>(CybuNext)"
lvim.keys.normal_mode["<S-tab>"] = "<Plug>(CybuPrev)"

-- lvim.keys.normal_mode["<leader>o"] = "o<ESC>"
-- lvim.keys.normal_mode["<leader>O"] = "O<ESC>"

lvim.keys.insert_mode["jk"] = "<ESC>"

lvim.keys.insert_mode["("] = "(<C-g>u"
lvim.keys.insert_mode["?"] = "?<C-g>u"
lvim.keys.insert_mode["["] = "[<C-g>u"
lvim.keys.insert_mode["{"] = "{<C-g>u"
lvim.keys.insert_mode["!"] = "!<C-g>u"
lvim.keys.insert_mode[":"] = ":<C-g>u"
lvim.keys.insert_mode["'"] = "'<C-g>u"
lvim.keys.insert_mode[";"] = ";<C-g>u"
lvim.keys.normal_mode["+"] = { "<C-a>" }
lvim.keys.normal_mode["-"] = { "<C-x>" }
lvim.keys.normal_mode["N"] = { "Nzzzv", { noremap = true } }
lvim.keys.normal_mode["Y"] = { "y$", { noremap = true } }
lvim.keys.normal_mode["n"] = { "nzzzv", { noremap = true } }
lvim.keys.visual_mode["p"] = [["_dP]]
-- lvim.keys.normal_mode["<leader>d"] = { "\"_d", { silent = true, noremap = true } }
-- lvim.keys.visual_mode["<leader>d"] = { "\"_d", { silent = true, noremap = true } }
-- lvim.keys.normal_mode["<leader>D"] = { "\"_D", { silent = true, noremap = true } }

lvim.keys.normal_mode["<esc>"] = { "<cmd>nohl<CR>" }

lvim.keys.normal_mode["<C-p>"] = { "<cmd>ChatGPT<cr>", { noremap = true, silent = true } }
-- lvim.keys.normal_mode["s"] = { "<Plug>(easymotion-overwin-f)", { noremap = true } }
-- lvim.keys.normal_mode["f"] = { "<Plug>(easymotion-overwin-f2)", { noremap = true } }
lvim.keys.normal_mode["<S-Up>"] = { ":resize -5<CR>" }
lvim.keys.normal_mode["<S-Down>"] = { ":resize +5<CR>" }
lvim.keys.normal_mode["<S-Left>"] = { ":vertical resize -5<CR>" }
lvim.keys.normal_mode["<S-Right>"] = { ":vertical resize +5<CR>" }

lvim.builtin.which_key.mappings["D"] = {
  name = "Directory",
  c = { "<cmd>cd %:h<CR>", "Current directory" },
  r = { "<cmd>Rooter<CR>", "Root directory" },
}

lvim.builtin.which_key.mappings.s.b = { ":Telescope buffers<CR>", "Find buffers" }
-- lvim.builtin.which_key.mappings.b.m = { ":BufferLineCloseLeft<CR>|:BufferLineCloseRight<CR>", "Close other buffers" }

-- Pop out the lvim which-key map
lvim.builtin.which_key.mappings["h"] = nil
lvim.builtin.which_key.mappings["q"] = nil
lvim.builtin.which_key.mappings["f"] = nil

-- Customize the which-key map
lvim.builtin.which_key.mappings["a"] = { "gg<S-v>G", "Select all" }
lvim.builtin.which_key.mappings["b"] = {
  name = "Buffer",
  m = { "<cmd>lua require('close_buffers').wipe({ type = 'other' })<CR>", "Close other buffers" },
}
lvim.builtin.which_key.mappings["C"] = {
  name = "ChatGPT",
  c = { "<cmd>ChatGPT<cr>", "Chat" },
  a = { "<cmd>ChatGPTActAs<cr>", "Act As" },
  e = { "<cmd>ChatGPTEditWithInstructions<cr>", "Edit" },
  r = { "<cmd>ChatRunCustomCodeAction<cr>", "Code Action" },
}
lvim.builtin.which_key.mappings["e"] = { ":NeoTreeFocusToggle<cr>", "Explorer" }
lvim.builtin.which_key.mappings["r"] = { "<cmd>Telescope projects<CR>", "Projects" }
lvim.builtin.which_key.mappings["<CR>"] =
  { require("lvim.core.telescope.custom-finders").find_project_files, "Find File" }
lvim.builtin.which_key.mappings["t"] = { ":Telescope grep_string search=<C-R><C-W><CR>", "Search Under Cursor" }
lvim.builtin.which_key.mappings["u"] = { ":UndotreeToggle<CR>", "UndoTree" }
lvim.builtin.which_key.mappings["o"] = { ":SymbolsOutline<CR>", "Outline" }
lvim.builtin.which_key.mappings.l.t = { ":LvimToggleFormatOnSave<CR>", "Toggle Format on Save" }

lvim.builtin.which_key.mappings["w"] = {
  name = "Windows",
  d = { "<cmd>windo diffthis<CR>", "Diff these" },
  t = { "<cmd>lua require 'sunwook.terminal'.htop_toggle()<cr>", "HTOP" },
  g = { "<cmd>lua require 'sunwook.terminal'.gpu_toggle()<cr>", "nvidia-smi" },
}
lvim.builtin.which_key.mappings["N"] = {
  name = "Neogen",
  c = { "<cmd>lua require('neogen').generate({ type = 'class'})<CR>", "Class Documentation" },
  f = { "<cmd>lua require('neogen').generate({ type = 'func'})<CR>", "Function Documentation" },
  t = { "<cmd>lua require('neogen').generate({ type = 'type'})<CR>", "Type Documentation" },
  F = { "<cmd>lua require('neogen').generate({ type = 'file'})<CR>", "File Documentation" },
}

lvim.builtin.which_key.mappings["S"] = {
  name = "Session",
  c = { "<cmd>lua require('persistence').load()<cr>", "Restore last session for current dir" },
  l = { "<cmd>lua require('persistence').load({ last = true })<cr>", "Restore last session" },
  Q = { "<cmd>lua require('persistence').stop()<cr>", "Quit without saving session" },
}

lvim.builtin.which_key.mappings["p"] = {
  name = "Replace",
  r = { "<cmd>lua require('spectre').open()<cr>", "Replace" },
  w = { "<cmd>lua require('spectre').open_visual({select_word=true})<cr>", "Replace Word" },
  f = { "<cmd>lua require('spectre').open_file_search()<cr>", "Replace Buffer" },
}

lvim.builtin.which_key.mappings["P"] = {
  name = "Plugins",
  i = { "<cmd>Lazy install<cr>", "Install" },
  s = { "<cmd>Lazy sync<cr>", "Sync" },
  S = { "<cmd>Lazy clear<cr>", "Status" },
  c = { "<cmd>Lazy clean<cr>", "Clean" },
  u = { "<cmd>Lazy update<cr>", "Update" },
  p = { "<cmd>Lazy profile<cr>", "Profile" },
  l = { "<cmd>Lazy log<cr>", "Log" },
  d = { "<cmd>Lazy debug<cr>", "Debug" },
}

-- p = {
--   name = "Plugins",
--   i = { "<cmd>Lazy install<cr>", "Install" },
--   s = { "<cmd>Lazy sync<cr>", "Sync" },
--   S = { "<cmd>Lazy clear<cr>", "Status" },
--   c = { "<cmd>Lazy clean<cr>", "Clean" },
--   u = { "<cmd>Lazy update<cr>", "Update" },
--   p = { "<cmd>Lazy profile<cr>", "Profile" },
--   l = { "<cmd>Lazy log<cr>", "Log" },
--   d = { "<cmd>Lazy debug<cr>", "Debug" },
-- },
lvim.builtin.which_key.mappings["z"] = {
  name = "Zen",
  f = { ":TZFocus<CR>", "Focus" },
  m = { ":TZMinimalist<CR>", "Minimalist" },
  z = { ":TZAtaraxis<CR>", "Zen" },
}

-- lvim.builtin.which_key.mappings["l"]["f"] = {
--   function()
--     require("lvim.lsp.utils").format { timeout_ms = 5000 }
--   end,
--   "Format",
-- }

-- lvim.keys.normal_mode["<leader>h"] = "<cmd>sv<CR>"
-- lvim.keys.normal_mode["<leader>v"] = "<cmd>vs<CR>"
-- override a default keymapping
-- lvim.keys.normal_mode["<C-q>"] = ":q<cr>" -- or vim.keymap.set("n", "<C-q>", ":q<cr>" )

-- vim.g.maplocalleader = " "
-- local wkl = require "which-key"

vim.cmd "autocmd FileType * lua SetKeybinds()"
function SetKeybinds()
  local fileTy = vim.api.nvim_buf_get_option(0, "filetype")
  local opts = { prefix = " ", buffer = 0 }

  if fileTy == "python" then
    require("sunwook.lsp.lang.python").keymaps(opts)
    -- wkl.register({
    --   ["j"] = {
    --     name = "Jupyter",
    --     i = { "<Cmd>MagmaInit<CR>", "Init Magma" },
    --     d = { "<Cmd>MagmaDeinit<CR>", "Deinit Magma" },
    --     e = { "<Cmd>MagmaEvaluateLine<CR>", "Evaluate Line" },
    --     r = { "<Cmd>MagmaReevaluateCell<CR>", "Re evaluate cell" },
    --     D = { "<Cmd>MagmaDelete<CR>", "Delete cell" },
    --     s = { "<Cmd>MagmaShowOutput<CR>", "Show Output" },
    --     R = { "<Cmd>MagmaRestart!<CR>", "Restart Magma" },
    --     S = { "<Cmd>MagmaSave<CR>", "Save" },
    --   },
    --   ["C"] = {
    --     name = "Python",
    --     m = { "<cmd>lua require('dap-python').test_method()<cr>", "Test Method" },
    --     f = { "<cmd>lua require('dap-python').test_class()<cr>", "Test Class" },
    --     s = { "<cmd>lua require('dap-python').debug_selection()<cr>", "Debug Selection" },
    --     i = { "<cmd>lua require('swenv.api').pick_venv()<cr>", "Pick Env" },
    --     d = { "<cmd>lua require('swenv.api').get_current_venv()<cr>", "Show Env" },
    --   },
    -- }, opts)
  elseif fileTy == "rust" then
    require("sunwook.lsp.lang.rust").keymaps(opts)
    -- wkl.register({
    --   ["C"] = {
    --     name = "Rust",
    --     r = { "<cmd>RustRunnables<Cr>", "Runnables" },
    --     t = { "<cmd>lua _CARGO_TEST()<cr>", "Cargo Test" },
    --     m = { "<cmd>RustExpandMacro<Cr>", "Expand Macro" },
    --     c = { "<cmd>RustOpenCargo<Cr>", "Open Cargo" },
    --     p = { "<cmd>RustParentModule<Cr>", "Parent Module" },
    --     d = { "<cmd>RustDebuggables<Cr>", "Debuggables" },
    --     v = { "<cmd>RustViewCrateGraph<Cr>", "View Crate Graph" },
    --     R = {
    --       "<cmd>lua require('rust-tools/workspace_refresh')._reload_workspace_from_cargo_toml()<Cr>",
    --       "Reload Workspace",
    --     },
    --     o = { "<cmd>RustOpenExternalDocs<Cr>", "Open External Docs" },
    --   },
    -- }, opts)
  elseif fileTy == "c" then
    require("sunwook.lsp.lang.c").keymaps(opts)
  elseif fileTy == "cpp" then
    require("sunwook.lsp.lang.c").keymaps(opts)
  else
    return
  end
end
