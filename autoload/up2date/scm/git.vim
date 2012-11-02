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

let s:save_cpo = &cpo
set cpo&vim


function! s:exec()
  return get(g:, 'up2date_git_executable', 'git')
endfunction


function! s:SID_PREFIX()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction
let s:SID = s:SID_PREFIX()


function! s:pull(temp_name) dict
  let status = readfile(a:temp_name)
  if !empty(status) && stridx(status[0], 'up to date') == -1
    lcd `=self.cwd`
    let changes = split(
          \ system(join([s:exec(),
          \ '--git-dir="'.expand(self.cwd.'/.git').'"',
          \ 'log', '--oneline', self.hash.'..HEAD','--'])),
          \ '\r\n\|\n\|\r')
    let msg = []
    for s in split(status, '\n')
      call add(msg, '    '.s)
    endfor
    for c in changes
      call add(msg, '- '.c)
    endfor
    call up2date#log#log('update[git] -> '.self.cwd, msg)
  endif
endfunction


function! s:checkout(temp_name) dict
  if !empty(self.rev)
    lcd `=self.cwd`
    echo system(join([s:exec(), 'checkout', self.rev]))
  endif
  let msg = ['checkout[git] -> '.self.cwd]
  call up2date#log#log(fnamemodify(self.cwd, ':t'), msg)
endfunction


function! up2date#scm#git#update(branch, revision, dir)
  if !empty(a:branch)
    call system(join([s:exec(), 'checkout', a:branch]))
  endif
  if !empty(a:revision)
    call system(join([s:exec(), 'checkout', a:revision]))
  else
    let hash = split(system(join([s:exec(),
          \ '--git-dir="'.expand(a:dir.'/.git').'"',
          \ 'log', '--oneline', '-1', '--format=%h'])))[0]
    let cmd = join([s:exec(),
          \ '--git-dir="'.expand(a:dir.'/.git').'"',
          \ '--work-tree="'.expand(a:dir).'"',
          \ 'pull', '--rebase'])
    let env = {
          \ 'cwd'  : a:dir,
          \ 'get'  : function(s:SID.'pull'),
          \ 'hash' : hash,
          \ }
    call up2date#worker#asynccommand(cmd, env)
  endif
endfunction


function! up2date#scm#git#checkout(url, branch, revision, dir)
  let opt = !empty(a:branch) ? '--branch '.a:branch : ''
  let cmd = join([s:exec(), 'clone', opt, a:url, a:dir])
  let env = {
        \ 'cwd' : a:dir,
        \ 'rev' : a:revision,
        \ 'get' : function(s:SID.'checkout'),
        \ 'is_checkout' : 1,
        \ }
  call up2date#worker#asynccommand(cmd, env)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
