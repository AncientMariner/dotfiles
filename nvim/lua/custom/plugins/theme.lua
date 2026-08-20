local c_black      = "#000000"
local c_near_black = "#080808"
local c_dark_gray  = "#404040"
local c_gray       = "#888888"
local c_mid_gray   = "#999999"
local c_silver     = "#aaaaaa"
local c_light_gray = "#c1c1c1"
local c_teal       = "#5f8787"
local c_teal_dark  = "#486e6f"

-- black metal (base)
local c_bm_rose        = "#dd9999"
local c_bm_dusty_rose  = "#a06666"
-- black metal (venom) - red
local c_bm_off_white   = "#f8f7f2"
local c_bm_dark_red    = "#79241f"
-- black metal (mayhem) - yellow
local c_bm_cream       = "#f3ecd4"
local c_bm_yellow      = "#eecc6c"
-- black metal (bathory) - orange
local c_bm_peach       = "#fbcb97"
local c_bm_orange      = "#e78a53"
-- black metal (burzum) - green
local c_bm_mint        = "#ddeecc"
local c_bm_sage        = "#99bbaa"
-- black metal (dark funeral) - blue
local c_bm_pale_blue   = "#d0dfee"
local c_bm_steel_blue  = "#5f81a5"
-- black metal (gorgoroth) - brown
local c_bm_warm_gray   = "#9b8d7f"
local c_bm_taupe       = "#8c7f70"
-- black metal (immortal) - ice
local c_bm_ice_blue    = "#7799bb"
local c_bm_slate       = "#556677"
-- black metal (khold) - contrast
local c_bm_near_white  = "#eceee3"
local c_bm_crimson     = "#974b46"
-- black metal (marduk) - neutral
local c_bm_stone       = "#a5aaa7"
local c_bm_dark_stone  = "#626b67"
-- black metal (nile) - sand
local c_bm_sand        = "#aa9988"
local c_bm_olive       = "#777755"

local black_metal_palettes = {
    ["black-metal"]             = { kw = c_teal_dark,   str = c_bm_rose,      sp = c_bm_dusty_rose },
    ["black-metal-venom"]       = { kw = c_teal,        str = c_bm_off_white,  sp = c_bm_dark_red   },
    ["black-metal-mayhem"]      = { kw = c_teal,        str = c_bm_cream,      sp = c_bm_yellow     },
    ["black-metal-bathory"]     = { kw = c_teal,        str = c_bm_peach,      sp = c_bm_orange     },
    ["black-metal-burzum"]      = { kw = c_teal,        str = c_bm_mint,       sp = c_bm_sage       },
    ["black-metal-dark-funeral"]= { kw = c_teal,        str = c_bm_pale_blue,  sp = c_bm_steel_blue },
    ["black-metal-gorgoroth"]   = { kw = c_teal,        str = c_bm_warm_gray,  sp = c_bm_taupe      },
    ["black-metal-immortal"]    = { kw = c_teal,        str = c_bm_ice_blue,   sp = c_bm_slate      },
    ["black-metal-khold"]       = { kw = c_teal,        str = c_bm_near_white, sp = c_bm_crimson    },
    ["black-metal-marduk"]      = { kw = c_teal,        str = c_bm_stone,      sp = c_bm_dark_stone },
    ["black-metal-nile"]        = { kw = c_teal,        str = c_bm_sand,       sp = c_bm_olive      },
}

local function apply_black_metal(p)
    vim.cmd.colorscheme("default")
    local hl = vim.api.nvim_set_hl
    hl(0, "Normal",       { fg = c_light_gray, bg = c_black })
    hl(0, "NormalFloat",  { fg = c_light_gray, bg = c_black })
    hl(0, "Comment",      { fg = c_dark_gray })
    hl(0, "Constant",     { fg = p.str })
    hl(0, "String",       { fg = p.str })
    hl(0, "Identifier",   { fg = c_light_gray })
    hl(0, "Function",     { fg = c_silver })
    hl(0, "Statement",    { fg = p.kw })
    hl(0, "Keyword",      { fg = p.kw })
    hl(0, "Type",         { fg = c_mid_gray })
    hl(0, "Special",      { fg = p.sp })
    hl(0, "LineNr",       { fg = c_dark_gray })
    hl(0, "CursorLineNr", { fg = c_gray, bold = true })
    hl(0, "Visual",       { fg = c_black,      bg = c_light_gray })
    hl(0, "Search",       { fg = c_black,      bg = p.sp })
    hl(0, "StatusLine",   { fg = c_light_gray, bg = c_black })
    hl(0, "Pmenu",        { fg = c_light_gray, bg = c_black })
    hl(0, "PmenuSel",     { fg = c_black,      bg = p.kw })
end

function ColorMyPencils(color)
	-- color = color or "rose-pine-moon"
 	-- color = color or "catppuccin"
 	color = color or "black-metal-bathory"
	-- color = color or "gruvbox"
	local bm = black_metal_palettes[color]
	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
	vim.api.nvim_set_hl(0, "LineNr", { fg = "#7f849c" })
	vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#7f849c", bold = true })
	if bm then
		apply_black_metal(bm)
	else
		vim.cmd.colorscheme(color)
	end
end

return {

    {
        "erikbackman/brightburn.vim",
    },

    {
        "ellisonleao/gruvbox.nvim",
        name = "gruvbox",
        config = function()
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
            ColorMyPencils()
        end,
    },
    {
        "folke/tokyonight.nvim",
        config = function()
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
            ColorMyPencils()
        end
    },

    {
        "rose-pine/neovim",
        name = "rose-pine",
        config = function()
            require('rose-pine').setup({
                disable_background = true,
                styles = {
                    italic = false,
                },
            })
            ColorMyPencils();
        end
    },
   {
		"catppuccin/nvim",
		name = "catppuccin",
		tag = "v1.7.0",
		enabled = true,
		priority = 1000,
		config = function()
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
            ColorMyPencils();
		end
  }
}
