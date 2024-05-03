-- local status_ok, lsp_installer = pcall(require, "nvim-lsp-installer")
-- if not status_ok then
--   return
-- end
local status_ok, lsp_installer = pcall(require, "mason")
if not status_ok then
  return
end
-- local lua_settings = {
--   Lua = {
--     runtime = {
--       -- LuaJIT in the case of Neovim
--       version = "LuaJIT",
--       path = vim.split(package.path, ";"),
--     },
--     diagnostics = {
--       -- Get the language server to recognize the `vim` global
--       globals = { "vim" },
--     },
--     workspace = {
--       -- Make the server aware of Neovim runtime files
--       library = {
--         [vim.fn.expand("$VIMRUNTIME/lua")] = true,
--         [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
--       },
--     },
--   },
-- }

-- -- Register a handler that will be called for all installed servers.
-- -- Alternatively, you may also register handlers on specific server instances instead (see example below).
-- lsp_installer.on_server_ready(function(server)
--   local opts = {
--     on_attach = require("sunwook.core.lsp.handlers").on_attach,
--     capabilities = require("sunwook.core.lsp.handlers").capabilities,
--   }

--   -- language specific config
--   if server.name == "lua" then
--     opts.settings = lua_settings
--   end
--   if server.name == "sourcekit" then
--     opts.filetypes = { "swift", "objective-c", "objective-cpp" } -- we don't want c and cpp!
--   end
--   if server.name == "clangd" then
--     opts.filetypes = { "c", "cpp" } -- we don't want objective-c and objective-cpp!
--   end

--   -- This setup() function is exactly the same as lspconfig's setup function.
--   -- Refer to https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
--   server:setup(opts)
-- end)

-- -- -- Lua
-- require("lsp-colors").setup({
--   Error = "#db4b4b",
--   Warning = "#e0af68",
--   Information = "#0db9d7",
--   Hint = "#10B981",
-- })
