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

## 索引位置

```
~/repos/skill-market/data/marketplace.json
```

## 自动下载机制

`marketplace.json` 在首次访问时自动从网络下载（约 80KB），无需手动获取。

**下载逻辑**（在任何检索命令前自动执行）：

```bash
MARKETPLACE_JSON="$HOME/repos/skill-market/data/marketplace.json"
MARKETPLACE_ZIP="/tmp/skill-market.zip"
MARKETPLACE_URL="https://download.codebuddy.cn/plugin-marketplace/codebuddy-plugins-official.zip"

if [ ! -f "$MARKETPLACE_JSON" ]; then
    echo "[skill-market] 首次使用，正在下载 marketplace.json..."
    mkdir -p "$(dirname "$MARKETPLACE_JSON")"
    curl -sL "$MARKETPLACE_URL" -o "$MARKETPLACE_ZIP" && \
    unzip -j -o "$MARKETPLACE_ZIP" ".codebuddy-plugin/marketplace.json" -d "$(dirname "$MARKETPLACE_JSON")/" && \
    rm -f "$MARKETPLACE_ZIP"
    echo "[skill-market] 下载完成"
fi
```

**手动更新**：
```bash
bash ~/repos/skill-market/scripts/setup.sh --force-download
```

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
# 自动下载 + 搜索（首次自动下载，之后直接搜）
MARKETPLACE_JSON="$HOME/repos/skill-market/data/marketplace.json"
MARKETPLACE_URL="https://download.codebuddy.cn/plugin-marketplace/codebuddy-plugins-official.zip"

# 首次自动下载
if [ ! -f "$MARKETPLACE_JSON" ]; then
    echo "[skill-market] 首次使用，正在下载 marketplace.json..."
    mkdir -p "$(dirname "$MARKETPLACE_JSON")"
    curl -sL "$MARKETPLACE_URL" -o /tmp/skill-market.zip && \
    unzip -j -o /tmp/skill-market.zip ".codebuddy-plugin/marketplace.json" -d "$(dirname "$MARKETPLACE_JSON")/" && \
    rm -f /tmp/skill-market.zip
fi

# 搜索示例
python3 -c "
import json, sys
with open('$HOME/repos/skill-market/data/marketplace.json') as f:
    data = json.load(f)
query = sys.argv[1] if len(sys.argv) > 1 else ''
for p in data['plugins']:
    if query.lower() in p.get('name','').lower() or query.lower() in p.get('description','').lower():
        print(f\"{p['name']}: {p.get('description','无描述')[:60]}\")
" '<搜索关键词>'
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
