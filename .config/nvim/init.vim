" Basic Settings
set number
set relativenumber
set mouse=a
set clipboard=unnamedplus
set tabstop=4
set shiftwidth=4
set expandtab
set smartindent
set nowrap
set termguicolors
set hidden
set signcolumn=yes

" Leader key
let mapleader = " "

" Keymaps
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>

" Plugins (using vim-plug)
call plug#begin('~/.local/share/nvim/plugged')

" Fuzzy Finder
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-lua/plenary.nvim'

" Syntax Highlighting
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

Plug 'plasticboy/vim-markdown'
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_conceal = 0
let g:vim_markdown_math = 1

" LSP and Autocompletion
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'

" Theme
Plug 'morhetz/gruvbox'

call plug#end()

" Colorscheme
colorscheme gruvbox
set background=dark

" Treesitter setup
autocmd VimEnter * :TSUpdate
