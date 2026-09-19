" Keep upstream rendering, but reserve the source window's winbar row.
let s:original_redraw = funcref('context#popup#nvim#redraw')
function! context#popup#nvim#redraw(winid, popup, lines) abort
    call s:original_redraw(a:winid, a:popup, a:lines)
    let info = getwininfo(a:winid)[0]
    call nvim_win_set_config(a:popup, {
                \ 'relative': 'editor',
                \ 'row': info.winrow - 1 + info.winbar, 'col': info.wincol - 1,
                \ })
endfunction
