let s:save_cpo = &cpo
set cpo&vim

if exists('g:text_omnicomplete#enable_plugin')
        \ && g:text_omnicomplete#enable_plugin == 0
    finish
endif

if !exists('g:text_omnicomplete#max_bigram_results')
    let g:text_omnicomplete#max_bigram_results = 300
endif

if !exists('g:text_omnicomplete#max_total_results')
    let g:text_omnicomplete#max_total_results = 600
endif

" Main function for completion - the omnifunc.
" See ':help complete-functions' for the specification of this function.
function! text_omnicomplete#OmniComplete(findstart, base)
    " Locate the start of the word.
    let line = getline('.')
    let start_of_word = col('.') - 1
    while start_of_word > 0 && line[start_of_word - 1] =~ '\w'
        let start_of_word -= 1
    endwhile

    if a:findstart
        return start_of_word
    else
        return s:get_completions(a:base, line, start_of_word)
    endif
endfun

" Returns a list of suggested completions.
function! s:get_completions(base, cur_line, start_of_word)
    " Check if the first letter of the curent prefix is a capital letter.
    let first_letter = strpart(a:base, 0, 1)
    let first_letter_is_upper = first_letter =~# '[A-Z]'

    " Try to locate the start of the previous whole word on the current line.
    let start_of_previous_word = a:start_of_word - 1
    while start_of_previous_word > 0
            \ && a:cur_line[start_of_previous_word - 1] =~ '\a'
        let start_of_previous_word -= 1
    endwhile
    " Is there a previous word on the current line?
    let cur_line_has_previous_word = 1
    if start_of_previous_word == a:start_of_word - 1  " If not found on current line.
        let cur_line_has_previous_word = 0
    endif

    if cur_line_has_previous_word == 1
        " A previous word has been found on the current line.
        let has_previous_word = 1
        let previous_word = strpart(
                        \ a:cur_line,
                        \ start_of_previous_word,
                        \ a:start_of_word - start_of_previous_word - 1)
    else
        " No previous word on current line was found, so now try to find one
        " on the line above the current line.
        let cur_line_num = line('.')
        if cur_line_num == 1  " User is on the first line; there is no line above.
            let has_previous_word = 0
        else  " There is a line above.
            " Try to find the last word in the line above by scanning from
            " the end of the line.
            let prev_line = getline(cur_line_num - 1)
            " Skip trailing whitespace to find the end of the last word on the
            " line.
            let end_of_previous_word = len(prev_line)
            while end_of_previous_word > 0
                    \ && prev_line[end_of_previous_word - 1] =~ '\s'
                let end_of_previous_word -= 1
            endwhile
            " Find the start of the last word on the line.
            let start_of_previous_word = end_of_previous_word
            while start_of_previous_word > 0
                    \ && prev_line[start_of_previous_word - 1] =~ '\a'
                let start_of_previous_word -= 1
            endwhile

            if start_of_previous_word == end_of_previous_word
                " No non-whitespace characters found.
                let has_previous_word = 0
            else
                let has_previous_word = 1
                let previous_word = strpart(
                        \ prev_line,
                        \ start_of_previous_word,
                        \ end_of_previous_word - start_of_previous_word)
            endif
        endif
    endif

    let results = []
    " If a previous word is available, insert suggestions based on 2-grams.
    let num_bigram_results = 0
    if has_previous_word == 1
        for word in text_omnicomplete_data#get_bigram_matches(tolower(previous_word))
            if word =~? '^' . a:base
                " Capitalize word if user has entered a prefix that starts
                " with a capital letter.
                if first_letter_is_upper == 1
                    let word = first_letter . strpart(word, 1)
                endif
                call add(results, {'word': word, 'menu': '[bigram]'})
                let num_bigram_results += 1
            endif

            " Stop adding bigram results when the user-specified number of
            " results has been reached.
            if num_bigram_results >= g:text_omnicomplete#max_bigram_results
                break
            endif
        endfor
    endif

    " Insert suggestions based on word frequency (1-grams).
    let num_results = num_bigram_results
    for suffix_candidate in text_omnicomplete_data#get_prefix_matches(tolower(a:base))
        " Stop adding results when the user-specified number of results
        " has been reached.
        if num_results >= g:text_omnicomplete#max_total_results
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
