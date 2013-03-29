"=============================================================================
" FILE: autoload/up2date.vim
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


let s:repos = []


" `:Up2date [<bundle_name>]`
function! up2date#update(...)
  let source = s:select_source()
  if !filereadable(source)
    echoerr 'up2date: source file not found!'
    return
  endif
  let repos = s:collect_repos(source)
  if a:0
    let repos = filter(repos, 'index(a:000, v:val.target) >= 0')
  endif
  call up2date#start(repos)
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


" :Up2dateAtCursor
function! up2date#update_line()
  let line = up2date#line#extract(getline('.'))
  if empty(line)
    echohl WarningMsg |echomsg 'No bundle lines are found.' | echohl None
    return
  endif

  let repo = up2date#line#parse(line)
  call up2date#start([repo])
endfunction


function! up2date#input()
  let line = input('BUNDLE:')
  let repo = up2date#line#parse(line)
  call up2date#start([repo])
endfunction


function! up2date#start(repo)
  if type(a:repo) == type([])
    call extend(s:repos, a:repo)
  elseif type(a:repo) == type({})
    call add(s:repos, a:repo)
  else
    return
  endif
  let s:newplugins = 0
  call up2date#run()
endfunction


function! up2date#run()
  let more = &more
  set nomore
  try 
    if empty(s:repos)
      call s:cycle_filetype(s:newplugins)
    else
      while !empty(s:repos) && !up2date#worker#is_full()
        let [repo, s:repos] = [s:repos[0], s:repos[1:]]
        let s:newplugins = s:process(repo) ? 1 : s:newplugins
        sleep 200m
      endwhile
    endif
  finally
    let &more = more
  endtry
endfunction


function! up2date#cancel()
  let s:repos = []
endfunction


function! up2date#indicator(...)
  let format = get(a:, '1', 'Up2date:{%num}')
  let format = substitute(format, '{%num}', len(s:repos), 'g')
  return len(s:repos)
        \ ? '['.format.']'
        \ : ''
endfunction



" Vim user directory
let s:vim_user_dir = expand((has('win32') || has('win64'))
      \ ? '~/vimfiles/' : '~/.vim/')


" Repositories to update
let s:repos = []



" Bundle directory
function! s:bundle_dir()
  return expand(get(g:, 'up2date_bundle_dir', s:vim_user_dir.'bundle').'/')
endfunction


" Ftbundle directory
function! s:ftbundle_dir()
  return expand(get(g:, 'up2date_ftbundle_dir', s:vim_user_dir.'ftbundle').'/')
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
  if !empty(a:repo.filetype)
    let dir = s:ftbundle_dir().a:repo.filetype.'/'.a:repo.target
  else
    let dir = s:bundle_dir().a:repo.target
  endif
  let new_plugin = 0
  if isdirectory(expand(dir))
    call s:scm_cmd('update', a:repo, dir)
  elseif !isdirectory(dir.'~')
    call s:scm_cmd('checkout', a:repo, dir)
    let new_plugin = 1
  else
    echomsg 'Don''t update' a:repo.target
  endif
  return new_plugin
endfunction


function! s:scm_cmd(cmd, repo, dir)
  if a:cmd ==# 'update'
    call up2date#scm#{a:repo.scm}#update(a:repo.branch, a:repo.revision, a:dir)
  else
    call mkdir(a:dir, 'p')
    call up2date#scm#{a:repo.scm}#checkout(a:repo.url, a:repo.branch,
          \ a:repo.revision, a:dir)
  endif
endfunction


function! s:collect_repos(file)
  return map(filter(map(readfile(a:file), 'up2date#line#extract(v:val)'),
        \ '!empty(v:val)'),
        \ 'up2date#line#parse(v:val)')
endfunction


function! s:diff_bundles(file)
  let all_bundles = filter(s:collect_repos(a:file), '!empty(v:val)')
  let _ = []
  for b in all_bundles
    let i = stridx(b.target, '/')
    if i >= 0
      let b.target = b.target[: i-1]
    endif
    call add(_, b)
  endfor
  let all_bundles = _
  let bundles = map(filter(copy(all_bundles), 'v:val.filetype == ""'),
        \ 'v:val.target')
  let ftbundles = map(filter(copy(all_bundles), 'v:val.filetype != ""'),
        \ 'v:val.target')
  let exists_bundles = map(
        \ split(globpath(s:bundle_dir(), '*'))
        \ , 'fnamemodify(v:val, ":t")')
  let exists_ftbundles = map(
        \ split(globpath(s:ftbundle_dir().'/*', '*'))
        \ , 'fnamemodify(v:val, ":t")')
  call filter(exists_bundles, 'index(exists_ftbundles, v:val) == -1')
  call up2date#log#msg('status'
        \ , ['## Ready to install']
        \ + map(filter(copy(bundles), 'index(exists_bundles, v:val) == -1'), '"- ".v:val')
        \ + map(filter(copy(ftbundles), 'index(exists_ftbundles, v:val) == -1'), '"- ".v:val')
        \ + ['', '## Unrecognized']
        \ + map(filter(copy(exists_bundles), 'index(bundles, v:val) == -1'), '"- ".v:val')
        \ + map(filter(copy(exists_ftbundles), 'index(ftbundles, v:val) == -1'), '"- ".v:val')
        \ )
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
