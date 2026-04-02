vim.pack.add({
	"https://github.com/nvim-treesitter/nvim-treesitter",
	"https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
	"https://github.com/nvim-treesitter/nvim-treesitter-context",
})

-- Setup treesitter after plugins are loaded
vim.schedule(function()
	-- Treesitter context setup
	local ok_context, treesitter_context = pcall(require, "treesitter-context")
	if ok_context then
		treesitter_context.setup({
			enable = true,
			mode = "topline",
			line_numbers = true
		})
	end

	-- Treesitter setup
	local ok_ts, treesitter = pcall(require, "nvim-treesitter.configs")
	if ok_ts then
		treesitter.setup({
			ensure_installed = {
				"csv", "dockerfile", "gitignore", "go", "gomod", "gosum",
				"gowork", "javascript", "json", "lua", "markdown", 
				-- "php",
				-- "proto", 
				-- "python", 
				-- "rego", 
				-- "ruby", 
				"sql", 
				-- "svelte", 
				"yaml", 
				-- "just", 
				"vimdoc", "bash" 
			},
			indent = {enable = true},
			auto_install = true,
			sync_install = false,
			highlight = {
				enable = true,
				disable = {"csv"}, -- preferring chrisbra/csv.vim
			},
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<c-space>",
					node_incremental = "<c-space>",
					scope_incremental = "<c-s>",
					node_decremental = "<c-backspace>",
				},
			},
			textobjects = {select = {enable = true, lookahead = true}}
		})
	end
end)

vim.api.nvim_create_autocmd("PackChanged", {
	desc = "Handle nvim-treesitter updates",
	group = vim.api.nvim_create_augroup("nvim-treesitter-pack-changed-update-handler", { clear = true }),
	callback = function(event)
		if event.data.kind == "update" then
			local ok = pcall(vim.cmd, "TSUpdate")
			if ok then
				vim.notify("TSUpdate completed successfully!", vim.log.levels.INFO)
			else
				vim.notify("TSUpdate command not available yet, skipping", vim.log.levels.WARN)
			end
		end
	end,
})
-- Run TSUpdate to ensure parsers are up to date
-- vim.cmd("TSUpdate")
