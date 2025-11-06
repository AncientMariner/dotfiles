vim.api.nvim_exec ('language en_US', true)
vim.opt.encoding = "utf-8"

vim.g.mapleader = " "
-- vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.opt.tabstop = 4
vim.opt.softtabstop = 0
vim.opt.expandtab = false
vim.opt.shiftwidth = 4

vim.opt.swapfile = false
vim.opt.backup = false
-- vim.opt.undodir = OS.getenv("HOME") .. "~/.vim/undodir"
vim.opt.undodir = "full path to ~/.vim/undodir not with ~"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true


vim.opt.scrolloff = 8

vim.opt.compatible = false
vim.opt.hlsearch = true
vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.laststatus = 2
vim.opt.vb = true
vim.opt.ruler = true
vim.opt.spell = true
vim.opt.spelllang = "en_us"
vim.opt.autoindent = true
-- vim.opt.colorcolumn = "120"
-- vim.opt.textwidth = 120
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamed"
vim.opt.scrollbind = false
vim.opt.wildmenu = true

-- filetype related 
vim.api.nvim_create_autocmd("FileType", {
    pattern = {"gitcommit"},
    callback = function(ev)
        vim.api.nvim_set_option_value("textwidth", 72, {scope = "local"})
    end
})

vim.api.nvim_create_autocmd("FileType", {
    pattern = {"markdown"},
    callback = function(ev)
        vim.api.nvim_set_option_value("textwidth", 0, {scope = "local"})
        vim.api.nvim_set_option_value("wrapmargin", 0, {scope = "local"})
        vim.api.nvim_set_option_value("linebreak", true, {scope = "local"})
    end
})
