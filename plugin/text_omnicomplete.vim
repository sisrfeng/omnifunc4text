if exists('g:text_omnicomplete_enable_plugin')
    if g:text_omnicomplete_enable_plugin == 0
        finish
    endif
endif

autocmd FileType text setlocal omnifunc=text_omnicomplete#Complete

command! TextOmnicompleteBuild call text_omnicomplete#Build()
