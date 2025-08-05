return {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
        keymap = {
            fzf = {
                ["ctrl-q"] = "select-all+accept",
            },
        },
    },
    keys = {
        { "<C-p>",         require("fzf-lua").global,       desc = "fzf lua: Find files" },
        { "<C-\\>",        require("fzf-lua").buffers,      desc = "fzf lua: search buffers" },
        { "<leader><C-b>", require("fzf-lua").builtin,      desc = "fzf lua: search builtins" },
        { "<leader>rg",    require("fzf-lua").live_grep,    desc = "fzf lua: ripgrep" },
        { "<C-g>",         require("fzf-lua").grep_project, desc = "fzf lua: grep project" },
        {
            "<leader>sc",
            function()
                require("fzf-lua").files({ cwd = vim.fn.stdpath("config") })
            end,
            desc = "fzf lua: [S]earch through neovim [c]onfig"
        },
        { "<leader>df", require("fzf-lua").dap_configurations, desc = "fzf lua: [D]ebug [f]ind configurations." },
        { "<leader>km", require("fzf-lua").keymaps,            desc = "fzf lua: keymaps" },
        {
            "<leader>lsd",
            function()
                require("fzf-lua").lsp_document_symbols()
            end,
            desc = "fzf lua: LSP: document symbols"
        },
        {
            "<leader>lsw",
            function()
                require("fzf-lua").lsp_workspace_symbols()
            end,
            desc = "fzf lua: LSP: workspace symbols"
        },
        {
            "gra",
            function()
                require("fzf-lua")
                    .lsp_code_actions({ winopts = { preview = { layout = "vertical" } } })
            end,
            desc = "fzf lua: LSP: code actions"
        },
    },
}
