return {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
    keys = {
        { "<C-p>",         function() require("fzf-lua").files() end,                                      desc = "Find files" },
        { "<C-\\>",        function() require "fzf-lua".buffers() end },
        { "<leader><C-b>", function() require "fzf-lua".builtin() end },
        { "<leader>rg",    function() require "fzf-lua".live_grep_glob() end },
        { "<C-g>",         function() require "fzf-lua".grep_project() end },
        { "<leader>sc",    function() require("fzf-lua").files({ cwd = "/Users/maxrn/.config/nvim" }) end, desc = "[S]earch through neovim [c]onfig" },
        { "<leader>df",    function() require "fzf-lua".dap_configurations() end,                          desc = "[D]ebug [f]ind configurations." },
    },
}
