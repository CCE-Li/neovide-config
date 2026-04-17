-- 新建 cpp 自动插入模板
vim.api.nvim_create_autocmd("BufNewFile", {
  pattern = "*.cpp",
  callback = function()
    require("modules.acm").insert_template()
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function(args)
    local opts = {
      tabstop = 4,
      shiftwidth = 4,
      softtabstop = 4,
      expandtab = true,
    }

    for key, value in pairs(opts) do
      vim.opt_local[key] = value
    end

    vim.bo[args.buf].commentstring = "# %s"
  end,
})
