local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
  return
end

require("sunwook.core.lsp.lsp-installer")
require("sunwook.core.lsp.handlers").setup()
require("sunwook.core.lsp.null-ls")
