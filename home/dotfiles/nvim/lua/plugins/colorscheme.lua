vim.pack.add({
    "https://github.com/folke/tokyonight.nvim",
})
vim.cmd.colorscheme("tokyonight")
vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "#AAAAAA" })
vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#AAAAAA" })
vim.api.nvim_set_hl(0, "LineNr", { fg = "#FFFFFF" })
