# skill-market

> 本地 skill-market 搜索工具 — 基于 `marketplace.json` 索引检索 AI Agent 技能插件

## 概述

skill-market 是一个本地 skill-market 搜索工具，提供了 205 个 AI Agent 技能插件的本地索引，基于 `marketplace.json` 实现快速检索。

## 目录结构

```
skill-market/
├── marketplace.json       # 插件索引（205个插件）
├── plugins/              # 官方插件目录（仅索引）
├── external_plugins/     # 第三方插件目录（仅索引）
└── references/
    └── marketplace-search-guide.md  # 检索指南
```

## 功能特性

- **本地索引**：205 个插件的元数据，无需网络
- **多维度检索**：支持按名称、描述、分类、标签、作者等检索
- **快速响应**：基于 JSON 的本地检索，毫秒级返回结果

## 检索方式

### 命令行检索

```bash
# 功能搜索
python3 -c "
import json, sys
with open('~/repos/skill-market/marketplace.json') as f:
    data = json.load(f)
query = sys.argv[1] if len(sys.argv) > 1 else ''
for p in data['plugins']:
    if query.lower() in p.get('description','').lower():
        print(f\"{p.get('name')}: {p.get('description','无描述')[:60]}\")
" '浏览器'
```

### 检索字段

| 字段 | 说明 |
|------|------|
| `name` | 插件名称 |
| `description` | 中文描述 |
| `description_en` | 英文描述 |
| `keywords` | 关键词数组 |
| `tags` | 标签数组 |
| `category` | 分类 |

## 安装

```bash
# 克隆到标准位置
git clone https://github.com/relunctance/skill-market.git ~/repos/skill-market

# 运行跨平台安装脚本
bash ~/repos/skill-market/scripts/setup.sh
```

## 许可证

MIT
