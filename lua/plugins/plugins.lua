-- 插件主配置文件
-- 加载所有插件模块

return {
  -- 加载会话管理插件
  require("plugins.session"),
  
  -- 加载主题插件
  require("plugins.theme"),
  
  -- 加载语法高亮插件
  require("plugins.syntax"),
  
  -- 加载代码补全插件
  require("plugins.completion"),
  
  -- 加载 LSP 插件
  require("plugins.lsp"),
  
  -- 加载注释插件
  require("plugins.comment"),
  
  -- 加载 ACM 竞赛工具
  require("plugins.acm"),
  
  -- 加载界面美化插件
  require("plugins.ui"),
  
  -- 加载文件管理插件
  require("plugins.file"),
  
  }


