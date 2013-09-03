function! s:add_point(s, l)
  if a:s =~ '^\s*\w' && a:s !~ '^\s*\(en\|if\|el\)'
    let l:r = join([
    \ printf('let [g:bvimrc_t[g:bvimrc_c], g:bvimrc_s, g:bvimrc_c] = [reltimestr(reltime(g:bvimrc_s)), reltime(), %d]', a:l),
    \], '|') . "\n" . a:s
  else
    let l:r = a:s
  endif
  return l:r
endfunction

function! s:detect_vimrc()
  if has('win32') || has('win64')
    let l:vimrc = fnamemodify(expand($MYVIMRC), ':p')
    if filereadable(l:vimrc)
      return l:vimrc
    endif
  endif
  return fnamemodify(expand($MYVIMRC), ':p')
endfunction

function! s:benchvimrc(vimrc)
  if a:vimrc ==# ''
    let l:vimrc = s:detect_vimrc()
  else
    let l:vimrc = expand(a:vimrc)
  endif
  let g:bvimrc_l = readfile(l:vimrc, 1)
  call add(g:bvimrc_l, "echo ''")
  let l:tmp = tempname()
  try
    let l = map(range(len(g:bvimrc_l)), 's:add_point(g:bvimrc_l[v:val], v:val + 1)')
    call writefile(split(join(l, "\n"), "\n", 1), l:tmp, 1)
    let g:bvimrc_t = {}
    let g:bvimrc_s = reltime()
    let g:bvimrc_c = 0
    exe 'so' l:tmp
    let l = map(range(1, len(g:bvimrc_l) - 1),
    \ 'printf("%s %05d: %s", has_key(g:bvimrc_t, v:val) ? g:bvimrc_t[v:val] : "          ", v:val, g:bvimrc_l[v:val - 1])'
    \)
    call writefile(l, l:tmp, 1)
    exe 'so' l:vimrc
    unlet g:bvimrc_c
    unlet g:bvimrc_l
    unlet g:bvimrc_t
    unlet g:bvimrc_s
    silent exe 'split' l:tmp
    silent file __BENCHVIMRC__
    setlocal buftype=nofile filetype=vim
    silent! %foldopen
  finally
    call delete(l:tmp)
  endtry
endfunction

command! -nargs=? BenchVimrc  call s:benchvimrc('<args>')
