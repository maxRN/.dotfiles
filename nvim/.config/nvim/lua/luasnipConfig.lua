local ls = require("luasnip")
local types = require("luasnip.util.types")
-- some shorthands...
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local l = require("luasnip.extras").lambda
local rep = require("luasnip.extras").rep
local p = require("luasnip.extras").partial
local m = require("luasnip.extras").match
local n = require("luasnip.extras").nonempty
local dl = require("luasnip.extras").dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local conds = require("luasnip.extras.expand_conditions")

require("luasnip.loaders.from_vscode").load()

vim.api.nvim_set_keymap(
	"n",
	"<leader><leader>s",
	"<cmd>luafile ~/.config/nvim/lua/luasnipConfig.lua<CR>",
	{ silent = true }
)

ls.config.set_config({
	history = true,

	updateevents = "TextChanged, TextChangedI",

	enable_autosnippets = true,

	ext_opts = {
		[types.choiceNode] = {
			active = {
				virt_text = { { "<-", "Error" } },
			},
		},
	},
})

local f = ls.function_node
local s = ls.s

ls.add_snippets(nil, {
	markdown = {
		ls.parser.parse_snippet("expand", "# this is markdown expand"),
		s(
			"date",
			f(function()
				return os.date("%A, %d %B - %Y-%m-%d")
			end)
		),
	},
	s("fn", {
		-- Simple static text.
		t("//Parameters: "),
		-- function, first parameter is the function, second the Placeholders
		-- whose text it gets as input.
		f(copy, 2),
		t({ "", "function " }),
		-- Placeholder/Insert.
		i(1),
		t("("),
		-- Placeholder with initial text.
		i(2, "int foo"),
		-- Linebreak
		t({ ") {", "\t" }),
		-- Last Placeholder, exit Point of the snippet.
		i(0),
		t({ "", "}" }),
	}),
})

ls.add_snippets(nil, {
	markdown = {
		ls.parser.parse_snippet("expand", "# this is markdown expand"),
		s(
			"date",
			f(function()
				return os.date("%A, %d %B - %Y-%m-%d")
			end)
		),
	},
	s("fn", {
		-- Simple static text.
		t("//Parameters: "),
		-- function, first parameter is the function, second the Placeholders
		-- whose text it gets as input.
		f(copy, 2),
		t({ "", "function " }),
		-- Placeholder/Insert.
		i(1),
		t("("),
		-- Placeholder with initial text.
		i(2, "int foo"),
		-- Linebreak
		t({ ") {", "\t" }),
		-- Last Placeholder, exit Point of the snippet.
		i(0),
		t({ "", "}" }),
	}),
})

ls.filetype_extend("javascript", { "html" })
ls.filetype_extend("javascriptreact", { "html" })
ls.filetype_extend("typescriptreact", { "html" })

ls.add_snippets("html", {
	s(
		{ trig = "clog", name = "console.log", dscr = "Inserts console.log statement." },
		fmt("console.log(`{iNode1}`);", {
			iNode1 = i(1, "here"),
		})
	),
})
