
""***************************** KEY MAPPINGS *********************************
let mapleader = " "
map <Leader> <Plug>(easymotion-prefix)
nmap <silent> <leader>d <Plug>DashSearch
nmap t% :tabedit %<CR>
nmap td :tabclose<CR>
"map escape to close terminal mode
tnoremap <Esc> <C-\><C-n>
"terminal nav mappings
tnoremap <A-h> <C-\><C-n><C-w>h
tnoremap <A-j> <C-\><C-n><C-w>j
tnoremap <A-k> <C-\><C-n><C-w>k
tnoremap <A-l> <C-\><C-n><C-w>l
nnoremap <A-h> <C-w>h
nnoremap <A-j> <C-w>j
nnoremap <A-k> <C-w>k
" add a new line when pressing enter without entering insert mode
nmap <S-Enter> O<Esc>
" increment amnd decrment on alt
nnoremap <C-x> <C-a>
nnoremap <C-z> <C-x>
" tab navigation
nnoremap ty  :tabnext<CR>
nnoremap tr  :tabprev<CR>


" open docs
set runtimepath+=~/path/to/deoplete.nvim/
let g:deoplete#enable_at_startup = 1
set hidden

autocmd BufWritePost * Neomake
let g:neomake_javascript_enabled_makers = ['eslint']
" open list Automatically
let g:neomake_open_list = 1


let g:neomake_javascript_enabled_makers = ['eslint']
let g:neomake_logfile = '/usr/local/var/log/neomake.log'

let g:jsx_ext_required = 0 " Allow JSX in normal JS files

let g:neomake_warning_sign = {
            \ 'text': 'W',
            \ 'texthl': 'WarningMsg',
            \ }
let g:neomake_error_sign = {
            \ 'text': 'E',
            \ 'texthl': 'ErrorMsg',
            \ }

if !exists('g:deoplete#omni#input_patterns')
    let g:deoplete#omni#input_patterns = {}
endif
" let g:deoplete#disable_auto_complete = 1

autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
" omnifuncs
augroup omnifuncs
    autocmd!
    autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
    autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
    au FileType javascript,jsx setl omnifunc=tern#Complete
    autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
    autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
augroup end
" tern
if exists('g:plugs["tern_for_vim"]')
    let g:tern_show_argument_hints = 'on_hold'
    let g:tern_show_signature_in_pum = 1
    autocmd FileType javascript setlocal omnifunc=tern#Complete
endif
" Use deoplete.
let g:tern_request_timeout = 1
let g:tern_show_signature_in_pum = 0  " This do disable full signature type on autocomplete
" tern
autocmd FileType javascript nnoremap <silent> <buffer> gb :TernDef<CR>

set rtp+=~/.fzf

" For conceal markers.
if has('conceal')
    set conceallevel=2 concealcursor=niv
endif


"nmap <CR> o<Esc>
"saves undos after a file has been closed
set undofile

" Syntastic
set autowrite                      " Automatically :write before running commands
syntax on
"set t_Co=2236
set cursorline                     " Highlight the current line
"set cursorcolumn
set backspace=2                    " Backspace deletes like most programs in insert mode
set expandtab                      " Tabs are spaces
set fileencoding=utf-8             " The encoding written to file
set fileformat=unix                " That LF life, son
"set hlsearch                       " Highlight searches
" map escape to clear highlights
nnoremap <silent> <esc> :noh<cr><esc>
set ignorecase                     " Ignore case when searching
"set number                         " Show line numbers all of the times
"set rnu                            "show relative line numbers
set showcmd                        " Display incomplete commands
" set ttimeoutlen=0u"  THIS BREAKS DEOPLETE                 " No delay after pressing escape
set nowrap
" set paste
" set modifiable " makes the buffer modifiable
" filetype plugin indent on
filetype plugin on
syntax enable
set background=dark
"colorscheme monokai
set t_Co=256
colo xoria256

"for HTML
filetype indent on  

autocmd FileType javascript vnoremap <buffer>  <c-f> :call RangeJsBeautify()<cr>
autocmd FileType json vnoremap <buffer> <c-f> :call RangeJsonBeautify()<cr>
autocmd FileType jsx vnoremap <buffer> <c-f> :call RangeJsxBeautify()<cr>
autocmd FileType html vnoremap <buffer> <c-f> :call RangeHtmlBeautify()<cr>
autocmd FileType css vnoremap <buffer> <c-f> :call RangeCSSBeautify()<cr>



" "color the status based on insert mode
" " first, enable status line always
set laststatus=2
"
" " now set it up to change the status line based on mode
if version >= 700
    au InsertEnter * hi StatusLine term=reverse ctermbg=5 gui=undercurl guisp=Magenta
    au InsertLeave * hi StatusLine term=reverse ctermfg=0 ctermbg=2 gui=bold,reverse
endif


" " persist the yanked clipboard
xnoremap p pgvy
set clipboard=unnamed

" Turn on case insensitive feature
let g:EasyMotion_smartcase = 1
set ignorecase
set smartcase
"applies substitutions globally on lines. For example, instead of :%s/foo/bar/g you just type :%s/foo/bar/
set gdefault
"Indent stuff
set smartindent
set autoindent
"work together to highlight search results (as you type). It’s really quite handy, as long as you have the next line as well.
set incsearch
set showmatch
set hlsearch


" " size of a hard tabstop
set tabstop=4
let g:netrw_banner=0
let g:netrw_preview = 1
let g:netrw_liststyle=1
let g:netrw_list_hide = '\(^\|\s\s\)\zs\.\S\+'


set history=1000         " remember more commands and search history
set undolevels=1000   

" "indenting---
set shiftwidth=4 

let g:GrepRoot = '.'
set statusline+=%#warningmsg#
set statusline+=%{exists('g:loaded_syntastic_plugin')?SyntasticStatuslineFlag():''}

set statusline+=%*
set statusline+=%f
set statusline+=%=

set statusline+=%l/%L
set statusline+=\ %P
" Change directory to the current buffer when opening files. NETRW
"set autochdir
"Vim diff - change the color scheme
highlight DiffAdd cterm=none ctermfg=bg ctermbg=Green gui=none guifg=bg guibg=Green
highlight DiffDelete cterm=none ctermfg=bg ctermbg=Red gui=none guifg=bg guibg=Red
highlight DiffChange cterm=none ctermfg=bg ctermbg=Yellow gui=none guifg=bg guibg=Yellow
highlight DiffText cterm=none ctermfg=bg ctermbg=Magenta gui=none guifg=bg guibg=Magenta


"You can map this to a shortcuts. Here is a list of suggested shortcuts:
" Grep in current directory.
set grepprg=grep\ -RHIn\ --exclude=\".tags\"\ --exclude-dir=\".svn\"\ --exclude-dir=\".git\"

" vim-plug *****************************************
"  *****************************************
call plug#begin('~/.vim/plugged')
" relevant javascript + jsx packages
Plug 'mxw/vim-jsx'
Plug 'pangloss/vim-javascript'
Plug 'othree/javascript-libraries-syntax.vim'
"""
Plug 'rizzatti/dash.vim'
Plug 'dkprice/vim-easygrep'
Plug 'benekastah/neomake'
Plug 'raimondi/delimitmate'
"Plug 'carlitux/deoplete-ternjs'
Plug 'scrooloose/nerdcommenter'
Plug 'easymotion/vim-easymotion'
Plug 'othree/yajs.vim', { 'for': 'javascript' }
function! DoRemote(arg)
    UpdateRemotePlugins
endfunction
function! DoRemote(arg)
    UpdateRemotePlugins
endfunction
Plug 'Shougo/deoplete.nvim', { 'do': function('DoRemote') }
Plug 'ternjs/tern_for_vim', { 'do': 'npm install' }
" Add plugins to &runtimepath
call plug#end()

