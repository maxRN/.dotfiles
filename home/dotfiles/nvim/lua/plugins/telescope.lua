return {
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.8",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope-fzf-native.nvim",
        },
        config = function()
            require("telescope").setup({
                pickers = {
                    lsp_references = {
                        theme = "dropdown",
                        layout_config = {
                            width = 100,
                            prompt_position = "top",
                            anchor = "N",
                        },
                    },
                    git_files = {
                        theme = "dropdown",
                        previewer = false,
                        hidden = true,
                        wrap_results = true,
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
                },
                extensions = {
                    fzf = {}
                }
            })
            vim.keymap.set("n", "<leader>sd", require("telescope.builtin").find_files)
            vim.keymap.set("n", "<leader>sc", function()
                require("telescope.builtin").find_files {
                    cwd = vim.fn.stdpath("config")
                }
            end)
            vim.keymap.set("n", "<leader>sg", require("telescope.builtin").live_grep,
                { desc = "[S]earch by [G]rep Telescope" })

            vim.keymap.set(
                "n",
                "<leader>so",
                require("telescope.builtin").oldfiles,
                { desc = '[S]earch Recent Files ("." for repeat) Telescope' }
            )
            vim.keymap.set("n", "<leader>sb", require("telescope.builtin").buffers,
                { desc = "[ ] Find existing buffers Telescope" })
        end
    },
}
