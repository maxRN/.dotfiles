require('telescope').load_extension('fzf')
require('telescope').load_extension('file_browser')
require('telescope').setup {
    pickers = {
        buffers = {
            mappings = {
                i = {
                    ["<c-d>"] = "delete_buffer",
                }
            }
        }
    }
}
