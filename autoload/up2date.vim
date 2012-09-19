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



" `:Up2date [<bundle_name>]`
function! up2date#update(...)
  let source = s:select_source()
  if !filereadable(source)
    echoerr 'up2date: source file not found!'
    return
  endif
  let more = &more
  set nomore
  try
    let is_update = (a:0)
          \ ? s:update_specified(source, a:000)
          \ : s:update_all(source)
  catch
    let is_update = 0
  finally
    if !a:0
      call up2date#worker#wait_until(0)
    endif
    let &more = more
  endtry
  call s:cycle_filetype(is_update)
endfunction


" Complete helper funcition for `:Up2dateBundle`
function! up2date#complete(arglead, cmdline, cursorpos)
  let source = s:select_source()
  if !filereadable(source)
    return []
  endif
  return filter(map(s:collect_repos(source), 'v:val.target'),
        \ 'match(v:val, a:arglead) > -1')
endfunction


function! up2date#status()
  let source = s:select_source()
  if !filereadable(source)
    echoerr 'up2date: source file not found!'
    return
  endif
  call s:diff_bundles(source)
endfunction


" :Up2dateLine
function! up2date#update_line()
  let line = up2date#line#extract(getline('.'))
  if empty(line)
    echohl WarningMsg |echomsg 'No bundle lines are found.' | echohl None
    return
  endif

  let repo = up2date#line#parse(line)
  call s:process(repo)
endfunction


function! up2date#start_bg(bundle)
  let source = s:select_source()
  if !filereadable(source)
    echoerr 'up2date: source file not found!'
    return
  endif
  let s:plugins = s:collect_repos(source)
  if !exists('g:up2date_workers_max')
    let g:up2date_workers_max = 1
    let s:is_override = 1
  endif
  augroup up2date_background
    autocmd!
    autocmd CursorHold,CursorHoldI * call s:on_cursor_hold(s:plugins)
  augroup END
endfunction


function! up2date#cancel_bg()
  let s:plugins = []
  if exists('s:is_override')
    unlet g:up2date_workers_max
    unlet s:is_override
  endif
  autocmd! up2date_background
endfunction


" Vim user directory
let s:vim_user_dir = expand((has('win32') || has('win64'))
      \ ? '~/vimfiles/' : '~/.vim/')


" Bundle directory
function! s:bundle_dir()
  return expand(get(g:, 'up2date_bundle_dir', s:vim_user_dir.'bundle').'/')
endfunction


" Cycle filetype off -> on
function! s:cycle_filetype(is_update)
  if !a:is_update
    return
  endif
  " reload ftplugin.vim
  filetype off
  filetype on
endfunction


function! s:select_source()
  return expand(get(g:, 'up2date_source_path', s:default_source_path('~/')))
endfunction


function! s:default_source_path(dir)
  let dir = (a:dir !~ '/$') ? a:dir.'/' : a:dir
  let lists =  filter(
        \ map([dir,'.vimrc', dir.'_vimrc'], 'expand(v:val)'),
        \ 'filereadable(v:val)')
  return !empty(lists) ? lists[0] : ''
endfunction


function! s:process(repo)
  if empty(a:repo.target) || a:repo.scm ==# 'unknown'
    echoerr 'Invalid "BUNDLE:" line:' a:repo.line
    return
  endif
  let dir = expand(s:bundle_dir().a:repo.target)
  let new_plugin = 0
  if isdirectory(dir)
    call s:scm_cmd('update', a:repo, dir)
  elseif !isdirectory(dir.'~')
    call s:scm_cmd('checkout', a:repo, expand(s:bundle_dir()))
    let new_plugin = 1
  else
    echomsg 'Don''t update' a:repo.target
  endif
  return new_plugin
endfunction


function! s:scm_cmd(cmd, repo, dir)
  let owd = getcwd()
  lcd `=a:dir`
  try
    if a:cmd ==# 'update'
      call up2date#scm#{a:repo.scm}#update(a:repo.branch, a:repo.revision)
    else
      call up2date#scm#{a:repo.scm}#checkout(a:repo.url, a:repo.branch, a:repo.revision, a:repo.target)
    endif
  finally
    lcd `=owd`
  endtry
endfunction


function! s:collect_repos(file)
  return map(filter(map(readfile(a:file), 'up2date#line#extract(v:val)'),
        \ '!empty(v:val)'),
        \ 'up2date#line#parse(v:val)')
endfunction


function! s:update_all(file)
  let newplugins = 
        \ filter(map(s:collect_repos(a:file),
        \ 's:process(v:val)'),
        \ 'v:val')
  return len(newplugins)
endfunction


function! s:update_specified(file, bundles)
  let newplugins =
        \ filter(map(filter(s:collect_repos(a:file), 'index(a:bundles, v:val.target) >= 0'),
        \ 's:process(v:val)'),
        \ 'v:val')
  return len(newplugins)
endfunction


function! s:diff_bundles(file)
  let bundles = map(filter(s:collect_repos(a:file),
        \ '!empty(v:val)'),
        \ 'v:val.target')
  let installed = map(
        \ split(globpath(s:bundle_dir(), '*')),
        \ 'fnamemodify(v:val, ":t")'
        \ )
  echomsg 'Uninstalled' '['
        \ join(filter(copy(bundles), 'index(installed, v:val) == -1'))
        \ ']'
  echomsg 'Unlisted' '['
        \ join(filter(copy(installed), 'index(bundles, v:val) == -1'))
        \ ']'
endfunction


function! s:on_cursor_hold(bundles)
  if !empty(a:bundles)
    let bundle = a:bundles[0]
    call s:process(bundle)
    call remove(a:bundles, 0)
  else
    call up2date#cancel_bg()
  endif

  if mode() ==# 'n'
    call feedkeys("g\<ESC>", 'n')
  else
    call feedkeys("a\<BS>",'n')
  endif
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
