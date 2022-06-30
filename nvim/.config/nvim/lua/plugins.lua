vim.cmd([[packadd packer.nvim]])

--   augroup packer_user_config
vim.cmd([[
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerCompile
  augroup end
]])

return require("packer").startup(function(use)
	-- Packer MUST manage itself
	use("wbthomason/packer.nvim")

	-- see here: https://github.com/iamcco/markdown-preview.nvim/issues/319
	-- if it does not work: run :mess after :MarkdownPreview to see the error output
	-- fix: cd into markdown-preview.nvim directory and run yarn install && yarn upgrade
	use({ "iamcco/markdown-preview.nvim", ft = "markdown", run = "cd app && yarn install && yarn upgrade" })

	-- theming themes color icons status line
	use({ "ellisonleao/gruvbox.nvim" })
	use("tjdevries/colorbuddy.nvim")
	use("bkegley/gloombuddy")
	use("kyazdani42/nvim-web-devicons")
	use({
		"nvim-lualine/lualine.nvim",
		requires = { "kyazdani42/nvim-web-devicons", opt = true },
	})

	--git stuff
	use("tpope/vim-fugitive")

	-- other stuff
	use("nvim-lua/plenary.nvim")
	-- Discord
	use("andweeb/presence.nvim")
	-- use("ThePrimeagen/harpoon")

	-- Telescope
	use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" })
	use({ "nvim-telescope/telescope.nvim", requires = { { "nvim-lua/plenary.nvim" } } })
	use("nvim-telescope/telescope-file-browser.nvim")
	use("TC72/telescope-tele-tabby.nvim")
	-- use("nvim-telescope/telescope-ui-select.nvim")
	use("crispgm/telescope-heading.nvim")

	-- LSP stuff
	use("neovim/nvim-lspconfig")
	use("jose-elias-alvarez/null-ls.nvim")
	use("jose-elias-alvarez/nvim-lsp-ts-utils")

	-- Code highlighting
	use("yamatsum/nvim-cursorline")

	-- TreeSitter stuff and comment
	use({ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" })
	use("nvim-treesitter/playground")
	use("windwp/nvim-autopairs")
	use("windwp/nvim-ts-autotag")
	use({ "abecodes/tabout.nvim", wants = { "nvim-treesitter" }, after = { "nvim-cmp" } })
	use("numToStr/Comment.nvim")
	use("JoosepAlviste/nvim-ts-context-commentstring")
	use({
		"ThePrimeagen/refactoring.nvim",
		requires = {
			{ "nvim-lua/plenary.nvim" },
			{ "nvim-treesitter/nvim-treesitter" },
		},
	})

	-- auto completion
	use("L3MON4D3/LuaSnip")
	use("hrsh7th/nvim-cmp")
	use("hrsh7th/cmp-nvim-lsp")
	use("hrsh7th/cmp-buffer")
	use("hrsh7th/cmp-path")
	use("hrsh7th/cmp-cmdline")
	use("saadparwaiz1/cmp_luasnip")
	use("hrsh7th/cmp-nvim-lua")
	use("davidsierradz/cmp-conventionalcommits")

	-- snippets
	use("rafamadriz/friendly-snippets")
end)
