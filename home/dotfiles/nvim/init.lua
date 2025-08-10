---get rid of undefined "vim" global warning
---@diagnostic disable: undefined-global
vim.pack.add({
    "https://github.com/folke/tokyonight.nvim",
    "https://github.com/nvim-tree/nvim-web-devicons",
})

vim.cmd.colorscheme("tokyonight")

vim.g.mapleader = " "
vim.keymap.set("n", "<leader>so", ":source<CR>")

-- vim.keymap.set("n", "<C-d>", "<C-d>zz")
-- vim.keymap.set("n", "<C-u>", "<C-u>zz")
--
-- vim.keymap.set("n", "n", "nzzzv")
-- keymap.set("n", "N", "Nzzzv")
vim.keymap.set("i", "<C-c>", "<Esc>")
vim.keymap.set("n", "Q", "<nop>", { desc = "I hate this and never used it. Ever." })
vim.keymap.set("n", "<leader>d", "\"_d")
vim.keymap.set("x", "<leader>d", "\"_d")

vim.opt.relativenumber = true
vim.opt.nu = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 50
vim.opt.colorcolumn = "80"
vim.opt.clipboard = "unnamedplus"
vim.opt.winborder = 'rounded'

require("plugins.lsp")
require("plugins.neogit")
require("plugins.oil")
require("plugins.fzf-lua")
require("plugins.conform")
require("plugins.nvim-lint")
require("plugins.harpoon")
require("plugins.rustaceanvim")
require("plugins.treesitter")
-- require("plugins.blink")
