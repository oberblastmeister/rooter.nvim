if exists('g:loaded_nvim_rooter') | finish | endif

let s:save_cpo = &cpo
set cpo&vim

command! Root lua require'rooter'.root()

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_nvim_rooter = 1
