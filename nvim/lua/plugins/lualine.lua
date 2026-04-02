vim.pack.add({
	"https://github.com/nvim-lualine/lualine.nvim",
	"https://github.com/nvim-tree/nvim-web-devicons",
})

require("lualine").setup({
	options = {
		theme = "auto"
	},
	sections = {
		lualine_c = { { 'filename', path = 1 } }
	},
})
