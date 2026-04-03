vim.pack.add({
	"https://github.com/nvim-treesitter/nvim-treesitter",
	"https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
	"https://github.com/nvim-treesitter/nvim-treesitter-context",
})

-- For Neovim 0.12+, use built-in treesitter configuration
-- Enable treesitter highlighting globally
vim.g.treesitter_highlight_enable = true

-- Setup treesitter after plugins are loaded
vim.schedule(function()
	-- First, check if nvim-treesitter plugin is available
	local has_treesitter_plugin = vim.fn.isdirectory(vim.fn.stdpath("data") .. "/site/pack/*/start/nvim-treesitter") == 1
	
	if not has_treesitter_plugin then
		print("nvim-treesitter plugin not found. Run :packloadall or restart Neovim")
		return
	end

	-- Try to require treesitter configs
	local ok_ts, ts_configs = pcall(require, "nvim-treesitter.configs")
	
	if ok_ts and ts_configs then
		ts_configs.setup({
			ensure_installed = {
				"csv", "dockerfile", "gitignore", "go", "gomod", "gosum",
				"gowork", "javascript", "json", "lua", "markdown", 
				"sql", "yaml", "vimdoc", "bash" 
			},
			auto_install = true,
			sync_install = false,
			highlight = {
				enable = true,
				disable = {"csv"},
				additional_vim_regex_highlighting = false,
			},
			indent = { enable = true },
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<c-space>",
					node_incremental = "<c-space>",
					scope_incremental = "<c-s>",
					node_decremental = "<c-backspace>",
				},
			},
			textobjects = { 
				select = { 
					enable = true, 
					lookahead = true 
				} 
			}
		})
	else
		print("nvim-treesitter.configs not available - using fallback configuration")
		-- Fallback: use native treesitter without nvim-treesitter plugin config
		vim.treesitter.language.register('go', 'go')
	end

	-- Setup treesitter-context
	local ok_context, ts_context = pcall(require, "treesitter-context")
	if ok_context then
		ts_context.setup({
			enable = true,
			mode = "topline",
			line_numbers = true
		})
	end
end)

-- Force enable treesitter for Go files
vim.api.nvim_create_autocmd("FileType", {
	pattern = "go",
	callback = function(args)
		local buf = args.buf
		vim.defer_fn(function()
			if vim.api.nvim_buf_is_valid(buf) then
				local ok = pcall(vim.treesitter.start, buf)
				if not ok then
					print("Failed to start treesitter for Go. Run :TSInstall go")
				end
			end
		end, 100)
	end,
})

-- Also try on BufEnter
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "*.go",
	callback = function(args)
		local buf = args.buf
		if vim.treesitter.highlighter.active[buf] == nil then
			vim.defer_fn(function()
				if vim.api.nvim_buf_is_valid(buf) then
					pcall(vim.treesitter.start, buf)
				end
			end, 100)
		end
	end,
})

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

-- Debug command to check treesitter status
vim.api.nvim_create_user_command("TSDebug", function()
	local buf = vim.api.nvim_get_current_buf()
	local ft = vim.bo[buf].filetype
	local parser_ok, parser = pcall(vim.treesitter.get_parser, buf, ft)
	local ts_enabled = vim.treesitter.highlighter.active[buf] ~= nil
	
	print("=== Treesitter Debug Info ===")
	print("Filetype: " .. ft)
	print("Has parser: " .. tostring(parser_ok))
	if parser_ok then
		print("Parser lang: " .. parser:lang())
	end
	print("Highlighting active: " .. tostring(ts_enabled))
	print("Treesitter module available: " .. tostring(pcall(require, "nvim-treesitter")))
	print("Config module available: " .. tostring(pcall(require, "nvim-treesitter.configs")))
end, {})

-- Command to manually enable treesitter highlighting
vim.api.nvim_create_user_command("TSEnableHighlight", function()
	local buf = vim.api.nvim_get_current_buf()
	local ok, err = pcall(vim.treesitter.start, buf)
	if ok then
		print("Treesitter highlighting enabled for buffer " .. buf)
	else
		print("Failed to enable treesitter: " .. tostring(err))
	end
end, {})

-- Command to force reload treesitter for current buffer
vim.api.nvim_create_user_command("TSReload", function()
	local buf = vim.api.nvim_get_current_buf()
	vim.treesitter.stop(buf)
	vim.defer_fn(function()
		vim.treesitter.start(buf)
		print("Treesitter reloaded")
	end, 50)
end, {})

-- Command to install Go parsers manually
vim.api.nvim_create_user_command("TSInstallGo", function()
	vim.cmd("TSInstall! go gomod gosum gowork")
	print("Installing Go parsers... This may take a moment on Windows.")
	print("After installation completes, restart Neovim or run :TSReload")
end, {})
