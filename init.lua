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

-- 基础样式/配置/快捷键/自动命令
safe_require("ui.neovide")    -- Neovide 界面样式设置
safe_require("core.options")  -- 基础全局配置（行号/缩进/编码等）
safe_require("core.keymaps")  -- 快捷键映射（已重构优化版）
safe_require("core.autocmds") -- 自动化脚本（自动命令）

-- 插件配置（需确保 plugins.lua 存在且加载正常）
safe_require("plugins")

-- 功能模块加载
local bracket = safe_require("modules.bracket")
if bracket then bracket.setup() end -- 括号匹配+自动缩进
safe_require("modules.lsp")             -- LSP 基础配置
safe_require("modules.clang-format")   -- Clang-format 配置

-- ======================== 2. Neovide 专属配置 ==============================
if vim.g.neovide then
  -- -------------------------- 自动聚焦窗口 (启动/快捷键) -------------------
  local neovide_focus = function()
    -- 1. Neovide 内置聚焦命令
    vim.cmd("NeovideFocus")
    
    -- 2. 系统级兜底（跨平台兼容）
    local os_name = vim.loop.os_uname().sysname
    if os_name == "Windows_NT" then
      -- Windows：PowerShell 强制激活窗口
      vim.fn.system([[
        powershell -Command "$hwnd = (Get-Process neovide -ErrorAction SilentlyContinue).MainWindowHandle; 
        if ($hwnd) { [User32]::SetForegroundWindow($hwnd) }"
      ]])
    elseif os_name == "Darwin" then
      -- macOS：AppleScript 激活窗口
      vim.fn.system("osascript -e 'tell application \"Neovide\" to activate'")
    else
      -- Linux：wmctrl/xdotool 聚焦（需提前安装）
      vim.fn.system("wmctrl -a Neovide 2>/dev/null || xdotool search --name Neovide windowactivate 2>/dev/null")
    end
  end

  -- 启动时延迟聚焦（适配慢启动场景）
  vim.defer_fn(neovide_focus, 100) -- 延迟 100ms，避免启动未完成

  -- 手动聚焦快捷键 (Leader + ff)
  vim.keymap.set('n', '<leader>ff', neovide_focus, {
    noremap = true,
    silent = true,
    desc = "Neovide: 强制聚焦窗口（跨平台兼容）"
  })

  -- -------------------------- Neovide 语言/编码配置 ------------------------
  -- 强制全局语言为英文（避免中文乱码/兼容问题）
  vim.env.LANG = "en_US.UTF-8"
  vim.env.LC_ALL = "en_US.UTF-8"
  vim.o.langmenu = "en_US"
end

-- ======================== 3. 全局鼠标行为优化 (全环境生效) =================
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