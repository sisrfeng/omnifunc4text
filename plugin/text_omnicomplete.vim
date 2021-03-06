if exists('g:text_omnicomplete_enable_plugin')
        \ && g:text_omnicomplete_enable_plugin == 0
    finish
endif

let s:save_cpo = &cpo
set cpo&vim

autocmd FileType text setlocal omnifunc=text_omnicomplete#OmniComplete

let &cpo = s:save_cpo
unlet s:save_cpo
