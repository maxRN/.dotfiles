let mapleader = " "
"from primeagen https://github.com/ThePrimeagen/.dotfiles/blob/master/nvim/.config/nvim/init.vim
"see also the youtube video: https://www.youtube.com/watch?v=hSHATqh8svM
nnoremap Y y$

inoremap . .<c-g>u
inoremap , ,<c-g>u
inoremap ! !<c-g>u
inoremap ? ?<c-g>u

nnoremap <leader>en <cmd>tabnew ~/.config/nvim/<cr>

" nnoremap J :m '>+1<CR>gv=gv
" vnoremap K :m '<-2<CR>gv=gv
" inoremap <C-j> <esc>:m .+1<CR>==
" inoremap <C-k> <esc>:m .-2<CR>==
" nnoremap <leader>j :m .+1<CR>==
" nnoremap <leader>k :m .-2<CR>==
" greatest remap ever
" xnoremap <leader>p "_dP

" Fake tabout because it's not working for me (whyyyy :(()
inoremap <Tab> <esc>la

set tabstop=4
set number
set shiftwidth=4
set expandtab
set nowrap
set relativenumber
" For auto save
set autowriteall
set statusline=3
" Change where new split windows open
set splitright
set splitbelow
set encoding=utf-8
set fileencoding=utf-8

" Abbreviations and fixes for common spelling errors
iab teh the

inoremap ##O <C-v>u00d6
inoremap ##o <C-v>u00f6
inoremap ##A <C-v>u00c4
inoremap ##a <C-v>u00e4
inoremap ##U <C-v>u00dc
inoremap ##u <C-v>u00fc
inoremap ##s <C-v>u00df

" Find files using Telescope command-line sugar.
nnoremap <C-p> <cmd>lua require('telescope.builtin').find_files()<cr>
nnoremap <leader>rg <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap <leader>t <cmd>Telescope tele_tabby list<cr>
nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>
nnoremap <leader>fb <cmd>Telescope file_browser<cr>
nnoremap <leader>fr <cmd>lua require('telescope.builtin').lsp_references()<cr>
nnoremap <leader>o <cmd>lua require('telescope.builtin').lsp_document_symbols()<cr>
nnoremap <leader>hh <cmd>Telescope heading<cr>

" all packer stuff
lua require('plugins')
lua require('globals')

lua require('treesitter')
lua require('lsp')
lua require('init')
lua require('telescope_setup')
lua require('completion')
lua require('luasnipConfig')

set termguicolors
set background=light
colorscheme gruvbox
highlight Normal     ctermbg=NONE guibg=NONE
set colorcolumn=80
