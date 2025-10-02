return {
    "hrsh7th/nvim-cmp",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp", -- cmp_nvim_lsp
        "neovim/nvim-lspconfig", -- lspconfig
        "onsails/lspkind-nvim", -- lspkind (VS pictograms)
        {
            "L3MON4D3/LuaSnip",
            version = "v2.*",
            build = "make install_jsregexp",
            dependencies = {"rafamadriz/friendly-snippets"}, -- Snippets
            config = function()
                require("luasnip.loaders.from_vscode").lazy_load()
                -- https://github.com/rafamadriz/friendly-snippets/blob/main/snippets/go.json
            end
        },
		{"saadparwaiz1/cmp_luasnip", enabled = true}
    },
    config = function()
        local luasnip = require("luasnip")
        local types = require("luasnip.util.types")

        -- Display virtual text to indicate snippet has more nodes
        luasnip.config.setup({
            ext_opts = {
                [types.choiceNode] = {
                    active = {virt_text = {{"⇥", "GruvboxRed"}}}
                },
                [types.insertNode] = {
                    active = {virt_text = {{"⇥", "GruvboxBlue"}}}
                }
            }
        })

        local cmp = require("cmp")
        local lspkind = require("lspkind")

        cmp.setup({
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end
            },
            window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered()
            },
            mapping = cmp.mapping.preset.insert({
                ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                ["<C-f>"] = cmp.mapping.scroll_docs(4),
                ["<C-Space>"] = cmp.mapping.complete(),
                ["<C-e>"] = cmp.mapping.abort(),
                ["<CR>"] = cmp.mapping.confirm({select = true}),
                ["<Tab>"] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    elseif luasnip.locally_jumpable(1) then
                        luasnip.jump(1)
                    else
                        fallback()
                    end
                end, {"i", "s"})
            }),
            sources = cmp.config.sources({
                {name = "nvim_lsp"}, {name = "luasnip"}, {name = "buffer"}
            }),
            formatting = {
                format = lspkind.cmp_format({
                    mode = "symbol_text",
                    maxwidth = 70,
                    show_labelDetails = true
                })
            }
        })

	    --  This function gets run when an LSP attaches to a particular buffer.
	    --    That is to say, every time a new file is opened that is associated with
	    --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
	    --    function will be executed to configure the current buffer
		vim.api.nvim_create_autocmd('LspAttach', {
			group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
			callback = function(event)
			  local map = function(keys, func, desc, mode)
				mode = mode or 'n'
				vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
			  end
			  -- Jump to the definition of the word under your cursor.
			  --  This is where a variable was first declared, or where a function is defined, etc.
			  --  To jump back, press <C-t>.
			  map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

			  -- Find references for the word under your cursor.
			  map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

			  -- Jump to the implementation of the word under your cursor.
			  --  Useful when your language has ways of declaring types without an actual implementation.
			  map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
			
			  -- Jump to the type of the word under your cursor.
			  --  Useful when you're not sure what type a variable is and you want to see
			  --  the definition of its *type*, not where it was *defined*.
			  map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

			  -- Fuzzy find all the symbols in your current document.
			  --  Symbols are things like variables, functions, types, etc.
			  map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

			  -- Fuzzy find all the symbols in your current workspace.
			  --  Similar to document symbols, except searches over your entire project.
			  map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

			  -- Rename the variable under your cursor.
			  --  Most Language Servers support renaming across files, etc.
			  map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

			  -- Execute a code action, usually your cursor needs to be on top of an error
			  -- or a suggestion from your LSP for this to activate.
			  -- using inline one, uncomment if want to use this
		      -- map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })

			  -- WARN: This is not Goto Definition, this is Goto Declaration.
			  --  For example, in C this would take you to the header.
			  map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

			  -- The following two autocommands are used to highlight references of the
			  -- word under your cursor when your cursor rests there for a little while.
			  --    See `:help CursorHold` for information about when this is executed
			  --
			  -- When you move your cursor, the highlights will be cleared (the second autocommand).
			  local client = vim.lsp.get_client_by_id(event.data.client_id)
			  if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
				local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
				vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
				  buffer = event.buf,
				  group = highlight_augroup,
				  callback = vim.lsp.buf.document_highlight,
				})

				vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
				  buffer = event.buf,
				  group = highlight_augroup,
				  callback = vim.lsp.buf.clear_references,
				})

				vim.api.nvim_create_autocmd('LspDetach', {
				  group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
				  callback = function(event2)
					vim.lsp.buf.clear_references()
					vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
				  end,
				})
			  end

			  -- The following code creates a keymap to toggle inlay hints in your
			  -- code, if the language server you are using supports them
			  --
			  -- This may be unwanted, since they displace some of your code
			  if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
				map('<leader>th', function()
				  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
				end, '[T]oggle Inlay [H]ints')
			  end

		end,
      })

		-- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specifination.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
		 local capabilities = vim.lsp.protocol.make_client_capabilities()
	     capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())



		-- vim.lsp.config('*', {
		--   capabilities = {
		--     textDocument = {
		--       semanticTokens = {
		--         multilineTokenSupport = true,
		--       }
		--     }
		--   },
		--   root_markers = { '.git' },
		-- })
		--
        -- deprecated old way local lspconfig = require("lspconfig")
		-- vim.lsp.enable('gopls')
		vim.lsp.enable('')

        -- All languages: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md

        -- Default lspconfig values for Go are set by `navigator`
        -- Go: go install golang.org/x/tools/gopls@latest

        -- Python: brew install pyright
        -- lspconfig["pyright"].setup {}

        -- Ruby: gem install solargraph
        -- lspconfig["solargraph"].setup {}

        -- https://phpactor.readthedocs.io/en/master/usage/standalone.html#installation
		-- brew uninstall hashicorp/tap/terraform-ls
        -- lspconfig["phpactor"].setup {}
		-- lspconfig.terraformls.setup {
		-- 	cmd = { "terraform-ls", "serve" },
		-- 	filetypes = { "terraform", "tf", "hcl", "tfvars" },
		-- 	-- root_dir = lspconfig.util.root_pattern(".terraform", ".git"),
		-- 	root_dir = function(fname)
		-- 		local root = lspconfig.util.root_pattern(".terraform", ".git")(fname)
		-- 		-- print("Detected root_dir: " .. (root or "nil"))
		-- 		return root
		-- 	end,
		--
		-- }
		-- vim.api.nvim_create_autocmd({"BufWritePre"}, {
		-- 	pattern = {"*.tf", "*.tfvars"},
		-- 	callback = function()
		-- 		vim.lsp.buf.format()
		-- 	end,
		-- })
    end
}

