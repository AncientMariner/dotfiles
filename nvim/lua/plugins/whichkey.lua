vim.pack.add({
	"https://github.com/folke/which-key.nvim",
})
local wk = require("which-key")

wk.add({

-- keys = {
-- 	{
-- 	  "<leader>h",
-- 	  function()
-- 		-- require("which-key").show({ global = false })
-- 		-- Show hydra mode for changing windows
-- 		require("which-key").show({
-- 		   keys = "<c-w>",
-- 		   loop = true, -- this will keep the popup open until you hit <esc>
-- 		 })
-- 	  end,
-- 	  desc = "Buffer Local Keymaps (which-key)",
-- 	},
-- },

	{
		-- "<c-w>",
		-- function()
		-- 	require("which-key").show({ keys = "<c-w>", loop = true })
		-- end,
		-- desc = "Window Hydra Mode (which-key)",
	},
})
