return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "stevearc/conform.nvim",
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/nvim-cmp",
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "j-hui/fidget.nvim",
		"onsails/lspkind-nvim",
    },

    config = function()
        require("conform").setup({
            formatters_by_ft = {
            }
        })
        local cmp = require('cmp')
        local cmp_lsp = require("cmp_nvim_lsp")
        local capabilities = vim.tbl_deep_extend(
            "force",
            {},
            vim.lsp.protocol.make_client_capabilities(),
            cmp_lsp.default_capabilities())

        require("fidget").setup({})
        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls",
                -- "rust_analyzer",
                "gopls",
                -- "vtsls",
                "tailwindcss",
            },
        })

        -- Configure gopls with inlay hints using modern vim.lsp.config
        vim.lsp.config.gopls = {
            cmd = { 'gopls' },
            filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
            root_markers = { 'go.work', 'go.mod', '.git' },
            capabilities = capabilities,
            settings = {
                gopls = {
                    hints = {
                        assignVariableTypes = true,
                        compositeLiteralFields = true,
                        compositeLiteralTypes = true,
                        constantValues = true,
                        functionTypeParameters = true,
                        parameterNames = true,
                        rangeVariableTypes = true,
                    },
                },
            },
        }

        -- Configure zls using modern vim.lsp.config
        vim.lsp.config.zls = {
            cmd = { 'zls' },
            filetypes = { 'zig', 'zir' },
            root_markers = { 'zls.json', 'build.zig', '.git' },
            capabilities = capabilities,
            settings = {
                zls = {
                    enable_inlay_hints = true,
                    enable_snippets = true,
                    warn_style = true,
                },
            },
        }

        -- Configure tailwindcss using modern vim.lsp.config
        vim.lsp.config.tailwindcss = {
            cmd = { 'tailwindcss-language-server', '--stdio' },
            filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact", "vue", "svelte", "heex" },
            root_markers = { 'tailwind.config.js', 'tailwind.config.cjs', 'tailwind.config.mjs', 'tailwind.config.ts', 'postcss.config.js', 'postcss.config.cjs', 'postcss.config.mjs', 'postcss.config.ts', '.git' },
            capabilities = capabilities,
        }

        -- Configure lua_ls with deferred library loading to avoid blocking startup
        vim.lsp.config.lua_ls = {
            cmd = { 'lua-language-server' },
            filetypes = { 'lua' },
            root_markers = { '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', 'stylua.toml', 'selene.toml', 'selene.yml', '.git' },
            capabilities = capabilities,
            on_init = function(client)
                -- Defer loading runtime files until after server starts
                vim.schedule(function()
                    if client and client.workspace_did_change_configuration then
                        client.config.settings.Lua.workspace.library = vim.api.nvim_get_runtime_file("", true)
                        client.notify('workspace/didChangeConfiguration', { settings = client.config.settings })
                    end
                end)
            end,
            settings = {
                Lua = {
                    runtime = {
                        version = 'LuaJIT',
                    },
                    diagnostics = {
                        globals = { 'vim' },
                    },
                    workspace = {
                        checkThirdParty = false,
                    },
                    format = {
                        enable = true,
                        -- Put format options here
                        -- NOTE: the value should be STRING!!
                        defaultConfig = {
                            indent_style = "space",
                            indent_size = "2",
                        }
                    },
                }
            }
        }

        -- Set Zig-specific options
        vim.g.zig_fmt_parse_errors = 0
        vim.g.zig_fmt_autosave = 0

        local cmp = require("cmp")
        local lspkind = require("lspkind")
		--
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
			  -- map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

			  -- Jump to the implementation of the word under your cursor.
			  --  Useful when your language has ways of declaring types without an actual implementation.
			  -- map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
			
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
		      map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction', { 'n', 'x' })

			  -- WARN: This is not Goto Definition, this is Goto Declaration.
			  --  For example, in C this would take you to the header.
			  map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

			  map('<leader>ggf', vim.lsp.buf.format, '[F]ormat [F]ile')

				-- Organize imports
		      map('<leader>ggi', function()
			    vim.lsp.buf.code_action({
		          context = { only = { "source.organizeImports" } },
				  apply = true,
				})
	          end, '[G]o [I]mports')
			  -- The following two autocommands are used to highlight references of the
			  -- word under your cursor when your cursor rests there for a little while.
			  --    See `:help CursorHold` for information about when this is executed
			  --
			  -- When you move your cursor, the highlights will be cleared (the second autocommand).
			  local client = vim.lsp.get_client_by_id(event.data.client_id)
			  if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
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
		  if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
			map('<leader>th', function()
			  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
			end, '[T]oggle Inlay [H]ints')

			-- Auto-enable inlay hints for gopls
			if client.name == "gopls" then
				vim.lsp.inlay_hint.enable(false, { bufnr = event.buf })
			end
		  end

	end,
      })

		-- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specifination.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
		 local capabilities = vim.lsp.protocol.make_client_capabilities()
	     capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())


        local cmp_select = { behavior = cmp.SelectBehavior.Select }

        cmp.setup({
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                end,
            },
            mapping = cmp.mapping.preset.insert({
                ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
                ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
                ['<C-y>'] = cmp.mapping.confirm({ select = true }),
                ["<C-Space>"] = cmp.mapping.complete(),
            }),
            sources = cmp.config.sources({
                { name = "copilot", group_index = 2 },
                { name = 'nvim_lsp' },
                { name = 'luasnip' }, -- For luasnip users.
            }, {
                { name = 'buffer' },
            })
        })

        vim.diagnostic.config({
            -- update_in_insert = true,
            float = {
                focusable = false,
                style = "minimal",
                border = "rounded",
                source = "always",
                header = "",
                prefix = "",
            },
        })
    end
}
