"=============================================================================
" FILE: autoload/up2date/scm/mercurial.vim
" AUTHOR: sgur <sgurrr@gmail.com>
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
  return get(g:, 'up2date_mercurial_executable', 'hg --encoding utf-8')
endfunction


function! s:SID_PREFIX()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:SID_PREFIX()


function! s:pull(temp_name) dict
  if getfsize(a:temp_name) > 0
    lcd `=self.cwd`
    let rev = system(join([s:exec(), '--cwd "'.expand(getcwd()).'"',
          \ 'log', '--template ''{rev}''', '-l 1']))
    let status = system(join([s:exec(), '--cwd "'.expand(getcwd()).'"',
          \ 'pull', '--update']))
    let changes = system(join([s:exec(), '--cwd "'.expand(getcwd()).'"',
          \ 'log', '--rev', rev.'..tip',
          \ '--template ''{node|short} {desc|strip|firstline}\n''']))
    let msg = []
    for s in split(status, '\n')
      call add(msg, '    '.s)
    endfor
    for c in changes
      call add(msg, '- '.c)
    endfor
    call up2date#log#log('update[mercurial]' '->' self.cwd, msg)
  endif
endfunction


function! s:clone(temp_name) dict
  let msg = ['checkout[mercurial] -> '.self.cwd]
  call up2date#log#log(fnamemodify(self.cwd, ':t'), msg)
endfunction


function! up2date#scm#mercurial#update(branch, revision)
  if !empty(a:revision)
    echo system(join([s:exec(), 'pull', '--update', '-rev '.a:revision]))
    return
  endif
  if !empty(a:branch)
    echo system(join([s:exec(), 'branch', a:branch]))
  endif
  let cmd = join([s:exec(), '--cwd "'.expand(getcwd()).'"', 'incoming', '-q'])
  let env = {
        \ 'cwd' : getcwd(),
        \ 'get' : function(s:SID.'pull'),
        \ }
  call up2date#worker#asynccommand(cmd, env)
endfunction


function! up2date#scm#mercurial#checkout(url, branch, revision, target)
  let opt = !empty(a:revision)
        \ ? ' --rev '.a:revision
        \ : (!empty(a:branch) ? ' --branch '.a:branch : '')
  let cwd = expand(getcwd().'/'.a:target)
  let cmd = join([s:exec(), 'clone', opt, a:url, cwd])
  let env = {
        \ 'cwd' : cwd,
        \ 'get' : function(s:SID.'clone'),
        \ 'is_checkout' : 1,
        \ }
  call up2date#worker#asynccommand(cmd, env)
endfunction

