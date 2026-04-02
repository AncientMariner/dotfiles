function ColorMyPencils(color)
	-- color = color or "rose-pine-moon"
	color = color or "catppuccin"
	-- color = color or "gruvbox"
	vim.cmd.colorscheme(color)

	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

vim.pack.add({
	"https://github.com/erikbackman/brightburn.vim",
	"https://github.com/ellisonleao/gruvbox.nvim",
	"https://github.com/folke/tokyonight.nvim",
	"https://github.com/rose-pine/neovim",
	"https://github.com/catppuccin/nvim",
})

-- Gruvbox setup
require("gruvbox").setup({
	background = "light",
	terminal_colors = true, -- add neovim terminal colors
	undercurl = true,
	underline = false,
	bold = true,
	italic = {
		strings = false,
		emphasis = false,
		comments = false,
		operators = false,
		folds = false,
	},
	strikethrough = true,
	invert_selection = false,
	invert_signs = false,
	invert_tabline = false,
	invert_intend_guides = false,
	inverse = false, -- invert background for search, diffs, statuslines and errors
	contrast = "hard", -- can be "hard", "soft" or empty string
	palette_overrides = {},
	overrides = {},
	dim_inactive = false,
	transparent_mode = false,
})

-- Tokyonight setup
require("tokyonight").setup({
	-- your configuration comes here
	-- or leave it empty to use the default settings
	style = "day", -- The theme comes in three styles, `storm`, `moon`, a darker variant `night` and `day`
	transparent = true, -- Enable this to disable setting the background color
	terminal_colors = true, -- Configure the colors used when opening a `:terminal` in Neovim
	styles = {
		-- Style to be applied to different syntax groups
		-- Value is any valid attr-list value for `:help nvim_set_hl`
		comments = { italic = false },
		keywords = { italic = false },
		-- Background styles. Can be "dark", "transparent" or "normal"
		sidebars = "dark", -- style for sidebars, see below
		floats = "dark", -- style for floating windows
	},
})

-- Rose-pine setup
require('rose-pine').setup({
	disable_background = true,
	styles = {
		italic = false,
	},
})

-- Catppuccin setup
vim.opt.termguicolors = true

local catppuccin = require("catppuccin")

catppuccin.setup({
	flavour = "mocha",
	term_colors = true,
	styles = {
		conditionals = {},
		functions = {"italic"},
		types = {"bold"}
	},
	color_overrides = {
		mocha = {
			base = "#171717", -- background
			surface2 = "#9A9A9A", -- comments
			text = "#F6F6F6"
		}
	},
	highlight_overrides = {
		mocha = function(C)
			return {
				NvimTreeNormal = {bg = C.none},
				CmpBorder = {fg = C.surface2},
				Pmenu = {bg = C.none},
				NormalFloat = {bg = C.none},
				TelescopeBorder = {link = "FloatBorder"}
			}
		end
	},
	integrations = {
		barbar = true,
		cmp = true,
		gitsigns = true,
		native_lsp = {enabled = true},
		nvimtree = true,
		telescope = true,
		treesitter = true,
		treesitter_context = true
	}
})

-- Apply the colorscheme
ColorMyPencils()
