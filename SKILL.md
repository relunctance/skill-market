---
name: skill-market
description: skill-market 本地搜索工具，基于 marketplace.json 索引检索 AI Agent 技能插件，支持按名称、描述、分类、标签等多维度搜索
version: "1.0.0"
author: relunctance
license: MIT
category: infrastructure
tags:
  - skill-market
  - marketplace
  - search
  - plugins
metadata:
  hermes:
    platforms:
      claude_code: true
      openclaw: true
      hermes: true
---

# skill-market

> 本地 skill-market 搜索工具 — 基于 `marketplace.json` 索引检索 AI Agent 技能插件

## 触发条件

用户说：
- `搜索 skill-market`
- `在 skill-market 中查找`
- `skill-market 有哪些 XX`
- `marketplace 搜索`
- `找 XX 相关的插件`

## 数据文件

```
~/repos/skill-market/data/
├── marketplace.zip      # 完整插件包（15MB，427个SKILL.md）
├── marketplace/         # 解压后的插件目录（检索用）
└── marketplace.json   # 旧版索引（仅205个，已弃用）
```

## 自动下载 + 解压机制

首次使用时自动下载并解压 `marketplace.zip`。

```bash
MARKETPLACE_DIR="$HOME/repos/skill-market/data"
MARKETPLACE_ZIP="$MARKETPLACE_DIR/marketplace.zip"
MARKETPLACE_EXTRACT="$MARKETPLACE_DIR/marketplace"
MARKETPLACE_URL="https://download.codebuddy.cn/plugin-marketplace/codebuddy-plugins-official.zip"

# 首次自动下载 + 解压
if [ ! -f "$MARKETPLACE_ZIP" ]; then
    echo "[skill-market] 首次使用，正在下载插件包（15MB）..."
    mkdir -p "$MARKETPLACE_DIR"
    curl -sL "$MARKETPLACE_URL" -o "$MARKETPLACE_ZIP"
fi

if [ ! -d "$MARKETPLACE_EXTRACT" ]; then
    echo "[skill-market] 正在解压..."
    unzip -q "$MARKETPLACE_ZIP" -d "$MARKETPLACE_EXTRACT"
fi
```

**手动更新**：
```bash
bash ~/repos/skill-market/scripts/setup.sh --force-download
```

## 检索方式

解压后用 `find` + `grep` 检索：

```bash
# 搜索示例
QUERY="brainstorming"
find "$HOME/repos/skill-market/data/marketplace" -name "SKILL.md" -exec grep -l -i "$QUERY" {} \; 2>/dev/null

# 查看结果内容
find "$HOME/repos/skill-market/data/marketplace" -name "SKILL.md" -exec grep -l -i "brainstorming" {} \; | \
    xargs head -20 2>/dev/null
```

**注意**：marketplace.json 索引不完整（仅205个），已弃用。现解压后直接搜索全部 427 个 SKILL.md。

```json
{
  "name": "plugins-official",
  "plugins": [
    {
      "name": "插件名称",
      "description": "中文描述",
      "description_en": "English description",
      "version": "1.0.0",
      "source": "./plugins/xxx 或 ./external_plugins/xxx",
      "category": "分类",
      "tags": ["标签1", "标签2"],
      "keywords": ["关键词1", "关键词2"],
      "author": { "name": "作者名", "url": "链接" },
      "homepage": "项目主页",
      "repository": "源码仓库",
      "license": "MIT"
    }
  ]
}
```

## 检索模式

详见 [references/marketplace-search-guide.md](references/marketplace-search-guide.md)

## 快速检索命令

```bash
# 自动下载 + 解压 + find 搜索
MARKETPLACE_DIR="$HOME/repos/skill-market/data"
MARKETPLACE_ZIP="$MARKETPLACE_DIR/marketplace.zip"
MARKETPLACE_EXTRACT="$MARKETPLACE_DIR/marketplace"
MARKETPLACE_URL="https://download.codebuddy.cn/plugin-marketplace/codebuddy-plugins-official.zip"

# 首次自动下载 + 解压
if [ ! -f "$MARKETPLACE_ZIP" ]; then
    echo "[skill-market] 首次使用，正在下载插件包（15MB）..."
    mkdir -p "$MARKETPLACE_DIR"
    curl -sL "$MARKETPLACE_URL" -o "$MARKETPLACE_ZIP"
fi

if [ ! -d "$MARKETPLACE_EXTRACT" ]; then
    echo "[skill-market] 正在解压..."
    unzip -q "$MARKETPLACE_ZIP" -d "$MARKETPLACE_EXTRACT"
fi

# 搜索
QUERY="${1:-brainstorming}"
find "$MARKETPLACE_EXTRACT" -name "SKILL.md" -exec grep -l -i "$QUERY" {} \; 2>/dev/null | head -10
```

**查看结果内容**：
```bash
find "$MARKETPLACE_EXTRACT" -name "SKILL.md" -exec grep -l -i "brainstorming" {} \; | \
    xargs head -20 2>/dev/null
```

## 检索字段优先级

| 字段 | 权重 | 说明 |
|------|------|------|
| `name` | 高 | 插件名称，精确匹配优先 |
| `description` | 高 | 中文描述，模糊匹配 |
| `description_en` | 中 | 英文描述 |
| `keywords` | 中 | 关键词数组，匹配度高 |
| `tags` | 中 | 标签数组 |
| `category` | 低 | 分类 |

## 输出格式

检索结果按以下格式展示：

```
## 检索结果 (共 X 个)

| 名称 | 描述 | 分类 | 作者 |
|------|------|------|------|
| xxx | 描述... | category | author |
```

每个结果包含：
- `name`：插件名称
- `description`：中文描述
- `category`：分类（如果有）
- `author.name`：作者
- `homepage` 或 `repository`：链接
