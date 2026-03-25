local uv = vim.uv or vim.loop

local function existing_path(paths)
  for _, path in ipairs(paths) do
    if path ~= "" and uv.fs_stat(path) then
      return path
    end
  end
  return ""
end

local function detect_clangd()
  return existing_path({
    vim.fn.exepath("clangd"),
    vim.fn.stdpath("data") .. "/mason/bin/clangd.cmd",
    "C:/msys64/clang64/bin/clangd.exe",
  })
end

local function detect_gpp()
  return existing_path({
    vim.fn.exepath("g++"),
    "C:/msys64/mingw64/bin/g++.exe",
    "C:/msys64/clang64/bin/g++.exe",
  })
end

local function detect_gpp_target(gpp_path)
  if gpp_path == "" then
    return ""
  end

  local result = vim.system({ gpp_path, "-dumpmachine" }, {
    text = true,
  }):wait()

  if result.code ~= 0 or not result.stdout then
    return ""
  end

  return vim.trim(result.stdout)
end

local function detect_gcc_toolchain(gpp_path)
  if gpp_path == "" then
    return ""
  end

  local bin_dir = vim.fs.dirname(gpp_path)
  if not bin_dir then
    return ""
  end

  local toolchain_dir = vim.fs.dirname(bin_dir)
  if toolchain_dir and uv.fs_stat(toolchain_dir) then
    return toolchain_dir
  end

  return ""
end

local function detect_include_dirs(gpp_path)
  if gpp_path == "" then
    return {}
  end

  local result = vim.system({ gpp_path, "-E", "-x", "c++", "-", "-v" }, {
    text = true,
    stdin = "",
  }):wait()

  if result.code ~= 0 or not result.stderr then
    return {}
  end

  local include_dirs = {}
  local in_block = false

  for line in result.stderr:gmatch("[^\r\n]+") do
    if line:find("#include <%.%.%.> search starts here:") then
      in_block = true
    elseif in_block and line:find("End of search list%.") then
      break
    elseif in_block then
      local dir = vim.trim(line)
      if dir ~= "" and uv.fs_stat(dir) then
        table.insert(include_dirs, dir)
      end
    end
  end

  return include_dirs
end

local function build_fallback_flags(gpp_path)
  local flags = { "-std=c++17" }
  local target = detect_gpp_target(gpp_path)
  local toolchain = detect_gcc_toolchain(gpp_path)

  if target ~= "" then
    table.insert(flags, "--target=" .. target)
  end

  if toolchain ~= "" then
    table.insert(flags, "--gcc-toolchain=" .. toolchain)
  end

  for _, dir in ipairs(detect_include_dirs(gpp_path)) do
    table.insert(flags, "-isystem")
    table.insert(flags, dir)
  end

  return flags
end

local clangd_path = detect_clangd()
local gpp_path = detect_gpp()

local clangd_config = {
  init_options = {
    fallbackFlags = build_fallback_flags(gpp_path),
  },
}

if clangd_path ~= "" then
  local query_drivers = {
    "C:/msys64/**/g++.exe",
    "C:/msys64/**/clang++.exe",
  }

  if gpp_path ~= "" then
    table.insert(query_drivers, 1, gpp_path)
  end

  clangd_config.cmd = {
    clangd_path,
    "--background-index",
    "--clang-tidy",
    "--header-insertion=never",
    "--query-driver=" .. table.concat(query_drivers, ","),
  }
else
  vim.notify("未找到 clangd，可执行 LSP 补全将不可用", vim.log.levels.WARN)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
local blink_ok, blink = pcall(require, "blink.cmp")
if blink_ok and blink.get_lsp_capabilities then
  capabilities = blink.get_lsp_capabilities(capabilities)
end

clangd_config.capabilities = capabilities

if vim.lsp.config and vim.lsp.enable then
  vim.lsp.config("clangd", clangd_config)
  vim.lsp.enable("clangd")
else
  local ok, lspconfig = pcall(require, "lspconfig")
  if ok then
    lspconfig.clangd.setup(clangd_config)
  end
end

vim.o.updatetime = 300 -- 将鼠标悬停时间控制在0.3s

vim.diagnostic.config({
  update_in_insert = false,
  severity_sort = true,
  virtual_text = {
    spacing = 2,
    source = "if_many",
  },
  float = {
    border = "rounded",
    source = "always",
    focus = false,
  },
})

local diagnostic_group = vim.api.nvim_create_augroup("LspDiagnosticUX", { clear = true })
local entered_at = {}

vim.api.nvim_create_autocmd({ "BufEnter", "BufNewFile", "BufReadPost" }, {
  group = diagnostic_group,
  callback = function(args)
    entered_at[args.buf] = (vim.uv or vim.loop).now()
  end,
})

vim.api.nvim_create_autocmd("CursorHold", {
  group = diagnostic_group,
  callback = function(args)
    local bufnr = args.buf
    local open_time = entered_at[bufnr] or 0

    if (vim.uv or vim.loop).now() - open_time < 1200 then
      return
    end

    local line_diagnostics = vim.diagnostic.get(bufnr, {
      lnum = vim.api.nvim_win_get_cursor(0)[1] - 1,
    })

    if #line_diagnostics == 0 then
      return
    end

    vim.diagnostic.open_float(nil)
  end,
})
