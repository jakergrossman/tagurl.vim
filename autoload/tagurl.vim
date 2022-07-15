" tagurl.vim
" Author:      Jake Grossman <jake.r.grossman@gmail.com>
" Last Change: July 15, 2022
" License:     Unlicense (See LICENSE.txt)

if exists('g:loaded_tagurl')
    finish
endif
let g:loaded_tagurl = 1

function! s:echo_verbose(msg) abort
    if g:tagurl_verbose == v:true
        unsilent echomsg a:msg
    endif
endfunction

function! s:echo_err(msg) abort
    echohl ErrorMsg
    echomsg a:msg
    echohl None
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

function! s:gen_url(help_file, tag_text)
    if g:tagurl_neovim
        let URL = 'https://neovim.io/doc/user/' . substitute(a:help_file, '\.txt$', '', '') . '.html#' . a:tag_text
    else
        let URL = 'https://vimhelp.org/' . a:help_file . '.html#' . a:tag_text
    endif

    return URL
endfunction

" Corresponding function for :TagURL command
"
" Takes a potential tag as input. If a help
" page is found for that tag, it will
" construct a vimhelp.org URL for that tag
" and copy it to the destination register
function! tagurl#tagurl(tag, ...) abort
    " open help for tag
    try
        " open new help buffer and force buftype
        " so help opens in that buf
        exec 'vsplit | enew | set buftype=help | help ' . a:tag
    catch
        " error! close opened help
        helpclose

        call s:echo_err(substitute(v:exception, '^Vim(help):', '', ''))

        return
    endtry

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

    helpclose

    " construct URL
    let URL = s:gen_url(help_file, tag_text)

    " register specified?
    if a:0 > 0
        let reg = '@' . a:1
    else
        let reg = '@' . g:tagurl_default_reg
    endif

    if !has('clipboard') && reg =~? '@[*+]'
        call s:echo_err('Your version of Vim does not support copying to the clipboard, specify a register: TagURL <tag> <register>')
    else
        exec 'let ' . reg . '="' . URL . '"'
        call s:echo_verbose('Copied ' . URL . ' to ' . reg)
    endif
endfunction
