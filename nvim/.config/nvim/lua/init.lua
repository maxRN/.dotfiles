require("nvim-web-devicons").setup({
	-- your personnal icons can go here (to override)
	-- you can specify color or cterm_color instead of specifying both of them
	-- DevIcon will be appended to `name`
	override = {
		zsh = {
			icon = "",
			color = "#428850",
			cterm_color = "65",
			name = "Zsh",
		},
	},
	-- globally enable default icons (default to false)
	-- will get overriden by `get_icons` option
	default = true,
})

require("lualine").setup({ options = { theme = "gruvbox_dark", globalstatus = true } })

vim.api.nvim_set_keymap("n", "<leader><leader>s", "<cmd>source ~/.config/nvim/lua/luasnipConfig.lua<CR>", {})

-- When opening a file, always jump to the last known cursor position.
vim.cmd([[autocmd bufreadpost * if line("'\"") > 0 && line("'\"") <= line("$") | execute 'normal! g`"' | endif]])
