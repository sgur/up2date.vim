"=============================================================================
" FILE: autoload/up2date/worker.vim
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
let s:workers_wait = 100

function! s:increment_worker()
  let s:workers += 1
endfunction


function! s:decrement_worker()
  let s:workers -= 1
endfunction

function! s:get_limit()
  return g:up2date_max_workers
endfunction

function! up2date#worker#is_full()
  let limit = s:get_limit()
  return s:workers > limit ? 1 : 0
endfunction


function! up2date#worker#asynccommand(cmd, env)
  if exists('g:loaded_asynccommand')
    call s:increment_worker()
    let env = a:env
    let env.callback = a:env.get
    function! env.get(temp_name) dict
      echomsg self.callback
      call up2date#run()
      call self.callback(a:temp_name)
      call s:decrement_worker()
      if exists('self.is_checkout') && self.is_checkout
        call up2date#util#source_plugin(self.cwd)
        call up2date#util#add_runtimepath(self.cwd)
        call up2date#util#helptags(self.cwd)
      endif
    endfunction
    call asynccommand#run(a:cmd, env)
  else
    let output = system(a:cmd)
    let tempfile = tempname()
    try
      call writefile(split(output), tempfile)
      call env.get(tempfile)
    catch
    finally
      call delete(tempfile)
    endtry
  endif
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
