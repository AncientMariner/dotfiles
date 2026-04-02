return {
    "mbbill/undotree",
    dependencies = {},
    config = function()
		vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, {desc = "Toggle undotree"})
    end
}
