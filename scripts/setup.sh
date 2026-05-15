#!/bin/bash
# skill-market 安装脚本 — 跨平台通用
# 克隆位置：~/repos/skill-market/

set -e

echo "Setting up skill-market..."

# 从脚本位置推算 repo 根目录（兼容所有平台）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"

# Hermes
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

echo "Done! skill-market ready."
