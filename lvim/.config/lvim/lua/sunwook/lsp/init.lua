lvim.builtin.dap.active = true

require("sunwook.lsp.lang.c").setup() -- c and cpp
require("sunwook.lsp.lang.python").setup()
require("sunwook.lsp.lang.rust").setup()
require("sunwook.lsp.lang.latex").setup()
require("sunwook.lsp.lang.js-ts").setup()
require "sunwook.lsp.lang.yaml"

-- generic LSP settings
--
lvim.lsp.on_attach_callback = function(client, bufnr)
  if client.name == "yamlls" then
    client.server_capabilities.documentRangeFormattingProvider = true
    client.server_capabilities.documentFormattingProvider = true
  end
end

vim.diagnostic.config { virtual_text = false }
-- -- make sure server will always be installed even if the server is in skipped_servers list
lvim.lsp.installer.setup.ensure_installed = {
  "jsonls",
}
-- -- change UI setting of `LspInstallInfo`
-- -- see <https://github.com/williamboman/nvim-lsp-installer#default-configuration>
-- lvim.lsp.installer.setup.ui.check_outdated_servers_on_open = false
-- lvim.lsp.installer.setup.ui.border = "rounded"
-- lvim.lsp.installer.setup.ui.keymaps = {
--     uninstall_server = "d",
--     toggle_server_expand = "o",
-- }

-- ---@usage disable automatic installation of servers
-- lvim.lsp.installer.setup.automatic_installation = false

---configure a server manually. !!Requires `:LvimCacheReset` to take effect!!
---see the full default list `:lua print(vim.inspect(lvim.lsp.automatic_configuration.skipped_servers))`

-- local opts = {} -- check the lspconfig documentation for a list of all possible options
-- require("lvim.lsp.manager").setup("pyright", opts)
-- ---remove a server from the skipped list, e.g. eslint, or emmet_ls. !!Requires `:LvimCacheReset` to take effect!!
-- ---`:LvimInfo` lists which server(s) are skipped for the current filetype
-- lvim.lsp.automatic_configuration.skipped_servers = vim.tbl_filter(function(server)
--   return server ~= "emmet_ls"
-- end, lvim.lsp.automatic_configuration.skipped_servers)

-- -- you can set a custom on_attach function that will be used for all the language servers
-- -- See <https://github.com/neovim/nvim-lspconfig#keybindings-and-completion>
-- -- set a formatter, this will override the language server formatting capabilities (if it exists)

-- Lengthen timeout range for formatting large files
lvim.lsp.null_ls.setup.timeout_ms = 5000

local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
  { command = "stylua", filetypes = { "lua" } },
  {
    -- each formatter accepts a list of options identical to https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#Configuration
    command = "prettier",
    ---@usage arguments to pass to the formatter
    -- these cannot contain whitespaces, options such as `--line-width 80` become either `{'--line-width', '80'}` or `{'--line-width=80'}`
    -- extra_args = { "--print-with", "100" },
    extra_args = { "--no-semi", "--single-quote", "--jsx-single-quote" },
    ---@usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
  },
}

-- -- set additional linters
-- local linters = require("lvim.lsp.null-ls.linters")
-- linters.setup({
-- { command = "flake8", filetypes = { "python" } },
-- {
--   -- each linter accepts a list of options identical to https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md#Configuration
--   command = "shellcheck",
--   ---@usage arguments to pass to the formatter
--   -- these cannot contain whitespaces, options such as `--line-width 80` become either `{'--line-width', '80'}` or `{'--line-width=80'}`
--   extra_args = { "--severity", "warning" },
-- },
-- {
--   command = "codespell",
--   ---@usage specify which filetypes to enable. By default a providers will attach to all the filetypes it supports.
--   filetypes = { "javascript", "python" },
-- },
-- })

-- Autocommands (https://neovim.io/doc/user/autocmd.html)
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = { "*.json", "*.jsonc" },
  -- enable wrap mode for json files only
  command = "setlocal wrap",
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "zsh",
  callback = function()
    -- let treesitter use bash highlight for zsh files as well
    require("nvim-treesitter.highlight").attach(0, "bash")
  end,
})
