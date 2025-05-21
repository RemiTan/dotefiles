return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons", "oxfist/night-owl.nvim" },
  config = function()
    vim.cmd "colorscheme carbonfox"
    require("lualine").setup {}
  end,
}
