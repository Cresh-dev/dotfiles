set nocompatible
filetype plugin indent on
syntax on
set encoding=utf-8

set number

set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set smartindent

set nowrap
set mouse=a
set clipboard=unnamedplus

set ignorecase
set smartcase
set incsearch
set hlsearch

set splitbelow
set splitright

set termguicolors

set ttyfast
set lazyredraw

call plug#begin('~/.vim/plugged')

Plug 'jacoborus/tender.vim'

Plug 'preservim/nerdtree'

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

Plug 'tpope/vim-commentary'

Plug 'sheerun/vim-polyglot'

call plug#end()

colorscheme tender
highlight Normal guibg=NONE ctermbg=NONE
highlight NonText guibg=NONE ctermbg=NONE
highlight LineNr guibg=NONE ctermbg=NONE
highlight SignColumn guibg=NONE ctermbg=NONE
set background=dark
let mapleader=" "  " Tasto leader: spazio

nnoremap <leader>n :NERDTreeToggle<CR>

nnoremap <leader>f :Files<CR>

nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>

nnoremap <leader>c gcc
vnoremap <leader>c gc
