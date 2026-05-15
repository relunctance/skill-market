#!/bin/bash
# skill-market 安装脚本 — 跨平台通用
# 克隆位置：~/repos/skill-market/
# marketplace.json 在首次安装时自动从网络下载

set -e

MARKETPLACE_URL="https://download.codebuddy.cn/plugin-marketplace/codebuddy-plugins-official.zip"
MARKETPLACE_VERSION_URL="https://download.codebuddy.cn/plugin-marketplace/version.json"

echo "Setting up skill-market..."

# 从脚本位置推算 repo 根目录（兼容所有平台）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
DATA_DIR="$SKILL_DIR/data"
MARKETPLACE_JSON="$DATA_DIR/marketplace.json"

# 下载并解压 marketplace.json
download_marketplace() {
    echo "正在下载 marketplace（首次安装需要网络）..."

    # 创建 data 目录
    mkdir -p "$DATA_DIR"

    # 下载 zip 到临时文件
    TEMP_ZIP=$(mktemp /tmp/skill-market-XXXXXX.zip)
    trap "rm -f $TEMP_ZIP" EXIT

    if ! curl -L -o "$TEMP_ZIP" "$MARKETPLACE_URL" 2>/dev/null; then
        echo "❌ 下载失败，请检查网络连接"
        return 1
    fi

    # 解压 marketplace.json（不展开整个 zip，只提取）
    if command -v unzip &> /dev/null; then
        # marketplace.json 在 .codebuddy-plugin/ 目录下
        unzip -j -o "$TEMP_ZIP" ".codebuddy-plugin/marketplace.json" -d "$DATA_DIR/" 2>/dev/null || {
            echo "❌ 解压 marketplace.json 失败"
            return 1
        }
    else
        echo "❌ 需要 unzip 命令，请先安装：apt install unzip"
        return 1
    fi

    if [ -f "$MARKETPLACE_JSON" ]; then
        echo "✅ marketplace.json 已下载 ($(wc -c < "$MARKETPLACE_JSON" | tr -d ' ') bytes)"
    else
        echo "❌ marketplace.json 未找到"
        return 1
    fi
}

# 首次安装或强制更新
if [ ! -f "$MARKETPLACE_JSON" ] || [ "$1" = "--force-download" ]; then
    download_marketplace
fi

# 创建符号链接（Hermes 平台）
mkdir -p ~/.hermes/skills/skill-market
ln -sf "$SKILL_DIR/SKILL.md" ~/.hermes/skills/skill-market/SKILL.md
echo "[Hermes] installed"

# Claude Code
if [ -d ~/claude/skills ]; then
    mkdir -p ~/claude/skills/skill-market
    ln -sf "$SKILL_DIR/SKILL.md" ~/claude/skills/skill-market/SKILL.md
    echo "[Claude Code] installed"
fi

# OpenClaw（clawhub）
if command -v clawhub &> /dev/null; then
    clawhub install skill-market 2>/dev/null || echo "[OpenClaw] skipped"
fi

# Codex
if [ -d ~/codex/skills ]; then
    mkdir -p ~/codex/skills/skill-market
    ln -sf "$SKILL_DIR/SKILL.md" ~/codex/skills/skill-market/SKILL.md
    echo "[Codex] installed"
fi

echo ""
echo "✅ Done! skill-market ready."
echo "   marketplace: $MARKETPLACE_JSON"
echo ""
echo "提示：marketplace 数据在 ~/.hermes/skills/skill-market/ 下"
echo "      使用 --force-download 强制重新下载"
