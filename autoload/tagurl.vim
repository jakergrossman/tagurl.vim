" tagurl.vim
" Author:      Jake Grossman <jake.r.grossman@gmail.com>
" Last Change: September 6, 2021
" License:     MIT (See LICENSE.txt)

if exists('g:loaded_tagurl')
    finish
endif
let g:loaded_tagurl = 1

" returns a list of buffer #s
" that have a 'help' buftype and
" whether or not they are loaded
function! s:poll_buffers() abort
    let l:ret = []
    for b in getbufinfo()
        if getbufvar(b.bufnr, '&buftype') ==? 'help'
            let l:ret += [[b.bufnr,b.loaded]]
        endif
    endfor
    return l:ret
endfunction

" Escape text for use in a URL
function! s:url_escape(text) abort
    " it is important that % is first
    " otherwise, previously escaped characters
    " will have their % escaped
    let conversion_table = [
                \ ['%',  '%25'],
                \ ['#',  '%23'],
                \ ['$',  '%24'],
                \ ['&',  '%26'],
                \ ['''', '%27'],
                \ ['(',  '%28'],
                \ [')',  '%29'],
                \ ['*',  '%2A'],
                \ ['+',  '%2B'],
                \ [',',  '%2C'],
                \ ['-',  '%2D'],
                \ ['/',  '%2F'],
                \ [':',  '%3A'],
                \ [';',  '%3B'],
                \ ['<',  '%3C'],
                \ ['=',  '%3D'],
                \ ['>',  '%3E'],
                \ ['?',  '%3F'],
                \ ['@',  '%40'],
                \ ['[',  '%5B'],
                \ ['\',  '%5C'],
                \ [']',  '%5D'],
                \ ['^',  '%5E'],
                \ ['`',  '%60'],
                \ ['{',  '%7B'],
                \ ['|',  '%7C'],
                \ ['}',  '%7D'],
                \ ['~',  '%7E'],
            \ ]

    let escaped_text = a:text

    " escape any special characters
    for c in conversion_table
        let escaped_text = substitute(escaped_text, '\v\' . c[0], c[1], 'g')
    endfor

    return escaped_text
endfunction

" Corresponding function for :TagURL command
"
" Takes a potential tag as input. If a help
" page is pulled up for that tag, it will
" copy the vimhelp.org URL for that tag
" to the clipboard
function! tagurl#tagurl(tag, ...) abort
    " open help for tag
    try
        let l:help_bufs = s:poll_buffers()
        let l:old_buf = -1
        if len(l:help_bufs) != 0
            for buf in l:help_bufs
                if buf[1] == 1
                    " there's an open help window
                    let l:old_buf = buf[0]
                    break
                endif
            endfor
        endif

        silent exec 'help ' . a:tag

        " no error, found tag
        "
        " found tag may differ, so make
        " sure to use <cword>
        "
        " e.g. ':h command' will go to ':command'
        let tag_text = expand('<cword>')

        " escape for use in URL
        let tag_text = s:url_escape(tag_text)

        " get name of help file
        let help_file = expand('%:t')

        " close opened help page
        if l:old_buf > 0
            silent exec "buffer " . l:old_buf
        else
            helpclose
        endif

        " construct URL
        let URL = 'https://vimhelp.org/' . help_file . '.html#' . tag_text
    catch
        if g:tagurl_verbose == v:true
            " 'Error' message on single line
            echohl ErrorMsg

            " remove "Vim(help):" prefix
            unsilent echom substitute(v:exception, '^Vim(help):', '', '')

            " reset
            echohl None
        endif

        return
    endtry

    " only update clipboard for a successful search

    " register specified?
    if a:0 > 0
        let reg = '@' . a:1
    else
        let reg = '@' . g:tagurl_default_reg
    endif

    exec 'let ' . reg . '="' . URL . '"'

    if g:tagurl_verbose == v:true
        echom 'Copied ' . URL . ' to ' . reg
    endif
endfunction
