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


function! up2date#scm#subversion#update(branch, revision)
  echomsg 'svn update at' getcwd()
  if !empty(a:branch)
    echo system(join([s:exec(), 'switch', a:branch]))
  endif
  let opt = !empty(a:revision) ? '--revision '.a:revision : ''
  echo system(join([s:exec(), 'update', opt]))
endfunction


function! up2date#scm#subversion#checkout(url, branch, revision, target)
  echomsg 'svn checkout at' getcwd()
  let opt = !empty(a:revision) ? '--revision '.a:revision : ''
  echo system(join([s:exec(), 'checkout', opt, a:url, a:target]))
endfunction

