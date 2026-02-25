-- ===========================================================================
-- Clang-format 配置
-- ===========================================================================

-- 手动设置 clang-format 路径（如果系统已安装）
local clang_format_path = vim.fn.exepath("clang-format")
if clang_format_path ~= "" then
  vim.g.clang_format_path = clang_format_path
  print("Found clang-format at: " .. clang_format_path)
else
  print("clang-format not found in PATH")
end

-- 格式化快捷键
vim.keymap.set('n', '<leader>f', function()
  vim.cmd('!clang-format -i --style="{IndentWidth: 4, TabWidth: 4, UseTab: Never}" %')
  print("Formatted with clang-format (4 spaces)")
end, { desc = "格式化当前文件" })

-- 保存时自动格式化 C++ 文件
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = {"*.cpp", "*.c", "*.h", "*.hpp"},
  callback = function()
    if vim.fn.executable("clang-format") == 1 then
      vim.cmd('silent !clang-format -i --style="{IndentWidth: 4, TabWidth: 4, UseTab: Never}" %')
    end
  end,
  desc = "保存时自动格式化 C++ 文件"
})
