return {
	"rmagatti/auto-session",
	config = function()
		require("auto-session").setup({
			session_lens = {
				buftypes_to_ignore = { "terminal" },
				load_on_setup = true,
				theme_conf = { border = true },
				previewer = false,
			},
		})
		local map = vim.keymap.set

		map("n", "<leader>ls", require("auto-session.session-lens").search_session, {noremap = true, desc = "session list"})
		map("n", "<leader>ss", require("auto-session").SaveSession, {noremap = true, desc = "save session"})
		map("n", "<leader>sd", require("auto-session").DeleteSession, {noremap = true, desc = "delete session"})
	end
}
