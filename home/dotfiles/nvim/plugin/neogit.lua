vim.pack.add({
    "https://github.com/NeogitOrg/neogit",
    "https://github.com/sindrets/diffview.nvim",
    "https://github.com/nvim-lua/plenary.nvim",
})
require("neogit").setup()
vim.keymap.set("n", "<leader>gs", ":Neogit<CR>")
