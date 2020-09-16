set number
set relativenumber
syntax enable
set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundlenVim/Vundle.vim'
Plugin 'chriskempson/base16-vim'
Plugin 'lervag/vimtex'
Plugin 'preservim/nerdtree'
Plugin 'junegunn/fzf'
Plugin 'junegunn/fzf.vim'
"Plugin 'dylanaraps/wal'

call vundle#end()
"execute pathogen#infect()

filetype plugin on

set nocompatible		" use vim defaults instead of vi
set encoding=utf-8		" always encode in utf

" Tabs
set autoindent						" copy indent from previous line
"set noexpandtab						" no replace tabs with spaces
set expandtab
set shiftwidth=2					" spaces for autoindenting
"set shiftwidth=4					" spaces for autoindenting
set smarttab						" <BS> removes shiftwidth worth of spaces
set softtabstop=2					" spaces for editing, e.g. <Tab> or <BS>
"set softtabstop=4					" spaces for editing, e.g. <Tab> or <BS>
set tabstop=2						" spaces for <Tab>
"set tabstop=4						" spaces for <Tab>
set t_Co=256


let base16colorspace=256
colorscheme base16-default-dark
"set background=dark " dark | light "
set background=light
"set background=dark
"colorscheme solarized
"colorscheme badwolf

"hi LineNr guibg=grey

" Makes the line numbers clear
highlight clear LineNr
highlight clear CursorLineNr


" NERDTree
" Sets the default of .vim files to be interpreted
" as latex files
let g:tex_flavor = 'latex'
nmap <C-n> :NERDTreeToggle<CR>



