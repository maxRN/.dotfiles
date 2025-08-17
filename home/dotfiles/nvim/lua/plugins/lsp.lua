vim.pack.add({
    "https://github.com/neovim/nvim-lspconfig",
})

vim.lsp.enable({
    "lua_ls",
    "gopls",
    "nixd",
    "ts_ls",
    "tinymist",
})
