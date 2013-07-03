"=============================================================================
" FILE: up2date/scm/subversion.vim
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

function! s:exec()
  return get(g:, 'up2date_subversion_executable', 'svn')
endfunction


function! s:SID_PREFIX()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:SID_PREFIX()


function! s:update(result, status, user)
  if !empty(a:result)
    let msg = []
    for l in a:result
      call add(msg, '> ' . l)
    endfor
    call up2date#log#msg('update[subversion] -> ' . a:user.cwd, msg)
  else
    call up2date#log#log('update[subversion] -> ' . a:user.cwd . ' (no update)')
  endif
  call up2date#run()
endfunction


function! s:checkout(result, status, user)
  call up2date#log#msg('checkout[subversion] -> ' . a:user.cwd, '(new)')
  call up2date#run()
endfunction


function! up2date#scm#subversion#update(branch, revision, dir)
  let cmds = []
  if !executable(s:exec())
    echoerr 'Up2date: "'.s:exec().'" command not found.'
  endif
  if !empty(a:branch)
    call add(cmds, join([s:exec(), 'switch', a:branch]))
  endif
  let opt = '--quiet'
        \ . (!empty(a:revision) ? '--revision '. a:revision : '')
  call add(cmds, join([s:exec(), 'update', opt, a:dir]))
  let env = {
        \ 'cwd' : a:dir
        \ }
  call up2date#shell#system(cmds, s:SID . 'update', env)
endfunction


function! up2date#scm#subversion#checkout(url, branch, revision, dir)
  if !executable(s:exec())
    echoerr 'Up2date: "'.s:exec().'" command not found.'
  endif
  let opt = !empty(a:revision) ? '--revision '.a:revision : ''
  let cmd = join([s:exec(), 'checkout', opt, a:url, a:dir])
  let env = {
        \ 'cwd' : a:dir,
        \ 'is_checkout' : 1,
        \ }
  call up2date#shell#system(cmd, s:SID . 'checkout', env)
endfunction

