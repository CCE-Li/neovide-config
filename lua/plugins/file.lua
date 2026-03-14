-- 文件管理
return {
  -- NvimTree 文件树
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("nvim-tree").setup({
        -- 启用右键菜单
        view = {
          width = 30,
        },
        renderer = {
          group_empty = true,
          highlight_git = true,
          highlight_opened_files = "none",
          root_folder_label = ":~:s?$?/..",
          indent_markers = {
            enable = true,
          },
          icons = {
            show = {
              file = true,
              folder = true,
              folder_arrow = true,
              git = true,
            },
          },
        },
        -- 右键菜单配置
        actions = {
          open_file = {
            quit_on_open = false,
          },
        },
        -- 启用文件弹出菜单（右键菜单）
        hijack_directories = {
          enable = true,
          auto_open = true,
        },
        update_focused_file = {
          enable = true,
          update_root = true,
        },
        git = {
          enable = true,
          ignore = false,
          timeout = 500,
        },
        filesystem_watchers = {
          enable = true,
          debounce_delay = 50,
          ignore_dirs = {},
        },
        on_attach = function(bufnr)
          local api = require("nvim-tree.api")
          
          -- 右键菜单函数
          local function show_context_menu(node)
            local menu_items = {}
            
            -- 根据节点类型添加不同的菜单项
            if node.type == "directory" then
              menu_items = {
                { key = "1", name = "打开文件夹", action = function() api.node.open.edit(node) end },
                { key = "2", name = "重命名", action = function() api.fs.rename(node) end },
                { key = "3", name = "删除", action = function() api.fs.remove(node) end },
                { key = "4", name = "创建文件/文件夹", action = function() api.fs.create(node) end },
                { key = "5", name = "复制", action = function() api.fs.copy.node(node) end },
                { key = "6", name = "剪切", action = function() api.fs.cut(node) end },
                { key = "7", name = "粘贴", action = function() api.fs.paste(node) end },
              }
            else -- 文件
              menu_items = {
                { key = "1", name = "打开", action = function() api.node.open.edit(node) end },
                { key = "2", name = "重命名", action = function() api.fs.rename(node) end },
                { key = "3", name = "删除", action = function() api.fs.remove(node) end },
                { key = "4", name = "复制", action = function() api.fs.copy.node(node) end },
                { key = "5", name = "剪切", action = function() api.fs.cut(node) end },
                { key = "6", name = "在所在文件夹创建", action = function() api.fs.create(node.parent) end },
              }
            end
            
            -- 创建浮动窗口显示菜单
            local buf = vim.api.nvim_create_buf(false, true)
            local lines = {"文件操作:"}
            for i, item in ipairs(menu_items) do
              table.insert(lines, string.format("  %s. %s", item.key, item.name))
            end
            table.insert(lines, "") -- 空行
            table.insert(lines, "ESC: 取消")
            
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
            vim.api.nvim_buf_set_option(buf, "modifiable", false)
            
            -- 获取窗口配置
            local width = 25
            local height = #lines
            local win_config = {
              relative = "cursor",
              width = width,
              height = height,
              row = 1,
              col = 2,
              border = "rounded",
              style = "minimal",
            }
            
            local win = vim.api.nvim_open_win(buf, true, win_config)
            
            -- 设置高亮
            vim.api.nvim_buf_add_highlight(buf, -1, "Title", 0, 0, -1)
            for i = 1, #menu_items do
              vim.api.nvim_buf_add_highlight(buf, -1, "Special", i, 0, 3)
            end
            
            -- 设置键盘映射
            for i, item in ipairs(menu_items) do
              vim.keymap.set("n", item.key, function()
                item.action()
                vim.api.nvim_win_close(win, true)
              end, { buffer = buf, noremap = true, silent = true })
            end
            
            -- ESC 关闭窗口
            vim.keymap.set("n", "<Esc>", function()
              vim.api.nvim_win_close(win, true)
            end, { buffer = buf, noremap = true, silent = true })
            
            -- 鼠标点击支持
            vim.keymap.set("n", "<LeftMouse>", function()
              local mouse_pos = vim.fn.getmousepos()
              -- 检查鼠标是否在当前浮动窗口内
              if mouse_pos.winid == win then
                local win_line = mouse_pos.line - mouse_pos.winrow + 1
                if win_line > 1 and win_line <= #menu_items + 1 then
                  local item = menu_items[win_line - 1]
                  item.action()
                  vim.api.nvim_win_close(win, true)
                end
              end
            end, { buffer = buf, noremap = true, silent = true })
            
            -- 鼠标悬停高亮 - 使用更可靠的鼠标移动检测
            vim.api.nvim_create_autocmd("CursorMoved", {
              buffer = buf,
              callback = function()
                local mouse_pos = vim.fn.getmousepos()
                if mouse_pos.winid == win then
                  local win_line = mouse_pos.line - mouse_pos.winrow + 1
                  if win_line > 1 and win_line <= #menu_items + 1 then
                    -- 清除之前的高亮并重新设置
                    vim.api.nvim_buf_clear_namespace(buf, -1, 0, -1)
                    vim.api.nvim_buf_add_highlight(buf, -1, "Title", 0, 0, -1)
                    for i = 1, #menu_items do
                      vim.api.nvim_buf_add_highlight(buf, -1, "Special", i, 0, 3)
                    end
                    vim.api.nvim_buf_add_highlight(buf, -1, "Visual", win_line - 1, 0, -1)
                  end
                end
              end,
            })
          end
          
          -- 右键菜单映射
          vim.keymap.set("n", "<RightMouse>", function()
            local node = api.tree.get_node_under_cursor()
            if node then
              show_context_menu(node)
            end
          end, { buffer = bufnr, noremap = true, silent = true, desc = "NvimTree 右键菜单" })
          
          -- 也可以使用 'm' 键触发菜单（备用方案）
          vim.keymap.set("n", "m", function()
            local node = api.tree.get_node_under_cursor()
            if node then
              show_context_menu(node)
            end
          end, { buffer = bufnr, noremap = true, silent = true, desc = "NvimTree 菜单" })
          
          -- 双击展开/折叠文件夹，打开文件
          vim.keymap.set("n", "<2-LeftMouse>", function()
            local node = api.tree.get_node_under_cursor()
            if node then
              if node.type == "directory" then
                -- 文件夹：切换展开/折叠状态
                api.node.open.edit(node)
              else
                -- 文件：打开文件
                api.node.open.edit(node)
              end
            end
          end, { buffer = bufnr, noremap = true, silent = true, desc = "NvimTree 双击" })
          
          -- 回车键打开文件/文件夹
          vim.keymap.set("n", "<CR>", function()
            local node = api.tree.get_node_under_cursor()
            if node then
              if node.type == "directory" then
                -- 文件夹：切换展开/折叠状态
                api.node.open.edit(node)
              else
                -- 文件：打开文件
                api.node.open.edit(node)
              end
            end
          end, { buffer = bufnr, noremap = true, silent = true, desc = "NvimTree 回车" })
        end,
      })
    end,
  },
}
