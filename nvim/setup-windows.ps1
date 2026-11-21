# Neovim 环境一键安装（Windows）
# 用法（在普通 PowerShell 中运行，无需管理员）：
#   powershell -ExecutionPolicy Bypass -File setup-windows.ps1
# 首次运行 nvim 时会自动下载全部插件（需联网；GitHub 不稳定时先配置代理，见仓库 README）

$ErrorActionPreference = 'Stop'

Write-Host '==> 检查 scoop ...' -ForegroundColor Cyan
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host '==> 安装 scoop ...' -ForegroundColor Cyan
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-RestMethod get.scoop.sh | Invoke-Expression
}

Write-Host '==> 安装 Neovim 及依赖 ...' -ForegroundColor Cyan
# git    : lazy.nvim 与插件下载必需
# gcc    : Treesitter 语法解析器编译必需
# ripgrep/fd : telescope 全文搜索必需
# tree-sitter : Treesitter 新版安装器 CLI
# nodejs-lts : Mason 安装 pyright 需要 npm
scoop install git neovim ripgrep fd gcc tree-sitter nodejs-lts

Write-Host '==> 安装 Nerd Font（终端图标）...' -ForegroundColor Cyan
scoop bucket add nerd-fonts
scoop install JetBrainsMono-NF

Write-Host '==> 部署 init.lua ...' -ForegroundColor Cyan
$targetDir = "$env:LOCALAPPDATA\nvim"
New-Item -ItemType Directory -Force $targetDir | Out-Null
Copy-Item "$PSScriptRoot\init.lua" "$targetDir\init.lua" -Force

Write-Host ''
Write-Host '完成！重新打开终端后运行 nvim 即可。' -ForegroundColor Green
Write-Host '提醒：Windows Terminal 字体请设为 "JetBrainsMono Nerd Font"。' -ForegroundColor Yellow
