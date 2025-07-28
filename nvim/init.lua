require("custom.default")
require("custom.lazy")
require("custom.remap")

vim.fn.matchadd('TodoComment', 'Todo')
vim.fn.matchadd('TodoComment', 'TODO')
vim.fn.matchadd('TodoComment', 'todo')

local function setup_todo_highlight()
	if not vim.g.my_highlight_loaded then
		vim.api.nvim_set_hl(0, 'TodoComment', { fg = '#ffd400', bg = '#1e1e2e', bold = false, italic = false })
		vim.g.my_highlight_loaded = true
	end
end

vim.api.nvim_create_autocmd('FileType', {
	pattern = 'go',
	callback = function()
		setup_todo_highlight()
	end,
})

