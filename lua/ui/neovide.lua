if vim.g.neovide then
  vim.g.neovide_cursor_vfx_mode = "railgun"
  vim.g.neovide_opacity = 0.95
  vim.opt.guifont = "Consolas:h14"

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
