return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup {}
	require("nvim-treesitter").install{
        "c",
        "python",
        "lua",
        "javascript",
        "html",
        "vim",
        "vimdoc",
        "query",
        "markdown",
        "markdown_inline",
	} 
  end,
}
