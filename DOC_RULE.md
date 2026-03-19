# 参考文档编写规范

本规范适用于 feishu-mcp-tool 所有模块的 reference 文档。

---

## 文档结构

每个模块文档按以下顺序组织：

```
1. 共用说明   — 简单但重复出现的字段描述
2. 类型定义   — 复杂且复用的参数结构
3. 工具列表   — 每个工具的参数和示例
4. 常见工作流 — 多工具组合的典型场景
```

---

## 一、共用说明

**收录标准：** 字段类型为 string/number 等简单类型，但描述较长（3 行以上），且在 2+ 个工具中出现。

**只写字段含义，不写使用约束。**

格式：
```markdown
## 共用说明

- **`fieldName`**：含义说明。
```

---

## 二、类型定义

### 抽取标准

同时满足以下两条才抽取为命名类型：

1. 在 2+ 个工具中出现
2. 是对象或联合类型（有嵌套结构），不是简单 string/number

不满足以上条件的字段直接在工具定义中内联。

### 类型定义规则

**只描述类型自身的结构和字段含义，不描述该类型与其他参数的约束关系。**

约束关系（如二选一、依赖关系）属于工具定义的职责。

格式：
```markdown
### TypeName
一句话说明这个类型是什么。

- `field1`* Type：字段含义
- `field2`? Type：字段含义，不传时的默认行为
```

联合类型（anyOf）用分条列出：
```markdown
### TypeName
以下两种之一：

- 情况A：`fieldA`* string，`style`? TypeX
- 情况B：`fieldB`* string，`style`? TypeX
```

有多个分支且结构差异大的联合类型用表格：
```markdown
### TypeName
- `key1`* string：可选值 `a` \| `b` \| `c`
- `key2`* object：key 必须与 key1 一致

| key1 值 | key2 结构 |
|---------|----------|
| `a` | `{fieldX*: string, fieldY?: number}` |
| `b` | `{fieldZ*: boolean}` |
```

### 字段标注规范

| 写法 | 含义 |
|------|------|
| `field`* Type | 必填 |
| `field`? Type | 可选 |
| Type[] | 数组 |
| `a` \| `b` \| `c` | 枚举值 |

---

## 三、工具定义

### 格式

```markdown
### `tool_name`

一句话描述工具用途和核心约束（如不支持 Wiki URL）。

**参数：**

- `param1`* Type → 见共用说明        （引用共用说明时）
- `param2`* TypeName                  （引用类型定义时）
- `param3`? string：字段含义          （简单内联时）
- `param4`* array：说明
  - `subField1`* string：含义
  - `subField2`? TypeName

> 参数间的约束（如二选一、前置条件）写在此处。

**示例：**（1~2 个，覆盖最典型的使用场景）

\```bash
feishu-mcp-tool tool_name '{"key":"value"}'
\```
```

### 参数描述规则

- **引用共用说明的字段**：写 `→ 见共用说明`，不重复描述
- **引用类型定义的字段**：直接写类型名，不展开结构
- **只在本工具出现的简单字段**：内联描述，格式 `含义，补充说明（如默认值、枚举值、范围）`
- **只在本工具出现的复杂字段**：在本工具定义中就地展开，不单独抽类型

### 约束关系写法

```markdown
> `paramA` 与 `paramB` 二选一，不可同时传。
> 调用前需先通过 `other_tool` 获取 xxx。
```

---

## 四、信息归属原则

| 信息类型 | 归属位置 |
|----------|----------|
| 字段的含义、格式、默认值、枚举值 | 共用说明 或 类型定义 |
| 字段在具体工具中的约束（二选一、依赖） | 工具定义 |
| 字段如何获取（从哪个工具的返回值来） | 类型定义（通用来源）或工具定义（特定来源）|
| 多工具组合的使用顺序 | 常见工作流 |

---

## 五、示例参考

以 `get_feishu_folder_files` 为例，展示规范应用：

```markdown
### `get_feishu_folder_files`

列出文件夹或知识库节点下的文件列表。

**参数：**

- `folderToken`? string：云盘文件夹 token，如 `FWK2fMleClICfodlHHWc4Mygnhb`
- `wikiContext`? WikiContext

> `folderToken` 与 `wikiContext` 二选一，不可同时传。

**示例：**

\```bash
feishu-mcp-tool get_feishu_folder_files '{"folderToken":"FWK2xxxxx"}'
feishu-mcp-tool get_feishu_folder_files '{"wikiContext":{"spaceId":"7614920810658024396"}}'
\```
```