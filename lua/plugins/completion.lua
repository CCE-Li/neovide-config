-- 代码补全
return {
  -- blink.cmp 新一代补全引擎
  {
    'saghen/blink.cmp',
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      'rafamadriz/friendly-snippets',
      'L3MON4D3/LuaSnip',
    },
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
