local settings = require "config.settings"

return {
  "zbirenbaum/copilot.lua",
  requires = {
    "copilotlsp-nvim/copilot-lsp", -- (optional) for NES functionality
    init = function()
      vim.g.copilot_nes_debounce = 75
    end,
  },
  cmd = { "Copilot" },
  event = { "InsertEnter" },
  config = function()
    require("copilot").setup {
      panel = {
        enabled = false,
      },

      suggestion = {
        enabled = true,
        auto_trigger = true,
        hide_during_completion = true,
        debounce = 75,
        trigger_on_accept = true,
        keymap = {
          accept = "<S-Tab>",
          accept_word = false,
          accept_line = false,
        },
      },
      nes = {
        enabled = true, -- requires copilot-lsp as a dependency
        auto_trigger = true,
        keymap = {
          accept_and_goto = "<C-y>",
          accept_word = false,
          accept_line = false,
        },
      },
      auth_provider_url = nil, -- URL to authentication provider, if not "https://github.com/"
      copilot_node_command = settings.copilot_node_command and vim.fn.expand(settings.copilot_node_command) or "node",
      workspace_folders = {},
      copilot_model = "",
      disable_limit_reached_message = false, -- Set to `true` to suppress completion limit reached popup
      root_dir = function()
        return vim.fs.dirname(vim.fs.find(".git", { upward = true })[1])
      end,
      should_attach = function(buf_id, _)
        local ft = vim.bo[buf_id].filetype

        -- Skip Telescope
        if ft == "TelescopePrompt" then
          return false
        end

        -- Skip oil.nvim
        if ft == "oil" then
          return false
        end

        if not vim.bo[buf_id].buflisted then
          vim.notify("not attaching, buffer is not 'buflisted'", vim.log.levels.DEBUG)
          return false
        end

        if vim.bo[buf_id].buftype ~= "" then
          vim.notify("not attaching, buffer 'buftype' is " .. vim.bo[buf_id].buftype, vim.log.levels.DEBUG)
          return false
        end

        return true
      end,
      server = {
        type = "nodejs", -- "nodejs" | "binary"
        custom_server_filepath = nil,
      },
      server_opts_overrides = {},
      filetypes = {
        markdown = true, -- overrides default
        terraform = false, -- disallow specific filetype
        sh = function()
          if string.match(vim.fs.basename(vim.api.nvim_buf_get_name(0)), "^%.env.*") then
            -- disable for .env files
            return false
          end
          return true
        end,
      },
    }
  end,
}
