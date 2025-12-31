" Fugitive GBrowse handler for Aliyun Codeup

if exists('g:autoloaded_fugitive_codeup')
  finish
endif
let g:autoloaded_fugitive_codeup = 1

function! fugitive#codeup#handler(opts) abort
  let l:remote = get(a:opts, 'remote', '')
  if l:remote !~# 'codeup\.aliyun\.com'
    return ''
  endif

  " git@codeup.aliyun.com:org/repo.git -> https://codeup.aliyun.com/org/repo
  let l:url = substitute(l:remote, '^git@codeup\.aliyun\.com:', 'https://codeup.aliyun.com/', '')
  let l:url = substitute(l:url, '\.git$', '', '')

  let l:url .= '/commit/' . a:opts.commit

  return l:url
endfunction

if !exists('g:fugitive_browse_handlers')
  let g:fugitive_browse_handlers = []
endif
call insert(g:fugitive_browse_handlers, function('fugitive#codeup#handler'))

