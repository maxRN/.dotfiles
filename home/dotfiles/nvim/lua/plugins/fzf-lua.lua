vim.pack.add({
    "https://github.com/ibhagwan/fzf-lua",
})

local fzl = require("fzf-lua")
fzl.setup({
    keymap = {
        fzf = {
            ["ctrl-q"] = "select-all+accept"
        }
    }
}
)

vim.keymap.set("n", "<C-p>", fzl.global, { desc = "fzf lua: Find files" })
vim.keymap.set("n", "<C-\\>", fzl.buffers, { desc = "fzf lua: search buffers" })
vim.keymap.set("n", "<leader><C-b>", fzl.builtin, { desc = "fzf lua: search builtins" })
vim.keymap.set("n", "<leader>rg", fzl.live_grep, { desc = "fzf lua: ripgrep" })
vim.keymap.set("n", "<C-g>", fzl.grep_project, { desc = "fzf lua: grep project" })
vim.keymap.set("n",
    "<leader>sc",
    function()
        require("fzf-lua").files({ cwd = vim.fn.stdpath("config") })
    end,
    { desc = "fzf lua: [S]earch through neovim [c]onfig" }
)
vim.keymap.set("n", "<leader>df", fzl.dap_configurations, { desc = "fzf lua: [D]ebug [f]ind configurations." })
vim.keymap.set("n", "<leader>km", fzl.keymaps, { desc = "fzf lua: keymaps" })
vim.keymap.set("n", "<leader>lsd", fzl.lsp_document_symbols, { desc = "fzf lua: LSP: document symbols" })
vim.keymap.set("n", "<leader>lsw", fzl.lsp_workspace_symbols, { desc = "fzf lua: LSP: workspace symbols" })
vim.keymap.set("n",
    "gra",
    function()
        fzl
            .lsp_code_actions({ winopts = { preview = { layout = "vertical" } } })
    end,
    { desc = "fzf lua: LSP: code actions" }
)

vim.cmd('FzfLua register_ui_select')
