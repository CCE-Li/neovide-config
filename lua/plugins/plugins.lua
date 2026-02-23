return {
  -- 1. 主题（护眼，代码高亮清晰）
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme tokyonight-storm]])
    end,
  },

  -- 2. 语法高亮（C++ 精准高亮）
{
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup({
      ensure_installed = { "cpp", "c", "lua" },
      highlight = { enable = true },
      indent = { enable = true },
      incremental_selection = { enable = true },
    })
  end
},

  -- 3. C++ LSP（代码补全、语法检查）
  {
    "neovim/nvim-lspconfig",
  },


  -- 4. 代码补全（ACM 快速补全）
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",    -- LSP 补全源
      "hrsh7th/cmp-buffer",      -- 缓冲区补全
      "L3MON4D3/LuaSnip",        -- 代码片段
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        sources = cmp.config.sources({
          { name = "nvim_lsp" },  -- 优先 LSP 补全
          { name = "buffer" },    -- 缓冲区单词补全
        }),
        mapping = cmp.mapping.preset.insert({
          ["<Tab>"] = cmp.mapping.select_next_item(),  -- Tab 选下一个
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),-- Shift+Tab 选上一个
          ["<CR>"] = cmp.mapping.confirm({ select = true }), -- 回车确认
        }),
      })
    end,
  },

  -- 5. 快速注释（ACM 调试/注释代码）
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
      -- 快捷键：gcc 注释当前行，gc 选中块注释
    end,
  },
  
  -- 6.快速运行调试
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
  -- 窗口美化，标签栏...
  {
    'romgrk/barbar.nvim',
	dependencies = {
		'lewis6991/gitsigns.nvim',
		'nvim-tree/nvim-web-devicons',
	},
	init = function() vim.g.barbar_auto_setup = false end,
	opts = {
		animation = false,
		auto_hide = true
	},
	version = '^1.0.0'
  },

  -- blink代码补全
  {
	'saghen/blink.cmp',
	event = { "BufReadPre", "BufNewFile" },
	dependencies = { 'rafamadriz/friendly-snippets' },
	version = '1.*',
	opts = {
		keymap = { preset = 'super-tab' },
		appearance = {
			nerd_font_variant = 'mono'
		},
		completion = { documentation = { auto_show = true } },
		sources = {
			default = { 'lsp', 'snippets', 'path', 'buffer' },
		},
		signature = {
			enabled = true,
		}
	},
	opts_extend = { "sources.default" },
  },

  -- 状态栏插件
  {
	'nvim-lualine/lualine.nvim',
	dependencies = { 'nvim-tree/nvim-web-devicons' },
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		theme = "auto"
	}
  },

  -- markdown可视化增强
  {
	'MeanderingProgrammer/render-markdown.nvim',
	dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' },
	opts = {},
  },

  -- 主题配置
  {
	"catppuccin/nvim",
	name = "catppuccin",
	priority = 1000,
	opts = {
		flavour = "frappe",
		transparent_background = true
	}
  },

  -- lsp管理插件
  {
	"mason-org/mason-lspconfig.nvim",
	opts = {
		ensure_installed = {
			"lua_ls",
			"clangd",
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
					"clang-format"
				},
			}
		},
		{
			"neovim/nvim-lspconfig",
			event = { "BufReadPre", "BufNewFile" },
		}
	},
  },

  -- nvim-tree
  {
	"nvim-tree/nvim-tree.lua",
	version = "*",
	lazy = false,
	dependencies = {
		"nvim-tree/nvim-web-devicons",
	},
	opts = {}
  },

}


