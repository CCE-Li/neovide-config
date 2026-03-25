if not vim.g.neovide then
  return
end

-- Visual defaults: use partial transparency in GUI mode.
vim.g.neovide_opacity = 0.3
vim.g.neovide_normal_opacity = 0.3
vim.g.neovide_remember_window_size = true
vim.g.neovide_scale_factor = 1.0

-- Cursor animation: subtle enough for daily editing without the heavy particle trail.
vim.g.neovide_cursor_vfx_mode = ""
vim.g.neovide_cursor_animation_length = 0.08
vim.g.neovide_cursor_trail_size = 0.2
vim.g.neovide_scroll_animation_length = 0.15
vim.g.neovide_hide_mouse_when_typing = true

-- Floating windows feel nicer in GUI mode with a bit of depth.
vim.g.neovide_floating_shadow = true
vim.g.neovide_floating_z_height = 8
vim.g.neovide_light_angle_degrees = 45
vim.g.neovide_light_radius = 5
vim.g.neovide_floating_corner_radius = 0.2
vim.g.neovide_floating_blur_amount_x = 2.0
vim.g.neovide_floating_blur_amount_y = 2.0

-- Input handling.
vim.g.neovide_input_use_logo = false
vim.g.neovide_input_macos_alt_is_meta = true
vim.g.neovide_input_ime = true

-- Prefer a single installed Nerd Font family so bold/italic variants resolve cleanly.
vim.o.guifont = "JetBrainsMono Nerd Font Mono:h14"
vim.opt.linespace = 0

local focus_window = function()
  pcall(vim.cmd, "NeovideFocus")
end

vim.keymap.set("n", "<F11>", function()
  vim.g.neovide_fullscreen = not vim.g.neovide_fullscreen
end, { desc = "切换全屏模式" })

local change_opacity = function(delta)
  local next_value = (vim.g.neovide_opacity or 1.0) + delta
  next_value = math.max(0.3, math.min(1.0, next_value))
  vim.g.neovide_opacity = next_value
  vim.g.neovide_normal_opacity = next_value
  vim.notify(string.format("Neovide 透明度: %.0f%%", next_value * 100), vim.log.levels.INFO)
end

vim.keymap.set("n", "<F12>", function()
  change_opacity(-0.05)
end, { desc = "降低 Neovide 透明度" })

vim.keymap.set("n", "<S-F12>", function()
  change_opacity(0.05)
end, { desc = "提高 Neovide 透明度" })

vim.keymap.set("n", "<leader>ff", focus_window, {
  noremap = true,
  silent = true,
  desc = "Neovide: 聚焦窗口",
})

-- Let IME follow editor mode so normal-mode commands stay predictable.
local ime_group = vim.api.nvim_create_augroup("NeovideIME", { clear = true })
vim.api.nvim_create_autocmd({ "InsertEnter", "CmdlineEnter" }, {
  group = ime_group,
  callback = function(args)
    local enabled = args.event == "InsertEnter" or vim.fn.getcmdtype():match("[/?]")
    vim.g.neovide_input_ime = not not enabled
  end,
})

vim.api.nvim_create_autocmd({ "InsertLeave", "CmdlineLeave" }, {
  group = ime_group,
  callback = function()
    vim.g.neovide_input_ime = false
  end,
})
