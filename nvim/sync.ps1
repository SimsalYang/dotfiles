# 将本机 Neovim 配置同步到 dotfiles 仓库（复制 + 提交 + 推送）
# 用法（在普通 PowerShell 中运行）：
#   powershell -ExecutionPolicy Bypass -File sync.ps1

$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path "$PSScriptRoot\.."
$src      = "$env:LOCALAPPDATA\nvim\init.lua"
$dst      = Join-Path $PSScriptRoot 'init.lua'

if (-not (Test-Path $src)) {
    Write-Error "找不到本机配置文件: $src"
}

Write-Host '==> 复制本机配置到仓库 ...' -ForegroundColor Cyan
Copy-Item $src $dst -Force

Set-Location $repoRoot

$changes = git status --porcelain -- nvim/init.lua
if (-not $changes) {
    Write-Host '配置没有变化，无需提交。' -ForegroundColor Green
    exit 0
}

git diff --stat -- nvim/init.lua | Write-Host

git add nvim/init.lua
$msg = "Update nvim config ($(Get-Date -Format 'yyyy-MM-dd HH:mm'))"
git commit -m $msg
git push

Write-Host '==> 已提交并推送。' -ForegroundColor Green
