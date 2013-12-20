"=============================================================================
" FILE: autoload/up2date/util.vim
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

function! up2date#util#source_plugin(dir)
  for plugin in split(globpath(a:dir, 'plugin/*.vim'))
    source `=plugin`
  endfor
endfunction


function! up2date#util#add_runtimepath(dir)
  let &runtimepath = a:dir . ',' . &runtimepath
  let after_dir = expand(a:dir . '/after')
  if isdirectory(after_dir)
    let &runtimepath .= ',' . afterdir
  endif
endfunction


function! up2date#util#helptags(dir)
  let doc_dir = expand(a:dir . '/doc')
  if isdirectory(doc_dir) && !findfile('tags', doc_dir)
    execute 'helptags' doc_dir
  endif
endfunction

