-- 代码注释
return {
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
      -- 快捷键：gcc 注释当前行，gc 选中块注释
    end,
  },
}
