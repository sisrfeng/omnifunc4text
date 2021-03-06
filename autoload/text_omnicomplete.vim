let s:save_cpo = &cpo
set cpo&vim

if exists('g:text_omnicomplete_enable_plugin')
        \ && g:text_omnicomplete_enable_plugin == 0
    finish
endif

if !exists('g:text_omnicomplete_max_bigram_results')
    let g:text_omnicomplete_max_bigram_results = 300
endif

if !exists('g:text_omnicomplete_max_total_results')
    let g:text_omnicomplete_max_total_results = 600
endif

if !exists('g:text_omnicomplete_bigram_indicator')
    let g:text_omnicomplete_bigram_indicator = '*'
endif

" Main function for completion - the omnifunc.
" See ':help complete-functions' for the specification of this function.
function! text_omnicomplete#OmniComplete(findstart, base)
    " Locate the start column of the word.
    let start_of_word = searchpos('\s', 'Wnb', line('.'))[1]
    if a:findstart
        return start_of_word
    else
        return s:get_completions(a:base, start_of_word)
    endif
endfun

" Get the first word before the given column on the given line.
" Returns '' if there is no such word.
function! s:get_previous_word(line, start_col)
    " Search the current line and if there is no word, try the line above
    " (only two lines are searched).
    let orig_line = line('.')
    let orig_col = col('.')
    call cursor(a:line, a:start_col)
    let stopline = a:line > 1 ? a:line - 1 : 1
    let [match_line, match_col] = searchpos('\S\+', 'Wnb', stopline)
    call cursor(orig_line, orig_col)  " Restore cursor position.
    if [match_line, match_col] == [0, 0]
        return ''
    endif
    return matchstr(getline(match_line), '\S\+', match_col - 1)
endfunction

" Returns a list of suggested completions.
function! s:get_completions(base, start_of_word)
    " Check if the first letter of the curent prefix is a capital letter.
    let first_letter = strpart(a:base, 0, 1)
    let first_letter_is_upper = first_letter =~# '[A-Z]'

    let results = []

    " If a previous word is available, insert suggestions based on 2-grams.
    let num_bigram_results = 0
    let previous_word = s:get_previous_word(line('.'), a:start_of_word)
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
