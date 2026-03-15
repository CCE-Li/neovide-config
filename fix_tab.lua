-- Tab缩进修复脚本
-- 在Neovim中运行: :source fix_tab.lua

-- 删除当前的Tab映射
vim.keymap.del('i', '<Tab>')

-- 重新设置正确的Tab映射
vim.keymap.set('i', '<Tab>', function()
  -- 检查是否有选中的文本
  local mode = vim.api.nvim_get_mode().mode
  if mode:find('v') or mode:find('V') or mode:find('s') or mode:find('S') then
    -- 有选中内容：增加缩进
    return vim.api.nvim_replace_termcodes('<Esc>><CR>gi', true, true, true)
  end
  
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local line_before_cursor = line:sub(1, col)
  
  -- 如果行首只有空白字符，执行智能缩进
  if line_before_cursor:match("^%s*$") then
    return vim.api.nvim_replace_termcodes('<C-t>', true, true, true)
  end
  
  -- 否则插入正常的Tab（转换为空格）
  return string.rep(' ', vim.o.shiftwidth)
end, { noremap = true, silent = true, expr = true, desc = "插入模式：Tab 智能缩进" })

-- 添加Shift+Tab减少缩进
vim.keymap.set('i', '<S-Tab>', function()
  -- 检查是否有选中的文本
  local mode = vim.api.nvim_get_mode().mode
  if mode:find('v') or mode:find('V') or mode:find('s') or mode:find('S') then
    -- 有选中内容：减少缩进
    return vim.api.nvim_replace_termcodes('<Esc><<CR>gi', true, true, true)
  end
  
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  local line_before_cursor = line:sub(1, col)
  
  -- 如果行首只有空白字符，执行减少缩进
  if line_before_cursor:match("^%s*$") then
    return vim.api.nvim_replace_termcodes('<C-d>', true, true, true)
  end
  
  -- 否则尝试删除一个缩进级别的空格
  local spaces_to_remove = math.min(col % vim.o.shiftwidth, vim.o.shiftwidth)
  if spaces_to_remove > 0 then
    return string.rep('<BS>', spaces_to_remove)
  else
    return '<BS>'
  end
end, { noremap = true, silent = true, expr = true, desc = "插入模式：Shift+Tab 减少缩进" })

print("Tab缩进修复完成！")
