"=============================================================================
" FILE: autoload/up2date/log.vim
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

function! up2date#log#log(title, lines)
  let curnr = bufwinnr('%')
  let bufname = '__UP2DATE__'
  execute 'silent topleft pedit' bufname
  execute bufwinnr(bufname).'wincmd w'
  setlocal buftype=nofile bufhidden=wipe noswapfile nowrap
  call append(0, a:title)
  for l in a:lines
    call append(line('$'), l)
  endfor
  1
  let cols = len(a:lines)+2
  if cols < &previewheight
    execute 'resize' cols
  endif
  redraw
  execute curnr.'wincmd w'
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo