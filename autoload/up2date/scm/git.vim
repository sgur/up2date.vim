"=============================================================================
" FILE: autoload/up2date/scm/git.vim
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
