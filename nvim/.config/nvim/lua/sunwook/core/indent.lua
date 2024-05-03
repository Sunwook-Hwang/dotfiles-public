-- Setup indent

vim.g.indent_blankline_char = "│" -- "|"
vim.g.indent_blankline_filetype_exclude = { "help", "packer", "dashboard" }
vim.g.indent_blankline_buftype_exclude = { "terminal", "nofile" }
vim.g.indent_blankline_char_highlight = "LineNr"
vim.g.indent_blankline_show_trailing_blankline_indent = false

local status_ok, indent = pcall(require, "indent_blankline")
if not status_ok then
  return
end

indent.setup({})
