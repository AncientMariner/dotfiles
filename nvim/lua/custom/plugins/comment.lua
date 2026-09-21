return {
    "numToStr/Comment.nvim",
    event = "BufReadPost",
    dependencies = {"nvim-treesitter/nvim-treesitter"},
    config = function() require("Comment").setup() end
}
