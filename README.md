# dotfiles

个人配置文件备份。换电脑时按各目录的说明快速恢复。

## 目录

| 目录 | 说明 |
|---|---|
| `PowerShell/` | PowerShell 配置（starship 提示符 + fnm Node 版本管理初始化） |
| `.logseq/` | Logseq 笔记配置 |
| `nvim/` | Neovim 配置（lazy.nvim + LSP + Treesitter） |

## nvim/ — Windows 一键恢复

在**普通 PowerShell**（非管理员）中运行：

```powershell
git clone https://github.com/SimsalYang/dotfiles.git
powershell -ExecutionPolicy Bypass -File .\dotfiles\nvim\setup-windows.ps1
```

脚本会自动完成：安装 scoop → 安装 Neovim 及全部依赖（git/gcc/ripgrep/tree-sitter/Nerd Font 等）→ 部署 `init.lua` 到 `%LOCALAPPDATA%\nvim\`。

首次运行 `nvim` 时会自动下载全部插件和语言服务器（lua_ls / pyright / ruff），保持网络畅通即可。

### 网络备注（国内环境）

- 插件与解析器从 GitHub 拉取，如网络不稳，先给 git 配代理：

  ```powershell
  git config --global http.https://github.com.proxy http://127.0.0.1:7890
  git config --global http.version HTTP/1.1
  ```

- pyright 由 Mason 通过 npm 安装，走的是 npm registry，一般无需代理。

### 配置文件结构（`nvim/init.lua`）

- **插件管理**：lazy.nvim
- **主题**：tokyonight-night
- **补全**：blink.cmp（含原生模糊匹配加速）
- **语法高亮**：nvim-treesitter（17 种语言解析器，gcc 编译）
- **LSP**：mason.nvim 管理服务器；已启用 lua_ls / pyright（类型）/ ruff（lint+格式化）
- **搜索**：telescope.nvim（ripgrep + fd）
- **文件树**：nvim-tree.lua
- **诊断面板**：trouble.nvim
- **快捷键提示**：which-key.nvim（Leader 键 = 空格）

新增语言支持：在 nvim 内 `:MasonInstall <服务器>`，然后在 `init.lua` 的 `vim.lsp.enable({...})` 一行里加上服务器名。

详细操作（新电脑恢复、日常同步、网络备注）见 [nvim/README.md](nvim/README.md)。
