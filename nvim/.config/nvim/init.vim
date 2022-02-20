"from primeagen https://github.com/ThePrimeagen/.dotfiles/blob/master/nvim/.config/nvim/init.vim
"see also the youtube video: https://www.youtube.com/watch?v=hSHATqh7svM
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

set tabstop=4
set number
set shiftwidth=4
set expandtab

" Find files using Telescope command-line sugar.
nnoremap <space>ff <cmd>lua require('telescope.builtin').find_files()<cr>
nnoremap <space>fg <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap <space>fb <cmd>lua require('telescope.builtin').buffers()<cr>
nnoremap <space>fh <cmd>lua require('telescope.builtin').help_tags()<cr>
nnoremap <space>fr <cmd>lua require('telescope.builtin').lsp_references()<cr>

" all packer stuff
lua require('plugins')

lua require('lsp')
lua require('init')
lua require('telescope_setup')
lua require('completion')
lua require('luasnipConfig')

" imap <silent><expr> <c-k> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : 
" inoremap <silent> <c-j> <cmd> lua require('luasnip').jump(-1)<Cr>

set termguicolors
set background = "dark"
colorscheme gruvbox
highlight Normal     ctermbg=NONE guibg=NONE
set colorcolumn=80
