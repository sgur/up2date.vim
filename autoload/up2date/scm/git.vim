function! s:exec()
  return get(g:, 'up2date_git_executable', 'git')
endfunction


function! up2date#scm#git#update(branch, revision)
  echomsg 'git pull at' getcwd()
  if !empty(a:branch)
    echo system(join([s:exec(), 'checkout', a:branch]))
  endif
  let hash = split(system(join([s:exec(), 'log', '--oneline', '-1', '--format=%h'])))[0]
  echo system(join([s:exec(), 'pull', '--rebase']))
  echo system(join([s:exec(), 'log', '--oneline', hash.'..HEAD']))
endfunction


function! up2date#scm#git#checkout(url, branch, revision, target)
  echomsg 'git clone' 'at' getcwd()
  let opt = !empty(a:branch) ? '--branch '.a:branch : ''
  let cmd = join([s:exec(), 'clone', opt, a:url, a:target])
  echo system(cmd)
  if !empty(a:revision)
    let cmd = join([s:exec(), 'checkout', opt, a:revision])
    echo system(cmd)
  endif
endfunction
