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
