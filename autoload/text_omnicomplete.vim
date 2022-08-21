if exists('g:text_omnicomplete_enable_plugin')
    if g:text_omnicomplete_enable_plugin == 0
        finish
    endif
endif

let s:plugin_root = expand('<sfile>:p:h:h')
let s:this_file   = expand('<sfile>:p')

if !exists('*text_omnicomplete#Build')  " Prevent E127 when re-sourcing.
    function text_omnicomplete#Build() abort
        let save_dir = chdir(s:plugin_root)
        if executable('make')
            let cmd = 'make'
        else
            if executable('python3')
                let l:python = 'python3'
            elseif executable('python2')
                let l:python = 'python2'
            elseif executable('python')
                let l:python = 'python'
            else
                echohl ErrorMsg
                echomsg 'vim-text-omnicomplete: Python executable not found.'
                echohl None
                return
            endif
            let cmd = l:python . ' ' . s:plugin_root . '/build.py'
        endif
        echomsg 'vim-text-omnicomplete: Building ...'
        let output = system(cmd)
        call chdir(save_dir)
        if v:shell_error == 0
            echomsg 'vim-text-omnicomplete: Finished building.'
            execute 'source ' . s:this_file
        else
            echohl ErrorMsg
            echomsg 'Exit code ' . v:shell_error . ': ' . cmd
            echomsg 'Output: ' . output
            echohl None
        endif
    endfunction
endif

if filereadable(expand('<sfile>:p:h') . '/text_omnicomplete_data.vim') == 0
    echohl ErrorMsg
    echomsg 'vim-text-omnicomplete: Build step needed. Run :TextOmnicompleteBuild'
    echohl None
    finish
endif

let s:save_cpo = &cpo
set cpo&vim

let g:text_omnicomplete_max_bigram_results = 300

let g:text_omnicomplete_max_total_results = 600

let g:text_omnicomplete_bigram_indicator = '*'

" Main function for completion - the omnifunc.
" See ':help complete-functions' for the specification of this function.
function! text_omnicomplete#Complete(findstart, base) abort
    " Locate the start column of the word.
    let start_of_word = searchpos('\s', 'Wnb', line('.'))[1]
    if a:findstart
        return start_of_word
    else
        return s:get_completions(a:base, start_of_word)
    endif
endfun

" Get the first word before the given column on the current line.
" Returns '' if there is no such word.
function! s:get_previous_word(start_col)
    " Search the current line and if there is no word, try the line above
    " (only two lines are searched).
    let orig_line = line('.')
    let orig_col = col('.')
    call cursor(orig_line, a:start_col)
    let stopline = orig_line > 1 ? orig_line - 1 : 1
    let [match_line, match_col] = searchpos('\S\+', 'Wnb', stopline)
    call cursor(orig_line, orig_col)  " Restore cursor position.
    if [match_line, match_col] == [0, 0]
        return ''
    endif
    return matchstr(getline(match_line), '\S\+', match_col - 1)
endfunction

" Returns a list of suggested completions.
function! s:get_completions(base, start_of_word)
    if a:base !~? '\m^\a*$'  " If the prefix is not completely alphabetic.
        return []
    endif

    " Check if the first letter of the curent prefix is a capital letter.
    let first_letter = strpart(a:base, 0, 1)
    let first_letter_is_upper = first_letter =~# '[A-Z]'

    let results = []

    " If a previous word is available, insert suggestions based on 2-grams.
    let num_bigram_results = 0
    let previous_word = s:get_previous_word(a:start_of_word)
    if previous_word != ''
        for word in text_omnicomplete_data#get_bigram_matches(tolower(previous_word))
            if stridx(word, tolower(a:base)) == 0
                " Capitalize word if user has entered a prefix that starts
                " with a capital letter.
                if first_letter_is_upper == 1
                    let word = first_letter . strpart(word, 1)
                endif
                call add(results, {
                    \'word': word,
                    \'menu': g:text_omnicomplete_bigram_indicator,
                \})
                let num_bigram_results += 1
            endif

            " Stop adding bigram results when the user-specified number of
            " results has been reached.
            if num_bigram_results >= g:text_omnicomplete_max_bigram_results
                break
            endif
        endfor
    endif

    " Insert suggestions based on word frequency (1-grams).
    let num_results = num_bigram_results
    for suffix_candidate in text_omnicomplete_data#get_prefix_matches(tolower(a:base))
        " Stop adding results when the user-specified number of results
        " has been reached.
        if num_results >= g:text_omnicomplete_max_total_results
            break
        endif

        let word = a:base . suffix_candidate
        " Capitalize word if user has entered a prefix that starts with a
        " capital letter.
        if first_letter_is_upper == 1
            let word = first_letter . strpart(word, 1)
        endif
        call add(results, {'word': word})
        let num_results += 1
    endfor

    return results
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
