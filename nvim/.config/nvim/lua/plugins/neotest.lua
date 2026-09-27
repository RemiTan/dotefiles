return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-neotest/neotest-python",
    "mfussenegger/nvim-dap",
    "mfussenegger/nvim-dap-python",
    "theHamsta/nvim-dap-virtual-text",
    "nvim-neotest/nvim-nio",
    "rcarriga/nvim-dap-ui",
  },
  keys = {
    {
      "<leader>tn",
      function()
        require("neotest").run.run()
      end,
      desc = "Run nearest test",
    },
    {
      "<leader>tf",
      function()
        require("neotest").run.run(vim.fn.expand "%")
      end,
      desc = "Run tests in file",
    },
    {
      "<leader>tD",
      function()
        require("neotest").run.run { strategy = "dap" }
      end,
      desc = "Debug nearest test",
    },
    {
      "<leader>tF",
      function()
        require("neotest").run.run { vim.fn.expand "%", strategy = "dap" }
      end,
      desc = "Debug tests in file",
    },
    {
      "<leader>ts",
      function()
        require("neotest").summary.toggle()
      end,
      desc = "Toggle test summary",
    },
    {
      "<leader>to",
      function()
        require("neotest").output_panel.toggle()
      end,
      desc = "Toggle test output panel",
    },
    {
      "<leader>tO",
      function()
        require("neotest").output.open { enter = true }
      end,
      desc = "Open nearest test output",
    },
    {
      "<leader>tr",
      function()
        require("neotest").run.run_last()
      end,
      desc = "Re-run last test",
    },
    {
      "<leader>tx",
      function()
        require("neotest").run.stop()
      end,
      desc = "Stop running test",
    },
    { "<leader>tL", "<cmd>NeotestLog<CR>", desc = "Open Neotest log" },
    {
      "<leader>dr",
      function()
        local dap = require "dap"
        local run_last_test = function()
          require("neotest").run.run_last { strategy = "dap" }
        end

        if dap.session() then
          dap.terminate { on_done = vim.schedule_wrap(run_last_test) }
        else
          run_last_test()
        end
      end,
      desc = "Restart debugging the last test",
    },
    {
      "<leader>db",
      function()
        require("dap").toggle_breakpoint()
      end,
      desc = "Debugger: toggle breakpoint",
    },
    {
      "<leader>dh",
      function()
        require("dap").continue()
      end,
      desc = "Debugger: continue",
    },
    {
      "<leader>dj",
      function()
        require("dap").step_into()
      end,
      desc = "Debugger: step into",
    },
    {
      "<leader>dk",
      function()
        require("dap").step_over()
      end,
      desc = "Debugger: step over",
    },
    {
      "<leader>dK",
      function()
        require("dap").step_out()
      end,
      desc = "Debugger: step out",
    },
    {
      "<leader>du",
      function()
        require("dapui").toggle()
      end,
      desc = "Debugger: toggle UI",
    },
    {
      "<leader>dq",
      function()
        require("dap").terminate()
      end,
      desc = "Debugger: stop session",
    },
    {
      "<leader>d1",
      function()
        require("dapui").toggle { layout = 1 }
      end,
      desc = "Debugger: toggle sidebar",
    },
    {
      "<leader>d2",
      function()
        require("dapui").toggle { layout = 2 }
      end,
      desc = "Debugger: toggle REPL/console",
    },
    {
      "<leader>de",
      function()
        require("dapui").eval(nil, { enter = true })
      end,
      mode = { "n", "v" },
      desc = "Debugger: evaluate expression",
    },
  },
  config = function()
    local dap = require "dap"
    local dapui = require "dapui"

    dapui.setup {
      layouts = {
        {
          elements = {
            { id = "watches", size = 0.25 },
            { id = "stacks", size = 0.20 },
            { id = "breakpoints", size = 0.25 },
            { id = "scopes", size = 0.30 },
          },
          size = 34,
          position = "left",
        },
        {
          elements = {
            { id = "repl", size = 0.6 },
            { id = "console", size = 0.4 },
          },
          size = 0.25,
          position = "bottom",
        },
      },
    }
    require("nvim-dap-virtual-text").setup {
      enabled = true,
      enabled_commands = true,
      highlight_changed_variables = true,
      commented = true,
      show_stop_reason = true,
      only_first_definition = false,
      all_references = true,
      virt_text_pos = "inline",
    }
    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close()
    end

    -- Mason installs debugpy separately from each project's interpreter.
    -- nvim-dap-python still detects and uses the project's .venv to launch code.
    local debugpy_python = vim.fn.stdpath "data" .. "/mason/packages/debugpy/venv/bin/python"
    require("dap-python").setup(debugpy_python)

    require("neotest").setup {
      adapters = {
        require "neotest-python" {
          runner = "pytest",
          dap = { justMyCode = false },
        },
      },
      output = { open_on_run = "short" },
      quickfix = { enabled = true, open = false },
      status = { enabled = true, signs = true, virtual_text = false },
      diagnostic = { enabled = true, severity = vim.diagnostic.severity.ERROR },
      log_level = vim.log.levels.DEBUG,
    }

    pcall(vim.api.nvim_del_user_command, "NeotestLog")
    vim.api.nvim_create_user_command("NeotestLog", function()
      local paths = {
        vim.fn.stdpath "log" .. "/neotest.log",
        vim.fn.stdpath "data" .. "/neotest.log",
      }
      for _, path in ipairs(paths) do
        if vim.fn.filereadable(path) == 1 then
          vim.cmd("tabedit " .. vim.fn.fnameescape(path))
          return
        end
      end
      vim.notify("No Neotest log yet. Run a test, then try :NeotestLog again.", vim.log.levels.WARN)
    end, { desc = "Open Neotest diagnostic log" })
  end,
}
