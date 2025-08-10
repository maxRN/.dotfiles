vim.pack.add({
    "https://github.com/stevearc/oil.nvim",
})
-- Oil.nvim
vim.keymap.set("n", "-", ":Oil<CR>")
require("oil").setup(
    {
        keymaps = {
            ["<C-p>"] = false
        }
    }
)
