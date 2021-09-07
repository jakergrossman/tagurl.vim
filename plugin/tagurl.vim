" tagurl.vim
" Author:      Jake Grossman <jake.r.grossman@gmail.com>
" Last Change: September 6, 2021
" License:     MIT (See LICENSE.txt)

" save vi compatibility options
let s:cpo_save = &cpo
set cpo&vim

" Set default options, if not set
let s:def_options = [
   \['g:tagurl_map',             '<C-k>'],
   \['g:tagurl_enable_mapping',  v:true],
   \['g:tagurl_default_reg',     '+'],
   \['g:tagurl_verbose',         v:true],
\]

for opt in s:def_options
    " check if option is already set
    if !exists(opt[0])
        " set to default if not set
        exec 'let ' . opt[0] . '="' . opt[1] . '"'
    endif
endfor

" Define command
command! -nargs=* TagURL call tagurl#tagurl(<f-args>)

" Define mapping, if enabled
if g:tagurl_enable_mapping == v:true && !empty(g:tagurl_map)
    exec 'nnoremap ' . g:tagurl_map . ' :exec "TagURL " . expand("<cword>")<CR>'
endif

" restore vim compatibility options
let &cpo = s:cpo_save
unlet s:cpo_save
