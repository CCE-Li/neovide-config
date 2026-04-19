-- ===========================================================================
-- Neovim 主配置文件 (init.lua)
-- 核心原则：模块化加载 / 兼容 Neovide/终端 / 配置解耦
-- ===========================================================================

-- ======================== 1. 核心模块加载 (优先级最高) =====================
-- 注：确保以下模块文件路径正确（core/、ui/、modules/ 需存在）
local safe_require = function(module)
  local ok, result = pcall(require, module)
  if not ok then
    vim.notify("加载模块失败: " .. module .. " | " .. result, vim.log.levels.WARN)
    return nil
  end
  return result
end

local function prepend_env_path(paths)
  local path_sep = package.config:sub(1, 1) == "\\" and ";" or ":"
  local current = vim.env.PATH or ""
  local parts = vim.split(current, path_sep, { plain = true, trimempty = true })
  local seen = {}

  for _, part in ipairs(parts) do
    seen[part:lower()] = true
  end

  local prefix = {}
  for _, path in ipairs(paths) do
    if path ~= "" and vim.uv.fs_stat(path) and not seen[path:lower()] then
      table.insert(prefix, path)
      seen[path:lower()] = true
    end
  end

  if #prefix > 0 then
    vim.env.PATH = table.concat(prefix, path_sep) .. path_sep .. current
  end
end

prepend_env_path({
  "C:/Users/Lenovo/AppData/Local/Programs/Python/Python39",
  "C:/Users/Lenovo/AppData/Local/Programs/Python/Python39/Scripts",
  "C:/Python",
  "C:/Python/Scripts",
})

-- 基础样式/配置/快捷键/自动命令
safe_require("ui.neovide")    -- Neovide 界面样式设置
safe_require("core.options")  -- 基础全局配置（行号/缩进/编码等）
safe_require("core.keymaps")  -- 快捷键映射（已重构优化版）
safe_require("core.autocmds") -- 自动化脚本（自动命令）

-- 为仍使用旧 LSP API 的插件提供兼容层，避免触发废弃警告
if vim.lsp and vim.lsp.get_clients and vim.lsp.buf_get_clients then
  vim.lsp.buf_get_clients = function(bufnr)
    if type(bufnr) == "table" then
      return vim.lsp.get_clients(bufnr)
    end
    return vim.lsp.get_clients({ bufnr = bufnr })
  end
end

-- 插件配置（需确保 plugins.lua 存在且加载正常）
safe_require("plugins")

-- 功能模块加载
local bracket = safe_require("modules.bracket")
if bracket then bracket.setup() end -- 括号匹配+自动缩进
safe_require("modules.lsp")             -- LSP 基础配置
safe_require("modules.clang-format")   -- Clang-format 配置

-- ======================== 2. 全局鼠标行为优化 (全环境生效) =================
-- 注：core.options 中若已定义，此处会覆盖，建议统一移到 core.options 中
local mouse_opts = {
  mouse = 'a',                  -- 全模式启用鼠标
  mousemodel = 'extend',        -- 插入模式鼠标选中不切换可视模式
  virtualedit = 'onemore',      -- 允许光标移到行尾外（选中更友好）
  selectmode = 'mouse,key',     -- 选中后输入自动覆盖（编辑器习惯）
  scrolloff = 5,                -- 滚轮滚动保留5行上下文
}

-- 应用鼠标配置（避免重复 set）
for opt, val in pairs(mouse_opts) do
  if vim.opt[opt]:get() ~= val then
    vim.opt[opt] = val
  end
end

-- 滚轮步长优化（垂直/水平各1单位，更自然）
vim.api.nvim_set_option('mousescroll', 'ver:1,hor:1')

-- 移除自动注释换行（避免选中/换行时自动加注释符）
vim.opt.formatoptions:remove('o')

-- ===========================================================================
-- 配置结束
-- 注：所有模块建议遵循 "单一职责"，避免 init.lua 过度臃肿
-- ===========================================================================
