return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = {
        {"nvim-treesitter/nvim-treesitter-textobjects"}, -- Syntax aware text-objects
        {
            "nvim-treesitter/nvim-treesitter-context", -- Show code context
            opts = {enable = true, mode = "topline", line_numbers = true}
        }
    },
    config = function()
        local treesitter = require("nvim-treesitter.configs")

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
}
