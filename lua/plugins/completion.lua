-- 代码补全
return {
  -- blink.cmp 新一代补全引擎
  {
    'saghen/blink.cmp',
    lazy = false,
    dependencies = {
      'rafamadriz/friendly-snippets',
      'L3MON4D3/LuaSnip',
    },
    version = '1.*',
    opts = {
      keymap = { 
        preset = 'default',
        ['<Tab>'] = { 'accept', 'snippet_forward', 'fallback' },
        ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
        ['<Down>'] = { 'select_next', 'fallback' },
        ['<Up>'] = { 'select_prev', 'fallback' },
        ['<C-n>'] = { 'select_next', 'fallback' },
        ['<C-p>'] = { 'select_prev', 'fallback' },
        ['<C-Space>'] = { 'show', 'show_documentation', 'fallback' },
      },
      appearance = {
        nerd_font_variant = 'mono'
      },
      completion = {
        trigger = {
          show_on_keyword = true,
          show_on_trigger_character = true,
          show_on_accept_on_trigger_character = true,
          show_on_insert_on_trigger_character = true,
          show_on_blocked_trigger_characters = { ' ', '\n', '\t' },
        },
        list = {
          selection = {
            preselect = true,
            auto_insert = false,
          },
        },
        menu = {
          auto_show = true,
        },
        documentation = {
          auto_show = true,
        },
      },
      sources = {
        default = { 'lsp' },
        providers = {
          lsp = {
            min_keyword_length = 0,
          },
        },
      },
      signature = {
        enabled = true,
      }
    },
    opts_extend = { "sources.default" },
  },
}
