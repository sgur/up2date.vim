"=============================================================================
" FILE: autoload/up2date/helper.vim
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

let s:save_cpo = &cpo
set cpo&vim

let s:workers = 0
let s:workers_max = 4
let s:workers_wait = 100

function! s:increment_worker()
  let s:workers += 1
endfunction


function! s:decrement_worker()
  let s:workers -= 1
endfunction

function! up2date#helper#asynccommand(cmd, env)
  while s:workers >= s:workers_max
    execute 'sleep' s:workers_wait.'m'
  endwhile
  call s:increment_worker()
  let env = a:env
  let env.callback = a:env.get
  function! env.get(temp_name) dict
    echomsg self.callback
    call self.callback(a:temp_name)
    call s:decrement_worker()
  endfunction
  call asynccommand#run(a:cmd, env)
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
