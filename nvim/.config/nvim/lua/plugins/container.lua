return {
  dir = vim.fn.expand "~/container.nvim",
  name = "container.nvim",
  cmd = { "ContainerAttach", "ContainerLog", "ContainerResume" },
  opts = {
    config_mode = "copy",
    copy_plugins = true,
    python_lsp = "auto",
    git = "auto",
  },
}
