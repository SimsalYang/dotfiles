# windows-terminal/

Windows Terminal（稳定版）的 `settings.json` 备份。本机实际位置：

```
%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json
```

## 在新电脑上恢复

1. 先安装 Windows Terminal（Microsoft Store 或 `winget install Microsoft.WindowsTerminal`），**先打开一次让它生成默认配置**，然后完全退出。
2. 把本目录的 `settings.json` 复制覆盖到上面的路径：

   ```powershell
   copy .\dotfiles\windows-terminal\settings.json `
        "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
   ```

3. 重新打开 Windows Terminal 生效。

> 注意：`settings.json` 里的 profile GUID 是通用的（pwsh / cmd / Azure 等系统配置），跨机器可直接用；但如果里面引用了本机特有路径（启动目录、图标等），恢复后按新机器情况微调。

## 依赖

- **字体**：终端里如果显示方块图标，先装 Nerd Font：

  ```powershell
  scoop bucket add nerd-fonts
  scoop install JetBrainsMono-NF
  ```

  然后在 settings.json 的 `profiles.defaults` 里加一行 `"font": { "face": "JetBrainsMono Nerd Font" }`（当前备份尚未设置字体，这是为了跟 nvim 的图标显示对齐，建议恢复后加上）。

## 同步回仓库

本机改完终端设置后，重新复制覆盖本目录的 `settings.json` 并提交：

```powershell
copy "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" <仓库路径>\windows-terminal\
```
