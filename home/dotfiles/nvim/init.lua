---get rid of undefined "vim" global warning
---@diagnostic disable: undefined-global
vim.pack.add({
    "https://github.com/nvim-tree/nvim-web-devicons",
})

vim.g.mapleader = " "
vim.keymap.set("n", "<leader>so", ":source<CR>")
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

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
vim.opt.undofile = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.colorcolumn = "80"
vim.opt.winborder = 'rounded'

require("plugins.colorscheme")
require("plugins.lsp")
require("plugins.neogit")
require("plugins.oil")
require("plugins.fzf-lua")
require("plugins.conform")
require("plugins.nvim-lint")
require("plugins.harpoon")
require("plugins.rustaceanvim")
require("plugins.treesitter")
require("plugins.typst-preview")
-- require("plugins.blink")
