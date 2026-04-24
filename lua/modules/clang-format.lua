-- ===========================================================================
-- Clang-format configuration
-- ===========================================================================

local clang_format = vim.fn.exepath("clang-format")

if clang_format ~= "" then
  vim.g.clang_format_path = clang_format
end

local format_args = {
  '--style={IndentWidth: 2, TabWidth: 2, UseTab: Never}',
}

local function format_current_file(bufnr)
  if clang_format == "" then
    vim.notify("clang-format not found in PATH", vim.log.levels.WARN)
    return
  end

  bufnr = bufnr or 0

  local file = vim.api.nvim_buf_get_name(bufnr)
  if file == "" then
    return
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local input = table.concat(lines, "\n")

  if vim.bo[bufnr].endofline then
    input = input .. "\n"
  end

  local cmd = vim.list_extend({ clang_format }, vim.list_extend(vim.deepcopy(format_args), {
    "--assume-filename",
    file,
  }))

  local result = vim.system(cmd, {
    text = true,
    stdin = input,
  }):wait()

  if result.code ~= 0 then
    local message = result.stderr ~= "" and result.stderr or "clang-format failed"
    vim.notify(message, vim.log.levels.ERROR)
    return
  end

  local formatted_lines = vim.split(result.stdout, "\n", { plain = true })
  if formatted_lines[#formatted_lines] == "" then
    table.remove(formatted_lines, #formatted_lines)
  end

  local view = vim.fn.winsaveview()
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, formatted_lines)
  vim.fn.winrestview(view)
end

vim.keymap.set("n", "<leader>f", function()
  format_current_file(0)
end, {
  desc = "Format current file with clang-format",
})
