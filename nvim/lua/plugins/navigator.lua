vim.pack.add({
	"https://github.com/ray-x/navigator.lua",
	"https://github.com/hrsh7th/nvim-cmp",
	"https://github.com/nvim-treesitter/nvim-treesitter",
	"https://github.com/ray-x/guihua.lua",
	"https://github.com/ray-x/go.nvim",
	"https://github.com/ray-x/lsp_signature.nvim",
})

-- Build guihua.lua
vim.cmd("silent! cd lua/fzy && make")

-- Update go.nvim
require("go.install").update_all_sync()

-- lsp_signature setup
require("lsp_signature").setup()

-- go.nvim setup
require("go").setup()

-- navigator setup
require("navigator").setup({
	lsp_signature_help = true, -- enable ray-x/lsp_signature
	lsp = {
		format_on_save = true,
		gopls = {
			settings = {
				gopls = {
					hints = {
						assignVariableTypes = false,
						compositeLiteralFields = true,
						compositeLiteralTypes = true,
						constantValues = true,
						functionTypeParameters = true,
						parameterNames = true,
						rangeVariableTypes = false
					}
				}
			}
		}
	}
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = {"go"},
	callback = function(ev)
		-- CTRL/control keymaps
		vim.api.nvim_buf_set_keymap(0, "n", "<leader>ggi", ":GoImports<CR>", {desc = "Go Imports"})
		vim.api.nvim_buf_set_keymap(0, "n", "<leader>ggb", ":GoBuild %:h<CR>", {desc = "Go Build"})
		vim.api.nvim_buf_set_keymap(0, "n", "<leader>ggt", ":GoTestPkg<CR>", {desc = "Go Test Package"})
		vim.api.nvim_buf_set_keymap(0, "n", "<leader>ggc", ":GoCoverage -p<CR>", {desc = "Go Coverage"})
		vim.api.nvim_buf_set_keymap(0, "n", "<leader>ggr", ":GoRun<CR>", {desc = "Go Run"})
		vim.api.nvim_buf_set_keymap(0, "n", "<leader>ggf", ":GoFmt<CR>", {desc = "Go Format"})

		-- Opens test files
		vim.api.nvim_buf_set_keymap(0, "n", "<leader>ggn", ":lua require('go.alternate').switch(true, '')<CR>", {desc = "Open test file"}) -- Test
		vim.api.nvim_buf_set_keymap(0, "n", "<leader>ggv", ":lua require('go.alternate').switch(true, 'vsplit')<CR>", {desc = "Open test file in vert split"}) -- Test Vertical
		vim.api.nvim_buf_set_keymap(0, "n", "<leader>ggh", ":lua require('go.alternate').switch(true, 'split')<CR>", {desc = "Open test file in horiz split"}) -- Test Split
	end,
	group = vim.api.nvim_create_augroup("go_autocommands", {clear = true})
})
