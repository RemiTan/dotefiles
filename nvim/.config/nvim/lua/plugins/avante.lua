local preferences = require("config.avante_preferences")

local function save_preferences()
  local path = vim.fs.joinpath(vim.fn.stdpath("config"), "lua", "config", "avante_preferences.lua")
  local file, err = io.open(path, "w")
  if not file then
    vim.notify("Could not save Avante preferences: " .. tostring(err), vim.log.levels.ERROR)
    return false
  end

  file:write(string.format(
    "-- Updated by :AvanteModels and :AvanteEffort.\nreturn {\n  model = %q,\n  reasoning_effort = %q,\n}\n",
    preferences.model,
    preferences.reasoning_effort
  ))
  file:close()
  return true
end

local function choose_effort()
  local choices = { "low", "medium", "high" }
  vim.ui.select(choices, {
    prompt = "Avante reasoning effort",
    format_item = function(choice)
      return choice .. (choice == preferences.reasoning_effort and " (current)" or "")
    end,
  }, function(choice)
    if not choice then return end

    preferences.reasoning_effort = choice
    local avante_config = require("avante.config")
    avante_config.override({
      providers = {
        copilot = {
          extra_request_body = { reasoning_effort = choice },
        },
      },
    })

    local provider = require("avante.providers").copilot
    provider.extra_request_body = provider.extra_request_body or {}
    provider.extra_request_body.reasoning_effort = choice

    if save_preferences() then
      local model = avante_config.providers.copilot.model
      local applies = require("avante.providers.openai").is_reasoning_model(model)
      local message = "Saved Avante reasoning effort: " .. choice
      if not applies then message = message .. " (the current model does not use this setting)" end
      vim.notify(message, vim.log.levels.INFO)
    end
  end)
end

local function set_diff_highlights()
  vim.api.nvim_set_hl(0, "AvanteConflictCurrent", {
    fg = "#fff1f2",
    bg = "#7f1d1d",
    bold = true,
  })
  vim.api.nvim_set_hl(0, "AvanteConflictCurrentLabel", {
    fg = "#ffffff",
    bg = "#991b1b",
    bold = true,
  })
  vim.api.nvim_set_hl(0, "AvanteConflictIncoming", {
    fg = "#ecfdf5",
    bg = "#14532d",
    bold = true,
  })
  vim.api.nvim_set_hl(0, "AvanteConflictIncomingLabel", {
    fg = "#ffffff",
    bg = "#166534",
    bold = true,
  })
end

return {
  "yetone/avante.nvim",
  enabled = false,
  -- Download Avante's prebuilt native libraries; a local Rust toolchain is not required.
  build = "bash ./build.sh",
  event = "VeryLazy",
  version = false, -- Never set this value to "*"! Never!
  ---@module 'avante'
  ---@type avante.Config
  opts = {
    -- add any opts here
    -- this file can contain specific instructions for your project
    instructions_file = "avante.md",
    -- Agentic edits stream as diffs and wait for tool/apply confirmation.
    mode = "agentic",
    behaviour = {
      auto_suggestions = false,
      auto_set_highlight_group = true,
      auto_set_keymaps = true,
      auto_apply_diff_after_generation = false,
      support_paste_from_clipboard = false,
      auto_focus_on_diff_view = true,
      minimize_diff = true,
      enable_token_counting = true,
      auto_add_current_file = true,
      auto_approve_tool_permissions = false,
      confirmation_ui_style = "inline_buttons",
      acp_follow_agent_locations = true,
    },
    windows = {
      position = "right",
      wrap = true,
      width = 30,
    },
    highlights = {
      diff = {
        current = "AvanteConflictCurrent",
        incoming = "AvanteConflictIncoming",
      },
    },
    -- for example
    provider = "copilot",
    providers = {
      copilot = {
        model = preferences.model,
        extra_request_body = {
          reasoning_effort = preferences.reasoning_effort,
        },
        -- Copilot exposes GPT-6 Luna through /responses, not /chat/completions.
        -- Keep the existing Responses API behavior for Codex models too.
        use_response_api = function(provider, opts)
          local model = (opts and opts.model) or provider.model
          return type(model) == "string" and (model == "gpt-6-luna" or model:match "gpt%-%d+%.?%d*%-codex" ~= nil)
        end,
      },
    },
  },
  config = function(_, opts)
    set_diff_highlights()
    require("avante").setup(opts)
    local highlight_group = vim.api.nvim_create_augroup("AvanteDiffHighlightOverrides", { clear = true })
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = highlight_group,
      callback = set_diff_highlights,
    })

    -- Keep the built-in model picker, while mirroring its Copilot model choice to Lua config.
    local avante_config = require("avante.config")
    if not avante_config._dotefiles_model_persistence then
      local save_last_model = avante_config.save_last_model
      avante_config.save_last_model = function(model, provider, save_provider)
        save_last_model(model, provider, save_provider)
        if provider == "copilot" and model then
          preferences.model = model
          save_preferences()
        end
      end
      avante_config._dotefiles_model_persistence = true
    end

    pcall(vim.api.nvim_del_user_command, "AvanteEffort")
    vim.api.nvim_create_user_command("AvanteEffort", choose_effort, {
      desc = "Choose and save Avante reasoning effort",
    })
  end,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    --- The below dependencies are optional,
    "nvim-mini/mini.pick", -- for file_selector provider mini.pick
    "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
    "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
    "ibhagwan/fzf-lua", -- for file_selector provider fzf
    "stevearc/dressing.nvim", -- for input provider dressing
    "folke/snacks.nvim", -- for input provider snacks
    "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
    "zbirenbaum/copilot.lua", -- for providers='copilot'
    {
      -- support for image pasting
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      "MeanderingProgrammer/render-markdown.nvim",
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
}
