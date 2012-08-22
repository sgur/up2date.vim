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


let s:workers = 0

let s:cb_base = {
      \ 'cwd' : '',
      \ }

function! s:cb_base.get(temp_name) dict
  if getfsize(a:temp_name) > 0
    lcd `=self.cwd`
    echomsg 'git pull:' getcwd()
    let hash = split(system(join([s:exec(), 'log', '--oneline', '-1', '--format=%h'])))[0]
    call system(join([s:exec(), 'rebase', '-f', 'origin']))
    echo system(join([s:exec(), 'log', '--oneline', hash.'..HEAD']))
  endif
  let s:workers -= 1
endfunction



function! s:check_update()
  while s:workers >= 4
    sleep 100m
  endwhile
  let s:workers += 1
  let cmd = join([s:exec(), 'fetch'])
  " let Fn = function('up2date#scm#git#do_update')
  let cb = copy(s:cb_base)
  let cb.cwd = getcwd()
  if exists('g:loaded_asynccommand')
    echomsg 'git fetch:' getcwd()
    call asynccommand#run(cmd, cb)
  else
    let log = system(cmd)
    let tempfile = tempname()
    try
      call writefile(split(log), tempfile) 
      call cb.get(tempfile)
    catch
    finally
      call delete(tempfile)
    endtry
  endif
endfunction


function! up2date#scm#git#update(branch, revision)
  if !empty(a:branch)
    call system(join([s:exec(), 'checkout', a:branch]))
  endif
  if !empty(a:revision)
    call system(join([s:exec(), 'checkout', a:revision]))
  else
    call s:check_update()
  endif
endfunction


function! up2date#scm#git#checkout(url, branch, revision, target)
  echomsg 'git clone' 'at' getcwd()
  let opt = !empty(a:branch) ? '--branch '.a:branch : ''
  echo system(join([s:exec(), 'clone', opt, a:url, a:target]))
  if !empty(a:revision)
    echo system(join([s:exec(), 'checkout', opt, a:revision]))
  endif
endfunction
