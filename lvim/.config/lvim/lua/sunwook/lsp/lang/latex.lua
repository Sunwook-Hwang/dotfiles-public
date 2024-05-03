local M = {}

M.setup = function()
  vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "texlab" })

  local capabilities = require("lvim.lsp").common_capabilities()

  require("lvim.lsp.manager").setup("texlab", {
    on_attach = require("lvim.lsp").common_on_attach,
    on_init = require("lvim.lsp").common_on_init,
    capabilities = capabilities,
  })
  -- Setup formatters.
  local formatters = require "lvim.lsp.null-ls.formatters"
  formatters.setup {
    { command = "latexindent", filetypes = { "tex" } },
  }
  -- latex settings
  vim.cmd [[
if has("mac")
  let g:latex_view_general_viewer = "skim"
  let g:vimtex_view_method = "skim"
  let g:vimtex_compiler_latexmk = {
        \ 'build_dir' : '',
        \ 'callback' : 1,
        \ 'continuous' : 1,
        \ 'executable' : 'latexmk',
        \ 'hooks' : [],
        \ 'options' : [
          \   '-verbose',
          \   '-shell-escape',
          \   '-file-line-error',
          \   '-synctex=1',
          \   '-interaction=nonstopmode',
          \ ],
          \}
endif
]]
  vim.g.vimtex_quickfix_open_on_warning = 0
end

vim.g.maplocalleader = ";"

-- M.keymaps = function(opts)
--   if opts then
--     opts = opts
--   else
--     opts = {}
--   end

--   local wkl = require "which-key"

--   wkl.register({
--     ["n"] = {
--       name = "LaTeX",
--       m = { "<cmd>VimtexContextMenu<CR>", "Open Context Menu" },
--       u = { "<cmd>VimtexCountLetters<CR>", "Count Letters" },
--       w = { "<cmd>VimtexCountWords<CR>", "Count Words" },
--       d = { "<cmd>VimtexDocPackage<CR>", "Open Doc for package" },
--       e = { "<cmd>VimtexErrors<CR>", "Look at the errors" },
--       s = { "<cmd>VimtexStatus<CR>", "Look at the status" },
--       a = { "<cmd>VimtexToggleMain<CR>", "Toggle Main" },
--       v = { "<cmd>VimtexView<CR>", "View pdf" },
--       i = { "<cmd>VimtexInfo<CR>", "Vimtex Info" },
--       l = {
--         name = "Clean",
--         l = { "<cmd>VimtexClean<CR>", "Clean Project" },
--         c = { "<cmd>VimtexClean<CR>", "Clean Cache" },
--       },
--       c = {
--         name = "Compile",
--         c = { "<cmd>VimtexCompile<CR>", "Compile Project" },
--         o = {
--           "<cmd>VimtexCompileOutput<CR>",
--           "Compile Project and Show Output",
--         },
--         s = { "<cmd>VimtexCompileSS<CR>", "Compile project super fast" },
--         e = { "<cmd>VimtexCompileSelected<CR>", "Compile Selected" },
--       },
--       r = {
--         name = "Reload",
--         r = { "<cmd>VimtexReload<CR>", "Reload" },
--         s = { "<cmd>VimtexReloadState<CR>", "Reload State" },
--       },
--       o = {
--         name = "Stop",
--         p = { "<cmd>VimtexStop<CR>", "Stop" },
--         a = { "<cmd>VimtexStopAll<CR>", "Stop All" },
--       },
--       t = {
--         name = "TOC",
--         o = { "<cmd>VimtexTocOpen<CR>", "Open TOC" },
--         t = { "<cmd>VimtexTocToggle<CR>", "Toggle TOC" },
--       },
--     },
--   }, opts)
-- end

return M
