"=============================================================================
" FILE: up2date/scm/subversion.vim
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
  return get(g:, 'up2date_subversion_executable', 'svn')
endfunction


function! s:SID_PREFIX()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:SID_PREFIX()


function! s:update(temp_name) dict
  let lines = split(readfile(a:temp_name))
  if !empty(lines)
    echohl Title
    echomsg 'update[subversion]' '->' self.cwd
    echohl None
    for l in lines
      echo lines
    endfor
  else
    echo 'update[subversion]' '->' self.cwd '(no update)'
  endif
endfunction


function! s:checkout(temp_name) dict
  echomsg 'checkout[subversion]' '->' self.cwd
endfunction


function! up2date#scm#subversion#update(branch, revision)
  if !empty(a:branch)
    echo system(join([s:exec(), 'switch', a:branch]))
  endif
  let opt = !empty(a:revision) ? '--revision '.a:revision : ''
  let cmd = join([s:exec(), 'update', opt])
  let env = {
        \ 'cwd' : getcwd(),
        \ 'get' : function(s:SID.'update'),
        \ }
  call up2date#worker#asynccommand(cmd, env)
endfunction


function! up2date#scm#subversion#checkout(url, branch, revision, target)
  let opt = !empty(a:revision) ? '--revision '.a:revision : ''
  let cmd = join([s:exec(), 'checkout', opt, a:url, a:target])
  let env = {
        \ 'cwd' : expand(getcwd().'/'.a:target),
        \ 'get' : function(s:SID.'checkout'),
        \ 'is_checkout' : 1,
        \ }
  call up2date#worker#asynccommand(cmd, env)
endfunction

