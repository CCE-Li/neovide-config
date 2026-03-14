-- 会话管理和状态恢复
return {
  -- 项目管理
  {
    "ahmedkhalf/project.nvim",
    config = function()
      require("project_nvim").setup({
        manual_mode = false,
        detection_methods = { "lsp", "pattern" },
        patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json" },
        ignore_lsp = {},
        exclude_dirs = {},
        show_hidden = false,
        silent_chdir = true,
        scope_chdir = {
          pre = "tab",
          post = "tab",
        },
        datapath = vim.fn.stdpath("data") .. "/project_nvim",
      })
    end,
    dependencies = { "nvim-telescope/telescope.nvim" },
  },

  -- 启动界面
  {
    "goolord/alpha-nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")
      
      -- 设置启动界面
      dashboard.section.header.val = {
        "██████╗ ██████╗ ██╗███╗   ██╗    ██████╗ ██╗   ██╗███████╗████████╗",
        "██╔══██╗██╔══██╗██║████╗  ██║    ██╔══██╗██║   ██║██╔════╝╚══██╔══╝",
        "██████╔╝██████╔╝██║██╔██╗ ██║    ██████╔╝██║   ██║█████╗     ██║   ",
        "██╔══██╗██╔══██╗██║██║╚██╗██║    ██╔══██╗██║   ██║██╔══╝     ██║   ",
        "██║  ██║██████╔╝██║██║ ╚████║    ██║  ██║╚██████╔╝███████╗   ██║   ",
        "╚═╝  ╚═╝╚═════╝ ╚═╝╚═╝  ╚═══╝    ╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝   ",
      }
      
      dashboard.section.buttons.val = {
        dashboard.button("f", "📁 打开文件夹", ":NvimTreeToggle<CR>"),
        dashboard.button("n", "📝 新建文件", ":ene <BAR>startinsert<CR>"),
        dashboard.button("q", "🚪 退出", ":qa<CR>"),
      }
      
      alpha.setup(dashboard.config)
    end,
  },
}
