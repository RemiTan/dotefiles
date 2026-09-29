local settings = require "config.settings"

local M = {
  chat_buffer = nil,
  terminal_buffer = nil,
  main_buffer = nil,
  main_window = nil,
  chat_window = nil,
  panel_width = nil,
  mode = "chat",
  zen = false,
}

local function is_valid_buf(buf)
  return buf and vim.api.nvim_buf_is_valid(buf)
end

local function is_valid_win(win)
  return win and vim.api.nvim_win_is_valid(win)
end

local function is_chat_buffer(buf)
  if not is_valid_buf(buf) then
    return false
  end
  local ok, value = pcall(vim.api.nvim_buf_get_var, buf, "copilot_chat_workspace")
  return ok and value == true
end

local function is_terminal_panel_buffer(buf)
  if not is_valid_buf(buf) then
    return false
  end
  local ok, value = pcall(vim.api.nvim_buf_get_var, buf, "terminal_workspace_panel")
  return ok and value == true
end

local function is_panel_buffer(buf)
  return is_chat_buffer(buf) or is_terminal_panel_buffer(buf)
end

local function set_mode_from_buffer(buf)
  if is_chat_buffer(buf) then
    M.mode = "chat"
  elseif is_terminal_panel_buffer(buf) then
    M.mode = "terminal"
  end
end

local function terminal_is_running(buf)
  local ok, job = pcall(vim.api.nvim_buf_get_var, buf, "terminal_job_id")
  return ok and type(job) == "number" and vim.fn.jobwait({ job }, 0)[1] == -1
end

local function find_panel_buffer(mode)
  local cached = mode == "chat" and M.chat_buffer or M.terminal_buffer
  local is_kind = mode == "chat" and is_chat_buffer or is_terminal_panel_buffer
  if is_kind(cached) then
    return cached
  end
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if is_kind(buf) then
      if mode == "chat" then
        M.chat_buffer = buf
      else
        M.terminal_buffer = buf
      end
      return buf
    end
  end
end

local function find_panel_window()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if is_panel_buffer(buf) then
      set_mode_from_buffer(buf)
      return win
    end
  end
end

local function command_args()
  local command = settings.copilot_cli_command or "copilot"
  if type(command) == "table" then
    return command
  end
  return vim.fn.split(command)
end

local function panel_width()
  return math.max(30, math.floor(vim.o.columns * 0.36))
end

local function move_panel_rightmost(win)
  if M.zen or not is_valid_win(win) then
    return
  end
  vim.api.nvim_win_call(win, function()
    vim.cmd "wincmd L"
  end)
end

local function start_panel_in_current_buffer(mode, buf)
  local is_kind = mode == "chat" and is_chat_buffer or is_terminal_panel_buffer
  if is_kind(buf) and terminal_is_running(buf) then
    if mode == "chat" then
      M.chat_buffer = buf
    else
      M.terminal_buffer = buf
    end
    return true
  end

  local command = mode == "chat" and command_args() or vim.fn.split(vim.o.shell)
  if #command == 0 or vim.fn.executable(command[1]) ~= 1 then
    local message = mode == "chat" and "Copilot CLI not found. Install it or set copilot_cli_command in ~/.nvim-local.lua."
      or "Configured shell executable was not found"
    vim.notify(message, vim.log.levels.ERROR)
    return false
  end

  if is_panel_buffer(buf) then
    -- Terminal jobs cannot survive a full Neovim exit. Drop the dead buffer
    -- and restart its command instead of accumulating duplicate terminals.
    vim.api.nvim_buf_delete(buf, { force = true })
  end

  vim.cmd "enew"
  buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].bufhidden = "hide"
  local job = vim.fn.termopen(command, { cwd = vim.fn.getcwd() })
  if job <= 0 then
    vim.notify("Could not start Copilot CLI", vim.log.levels.ERROR)
    return false
  end
  if mode == "chat" then
    vim.b[buf].copilot_chat_workspace = true
    M.chat_buffer = buf
  else
    vim.b[buf].terminal_workspace_panel = true
    M.terminal_buffer = buf
  end
  return true
end

local function open_panel()
  local panel_win = find_panel_window()
  if panel_win then
    move_panel_rightmost(panel_win)
    M.chat_window = panel_win
    vim.api.nvim_set_current_win(panel_win)
    local panel_buf = find_panel_buffer(M.mode)
    local is_kind = M.mode == "chat" and is_chat_buffer or is_terminal_panel_buffer
    if is_kind(panel_buf) and terminal_is_running(panel_buf) then
      vim.api.nvim_win_set_buf(panel_win, panel_buf)
      return true
    end
    return start_panel_in_current_buffer(M.mode, panel_buf)
  end

  local current = vim.api.nvim_get_current_win()
  local current_buf = vim.api.nvim_get_current_buf()
  if not is_panel_buffer(current_buf) then
    M.main_window = current
    M.main_buffer = current_buf
  end

  vim.cmd "rightbelow vsplit"
  vim.cmd "wincmd L"
  local panel_buf = find_panel_buffer(M.mode)
  local is_kind = M.mode == "chat" and is_chat_buffer or is_terminal_panel_buffer
  if is_kind(panel_buf) and terminal_is_running(panel_buf) then
    vim.api.nvim_win_set_buf(0, panel_buf)
  else
    if panel_buf then
      vim.api.nvim_buf_delete(panel_buf, { force = true })
      if M.mode == "chat" then
        M.chat_buffer = nil
      else
        M.terminal_buffer = nil
      end
    end
    if not start_panel_in_current_buffer(M.mode, nil) then
      vim.cmd "close"
      return false
    end
  end

  M.chat_window = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_width(M.chat_window, panel_width())
  return true
end

local function restore_panel()
  local chat_win = vim.api.nvim_get_current_win()
  local panel_buf = vim.api.nvim_win_get_buf(chat_win)
  local main_buf = M.main_buffer
  if not is_valid_buf(main_buf) then
    vim.notify("No code buffer to restore beside the terminal panel", vim.log.levels.INFO)
    M.zen = false
    return false
  end

  vim.cmd "leftabove vsplit"
  local main_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(main_win, main_buf)
  M.main_window = main_win
  M.chat_window = chat_win
  if is_chat_buffer(panel_buf) then
    M.chat_buffer = panel_buf
  else
    M.terminal_buffer = panel_buf
  end
  vim.api.nvim_win_set_width(chat_win, M.panel_width or panel_width())
  M.zen = false
  vim.api.nvim_set_current_win(main_win)
  return true
end

function M.toggle()
  if M.zen then
    return restore_panel()
  end

  local current_buf = vim.api.nvim_get_current_buf()
  local panel_win = find_panel_window()
  if is_panel_buffer(current_buf) then
    set_mode_from_buffer(current_buf)
    local main_win = M.main_window
    if not is_valid_win(main_win) then
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if win ~= vim.api.nvim_get_current_win() and not is_panel_buffer(vim.api.nvim_win_get_buf(win)) then
          main_win = win
          M.main_window = win
          M.main_buffer = vim.api.nvim_win_get_buf(win)
          break
        end
      end
    end
    if is_valid_win(main_win) and main_win ~= vim.api.nvim_get_current_win() then
      vim.api.nvim_set_current_win(main_win)
      return
    end
    return
  end

  if panel_win then
    M.main_window = vim.api.nvim_get_current_win()
    M.main_buffer = current_buf
    move_panel_rightmost(panel_win)
    vim.api.nvim_set_current_win(panel_win)
    if start_panel_in_current_buffer(M.mode, vim.api.nvim_win_get_buf(panel_win)) then
      vim.cmd.startinsert()
    end
    return
  end

  if open_panel() then
    vim.cmd.startinsert()
  end
end

function M.hide()
  if M.zen then
    if not restore_panel() then
      return
    end
  end
  local panel_win = find_panel_window()
  if not panel_win then
    return
  end
  if vim.api.nvim_get_current_win() == panel_win and is_valid_win(M.main_window) then
    vim.api.nvim_set_current_win(M.main_window)
  end
  pcall(vim.api.nvim_win_close, panel_win, true)
  M.chat_window = nil
end

function M.toggle_zen()
  if M.zen then
    return restore_panel()
  end
  if not is_panel_buffer(vim.api.nvim_get_current_buf()) then
    M.main_window = vim.api.nvim_get_current_win()
    M.main_buffer = vim.api.nvim_get_current_buf()
  end
  if not open_panel() then
    return
  end
  local panel_win = vim.api.nvim_get_current_win()
  if not is_panel_buffer(vim.api.nvim_win_get_buf(panel_win)) then
    panel_win = find_panel_window()
  end
  if not is_valid_win(panel_win) then
    return
  end
  M.chat_window = panel_win
  if is_chat_buffer(vim.api.nvim_win_get_buf(panel_win)) then
    M.chat_buffer = vim.api.nvim_win_get_buf(panel_win)
  else
    M.terminal_buffer = vim.api.nvim_win_get_buf(panel_win)
  end
  M.panel_width = vim.api.nvim_win_get_width(panel_win)
  vim.api.nvim_set_current_win(panel_win)
  vim.cmd.only()
  M.chat_window = vim.api.nvim_get_current_win()
  M.zen = true
  vim.cmd.startinsert()
end

function M.toggle_mode()
  set_mode_from_buffer(vim.api.nvim_get_current_buf())
  local panel_win = find_panel_window()
  local target_mode = M.mode == "chat" and "terminal" or "chat"
  M.mode = target_mode
  if M.zen then
    panel_win = vim.api.nvim_get_current_win()
  elseif not panel_win then
    if not open_panel() then
      M.mode = target_mode == "chat" and "terminal" or "chat"
      return
    end
    panel_win = vim.api.nvim_get_current_win()
  else
    move_panel_rightmost(panel_win)
  end

  local buf = find_panel_buffer(M.mode)
  vim.api.nvim_set_current_win(panel_win)
  if buf and terminal_is_running(buf) then
    vim.api.nvim_win_set_buf(panel_win, buf)
  else
    if buf then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
    if not start_panel_in_current_buffer(M.mode, nil) then
      M.mode = target_mode == "chat" and "terminal" or "chat"
      return
    end
    buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_win_set_buf(panel_win, buf)
  end
  vim.cmd.startinsert()
end

function M.open_chat()
  M.mode = "chat"
  local panel_win = find_panel_window()
  M.mode = "chat"
  if panel_win then
    move_panel_rightmost(panel_win)
    vim.api.nvim_set_current_win(panel_win)
    local chat_buf = find_panel_buffer("chat")
    if chat_buf and terminal_is_running(chat_buf) then
      vim.api.nvim_win_set_buf(panel_win, chat_buf)
    elseif not start_panel_in_current_buffer("chat", chat_buf) then
      return
    end
  elseif not open_panel() then
    return
  end
  vim.cmd.startinsert()
end

function M.toggle_chat()
  local panel_win = find_panel_window()
  if panel_win and is_chat_buffer(vim.api.nvim_win_get_buf(panel_win)) then
    M.hide()
    return
  end
  M.open_chat()
end

local function reference_path(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  if name == "" then
    return nil
  end
  local root = vim.fs.root(buf, { ".git" }) or vim.fn.getcwd()
  local relative = vim.fn.fnamemodify(name, ":.")
  if vim.startswith(name, root .. "/") then
    relative = name:sub(#root + 2)
  else
    relative = name
  end
  return relative:gsub("\\", "/")
end

local function copy_reference(first, last)
  local path = reference_path(vim.api.nvim_get_current_buf())
  if not path then
    vim.notify("Save the buffer before copying a Copilot file reference", vim.log.levels.WARN)
    return
  end
  local reference = "@" .. path
  if first then
    if first == last then
      reference = string.format("%s (line %d)", reference, first)
    else
      reference = string.format("%s (lines %d-%d)", reference, first, last)
    end
  end
  vim.fn.setreg("+", reference)
  vim.notify("Copied Copilot reference: " .. reference, vim.log.levels.INFO)
end

vim.api.nvim_create_user_command("CopilotRef", function(opts)
  if opts.range == 0 then
    local line = vim.api.nvim_win_get_cursor(0)[1]
    copy_reference(line, line)
  else
    copy_reference(opts.line1, opts.line2)
  end
end, { range = true, desc = "Copy current line or selected lines as a Copilot reference" })

vim.api.nvim_create_user_command("CopilotFileRef", function()
  copy_reference(nil, nil)
end, { desc = "Copy current buffer as a Copilot file reference" })

vim.api.nvim_create_user_command("CopilotPanel", M.toggle, { desc = "Focus or open the Copilot CLI panel" })
vim.api.nvim_create_user_command("CopilotPanelHide", M.hide, { desc = "Hide the Copilot CLI panel" })
vim.api.nvim_create_user_command("CopilotPanelZen", M.toggle_zen, { desc = "Toggle full-screen workspace panel" })
vim.api.nvim_create_user_command("WorkspacePanelToggle", M.toggle_mode, { desc = "Switch between Copilot CLI and shell" })

return M
