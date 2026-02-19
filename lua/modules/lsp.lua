vim.lsp.config("clangd", {
  cmd = {
    "C:/msys64/mingw64/bin/clangd.exe",
    "--background-index",
    "--query-driver=C:/msys64/mingw64/bin/g++.exe",
  },
})


vim.lsp.enable("clangd")



vim.o.updatetime = 300 -- 将鼠标悬停时间控制在0.3s

-- ========== 鼠标悬停时，显示错误弹窗 =========
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.open_float(nil, {
      focus = false,
      border = "rounded",
      source = "always",
    })
  end,
})
