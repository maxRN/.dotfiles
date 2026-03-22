vim.pack.add({
    { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" }
})

local langs_config = {
    { "css",        "css" },
    { "go",         "go" },
    { "html",       "html" },
    { "java",       "java" },
    { "javascript", "javascript" },
    { "kotlin",     "kotlin" },
    { "nix",        "nix" },
    { "python",     "python" },
    { "rust",       "rust" },
    { "typescript", "typescript" },
    { "typst",      "typst" },
    { "tsx",        "typescriptreact" },
    { "jsx",        "javascriptreact" },
    { "lua",        "lua" },
}

local langs = {}
local patterns = {}
for _, lang_setup in ipairs(langs_config) do
    local lang = lang_setup[1]
    table.insert(langs, lang)
    local pattern = lang_setup[2]
    table.insert(patterns, pattern)
end

local treesitter = require("nvim-treesitter")
treesitter.install(langs)

vim.api.nvim_create_autocmd('FileType', {
    pattern = patterns,
    callback = function(ev)
        -- syntax highlighting, provided by Neovim
        vim.treesitter.start()
        -- folds, provided by Neovim
        vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
        -- indentation, provided by nvim-treesitter
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
})

treesitter.update()


