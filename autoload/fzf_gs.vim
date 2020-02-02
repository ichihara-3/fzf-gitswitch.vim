" switch branch with fzf window
function! fzf_gs#git_switch_with_fzf ()
  let l:cwd = getcwd()
  let l:changeto = expand('%:p:h')
  call chdir(l:changeto)

  try
    let l:branches = s:branches()
    call fzf#run(fzf#wrap({
    \ 'source': l:branches,
    \ 'sink': function('s:switch')
    \ }))
  catch
    echohl Warningmsg
    echomsg "the file may not in a git repo"
    echohl None
  finally
    call chdir(l:cwd)
  endtry
endfunction

function! s:switch(line) abort
  let l:branch = s:get_branchname(a:line)
  call s:git_switch(l:branch)
endfunction


function! s:git_switch (branch) abort
  if s:buffer_modified()
    echohl Warningmsg
    echomsg 'some buffers has changed. save or discard them.'
    echohl None
    return
  endif

  silent let l:result = system('git switch ' .. a:branch)
  if v:shell_error != 0
    silent let l:result = system('git checkout ' .. a:branch)
    if v:shell_error != 0
      silent let l:result = system('git -b checkout ' .. a:branch)
    endif
  endif
  if v:shell_error == 0
    if s:buffer_exists()
      bufdo edit!
    endif
    echomsg 'switched to ::' .. a:branch
  else
    echohl Warningmsg
    echomsg l:result
    echohl None
  endif
endfunction

" check if buffers exist
function! s:buffer_exists()
  return len(filter(filter(range(1, bufnr('$')), 'buflisted(v:val)'), 'bufname(v:val) != ""')) >= 1
endfunction

function! s:buffer_modified ()
  return len(getbufinfo({'bufmodified': 1})) != 0
endfunction

" get branches
function! s:branches () abort

  if !s:is_in_git_repo()
    throw "not in git repo"
  endif

  let l:current = trim(system("git branch --points-at=HEAD --format='%(HEAD)%(refname:lstrip=2)'| sed -n '/^\*/p' | tr -d '*'"))
  let l:remote = system('git branch -r |sed -e "/HEAD/d" -e "/->/d" -e "/' .. escape(l:current, '/') .. '/d"')
  let l:local = system('git branch |sed -e "/\*/d" -e "/' .. escape(l:current, '/') .. '/d"')

  return s:add_label(split(l:remote, '\n'), 'remote') + s:add_label(split(l:local, '\n'), 'local')
endfunction

" add local / remote label
function! s:add_label (branches, label) abort
 return map(copy(a:branches), {_, el -> a:label .. ":\t" .. trim(el)})
endfunction

function! s:is_in_git_repo() abort
  silent let l:result = trim(system("git rev-parse --is-inside-work-tree"))
  return l:result == 'true'
endfunction

function! s:get_branchname(line) abort
  if s:is_remote(a:line)
    let l:separated = split(substitute(a:line, '^remote:\t', '', ''), '/')
    let l:branch = trim(len(l:separated) == 1 ? separated[0] : join(l:separated[1:], '/'))
  else
    let l:branch = trim(substitute(a:line, '^local:\t', '', ''))
  endif
  return l:branch
endfunction

function! s:is_remote(line) abort
  return match(a:line, '^remote:\t') != -1
endfunction
