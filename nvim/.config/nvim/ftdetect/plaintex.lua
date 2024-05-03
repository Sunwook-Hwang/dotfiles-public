vim.cmd([[ au BufRead,BufNewFile *.tex set filetype=tex ]])
vim.cmd([[autocmd FileType tex setlocal shiftwidth=2 expandtab tabstop=2]])
