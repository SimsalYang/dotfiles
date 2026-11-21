# dotfiles 一键恢复（Windows）
# 用法（普通 PowerShell，非管理员）：
#   git clone https://github.com/SimsalYang/dotfiles.git
#   powershell -ExecutionPolicy Bypass -File .\dotfiles\restore-all.ps1

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot

function Step($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }

# 从注册表刷新 PATH（scoop 刚装完时当前会话还看不到它的命令）
function Refresh-Path {
    $env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'User') + ';' +
                [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
}

Step '第 1 步：Neovim 环境（scoop + 全部依赖 + 配置部署）'
& "$root\nvim\setup-windows.ps1"
Refresh-Path

Step '第 2 步：starship 与 fnm（PowerShell 提示符的依赖）'
scoop install starship fnm
fnm install --lts

Step '第 3 步：部署 PowerShell profile'
foreach ($d in @("$HOME\Documents\PowerShell", "$HOME\Documents\WindowsPowerShell")) {
    New-Item -ItemType Directory -Force $d | Out-Null
    Copy-Item "$root\PowerShell\Microsoft.PowerShell_profile.ps1" "$d\" -Force
}

Step '第 4 步：Windows Terminal 配置'
$wtDir = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
if (Test-Path $wtDir) {
    if (Test-Path "$wtDir\settings.json") {
        Copy-Item "$wtDir\settings.json" "$wtDir\settings.json.bak" -Force
    }
    Copy-Item "$root\windows-terminal\settings.json" "$wtDir\settings.json" -Force
    Write-Host '已恢复（原配置备份为 settings.json.bak）。' -ForegroundColor Green
} else {
    Write-Host '未检测到 Windows Terminal。请先从商店安装并打开一次，再按 windows-terminal\README.md 手动复制配置。' -ForegroundColor Yellow
}

Write-Host "`n全部完成！重新打开终端即可使用。" -ForegroundColor Green
Write-Host '网络备注：首次运行 nvim 会从 GitHub 下载插件，如失败先执行：' -ForegroundColor Yellow
Write-Host '  git config --global http.https://github.com.proxy http://127.0.0.1:7890' -ForegroundColor Yellow
