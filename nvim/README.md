# nvim/

Neovim 配置文件（Windows / Linux 通用）。本机配置文件位置：Windows 为 `%LOCALAPPDATA%\nvim\init.lua`，Linux 为 `~/.config/nvim/init.lua`。

## 目录内容

| 文件 | 作用 |
|---|---|
| `init.lua` | Neovim 主配置（插件、LSP、快捷键都在里面） |
| `setup-windows.ps1` | **新电脑恢复**：一键安装 Neovim 及全部依赖，并部署本配置 |
| `sync.ps1` | （已移至仓库根目录）通用同步脚本，覆盖 nvim / PowerShell / 终端配置 |

## 场景一：在新 Windows 电脑上恢复环境

前提：已安装 git。在普通 PowerShell（非管理员）中执行：

```powershell
git clone https://github.com/SimsalYang/dotfiles.git
powershell -ExecutionPolicy Bypass -File .\dotfiles\nvim\setup-windows.ps1
```

脚本自动完成：

1. 安装 scoop（如果没有）
2. 安装 Neovim 及依赖：git、ripgrep、fd、gcc（编译 Treesitter 解析器）、tree-sitter（解析器安装 CLI）、nodejs-lts（Mason 装 pyright 需要 npm）、JetBrainsMono-NF（终端图标字体）
3. 把 `init.lua` 复制到 `%LOCALAPPDATA%\nvim\`

然后重新打开终端，运行 `nvim`——首次启动会自动下载全部插件（lazy.nvim）和语言服务器（lua_ls / pyright / ruff），保持网络畅通，等它跑完即可。

## 场景一（Linux）：在新 Linux 机器上恢复环境

前提：已安装 git 和 curl。运行：

```bash
git clone https://github.com/SimsalYang/dotfiles.git
bash ./dotfiles/nvim/setup-linux.sh
```

Linux 上日常改完配置后，用同一个脚本备份到仓库：

```bash
bash ./dotfiles/nvim/setup-linux.sh --sync
```

脚本自动完成（支持 Debian/Ubuntu、Fedora、Arch）：

1. 用发行版包管理器安装依赖：git、ripgrep、fd、gcc、make、xclip（剪贴板互通）、nodejs/npm（Mason 装 pyright 需要）、python3
2. 安装 Neovim（源内版本 ≥ 0.11 直接用源内的，过旧则自动从 GitHub 下载官方版到 `~/.local/opt`）
3. 把 `init.lua` 复制到 `~/.config/nvim/`

然后运行 `nvim`，首次启动自动下载插件和语言服务器。字体需自行安装一款 Nerd Font；无桌面的服务器环境可跳过。

## 场景二：本机改完配置，同步到仓库

日常在 `%LOCALAPPDATA%\nvim\init.lua` 里改配置、验证没问题后，运行仓库**根目录**的通用同步脚本：

```powershell
powershell -ExecutionPolicy Bypass -File <仓库路径>\sync.ps1
```

脚本会自动同步 Neovim、PowerShell profile、Windows Terminal 三处配置：逐文件检查改动 → 有改动就提交并推送，全部最新则提示无需提交。

> 注意：同步方向永远是 **本机 → 仓库**（备份）。不要在仓库里直接改文件，否则下次同步会被本机覆盖。

## 场景三：手动同步（脚本不可用时的兜底）

```powershell
# 本机 → 仓库
copy $env:LOCALAPPDATA\nvim\init.lua <仓库路径>\nvim\init.lua
cd <仓库路径>
git add nvim/init.lua
git commit -m "Update nvim config"
git push
```

## 网络备注（国内环境）

首次启动 nvim 会从 GitHub 下载插件和解析器，如网络不稳定，先给 git 配代理：

```powershell
git config --global http.https://github.com.proxy http://127.0.0.1:7890
git config --global http.version HTTP/1.1
```

pyright 走 npm registry，一般无需代理。

## 使用要点速查

- **Leader 键 = 空格**，按下去有按键提示弹窗（which-key）
- `<空格>e` 文件树；`<空格>ff` 找文件；`<空格>fg` 全文搜索
- `gd` 跳定义；`<空格>rn` 重命名；`<空格>ca` 代码操作；`<空格>cf` 格式化
- `[d` / `]d` 诊断跳转；`<空格>xx` 全项目诊断面板
- 插件管理：`:Lazy sync`；语言服务器：`:Mason`；语法解析器：`:TSInstall <语言>`
- 新增语言支持：`:MasonInstall <服务器>`，然后在 `init.lua` 的 `vim.lsp.enable({...})` 一行里加上服务器名
