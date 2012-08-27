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


" `:Up2date [<source_file>]`
function! up2date#update(src)
  let source = s:select_source(a:src)
  if !filereadable(source)
    echoerr 'up2date: source file not found!'
    return
  endif
  let is_update = s:update_all(file)
  call s:cycle_filetype(is_update)
endfunction


" `:Up2dateBundle <bundle_name>`
function! up2date#update_bundle(bundle)
  let source = s:select_source('')
  if !filereadable(source)
    echoerr 'up2date: source file not found!'
    return
  endif
  let is_update = s:update_one(source, a:bundle)
  call s:cycle_filetype(is_update)
endfunction


" Complete helper funcition for `:Up2dateBundle`
function! up2date#complete(arglead, cmdline, cursorpos)
  let source = s:select_source('')
  if !filereadable(source)
    return []
  endif
  return filter(map(s:collect_repos(source), 'v:val.target'),
        \ 'match(v:val, a:arglead) > -1')
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


function! s:process(repo)
  if empty(a:repo.target) || a:repo.scm == 'unknown'
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
  let more = &more
  lcd `=a:dir`
  set nomore
  try
    if a:cmd == 'update'
      call up2date#scm#{a:repo.scm}#update(a:repo.branch, a:repo.revision)
    else
      call up2date#scm#{a:repo.scm}#checkout(a:repo.url, a:repo.branch, a:repo.revision, a:repo.target)
    endif
  finally
    lcd `=owd`
    let &more = more
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


function! s:update_one(file, bundle)
  let newplugins =
        \ filter(map(filter(s:collect_repos(a:file), 'v:val.target == a:bundle'),
        \ 's:process(v:val)'),
        \ 'v:val')
  return len(newplugins)
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
