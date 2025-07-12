vim.keymap.set("n", "<leader>tb", function()
    require("dap").toggle_breakpoint()
end, { desc = "[T]oggle [b]reakpoint." })

vim.keymap.set("n", "<leader>ds", function()
    vim.cmd("RustLsp debug")
end, { desc = "Start debugging thing under cursor." })

vim.keymap.set("n", "<leader>dl", function()
    vim.cmd("RustLsp! debug")
end, { desc = "Run last debug configuration" })
