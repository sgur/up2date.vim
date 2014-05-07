"=============================================================================
" FILE: autoload/up2date/scm/git.vim
" AUTHOR: sgur <sgurrr+vim@gmail.com>
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim


function! s:exec()
  return get(g:, 'up2date_git_executable', 'git')
endfunction


function! s:SID_PREFIX()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:SID_PREFIX()


function! s:expand(path)
  return substitute(expand(a:path), '\\', '/', 'g')
endfunction


function! s:shallow_opt()
  return get(g:, 'up2date_git_use_shallow', 0)
        \ ? '--depth=1'
        \ : ''
endfunction

function! s:pull(result, status, user)
  if !empty(a:result) && stridx(a:result[-1], 'up-to-date') == -1
    let msg = map(a:result, 'repeat(" ", 4) . v:val')
    call up2date#log#msg('update[git] -> '.a:user.cwd, msg)
  else
    call up2date#log#log('update[git] -> '.a:user.cwd.' (no update)')
  endif
  call up2date#run()
endfunction


function! s:checkout(result, status, user)
  call up2date#log#msg('checkout[git] -> ' . a:user.cwd . '(new)', '')
  call up2date#util#add_runtimepath(a:user.cwd)
  call up2date#util#source_plugin(a:user.cwd)
  call up2date#util#helptags(a:user.cwd)
  call up2date#run()
endfunction


function! up2date#scm#git#update(branch, revision, dir)
  if !executable(s:exec())
    echoerr 'Up2date: "'.s:exec().'" command not found.'
  endif
  let cmds = []
  let env =
        \ { 'cwd'  : a:dir
        \ }
  if !empty(a:revision)
    call up2date#shell#system(join([s:exec()
          \ , 'checkout', '-q', a:revision])
          \ , s:SID . 'pull', env)
    return
  elseif !empty(a:branch)
    call add(cmds, join([s:exec()
          \ , 'checkout', '-q', a:branch]))
  else
    call add(cmds, join([s:exec()
          \ , 'checkout', '-q', 'master']))
  endif
  call add(cmds, join([s:exec()
        \ , 'pull', '--verbose', '--recurse-submodules', s:shallow_opt()]))
  call up2date#shell#system(cmds, s:SID . 'pull', env)
endfunction


function! up2date#scm#git#checkout(url, branch, revision, dir)
  if !executable(s:exec())
    echoerr 'Up2date: "'.s:exec().'" command not found.'
  endif
  let opt = '--recurse-submodules ' . (!empty(a:branch) ? '--branch '.a:branch : '')
  let cmds = [join([s:exec(), 'clone', opt, s:shallow_opt(), a:url, a:dir])
        \ , join([s:exec(), 'checkout', a:revision])]
  let env = {
        \ 'cwd' : a:dir,
        \ 'rev' : a:revision,
        \ 'is_checkout' : 1,
        \ }
  call up2date#shell#system(cmds, s:SID . 'checkout', env)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
