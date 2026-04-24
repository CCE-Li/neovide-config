-- LSP 配置
return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
  },
  -- LSP 管理器
  {
    "mason-org/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      ensure_installed = {
        "lua_ls",
        "clangd",
        "pyright",
        "ruff",
        "ts_ls",
        "rust_analyzer",
        "tailwindcss",
      }
    },
    dependencies = {
      {
        "mason-org/mason.nvim",
        opts = {
          ui = {
            icons = {
              package_installed = "✓",
              package_pending = "➜",
              package_uninstalled = "✗"
            }
          }
        }
      },
      {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        opts = {
          ensure_installed = {
            "clang-format",
            "clangd",
            "cpptools",
            "black",
            "isort",
            "ruff"
          },
          auto_update = true,
          run_on_start = true,
        }
      },
      {
        "neovim/nvim-lspconfig",
      },
    },
  },
}
