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


  if s:has_git_switch()
    silent let l:result = system('git switch ' .. a:branch)
  else
    silent let l:result = system('git checkout ' .. a:branch)
    if v:shell_error != 0
      silent let l:result = system('git checkout -b ' .. a:branch)
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

" check if git switch command exists
function! s:has_git_switch() abort
  call system('git switch --help > /dev/null 2>&1')
  return v:shell_error == 0
endfunction

" get branches
function! s:branches () abort

  if !s:is_in_git_repo()
    throw "not in git repo"
  endif

  let l:current = trim(substitute(
        \  get(filter(split(system('git branch'), '\n'), {_, val -> match(val, '\*') != -1}), 0, '')
        \  , '\s*\*\s*', '', ''))
  let l:remote = filter(split(system('git branch -r'), '\n'), {_, val -> match(val, 'HEAD') == -1 || match(val, l:current) == -1})
  let l:local = filter(split(system('git branch'), '\n'), {_, val -> match(val, '\*') == -1 || match(val, l:current) == -1})

  return s:add_label(l:remote, 'remote') + s:add_label(l:local, 'local')
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
