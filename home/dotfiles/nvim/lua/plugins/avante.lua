return {
    "yetone/avante.nvim",
    enabled      = false,
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    -- ⚠️ must add this setting! ! !
    build        = "make BUILD_FROM_SOURCE=true",
    -- build        = function()
    --     -- conditionally use the correct build system for the current OS
    --     if vim.fn.has("win32") == 1 then
    --         return "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
    --     else
    --         return "make BUILD_FROM_SOURCE=true"
    --     end
    -- end,
    event        = "VeryLazy",
    version      = false, -- Never set this value to "*"! Never!
    ---@module 'avante'
    ---@type avante.Config
    opts         = {
        -- add any opts here
        -- for example
        provider = "claude",
        providers = {
            claude = {
                endpoint = "https://api.anthropic.com",
                -- model = "claude-sonnet-4-20250514",
                -- model = "claude-3-5-sonnet-20241022",
                model = "claude-opus-4-20250514",
                timeout = 30000, -- Timeout in milliseconds
                extra_request_body = {
                    temperature = 0.75,
                    max_tokens = 20480,
                },
            },
        },
        selector = {

        },
    },
    dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        --- The below dependencies are optional,
        "ibhagwan/fzf-lua",            -- for file_selector provider fzf
        "folke/snacks.nvim",           -- for input provider snacks
        "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
        {
            -- support for image pasting
            "HakonHarnes/img-clip.nvim",
            event = "VeryLazy",
            opts = {
                -- recommended settings
                default = {
                    embed_image_as_base64 = false,
                    prompt_for_file_name = false,
                    drag_and_drop = {
                        insert_mode = true,
                    },
                    -- required for Windows users
                    use_absolute_path = true,
                },
            },
        },
        {
            -- Make sure to set this up properly if you have lazy=true
            'MeanderingProgrammer/render-markdown.nvim',
            opts = {
                file_types = { "markdown", "Avante" },
            },
            ft = { "markdown", "Avante" },
        },
    },
}
