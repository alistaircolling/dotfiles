execute pathogen#infect()
Helptags
"open in a split if a file contains unsaved edits
set nohidden


set nocp
" Use Mouse
set mouse=a
set ttymouse=xterm2
set ttyfast
set ttyscroll=3
set mousefocus
"clear search my leader space
nnoremap <leader><space> :noh<cr>
"let g:NERDTreeMouseMode=3

" Key Bindings
nmap <C-n> :NERDTreeToggle<CR>
"add a new line when pressing Enter without entering insert mode
nmap <S-Enter> O<Esc>
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
set hlsearch                       " Highlight searches
set ignorecase                     " Ignore case when searching
set number                         " Show line numbers all of the times
set rnu                            "show relative line numbers
set showcmd                        " Display incomplete commands
set ttimeoutlen=0                 " No delay after pressing escape
set nowrap
set paste
set modifiable " makes the buffer modifiable
filetype plugin indent on
filetype plugin on

" Add solarized theme
syntax enable
set background=dark
"colorscheme solarized
colorscheme monokai
set t_Co=256
":colo xoria256



" JS Beautify
map <c-f> :call JsBeautify()<cr>
" or
autocmd FileType javascript noremap <buffer>  <c-f> :call JsBeautify()<cr>
" for html
autocmd FileType html noremap <buffer> <c-f> :call HtmlBeautify()<cr>
" for css or scss
autocmd FileType css noremap <buffer> <c-f> :call CSSBeautify()<cr>
autocmd FileType scss noremap <buffer> <c-f> :call CSSBeautify()<cr>

"toggle highlighting (e.g. on search)
map <c-h> :noh<cr>
"color the status based on insert mode
" first, enable status line always
set laststatus=2

"SCSS Auto complete
autocmd BufNewFile,BufRead *.scss             set ft=scss.css
set omnifunc=csscomplete#CompleteCSS
autocmd FileType css set omnifunc=csscomplete#CompleteCSS



au Filetype html,xml,xsl "source ~/dotfiles/vim/bundle/closetag.vim/
let g:closetag_html_style=1
"source ~/dotfiles/vim/bundle/closetag.vim/

" now set it up to change the status line based on mode
if version >= 700
  au InsertEnter * hi StatusLine term=reverse ctermbg=5 gui=undercurl guisp=Magenta
  au InsertLeave * hi StatusLine term=reverse ctermfg=0 ctermbg=2 gui=bold,reverse
endif


"Percent Function for scroll position
function! Percent()
    let byte = line2byte( line( "." ) ) + col( "." ) - 1
    let size = (line2byte( line( "$" ) + 1 ) - 1)
    " return byte . " " . size . " " . (byte * 100) / size
    return (byte * 100) / size
endfunction



" persist the yanked clipboard
xnoremap p pgvy
set clipboard=unnamed

"syntastic errpr checking
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
""ignore attribute errors (e.g. angular directives)

"let g:syntastic_html_tidy_ignore_errors=[" proprietary attribute " ]
""always check while editing
"let g:syntastic_auto_loc_list=1
let g:EasyMotion_do_mapping = 0 " Disable default mappings


let delimitMate_expand_cr = 1
filetype indent plugin on

let g:CommandTWildIgnore=&wildignore . ",**/node_modules/*,**/dist/*,*.svg,*.jpg"
"Set default search directory to src
let g:CommandTTraverseSCM = 'src'
let g:CommandTHighlightColor = 'DiffText'
let g:CommandTCursorColor = 'DiffText'
"SEARCH AND REPLACE
:map <C-h> :%s/


"snipmate mapping
:imap <Tab> <Plug>snipMateTrigger


" Bi-directional find motion
" Jump to anywhere you want with minimal keystrokes, with just one key binding.
" `s{char}{label}`
"nmap s <Plug>(easymotion-s)
" or
" `s{char}{char}{label}`
" Need one more keystroke, but on average, it may be more comfortable.
"nmap s <Plug>(easymotion-s2)

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

" JK motions: Line motions
map <Leader>j <Plug>(easymotion-j)
map <Leader>k <Plug>(easymotion-k)
highlight Pmenu ctermfg=2 ctermbg=20 guifg=#ffffff guibg=#0000ff

"let g:syntastic_typescript_tsc_args = '--target ES5'
"let g:syntastic_debug=3
"let g:syntastic_typescript_checkers = ['tslint', 'tsc']
let g:syntastic_html_tidy_ignore_errors = ['is not recognized!', 'content occurs after end of body', 'discarding unexpected\']
let g:syntastic_html_tidy_quiet_messages = { "level" : "warnings", "type": "style" }
let g:syntastic_quiet_messages = { "type": "style" }

" size of a hard tabstop
set tabstop=4
"au VimEnter *  NERDTree

hi TabLineFill ctermfg=Black ctermbg=DarkGreen
"hi TabLine ctermfg=Blue ctermbg=20
hi TabLineSel ctermfg=Red ctermbg=Yellow
let g:netrw_banner=0
"allows previewing of file by pressing p 
let g:netrw_preview = 1

"disable "arrow keys
"noremap <Up> <NOP>
"noremap <Down> <NOP>
"noremap <Left> <NOP>
"noremap <Right> <NOP>

"file browser:
let g:netrw_liststyle=1
let g:netrw_list_hide = '\(^\|\s\s\)\zs\.\S\+'
"stop the scratch window appearing when autocomplete goes...
set completeopt-=preview


"react highlighting:
"let g:jsx_ext_required = 0
let g:syntastic_javascript_checkers = ['eslint']

"let g:syntastic_javascript_checkers = ['jsxhint']
"let g:syntastic_javascript_jsxhint_exec = 'jsx-jshint-wrapper'

"indenting---
set shiftwidth=4 
"INCREMENT AMND DECRMENT on ALt
nnoremap <C-x> <C-a>
nnoremap <C-z> <C-x>

let g:GrepRoot = '.'
set statusline+=%#warningmsg#
set statusline+=%{exists('g:loaded_syntastic_plugin')?SyntasticStatuslineFlag():''}
"set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
set statusline+=%f
set statusline+=%=
"set statusline+=%c,
set statusline+=%l/%L
set statusline+=\ %P
" Change directory to the current buffer when opening files. NETRW
set autochdir
