vim.pack.add({ "https://github.com/nvim-lua/plenary.nvim" })
vim.pack.add({ "https://github.com/pmizio/typescript-tools.nvim" })

local api = require("typescript-tools.api")
require("typescript-tools").setup {
    handlers = {
        ["textDocument/publishDiagnostics"] = api.filter_diagnostics(
            -- ignore require -> import warning
            { 80005 }
        ),
    },
}
