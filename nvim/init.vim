if exists('veonim')
filetype plugin on

" built-in plugin manager
Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'easymotion/vim-easymotion'
" Plug 'flazz/vim-colorschemes'

" extensions for web dev
VeonimExt 'veonim/ext-css'
VeonimExt 'veonim/ext-json'
VeonimExt 'veonim/ext-html'
VeonimExt 'vscode:extension/sourcegraph.javascript-typescript'

" window nav
nnoremap <silent> <space>pj <C-W><C-J>
nnoremap <silent> <space>pk <C-W><C-K>
nnoremap <silent> <space>pl <C-W><C-L>
nnoremap <silent> <space>ph <C-W><C-H>

" workspace management
let g:vn_project_root = '~/proj'
nno <silent> <c-t>p :call Veonim('vim-create-dir', g:vn_project_root)<cr>
"nno <silent> ,r :call Veonim('change-dir', g:vn_project_root)<cr>

" multiplexed vim instance management
nno <silent> ,c :Veonim vim-create<cr>
nno <silent> ,s :Veonim vim-switch<cr>
nno <silent> ,n :Veonim vim-rename<cr>

" workspace functions
nno <silent> ,f :Veonim files<cr>
nno <silent> ,e :Veonim explorer<cr>
nno <silent> ,b :Veonim buffers<cr>
nno <silent> ,d :Veonim change-dir<cr>

" searching text
nno <silent> <space>fw :Veonim grep-word<cr>
vno <silent> <space>fw :Veonim grep-selection<cr>
nno <silent> <space>fa :Veonim grep<cr>
nno <silent> <space>ff :Veonim grep-resume<cr>
nno <silent> <space>fb :Veonim buffer-search<cr>

" color picker
nno <silent> sc :Veonim pick-color<cr>

" language server functions
nno <silent> sr :Veonim rename<cr>
nno <silent> sd :Veonim definition<cr>
nno <silent> st :Veonim type-definition<cr>
nno <silent> si :Veonim implementation<cr>
nno <silent> sf :Veonim references<cr>
nno <silent> sh :Veonim hover<cr>
nno <silent> sl :Veonim symbols<cr>
nno <silent> so :Veonim workspace-symbols<cr>
nno <silent> sq :Veonim code-action<cr>
nno <silent> sp :Veonim show-problem<cr>
nno <silent> sk :Veonim highlight<cr>
nno <silent> sK :Veonim highlight-clear<cr>
nno <silent> <c-n> :Veonim next-problem<cr>
nno <silent> <c-p> :Veonim prev-problem<cr>
nno <silent> ,n :Veonim next-usage<cr>
nno <silent> ,p :Veonim prev-usage<cr>
nno <silent> <space>pt :Veonim problems-toggle<cr>
nno <silent> <space>pf :Veonim problems-focus<cr>
nno <silent> <d-o> :Veonim buffer-prev<cr>
nno <silent> <d-i> :Veonim buffer-next<cr>

set smartindent
set autoindent
set smarttab
set cindent
set tabstop=2
set shiftwidth=2
filetype indent on
filetype plugin indent on

" " persist the yanked clipboard
xnoremap p pgvy
set clipboard=unnamed
set nowrap
"
let g:netrw_localrmdir='rm -r'
let g:netrw_liststyle= 3

let g:vn_font_size = 13


" " persist the yanked clipboard
xnoremap p pgvy
set clipboard=unnamed



"KEY BINDINGS
let mapleader = " "
map <Leader> <Plug>(easymotion-prefix)
set hlsearch!
nnoremap <F3> :set hlsearch!<CR>
command! E Explore

endif
