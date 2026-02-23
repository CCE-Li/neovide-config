-- 代码补全
return {
  -- nvim-cmp 补全引擎
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

  -- blink.cmp 新一代补全引擎
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
}
