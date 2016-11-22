" vim-plug *****************************************
"  *****************************************
call plug#begin('~/.vim/plugged')
" relevant javascript + jsx packages
Plug 'mxw/vim-jsx'
Plug 'pangloss/vim-javascript'
Plug 'othree/javascript-libraries-syntax.vim'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' } 
Plug 'junegunn/fzf.vim'
Plug 'arames/vim-async-grep'
Plug 'flazz/vim-colorschemes'
Plug 'jiangmiao/auto-pairs'
Plug 'rizzatti/dash.vim'
Plug 'honza/vim-snippets'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'ternjs/tern_for_vim', { 'for': ['javascript', 'javascript.jsx'] }
Plug 'carlitux/deoplete-ternjs', { 'for': ['javascript', 'javascript.jsx'] }
Plug 'othree/jspc.vim', { 'for': ['javascript', 'javascript.jsx'] }
Plug 'dkprice/vim-easygrep'
Plug 'benekastah/neomake'
Plug 'raimondi/delimitmate'
Plug 'carlitux/deoplete-ternjs'
Plug 'scrooloose/nerdcommenter'
Plug 'easymotion/vim-easymotion'
Plug 'othree/yajs.vim', { 'for': 'javascript' }
Plug 'DirDiff.vim'
Plug 'altercation/vim-colors-solarized'
Plug 'tpope/vim-surround'

function! DoRemote(arg)
    UpdateRemotePlugins
endfunction
Plug 'Shougo/deoplete.nvim', { 'do': function('DoRemote') }
Plug 'ervandew/supertab'
Plug 'marijnh/tern_for_vim' , { 'do': 'npm install' } " Add plugins to &runtimepath
call plug#end()

let mapleader = " "

set runtimepath+=~/.nvim/plugged/deoplete.nvim 
let g:netrw_localrmdir='rm -r'

"autocmd InsertChange,TextChanged * update | Neomake
autocmd! BufWritePost * Neomake


let g:neomake_javascript_enabled_makers = ['eslint']
" open list Automatically
let g:neomake_verbose=1
let g:neomake_open_list = 2


let g:neomake_logfile = '/usr/local/var/log/neomake.log'

let g:jsx_ext_required = 0 " Allow JSX in normal JS files

let g:neomake_javascript_eslint_maker = {
\ 'args': ['--format', 'compact'],
\ 'errorformat': '%f: line %l\, col %c\, %m'
\ }
let g:neomake_warning_sign = {
  \ 'text': '👋',
  \ 'texthl': 'WarningMsg',
  \ }
let g:neomake_error_sign = {
  \ 'text': '😱',
  \ 'texthl': 'ErrorMsg',
  \ }
"************ DEOPLETE ***********
let g:deoplete#enable_at_startup = 1
if !exists('g:deoplete#omni#input_patterns')
  let g:deoplete#omni#input_patterns = {}
endif
" let g:deoplete#disable_auto_complete = 1
"autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif

" omnifuncs
augroup omnifuncs
    autocmd!
    autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
    autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
    au FileType javascript,jsx setl omnifunc=tern#Complete
    autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
    autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
augroup end

let g:deoplete#omni#functions = {}
let g:deoplete#omni#functions.javascript = [
  \ 'tern#Complete',
  \ 'jspc#omni'
\]

autocmd FileType javascript let g:SuperTabDefaultCompletionType = "<c-x><c-o>"
let g:UltiSnipsExpandTrigger="<C-j>"
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" tern
if exists('g:plugs["tern_for_vim"]')
    let g:tern_show_argument_hints = 'on_hold'
    let g:tern_show_signature_in_pum = 1
    autocmd FileType javascript setlocal omnifunc=tern#Complete
endif
"
autocmd FileType javascript nnoremap <silent> <buffer> gb :TernDef<CR>
"
" Use deoplete.
let g:tern_request_timeout = 1
let g:tern_show_signature_in_pum = 0  " This do disable full signature type on autocomplete
"
" tern
autocmd FileType javascript nnoremap <silent> <buffer> gb :TernDef<CR>

set rtp+=~/.fzf

"set directory for swap files
set directory=~/dotfiles/swap-files

" For conceal markers.
if has('conceal')
    set conceallevel=2 concealcursor=niv
endif

"******************************* KEY BINDINGS ******************************* 
"DEOPLETE
" deoplete tab-complete
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"
" tern
autocmd FileType javascript nnoremap <silent> <buffer> gb :TernDef<CR>
"fzf
nmap <Leader>. :FZF<CR> 
" Can be typed even faster than jj. Exit Insert Mode
imap jk <Esc>
"split navigation
"nmap <Leader>l :wincmd l<CR>
"nmap <Leader>j :wincmd j<CR>
"nmap <Leader>k :wincmd k<CR>
"nmap <Leader>h :wincmd h<CR>
nmap <Leader>; :wincmd w<CR>
"Resize vertical split
nmap <Leader>h :vertical resize -5<CR>
nmap <Leader>l :vertical resize +5<CR>
nmap <Leader>j :resize +5<CR>
nmap <Leader>k :resize -5<CR>

nmap <Leader>a ggVG<CR>
map <Leader> <Plug>(easymotion-prefix)
" open docs
nmap <silent> <leader>d <Plug>DashSearch
"
" neomake
nmap <Leader>o :lopen<CR>      " open location window
nmap <Leader>c :lclose<CR>     " close location window
nmap <Leader>, :ll<CR>         " go to current error/warning
nmap <Leader>n :lnext<CR>      " next error/warning
nmap <Leader>p :lprev<CR>      " previous error/warning
nmap tt :tabedit %<CR>
nmap td :tabclose<CR>

"nmap <silent> <leader>§ <Plug>:Files
"Map Escape to close terminal mode
tnoremap <Esc> <C-\><C-n>
"Terminal nav mappings
tnoremap <A-h> <C-\><C-n><C-w>h
tnoremap <A-j> <C-\><C-n><C-w>j
tnoremap <A-k> <C-\><C-n><C-w>k
tnoremap <A-l> <C-\><C-n><C-w>l
nnoremap <A-h> <C-w>h
nnoremap <A-j> <C-w>j
nnoremap <A-k> <C-w>k
" Key Bindings
"add a new line when pressing Enter without entering insert mode
nmap <S-Enter> O<Esc>
"nmap <CR> o<Esc>
" map escape to clear highlights
nnoremap <silent> <esc> :noh<cr><esc>
"saves undos after a file has been closed
set undofile
set hidden
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
set t_Co=256
"colo xoria256
colorscheme solarized

"for HTML
filetype indent on  
filetype plugin indent on  

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
" "INCREMENT AMND DECRMENT on ALt
nnoremap <C-x> <C-a>
nnoremap <C-z> <C-x>

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
" Grep for the word under the cursor.
nnoremap K :Grep "\\<<C-r><C-w>\\>" .<CR>
nmap <leader>grep K
" Versions suffixed with `l` for the location list cause vim to wait for keys
" after `grep`. Provide versions with extra characters to allow skipping the
" wait.
nmap <leader>grepc K
nmap <leader>grep<Space> K
nmap <leader>grep<CR> K
" Grep in the current file's path.
nmap <leader>grepd :Grep "\\<<C-r><C-w>\\>" %:p:h<CR>
" Grep for the text selected. Do not look for word boundaries.
vnoremap K "zy:<C-u>Grep "<C-r>z" .<CR>
vmap <leader>grep K
vmap <leader>grepd :Grep "\\<<C-r><C-w>\\>" %:p:h<CR>

" Same as above, but for the location list.
nnoremap <F9> :GrepL "\\<<C-r><C-w>\\>" .<CR>
nmap <leader>grepl <F9>
nmap <leader>grepl<Space> <F9>
nmap <leader>grepl<CR> <F9>
nmap <leader>grepld :GrepL "\\<<C-r><C-w>\\>" %:p:h<CR>
vnoremap <F9> "zy:<C-u>GrepL "<C-r>z" .<CR>
vmap <leader>grepl <F9>
vmap <leader>grepld :GrepL "\\<<C-r><C-w>\\>" %:p:h<CR>
"TAB NAVIGATION
nnoremap ty  :tabnext<CR>
nnoremap tr  :tabprev<CR>
