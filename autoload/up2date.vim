"=============================================================================
" FILE: autoload/up2date.vim
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


function! up2date#update(src)
  let source = s:select_source(a:src)
  if empty(source)
    echoerr 'up2date: source file not found!'
    return
  endif
  let repos = up2date#line#parse_file(source)
  call s:process(repos)
endfunction


" Vim user directory
let s:vim_user_dir = expand((has('win32') || has('win64'))
      \ ? '~/vimfiles/' : '~/.vim/')
" Bundle directory
let s:bundle_dir = s:vim_user_dir.'bundle/'


function! s:select_source(src)
  return empty(a:src)
        \ ? expand(get(g:, 'up2date_source_path', s:default_source_path('~/')))
        \ : (filereadable(expand(a:src)) ? expand(a:src) : '')
endfunction


function! s:default_source_path(dir)
  let dir = (a:dir !~ '/$') ? a:dir.'/' : a:dir
  let lists =  filter(
        \ map([dir,'.vimrc', dir.'_vimrc'], 'expand(v:val)'),
        \ 'filereadable(v:val)')
  return !empty(lists) ? lists[0] : ''
endfunction


function! s:process(repos)
  for r in a:repos
    if empty(r.target)
      echoerr 'invalid "BUNDLE:" line:' r.url
    endif
    if isdirectory(dir)
      call s:scm_cmd('update', r, expand(s:bundle_dir.r.target))
    elseif !isdirectory(dir.'~')
      call s:scm_cmd('checkout', r, expand(s:bundle_dir))
    else
      echomsg 'Don''t update' r.target
      continue
    endif
  endfor
endfunction


function! s:scm_cmd(cmd, repo, dir)
  let owd = getcwd()
  try
    lcd `=a:dir`
    if a:cmd == 'update'
      call up2date#scm#{a:repo.scm}#update(a:repo.branch, a:repo.revision)
    else
      call up2date#scm#{a:repo.scm}#checkout(a:repo.url, a:repo.branch, a:repo.revision, a:repo.target)
    endif
  finally
    lcd `=owd`
  endtry
endfunction


" vspec helper functions. see vspec#hint() {{{
function! up2date#scope()  "{{{
  return s:
endfunction "}}}

function! up2date#sid()  "{{{
  return maparg('<SID>', 'n')
endfunction "}}}
nnoremap <SID>  <SID>
" }}}


let &cpo = s:save_cpo
unlet s:save_cpo
