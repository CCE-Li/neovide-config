-- ===========================================================================
-- Neovim 基础配置 (options.lua)
-- 核心原则：模块化划分 / 注释清晰 / 兼容终端/图形界面
-- ===========================================================================

-- ======================== 核心映射配置 (必须前置) ==========================
-- 设置 Leader 键为空格（Vim 插件常用的前缀键）
vim.g.mapleader = " "
vim.g.maplocalleader = " " -- 局部 Leader 键（部分插件使用）

-- ======================== 1. 界面显示配置 ================================
local ui_opts = {
  number = true,               -- 显示绝对行号
  relativenumber = true,       -- 显示相对行号（便于跳转）
  cursorline = true,           -- 高亮当前光标所在行
  scrolloff = 5,               -- 滚动时保留5行上下文（避免光标贴边）
  signcolumn = "yes",          -- 始终显示符号列（左侧git/诊断图标列）
  wrap = false,                -- 禁用行自动换行（代码编辑更友好）
  cmdheight = 1,               -- 命令行高度（1行足够，节省空间）
  showmode = false,            -- 隐藏模式提示（如 -- INSERT --，插件会替代）
  showcmd = true,              -- 显示正在输入的命令（新手友好）
  laststatus = 3,              -- 全局统一状态栏（多窗口时更整洁）
  termguicolors = true,        -- 启用真彩色（终端需支持，显示主题完整配色）
}

-- ======================== 2. 缩进配置 (核心，和快捷键联动) =================
local indent_opts = {
  tabstop = 2,                 -- Tab 键显示宽度（2个字符）
  shiftwidth = 2,              -- 自动缩进/>>/<< 时的空格数（和 tabstop 一致）
  expandtab = true,            -- 将 Tab 键转换为空格（代码规范）
  softtabstop = 2,             -- 插入模式下 Tab 键实际插入的空格数
  smartindent = true,          -- 智能缩进（针对代码块的自动缩进优化）
  autoindent = true,           -- 换行时继承上一行的缩进
}

-- ======================== 3. 编辑行为配置 ================================
local edit_opts = {
  encoding = "utf-8",          -- 全局编码（避免中文乱码）
  fileencoding = "utf-8",      -- 文件编码（保存时使用）
  backspace = "indent,eol,start", -- 退格键可删除缩进/行尾/行首字符
  virtualedit = "onemore",     -- 允许光标移到行尾字符外（选中更友好）
  selectmode = "mouse,key",    -- 鼠标/键盘选中后输入自动覆盖（编辑器习惯）
  keymodel = "startsel,stopsel", -- Shift+方向键开始/扩展选择，普通方向键退出选择
  mouse = "a",                 -- 全模式启用鼠标支持
  mousemodel = "extend",       -- 插入模式鼠标选中不切换到可视模式
}

-- ======================== 4. 性能/交互配置 ===============================
local perf_opts = {
  updatetime = 300,            -- 自动保存/诊断刷新间隔（300ms，响应更快）
  timeoutlen = 500,            -- 快捷键组合超时时间（500ms，新手友好）
  ttimeoutlen = 10,            -- 终端键码超时时间（减少乱码）
  lazyredraw = true,           -- 执行宏/插件时延迟重绘（提升性能）
  swapfile = false,            -- 禁用交换文件（避免生成 .swp 文件）
  backup = false,              -- 禁用备份文件
  writebackup = false,         -- 保存时禁用临时备份
  undofile = true,             -- 启用持久化撤销（关闭文件后仍可撤销）
  undodir = vim.fn.stdpath("data") .. "/undo", -- 撤销文件存储路径
}

-- ======================== 5. 剪贴板配置 ==================================
local clipboard_opts = {
  clipboard = "unnamedplus",   -- 联动系统剪贴板（Windows/macOS/Linux通用）
}

-- ======================== 应用所有配置 ====================================
-- 合并所有配置项
local all_opts = vim.tbl_deep_extend("force",
  ui_opts,
  indent_opts,
  edit_opts,
  perf_opts,
  clipboard_opts
)

-- 批量应用配置
for opt, value in pairs(all_opts) do
  vim.opt[opt] = value
end

-- ======================== 额外优化配置 (补充) =============================
-- 显示标签栏以查看当前打开的文件
vim.opt.showtabline = 2        -- 始终显示标签栏
-- vim.opt.laststatus = 0         -- 隐藏状态栏（如果不需要）
vim.opt.laststatus = 3         -- 全局状态栏（如果需要保留）

-- 创建撤销文件目录（避免 undofile=true 报错）
vim.fn.mkdir(vim.fn.stdpath("data") .. "/undo", "p")

-- ===========================================================================
-- 配置结束
-- ===========================================================================
