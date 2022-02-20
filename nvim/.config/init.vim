"from primeagen https://github.com/ThePrimeagen/.dotfiles/blob/master/nvim/.config/nvim/init.vim
"see also the youtube video: https://www.youtube.com/watch?v=hSHATqh8svM
nnoremap Y y$

inoremap . .<c-g>u
inoremap , ,<c-g>u
inoremap ! !<c-g>u
inoremap ? ?<c-g>u

vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv
" inoremap <C-j> <esc>:m .+1<CR>==
" inoremap <C-k> <esc>:m .-2<CR>==
nnoremap <leader>j :m .+1<CR>==
nnoremap <leader>k :m .-2<CR>==
" greatest remap ever
xnoremap <leader>p "_dP

" Fake tabout because it's not working for me (whyyyy :(()
inoremap <leader><leader> <esc>la

"set foldmethod=expr
"set foldexpr=nvim_treesitter#foldexpr()

call plug#begin('~/.vim/plugged')

"language server protocol default setup stuff
Plug 'neovim/nvim-lspconfig'

"Markdown preview and renderer
Plug 'junegunn/goyo.vim'

" Telescope stuff
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-file-browser.nvim'
Plug 'kyazdani42/nvim-web-devicons'

"automatic linting + formatting on save
Plug 'jose-elias-alvarez/null-ls.nvim'
Plug 'jose-elias-alvarez/nvim-lsp-ts-utils'

" Discord rich presence integration
Plug 'andweeb/presence.nvim'

" Tree sitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'windwp/nvim-autopairs' " auto close brackets
Plug 'windwp/nvim-ts-autotag'

" Harpoon
Plug 'ThePrimeagen/harpoon'

" Comment
Plug 'numToStr/Comment.nvim'
Plug 'JoosepAlviste/nvim-ts-context-commentstring'

" Tab out of brackets, quotes, etc.
Plug 'abecodes/tabout.nvim'

call plug#end()

set tabstop=4
set number
set shiftwidth=4
set expandtab

" Find files using Telescope command-line sugar.
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>



" all packer stuff
lua require('plugins')

lua require('lsp')
lua require('init')
lua require('telescope_setup')
lua require('completion')
lua require('luasnipConfig')

" imap <silent><expr> <c-k> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : 
" inoremap <silent> <c-j> <cmd> lua require('luasnip').jump(-1)<Cr>


set background = "dark"
let g:gruvbox_transparent_bg = '1'
colorscheme default
highlight Normal     ctermbg=NONE guibg=NONE
set colorcolumn=80
