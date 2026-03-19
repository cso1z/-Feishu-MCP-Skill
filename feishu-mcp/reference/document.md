# feishu-mcp-tool — Document 模块参考

覆盖文件夹、文档、块、图片、白板相关全部 15 个工具。

---

## 共用说明

以下字段在多个工具中出现，含义一致：

- **`documentId`**：文档 ID 或普通文档 URL，支持 `https://xxx.feishu.cn/docx/xxx` 或直接传 token（如 `JcKbdlokYoPIe0xDzJ1cduRXnRf`）。⚠️ 不支持 Wiki URL，Wiki 需先调用 `get_feishu_document_info` 获取 documentId。
- **`parentBlockId`**：父块 ID，**必填，不可省略**。向文档**根级**写入时 `parentBlockId` = `documentId`（两者值完全相同）；操作嵌套块（如表格内）时传对应父块 ID。
- **`index`**：插入位置，0-based，标题块不计入。文档有 N 个内容块时有效值 0~N，N=追加末尾。

---

## 类型定义

### WikiContext

- `spaceId`* string：知识库空间 ID，从 `get_feishu_root_folder_info` 返回的 `wiki_spaces` 获取
- `parentNodeToken`? string：父节点 token，不传则从知识库根节点获取

### TextStyle

所有字段可选，只传需要改变的属性：

- `bold`? boolean：加粗
- `italic`? boolean：斜体
- `underline`? boolean：下划线
- `strikethrough`? boolean：删除线
- `inline_code`? boolean：行内代码
- `text_color`? number：文字颜色，0=黑(默认) 1=灰 2=棕 3=橙 4=黄 5=绿 6=蓝 7=紫
- `background_color`? number：文字背景色，1=灰 2=棕 3=橙 4=黄 5=绿 6=蓝 7=紫

### TextElement

以下两种之一：

- 普通文本：`text`* string（不含 markdown 语法），`style`? TextStyle
- 数学公式：`equation`* string（LaTeX 格式），`style`? TextStyle

### BlockConfig

- `blockType`* string：`text` \| `code` \| `heading` \| `list` \| `image` \| `mermaid` \| `whiteboard`
- `options`* object：key 必须与 blockType 完全一致

| blockType | options 结构 |
|-----------|-------------|
| `text` | `{text: {textStyles*: TextElement[], align?: 1\|2\|3}}` |
| `heading` | `{heading: {level*: 1~9, content*: string, align?: 1\|2\|3}}` |
| `code` | `{code: {code*: string, language?: number, wrap?: boolean}}` |
| `list` | `{list: {content*: string, isOrdered?: boolean, align?: 1\|2\|3}}` |
| `image` | `{image: {width?: number, height?: number}}` |
| `mermaid` | `{mermaid: {code*: string}}` |
| `whiteboard` | `{whiteboard: {align?: 1\|2\|3}}` |

`align`：1=左(默认) 2=居中 3=右（`whiteboard` 默认 2=居中）

`code.language` 常用值：1=纯文本(默认) 7=Bash 22=Go 29=Java 30=JavaScript 49=Python 52=Ruby 53=Rust 56=SQL 63=TypeScript 66=XML 67=YAML

`image`、`whiteboard` 创建空块，需后续工具填充内容。`mermaid` 中含特殊字符（`()[]-->`）的节点标签需用双引号包裹，如 `A["finish()"] --> B`。

---

## 工具列表

### `get_feishu_root_folder_info`

获取根文件夹 token、知识空间列表和我的知识库信息。无需参数。

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

**参数：**

- `folderToken`? string：云盘文件夹 token，如 `FWK2fMleClICfodlHHWc4Mygnhb`
- `wikiContext`? WikiContext

> `folderToken` 与 `wikiContext` 二选一，不可同时传。

```bash
feishu-mcp-tool get_feishu_folder_files '{"folderToken":"FWK2xxxxx"}'
feishu-mcp-tool get_feishu_folder_files '{"wikiContext":{"spaceId":"7614920810658024396"}}'
feishu-mcp-tool get_feishu_folder_files '{"wikiContext":{"spaceId":"7614920810658024396","parentNodeToken":"WikxxxYYY"}}'
```

---

### `create_feishu_folder`

> ⚠️ **仅适用于云盘文件夹，不支持知识库。** 知识库中不存在「文件夹」概念，**禁止**对知识库使用此工具。知识库创建节点请改用 `create_feishu_document` + `wikiContext`（知识库中文档即节点）。

在云盘指定文件夹下创建子文件夹。

**参数：**

- `folderToken`* string：父文件夹 token（云盘 token，如 `FWK2xxxxx`）
- `folderName`* string：新文件夹名称

```bash
feishu-mcp-tool create_feishu_folder '{"folderToken":"FWK2xxxxx","folderName":"2024项目"}'
```

---

### `create_feishu_document`

在云盘文件夹或知识库中创建新文档。

> **知识库中，文档 = 节点**（无单独的「创建节点」工具）。返回 `node_token`（可作为子节点的 `parentNodeToken`，用于在其下继续创建子文档/子节点）和 `obj_token`（等同于 `documentId`，用于写入文档内容）。**需要在知识库中建节点树，请反复调用本工具并传递 `parentNodeToken`，不要使用 `create_feishu_folder`。**

**参数：**

- `title`* string：文档标题
- `folderToken`? string：云盘文件夹 token
- `wikiContext`? WikiContext

> `folderToken` 与 `wikiContext` 二选一，不可同时传。

```bash
feishu-mcp-tool create_feishu_document '{"title":"需求文档","folderToken":"FWK2xxxxx"}'
feishu-mcp-tool create_feishu_document '{"title":"需求文档","wikiContext":{"spaceId":"7614920810658024396","parentNodeToken":"WikxxxYYY"}}'
```

---

### `get_feishu_document_info`

获取文档或知识库节点的元数据（标题、类型、创建时间等）。Wiki 文档返回 `documentId`（obj_token，用于编辑）、`space_id` 和 `node_token`（用于创建子节点）。

**参数：**

- `documentId`* string：文档 ID/URL 或 Wiki ID/URL，支持 `https://xxx.feishu.cn/docx/xxx`、`https://xxx.feishu.cn/wiki/xxx`、或直接传 token
- `documentType`? string：`document`（普通文档）\| `wiki`（知识库文档）

```bash
feishu-mcp-tool get_feishu_document_info '{"documentId":"Uk6mdN6Hao5umbxC13ccGstonIh"}'
feishu-mcp-tool get_feishu_document_info '{"documentId":"https://xxx.feishu.cn/wiki/xxxxx","documentType":"wiki"}'
```

---

### `get_feishu_document_blocks`

获取文档的完整块结构（文本、标题、代码、图片、表格等）。

**参数：**

- `documentId`* → 见共用说明

```bash
feishu-mcp-tool get_feishu_document_blocks '{"documentId":"Uk6mdN6Hao5umbxC13ccGstonIh"}'
```

---

### `search_feishu_documents`

搜索飞书文档和/或知识库节点。每种类型最多返回 100 条，默认每页 20 条。

**参数：**

- `searchKey`* string：搜索关键词
- `searchType`? string：`document` \| `wiki` \| `both`（默认）
- `offset`? number：普通文档分页偏移量，首次不传，翻页时传上次返回值
- `pageToken`? string：知识库分页 token，首次不传，翻页时传上次返回值

```bash
feishu-mcp-tool search_feishu_documents '{"searchKey":"需求评审"}'
feishu-mcp-tool search_feishu_documents '{"searchKey":"项目方案","searchType":"wiki"}'
```

---

### `batch_create_feishu_blocks`

在文档指定位置批量创建块。

> ⚠️ `parentBlockId` **必须明确传入，不可省略**（即便只操作根级也不例外）。向文档根级写入时，`parentBlockId` = `documentId`（两者值完全相同）。`create_feishu_document` 或 `get_feishu_document_info` 返回的 `obj_token` 即为文档的 `documentId`。

**参数：**

- `documentId`* → 见共用说明
- `parentBlockId`* → 见共用说明（根级写入时 = documentId）
- `index`* → 见共用说明
- `blocks`* BlockConfig[]

```bash
# 向文档根级写入块（parentBlockId = documentId，两者值相同）
feishu-mcp-tool batch_create_feishu_blocks '{
  "documentId": "Uk6mdN6Hao5umbxC13ccGstonIh",
  "parentBlockId": "Uk6mdN6Hao5umbxC13ccGstonIh",
  "index": 0,
  "blocks": [
    {"blockType":"heading","options":{"heading":{"level":1,"content":"项目概述"}}},
    {"blockType":"text","options":{"text":{"textStyles":[{"text":"说明文字"},{"text":"加粗部分","style":{"bold":true}}]}}},
    {"blockType":"code","options":{"code":{"code":"npm install feishu-mcp","language":7}}}
  ]
}'
```

---

### `batch_update_feishu_block_text`

批量更新文档块的文本内容和行内样式（整块替换）。

> ⚠️ **字段名区分**：本工具更新字段为 **`textElements`**（TextElement 数组），与 `batch_create_feishu_blocks` 中 text 块 options 里的 `textStyles` **不同**，切勿混用。
>
> ⚠️ **表格单元格更新**：更新表格单元格内容时，`blockId` 必须是单元格**子块**（children[0]）的 ID，而非单元格容器块本身。可先调用 `get_feishu_document_blocks` 查看单元格的 `children` 数组取到子块 ID。

**参数：**

- `documentId`* → 见共用说明
- `updates`* array（至少 1 项）：
  - `blockId`* string：目标块 ID（表格单元格需用子块 ID，见上方警告）
  - `textElements`* TextElement[]（非 textStyles）

```bash
feishu-mcp-tool batch_update_feishu_block_text '{
  "documentId": "Uk6mdN6Hao5umbxC13ccGstonIh",
  "updates": [
    {
      "blockId": "doxcnpIWdCpmEg5sUx00hr27lXe",
      "textElements": [
        {"text":"重要提示：","style":{"bold":true}},
        {"text":"请及时更新文档内容。"}
      ]
    }
  ]
}'
```

---

### `delete_feishu_document_blocks`

删除文档中指定范围的块，范围为 [startIndex, endIndex)（startIndex 含，endIndex 不含）。

**参数：**

- `documentId`* → 见共用说明
- `parentBlockId`* → 见共用说明
- `startIndex`* integer：起始索引，0-based，标题块不计入
- `endIndex`* integer：结束索引（不含），必须 > startIndex。删除位置 2、3、4 → startIndex=2, endIndex=5；仅删除位置 2 → startIndex=2, endIndex=3

```bash
feishu-mcp-tool delete_feishu_document_blocks '{
  "documentId": "Uk6mdN6Hao5umbxC13ccGstonIh",
  "parentBlockId": "Uk6mdN6Hao5umbxC13ccGstonIh",
  "startIndex": 0,
  "endIndex": 1
}'
```

---

### `create_feishu_table`

在文档指定位置插入表格。

> ⚠️ 行列数嵌套在 `tableConfig` 对象内，字段名为 **`rowSize`** / **`columnSize`**，不是 `rows`/`cols`。
>
> ⚠️ **更新单元格内容**：表格创建后，每个单元格容器（block_type=32）内有一个文本子块（children[0]）。调用 `batch_update_feishu_block_text` 时，`blockId` 应传该**子块 ID**，而非单元格容器 ID（否则报错 1770025）。

**参数：**

- `documentId`* → 见共用说明
- `parentBlockId`* → 见共用说明
- `index`* → 见共用说明
- `tableConfig`* object：
  - `rowSize`* number：行数（≥1）
  - `columnSize`* number：列数（≥1）
  - `cells`? array：单元格内容配置，不传则所有单元格为空文本块，每项：
    - `coordinate`* object：`{row*: number, column*: number}`，0-based
    - `content`* BlockConfig：单元格内容块，同一坐标多项则顺序追加

```bash
feishu-mcp-tool create_feishu_table '{
  "documentId": "Uk6mdN6Hao5umbxC13ccGstonIh",
  "parentBlockId": "Uk6mdN6Hao5umbxC13ccGstonIh",
  "index": 0,
  "tableConfig": {
    "rowSize": 3,
    "columnSize": 2,
    "cells": [
      {"coordinate":{"row":0,"column":0},"content":{"blockType":"text","options":{"text":{"textStyles":[{"text":"姓名","style":{"bold":true}}]}}}},
      {"coordinate":{"row":0,"column":1},"content":{"blockType":"text","options":{"text":{"textStyles":[{"text":"职位","style":{"bold":true}}]}}}}
    ]
  }
}'
```

---

### `get_feishu_image_resource`

下载图片资源，返回 base64 编码数据。

**参数：**

- `mediaId`* string：图片媒体 token，来源：`get_feishu_document_blocks` 返回的图片块（block_type=27）中的 `block.image.token`
- `extra`? string：加密图片的额外参数，普通图片块可省略

```bash
feishu-mcp-tool get_feishu_image_resource '{"mediaId":"IN3QbYHQWoijZgxjkOzcpQcPnOB"}'
```

---

### `upload_and_bind_image_to_block`

批量上传图片并绑定到文档已有的空图片块。需先用 `batch_create_feishu_blocks` 创建 `image` 类型块。

**参数：**

- `documentId`* → 见共用说明
- `images`* array：
  - `blockId`* string：目标图片块 ID
  - `imagePathOrUrl`* string：本地绝对路径（如 `/tmp/image.png`）或 HTTP/HTTPS URL
  - `fileName`? string：文件名含扩展名（如 `image.png`），不传则自动生成

```bash
feishu-mcp-tool upload_and_bind_image_to_block '{
  "documentId": "Uk6mdN6Hao5umbxC13ccGstonIh",
  "images": [
    {"blockId":"doxcnkLUSCAZrcWDz5Cj6oKSbQh","imagePathOrUrl":"https://example.com/chart.png"},
    {"blockId":"doxcnkLUSCAZrcWDz5Cj6oKSbQi","imagePathOrUrl":"/tmp/screenshot.png","fileName":"screenshot.png"}
  ]
}'
```

---

### `get_feishu_whiteboard_content`

获取白板的节点结构和内容数据。

**参数：**

- `whiteboardId`* string：白板 token，从文档块（block_type=43）的 `board.token` 获取

```bash
feishu-mcp-tool get_feishu_whiteboard_content '{"whiteboardId":"EPJKwvY5ghe3pVbKj9RcT2msnBX"}'
```

---

### `fill_whiteboard_with_plantuml`

批量将 PlantUML 或 Mermaid 图表填充到白板块中。

**参数：**

- `whiteboards`* array：
  - `whiteboardId`* string：白板 token，从 `batch_create_feishu_blocks` 创建白板块的返回值 `board.token` 获取
  - `code`* string：图表代码（PlantUML 或 Mermaid 格式）
  - `syntax_type`* string：`plantuml` \| `mermaid`

```bash
feishu-mcp-tool fill_whiteboard_with_plantuml '{
  "whiteboards": [
    {
      "whiteboardId": "EPJKwvY5ghe3pVbKj9RcT2msnBX",
      "code": "@startuml\nAlice -> Bob: 请求\nBob --> Alice: 响应\n@enduml",
      "syntax_type": "plantuml"
    }
  ]
}'
```

---

## 常见工作流

### 工作流 1：创建文档并填充结构化内容

```bash
# 1. 获取根文件夹 token
feishu-mcp-tool get_feishu_root_folder_info

# 2. 创建文档
feishu-mcp-tool create_feishu_document '{"title":"项目方案","folderToken":"<root_token>"}'

# 3. 批量插入内容块
feishu-mcp-tool batch_create_feishu_blocks '{
  "documentId": "<doc_id>",
  "parentBlockId": "<doc_id>",
  "index": 0,
  "blocks": [
    {"blockType":"heading","options":{"heading":{"level":1,"content":"背景"}}},
    {"blockType":"text","options":{"text":{"textStyles":[{"text":"项目背景说明..."}]}}},
    {"blockType":"code","options":{"code":{"code":"// 核心代码","language":63}}}
  ]
}'
```

---

### 工作流 2：搜索文档并更新指定块

```bash
# 1. 搜索目标文档
feishu-mcp-tool search_feishu_documents '{"searchKey":"项目方案","searchType":"document"}'

# 2. 读取文档块结构，找到目标 blockId
feishu-mcp-tool get_feishu_document_blocks '{"documentId":"<doc_id>"}'

# 3. 更新目标块文本
feishu-mcp-tool batch_update_feishu_block_text '{
  "documentId": "<doc_id>",
  "updates": [{"blockId":"<block_id>","textElements":[{"text":"更新后的内容"}]}]
}'
```

---

### 工作流 3：在文档中插入图片

```bash
# 1. 创建空图片块，获取返回的 blockId
feishu-mcp-tool batch_create_feishu_blocks '{
  "documentId": "<doc_id>",
  "parentBlockId": "<doc_id>",
  "index": 0,
  "blocks": [{"blockType":"image","options":{"image":{}}}]
}'

# 2. 上传图片并绑定
feishu-mcp-tool upload_and_bind_image_to_block '{
  "documentId": "<doc_id>",
  "images": [{"blockId":"<image_block_id>","imagePathOrUrl":"https://example.com/diagram.png"}]
}'
```

---

### 工作流 4：用 PlantUML 填充白板

```bash
# 1. 创建白板块，获取返回的 board.token
feishu-mcp-tool batch_create_feishu_blocks '{
  "documentId": "<doc_id>",
  "parentBlockId": "<doc_id>",
  "index": 0,
  "blocks": [{"blockType":"whiteboard","options":{"whiteboard":{}}}]
}'

# 2. 填充图表
feishu-mcp-tool fill_whiteboard_with_plantuml '{
  "whiteboards": [{
    "whiteboardId": "<board_token>",
    "code": "@startuml\nA -> B: 调用\nB --> A: 返回\n@enduml",
    "syntax_type": "plantuml"
  }]
}'
```

---

### 工作流 5：在知识库中创建节点树

> 知识库中**文档 = 节点**，禁止使用 `create_feishu_folder`。通过 `parentNodeToken` 链式调用 `create_feishu_document` 构建层级结构。

```bash
# 1. 获取知识库 spaceId
feishu-mcp-tool get_feishu_root_folder_info
# 返回示例：{"wiki_spaces":[{"id":"7593969969780509915","name":"团队知识库"}]}

# 2. 在知识库根节点下创建父节点（文档即节点）
feishu-mcp-tool create_feishu_document '{
  "title": "Q2 项目规划",
  "wikiContext": {"spaceId": "7593969969780509915"}
}'
# 返回示例：{"node_token":"WikXxxParent","obj_token":"docXxxParent"}

# 3. 在父节点下创建子节点（传 parentNodeToken = 上一步 node_token）
feishu-mcp-tool create_feishu_document '{
  "title": "技术方案",
  "wikiContext": {
    "spaceId": "7593969969780509915",
    "parentNodeToken": "WikXxxParent"
  }
}'
# 返回示例：{"node_token":"WikXxxChild","obj_token":"docXxxChild"}

# 4. 向子节点文档写入内容（obj_token 即 documentId，parentBlockId = obj_token）
feishu-mcp-tool batch_create_feishu_blocks '{
  "documentId": "docXxxChild",
  "parentBlockId": "docXxxChild",
  "index": 0,
  "blocks": [
    {"blockType":"heading","options":{"heading":{"level":1,"content":"技术方案概述"}}},
    {"blockType":"text","options":{"text":{"textStyles":[{"text":"本方案描述..."}]}}}
  ]
}'
```

---

### 工作流 6：新建文档并写入内容（parentBlockId = obj_token）

> `create_feishu_document` 返回的 `obj_token`（知识库）或 `documentId`（云盘）即为写块时的 `documentId` 和根级 `parentBlockId`。

```bash
# 1. 创建文档
feishu-mcp-tool create_feishu_document '{"title":"架构设计","folderToken":"FWK2xxxxx"}'
# 返回：{"documentId":"NewDocId","..."}

# 2. 写入块（documentId = parentBlockId = 上一步的 documentId / obj_token）
feishu-mcp-tool batch_create_feishu_blocks '{
  "documentId": "NewDocId",
  "parentBlockId": "NewDocId",
  "index": 0,
  "blocks": [
    {"blockType":"heading","options":{"heading":{"level":1,"content":"整体架构"}}},
    {"blockType":"text","options":{"text":{"textStyles":[{"text":"系统分为前端、后端、数据层..."}]}}}
  ]
}'
```