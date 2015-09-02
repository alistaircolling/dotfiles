execute pathogen#infect()


" Use Mouse
set mouse=a
set ttymouse=xterm2
set ttyfast
set ttyscroll=3 
set mousefocus
let g:NERDTreeMouseMode=3 

" Syntastic
set autowrite                      " Automatically :write before running commands
syntax on
set t_Co=2236     
set cursorline                     " Highlight the current line
set cursorcolumn
set backspace=2                    " Backspace deletes like most programs in insert mode
set expandtab                      " Tabs are spaces
set fileencoding=utf-8             " The encoding written to file
set fileformat=unix                " That LF life, son
set hlsearch                       " Highlight searches
set ignorecase                     " Ignore case when searching
set number                         " Show line numbers all of the times
set rnu                            "show relative line numbers
set showcmd                        " Display incomplete commands
set ttimeoutlen=0                 " No delay after pressing escape 
set nowrap
set paste

filetype plugin indent on

" Add solarized theme
syntax enable
set background=dark
colorscheme solarized

au VimEnter *  NERDTree
