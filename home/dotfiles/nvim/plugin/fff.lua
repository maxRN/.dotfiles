vim.pack.add({ "https://github.com/dmtrKovalenko/fff" })

vim.keymap.set("n", "<leader>rg", function()
    require("fff").live_grep()
end, { desc = "fff: live grep" })
