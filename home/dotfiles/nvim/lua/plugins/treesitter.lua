vim.pack.add({
    { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" }
})

local langs = {
    "css",
    "go",
    "html",
    "java",
    "javascript",
    "kotlin",
    "nix",
    "python",
    "rust",
    "typescript",
    "typst",
}

require("nvim-treesitter").install(langs)

vim.api.nvim_create_autocmd('FileType', {
    pattern = langs,
    callback = function()
        -- syntax highlighting, provided by Neovim
        vim.treesitter.start()
        -- folds, provided by Neovim
        vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
        -- indentation, provided by nvim-treesitter
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
})

vim.cmd([[:TSUpdate]])
