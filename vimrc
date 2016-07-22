call plug#begin('~/.vim/plugged') " {{{
Plug 'lvht/fzf-mru'|Plug 'junegunn/fzf'
Plug 'scrooloose/nerdtree'
Plug 'itchyny/lightline.vim'
Plug 'phpvim/phpcd.vim'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
call plug#end() " }}}
" color {{{
set laststatus=2
set t_Co=256
color desert
highlight VertSplit ctermfg=240 ctermbg=232 cterm=bold
set hlsearch
" }}}
" keymap {{{
nnoremap <silent> <C-p> :FZF<cr>
nnoremap <silent> <C-u> :FZFMru<cr>
nnoremap <silent> <leader>e :NERDTreeToggle<cr>
" }}}
" expandtab, fold {{{
autocmd FileType php setlocal omnifunc=phpcd#CompletePHP
func! ExpandTab(len)
	setlocal expandtab
	execute 'setlocal shiftwidth='.a:len
	execute 'setlocal softtabstop='.a:len
	execute 'setlocal tabstop='.a:len
endfunc
autocmd FileType html,css,scss,javascript call ExpandTab(2)
autocmd FileType php,python,json,nginx call ExpandTab(4)

autocmd FileType vim setlocal foldmethod=marker
" }}}
" 将光标跳转到上次打开当前文件的位置 {{{
autocmd BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") |
			\ execute "normal! g`\"" |
			\ endif " }}}
" 清理行尾空白字符，md 文件除外 {{{
autocmd BufWritePre * if &filetype != 'markdown' |
			\ :%s/\s\+$//e |
			\ endif " }}}
" fzf-ag {{{
function! s:ag_to_qf(line)
	let parts = split(a:line, ':')
	return {'filename': parts[0], 'lnum': parts[1], 'col': parts[2],
				\ 'text': join(parts[3:], ':')}
endfunction

function! s:ag_handler(lines)
	if len(a:lines) < 2 | return | endif

	let cmd = get({'ctrl-x': 'split',
				\ 'ctrl-v': 'vertical split',
				\ 'ctrl-t': 'tabe'}, a:lines[0], 'e')
	let list = map(a:lines[1:], 's:ag_to_qf(v:val)')

	let first = list[0]
	execute cmd escape(first.filename, ' %#\')
	execute first.lnum
	execute 'normal!' first.col.'|zz'

	if len(list) > 1
		call setqflist(list)
		copen
		wincmd p
	endif
endfunction

function! s:ag_search(keyword)
	call fzf#run({
				\ 'source':  printf('ag --nogroup --column --color "%s"',
				\                   escape(empty(a:keyword) ? '^(?=.)' : a:keyword, '"\')),
				\ 'sink*':   function('s:ag_handler'),
				\ 'options': '--ansi --expect=ctrl-t,ctrl-v,ctrl-x --delimiter : --nth 4.. '.
				\            '--multi --bind ctrl-a:select-all,ctrl-d:deselect-all '.
				\            '--color hl:68,hl+:110',
				\ 'down':    '10'
				\ })
endfunction

command! -nargs=* Ag call s:ag_search(<q-args>)
command! Agc call s:ag_search(expand('<cword>'))
" }}}
" vim: foldmethod=marker:noexpandtab:ts=2:sts=2:sw=2
