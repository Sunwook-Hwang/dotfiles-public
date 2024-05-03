local M = {}

M.setup = function()
  require("lvim.lsp.manager").setup "pyright"

  local formatters = require "lvim.lsp.null-ls.formatters"
  formatters.setup {
    { command = "black", filetypes = { "python" } },
  }

  local mason_path = vim.fn.glob(vim.fn.stdpath "data" .. "/mason/")

  pcall(function()
    require("dap-python").setup(mason_path .. "packages/debugpy/venv/bin/python")
  end)

  -- Supported test frameworks are unittest, pytest and django. By default it
  -- tries to detect the runner by probing for pytest.ini and manage.py, if
  -- neither are present it defaults to unittest.
  pcall(function()
    require("dap-python").test_runner = "pytest"
  end)

  -- Magma Setup

  -- Image options. Other options:
  -- 1. none:     Don't show images.
  -- 2. ueberzug: use Ueberzug to display images.
  -- 3. kitty:    use the Kitty protocol to display images.
  vim.g.magma_image_provider = "kitty"

  -- If this is set to true, then whenever you have an active cell its output
  -- window will be automatically shown.
  vim.g.magma_automatically_open_output = true

  -- If this is true, then text output in the output window will be wrapped.
  vim.g.magma_wrap_output = false

  -- If this is true, then the output window will have rounded borders.
  vim.g.magma_output_window_borders = false

  -- The highlight group to be used for highlighting cells.
  vim.g.magma_cell_highlight_group = "CursorLine"

  -- Where to save/load with :MagmaSave and :MagmaLoad.
  -- The generated file is placed in this directory, with the filename itself
  -- being the buffer's name, with % replaced by %% and / replaced by %, and
  -- postfixed with the extension .json.
  vim.g.magma_save_path = vim.fn.stdpath "data" .. "/magma"
end

M.keymaps = function(opts)
  if opts then
    opts = opts
  else
    opts = {}
  end

  local wkl = require "which-key"

  wkl.register({
    ["j"] = {
      name = "Jupyter",
      i = { "<Cmd>MagmaInit<CR>", "Init Magma" },
      d = { "<Cmd>MagmaDeinit<CR>", "Deinit Magma" },
      e = { "<Cmd>MagmaEvaluateLine<CR>", "Evaluate Line" },
      r = { "<Cmd>MagmaReevaluateCell<CR>", "Re evaluate cell" },
      D = { "<Cmd>MagmaDelete<CR>", "Delete cell" },
      s = { "<Cmd>MagmaShowOutput<CR>", "Show Output" },
      R = { "<Cmd>MagmaRestart!<CR>", "Restart Magma" },
      S = { "<Cmd>MagmaSave<CR>", "Save" },
    },
    ["n"] = {
      name = "Python",
      m = { "<cmd>lua require('dap-python').test_method()<cr>", "Test Method" },
      f = { "<cmd>lua require('dap-python').test_class()<cr>", "Test Class" },
      s = { "<cmd>lua require('dap-python').debug_selection()<cr>", "Debug Selection" },
      i = { "<cmd>lua require('swenv.api').pick_venv()<cr>", "Pick Env" },
      d = { "<cmd>lua require('swenv.api').get_current_venv()<cr>", "Show Env" },
    },
  }, opts)
end

return M
