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
~/repos/skill-market/marketplace.json
```

## marketplace.json 结构

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
# 加载 marketplace.json
python3 -c "
import json
with open('~/repos/skill-market/marketplace.json') as f:
    data = json.load(f)
plugins = data['plugins']
"

# 搜索示例
python3 -c "
import json, sys
with open('~/repos/skill-market/marketplace.json') as f:
    data = json.load(f)
query = sys.argv[1] if len(sys.argv) > 1 else ''
results = [p for p in data['plugins']
           if query.lower() in p.get('name','').lower()
           or query.lower() in p.get('description','').lower()]
for p in results[:10]:
    print(f\"{p['name']}: {p.get('description','无描述')[:60]}\")
"
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
