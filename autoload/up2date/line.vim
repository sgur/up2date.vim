"=============================================================================
" FILE: autoload/up2date/line.vim
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


function! up2date#line#extract(line)
  let matches = matchlist(a:line, '\<BUNDLE:\s*\(.\+\)$')
  return empty(matches) ? '' : matches[1]
endfunction


function! up2date#line#parse(line)
  let opt = s:parse_options(a:line)
  let repo = s:scm_from_line(opt.url)
  return {
        \ 'branch'   : opt.branch,
        \ 'line'     : a:line,
        \ 'revision' : opt.revision,
        \ 'scm'      : !empty(opt.scm) ? opt.scm : repo.scm,
        \ 'target'   : !empty(opt.target) ? opt.target
        \   : substitute(substitute(repo.dir, '^vim-', '', ''), '[.-]vim$', '', ''),
        \ 'url'      : repo.url,
        \ 'filetype' : opt.filetype,
        \ }
endfunction


function! s:parse_options(line)
  let options = {
        \ 'branch'   : '',
        \ 'revision' : '',
        \ 'scm'      : '',
        \ 'target'   : '',
        \ 'url'      : '',
        \ 'filetype' : '',
        \ }
  if empty(a:line)
    return options
  endif
  let items = split(a:line)
  let options.url = items[0]
  for elem in items[1:]
    if !stridx(elem, '@')       " revision
      let options.revision = elem[1:]
    elseif !stridx(elem, '+')   " branch
      let options.branch   = elem[1:]
    elseif !stridx(elem, '/')   " target
      let options.target   = elem[1:]
    elseif !stridx(elem, '-')   " scm
      let options.scm      = elem[1:]
    elseif !stridx(elem, '#')   " ftbundle
      let options.filetype = elem[1:]
    endif
  endfor
  return options
endfunction



function! s:scm_from_line(line)
  let matches = matchlist(a:line, '^\(https:\|git[@:]\).\+/\zs[^/]\+\ze\.git$')
  if !empty(matches)
    return {'scm' : 'git',
          \ 'dir' : matches[0],
          \ 'url' : a:line }
  endif
  let matches = matchlist(a:line, '^http\%(s\)\?://github\.com.\+/\zs[^/]\+\ze$')
  if !empty(matches)
    return {'scm' : 'git',
          \ 'dir' : matches[0],
          \ 'url' : a:line }
  endif
  let matches = matchlist(a:line, '\(https\|ssh\)://bitbucket\.org.\+/\zs[^/]\+$')
  if !empty(matches)
    return {'scm' : 'mercurial',
          \ 'dir' : matches[0],
          \ 'url' : a:line }
  endif
  return {'scm' : 'unknown',
        \ 'dir' : '',
        \ 'url' : a:line }
endfunction


function! up2date#line#scope()  "{{{
  return s:
endfunction "}}}


function! up2date#line#sid()  "{{{
  return maparg('<SID>', 'n')
endfunction "}}}
nnoremap <SID>  <SID>


let &cpo = s:save_cpo
unlet s:save_cpo

