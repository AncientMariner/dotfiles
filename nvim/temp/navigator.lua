return {
    "ray-x/navigator.lua",
    dependencies = {
        {"hrsh7th/nvim-cmp"},
		{"nvim-treesitter/nvim-treesitter"},
        {"ray-x/guihua.lua", run = "cd lua/fzy && make"},
		{
            "ray-x/go.nvim",
            event = {"CmdlineEnter"},
            ft = {"go", "gomod"},
            build = ':lua require("go.install").update_all_sync()'
        },
		{
            "ray-x/lsp_signature.nvim", -- Show function signature when you type
            event = "VeryLazy",
            config = function() require("lsp_signature").setup() end
        }
    },
    config = function()
        require("go").setup()
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
    end
}
