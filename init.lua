
-- ======================= 基础配置 ==========================

require("ui.neovide") -- 样式设置

require("core.options") -- 基础配置
require("core.keymaps") -- 快捷键
require("core.autocmds") -- 自动化脚本

require("plugins") -- 插件配置


-- ======================= 模块化引用 ========================
require("modules.bracket").setup() -- 加载括号匹配+自动缩进模块

require("modules.lsp") -- lsp基础设置

