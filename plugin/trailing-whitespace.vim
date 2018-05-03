if exists('loaded_trailing_whitespace_plugin') | finish | endif
let loaded_trailing_whitespace_plugin = 1

if !exists('g:extra_whitespace_ignored_filetypes')
    let g:extra_whitespace_ignored_filetypes = []
endif

if !exists('g:trailing_whitespace_enable')
    let g:trailing_whitespace_enable = 1
endif

function! s:ReloadSyntaxFromStart()
	syn off
	syn on
endfunction

function! EnableTrailingWhitespace()
    let g:trailing_whitespace_enable = 1
	call s:ReloadSyntaxFromStart()
endfunction

function! DisableTrailingWhitespace()
    let g:trailing_whitespace_enable = 0
	call s:ReloadSyntaxFromStart()
endfunction

function! ToggleTrailingWhitespace()
    let g:trailing_whitespace_enable = 1 - g:trailing_whitespace_enable
	call s:ReloadSyntaxFromStart()
endfunction

function! ShouldMatchWhitespace()
    for ft in g:extra_whitespace_ignored_filetypes
        if ft ==# &filetype | return 0 | endif
    endfor
    return 1
endfunction

" Highlight EOL whitespace, http://vim.wikia.com/wiki/Highlight_unwanted_spaces
highlight default ExtraWhitespace ctermbg=darkred guibg=darkred
autocmd ColorScheme * if g:trailing_whitespace_enable | highlight default ExtraWhitespace ctermbg=darkred guibg=darkred | endif
autocmd BufRead,BufNew * if ShouldMatchWhitespace() | match ExtraWhitespace /\\\@<![\u3000[:space:]]\+$/ | else | match ExtraWhitespace /^^/ | endif

" The above flashes annoyingly while typing, be calmer in insert mode
autocmd InsertLeave * if ShouldMatchWhitespace() | match ExtraWhitespace /\\\@<![\u3000[:space:]]\+$/ | endif
autocmd InsertEnter * if ShouldMatchWhitespace() | match ExtraWhitespace /\\\@<![\u3000[:space:]]\+\%#\@<!$/ | endif

function! s:FixWhitespace(line1,line2)
    let l:save_cursor = getpos(".")
    silent! execute ':' . a:line1 . ',' . a:line2 . 's/\\\@<!\s\+$//'
    call setpos('.', l:save_cursor)
endfunction

" Run :FixWhitespace to remove end of line white space
command! -range=% FixWhitespace call <SID>FixWhitespace(<line1>,<line2>)
