vim.pack.add({
	"https://github.com/tpope/vim-fugitive",
})

vim.keymap.set("n", "<leader>gs", vim.cmd.Git, {desc = "[G]it [s]tatus"})
vim.keymap.set("n", "gf", "<cmd>diffget //2<CR>", {desc = "Get from left"})
vim.keymap.set("n", "gh", "<cmd>diffget //3<CR>", {desc = "Get from right"})
