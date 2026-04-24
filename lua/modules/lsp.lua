local uv = vim.uv or vim.loop

if vim.fn.exists(":LspInfo") == 0 then
  vim.api.nvim_create_user_command("LspInfo", function()
    local bufnr = vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_clients({ bufnr = bufnr })

    if #clients == 0 then
      vim.notify("当前 buffer 没有附着任何 LSP", vim.log.levels.WARN)
      return
    end

    local lines = { "当前 buffer 的 LSP:" }
    for _, client in ipairs(clients) do
      table.insert(lines, string.format("- %s (id=%d)", client.name, client.id))
    end

    vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "LSP Info" })
  end, {
    desc = "显示当前 buffer 的 LSP 客户端信息",
  })
end

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

local function detect_python()
  return existing_path({
    "C:/Users/Lenovo/AppData/Local/Programs/Python/Python39/python.exe",
    "C:/Python312/python.exe",
    "C:/Python313/python.exe",
    "C:/Python311/python.exe",
    "C:/Python/python.exe",
    vim.fn.exepath("python"),
    vim.fn.exepath("python3"),
    "C:/msys64/mingw64/bin/python.exe",
  })
end

local function detect_cargo()
  return existing_path({
    vim.fn.exepath("cargo"),
    "C:/Users/Lenovo/.cargo/bin/cargo.exe",
  })
end

local function detect_rust_analyzer()
  local candidates = {
    vim.fn.stdpath("data") .. "/mason/packages/rust-analyzer/rust-analyzer.exe",
    vim.fn.stdpath("data") .. "/mason/bin/rust-analyzer.cmd",
  }

  local exepath = vim.fn.exepath("rust-analyzer")
  local lower_exepath = exepath:lower()
  local is_rustup_proxy = lower_exepath:find("\\.cargo\\bin\\rust%-analyzer%.exe$") ~= nil
    or lower_exepath:find("/%.cargo/bin/rust%-analyzer%.exe$") ~= nil

  if exepath ~= "" and not is_rustup_proxy then
    table.insert(candidates, exepath)
  end

  return existing_path(candidates)
end

local function detect_gpp()
  return existing_path({
    vim.fn.exepath("g++"),
    "C:/msys64/mingw64/bin/g++.exe",
    "C:/msys64/clang64/bin/g++.exe",
  })
end

local function safe_system_wait(cmd, opts)
  local ok, system_obj = pcall(vim.system, cmd, opts or {})
  if not ok or not system_obj then
    return nil
  end

  local wait_ok, result = pcall(system_obj.wait, system_obj)
  if not wait_ok then
    return nil
  end

  return result
end

local function detect_gpp_target(gpp_path)
  if gpp_path == "" then
    return ""
  end

  local result = safe_system_wait({ gpp_path, "-dumpmachine" }, {
    text = true,
  })

  if not result or result.code ~= 0 or not result.stdout then
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

  local result = safe_system_wait({ gpp_path, "-E", "-x", "c++", "-", "-v" }, {
    text = true,
    stdin = "",
  })

  if not result or result.code ~= 0 or not result.stderr then
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

local function detect_project_root(start_path, markers)
  local path = start_path
  if type(path) == "number" then
    path = vim.api.nvim_buf_get_name(path)
  end

  if type(path) ~= "string" then
    path = ""
  end

  if path == "" then
    return vim.fn.getcwd()
  end

  local stat = uv.fs_stat(path)
  local start_dir = path

  if stat and stat.type == "file" then
    start_dir = vim.fs.dirname(path) or path
  end

  local matches = vim.fs.find(markers, {
    path = start_dir,
    upward = true,
  })

  if matches[1] then
    return vim.fs.dirname(matches[1])
  end

  return start_dir
end

local function find_project_file(start_path)
  local path = start_path
  if type(path) == "number" then
    path = vim.api.nvim_buf_get_name(path)
  end

  if type(path) ~= "string" or path == "" then
    return nil
  end

  local stat = uv.fs_stat(path)
  local start_dir = stat and stat.type == "file" and (vim.fs.dirname(path) or path) or path
  local matches = vim.fs.find({ "Cargo.toml", "rust-project.json" }, {
    path = start_dir,
    upward = true,
  })

  return matches[1]
end

local clangd_path = detect_clangd()
local gpp_path = detect_gpp()
local python_path = detect_python()
local cargo_path = detect_cargo()
local rust_analyzer_path = detect_rust_analyzer()

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

local python_servers = {
  pyright = {
    settings = {
      python = {
        analysis = {
          autoImportCompletions = true,
          autoSearchPaths = true,
          diagnosticMode = "workspace",
          typeCheckingMode = "basic",
          useLibraryCodeForTypes = true,
        },
      },
    },
  },
  ruff = {},
}

if python_path ~= "" then
  python_servers.pyright.settings.python.pythonPath = python_path
end

local rust_analyzer_config = {
  capabilities = capabilities,
  filetypes = { "rust" },
  root_markers = { "Cargo.toml", "rust-project.json", ".git" },
  root_dir = function(fname)
    return detect_project_root(fname, { "Cargo.toml", "rust-project.json", ".git" })
  end,
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        allFeatures = true,
      },
      checkOnSave = true,
      check = {
        command = "clippy",
      },
      procMacro = {
        enable = true,
      },
    },
  },
}

if cargo_path ~= "" then
  rust_analyzer_config.cmd_env = {
    PATH = vim.env.PATH,
    CARGO = cargo_path,
  }
end

if rust_analyzer_path ~= "" then
  rust_analyzer_config.cmd = { rust_analyzer_path }
else
  vim.notify("未找到 rust-analyzer，可执行 Rust 补全将不可用", vim.log.levels.WARN)
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "rust",
  callback = function(args)
    if rust_analyzer_path == "" then
      return
    end

    local existing_clients = vim.lsp.get_clients({
      bufnr = args.buf,
      name = "rust_analyzer",
    })

    if #existing_clients > 0 then
      return
    end

    local bufname = vim.api.nvim_buf_get_name(args.buf)
    local root_dir = detect_project_root(args.buf, { "Cargo.toml", "rust-project.json", ".git" })
    local project_file = find_project_file(args.buf)

    local start_config = vim.tbl_deep_extend("force", rust_analyzer_config, {
      name = "rust_analyzer",
      root_dir = root_dir,
      workspace_folders = {
        {
          uri = vim.uri_from_fname(root_dir),
          name = vim.fs.basename(root_dir),
        },
      },
    })

    if bufname == "" then
      return
    end

    if not project_file then
      start_config.settings = vim.tbl_deep_extend("force", start_config.settings or {}, {
        ["rust-analyzer"] = {
          detachedFiles = { bufname },
        },
      })
    end

    local client_id = vim.lsp.start(start_config, {
      bufnr = args.buf,
    })

    if not client_id then
      vim.notify("rust_analyzer 启动失败", vim.log.levels.WARN)
    end
  end,
  desc = "启动 rust_analyzer",
})

if vim.lsp.config and vim.lsp.enable then
  vim.lsp.config("rust_analyzer", rust_analyzer_config)
  vim.lsp.enable("rust_analyzer")
else
  local ok, lspconfig = pcall(require, "lspconfig")
  if ok and lspconfig.rust_analyzer then
    lspconfig.rust_analyzer.setup(rust_analyzer_config)
  end
end

for server, config in pairs(python_servers) do
  config.capabilities = capabilities

  if vim.lsp.config and vim.lsp.enable then
    vim.lsp.config(server, config)
    vim.lsp.enable(server)
  else
    local ok, lspconfig = pcall(require, "lspconfig")
    if ok and lspconfig[server] then
      lspconfig[server].setup(config)
    end
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
