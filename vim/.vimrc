" -----------------------------
"   BASIC SETTINGS
" -----------------------------
set nocompatible
filetype plugin indent on      " enable filetype detection, plugins and indentation
syntax on                      " enable syntax highlighting
set encoding=utf-8             " use UTF-8 encoding

" Line numbering
set number                     " show absolute line numbers
set relativenumber             " show relative numbers for easier navigation

" Tabs and indentation
set tabstop=4                  " number of spaces that a <Tab> counts for
set shiftwidth=4               " number of spaces to use for autoindent
set expandtab                  " convert tabs to spaces
set autoindent                 " maintain indent from previous line
set smartindent                " smart autoindenting for new lines

" Show whitespace characters
set list
set listchars=tab:»·,trail:·,extends:>,precedes:<

" Search settings
set ignorecase                 " ignore case in search
set smartcase                  " case-sensitive if uppercase letters used
set incsearch                  " show search matches as you type
set hlsearch                   " highlight all search matches

" Splits
set splitbelow                 " new horizontal splits below
set splitright                 " new vertical splits to the right

" Colors
set termguicolors
set background=dark

" Performance
set ttyfast
set lazyredraw

" Backspace behavior
set backspace=indent,eol,start

" History and undo
set history=1000
set undofile                   " enable persistent undo
set undodir=~/.vim/undodir

" Highlight current line
set cursorline

" Enable mouse
set mouse=a

" Clipboard (optional, use + register for system clipboard)
" set clipboard=unnamedplus


" -----------------------------
"   PLUGINS (vim-plug)
" -----------------------------
call plug#begin('~/.vim/plugged')

" Color scheme
Plug 'jacoborus/tender.vim'

" File explorer
Plug 'preservim/nerdtree'

" Fuzzy file search
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Status line
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Easy commenting
Plug 'tpope/vim-commentary'

" Syntax highlighting for many languages
Plug 'sheerun/vim-polyglot'

" Surroundings (parentheses, quotes, tags)
Plug 'tpope/vim-surround'

" Auto-close parentheses, quotes, etc.
Plug 'jiangmiao/auto-pairs'

call plug#end()


" -----------------------------
"   COLORSCHEME & HIGHLIGHT
" -----------------------------
colorscheme tender
highlight Normal guibg=NONE ctermbg=NONE
highlight NonText guibg=NONE ctermbg=NONE
highlight LineNr guibg=NONE ctermbg=NONE
highlight SignColumn guibg=NONE ctermbg=NONE


" -----------------------------
"   KEY MAPPINGS
" -----------------------------
let mapleader=" "  " Leader key = space

" NERDTree toggle
nnoremap <leader>n :NERDTreeToggle<CR>

" FZF file search
nnoremap <leader>f :Files<CR>

" Move between splits
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Save and quit
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>

" Comment/uncomment lines
nnoremap <leader>c gcc
vnoremap <leader>c gc

