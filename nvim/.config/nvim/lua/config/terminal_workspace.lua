local M = {
  terminal_tab = nil,
  return_tab = nil,
  cwd = nil,
}

local function tab_is_valid(tab)
  return tab and vim.api.nvim_tabpage_is_valid(tab)
end

local function current_tab()
  return vim.api.nvim_get_current_tabpage()
end

local function go_to_tab(tab)
  if not tab_is_valid(tab) then
    return false
  end
  vim.api.nvim_set_current_tabpage(tab)
  return true
end

local function find_live_workspace_terminal()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal" then
      local ok, is_workspace_terminal = pcall(vim.api.nvim_buf_get_var, buf, "terminal_workspace")
      if ok and is_workspace_terminal then
        local job_ok, job = pcall(vim.api.nvim_buf_get_var, buf, "terminal_job_id")
        if job_ok and type(job) == "number" and vim.fn.jobwait({ job }, 0)[1] == -1 then
          return buf
        end
      end
    end
  end
end

local function show_terminal(buf)
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(M.terminal_tab)) do
    if vim.api.nvim_win_get_buf(win) == buf then
      vim.api.nvim_set_current_win(win)
      return
    end
  end
  vim.api.nvim_set_current_buf(buf)
end

local function create_terminal_tab(cwd)
  vim.cmd.tabnew()
  M.terminal_tab = current_tab()
  M.cwd = cwd or vim.fn.getcwd()
  vim.t.terminal_workspace = true
  return M.terminal_tab
end

local function make_terminal(direction, reuse_current_window)
  local tab = current_tab()
  if tab ~= M.terminal_tab then
    M.return_tab = tab
    M.cwd = vim.fn.getcwd()
    if not tab_is_valid(M.terminal_tab) then
      create_terminal_tab(M.cwd)
    else
      go_to_tab(M.terminal_tab)
    end
  end

  local line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
  local reuse_empty_buffer = vim.bo.buftype == "" and vim.api.nvim_buf_get_name(0) == ""
    and vim.api.nvim_buf_line_count(0) == 1 and line == ""
  if reuse_current_window and not reuse_empty_buffer and vim.bo.buftype == "terminal" then
    vim.cmd("enew")
    reuse_empty_buffer = true
  end

  if not reuse_current_window and not reuse_empty_buffer and direction == "vertical" then
    vim.cmd("rightbelow vsplit")
  elseif not reuse_current_window and not reuse_empty_buffer then
    vim.cmd("rightbelow split")
  end

  if not reuse_empty_buffer then
    vim.cmd("enew")
  end
  local buf = vim.api.nvim_get_current_buf()
  vim.bo[buf].bufhidden = "hide"
  vim.fn.termopen(vim.o.shell, { cwd = M.cwd or vim.fn.getcwd() })
  vim.b[buf].terminal_workspace = true
  vim.cmd.startinsert()
end

function M.toggle()
  local tab = current_tab()
  if tab == M.terminal_tab then
    if not go_to_tab(M.return_tab) then
      vim.notify("No code tab to return to", vim.log.levels.INFO)
    end
    return
  end

  M.return_tab = tab
  M.cwd = vim.fn.getcwd()
  if not tab_is_valid(M.terminal_tab) then
    create_terminal_tab(M.cwd)
  else
    go_to_tab(M.terminal_tab)
  end

  local terminal = find_live_workspace_terminal()
  if terminal then
    show_terminal(terminal)
    vim.cmd.startinsert()
  else
    make_terminal("horizontal", true)
  end
end

function M.horizontal()
  make_terminal("horizontal")
end

function M.vertical()
  make_terminal("vertical")
end

vim.api.nvim_create_user_command("TermWorkspace", M.toggle, { desc = "Toggle terminal workspace" })
vim.api.nvim_create_user_command("TermNewHorizontal", M.horizontal, { desc = "Add a horizontal workspace terminal" })
vim.api.nvim_create_user_command("TermNewVertical", M.vertical, { desc = "Add a vertical workspace terminal" })

return M
