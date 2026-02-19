-- 新建 cpp 自动插入模板
vim.api.nvim_create_autocmd("BufNewFile", {
  pattern = "*.cpp",
  callback = function()
    require("modules.acm").insert_template()
  end,
})
