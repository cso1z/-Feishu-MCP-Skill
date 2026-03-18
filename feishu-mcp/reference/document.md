# feishu-mcp-tool — Document 模块参考

覆盖文件夹、文档、块、图片、白板相关全部 15 个工具。

---

## 文件夹工具

### `get_feishu_root_folder_info`

获取根文件夹 token、知识空间列表和我的知识库信息。

无需参数。

```bash
feishu-mcp-tool get_feishu_root_folder_info
```

返回示例：
```json
{
  "root_folder": {"token": "FWK2xxxxx", "id": "0"},
  "wiki_spaces": [{"id": "7614920810658024396", "name": "团队知识库"}],
  "my_wiki": {"spaceId": "xxx", "nodeToken": "xxx"}
}
```

---

### `get_feishu_folder_files`

列出文件夹或知识库节点下的文件列表。

| 参数 | 类型 | 必填 | 含义 |
|------|------|------|------|
| `folderToken` | string | 否* | 云盘文件夹 token |
| `wikiSpaceId` | string | 否* | 知识库空间 ID |
| `wikiNodeToken` | string | 否* | 知识库节点 token |

*`folderToken` 与 `wikiSpaceId`+`wikiNodeToken` 二选一。

```bash
# 云盘文件夹
feishu-mcp-tool get_feishu_folder_files '{"folderToken":"FWK2xxxxx"}'

# 知识库节点
feishu-mcp-tool get_feishu_folder_files '{"wikiSpaceId":"7614920810658024396","wikiNodeToken":"WikxxxYYY"}'
```

---

### `create_feishu_folder`

在指定文件夹下创建子文件夹。

| 参数 | 类型 | 必填 | 含义 |
|------|------|------|------|
| `folderToken` | string | 是 | 父文件夹 token |
| `folderName` | string | 是 | 新文件夹名称 |

```bash
feishu-mcp-tool create_feishu_folder '{"folderToken":"FWK2xxxxx","folderName":"2024项目"}'
```

---

## 文档工具

### `create_feishu_document`

在云盘文件夹或知识库中创建新文档。

| 参数 | 类型 | 必填 | 含义 |
|------|------|------|------|
| `title` | string | 是 | 文档标题 |
| `folderToken` | string | 否* | 云盘文件夹 token |
| `wikiContext` | object | 否* | 知识库上下文（见下）|
| `wikiContext.spaceId` | string | 否 | 知识库空间 ID |
| `wikiContext.parentNodeToken` | string | 否 | 父节点 token |

*`folderToken` 与 `wikiContext` 二选一。

```bash
# 云盘模式
feishu-mcp-tool create_feishu_document '{"title":"需求文档","folderToken":"FWK2xxxxx"}'

# 知识库模式
feishu-mcp-tool create_feishu_document '{"title":"需求文档","wikiContext":{"spaceId":"7614920810658024396","parentNodeToken":"WikxxxYYY"}}'
```

---

### `get_feishu_document_info`

获取文档元数据（标题、token、类型、创建/修改时间等）。

| 参数 | 类型 | 必填 | 含义 |
|------|------|------|------|
| `documentId` | string | 是 | 文档 token、URL 或飞书文档链接 |

```bash
feishu-mcp-tool get_feishu_document_info '{"documentId":"Uk6mdN6Hao5umbxC13ccGstonIh"}'
```

---

### `get_feishu_document_blocks`

获取文档的完整块结构（文本、标题、代码、图片、表格等）。图片块返回 mediaId，白板块返回 whiteboardId 提示。

| 参数 | 类型 | 必填 | 含义 |
|------|------|------|------|
| `documentId` | string | 是 | 文档 token 或 URL |

```bash
feishu-mcp-tool get_feishu_document_blocks '{"documentId":"Uk6mdN6Hao5umbxC13ccGstonIh"}'
```

---

### `search_feishu_documents`

搜索飞书文档和/或知识库。

| 参数 | 类型 | 必填 | 含义 |
|------|------|------|------|
| `query` | string | 是 | 搜索关键词 |
| `searchType` | string | 否 | `"doc"` / `"wiki"` / `"both"`（默认 `"both"`）|

```bash
feishu-mcp-tool search_feishu_documents '{"query":"需求评审","searchType":"both"}'
```

---

## 块操作工具

### `batch_create_feishu_blocks`

在文档中批量创建块，支持文本、标题、代码、有序/无序列表、图片、Mermaid、白板等类型。

| 参数 | 类型 | 必填 | 含义 |
|------|------|------|------|
| `documentId` | string | 是 | 目标文档 token |
| `parentBlockId` | string | 是 | 父块 ID（通常与 documentId 相同表示文档根）|
| `index` | number | 是 | 插入位置（0 = 第一个子块之前）|
| `blocks` | array | 是 | 块定义数组（见下）|

**blocks 数组元素结构**：

| 字段 | 类型 | 必填 | 含义 |
|------|------|------|------|
| `blockType` | string | 是 | 块类型：`text` / `heading` / `code` / `bullet` / `ordered` / `image` / `mermaid` / `whiteboard` |
| `options` | object | 否 | 块的具体内容（因类型而异，见下）|

**options 按 blockType 说明**：

- `text`：`{"text":"内容","bold":true,"italic":false}`
- `heading`：`{"text":"标题","level":1}` （level 1-9）
- `code`：`{"text":"代码内容","language":"JavaScript"}`
- `bullet` / `ordered`：`{"text":"列表项"}`
- `image`：`{}` （创建空图片块，后续用 upload_and_bind_image_to_block 填充）
- `mermaid`：`{"text":"graph TD\nA-->B"}`
- `whiteboard`：`{}` （创建空白板块）

```bash
feishu-mcp-tool batch_create_feishu_blocks '{
  "documentId": "Uk6mdN6Hao5umbxC13ccGstonIh",
  "parentBlockId": "Uk6mdN6Hao5umbxC13ccGstonIh",
  "index": 0,
  "blocks": [
    {"blockType": "heading", "options": {"text": "项目概述", "level": 1}},
    {"blockType": "text", "options": {"text": "本文档描述项目背景和目标。"}},
    {"blockType": "code", "options": {"text": "npm install feishu-mcp", "language": "Bash"}}
  ]
}'
```

---

### `batch_update_feishu_block_text`

批量更新块的文本内容和行内样式。

| 参数 | 类型 | 必填 | 含义 |
|------|------|------|------|
| `documentId` | string | 是 | 文档 token |
| `updates` | array | 是 | 更新项数组 |
| `updates[].blockId` | string | 是 | 目标块 ID |
| `updates[].textElements` | array | 是 | 文本元素数组 |
| `updates[].textElements[].text` | string | 是 | 文本内容 |
| `updates[].textElements[].bold` | boolean | 否 | 加粗 |
| `updates[].textElements[].italic` | boolean | 否 | 斜体 |
| `updates[].textElements[].strikethrough` | boolean | 否 | 删除线 |
| `updates[].textElements[].underline` | boolean | 否 | 下划线 |
| `updates[].textElements[].inlineCode` | boolean | 否 | 行内代码 |
| `updates[].textElements[].textColor` | string | 否 | 文字颜色 |

```bash
feishu-mcp-tool batch_update_feishu_block_text '{
  "documentId": "Uk6mdN6Hao5umbxC13ccGstonIh",
  "updates": [
    {
      "blockId": "doxcnpIWdCpmEg5sUx00hr27lXe",
      "textElements": [
        {"text": "重要提示：", "bold": true},
        {"text": "请及时更新文档内容。", "italic": true}
      ]
    }
  ]
}'
```

---

### `delete_feishu_document_blocks`

删除文档中指定范围的块（按父块下的子块索引范围）。

| 参数 | 类型 | 必填 | 含义 |
|------|------|------|------|
| `documentId` | string | 是 | 文档 token |
| `parentBlockId` | string | 是 | 父块 ID |
| `startIndex` | number | 是 | 起始索引（含，从 0 开始）|
| `endIndex` | number | 是 | 结束索引（含）|

```bash
# 删除根块下第 0 到第 2 个子块（共 3 个块）
feishu-mcp-tool delete_feishu_document_blocks '{
  "documentId": "Uk6mdN6Hao5umbxC13ccGstonIh",
  "parentBlockId": "Uk6mdN6Hao5umbxC13ccGstonIh",
  "startIndex": 0,
  "endIndex": 2
}'
```

---

### `create_feishu_table`

在文档指定位置插入表格。

| 参数 | 类型 | 必填 | 含义 |
|------|------|------|------|
| `documentId` | string | 是 | 文档 token |
| `parentBlockId` | string | 是 | 父块 ID |
| `index` | number | 否 | 插入位置（默认末尾）|
| `tableConfig` | object | 是 | 表格配置 |
| `tableConfig.rowSize` | number | 是 | 行数 |
| `tableConfig.columnSize` | number | 是 | 列数 |

```bash
feishu-mcp-tool create_feishu_table '{
  "documentId": "Uk6mdN6Hao5umbxC13ccGstonIh",
  "parentBlockId": "Uk6mdN6Hao5umbxC13ccGstonIh",
  "tableConfig": {"rowSize": 4, "columnSize": 3}
}'
```

---

## 图片工具

### `get_feishu_image_resource`

下载图片资源，返回 Buffer（含 base64 编码数据）。通常配合 `get_feishu_document_blocks` 获取的 `mediaId` 使用。

| 参数 | 类型 | 必填 | 含义 |
|------|------|------|------|
| `mediaId` | string | 是 | 图片媒体 ID（从文档块中获取）|
| `extra` | string | 否 | 额外参数（通常为空字符串）|

```bash
feishu-mcp-tool get_feishu_image_resource '{"mediaId":"IN3QbYHQWoijZgxjkOzcpQcPnOB","extra":""}'
# 返回：{"type":"Buffer","data":[137,80,78,...]}
```

---

### `upload_and_bind_image_to_block`

上传本地图片文件或网络图片 URL，并绑定到文档中已有的图片块。

| 参数 | 类型 | 必填 | 含义 |
|------|------|------|------|
| `documentId` | string | 是 | 文档 token |
| `blockId` | string | 是 | 目标图片块 ID |
| `imageSource` | string | 是 | 图片来源：本地文件路径或 URL |
| `sourceType` | string | 是 | `"file"` （本地文件）或 `"url"` （网络图片）|

```bash
# 上传网络图片
feishu-mcp-tool upload_and_bind_image_to_block '{
  "documentId": "Uk6mdN6Hao5umbxC13ccGstonIh",
  "blockId": "doxcnkLUSCAZrcWDz5Cj6oKSbQh",
  "imageSource": "https://example.com/chart.png",
  "sourceType": "url"
}'

# 上传本地文件
feishu-mcp-tool upload_and_bind_image_to_block '{
  "documentId": "Uk6mdN6Hao5umbxC13ccGstonIh",
  "blockId": "doxcnkLUSCAZrcWDz5Cj6oKSbQh",
  "imageSource": "/tmp/screenshot.png",
  "sourceType": "file"
}'
```

---

## 白板工具

### `get_feishu_whiteboard_content`

获取白板的节点结构和内容数据。

| 参数 | 类型 | 必填 | 含义 |
|------|------|------|------|
| `whiteboardId` | string | 是 | 白板 ID（从文档块中获取）|

```bash
feishu-mcp-tool get_feishu_whiteboard_content '{"whiteboardId":"W3BXxxxxx"}'
```

---

### `fill_whiteboard_with_plantuml`

将 PlantUML 或 Mermaid 图表渲染后填充到白板中。

| 参数 | 类型 | 必填 | 含义 |
|------|------|------|------|
| `whiteboardId` | string | 是 | 白板 ID |
| `plantumlContent` | string | 是 | PlantUML 或 Mermaid 图表源码 |

```bash
feishu-mcp-tool fill_whiteboard_with_plantuml '{
  "whiteboardId": "W3BXxxxxx",
  "plantumlContent": "@startuml\nactor User\nUser -> Server: 请求\nServer --> User: 响应\n@enduml"
}'
```

---

## 常见工作流

### 工作流 1：创建文档并填充结构化内容

```bash
# 1. 获取根文件夹 token
feishu-mcp-tool get_feishu_root_folder_info

# 2. 创建文档（使用上一步返回的 root_folder.token）
feishu-mcp-tool create_feishu_document '{"title":"项目方案","folderToken":"<root_token>"}'

# 3. 批量插入内容块（使用上一步返回的 documentId）
feishu-mcp-tool batch_create_feishu_blocks '{
  "documentId": "<doc_id>",
  "parentBlockId": "<doc_id>",
  "index": 0,
  "blocks": [
    {"blockType": "heading", "options": {"text": "背景", "level": 1}},
    {"blockType": "text", "options": {"text": "项目背景说明..."}},
    {"blockType": "heading", "options": {"text": "方案设计", "level": 1}},
    {"blockType": "code", "options": {"text": "// 核心代码", "language": "TypeScript"}}
  ]
}'
```

---

### 工作流 2：搜索文档并更新指定块内容

```bash
# 1. 搜索目标文档
feishu-mcp-tool search_feishu_documents '{"query":"项目方案","searchType":"doc"}'

# 2. 读取文档块结构（找到需要更新的 blockId）
feishu-mcp-tool get_feishu_document_blocks '{"documentId":"<doc_id>"}'

# 3. 更新目标块文本
feishu-mcp-tool batch_update_feishu_block_text '{
  "documentId": "<doc_id>",
  "updates": [{"blockId": "<block_id>", "textElements": [{"text": "更新后的内容"}]}]
}'
```

---

### 工作流 3：在文档中插入图片

```bash
# 1. 创建空图片块
feishu-mcp-tool batch_create_feishu_blocks '{
  "documentId": "<doc_id>",
  "parentBlockId": "<doc_id>",
  "index": 0,
  "blocks": [{"blockType": "image"}]
}'

# 2. 上传图片并绑定到刚创建的图片块（使用上一步返回的 blockId）
feishu-mcp-tool upload_and_bind_image_to_block '{
  "documentId": "<doc_id>",
  "blockId": "<image_block_id>",
  "imageSource": "https://example.com/diagram.png",
  "sourceType": "url"
}'
```

---

### 工作流 4：用 PlantUML 填充文档白板

```bash
# 1. 在文档中创建白板块
feishu-mcp-tool batch_create_feishu_blocks '{
  "documentId": "<doc_id>",
  "parentBlockId": "<doc_id>",
  "index": 0,
  "blocks": [{"blockType": "whiteboard"}]
}'

# 2. 获取文档块找到 whiteboardId
feishu-mcp-tool get_feishu_document_blocks '{"documentId":"<doc_id>"}'

# 3. 填充 PlantUML 图表
feishu-mcp-tool fill_whiteboard_with_plantuml '{
  "whiteboardId": "<whiteboard_id>",
  "plantumlContent": "@startuml\nA -> B: 调用\nB --> A: 返回\n@enduml"
}'
```
