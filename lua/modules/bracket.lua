-- lua/bracket.lua
local M = {}

--------------------------------------------------
-- 工具函数
--------------------------------------------------
local function get_cursor()
  local pos = vim.api.nvim_win_get_cursor(0)
  return pos[1] - 1, pos[2]  -- row(0-based), col(0-based)
end

local function get_line(row)
  return vim.api.nvim_buf_get_lines(0, row, row + 1, false)[1] or ""
end

local function clamp_cursor_col(row, col)
  local line = get_line(row)
  return math.max(0, math.min(col, #line))
end

local function clamp_row(row)
  local line_count = vim.api.nvim_buf_line_count(0)
  return math.max(0, math.min(row, math.max(0, line_count - 1)))
end

local function get_active_selection_bounds(mode)
  local visual_start = vim.fn.getpos("v")
  local cursor = vim.api.nvim_win_get_cursor(0)

  local start_row = clamp_row((visual_start[2] or 1) - 1)
  local start_col = math.max(0, (visual_start[3] or 1) - 1)
  local end_row = clamp_row((cursor[1] or 1) - 1)
  local end_col = math.max(0, cursor[2] or 0)

  if start_row > end_row or (start_row == end_row and start_col > end_col) then
    start_row, end_row = end_row, start_row
    start_col, end_col = end_col, start_col
  end

  if mode == "V" or mode == "S" then
    start_col = 0
    end_col = #get_line(end_row)
  else
    start_col = clamp_cursor_col(start_row, start_col)
    end_col = clamp_cursor_col(end_row, end_col + 1)
  end

  return start_row, start_col, end_row, end_col
end

--------------------------------------------------
-- 智能回车
--------------------------------------------------
local function smart_enter()
  local row, col = get_cursor()
  local line = get_line(row)

  local indent = vim.fn.indent(row + 1)
  local shiftwidth = vim.o.shiftwidth

  local left_char  = line:sub(col, col)
  local right_char = line:sub(col + 1, col + 1)

  if left_char == "{" and right_char == "}" then
    vim.schedule(function()
      -- 删除 }
      vim.api.nvim_buf_set_text(0, row, col, row, col + 1, {})

      -- 插入两行
      vim.api.nvim_buf_set_lines(0, row + 1, row + 1, false, {
        string.rep(" ", indent + shiftwidth),
        string.rep(" ", indent) .. "}",
      })

      -- 光标移到中间
      vim.api.nvim_win_set_cursor(0, { row + 2, indent + shiftwidth })
    end)
    return ""
  end

  return "\n"
end

--------------------------------------------------
-- 插入括号对
--------------------------------------------------
local function insert_pair(char)
  local pair_map = {
    ["("] = ")",
    ["["] = "]",
    ["{"] = "}",
    ['"'] = '"',
    ["'"] = "'",
  }

  local row, col = get_cursor()

  -- 左括号
  if pair_map[char] then
    vim.schedule(function()
      vim.api.nvim_buf_set_text(
        0,
        row,
        col,
        row,
        col,
        { char .. pair_map[char] }
      )
      vim.api.nvim_win_set_cursor(0, { row + 1, col + 1 })
    end)
    return ""
  end

  -- 右括号跳过
  local line = get_line(row)
  local next_char = line:sub(col + 1, col + 1)

  if next_char == char then
    vim.schedule(function()
      vim.api.nvim_win_set_cursor(0, { row + 1, col + 1 })
    end)
    return ""
  end

  return char
end

--------------------------------------------------
-- 删除括号对
--------------------------------------------------
local function delete_pair()
  local row, col = get_cursor()

  if col == 0 then
    return "<BS>"
  end

  local line = get_line(row)

  local left_char  = line:sub(col, col)
  local right_char = line:sub(col + 1, col + 1)

  local pair_map = {
    ["("] = ")",
    ["["] = "]",
    ["{"] = "}",
    ['"'] = '"',
    ["'"] = "'",
  }

  if pair_map[left_char] == right_char then
    vim.schedule(function()
      vim.api.nvim_buf_set_text(0, row, col - 1, row, col + 1, {})
      vim.api.nvim_win_set_cursor(0, { row + 1, col - 1 })
    end)
    return ""
  end

  return "<BS>"
end

--------------------------------------------------
-- 包裹选中文本
--------------------------------------------------
local function surround_selection(open_char)
  local pair_map = {
    ["("] = ")",
    ["["] = "]",
    ["{"] = "}",
    ['"'] = '"',
    ["'"] = "'",
  }

  local close_char = pair_map[open_char]
  if not close_char then
    return
  end

  local mode = vim.fn.mode()
  local start_row, start_col, end_row, end_col = get_active_selection_bounds(mode)

  vim.api.nvim_buf_set_text(0, end_row, end_col, end_row, end_col, { close_char })
  vim.api.nvim_buf_set_text(0, start_row, start_col, start_row, start_col, { open_char })

  local cursor_col = clamp_cursor_col(start_row, start_col + 1)
  pcall(vim.api.nvim_win_set_cursor, 0, { start_row + 1, cursor_col })
end

--------------------------------------------------
-- setup
--------------------------------------------------
function M.setup()
  local brackets = { "(", ")", "[", "]", "{", "}", '"', "'" }
  local surround_chars = { "(", "[", "{", '"', "'" }

  for _, char in ipairs(brackets) do
    vim.keymap.set("i", char, function()
      return insert_pair(char)
    end, { expr = true, noremap = true })
  end

  for _, char in ipairs(surround_chars) do
    vim.keymap.set("x", char, function()
      surround_selection(char)
    end, { noremap = true, silent = true })

    vim.keymap.set("s", char, function()
      local visual_keys = vim.keycode("<C-g>")
      vim.api.nvim_feedkeys(visual_keys, "n", false)
      vim.schedule(function()
        surround_selection(char)
      end)
    end, { noremap = true, silent = true })
  end

  vim.keymap.set("i", "<BS>", function()
    return delete_pair()
  end, { expr = true, noremap = true })

  vim.keymap.set("i", "<CR>", function()
    return smart_enter()
  end, { expr = true, noremap = true })
end

return M
