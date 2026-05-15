# marketplace 检索指南

## 查询类型与检索策略

### 1. 功能描述查询（最常见）

用户用自然语言描述需求，如「浏览器自动化」「GitHub 集成」「游戏开发」。

**检索策略**：
- 优先匹配 `description` 和 `description_en`
- 其次匹配 `keywords` 和 `tags`
- 按匹配度排序

**示例**：
```
用户: "网页浏览器自动化"
检索: description 包含 "浏览器" 或 "browser" 或 "自动化"
结果: agent-browser, atuin
```

### 2. 精确名称查询

用户知道插件名称，直接搜索名称。

**检索策略**：
- `name` 字段精确匹配或前缀匹配
- 忽略大小写

**示例**：
```
用户: "atuin"
检索: name == "atuin"
结果: atuin
```

### 3. 分类查询

用户想找某一类插件，如「开发工具」「游戏」「AI」。

**检索策略**：
- `category` 字段精确匹配
- 常见分类：`game-development`, `development`, `automation`, `AI`

**示例**：
```
用户: "游戏开发相关的插件"
检索: category == "game-development"
结果: godot-mcp
```

### 4. 作者查询

用户想找某个作者开发的插件。

**检索策略**：
- `author.name` 字段模糊匹配

**示例**：
```
用户: "找找看 Claude 开发的插件"
检索: author.name 包含 "Claude" 或 "Anthropic"
结果: agent-sdk-dev
```

### 5. 标签/关键词查询

用户用标签缩小范围，如「需要 MIT 许可证」「需要 MCP 协议」。

**检索策略**：
- `tags` 数组精确匹配
- `keywords` 数组模糊匹配
- `license` 字段精确匹配

**示例**：
```
用户: "支持 MCP 协议的插件"
检索: keywords 或 tags 包含 "MCP"
结果: godot-mcp, context7
```

## 检索脚本模板

```python
import json
import sys
from pathlib import Path

MARKETPLACE = Path.home() / "repos/skill-market/data/marketplace.json"

def search_marketplace(query: str, field: str = "all") -> list[dict]:
    """搜索 marketplace.json"""
    with open(MARKETPLACE) as f:
        data = json.load(f)

    results = []
    for plugin in data["plugins"]:
        if field == "all":
            # 全字段搜索
            text = " ".join([
                plugin.get("name", ""),
                plugin.get("description", ""),
                plugin.get("description_en", ""),
                " ".join(plugin.get("keywords", [])),
                " ".join(plugin.get("tags", [])),
                plugin.get("category", ""),
            ])
            score = query.lower() in text.lower()
        elif field == "name":
            score = query.lower() in plugin.get("name", "").lower()
        elif field == "category":
            score = query.lower() == plugin.get("category", "").lower()
        elif field == "author":
            author = plugin.get("author", {})
            if isinstance(author, dict):
                score = query.lower() in author.get("name", "").lower()
            else:
                score = query.lower() in str(author).lower()
        else:
            score = query.lower() in plugin.get(field, "").lower()

        if score:
            results.append(plugin)

    return results

def format_results(plugins: list[dict], limit: int = 10) -> str:
    """格式化输出"""
    if not plugins:
        return "未找到匹配的插件"

    lines = [f"## 检索结果 (共 {len(plugins)} 个)", ""]
    lines.append("| 名称 | 描述 | 分类 |")
    lines.append("|------|------|------|")
    for p in plugins[:limit]:
        name = p.get("name", "")
        desc = p.get("description", p.get("description_en", "无描述"))[:40]
        cat = p.get("category", "-")
        lines.append(f"| {name} | {desc} | {cat} |")

    if len(plugins) > limit:
        lines.append(f"\n_...还有 {len(plugins) - limit} 个结果_")

    return "\n".join(lines)

if __name__ == "__main__":
    query = sys.argv[1] if len(sys.argv) > 1 else ""
    results = search_marketplace(query)
    print(format_results(results))
```

## 使用示例

```bash
# 功能搜索
python3 search.py "浏览器自动化"

# 名称搜索
python3 search.py --field name "atuin"

# 分类搜索
python3 search.py --field category "game-development"

# 作者搜索
python3 search.py --field author "Anthropic"
```

## 分类列表

marketplace.json 中的 `category` 值：

| category | 说明 |
|----------|------|
| `game-development` | 游戏开发 |
| `development` | 开发工具 |
| `automation` | 自动化 |
| `AI` | AI 相关 |

## 注意事项

- `source` 字段表示插件源码位置：`./plugins/xxx` 或 `./external_plugins/xxx`
- 部分插件可能只有 `description_en` 没有 `description`
- `author` 字段可能是对象 `{name, url}` 也可能是字符串
