#!/usr/bin/env bash
# Neovim 环境一键安装（Linux）
# 用法:
#   bash setup-linux.sh
# 支持 Debian/Ubuntu、Fedora、Arch；其他发行版会提示手动安装。
# 首次运行 nvim 时会自动下载插件与语言服务器（GitHub 网络不稳时先配代理）。

set -e

# 同步模式：本机 ~/.config/nvim/init.lua -> 仓库（备份，方向不可逆）
if [ "${1:-}" = "--sync" ]; then
    repo_root="$(cd "$(dirname "$0")" && pwd)"
    src="${XDG_CONFIG_HOME:-$HOME/.config}/nvim/init.lua"
    if [ ! -f "$src" ]; then
        echo "找不到本机配置: $src" >&2
        exit 1
    fi
    cp "$src" "$repo_root/nvim/init.lua"
    if git -C "$repo_root" status --porcelain -- nvim/init.lua | grep -q .; then
        git -C "$repo_root" add nvim/init.lua
        git -C "$repo_root" commit -m "Sync nvim config ($(date '+%Y-%m-%d %H:%M'))"
        git -C "$repo_root" push
        echo '==> 已提交并推送。' 
    else
        echo '==> 配置没有变化，无需提交。'
    fi
    exit 0
fi

echo '==> 安装系统依赖 ...'
if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update
    # neovim: 源内版本可能过旧（需 >= 0.11），先不装，后面统一装官方版
    sudo apt-get install -y git ripgrep gcc make unzip xclip nodejs npm python3 python3-venv
    # Ubuntu/Debian 的 fd 包叫 fdfind，做个 fd 链接
    sudo apt-get install -y fd-find || true
    command -v fdfind >/dev/null && mkdir -p "$HOME/.local/bin" && ln -sf "$(command -v fdfind)" "$HOME/.local/bin/fd"
    sudo apt-get install -y tree-sitter-cli || true
elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y git ripgrep fd gcc make unzip xclip nodejs npm python3 tree-sitter-cli
elif command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --needed --noconfirm git ripgrep fd gcc make unzip xclip nodejs npm python3 tree-sitter
else
    echo '未识别的发行版，请手动安装: git ripgrep fd gcc make unzip xclip nodejs npm python3 tree-sitter-cli' >&2
    exit 1
fi

# 确保 ~/.local/bin 在 PATH 里（当前会话与 .bashrc/.zshrc 都尽量覆盖）
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH"
       grep -qs '.local/bin' "$HOME/.bashrc" 2>/dev/null || echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
       [ -f "$HOME/.zshrc" ] && { grep -qs '.local/bin' "$HOME/.zshrc" || echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"; } ;;
esac

version_ok() {
    command -v nvim >/dev/null 2>&1 || return 1
    local v
    v=$(nvim --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
    [ -n "$v" ] && [ "$(printf '%s\n%s\n' "0.11" "$v" | sort -V | head -1)" = "0.11" ]
}

echo '==> 安装 Neovim（要求 >= 0.11）...'
if ! version_ok; then
    echo '    系统源内版本过旧或不存在，改从 GitHub 安装官方版 ...'
    tmp=$(mktemp -d)
    curl -fL --retry 3 -o "$tmp/nvim.tar.gz" https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
    mkdir -p "$HOME/.local/opt"
    tar -xzf "$tmp/nvim.tar.gz" -C "$HOME/.local/opt"
    ln -sfn "$HOME/.local/opt/nvim-linux-x86_64/bin/nvim" "$HOME/.local/bin/nvim"
    rm -rf "$tmp"
fi
nvim --version | head -1

echo '==> 部署 init.lua ...'
cfg_dir="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
mkdir -p "$cfg_dir"
cp "$(dirname "$0")/init.lua" "$cfg_dir/init.lua"

echo
echo '完成！运行 nvim 即会自动下载插件。'
echo '提醒：终端字体请自行安装 Nerd Font（如 JetBrainsMono Nerd Font），否则图标显示为方块。'
echo '提醒：无图形界面的服务器环境无需字体，但剪贴板互通需要 xclip（已装）。'
