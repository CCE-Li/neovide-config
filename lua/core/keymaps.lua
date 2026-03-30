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
  shiftwidth = 2,               -- 缩进宽度（和 Tab 配置联动）
  tabstop = 2,
  softtabstop = 2,
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

local function pwsh_escape_single_quotes(value)
  return tostring(value):gsub("'", "''")
end

local function pwsh_cd_command(dir)
  return "Set-Location -LiteralPath '" .. pwsh_escape_single_quotes(dir) .. "'"
end

local function current_buffer_dir()
  if vim.bo.buftype == "terminal" then
    return vim.fn.getcwd()
  end

  local file_path = vim.fn.expand("%:p")
  if file_path == nil or file_path == "" or file_path:match("^term://") then
    return vim.fn.getcwd()
  end

  return vim.fn.fnamemodify(file_path, ":h")
end

local function open_pwsh_command(command)
  local escaped = command:gsub('"', '`"')
  local full_cmd = string.format(
    'Start-Process pwsh -ArgumentList "-NoExit", "-Command", "%s"',
    escaped
  )
  return vim.fn.system(full_cmd)
end

local function compile_cpp_file(file_path)
  local exe_path = vim.fn.fnamemodify(file_path, ":r") .. ".exe"
  local compile_cmd = string.format(
    "g++ -std=c++17 -O2 '%s' -o '%s' 2>&1",
    pwsh_escape_single_quotes(file_path),
    pwsh_escape_single_quotes(exe_path)
  )
  local output = vim.fn.system(compile_cmd)
  return vim.v.shell_error == 0, exe_path, output
end

local function list_txt_files(dir)
  local files = vim.fn.globpath(dir, "*.txt", false, true)
  table.sort(files, function(a, b)
    return a:lower() < b:lower()
  end)
  return files
end

local function open_input_picker(on_select)
  local target_dir = current_buffer_dir()
  local txt_files = list_txt_files(target_dir)

  if #txt_files == 0 then
    vim.notify("当前目录下没有 .txt 输入文件", vim.log.levels.WARN)
    return
  end

  local display_lines = {}
  for _, file in ipairs(txt_files) do
    table.insert(display_lines, vim.fn.fnamemodify(file, ":t"))
  end

  local width = 0
  for _, line in ipairs(display_lines) do
    width = math.max(width, vim.fn.strdisplaywidth(line))
  end
  width = math.max(width + 4, 28)

  local height = math.min(#display_lines, math.max(4, vim.o.lines - 6))
  local row = math.floor((vim.o.lines - height) / 2 - 1)
  local col = math.floor((vim.o.columns - width) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, display_lines)

  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype = "f6_input_picker"

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = math.max(row, 1),
    col = math.max(col, 0),
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
    title = " 选择输入样例 ",
    title_pos = "center",
  })

  vim.wo[win].cursorline = true
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].signcolumn = "no"

  local function close_picker()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end

  local function confirm_selection()
    local line = vim.api.nvim_win_get_cursor(win)[1]
    local selected = txt_files[line]
    close_picker()
    if selected then
      on_select(selected)
    end
  end

  local function move_cursor(delta)
    local line = vim.api.nvim_win_get_cursor(win)[1]
    local next_line = math.max(1, math.min(#txt_files, line + delta))
    vim.api.nvim_win_set_cursor(win, { next_line, 0 })
  end

  local picker_opts = { buffer = buf, noremap = true, silent = true, nowait = true }
  vim.keymap.set("n", "j", function() move_cursor(1) end, picker_opts)
  vim.keymap.set("n", "k", function() move_cursor(-1) end, picker_opts)
  vim.keymap.set("n", "<Down>", function() move_cursor(1) end, picker_opts)
  vim.keymap.set("n", "<Up>", function() move_cursor(-1) end, picker_opts)
  vim.keymap.set("n", "<CR>", confirm_selection, picker_opts)
  vim.keymap.set("n", "q", close_picker, picker_opts)
  vim.keymap.set("n", "<Esc>", close_picker, picker_opts)
end


local function close_current_entry(force)
  local current_buf = vim.api.nvim_get_current_buf()
  local wins_in_tab = vim.api.nvim_tabpage_list_wins(0)
  local listed_buffers = vim.tbl_filter(function(buf)
    return vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted
  end, vim.api.nvim_list_bufs())

  if #wins_in_tab > 1 then
    vim.cmd(force and "q!" or "q")
    return
  end

  if #listed_buffers <= 1 then
    vim.cmd(force and "quitall!" or "confirm quitall")
    return
  end

  local delete_cmd = string.format("%sbdelete %d", force and "" or "confirm ", current_buf)
  local ok = pcall(vim.cmd, delete_cmd)
  if not ok then
    return
  end
end

vim.api.nvim_create_user_command("CloseCurrentEntry", function(opts)
  close_current_entry(opts.bang)
end, { bang = true })

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

-- -------------------------- 复制当前行到下一行 (Ctrl+D) --------------------
vim.keymap.set("i", "<C-d>", function()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()

  vim.api.nvim_buf_set_lines(0, row, row, false, { line })
  vim.api.nvim_win_set_cursor(0, { row + 1, col })
  vim.cmd("startinsert")
end, vim.tbl_extend("force", map_opts, { desc = "插入模式：复制当前行到下一行" }))

-- ======================== 2. Tab/缩进配置 (智能缩进) =======================
-- 插入模式 Tab 键：空行自动缩进 / 非空行插入2空格
vim.keymap.set('i', '<Tab>', function()
  local line = vim.api.nvim_get_current_line()
  local trimmed_line = vim.trim(line)
  
  if trimmed_line == "" then
    -- 空行：执行 Vim 内置自动缩进
    return vim.api.nvim_replace_termcodes('<C-t>', true, true, true)
  else
    -- 非空行：插入2个空格（匹配全局缩进配置）
    return string.rep(' ', vim.o.shiftwidth)
  end
end, vim.tbl_extend("force", expr_opts, { desc = "插入模式：Tab 智能缩进" }))

-- ======================== 2.1. 插入模式全选功能 ==============================
-- 插入模式：Ctrl + A 全选当前文件内容
vim.keymap.set("i", "<C-a>", function()
  -- 进入普通模式，全选文件内容，然后回到插入模式
  return vim.api.nvim_replace_termcodes('<Esc>ggVG', true, true, true)
end, vim.tbl_extend("force", expr_opts, { desc = "插入模式：全选文件内容" }))

-- ======================== 2.2. 单词级文本选择 ==============================
-- Ctrl + Shift + Left/Right：像常见编辑器一样按单词扩展选择
vim.keymap.set("x", "<C-S-Left>", "b", vim.tbl_extend("force", map_opts, {
  desc = "按单词向左扩展选择",
}))

vim.keymap.set("x", "<C-S-Right>", "e", vim.tbl_extend("force", map_opts, {
  desc = "按单词向右扩展选择",
}))

-- 从 Shift+方向键进入的是 select 模式，先切到 visual 再做单词扩展，避免被 keymodel 停止选择
vim.keymap.set("s", "<C-S-Left>", "<C-g>b", vim.tbl_extend("force", map_opts, {
  desc = "按单词向左扩展选择",
}))

vim.keymap.set("s", "<C-S-Right>", "<C-g>e", vim.tbl_extend("force", map_opts, {
  desc = "按单词向右扩展选择",
}))

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
      "& '.\\%s'; Write-Host ''; Write-Host '按回车键退出...'; [void][System.Console]::ReadLine(); exit",
      pwsh_escape_single_quotes(exe_name)
    )
    open_pwsh_command(run_cmd)
  else
    print("编译失败：")
    print(output)
  end
end, vim.tbl_extend("force", map_opts, { desc = "ACM：编译并运行 C++ 文件" }))

-- F6：直接运行已编译的 exe 文件
vim.keymap.set(acm_mode, "<F6>", function()
  vim.cmd("w")

  local file_path = vim.fn.expand("%:p")
  if file_path == "" or vim.fn.expand("%:e") ~= "cpp" then
    vim.notify("F6 仅支持当前 C++ 文件", vim.log.levels.WARN)
    return
  end

  open_input_picker(function(input_file)
    local ok, exe_path, output = compile_cpp_file(file_path)
    if not ok then
      vim.notify("编译失败，请查看消息输出", vim.log.levels.ERROR)
      print("编译失败：")
      print(output)
      return
    end

    local run_cmd = string.format(
      "%s; cmd /c '\"%s\" < \"%s\"'; Write-Host ''; Write-Host '按回车键退出...'; [void][System.Console]::ReadLine(); exit",
      pwsh_cd_command(vim.fn.fnamemodify(file_path, ":h")),
      exe_path,
      input_file
    )
    open_pwsh_command(run_cmd)
  end)
end, vim.tbl_extend("force", map_opts, { desc = "ACM：选择输入样例后编译运行 C++ 程序" }))

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
-- F1：在终端缓冲区中打开 Yazi（兼容 Neovide）
vim.keymap.set("n", "<F1>", function()
  if vim.fn.executable("yazi") ~= 1 then
    vim.notify("未找到 yazi 可执行文件", vim.log.levels.WARN)
    return
  end

  local target_dir = current_buffer_dir()

  vim.cmd("botright split")
  vim.cmd("resize 18")
  vim.cmd("terminal")
  vim.fn.chansend(vim.b.terminal_job_id, { "cd /d " .. target_dir .. "\r", "yazi\r" })
  vim.cmd("startinsert")
end, vim.tbl_extend("force", map_opts, { desc = "打开 Yazi 文件管理器" }))

-- F2：切换 NvimTree 文件管理器
vim.keymap.set('n', '<F2>', ':NvimTreeToggle<CR>', vim.tbl_extend("force", map_opts, { desc = "切换 NvimTree 显示/隐藏" }))
vim.keymap.set('i', '<F2>', '<Esc>:NvimTreeToggle<CR>a', vim.tbl_extend("force", map_opts, { desc = "切换 NvimTree（插入模式）" }))

-- ======================== 7. 会话管理快捷键 ================================
-- Leader + s：保存会话
vim.keymap.set("n", "<leader>ss", "<cmd>SessionSave<CR>", vim.tbl_extend("force", map_opts, { desc = "保存当前会话" }))
-- Leader + r：恢复会话
vim.keymap.set("n", "<leader>sr", "<cmd>SessionRestore<CR>", vim.tbl_extend("force", map_opts, { desc = "恢复会话" }))
-- Leader + d：删除会话
vim.keymap.set("n", "<leader>sd", "<cmd>SessionDelete<CR>", vim.tbl_extend("force", map_opts, { desc = "删除会话" }))
-- Leader + p：项目切换
vim.keymap.set("n", "<leader>sp", "<cmd>Telescope projects<CR>", vim.tbl_extend("force", map_opts, { desc = "切换项目" }))

-- ======================== 8. 界面控制快捷键 ================================
-- Leader + t：切换标签栏显示/隐藏
vim.keymap.set("n", "<leader>tt", function()
  if vim.opt.showtabline:get() == 0 then
    vim.opt.showtabline = 2
    print("标签栏已显示")
  else
    vim.opt.showtabline = 0
    print("标签栏已隐藏")
  end
end, vim.tbl_extend("force", map_opts, { desc = "切换标签栏显示/隐藏" }))

-- Leader + b：切换状态栏显示/隐藏
vim.keymap.set("n", "<leader>bb", function()
  if vim.opt.laststatus:get() == 0 then
    vim.opt.laststatus = 3
    print("状态栏已显示")
  else
    vim.opt.laststatus = 0
    print("状态栏已隐藏")
  end
end, vim.tbl_extend("force", map_opts, { desc = "切换状态栏显示/隐藏" }))

-- Leader + l：切换行号显示/隐藏
vim.keymap.set("n", "<leader>ll", function()
  if vim.opt.number:get() then
    vim.opt.number = false
    vim.opt.relativenumber = false
    print("行号已隐藏")
  else
    vim.opt.number = true
    vim.opt.relativenumber = true
    print("行号已显示")
  end
end, vim.tbl_extend("force", map_opts, { desc = "切换行号显示/隐藏" }))

-- Leader + c：专注模式（隐藏所有界面元素）
vim.keymap.set("n", "<leader>cc", function()
  vim.opt.showtabline = 0
  vim.opt.laststatus = 0
  vim.opt.number = false
  vim.opt.relativenumber = false
  vim.opt.signcolumn = "no"
  vim.opt.cursorline = false
  print("专注模式已启用")
end, vim.tbl_extend("force", map_opts, { desc = "专注模式（隐藏所有界面元素）" }))

-- Leader + n：正常模式（恢复所有界面元素）
vim.keymap.set("n", "<leader>nn", function()
  vim.opt.showtabline = 2
  vim.opt.laststatus = 3
  vim.opt.number = true
  vim.opt.relativenumber = true
  vim.opt.signcolumn = "yes"
  vim.opt.cursorline = true
  print("正常模式已恢复")
end, vim.tbl_extend("force", map_opts, { desc = "正常模式（恢复所有界面元素）" }))

-- ======================== 8.1. 标签页导航快捷键 ==============================
-- Alt + 数字键：快速切换到指定标签页
for i = 1, 9 do
  vim.keymap.set("n", "<M-" .. i .. ">", function()
    vim.cmd("tabnext " .. i)
  end, vim.tbl_extend("force", map_opts, { desc = "切换到标签页 " .. i }))
end

-- Alt + 0：切换到最后一个标签页
vim.keymap.set("n", "<M-0>", function()
  vim.cmd("tablast")
end, vim.tbl_extend("force", map_opts, { desc = "切换到最后一个标签页" }))

-- Ctrl + Tab：切换到下一个标签页
vim.keymap.set("n", "<C-Tab>", function()
  vim.cmd("tabnext")
end, vim.tbl_extend("force", map_opts, { desc = "切换到下一个标签页" }))

-- Ctrl + Shift + Tab：切换到上一个标签页
vim.keymap.set("n", "<C-S-Tab>", function()
  vim.cmd("tabprevious")
end, vim.tbl_extend("force", map_opts, { desc = "切换到上一个标签页" }))

-- Alt + q：关闭当前标签页
vim.keymap.set("n", "<M-q>", function()
  vim.cmd("tabclose")
end, vim.tbl_extend("force", map_opts, { desc = "关闭当前标签页" }))

-- ======================== 9. 鼠标窗口控制快捷键 ==============================
-- 鼠标右键点击窗口边缘可以调整大小（已通过 mousemodel="extend" 启用）

-- Leader + w：窗口操作菜单
vim.keymap.set("n", "<leader>ww", function()
  local choice = vim.fn.inputlist({
    "窗口操作:",
    "1. 水平分割<leader> + s",
    "2. 垂直分割<leader> + v", 
    "3. 关闭当前窗口<leader> + c",
    "4. 仅保留当前窗口<leader> + o",
    "5. 切换窗口<leader> + w",
    "6. 窗口均等<leader> + =",
    "7. 最大化/还原当前窗格<leader> + z",
    "8. 底部终端窗格<leader> + t"
  })
  
  if choice == 1 then vim.cmd("split") end
  if choice == 2 then vim.cmd("vsplit") end
  if choice == 3 then vim.cmd("close") end
  if choice == 4 then vim.cmd("only") end
  if choice == 5 then vim.cmd("wincmd w") end
  if choice == 6 then vim.cmd("wincmd =") end
  if choice == 7 then require("modules.panes").toggle_zoom() end
  if choice == 8 then require("modules.panes").open_terminal_bottom() end
end, vim.tbl_extend("force", map_opts, { desc = "窗口操作菜单" }))

-- 鼠标中键关闭窗口
vim.keymap.set("n", "<MiddleMouse>", "<C-w>c", vim.tbl_extend("force", map_opts, { desc = "鼠标中键关闭窗口" }))

-- Ctrl + 鼠标滚轮调整窗口大小
vim.keymap.set("n", "<C-MouseUp>", "<C-w>+", vim.tbl_extend("force", map_opts, { desc = "Ctrl+滚轮向上：增加窗口高度" }))
vim.keymap.set("n", "<C-MouseDown>", "<C-w>-", vim.tbl_extend("force", map_opts, { desc = "Ctrl+滚轮向下：减少窗口高度" }))
vim.keymap.set("n", "<C-S-MouseUp>", "<C-w>", vim.tbl_extend("force", map_opts, { desc = "Ctrl+Shift+滚轮向上：增加窗口宽度" }))
vim.keymap.set("n", "<C-S-MouseDown>", "<C-w><", vim.tbl_extend("force", map_opts, { desc = "Ctrl+Shift+滚轮向下：减少窗口宽度" }))

-- ======================== 10. 文件创建快捷键 ==============================
-- Ctrl + n：在当前文件夹创建新的未命名 C++ 文件（新标签页）
vim.keymap.set("n", "<C-n>", function()
  -- 获取当前文件的目录
  local current_file = vim.fn.expand("%:p")
  local current_dir = vim.fn.fnamemodify(current_file, ":h")
  
  -- 如果没有当前文件，使用当前工作目录
  if current_dir == "." then
    current_dir = vim.fn.getcwd()
  end
  
  -- 生成新的未命名文件名（基于时间戳避免冲突）
  local timestamp = os.date("%Y%m%d_%H%M%S")
  local new_filename = string.format("untitled_%s.cpp", timestamp)
  local new_filepath = vim.fn.join({current_dir, new_filename}, "\\")
  
  -- 在新标签页中创建文件
  vim.cmd("tabnew")
  vim.cmd("edit " .. new_filepath)
  
  -- 插入 ACM 模板（如果可用）
  pcall(function()
    local acm = require("modules.acm")
    acm.insert_template()
  end)
  
  print(string.format("已创建新 C++ 文件: %s", new_filename))
end, vim.tbl_extend("force", map_opts, { desc = "创建新的未命名 C++ 文件（新标签页）" }))

-- Ctrl + Shift + n：在当前文件夹创建新的未命名文件（当前标签页）
vim.keymap.set("n", "<C-S-n>", function()
  -- 获取当前文件的目录
  local current_file = vim.fn.expand("%:p")
  local current_dir = vim.fn.fnamemodify(current_file, ":h")
  
  -- 如果没有当前文件，使用当前工作目录
  if current_dir == "." then
    current_dir = vim.fn.getcwd()
  end
  
  -- 生成新的未命名文件名
  local timestamp = os.date("%Y%m%d_%H%M%S")
  local new_filename = string.format("untitled_%s.cpp", timestamp)
  local new_filepath = vim.fn.join({current_dir, new_filename}, "\\")
  
  -- 在当前窗口中创建文件
  vim.cmd("edit " .. new_filepath)
  
  -- 插入 ACM 模板（如果可用）
  pcall(function()
    local acm = require("modules.acm")
    acm.insert_template()
  end)
  
  print(string.format("已创建新 C++ 文件: %s", new_filename))
end, vim.tbl_extend("force", map_opts, { desc = "创建新的未命名 C++ 文件（当前标签页）" }))

-- ======================== 10.1. 插入模式文本移动快捷键 ==========================
-- Shift + Ctrl + 上下方向键：在插入模式下移动选中的文本行
vim.keymap.set("i", "<C-S-Up>", function()
  -- 检查是否有选中的文本
  local mode = vim.api.nvim_get_mode().mode
  if mode:find('v') or mode:find('V') or mode:find('s') or mode:find('S') then
    -- 有选中内容：移动选中的文本向上
    return vim.api.nvim_replace_termcodes('<Esc>:move .-2<CR>==gi', true, true, true)
  else
    -- 没有选中内容：移动当前行向上
    return vim.api.nvim_replace_termcodes('<Esc>:move .-2<CR>==i', true, true, true)
  end
end, vim.tbl_extend("force", expr_opts, { desc = "插入模式：向上移动选中文本/当前行" }))

vim.keymap.set("i", "<C-S-Down>", function()
  -- 检查是否有选中的文本
  local mode = vim.api.nvim_get_mode().mode
  if mode:find('v') or mode:find('V') or mode:find('s') or mode:find('S') then
    -- 有选中内容：移动选中的文本向下
    return vim.api.nvim_replace_termcodes('<Esc>:move .+1<CR>==gi', true, true, true)
  else
    -- 没有选中内容：移动当前行向下
    return vim.api.nvim_replace_termcodes('<Esc>:move .+1<CR>==i', true, true, true)
  end
end, vim.tbl_extend("force", expr_opts, { desc = "插入模式：向下移动选中文本/当前行" }))

-- 可视模式也支持相同的快捷键（保持一致性）
vim.keymap.set("x", "<C-S-Up>", ":move '<-2<CR>gv=gv", vim.tbl_extend("force", map_opts, { desc = "可视模式：向上移动选中文本" }))
vim.keymap.set("x", "<C-S-Down>", ":move '>+1<CR>gv=gv", vim.tbl_extend("force", map_opts, { desc = "可视模式：向下移动选中文本" }))

-- Select 模式下也走同样的选区边界逻辑
vim.keymap.set("s", "<C-S-Up>", "<C-g>:move '<-2<CR>gv=gv", vim.tbl_extend("force", map_opts, { desc = "选择模式：向上移动选中文本" }))
vim.keymap.set("s", "<C-S-Down>", "<C-g>:move '>+1<CR>gv=gv", vim.tbl_extend("force", map_opts, { desc = "选择模式：向下移动选中文本" }))

-- 普通模式也支持（单行移动）
vim.keymap.set("n", "<C-S-Up>", ":move .-2<CR>==", vim.tbl_extend("force", map_opts, { desc = "普通模式：向上移动当前行" }))
vim.keymap.set("n", "<C-S-Down>", ":move .+1<CR>==", vim.tbl_extend("force", map_opts, { desc = "普通模式：向下移动当前行" }))

-- ======================== 10.2. 文件重命名快捷键 ==============================
-- Leader + r：重命名当前文件
vim.keymap.set("n", "<leader>rn", function()
  local old_name = vim.fn.expand("%:t")
  local old_path = vim.fn.expand("%:p")
  local new_name = vim.fn.input("新文件名: ", old_name)
  
  if new_name ~= "" and new_name ~= old_name then
    local new_path = vim.fn.expand("%:h") .. "\\" .. new_name
    
    -- 保存当前文件
    vim.cmd("w")
    
    -- 使用 :saveas 创建新文件
    vim.cmd("saveas " .. new_path)
    
    -- 删除旧文件（Windows）
    if vim.fn.has("win32") == 1 then
      vim.fn.system("del \"" .. old_path .. "\"")
    else
      vim.fn.system("rm \"" .. old_path .. "\"")
    end
    
    print(string.format("文件已重命名: %s -> %s", old_name, new_name))
  end
end, vim.tbl_extend("force", map_opts, { desc = "重命名当前文件" }))

-- Leader + m：移动文件到其他目录
vim.keymap.set("n", "<leader>mv", function()
  local old_name = vim.fn.expand("%:t")
  local old_path = vim.fn.expand("%:p")
  local current_dir = vim.fn.expand("%:h")
  
  -- 获取目标目录
  local target_dir = vim.fn.input("目标目录: ", current_dir)
  
  if target_dir ~= "" and target_dir ~= current_dir then
    local new_path = target_dir .. "\\" .. old_name
    
    -- 保存当前文件
    vim.cmd("w")
    
    -- 使用 :saveas 创建新文件
    vim.cmd("saveas " .. new_path)
    
    -- 删除旧文件
    if vim.fn.has("win32") == 1 then
      vim.fn.system("del \"" .. old_path .. "\"")
    else
      vim.fn.system("rm \"" .. old_path .. "\"")
    end
    
    print(string.format("文件已移动: %s -> %s", old_path, new_path))
  end
end, vim.tbl_extend("force", map_opts, { desc = "移动文件到其他目录" }))

-- ===========================================================================
-- 配置结束
-- ===========================================================================

-- ======================== 11. 自定义命令行为 ==============================
-- 重写 :new 命令，让它在新标签页中打开文件而不是分屏
-- 使用 autocmd 在 VimEnter 事件后重定义命令
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.cmd([[
      " 定义一个以大写字母开头的用户命令 New
      command! -nargs=? -complete=file New call s:NewInTab(<q-args>)
      function! s:NewInTab(args)
        if a:args != ''
          execute 'tabnew ' . a:args
        else
          tabnew
        endif
      endfunction
      
      " 使用 cabbrev 创建 :new 的缩写，指向我们的 New 命令
      cabbrev new New
      cnoreabbrev <expr> q getcmdtype() == ':' && getcmdline() == 'q' ? 'CloseCurrentEntry' : 'q'
      cnoreabbrev <expr> q! getcmdtype() == ':' && getcmdline() == 'q!' ? 'CloseCurrentEntry!' : 'q!'
    ]])
  end,
})

