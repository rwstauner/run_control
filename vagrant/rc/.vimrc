" common settings

set nocompatible

set hlsearch
set laststatus=2
set lazyredraw
set number
set report=0
set showcmd
set showmode
set ttyfast

" custom prefs

set     encoding=utf-8
set termencoding=utf-8

set   background=dark
set   listchars=tab:▸\ ,extends:⇢,precedes:⇠,nbsp:☐,trail:⬚ "eol:¬, " hooray for unicode
set   showbreak=⦉  " show start of wrapped lines
set   tildeop

set ignorecase smartcase

set autoindent nosmartindent
set textwidth=80 colorcolumn=+0

set rtp ^=$HOME/.vagrant.rc/rc/vim

colorscheme deserted

set ts=2 sts=2 sw=2 et sta

syntax enable
filetype plugin indent on
