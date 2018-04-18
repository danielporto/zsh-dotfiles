call plug#begin()
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-fugitive'
"Plug 'vim-gitgutter'
Plug 'jelera/vim-javascript-syntax'
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'
"Plug 'kovetskiy/sxhkd-vim'
Plug 'chrisbra/Colorizer'
"Colors
Plug 'flazz/vim-colorschemes'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'Raimondi/delimitMate'
"Plug 'mhartington/oceanic-next'
Plug 'bling/vim-airline'
Plug 'vim-airline/vim-airline-themes'
"Plug 'evanmiller/nginx-vim-syntax'
" add terraform support
Plug 'hashivim/vim-terraform'
"Plug 'juliosueiras/vim-terraform-completion'
Plug 'vim-syntastic/syntastic'
"autocomplete
Plug 'valloric/youcompleteme'
"filemanager inside vim
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'jlanzarotta/bufexplorer'
"improve color visibility
Plug 'godlygeek/csapprox'
"generate markdown table of contents
Plug 'mzlogin/vim-markdown-toc'
call plug#end()

" Make Vim more useful
set nocompatible
" Use the OS clipboard by default (on versions compiled with `+clipboard`)
set clipboard=unnamed
" Enhance command-line completion
set wildmenu
" Allow cursor keys in insert mode
set esckeys
" Allow backspace in insert mode
set backspace=indent,eol,start
" Optimize for fast terminal connections
set ttyfast
" Add the g flag to search/replace by default
set gdefault
" Use UTF-8 without BOM
set encoding=utf-8 nobomb
" Change mapleader
let mapleader=","
" Don’t add empty newlines at the end of files
set binary
set noeol
" Centralize backups, swapfiles and undo history
set backupdir=~/.vim/backups
set directory=~/.vim/swaps
if exists("&undodir")
  set undodir=~/.vim/undo
endif

" Enable per-directory .vimrc files and disable unsafe commands in them
set exrc
set secure
" Enable line numbers
set number
" Show “invisible” characters
set lcs=tab:▸\ ,trail:·,eol:¬,nbsp:_
set list
" Highlight searches
set hlsearch
" Ignore case of searches
set ignorecase
" Highlight dynamically as pattern is typed
set incsearch
" Enable mouse in all modes
set mouse=a
" Tabs to spaces
set expandtab
" 2 spaces
set tabstop=2
set shiftwidth=2

set t_Co=256
colorscheme molokai 
set background=dark

" terraform linter configuration ---------------------------
set nocompatible
syntax on
filetype plugin indent on

" Syntastic Config
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_loc_list_height=5
let syntastic_quiet_messages = {
        \ "!level":  "errors",
        \ "type":    "style",
        \ "regex":   '.*',
        \ "file:p":  '.*' }
set completeopt-=preview

" (Optional)Hide Info(Preview) window after completions
autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
autocmd InsertLeave * if pumvisible() == 0|pclose|endif

" (Optional) Enable terraform plan to be include in filter
let g:syntastic_terraform_tffilter_plan = 1

" (Optional) Default: 0, enable(1)/disable(0) plugin's keymapping
let g:terraform_completion_keys = 1

" (Optional) Default: 1, enable(1)/disable(0) terraform module registry completion
let g:terraform_registry_module_completion = 0

" activate NERDtree at startup
" autocmd vimenter * NERDTree