return {
  {
    "mrjones2014/smart-splits.nvim",
    event = "VeryLazy",
    opts = {
      ignored_filetypes = {
        "nofile",
        "quickfix",
        "prompt",
      },
      ignored_buftypes = { "nofile" },
      default_amount = 3,
      at_edge = "stop",
    },
    config = function(_, opts)
      local smart_splits = require("smart-splits")
      local panes = require("modules.panes")

      smart_splits.setup(opts)

      local function leave_special_mode_then(fn)
        return function()
          local mode = vim.api.nvim_get_mode().mode
          if mode == "t" then
            local keys = vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true)
            vim.api.nvim_feedkeys(keys, "n", false)
            vim.schedule(fn)
            return
          end

          if mode:sub(1, 1) == "i" then
            vim.cmd("stopinsert")
          end

          vim.schedule(fn)
        end
      end

      local map = function(modes, lhs, rhs, desc)
        vim.keymap.set(modes, lhs, leave_special_mode_then(rhs), {
          silent = true,
          noremap = true,
          desc = desc,
        })
      end

      map({ "n", "i", "t" }, "<A-h>", smart_splits.move_cursor_left, "窗格焦点切到左侧")
      map({ "n", "i", "t" }, "<A-j>", smart_splits.move_cursor_down, "窗格焦点切到下方")
      map({ "n", "i", "t" }, "<A-k>", smart_splits.move_cursor_up, "窗格焦点切到上方")
      map({ "n", "i", "t" }, "<A-l>", smart_splits.move_cursor_right, "窗格焦点切到右侧")

      map({ "n", "i", "t" }, "<A-H>", smart_splits.resize_left, "向左收缩/扩展窗格")
      map({ "n", "i", "t" }, "<A-J>", smart_splits.resize_down, "向下收缩/扩展窗格")
      map({ "n", "i", "t" }, "<A-K>", smart_splits.resize_up, "向上收缩/扩展窗格")
      map({ "n", "i", "t" }, "<A-L>", smart_splits.resize_right, "向右收缩/扩展窗格")

      map("n", "<leader>ws", panes.split_down, "水平分屏")
      map("n", "<leader>wv", panes.split_right, "垂直分屏")
      map("n", "<leader>wx", panes.close_current, "关闭当前窗格")
      map("n", "<leader>we", panes.equalize, "均分所有窗格")
      map("n", "<leader>wz", panes.toggle_zoom, "最大化/还原当前窗格")
      map("n", "<leader>wt", panes.open_terminal_bottom, "在底部打开终端窗格")

      map("n", "<leader>wH", smart_splits.swap_buf_left, "与左侧窗格交换缓冲区")
      map("n", "<leader>wJ", smart_splits.swap_buf_down, "与下方窗格交换缓冲区")
      map("n", "<leader>wK", smart_splits.swap_buf_up, "与上方窗格交换缓冲区")
      map("n", "<leader>wL", smart_splits.swap_buf_right, "与右侧窗格交换缓冲区")
    end,
  },
}
