local M = {}

M.setup = function()
  vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "clangd" })
  -- customize clangd by changing the flags below
  local clangd_flags = {
    "--background-index",
    "--fallback-style=google",
    "--all-scopes-completion",
    "--clang-tidy",
    "--log=error",
    "--completion-style=detailed",
    "--pch-storage=disk",
    "--folding-ranges",
    "--enable-config",
    "--offset-encoding=utf-16",
  }

  local clangd_bin = "clangd"

  local opts = {
    cmd = { clangd_bin, unpack(clangd_flags) },
  }
  require("lvim.lsp.manager").setup("clangd", opts)

  local formatters = require "lvim.lsp.null-ls.formatters"
  formatters.setup {
    {
      command = "clang-format",
      filetype = { "c", "cpp", "cs", "java" },
      extra_args = { "--style", "{IndentWidth: 2}" },
    },
  }

  pcall(function()
    require("clangd_extensions").setup {
      server = {
        cmd = { "clangd", unpack(clangd_flags) },
        on_attach = require("lvim.lsp").common_on_attach,
        on_init = require("lvim.lsp").common_on_init,
        -- capabilities = capabilities,
        capabilities = require("lvim.lsp").common_capabilities(),
      },
      extensions = {
        autoSetHints = true,
        inlay_hints = {
          only_current_line = false,
          show_parameter_hints = false,
          parameter_hints_prefix = "<- ",
          other_hints_prefix = "=> ",
          highlight = "Comment",
          -- The highlight group priority for extmark
          priority = 100,
        },
        ast = {
          role_icons = {
            type = "🄣",
            declaration = "🄓",
            expression = "🄔",
            statement = ";",
            specifier = "🄢",
            ["template argument"] = "🆃",
          },
          kind_icons = {
            Compound = "🄲",
            Recovery = "🅁",
            TranslationUnit = "🅄",
            PackExpansion = "🄿",
            TemplateTypeParm = "🅃",
            TemplateTemplateParm = "🅃",
            TemplateParamObject = "🅃",
          },
          highlights = {
            detail = "Comment",
          },
        },
        memory_usage = {
          border = "rounded",
        },
        symbol_info = {
          border = "rounded",
        },
      },
    }
  end)

  lvim.builtin.dap.on_config_done = function(dap)
    dap.adapters.codelldb = {
      type = "server",
      port = "${port}",
      executable = {
        -- provide the absolute path for `codelldb` command if not using the one installed using `mason.nvim`
        command = "codelldb",
        -- command = mason_path .. "bin/codelldb",
        args = { "--port", "${port}" },

        -- On windows you may have to uncomment this:
        -- detached = false,
      },
    }

    dap.configurations.cpp = {
      {
        name = "Launch file",
        type = "codelldb",
        request = "launch",
        program = function()
          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
      },
    }
    dap.configurations.c = dap.configurations.cpp

    dap.configurations.rust = {
      {
        name = "Launch file",
        type = "codelldb",
        request = "launch",
        program = function()
          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
      },
    }
  end
end

M.keymaps = function(opts)
  if opts then
    opts = opts
  else
    opts = {}
  end

  local wkl = require "which-key"

  wkl.register({
    ["n"] = {
      name = "Clangd",
      a = { "<cmd>ClangdAST<CR>", "View AST" },
      s = { "<cmd>ClangdSymbolInfo<CR>", "View Symbol info" },
      t = { "<cmd>ClangdTypeHierarchy<CR>", "View Type hierarchy" },
      h = { "<cmd>ClangdSwitchSourceHeader<CR>", "Switch between source/header" },
      H = { "<cmd>ClangdToggleInlayHints<CR>", "Toggle Inlay Hints" },
    },
  }, opts)
end

return M
