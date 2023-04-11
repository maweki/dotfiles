set showcmd
set showmatch
set ruler

set wildmenu
set wildignore=*.o,*~,*.pyc

" Highlight search results
set hlsearch

set history=700
filetype plugin on
filetype indent on
set autoread

set encoding=utf-8

map j gj
map k gk
set linebreak

set listchars=eol:¬,tab:>·,trail:~,extends:>,precedes:<
set list

syntax on
set smartindent

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" Starting with Vim 7, the filetype of empty .tex files defaults to
" 'plaintex' instead of 'tex', which results in vim-latex not being loaded.
let g:tex_flavor='latex'

autocmd FileType html setlocal shiftwidth=2 tabstop=2
autocmd FileType python setlocal expandtab shiftwidth=4 softtabstop=4
autocmd FileType haskell setlocal expandtab shiftwidth=2 tabstop=2
autocmd FileType markdown setlocal expandtab tabstop=4 shiftwidth=4

" Install vim-plug if not found
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif

call plug#begin()
Plug 'tpope/vim-sensible'
Plug 'airblade/vim-gitgutter' 
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-latex/vim-latex'
call plug#end()

