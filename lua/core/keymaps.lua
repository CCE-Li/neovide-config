-- ===========================================================================
-- Neovim 热键配置 (重构版)
-- 核心原则：结构清晰 / 注释完整 / 兼容插入/普通模式 / 贴合编辑器习惯
-- ===========================================================================

-- ======================== 基础全局配置 (必须前置) ==========================
local global_opts = {
  clipboard = "unnamedplus",    -- 系统剪贴板集成
  mouse = "a",                  -- 全模式启用鼠标
  mousemodel = "extend",        -- 插入模式鼠标选中不切换模式
  virtualedit = "onemore",      -- 允许光标移到行尾外
  selectmode = "mouse,key",     -- 选中后输入自动覆盖
  shiftwidth = 4,               -- 缩进宽度（和 Tab 配置联动）
  tabstop = 4,
  softtabstop = 4,
  expandtab = true,             -- Tab 转为空格
}

-- 应用全局配置
for k, v in pairs(global_opts) do
  vim.o[k] = v
end

-- ======================== 通用映射参数 (复用) ==============================
-- 基础映射参数：无递归 + 静默 + 描述
local map_opts = {
  noremap = true,
  silent = true,
  desc = "" -- 每个映射单独覆盖
}

-- 表达式映射参数 (用于 Tab/退格等动态逻辑)
local expr_opts = vim.tbl_extend("force", map_opts, { expr = true })

-- ======================== 1. 基础编辑快捷键 (Ctrl+方向键/删除/撤销) ========
local edit_mode = { "n", "i" } -- 同时生效于普通/插入模式

-- -------------------------- Ctrl + 方向键 (按单词/行跳转) -------------------
-- 左/右：按单词跳转 | 上/下：跳转到行首/行尾
vim.keymap.set("n", "<C-Left>", "b", vim.tbl_extend("force", map_opts, { desc = "普通模式：按单词左跳" }))
vim.keymap.set("i", "<C-Left>", "<C-o>b", vim.tbl_extend("force", map_opts, { desc = "插入模式：按单词左跳" }))

vim.keymap.set("n", "<C-Right>", "w", vim.tbl_extend("force", map_opts, { desc = "普通模式：按单词右跳" }))
vim.keymap.set("i", "<C-Right>", "<C-o>w", vim.tbl_extend("force", map_opts, { desc = "插入模式：按单词右跳" }))

vim.keymap.set("n", "<C-Up>", "^", vim.tbl_extend("force", map_opts, { desc = "普通模式：跳转到行首" }))
vim.keymap.set("i", "<C-Up>", "<C-o>^", vim.tbl_extend("force", map_opts, { desc = "插入模式：跳转到行首" }))

vim.keymap.set("n", "<C-Down>", "$", vim.tbl_extend("force", map_opts, { desc = "普通模式：跳转到行尾" }))
vim.keymap.set("i", "<C-Down>", "<C-o>$", vim.tbl_extend("force", map_opts, { desc = "插入模式：跳转到行尾" }))

-- -------------------------- Ctrl + Backspace (删除单词) --------------------
vim.keymap.set("n", "<C-BS>", "db", vim.tbl_extend("force", map_opts, { desc = "普通模式：删除前一个单词" }))
vim.keymap.set("i", "<C-BS>", "<C-w>", vim.tbl_extend("force", map_opts, { desc = "插入模式：删除前一个单词" }))

-- -------------------------- 撤销/重做 (Ctrl+Z/Ctrl+Shift+Z) ----------------
vim.keymap.set(edit_mode, "<C-z>", "u", vim.tbl_extend("force", map_opts, { desc = "撤销操作" }))
vim.keymap.set(edit_mode, "<C-S-z>", "<C-r>", vim.tbl_extend("force", map_opts, { desc = "重做操作" }))
-- 插入模式兼容：通过<C-o>执行普通模式命令
vim.keymap.set("i", "<C-z>", "<C-o>u", vim.tbl_extend("force", map_opts, { desc = "插入模式：撤销" }))
vim.keymap.set("i", "<C-S-z>", "<C-o><C-r>", vim.tbl_extend("force", map_opts, { desc = "插入模式：重做" }))

-- -------------------------- 换行 (Ctrl+Enter/Shift+Enter) ------------------
vim.keymap.set(edit_mode, "<S-CR>", "<Esc>o", vim.tbl_extend("force", map_opts, { desc = "下一行开头（插入模式）" }))
vim.keymap.set(edit_mode, "<C-CR>", "<Esc>O", vim.tbl_extend("force", map_opts, { desc = "上一行开头（插入模式）" }))

-- ======================== 2. Tab/缩进配置 (智能缩进) =======================
-- 插入模式 Tab 键：空行自动缩进 / 非空行插入4空格
vim.keymap.set('i', '<Tab>', function()
  local line = vim.api.nvim_get_current_line()
  local trimmed_line = vim.trim(line)
  
  if trimmed_line == "" then
    -- 空行：执行 Vim 内置自动缩进
    return vim.api.nvim_replace_termcodes('<C-t>', true, true, true)
  else
    -- 非空行：插入4个空格（匹配全局缩进配置）
    return string.rep(' ', vim.o.shiftwidth)
  end
end, vim.tbl_extend("force", expr_opts, { desc = "插入模式：Tab 智能缩进" }))

-- ======================== 3. 复制/粘贴 (Ctrl+C/Ctrl+V) =====================
-- -------------------------- 复制 (Ctrl+C) ----------------------------------
-- 可视模式：复制选中内容到系统剪贴板
vim.keymap.set('v', '<C-c>', '"+y', vim.tbl_extend("force", map_opts, { desc = "可视模式：复制选中内容" }))
-- 插入模式：有选中则复制，无选中则保留原中断行为
vim.keymap.set('i', '<C-c>', function()
  local mode = vim.api.nvim_get_mode().mode
  if mode:find('v') then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<ESC>"+y', true, true, true), 'n', false)
    return '<ESC>a' -- 复制后回到插入模式
  else
    return '<C-c>'
  end
end, vim.tbl_extend("force", expr_opts, { desc = "插入模式：复制/中断" }))
-- 普通模式：复制当前行
vim.keymap.set('n', '<C-c>', '"+yy', vim.tbl_extend("force", map_opts, { desc = "普通模式：复制当前行" }))

-- -------------------------- 粘贴 (Ctrl+V) ----------------------------------
-- 插入模式：粘贴系统剪贴板内容
vim.keymap.set('i', '<C-v>', '<ESC>"+pa', vim.tbl_extend("force", map_opts, { desc = "插入模式：粘贴内容" }))
-- 可视模式：粘贴并覆盖选中内容
vim.keymap.set('v', '<C-v>', '"_d"+P', vim.tbl_extend("force", map_opts, { desc = "可视模式：粘贴覆盖选中内容" }))

-- ======================== 4. 窗口/标签页管理 ===============================
local window_mode = { "n", "i" }

-- -------------------------- 标签页切换 (Ctrl+Alt+方向键) --------------------
vim.keymap.set(window_mode, '<C-A-Left>', ':bprevious<CR>', vim.tbl_extend("force", map_opts, { desc = "切换到上一个缓冲区" }))
vim.keymap.set(window_mode, '<C-A-Right>', ':bnext<CR>', vim.tbl_extend("force", map_opts, { desc = "切换到下一个缓冲区" }))

-- -------------------------- 窗口大小调整 (Alt+Shift+Ctrl+方向键/hjkl) -------
local resize_opts = vim.tbl_extend("force", map_opts, { desc = "调整窗口大小" })
-- hjkl 调整（每次2单位，更顺滑）
vim.keymap.set(window_mode, '<A-S-C-h>', '<C-w>2<', resize_opts)
vim.keymap.set(window_mode, '<A-S-C-l>', '<C-w>2>', resize_opts)
vim.keymap.set(window_mode, '<A-S-C-j>', '<C-w>2-', resize_opts)
vim.keymap.set(window_mode, '<A-S-C-k>', '<C-w>2+', resize_opts)
-- 方向键兼容
vim.keymap.set(window_mode, '<A-S-C-Left>', '<C-w>2<', resize_opts)
vim.keymap.set(window_mode, '<A-S-C-Right>', '<C-w>2>', resize_opts)
vim.keymap.set(window_mode, '<A-S-C-Down>', '<C-w>2-', resize_opts)
vim.keymap.set(window_mode, '<A-S-C-Up>', '<C-w>2+', resize_opts)

-- -------------------------- Neovide 兼容配置 -------------------------------
if vim.g.neovide then
  vim.g.neovide_input_macos_alt_is_meta = true -- macOS Alt 映射为 Meta
  vim.g.neovide_input_use_logo = false         -- 避免 Cmd/Win 键干扰

  -- 兼容键码（部分终端识别为 <M-S-h> 而非 <A-S-h>）
  local neovide_opts = vim.tbl_extend("force", map_opts, { desc = "Neovide 兼容：调整窗口大小" })
  vim.keymap.set(window_mode, '<M-S-h>', '<C-w>2<', neovide_opts)
  vim.keymap.set(window_mode, '<M-S-l>', '<C-w>2>', neovide_opts)
  vim.keymap.set(window_mode, '<M-S-j>', '<C-w>2-', neovide_opts)
  vim.keymap.set(window_mode, '<M-S-k>', '<C-w>2+', neovide_opts)
end

-- ======================== 5. 编译运行 (ACM 竞赛专用) =======================
local acm_mode = { "n", "i" }

-- F5：保存并编译运行 C++ 文件
vim.keymap.set(acm_mode, "<F5>", function()
  vim.cmd("w")
  local filename = vim.fn.expand("%")
  local exe_name = vim.fn.expand("%:r") .. ".exe"
  local compile_cmd = string.format("g++ -std=c++17 -O2 %s -o %s 2>&1", filename, exe_name)
  local output = vim.fn.system(compile_cmd)

  if vim.v.shell_error == 0 then
    local run_cmd = string.format(
      "start cmd /k \"chcp 65001 && .\\%s && echo. && echo 按回车键退出... && pause > nul && exit\"",
      exe_name
    )
    vim.fn.system(run_cmd)
  else
    print("编译失败：")
    print(output)
  end
end, vim.tbl_extend("force", map_opts, { desc = "ACM：编译并运行 C++ 文件" }))

-- F6：直接运行已编译的 exe 文件
vim.keymap.set(acm_mode, "<F6>", function()
  local exe_name = vim.fn.expand("%:r") .. ".exe"
  local run_cmd = string.format(
    "start cmd /k \"chcp 65001 && .\\%s && echo. && echo 按回车键退出... && pause > nul && exit\"",
    exe_name
  )
  vim.fn.system(run_cmd)
end, vim.tbl_extend("force", map_opts, { desc = "ACM：运行已编译的 C++ 程序" }))

-- F9：调试 (gdb)
vim.keymap.set(acm_mode, "<F9>", ":w<CR>:!gdb %:r.exe<CR>", vim.tbl_extend("force", map_opts, { desc = "ACM：调试 C++ 程序" }))

-- F8：CompetiTest 运行测试用例
vim.keymap.set("n", "<F8>", ":CompetiTest run<CR>", vim.tbl_extend("force", map_opts, { desc = "CompetiTest：运行测试用例" }))
vim.keymap.set("i", "<F8>", "<ESC>:CompetiTest run<CR>a", vim.tbl_extend("force", map_opts, { desc = "CompetiTest：运行测试用例（插入模式）" }))

-- Leader + t：插入 ACM 模板
pcall(function()
  local acm = require("modules.acm")
  vim.keymap.set("n", "<leader>t", function()
    acm.insert_template()
  end, vim.tbl_extend("force", map_opts, { desc = "ACM：插入模板代码" }))
end)

-- ======================== 6. 插件快捷键 ===================================
-- Leader + y：打开 Yazi 文件管理器
vim.keymap.set("n", "<leader>y", "<cmd>Yazi<cr>", vim.tbl_extend("force", map_opts, { desc = "打开 Yazi 文件管理器" }))

-- F2：切换 NvimTree 文件管理器
vim.keymap.set('n', '<F2>', ':NvimTreeToggle<CR>', vim.tbl_extend("force", map_opts, { desc = "切换 NvimTree 显示/隐藏" }))
vim.keymap.set('i', '<F2>', '<Esc>:NvimTreeToggle<CR>a', vim.tbl_extend("force", map_opts, { desc = "切换 NvimTree（插入模式）" }))

-- ===========================================================================
-- 配置结束
-- ===========================================================================