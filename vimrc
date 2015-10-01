execute pathogen#infect()


" Use Mouse
set mouse=a
set ttymouse=xterm2
set ttyfast
set ttyscroll=3 
set mousefocus
let g:NERDTreeMouseMode=3

" Key Bindings
nmap <C-n> :NERDTreeToggle<CR>


" Syntastic
set autowrite                      " Automatically :write before running commands
syntax on
set t_Co=2236     
set cursorline                     " Highlight the current line
"set cursorcolumn
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
"set background=dark
"colorscheme solarized
colorscheme monokai


" JS Beautify
map <c-f> :call JsBeautify()<cr>
" or
autocmd FileType javascript noremap <buffer>  <c-f> :call JsBeautify()<cr>
" for html
autocmd FileType html noremap <buffer> <c-f> :call HtmlBeautify()<cr>
" for css or scss
autocmd FileType css noremap <buffer> <c-f> :call CSSBeautify()<cr>

"toggle highlighting (e.g. on search)
map <c-h> :noh<cr>
"color the status based on insert mode
" first, enable status line always
set laststatus=2

" now set it up to change the status line based on mode
if version >= 700
  au InsertEnter * hi StatusLine term=reverse ctermbg=5 gui=undercurl guisp=Magenta
  au InsertLeave * hi StatusLine term=reverse ctermfg=0 ctermbg=2 gui=bold,reverse
endif


au VimEnter *  NERDTree

