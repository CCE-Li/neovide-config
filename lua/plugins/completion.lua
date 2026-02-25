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
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()  -- 没有补全菜单时执行默认 Tab 行为（缩进）
            end
          end, { "i", "s", "c" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()  -- 没有补全菜单时执行默认 Shift+Tab 行为
            end
          end, { "i", "s", "c" }),
          ["<Down>"] = cmp.mapping.select_next_item(),  -- 下箭头选下一个
          ["<Up>"] = cmp.mapping.select_prev_item(),    -- 上箭头选上一个
          ["<C-n>"] = cmp.mapping.select_next_item(),    -- Ctrl+n 选下一个
          ["<C-p>"] = cmp.mapping.select_prev_item(),    -- Ctrl+p 选上一个
          ["<CR>"] = cmp.mapping.confirm({ select = true }), -- 回车确认
          ["<C-Space>"] = cmp.mapping.complete(),       -- Ctrl+Space 手动触发补全
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
      keymap = { 
        preset = 'super-tab',  -- 使用 super-tab 预设，智能 Tab 行为
        ['<Tab>'] = { 'select_next', 'snippet_forward', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
        ['<Down>'] = { 'select_next', 'fallback' },
        ['<Up>'] = { 'select_prev', 'fallback' },
        ['<C-n>'] = { 'select_next', 'fallback' },
        ['<C-p>'] = { 'select_prev', 'fallback' },
        ['<C-Space>'] = { 'show', 'show_documentation', 'fallback' },
      },
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
