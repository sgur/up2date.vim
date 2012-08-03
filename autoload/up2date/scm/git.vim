function! s:exec()
  return get(g:, 'up2date_git_executable', 'git')
endfunction


function! up2date#scm#git#update(branch, revision)
  echomsg 'git update' 'at' getcwd()
endfunction


function! up2date#scm#git#checkout(url, branch, revision, target)
  echomsg 'git clone' 'at' getcwd()
  let opt = !empty(a:branch) ? '--branch '.a:branch : ''
  let cmd = join([s:exec(), 'clone', opt, a:url, a:target])
  echomsg 'system' cmd
  if !empty(a:revision)
    let cmd = join([s:exec(), 'checkout', opt, a:revision])
    echomsg 'system' cmd
  endif
endfunction
