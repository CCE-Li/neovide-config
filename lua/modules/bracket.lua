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
-- setup
--------------------------------------------------
function M.setup()
  local brackets = { "(", ")", "[", "]", "{", "}", '"', "'" }

  for _, char in ipairs(brackets) do
    vim.keymap.set("i", char, function()
      return insert_pair(char)
    end, { expr = true, noremap = true })
  end

  vim.keymap.set("i", "<BS>", function()
    return delete_pair()
  end, { expr = true, noremap = true })

  vim.keymap.set("i", "<CR>", function()
    return smart_enter()
  end, { expr = true, noremap = true })
end

return M
