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

map j gj
map k gk
set linebreak

set listchars=eol:¬,tab:>·,trail:~,extends:>,precedes:<
set list

syntax on
set smartindent

autocmd FileType html setlocal shiftwidth=2 tabstop=2
autocmd FileType python setlocal expandtab shiftwidth=4 softtabstop=4
autocmd FileType haskell setlocal expandtab shiftwidth=2 tabstop=2
autocmd FileType markdown setlocal expandtab tabstop=4 shiftwidth=4

if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()
Plug 'airblade/vim-gitgutter' 
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'lervag/vimtex'
call plug#end()
