local M = {}

-- TODO: backfill this to template
M.setup = function()
  local signs = {
    { name = "DiagnosticSignError", text = "" },
    { name = "DiagnosticSignWarn", text = "" },
    { name = "DiagnosticSignHint", text = "" },
    { name = "DiagnosticSignInfo", text = "" },
  }

  for _, sign in ipairs(signs) do
    vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
  end

  local config = {
    -- disable virtual text
    virtual_text = false,
    -- show signs
    signs = {
      active = signs,
    },
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = {
      focusable = false,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
    },
  }

  vim.diagnostic.config(config)

  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "rounded",
  })

  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = "rounded",
  })
end

local function lsp_highlight_document(client)
  if client.server_capabilities.document_highlight then
    local status_ok, illuminate = pcall(require, "illuminate")
    if not status_ok then
      return
    end
    illuminate.on_attach(client)
  end
end

-- local function lsp_highlight_document(client)
--   -- Set autocommands conditional on server_capabilities
--   if client.server_capabilities.document_highlight then
--     vim.api.nvim_exec(
--       [[
--       augroup lsp_document_highlight
--       autocmd! * <buffer>
--       autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
--       autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
--       augroup END
--       ]],
--       false
--     )
--   end
-- end

local function lsp_keymaps(bufnr)
  local function buf_set_keymap(...)
    vim.api.nvim_buf_set_keymap(bufnr, ...)
  end

  local opts = { noremap = true, silent = true }

  buf_set_keymap("n", "<space>ga", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
  buf_set_keymap("n", "<space>ld", '<cmd>lua vim.diagnostic.open_float({border = "rounded"})<CR>', opts)
  buf_set_keymap("n", "<space>lj", '<cmd>lua vim.diagnostic.goto_next({popup_opts = {border = "rounded"}})<CR>', opts)
  buf_set_keymap("n", "<space>lk", '<cmd>lua vim.diagnostic.goto_prev({popup_opts = {border = "rounded"}})<CR>', opts)
  buf_set_keymap("n", "K", "<Cmd>lua vim.lsp.buf.hover()<CR>", opts)
  buf_set_keymap("n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)

  buf_set_keymap("n", "<space>lf", "<cmd>lua  vim.lsp.buf.format { async = true }<CR>", opts)
  -- vim.api.nvim_command([[augroup Format]])
  -- vim.api.nvim_command([[autocmd! * <buffer>]])
  -- vim.api.nvim_command([[autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_seq_sync()]])
  -- vim.api.nvim_command([[augroup END]])
end

M.on_attach = function(client, bufnr)
  if client.name == "tsserver" then
    client.server_capabilities.document_formatting = false
  end
  lsp_keymaps(bufnr)
  lsp_highlight_document(client)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()

local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not status_ok then
  return
end

M.capabilities = cmp_nvim_lsp.update_capabilities(capabilities)

return M
