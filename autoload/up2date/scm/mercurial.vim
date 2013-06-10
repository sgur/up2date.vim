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
  return '--encoding utf-8 --color false'
endfunction


function! s:SID_PREFIX()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:SID_PREFIX()


function! s:pull(temp_name) dict
  if getfsize(a:temp_name) > 0
    let rev = system(join([s:exec(), s:arguments()
          \ , '--cwd "'.expand(self.cwd).'"'
          \ , 'log', '--template ''{rev}''', '-l 1']))
    let status = system(join([s:exec(), s:arguments()
          \ , '--cwd "'.expand(self.cwd).'"'
          \ , 'pull', '--update']))
    let changes = system(join([s:exec(), s:arguments()
          \ , '--cwd "'.expand(self.cwd).'"'
          \ , 'log', '--rev', rev.'..tip'
          \ , '--template ''{node|short} {desc|strip|firstline}\n''']))
    let msg = []
    for s in split(status, '\n')
      call add(msg, '    '.s)
    endfor
    for c in changes
      call add(msg, '- '.c)
    endfor
    call up2date#log#msg('update[mercurial] -> '.self.cwd, msg)
  else
    call up2date#log#log('update[mercurial] -> '.self.cwd.' (no update)')
  endif
endfunction


function! s:clone(temp_name) dict
  let msg = []
  call up2date#log#msg('checkout[mercurial] -> '.self.cwd, '(new)')
endfunction


function! up2date#scm#mercurial#update(branch, revision, dir)
  if !executable(s:exec())
    echoerr 'Up2date: "'.s:exec().'" command not found.'
  endif
  if !empty(a:revision)
    call system(join([s:exec(), 'pull', '--update', '-rev '.a:revision]))
    return
  elseif !empty(a:branch)
    call system(join([s:exec(), 'checkout', a:branch]))
  endif
  let cmd = join([s:exec(), s:arguments(), '--cwd "'.expand(a:dir).'"', 'incoming', '-q'])
  let env = {
        \ 'cwd' : a:dir,
        \ 'get' : function(s:SID.'pull'),
        \ }
  call up2date#worker#asynccommand(cmd, env)
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
        \ 'get' : function(s:SID.'clone'),
        \ 'is_checkout' : 1,
        \ }
  call up2date#worker#asynccommand(cmd, env)
endfunction

