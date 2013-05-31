"=============================================================================
" FILE: plugin/up2date.vim
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

if exists('g:loaded_up2date') && g:loaded_up2date
  finish
endif
let g:loaded_up2date = 1

" Variables {{{

function! s:initalize_variables()
  let g:up2date_bundle_dir =
        \ expand(get(g:, 'up2date_bundle_dir', s:vim_user_dir.'bundle'.'/'))
  let g:up2date_ftbundle_dir =
        \ expand(get(g:, 'up2date_ftbundle_dir', s:vim_user_dir.'ftbundle'.'/'))
  let g:up2date_source_path =
        \ expand(get(g:, 'up2date_source_path', s:default_source_path('~/')))
  let g:up2date_max_workers =
        \ get(g:, 'up2date_max_workers', s:default_max_workers)
endfunction

" Vim user directory
let s:vim_user_dir = expand((has('win32') || has('win64'))
      \ ? '~/vimfiles/' : '~/.vim/')

" Defualt parallel workers
let s:default_max_workers = 2

function! s:default_source_path(dir)
  let dir = (a:dir !~ '/$') ? a:dir.'/' : a:dir
  let lists =  filter(
        \ map([dir,'.vimrc', dir.'_vimrc'], 'expand(v:val)'),
        \ 'filereadable(v:val)')
  return !empty(lists) ? lists[0] : ''
endfunction

call s:initalize_variables()

" }}}


" Commands {{{

command! -nargs=* -complete=customlist,up2date#complete Up2date
      \ call up2date#update(<f-args>)

command! -nargs=0 Up2dateCancel call up2date#cancel()

command! -nargs=0 Up2dateAtCursor call up2date#update_line()

command! -nargs=0 Up2dateStatus call up2date#status()

command! -nargs=0 Up2dateLog call up2date#log#show()

command! -nargs=0 Up2dateInput call up2date#input()

" }}}

