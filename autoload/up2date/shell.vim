let s:save_cpo = &cpo
set cpo&vim

let s:receivers = {}

function! up2date#shell#receivers()
 return s:receivers
endfunction

let s:is_win = has('win32') || has('win64')
let s:is_mac = !s:is_win && (has('mac') || has('macunix') || has('gui_macvim')
      \ || (!isdirectory('/proc') && executable('sw_vers')))

if has('gui_running')
  if s:is_mac
    if executable('mvim')
      let s:executable = 'mvim'
    endif
  else
    if executable('gvim')
      let s:executable = 'gvim'
    endif
  endif
elseif executable('vim')
  let s:executable = 'vim'
endif

function! s:vim_executable()
  if !exists('s:executable')
    throw 'asyncshell: executable not found'
  endif
  return s:executable . ' -u NONE --noplugin'
endfunction

function! s:shellredir(temp_file)
  return stridx(&shellredir, '%s') > -1
        \? printf(&shellredir, a:temp_file)
        \: (' >& ' . a:temp_file)
endfunction

function! s:system(cmd, handler, user_env)
  let temp_file = tempname()
  let temp_id = fnamemodify(temp_file, ':t:r')
  let s:receivers[temp_id] =
        \ { 'is_finished' : 0
        \ , 'cmd': a:cmd
        \ , 'result' : []
        \ , 'handler' : a:handler
        \ , 'user' : a:user_env
        \ , 'temp_file' : temp_file}
  if type(a:cmd) == type([])
    let target = join(a:cmd, ' && ')
  else
    let target = a:cmd
  endif
  let exec_cmd = '(' . (s:is_win ? 'title ' . temp_id . '& ' : '') . target . ') '
        \ . s:shellredir(temp_file)
  let result_var = s:is_win ? '\%ERRORLEVEL\%' : '$?'
  let vim_cmd = s:vim_executable() . ' --servername ' . v:servername
        \ . ' --remote-expr "AsyncShell__OnDone(''' . temp_id . ''', ' . result_var . ')"'
  if s:is_win
    silent execute '!start /b cmd /c "' . exec_cmd . ' & ' . vim_cmd . ' >NUL"'
  else
    silent execute '! (echo ASYNC' . temp_id . ' > /dev/null ; '. exec_cmd . ' ; ' . vim_cmd . ' >/dev/null) &'
  endif
  return temp_id
endfunction

function! s:default_handler(result, status, user)
  let more = &more
  set nomore
  echo join(a:result, "\n")
  let &more = more
endfunction

function! s:SID()
  return matchstr(expand('<sfile>'), '<SNR>\d\+_')
endfunction

function! s:default_handler_name()
  return s:SID() . 'default_handler'
endfunction

function! s:split_lines(string)
  return split(a:string, '\r\n\|\n\|\r')
endfunction

function! s:system_fallback(cmd, handler, user)
  if type(a:cmd) == type([])
    let result = ''
    for l in a:cmd
      let result .= system(l)
    endfor
  else
    let result = system(a:cmd)
  endif
  call call(a:handler, [s:split_lines(result), v:shell_error, a:user])
  return '+clientserver not found'
endfunction

function! AsyncShell__OnDone(temp_id, ret_code)
  let recv = s:receivers[a:temp_id]
  let recv.is_finished = 1
  let temp_file = recv.temp_file
  call call(recv.handler,
        \ [ readfile(expand(temp_file))
        \ , eval(a:ret_code)
        \ , recv.user])
  call delete(a:temp_file)
  call remove(s:receivers, a:temp_id)
  return ""
endfunction

function! up2date#shell#system(cmd, ...)
  let handler = a:0 > 0 ? a:1 : s:default_handler_name()
  let user =  a:0 > 1 ? a:2 : {}
  if !has('clientserver') " fallback
    return s:system_fallback(a:cmd, handler, user)
  endif
  return s:system(a:cmd, handler, user)
endfunction

function! up2date#shell#kill(id)
  if s:is_win
    let result = split(system('tasklist /NH /FO CSV /FI "WINDOWTITLE eq ' . a:id . '"'), '\r\n\|\n\|\r')[0]
    let pid = matchstr(result, '^"[^"]\+","\zs\d\+\ze"')
    call system('taskkill /PID '.pid)
  else
    let results = split(system('ps -u $USER | grep ASYNC' . a:id), '\r\n\|\n\|\r')
    let pids = map(results, 'matchstr(v:val, "\\s\\+\\d\\+\\s\\+\\zs\\d\\+\\ze")')
    call system('kill ' . join(pids, ' '))
  endif
endfunction



let &cpo = s:save_cpo
unlet s:save_cpo
