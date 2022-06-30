require("telescope").setup({
	extensions = {
		tele_tabby = {
			use_highlighter = true,
		},
		--[[ ["ui-select"] = {
			require("telescope.themes").get_dropdown({
				-- even more opts
			}),
		}, ]]
	},
	pickers = {
		lsp_references = {
			theme = "dropdown",
			layout_config = {
				width = 100,
				prompt_position = "top",
				anchor = "N",
			},
		},
		find_files = {
			theme = "dropdown",
			previewer = false,
			layout_config = {
				width = 100,
				prompt_position = "top",
				anchor = "N",
			},
			mappings = {
				i = {
					["?"] = require("telescope.actions.layout").toggle_preview,
				},
			},
		},
		buffers = {
			mappings = {
				i = {
					["<c-d>"] = "delete_buffer",
				},
			},
		},
	},
})
require("telescope").load_extension("fzf")
require("telescope").load_extension("file_browser")
require("telescope").load_extension("heading")
