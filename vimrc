execute pathogen#infect()


" Use Mouse
set mouse=a
" Syntastic
set autowrite                      " Automatically :write before running commands
syntax on
set t_Co=256     
set cursorline                     " Highlight the current line
set backspace=2                    " Backspace deletes like most programs in insert mode
set expandtab                      " Tabs are spaces
set fileencoding=utf-8             " The encoding written to file
set fileformat=unix                " That LF life, son
set hlsearch                       " Highlight searches
set ignorecase                     " Ignore case when searching
set number                         " Show line numbers all of the times
set relativenumber                 " Less arithmetic to navigate around (relative line numbers)
set scrolloff=3                    " More space around cursor when scrolling
set showcmd                        " Display incomplete commands
set ttimeoutlen=0                 " No delay after pressing escape 
filetype plugin indent on
" Theme
highlight CursorLine ctermbg=55
highlight CursorLineNR ctermbg=red ctermfg=white
highlight LineNr ctermfg=lightgrey ctermbg=23
highlight Normal ctermfg=white ctermbg=black
highlight Cursor guifg=white guibg=red
highlight iCursor guifg=white guibg=steelblue
" first, enable status line alwas
set laststatus=2
if version >= 700
        au InsertEnter * hi StatusLine term=reverse ctermbg=5 gui=undercurl guisp=Magenta
        au InsertLeave * hi StatusLine term=reverse ctermfg=0 ctermbg=2 gui=bold,reverse
endif

au VimEnter *  NERDTree
