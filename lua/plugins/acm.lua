-- ACM 竞赛工具
return {
  -- CompetiTest 测试用例管理
  {
    "xeluxee/competitest.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    config = function()
      require("competitest").setup({
        runner_ui = {
          interface = "split",
          watch = true,         -- 核心配置：默认开启监听
          watch_interval = 1000 -- 监听间隔（毫秒），可选，默认1000
        },
        split_ui = {
          position = "right",
          total_width = 0.45,
        },
        testcases_directory = "./test",
        testcases_use_single_file = true,
        testcases_auto_detect = true,
        -- 编译命令：使用 $(FNAME) 格式
        compile_command = {
          cpp = { exec = "g++", args = {"-std=c++17", "-O2", "$(FNAME)", "-o", "$(FNAME).out"} }
        },
        -- 运行命令：使用 $(FNAME) 格式
        run_command = {
          cpp = { exec = "./$(FNAME).out", args = {} }
        },
        split_window = {
          direction = "vertical",
          size = 0.5,
        }
      })
    end
  },
}
