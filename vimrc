execute pathogen#infect()


" Use Mouse
set mouse=a
set ttymouse=xterm2
set mouse+=a
if &term =~ '^screen'
            " tmux knows the extended mouse mode
                 set ttymouse=xterm2
                 endif



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
filetype plugin indent on

" Add solarized theme
syntax enable
set background=dark
colorscheme solarized


" Theme
"highlight CursorLine ctermbg=55
"highlight CursorLineNR ctermbg=red ctermfg=white
"highlight LineNr ctermfg=63 ctermbg=black


"hi CursorLine   cterm=NONE ctermbg=236 ctermfg=white guibg=red guifg=white
"hi CursorColumn cterm=NONE ctermbg=236 ctermfg=white guibg=red guifg=white
"nnoremap <Leader>c :set cursorline! && cursorcolumn!<CR>




" Normal text colors
"highlight Normal ctermfg=white ctermbg=black

"highlight Cursor guifg=white guibg=red
"highlight iCursor guifg=white guibg=steelblue
" first, enable status line alwas
"set laststatus=2
"if version >= 700
"        au InsertEnter * hi StatusLine term=reverse ctermbg=5 gui=undercurl guisp=Magenta
"        au InsertLeave * hi StatusLine term=reverse ctermfg=0 ctermbg=2 gui=bold,reverse
"endif

au VimEnter *  NERDTree
