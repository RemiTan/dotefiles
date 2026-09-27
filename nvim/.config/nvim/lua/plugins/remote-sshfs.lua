return {
  "nosduco/remote-sshfs.nvim",
  cmd = {
    "RemoteSSHFSConnect",
    "RemoteSSHFSDisconnect",
    "RemoteSSHFSFindFiles",
    "RemoteSSHFSLiveGrep",
    "RemoteSSHFSEdit",
  },
  keys = {
    { "<leader>rs", "<cmd>RemoteSSHFSConnect<CR>", desc = "Connect to SSH workspace" },
    { "<leader>rS", "<cmd>RemoteSSHFSDisconnect<CR>", desc = "Disconnect SSH workspace" },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",
  },
  opts = {
    ui = { picker = "telescope" },
    mounts = {
      base_dir = vim.fn.expand("~/.sshfs/"),
      unmount_on_exit = true,
    },
    handlers = {
      on_connect = { change_dir = true },
    },
  },
  config = function(_, opts)
    require("remote-sshfs").setup(opts)
    require("telescope").load_extension("remote-sshfs")
  end,
}
