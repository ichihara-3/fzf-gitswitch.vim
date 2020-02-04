" Vim global plugin for switching git branch with fzf
" Last Change:	2020 Feb 04
" Maintainer:	ichi_taro3 <taro3.ichi@gmail.com>
" License:	This file is placed in the public domain.

let s:save_cpo = &cpoptions
set cpoptions&vim

if exists('g:loaded_fzf_gs')
  finish
endif

let g:loaded_fzf_gs = 1

command! -nargs=0 Branches call fzf_gs#git_switch_with_fzf()
nmap <Plug>(fzf_gs) :<C-u>call fzf_gs#git_switch_with_fzf()<CR>

let &cpoptions = s:save_cpo
unlet s:save_cpo
