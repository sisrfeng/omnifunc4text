if exists('g:text_omnicomplete_enable_plugin')
    if g:text_omnicomplete_enable_plugin == 0  | finish  | en
en

au FileType  text       setl  omnifunc=text_omnicomplete#Complete
            "\ 没有text这个filetype吧

com!  TextOmnicompleteBuild call text_omnicomplete#Build()
