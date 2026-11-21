# 将本机配置同步到 dotfiles 仓库（Neovim + PowerShell + Windows Terminal）
# 方向永远是 本机 -> 仓库（备份）。不要在仓库里直接改文件，否则会被本机覆盖。
# 用法（普通 PowerShell）：
#   powershell -ExecutionPolicy Bypass -File sync.ps1

$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot

# 源 -> 目标 映射；PowerShell 7 的 profile 优先，其次 Windows PowerShell 5.1
$pairs = [System.Collections.Generic.List[hashtable]]::new()
$pairs.Add(@{ Src = "$env:LOCALAPPDATA\nvim\init.lua"; Dst = "$root\nvim\init.lua"; Label = 'Neovim init.lua' })

$ps7 = "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
$ps5 = "$HOME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
if (Test-Path $ps7) {
    $pairs.Add(@{ Src = $ps7; Dst = "$root\PowerShell\Microsoft.PowerShell_profile.ps1"; Label = 'PowerShell profile (7)' })
} elseif (Test-Path $ps5) {
    $pairs.Add(@{ Src = $ps5; Dst = "$root\PowerShell\Microsoft.PowerShell_profile.ps1"; Label = 'PowerShell profile (5.1)' })
}

$pairs.Add(@{
    Src   = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    Dst   = "$root\windows-terminal\settings.json"
    Label = 'Windows Terminal settings'
})

$changed = @()
foreach ($p in $pairs) {
    if (-not (Test-Path $p.Src)) {
        Write-Host "跳过（本机不存在）: $($p.Label)" -ForegroundColor DarkGray
        continue
    }
    Copy-Item $p.Src $p.Dst -Force
    if (git -C $root status --porcelain -- $p.Dst) {
        Write-Host "有更新: $($p.Label)" -ForegroundColor Cyan
        $changed += $p.Dst
    } else {
        Write-Host "无变化: $($p.Label)" -ForegroundColor DarkGray
    }
}

if ($changed.Count -eq 0) {
    Write-Host "`n全部配置已是最新，无需提交。" -ForegroundColor Green
    exit 0
}

Set-Location $root
git add @changed
$msg = "Sync dotfiles ($(Get-Date -Format 'yyyy-MM-dd HH:mm'))"
git commit -m $msg
git push
Write-Host "`n已提交并推送 $($changed.Count) 个文件。" -ForegroundColor Green
