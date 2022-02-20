local ls = require "luasnip"
local types = require("luasnip.util.types")

require("luasnip.loaders.from_vscode").load()

vim.api.nvim_set_keymap("n", "<leader><leader>s", "<cmd>luafile ~/.config/nvim/lua/luasnipConfig.lua<CR>", { silent = true })

ls.config.set_config {
    history = true,

    updateevents = "TextChanged, TextChangedI",

    enable_autosnippets = true,

    ext_opts = {
        [types.choiceNode] = {
            active = {
                virt_text = { { "<-", "Error"}},
            },
        },
    },
}

ls.snippets = {
    all = {
        ls.parser.parse_snippet("expand", "--this is what was expanded")
    }
}
