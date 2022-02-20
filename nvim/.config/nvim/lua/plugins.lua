vim.cmd([[packadd packer.nvim]])

--   augroup packer_user_config
vim.cmd([[
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]])

return require("packer").startup(function(use)
	-- Packer can manage itself
	use("wbthomason/packer.nvim")
	use({
		"nvim-lualine/lualine.nvim",
		requires = { "kyazdani42/nvim-web-devicons", opt = true },
	})

	-- see here: https://github.com/iamcco/markdown-preview.nvim/issues/319
	-- if it does not work: run :mess after :MarkdownPreview to see the error output
	-- fix: cd into markdown-preview.nvim directory and run yarn install && yarn upgrade
	use({ "iamcco/markdown-preview.nvim", ft = "markdown", run = "cd app && yarn install" })
	use({ "ellisonleao/gruvbox.nvim" })
    use("tpope/vim-fugitive")

    -- auto completion
    use("L3MON4D3/LuaSnip")
    use('hrsh7th/nvim-cmp')
    use('hrsh7th/cmp-nvim-lsp')
    use('hrsh7th/cmp-buffer')
    use('hrsh7th/cmp-path')
    use('hrsh7th/cmp-cmdline')
    use('saadparwaiz1/cmp_luasnip')
    use('hrsh7th/cmp-nvim-lua')

    use "rafamadriz/friendly-snippets"
end)
