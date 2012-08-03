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
  echo s:update(source)
endfunction


function! s:select_source(src)
  return empty(a:src) ?
        \ get(g:, 'up2date_source_path', s:default_source_path('~/')) :
        \ (filereadable(expand(a:src)) ? expand(a:src) : '')
endfunction


function! s:default_source_path(dir)
  let dir = (a:dir !~ '/$') ? a:dir.'/' : a:dir
  let lists =  filter(map([dir,'.vimrc', dir.'_vimrc'], 'expand(v:val)'),
        \ 'filereadable(v:val)',
        \ )
  return !empty(lists) ? lists[0] : ''
endfunction


function! s:update(rcfile)
  return a:rcfile
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
