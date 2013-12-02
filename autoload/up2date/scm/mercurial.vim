"=============================================================================
" FILE: autoload/up2date/scm/mercurial.vim
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
  return get(g:, 'up2date_mercurial_executable', 'hg')
endfunction


function! s:arguments()
  return '--encoding utf-8 --config color.mode=false'
endfunction


function! s:SID_PREFIX()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:SID_PREFIX()


function! s:pull(result, status, user)
  if len(a:result) > 0
    let rev = system(join([s:exec(), s:arguments()
          \ , 'log', '--template ''{rev}''', '-l 1']))
    let status = system(join([s:exec(), s:arguments()
          \ , 'pull', '--update']))
    let changes = system(join([s:exec(), s:arguments()
          \ , 'log', '--rev', rev.'..tip'
          \ , '--template ''{node|short} {desc|strip|firstline}\n''']))
    let msg = map(a:result, 'repeat(" ", 4) . v:val')
    for c in changes
      call add(msg, '- '.c)
    endfor
    call up2date#log#msg('update[mercurial] -> '.a:user.cwd, msg)
  else
    call up2date#log#log('update[mercurial] -> '. a:user.cwd .' (no update)')
  endif
  call up2date#run()
endfunction


function! s:clone(result, status, user)
  let msg = []
  call up2date#log#msg('checkout[mercurial] -> '.a:user.cwd, '(new)')
  call up2date#run()
endfunction


function! up2date#scm#mercurial#update(branch, revision, dir)
  if !executable(s:exec())
    echoerr 'Up2date: "'.s:exec().'" command not found.'
  endif
  let env = {'cwd' : a:dir }
  let cmds = []
  if !empty(a:revision)
    call up2date#shell#system(join([s:exec(), 'pull', '--update', '-rev '.a:revision])
          \ , s:SID . 'pull', env)
    return
  elseif !empty(a:branch)
    call add(cmds, join([s:exec(), 'checkout', a:branch]))
  endif
  call add(cmds, join([s:exec(), s:arguments(), 'incoming', '-q']))
  call up2date#shell#system(cmds, s:SID . 'pull', env)
endfunction


function! up2date#scm#mercurial#checkout(url, branch, revision, dir)
  if !executable(s:exec())
    echoerr 'Up2date: "'.s:exec().'" command not found.'
  endif
  let opt = !empty(a:revision)
        \ ? ' --rev '.a:revision
        \ : (!empty(a:branch) ? ' --branch '.a:branch : '')
  let cmd = join([s:exec(), s:arguments(), 'clone', opt, a:url, a:dir])
  let env = {
        \ 'cwd' : a:dir,
        \ 'is_checkout' : 1,
        \ }
  call up2date#shell#system(cmd, s:SID . 'clone', env)
endfunction

