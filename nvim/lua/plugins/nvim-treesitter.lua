-- Installation instructions for Neovim 0.12 with native package manager
-- These plugins need to be manually cloned to the pack directory

-- Run these commands in PowerShell/CMD to install the plugins:
--[[
# Navigate to your Neovim data directory
cd $env:LOCALAPPDATA\nvim-data\site\pack\plugins\start
# Create directory if needed
New-Item -ItemType Directory -Force
# Or on Unix-like systems (WSL, Git Bash):
# cd ~/.local/share/nvim/site/pack/plugins/start

For windows install
1. Go to the Visual Studio downloads page:
   - Visit: https://visualstudio.microsoft.com/downloads/
2. Scroll down to "All Downloads"
   - Expand the section "Tools for Visual Studio"
   - Find "Build Tools for Visual Studio 2022" (or latest version)
   - Click Download
5. Make sure "Desktop development with C++" is checked:
   - This is the workload checkbox on the left side
   - It should install the MSVC compiler AND the Windows SDK (which contains stdlib.h)
6. On the right side (Installation Details), verify these are included:
   - MSVC v143 - VS 2022 C++ x64/x86 build tools
   - Windows 11 SDK (or Windows 10 SDK)
   - C++ core features

1. Press the Windows key and search for:
      Developer Command Prompt for VS 2022
      OR
      Developer PowerShell for VS 2022
   
2. Launch it (this sets up the compiler environment automatically)
3. Verify the compiler is now available:
      cl
      You should see "Microsoft (R) C/C++ Optimizing Compiler" message
4. Launch Neovim from this prompt:
      nvim
   
5. Now try installing the Go parser:
      :TSInstall go

# Clone the plugins
git clone https://github.com/nvim-treesitter/nvim-treesitter
git clone https://github.com/nvim-treesitter/nvim-treesitter-textobjects
git clone https://github.com/nvim-treesitter/nvim-treesitter-context

# After cloning, restart Neovim
]]

-- Alternative: Use a plugin manager bootstrap script
local function ensure_plugin(url, name)
	local pack_path = vim.fn.stdpath("data") .. "/site/pack/plugins/start"
	local plugin_path = pack_path .. "/" .. name
	
	if vim.fn.isdirectory(plugin_path) == 0 then
		print("Installing " .. name .. "...")
		vim.fn.mkdir(pack_path, "p")
		local result = vim.fn.system({
			"git", "clone", "--depth=1",
			url,
			plugin_path
		})
		if vim.v.shell_error ~= 0 then
			print("Failed to clone " .. name)
			print(result)
			return false
		end
		vim.cmd("packloadall!")
		return true
	end
	return true
end

-- Bootstrap the plugins
ensure_plugin("https://github.com/nvim-treesitter/nvim-treesitter", "nvim-treesitter")
ensure_plugin("https://github.com/nvim-treesitter/nvim-treesitter-textobjects", "nvim-treesitter-textobjects")
ensure_plugin("https://github.com/nvim-treesitter/nvim-treesitter-context", "nvim-treesitter-context")

-- Load the plugins
vim.cmd("packloadall!")

-- For Neovim 0.12+, use built-in treesitter configuration
-- Enable treesitter highlighting globally
vim.g.treesitter_highlight_enable = true

-- Setup treesitter after plugins are loaded
vim.schedule(function()
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
		print("nvim-treesitter configured successfully!")
	else
		print("ERROR: nvim-treesitter.configs not available")
		print("Please install nvim-treesitter manually - see comments at top of this file")
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
	
	-- Check plugin directory
	local plugin_path = vim.fn.stdpath("data") .. "/site/pack/plugins/start/nvim-treesitter"
	print("Plugin directory exists: " .. tostring(vim.fn.isdirectory(plugin_path) == 1))
	print("Plugin path: " .. plugin_path)
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

-- Command to bootstrap/install treesitter if missing
vim.api.nvim_create_user_command("TSBootstrap", function()
	print("Bootstrapping nvim-treesitter...")
	ensure_plugin("https://github.com/nvim-treesitter/nvim-treesitter", "nvim-treesitter")
	ensure_plugin("https://github.com/nvim-treesitter/nvim-treesitter-textobjects", "nvim-treesitter-textobjects")
	ensure_plugin("https://github.com/nvim-treesitter/nvim-treesitter-context", "nvim-treesitter-context")
	print("Done! Restart Neovim for changes to take effect.")
end, {})
