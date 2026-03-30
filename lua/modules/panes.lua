local M = {}

local zoom_state = {
  active = false,
  restore_cmd = nil,
  win = nil,
}

local function pwsh_escape_single_quotes(value)
  return tostring(value):gsub("'", "''")
end

local function current_target_dir()
  if vim.bo.buftype == "terminal" then
    return vim.fn.getcwd()
  end

  local file_path = vim.fn.expand("%:p")
  if file_path == nil or file_path == "" or file_path:match("^term://") then
    return vim.fn.getcwd()
  end

  return vim.fn.fnamemodify(file_path, ":h")
end

function M.split_right()
  vim.cmd("vsplit")
end

function M.split_down()
  vim.cmd("split")
end

function M.close_current()
  if vim.fn.winnr("$") == 1 then
    vim.notify("当前只剩一个窗格了", vim.log.levels.INFO)
    return
  end

  vim.cmd("close")
end

function M.equalize()
  vim.cmd("wincmd =")
end

function M.toggle_zoom()
  local current_win = vim.api.nvim_get_current_win()

  if zoom_state.active and zoom_state.win == current_win and zoom_state.restore_cmd then
    vim.cmd(zoom_state.restore_cmd)
    zoom_state.active = false
    zoom_state.restore_cmd = nil
    zoom_state.win = nil
    vim.notify("窗格布局已还原", vim.log.levels.INFO)
    return
  end

  zoom_state.restore_cmd = vim.fn.winrestcmd()
  zoom_state.win = current_win
  zoom_state.active = true

  vim.cmd("wincmd |")
  vim.cmd("wincmd _")
  vim.notify("当前窗格已最大化", vim.log.levels.INFO)
end

function M.open_terminal_bottom()
  local target_dir = current_target_dir()

  vim.cmd("botright split")
  vim.cmd("resize 15")
  vim.cmd("terminal")

  local job_id = vim.b.terminal_job_id
  if job_id then
    vim.fn.chansend(job_id, {
      "Set-Location -LiteralPath '" .. pwsh_escape_single_quotes(target_dir) .. "'\r",
    })
  end

  vim.cmd("startinsert")
end

return M
