" Syntastic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
set autowrite                      " Automatically :write before running commands
set term=xterm-256color            " Set the correct term
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
set ttimeoutlen=50                 " No delay after pressing escape 
" Theme
set background=dark
colorscheme base16-railscasts
highlight CursorLine ctermbg=235
highlight CursorLineNR ctermbg=235 ctermfg=white
highlight LineNr ctermfg=lightgrey ctermbg=23

