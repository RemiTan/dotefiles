local M = {}
-- Icon definitions for the dashboard
M.icon = function(file, icon_type)
  local icons = {
    file = { "", width = 2, hl = "IconFile" }, -- Default icon for files
    directory = { "", width = 2, hl = "IconDirectory" }, -- Default icon for directories
    text = { "", width = 2, hl = "IconText" }, -- Text file
    markdown = { "", width = 2, hl = "IconMarkdown" }, -- Markdown file
    lua = { "", width = 2, hl = "IconLua" }, -- Lua file
    py = { "", width = 2, hl = "IconPython" }, -- Python file
    html = { "", width = 2, hl = "IconHTML" }, -- HTML file
    css = { "", width = 2, hl = "IconCSS" }, -- CSS file
    js = { "", width = 2, hl = "IconJavaScript" }, -- JavaScript file
    json = { "", width = 2, hl = "IconJSON" }, -- JSON file
    image = { "", width = 2, hl = "IconImage" }, -- Image file
    binary = { "", width = 2, hl = "IconBinary" }, -- Binary file
    default = { "", width = 2, hl = "IconDefault" }, -- fallback for unknown types
  }
  if icon_type == "file" then
    local ext = vim.fn.fnamemodify(file, ":e")
    return icons[ext] or icons.default
  elseif icon_type == "directory" then
    return icons.directory
  end

  return icons.default
end

vim.cmd [[
  highlight IconFile guifg=#a0a0a0          " Neutral grey for generic files
  highlight IconDirectory guifg=#0078d7     " Blue for directories (Windows/Folder theme)
  highlight IconText guifg=#008080          " Teal for plain text
  highlight IconMarkdown guifg=#083fa1      " Dark blue, close to the GitHub markdown theme
  highlight IconLua guifg=#000080           " Dark blue for Lua (official website theme)
  highlight IconPython guifg=#3776AB        " Python blue from the logo
  highlight IconHTML guifg=#E44D26          " HTML5 orange from the logo
  highlight IconCSS guifg=#264de4           " CSS blue from the logo
  highlight IconJavaScript guifg=#F7DF1E    " Yellow from the JS logo
  highlight IconJSON guifg=#6DB33F          " Green for JSON (Node/JSON themes)
  highlight IconImage guifg=#DB4437         " Red for image files (Google Photos theme)
  highlight IconBinary guifg=#FF4500        " Bright red-orange for binary files
  highlight IconDefault guifg=#C0C0C0       " Light grey for unknown file types
]]

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
    bigfile = { enabled = true },
    explorer = { enabled = false },
    indent = { enabled = true },
    input = { enabled = false },
    picker = { enabled = false },
    notifier = { enabled = false },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = false },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    git = { enabled = true },
    image = { enabled = true },
    dashboard = {
      width = 60,
      row = nil, -- dashboard position. nil for center
      col = nil, -- dashboard position. nil for center
      pane_gap = 8, -- empty columns between vertical panes
      autokeys = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ", -- autokey sequence
      -- These settings are used by some built-in sections
      preset = {
        -- Defaults to a picker that supports `fzf-lua`, `telescope.nvim` and `mini.pick`
        ---@type fun(cmd:string, opts:table)|nil
        pick = nil,
        -- Used by the `keys` section to show keymaps.
        -- Set your custom keymaps here.
        -- When using a function, the `items` argument are the default keymaps.
        ---@type snacks.dashboard.Item[]
        keys = {
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          {
            icon = " ",
            key = "c",
            desc = "Config",
            action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
          },
          {
            icon = " ",
            key = "r",
            desc = "Restore Session",
            action = "<cmd> SessionRestore <CR>",
          },
          {
            icon = "󰉋 ",
            key = "w",
            desc = "Change Workspace",
            action = function()
              require("config.projects").pick()
            end,
          },
          { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
        -- Used by the `header` section
        header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
      },
      -- item field formatters
      formats = {
        icon = function(item)
          if item.file and item.icon == "file" or item.icon == "directory" then
            return M.icon(item.file, item.icon)
          end
          return { item.icon, width = 2, hl = "icon" }
        end,
        footer = { "%s", align = "center" },
        header = { "%s", align = "center" },
        file = function(item, ctx)
          local fname = vim.fn.fnamemodify(item.file, ":~")
          fname = ctx.width and #fname > ctx.width and vim.fn.pathshorten(fname) or fname
          if #fname > ctx.width then
            local dir = vim.fn.fnamemodify(fname, ":h")
            local file = vim.fn.fnamemodify(fname, ":t")
            if dir and file then
              file = file:sub(-(ctx.width - #dir - 2))
              fname = dir .. "/…" .. file
            end
          end
          local dir, file = fname:match "^(.*)/(.+)$"
          return dir and { { dir .. "/", hl = "dir" }, { file, hl = "file" } } or { { fname, hl = "file" } }
        end,
      },
      sections = {
        { section = "header" },
        function()
          return {
            text = {
              { "Workspace: ", hl = "SnacksDashboardTitle" },
              { vim.fn.fnamemodify(vim.fn.getcwd(), ":~"), hl = "SnacksDashboardDesc" },
            },
            align = "center",
            padding = 1,
          }
        end,
        {
          pane = 2,
          section = "terminal",
          cmd = "colorscript -e square",
          height = 5,
          padding = 1,
        },
        {
          pane = 2,
          icon = " ",
          desc = "Browse Repo",
          padding = 1,
          key = "b",
          action = function()
            Snacks.gitbrowse()
          end,
        },
        { section = "keys", gap = 1, padding = 2 },
        {
          pane = 2,
          icon = " ",
          section = "terminal",
          enabled = function()
            return Snacks.git.get_root() ~= nil
          end,
          padding = 1,
          ttl = 5 * 60,
          indent = 3,
          title = "Notifications",
          cmd = "gh notify -s -a -n5",
          action = function()
            vim.ui.open "https://github.com/notifications"
          end,
          key = "n",
          height = 7,
        },
        {
          pane = 2,
          icon = " ",
          title = "Git Status",
          section = "terminal",
          enabled = function()
            return Snacks.git.get_root() ~= nil
          end,
          cmd = "git --no-pager diff --stat -B -M -C",
          height = 5,
          padding = 1,
          ttl = 5 * 60,
          indent = 3,
        },
        {
          pane = 2,
          section = "terminal",
          enabled = function()
            return Snacks.git.get_root() ~= nil
          end,
          padding = 1,
          ttl = 0,
          indent = 3,
          icon = " ",
          title = "Open PRs",
          cmd = "gh pr list -L 3",
          key = "p",
          action = function()
            vim.fn.jobstart("gh pr list --web", { detach = true })
          end,
          height = 7,
        },
        { section = "startup" },
      },
    },
  },
}
