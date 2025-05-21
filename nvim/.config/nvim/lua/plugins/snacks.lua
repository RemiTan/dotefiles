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
    image = { enable = true },

    gitbrowse = {
      ---@class snacks.gitbrowse.Config
      ---@field url_patterns? table<string, table<string, string|fun(fields:snacks.gitbrowse.Fields):string>>
      {
        notify = true, -- show notification on open
        -- Handler to open the url in a browser
        ---@param url string
        open = function(url)
          if vim.fn.has "nvim-0.10" == 0 then
            require("lazy.util").open(url, { system = true })
            return
          end
          vim.ui.open(url)
        end,
        ---@type "repo" | "branch" | "file" | "commit"
        what = "file", -- what to open. not all remotes support all types
        branch = nil, ---@type string?
        line_start = nil, ---@type number?
        line_end = nil, ---@type number?
        -- patterns to transform remotes to an actual URL
        remote_patterns = {
          { "^(https?://.*)%.git$", "%1" },
          { "^git@(.+):(.+)%.git$", "https://%1/%2" },
          { "^git@(.+):(.+)$", "https://%1/%2" },
          { "^git@(.+)/(.+)$", "https://%1/%2" },
          { "^ssh://git@(.*)$", "https://%1" },
          { "^ssh://([^:/]+)(:%d+)/(.*)$", "https://%1/%3" },
          { "^ssh://([^/]+)/(.*)$", "https://%1/%2" },
          { "ssh%.dev%.azure%.com/v3/(.*)/(.*)$", "dev.azure.com/%1/_git/%2" },
          { "^https://%w*@(.*)", "https://%1" },
          { "^git@(.*)", "https://%1" },
          { ":%d+", "" },
          { "%.git$", "" },
        },
        url_patterns = {
          ["github%.com"] = {
            branch = "/tree/{branch}",
            file = "/blob/{branch}/{file}#L{line_start}-L{line_end}",
            commit = "/commit/{commit}",
          },
          ["gitlab%.com"] = {
            branch = "/-/tree/{branch}",
            file = "/-/blob/{branch}/{file}#L{line_start}-L{line_end}",
            commit = "/-/commit/{commit}",
          },
          ["bitbucket%.org"] = {
            branch = "/src/{branch}",
            file = "/src/{branch}/{file}#lines-{line_start}-L{line_end}",
            commit = "/commits/{commit}",
          },
        },
      },
    },
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
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          {
            icon = " ",
            key = "g",
            desc = "Find Text",
            action = function()
              local pickers = require "telescope.pickers"
              local finders = require "telescope.finders"
              local make_entry = require "telescope.make_entry"
              local conf = require("telescope.config").values
              local opts = opts or {}
              opts.cwd = opts.cwd or vim.uv.cwd()
              local finder = finders.new_async_job {
                command_generator = function(prompt)
                  if not prompt or prompt == "" then
                    return nil
                  end

                  local pieces = vim.split(prompt, "  ")
                  local args = { "rg" }
                  if pieces[1] then
                    table.insert(args, "-e")
                    table.insert(args, pieces[1])
                  end

                  if pieces[2] then
                    table.insert(args, "-g")
                    table.insert(args, pieces[2])
                  end

                  return vim.tbl_flatten {
                    args,
                    {
                      "--color=never",
                      "--no-heading",
                      "--with-filename",
                      "--line-number",
                      "--column",
                      "--smart-case",
                    },
                  }
                end,
                entry_maker = make_entry.gen_from_vimgrep(opts),
                cwd = opts.cwd,
              }
              pickers
                .new(opts, {
                  debounce = 100,
                  prompt_title = "multi grep",
                  finder = finder,
                  previewer = conf.grep_previewer(opts),
                  sorter = require("telescope.sorters").empty(),
                })
                :find()
            end,
          },
          { icon = " ", key = "o", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
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
        { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
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
          ttl = 5 * 60,
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
