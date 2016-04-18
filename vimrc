execute pathogen#infect()
Helptags

let mapleader=" "
map <Leader> <Plug>(easymotion-prefix)


" open docs
nmap <silent> <leader>d <Plug>DashSearch
let g:deoplete#enable_at_startup = 1
set hidden

let g:neomake_javascript_enabled_makers = ['eslint']

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
  autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
  autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
augroup end
" tern
if exists('g:plugs["tern_for_vim"]')
  let g:tern_show_argument_hints = 'on_hold'
  let g:tern_show_signature_in_pum = 1
  autocmd FileType javascript setlocal omnifunc=tern#Complete
endif

set rtp+=~/.fzf

" Plugin key-mappings. for NEO SNIPPET

" SuperTab like snippets behavior.
imap <expr><TAB> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : pumvisible() ? "\<C-n>" : "\<TAB>" 
smap <expr><TAB> neosnippet#expandable_or_jumpable() ? "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>" 

" For conceal markers.
if has('conceal')
  set conceallevel=2 concealcursor=niv
endif


nmap t% :tabedit %<CR>
nmap td :tabclose<CR>

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
"set number                         " Show line numbers all of the times
"set rnu                            "show relative line numbers
set showcmd                        " Display incomplete commands
" set ttimeoutlen=0u"  THIS BREAKS DEOPLETE                 " No delay after pressing escape
 set nowrap
" set paste
" set modifiable " makes the buffer modifiable
" filetype plugin indent on
" filetype plugin on
syntax enable
set background=dark
"colorscheme monokai
set t_Co=256
colo xoria256



 " JS Beautify
 map <c-f> :call JsBeautify()<cr>
  "or
 autocmd FileType javascript noremap <buffer>  <c-f> :call JsBeautify()<cr>
  "for html
 autocmd FileType html noremap <buffer> <c-f> :call HtmlBeautify()<cr>
  "for css or scss
 autocmd FileType css noremap <buffer> <c-f> :call CSSBeautify()<cr>
 autocmd FileType scss noremap <buffer> <c-f> :call CSSBeautify()<cr>

" "color the status based on insert mode
" " first, enable status line always
set laststatus=2

" "SCSS Auto complete
" autocmd BufNewFile,BufRead *.scss             set ft=scss.css
" set omnifunc=csscomplete#CompleteCSS
" autocmd FileType css set omnifunc=csscomplete#CompleteCSS



" au Filetype html,xml,xsl "source ~/dotfiles/vim/bundle/closetag.vim/
" let g:closetag_html_style=1
" "source ~/dotfiles/vim/bundle/closetag.vim/

" " now set it up to change the status line based on mode
if version >= 700
  au InsertEnter * hi StatusLine term=reverse ctermbg=5 gui=undercurl guisp=Magenta
  au InsertLeave * hi StatusLine term=reverse ctermfg=0 ctermbg=2 gui=bold,reverse
endif


" "Percent Function for scroll position
" function! Percent()
"     let byte = line2byte( line( "." ) ) + col( "." ) - 1
"     let size = (line2byte( line( "$" ) + 1 ) - 1)
"     " return byte . " " . size . " " . (byte * 100) / size
"     return (byte * 100) / size
" endfunction



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

" " JK motions: Line motions


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
 set autochdir
