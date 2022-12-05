" Supposed to transfer copy and paste, but not sure its working
source $VIMRUNTIME/mswin.vim

" initial options
syntax on
filetype plugin indent on

" tab settings
set tabstop=2
set expandtab
set softtabstop=2
set shiftwidth=2
set autoindent
set smartindent

" Plug ins

call plug#begin()
Plug 'neoclide/coc.nvim', {'branch': 'master', 'do': 'yarn install --frozen-lockfile'}
Plug 'preservim/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'gruvbox-community/gruvbox'
Plug 'kaicataldo/material.vim'
Plug 'sickill/vim-monokai'
call plug#end()

" use <tab> for trigger complete and navigate to the next compelete item
function! s:check_back_space() abort
    let col = col(',') - 1
    return !col || getline('.')[col -1] =~ '\s'
endfunction

" Tab autocomplete
inoremap <silent><expr> <Tab>
    \ pumvisible() ? "\<C-n>" :
    \ <SID>check_back_space() ? "\<Tab>" :
    \ coc#refresh()

" Ctrl B to toggle nerd tree
inoremap <c-b> <Esc>:NERDTreeToggle<cr>
nnoremap <c-b> <Esc>:NERDTreeToggle<cr>

" Theme stuff
set termguicolors
colo gruvbox


