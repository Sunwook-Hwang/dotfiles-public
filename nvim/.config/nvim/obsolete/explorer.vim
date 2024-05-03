autocmd FileType netrw nnoremap ? :help netrw-quickmap<CR>
" absolute width of netrw window
let g:netrw_winsize = 25

" do not display info on the top of window
let g:netrw_banner = 0

" tree-view
let g:netrw_liststyle = 3

" sort is affecting only: directories on the top, files below
let g:netrw_sort_sequence = '[\/]$,*'

" use the previous window to open file
let g:netrw_browse_split = 4
let g:netrw_localrmdir='rm -r'

let NERDTreeShowHidden=1

function! NERDTreeToggleFind()
  if exists("g:NERDTree") && g:NERDTree.IsOpen()
    NERDTreeClose
  elseif filereadable(expand('%'))
    NERDTreeFind
  else
    NERDTree
  endif
endfunction
