# Neovim 配置文档

这是一个专为 ACM 竞赛编程优化的 Neovim 配置，集成了现代化的开发工具和美观的界面效果。

## 🚀 功能特性

### 🎯 竞赛编程
- **ACM 模板支持** - 打开 `.cpp` 文件自动插入 ACM 竞赛模板
- **在线评测** - 集成 `competitest.nvim` 插件，支持主流 OJ 平台
- **快捷编译运行** - `F5` 在普通模式和插入模式下都能编译运行代码
- **错误信息显示** - 编译错误直接输出在控制台，便于快速调试

### 🔧 开发环境
- **LSP 支持** - 配置 `clangd` 语法检测和智能补全
- **代码补全** - 集成 `nvim-cmp` 和 `blink.cmp` 双重补全引擎
- **语法高亮** - 使用 `nvim-treesitter` 提供精确的语法高亮
- **括号匹配** - 智能括号匹配和自动缩进
- **代码注释** - `Comment.nvim` 提供快捷注释功能

### 🎨 界面美化
- **主题支持** - 集成 Tokyo Night 和 Catppuccin 主题
- **玻璃效果** - Neovide 支持透明背景和模糊效果
- **无边框模式** - F11 切换全屏无边框模式
- **状态栏** - 简洁的 lualine 状态栏
- **文件树** - nvim-tree 文件管理器

### ⌨️ 快捷键配置

#### 文件操作
- `Ctrl + N` - 在当前目录创建新的 C++ 文件（新标签页）
- `Ctrl + Shift + N` - 在当前目录创建新的 C++ 文件（当前标签页）
- `<leader>rn` - 重命名当前文件
- `<leader>mv` - 移动当前文件到其他目录

#### 标签页管理
- `Alt + Q` - 快速关闭当前标签页
- `Alt + Ctrl + 方向键` - 切换标签页

#### 窗口控制
- `F11` - 切换全屏模式（无边框效果）
- `F12` - 调整玻璃效果透明度
- `<leader>fw` - 最大化窗口
- `<leader>fr` - 恢复窗口大小

#### 文本选择
- `鼠标拖拽` - 可视化选择文本
- `Shift + 方向键` - 扩展选择
- `Shift + Ctrl + 方向键` - 按单词扩展选择

#### 代码编辑
- `gcc` - 注释/取消注释当前行
- `gc` - 注释/取消注释选中块
- `Tab` - 选择下一个补全项
- `Shift + Tab` - 选择上一个补全项

#### 系统集成
- `Ctrl + C/V/X` - 与 Windows 剪贴板同步
- `启动时自动切换英文输入法` - 模拟 Shift 键切换

## 📁 配置结构

```
nvim/
├── init.lua                    # 主配置文件
├── lua/
│   ├── core/
│   │   ├── options.lua         # 基础选项配置
│   │   └── keymaps.lua         # 快捷键映射
│   ├── plugins/
│   │   ├── plugins.lua         # 插件管理
│   │   ├── theme.lua           # 主题配置
│   │   ├── syntax.lua          # 语法高亮
│   │   ├── completion.lua      # 代码补全
│   │   ├── lsp.lua             # LSP 配置
│   │   ├── comment.lua         # 注释插件
│   │   ├── acm.lua             # ACM 竞赛工具
│   │   ├── ui.lua              # 界面美化
│   │   └── file.lua            # 文件管理
│   └── ui/
│       └── neovide.lua         # Neovide 特定配置
```

## 🛠️ 安装与使用

### 环境要求
- Neovim 0.9+
- Neovide（可选，用于玻璃效果）
- Git
- C++ 编译器（g++/clang++）
- clangd（LSP 服务器）

### 安装步骤
1. 备份现有配置：
   ```bash
   mv ~/.config/nvim ~/.config/nvim.backup
   ```

2. 克隆配置：
   ```bash
   git clone <repository-url> ~/.config/nvim
   ```

3. 启动 Neovim：
   ```bash
   nvim
   ```

4. 插件会自动安装，首次启动可能需要几分钟

### Neovide 配置
如果使用 Neovide，可获得额外的视觉效果：
- 透明玻璃背景
- 无边框全屏模式
- 光标特效

启动命令：
```bash
neovide
```

## 🎯 ACM 竞赛使用

### 模板功能
打开任何 `.cpp` 文件时会自动插入 ACM 模板，包含：
- 常用头文件（包括 `bits/stdc++.h`）
- 快速 I/O 设置
- 常用宏定义

### 编译运行
- 按 `F5` 编译并运行当前文件
- 编译错误会显示在下方控制台
- 支持多文件项目编译

### 在线评测
使用 `competitest.nvim` 插件：
- 支持主流 OJ 平台
- 自动获取测试数据
- 一键提交代码

## 🔧 自定义配置

### 修改主题
在 `lua/plugins/theme.lua` 中切换主题：
```lua
-- 启用 Tokyo Night
require("tokyodark").setup()

-- 或启用 Catppuccin
require("catppuccin").setup()
```

### 调整快捷键
在 `lua/core/keymaps.lua` 中修改或添加快捷键。

### 添加新插件
在 `lua/plugins/plugins.lua` 中添加新插件配置。

## 🐛 常见问题

### clangd 无法识别 `bits/stdc++.h`
确保安装了完整的 GCC 工具链，并在 `compile_commands.json` 中正确配置包含路径。

### Neovide 玻璃效果不生效
检查 Neovide 版本是否为最新，某些旧版本可能不支持透明效果。

### 插件加载失败
运行 `:PackerSync` 重新安装插件，或检查网络连接。

## 📝 更新日志

### 2026-02-24
- ✅ 配置新建文件快捷键
- ✅ 完善鼠标选择模式
- ✅ 优化换行缩进

### 2026-02-23
- ✅ 配置窗口移动快捷键
- ✅ 隐藏窗口任务栏
- ✅ 优化鼠标选择功能

### 2026-02-21
- ✅ 添加 Alt + Ctrl + 方向键切换标签页

### 2026-02-20
- ✅ 美化窗口界面
- ✅ 安装 nvim-tree 文件管理器
- ✅ 设置算法目录为初始化目录
- ✅ 优化窗口快捷键

### 2026-02-19
- ✅ 解决 clangd 无法识别 bits/stdc++.h 的 bug

### 2026-02-17
- ✅ 适配 clangd 语法检测
- ✅ 将编译错误输出到控制台

### 2026-02-16
- ✅ 配置启动时切换英文输入法
- ✅ 添加大括号缩进
- ✅ 修复 `#define endl '\n'` 正则匹配
- ✅ 普通模式复制粘贴与 Windows 同步
- ✅ 插入模式支持 F5
- ✅ 重新排版配置文件

## 📄 许可证

MIT License

## 🤝 贡献

欢迎提交 Issue 和 Pull Request 来改进这个配置！

---

**Happy Coding! 🎉**
