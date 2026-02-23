-- 界面美化
return {
  -- 标签栏（显示当前打开的文件）
  {
    'romgrk/barbar.nvim',
    dependencies = {
      'lewis6991/gitsigns.nvim',
      'nvim-tree/nvim-web-devicons',
    },
    init = function() vim.g.barbar_auto_setup = false end,
    opts = {
      animation = false,
      auto_hide = false,  -- 始终显示标签栏
      icons = {
        buffer_index = false,
        buffer_number = false,
        button = '×',
        gitsigns = {
          added = '+',
          changed = '~',
          deleted = '-',
        },
        filetype = {
          custom_colors = false,
          enabled = true,
        },
        separator = { left = '▎', right = '' },
        modified = { buffer_number = '', icon = '●' },
        pinned = { buffer_number = '', icon = '📌' },
      },
      maximum_length = 30,  -- 文件名最大显示长度
      maximum_padding = 5,
      minimum_length = 8,
      sidebar_filetypes = {
        NvimTree = true,
        undotree = {
          text = 'undotree',
          align = 'center',
        },
      },
    },
    version = '^1.0.0'
  },

  -- 状态栏
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      theme = "auto",
      options = {
        -- 隐藏组件以简化状态栏
        component_separators = '',
        section_separators = '',
        globalstatus = true,  -- 全局状态栏
        disabled_filetypes = {
          'NvimTree',
          'alpha',
          'TelescopePrompt'
        }
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'filename', 'location' },
        lualine_c = {},
        lualine_x = { 'encoding', 'fileformat' },
        lualine_y = { 'filetype' },
        lualine_z = { 'progress' }
      }
    }
  },

  -- Markdown 可视化增强
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' },
    opts = {},
  },
}
