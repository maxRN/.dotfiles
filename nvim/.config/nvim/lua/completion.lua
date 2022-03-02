vim.opt.completeopt = { "menu", "menuone", "noselect" }

-- Setup nvim-cmp.
local cmp = require("cmp")
local ls = require("luasnip")

local t = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

_G.tab_complete = function()
    if ls and ls.expand_or_jumpable() then
        return t("<Plug>luasnip-expand-or-jump")
    else
        cmp.complete()
    end
    return ""
end

_G.s_tab_complete = function()
    if ls and ls.jumpable(-1) then
        return t("<Plug>luasnip-jump-prev")
    end
    return ""
end
vim.api.nvim_set_keymap("i", "<C-k>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<C-k>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("i", "<C-j>", "v:lua.s_tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<C-j>", "v:lua.s_tab_complete()", {expr = true})


cmp.setup({
	experimental = {
		ghost_text = true,
	},
	native_menu = false,

	snippet = {
		-- REQUIRED - you must specify a snippet engine
		expand = function(args)
			require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
		end,
	},
	mapping = {
		["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
		["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
		["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
		["<C-y>"] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
		["<C-e>"] = cmp.mapping({
			i = cmp.mapping.abort(),
			c = cmp.mapping.close(),

		}),
		["<C-q>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
		["<C-n>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			else
				fallback()
			end
		end, {
			"i",
			"s",
		}),
		["<C-p>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			else
				fallback()
			end
		end, { "i", "s" }),
	},
	sources = {
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
        { name = "nvim_lua"},
		{ name = "path" },
		{ name = "buffer", keyword_length = 3 },
	},
	-- see here for more information regarding sorting of the autocomplete: https://github.com/tjdevries/config_manager/blob/8f14ab2dd6ba40645af196cc40116b55c0aca3c0/xdg_config/nvim/after/plugin/completion.lua#L110
	-- nvim cmp source code reference: https://github.com/hrsh7th/nvim-cmp/blob/55f04e49dcd8c78e2fee09159f8587ec6a9d160e/lua/cmp/config/compare.lua
	sorting = {
		comparators = {
			cmp.config.compare.offset,
			cmp.config.compare.exact,
			cmp.config.compare.score,
		},
	},
})


