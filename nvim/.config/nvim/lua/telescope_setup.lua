require("telescope").load_extension("fzf")
require("telescope").load_extension("file_browser")
require("telescope").load_extension("heading")
require("telescope").setup({
	extensions = {
		tele_tabby = {
			use_highlighter = true,
		},
	},
})
require("telescope").setup({
	pickers = {
		buffers = {
			mappings = {
				i = {
					["<c-d>"] = "delete_buffer",
				},
			},
		},
	},
})
