return {
	"mfussenegger/nvim-dap",

	dependencies = {
        "leoluz/nvim-dap-go",
	    "nvim-neotest/nvim-nio",
		"rcarriga/nvim-dap-ui"
    },
    lazy = false,
    config = function()
		local dap, dapui = require('dap'), require('dapui')
		local dapgo = require('dap-go')
		dapui.setup()
		dapgo.setup()
		dap.listeners.before.attach.dapui_config = function()
		 dapui.open()
		end
		dap.listeners.before.launch.dapui_config = function()
		 dapui.open()
		end

		-- Include the next few lines until the comment only if you feel you need it
		dap.listeners.before.event_terminated.dapui_config = function()
		 dapui.close()
		end
		dap.listeners.before.event_exited.dapui_config = function()
		 dapui.close()
		end
		-- Include everything after this
		 
		-- dapui.setup({
		--   icons = { expanded = "▾", collapsed = "▸" },
		--   mappings = {
		-- 	open = "o",
		-- 	remove = "d",
		-- 	edit = "e",
		-- 	repl = "r",
		-- 	toggle = "t",
		--   },
		--   expand_lines = vim.fn.has("nvim-0.7"),
		--   layouts = {
		-- 	{
		-- 	  elements = {
		-- 		"scopes",
		-- 	  },
		-- 	  size = 0.3,
		-- 	  position = "right"
		-- 	},
		-- 	{
		-- 	  elements = {
		-- 		"repl",
		-- 		"breakpoints"
		-- 	  },
		-- 	  size = 0.3,
		-- 	  position = "bottom",
		-- 	},
		--   },
		--   floating = {
		-- 	max_height = nial,
		-- 	max_width = nil,
		-- 	border = "single",
		-- 	mappings = {
		-- 	  close = { "q", "<Esc>" },
		-- 	},
		--   },
		--   windows = { indent = 1 },
		--   render = {
		-- 	max_type_length = nil,
		--   },
		-- })

		-- vim.fn.sign_define('DapBreakpoint', { text = '🔴', texthl='', linehl='Special', numhl='' })
		vim.fn.sign_define('DapBreakpoint', { text ='🟥', texthl='DapBreakpoint', linehl='DapBreakpoint', numhl='DapBreakpoint'})
		vim.fn.sign_define('DapStopped', { text ='🦠', texthl ='', linehl ='CursorLine', numhl =''})

		vim.keymap.set('n', '<Leader>dc', function() dap.continue() end, {desc = "Continue debug"})
		vim.keymap.set('n', '<Leader>do', function() dap.step_over() end, {desc = "Step over"})
		vim.keymap.set('n', '<Leader>di', function() dap.step_into() end, {desc = "Step into"})
		vim.keymap.set('n', '<Leader>du', function() dap.step_out() end, {desc = "Step out"})

		vim.keymap.set('n', '<Leader>dv', function() dap.toggle_breakpoint() end, {desc = "Toggle breakpoint"})
		vim.keymap.set('n', '<Leader>db', function() dap.set_breakpoint() end, {desc = "Set breakpoint"})
		vim.keymap.set('n', '<Leader>dq', function() dap.terminate() end, {desc = "Terminate debug"})

		vim.keymap.set('n', '<Leader>cb', function() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, {desc = "Set breakpoint condition"})
		vim.keymap.set('n', '<Leader>lb', function() dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end, {desc = "Set breakpoint with message"})
		vim.keymap.set('n', '<Leader>dr', function() dap.repl.open() end, {desc = "Repl open"})
		vim.keymap.set('n', '<Leader>dl', function() dap.run_last() end, {desc = "Run last"})

		-- evaluate	
		vim.keymap.set("n", "<Leader>de", require("dap.ui.widgets").hover, {desc = "Evaluate under cursor"})
		vim.keymap.set('n', '<Leader>w', function() dapui.open() end, {desc = "Dap ui open"})
		vim.keymap.set('n', '<Leader>W', function() dapui.close() end, {desc = "Dap ui close"})
		vim.keymap.set("n", "<Leader>dC", function() dap.clear_breakpoints() end, {desc = "Clear breakpoints"})
		-- Close debugger and clear breakpoints
		vim.keymap.set("n", "<Leader>dQ", function()
		  dap.clear_breakpoints()
		  ui.toggle({})
		  dap.terminate()
		  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-w>=", false, true, true), "n", false)
		  require("notify")("Debugger session ended", "warn")
		end, {desc = "Clear debugger and breakpoints"})
    end,
}
