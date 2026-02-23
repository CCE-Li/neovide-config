-- 会话管理和状态恢复
return {
  -- 自动保存和恢复会话
  {
    "rmagatti/auto-session",
    lazy = false,
    opts = {
      auto_restore = true,           -- 自动恢复会话
      auto_save = true,              -- 自动保存会话
      session_lens = {
        load_on_setup = true,        -- 启动时显示会话列表
      },
      log_level = "error",
      auto_session_last_session_dir = vim.fn.stdpath("data") .. "/sessions/",
      auto_session_enabled = true,
      auto_session_create_enabled = true,
      auto_session_suppress_dirs = { -- 不保存会话的目录
        "~/",
        "~/Downloads",
        "/",
      },
    }
  },

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
        dashboard.button("r", "🔄 恢复上次会话", ":SessionRestore<CR>"),
        dashboard.button("f", "📁 查找文件", ":Telescope find_files<CR>"),
        dashboard.button("p", "📂 切换项目", ":Telescope projects<CR>"),
        dashboard.button("n", "📝 新建文件", ":ene <BAR>startinsert<CR>"),
        dashboard.button("q", "🚪 退出", ":qa<CR>"),
      }
      
      alpha.setup(dashboard.config)
    end,
  },
}
