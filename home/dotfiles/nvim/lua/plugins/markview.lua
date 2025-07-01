return {
    "OXY2DEV/markview.nvim",
    lazy = false,
    enabled = false,
    -- opts = {
    -- 	modes = {},
    -- 	hybrid_mods = nil,
    -- },
    keys = {
        { "<leader>md", "<Cmd>Markview toggle<Cr>" },
    },
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
}
