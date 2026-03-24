-- ===========================================================================
-- Clang-format configuration
-- ===========================================================================

local clang_format = vim.fn.exepath("clang-format")

if clang_format ~= "" then
  vim.g.clang_format_path = clang_format
end

local format_args = {
  "-i",
  '--style={IndentWidth: 4, TabWidth: 4, UseTab: Never}',
}

local function format_current_file()
  if clang_format == "" then
    vim.notify("clang-format not found in PATH", vim.log.levels.WARN)
    return
  end

  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    return
  end

  local result = vim.system(vim.list_extend({ clang_format }, vim.list_extend(vim.deepcopy(format_args), { file })), {
    text = true,
  }):wait()

  if result.code ~= 0 then
    local message = result.stderr ~= "" and result.stderr or "clang-format failed"
    vim.notify(message, vim.log.levels.ERROR)
  end
end

vim.keymap.set("n", "<leader>f", format_current_file, {
  desc = "Format current file with clang-format",
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.cpp", "*.c", "*.h", "*.hpp" },
  callback = format_current_file,
  desc = "Format C/C++ files with clang-format before saving",
})
