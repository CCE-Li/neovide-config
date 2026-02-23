if vim.g.neovide then
  -- 基础设置
  vim.g.neovide_cursor_vfx_mode = "railgun"
  vim.g.neovide_opacity = 0.95
  vim.opt.guifont = "Consolas:h14"

  -- F11：切换全屏（无边框效果）
  vim.keymap.set("n", "<F11>", function()
    vim.cmd("call neovide#fullscreen#toggle()")
  end, { desc = "切换全屏模式" })

  -- 自动聚焦窗口
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      vim.schedule(function()
        vim.fn.system([[
          powershell -Command "(New-Object -ComObject WScript.Shell).SendKeys('+')"
        ]])
      end)
    end,
  })
end
