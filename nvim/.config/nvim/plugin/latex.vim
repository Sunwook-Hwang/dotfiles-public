if has("mac")
  let g:latex_view_general_viewer = "skim"
  let g:vimtex_view_method = "skim"
  let g:vimtex_quickfix_open_on_warning = 0
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

if has("wsl")
  " let g:latex_view_general_viewer = "skim"
  " let g:vimtex_view_method = "skim"
  let g:vimtex_quickfix_open_on_warning = 0
endif
