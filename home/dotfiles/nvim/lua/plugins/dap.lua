return {
	{
		"mfussenegger/nvim-dap",
        enabled = false,
		dependencies = {
			"leoluz/nvim-dap-go",
			"rcarriga/nvim-dap-ui",
			"theHamsta/nvim-dap-virtual-text",
			"nvim-neotest/nvim-nio",
		},
		config = function()
			local dap = require("dap")
			local ui = require("dapui")

			require("dapui").setup()
			require("dap-go").setup()
			require("nvim-dap-virtual-text").setup({})

			vim.keymap.set("n", "<leader>tb", dap.toggle_breakpoint)
			vim.keymap.set("n", "<leader>gb", dap.run_to_cursor)

			vim.keymap.set("n", "<leader>?", function()
				---@diagnostic disable-next-line: missing-fields
				require("dapui").eval(nil, { enter = true })
			end)

			vim.keymap.set("n", "<leader>ds", dap.continue, { desc = "[D]ebugging [S]tart" })

			-- Need to figure out how to use F1 keys on my keyboard :(
			vim.keymap.set("n", "<leader>dc", dap.continue)
			vim.keymap.set("n", "<leader>si", dap.step_into)
			vim.keymap.set("n", "S-j", dap.step_over)
			vim.keymap.set("n", "<leader>so", dap.step_out)
			vim.keymap.set("n", "S-k", dap.step_back)
			vim.keymap.set("n", "<leader>dr", dap.restart)

			dap.listeners.before.attach.dapui_config = function()
				ui.open()
			end

			dap.listeners.before.launch.dapui_config = function()
				ui.open()
			end

			dap.listeners.before.event_terminated.dapui_config = function()
				ui.close()
			end

			dap.listeners.before.event_exited.dapui_config = function()
				ui.close()
			end
		end,
	},
}
