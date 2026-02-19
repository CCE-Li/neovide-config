-- Ctrl + 方向键移动
vim.keymap.set("n", "<C-Left>", "b", { noremap = true })
vim.keymap.set("i", "<C-Left>", "<C-o>b", { noremap = true })

vim.keymap.set("n", "<C-Right>", "w", { noremap = true })
vim.keymap.set("i", "<C-Right>", "<C-o>w", { noremap = true })

vim.keymap.set("n", "<C-Up>", "^", { noremap = true })
vim.keymap.set("i", "<C-Up>", "<C-o>^", { noremap = true })

vim.keymap.set("n", "<C-Down>", "$", { noremap = true })
vim.keymap.set("i", "<C-Down>", "<C-o>$", { noremap = true })

-- Ctrl + Backspace
vim.keymap.set("n", "<C-BS>", "db", { noremap = true })
vim.keymap.set("i", "<C-BS>", "<C-w>", { noremap = true })

-- 撤销重做
vim.keymap.set("i", "<C-z>", "<C-o>u", { noremap = true, silent = true })
vim.keymap.set("i", "<C-S-z>", "<C-o><C-r>", { noremap = true, silent = true })

vim.keymap.set("n", "<C-z>", "u", { noremap = true, silent = true })
vim.keymap.set("n", "<C-S-z>", "<C-r>", { noremap = true, silent = true })

-- ACM 快捷键
vim.keymap.set({"n", "i"}, "<F5>", function()
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
end)

vim.keymap.set({"n", "i"}, "<F6>", function()
  local exe_name = vim.fn.expand("%:r") .. ".exe"
  local run_cmd = string.format(
    "start cmd /k \"chcp 65001 && .\\%s && echo. && echo 按回车键退出... && pause > nul && exit\"",
    exe_name
  )
  vim.fn.system(run_cmd)
end)

vim.keymap.set({"n", "i"}, "<F9>", ":w<CR>:!gdb %:r.exe<CR>", { noremap = true })

-- 模板
local acm = require("modules.acm")
vim.keymap.set("n", "<leader>t", function()
  acm.insert_template()
end, { silent = true })


-- 3. 绑定 F8 键到 CompetiTest run 命令
-- 全局映射，在任意模式下按 F8 都能触发
vim.keymap.set('n', '<F8>', ':CompetiTest run<CR>', {
  noremap = true,  -- 防止递归映射
  silent = true,   -- 不显示命令行输出
  desc = "CompetiTest: Run test cases with split_ui (watch mode on)"
})

-- 可选：为插入模式也绑定 F8（按需添加）
vim.keymap.set('i', '<F8>', '<ESC>:CompetiTest run<CR>', { noremap = true, silent = true })

vim.keymap.set("n", "<leader>y", "<cmd>Yazi<cr>")

