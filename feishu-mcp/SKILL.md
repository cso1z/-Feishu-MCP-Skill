---
version: 1.3.0
description: 使用 feishu-tool CLI 操作飞书文档、任务、用户等资源。当用户需要读写飞书（创建/查询/更新/删除文档、块、任务、文件夹、用户）时调用此 skill。
argument-hint: "[tool-name] [json-params]"
allowed-tools: Read, Bash(feishu-tool *), Bash(command -v feishu-tool), Bash(npm install -g feishu-mcp@latest), Bash(node -e *)
parameters:
  - name: tool_name
    type: string
    required: false
    description: 工具名称，如 get_feishu_root_folder_info、create_feishu_document 等
  - name: json_params
    type: string
    required: false
    default: "{}"
    description: 工具参数，JSON 字符串格式
---

# feishu-tool CLI

命令行工具，支持直接调用全部飞书 MCP 工具。专为 LLM Agent 设计：参数以 JSON 传入，日志和授权提示输出到 stderr。

> ⚠️ **stdout 纯净性说明**：大多数工具以纯 JSON 输出到 stdout；但 `get_feishu_document_blocks` 在检测到图片块（block_type=27）或白板块时，会在 JSON 数组末尾追加非 JSON 提示文本（emoji 行）。**不要将该工具的输出直接 pipe 给 JSON 解析器**，应先将结果保存到变量，再截取到最后一个 `]` 为止，或用 `node -e` 提取所需字段。

## 执行流程

每次调用前，按以下顺序检查，任一步骤不满足则停止并提示用户：

### 第一步：检查命令是否可用

```bash
feishu-tool --help
```

- **有输出**：继续下一步
- **报错 / 命令未找到**：自动执行安装，**停止执行后续步骤**：

```bash
npm install -g feishu-mcp@latest
```

安装完成后重新从第一步开始。

### 第二步：检查是否已完成初始化配置

```bash
feishu-tool config
```

- 若 `FEISHU_APP_ID` 或 `FEISHU_APP_SECRET` 为 `(未设置)`：调用 `feishu-tool guide` 并提示用户按指南完成初始化，**停止执行**
- 配置就绪：继续下一步

### 第三步（仅 user 模式）：检查授权状态

若 `FEISHU_AUTH_TYPE` 为 `user`，执行：

```bash
feishu-tool auth
```

| 状态 | 操作 |
|------|------|
| `isValid: true` | token 有效，直接执行目标工具 |
| `isValid: false, canRefresh: true` | SDK 内部自动刷新，直接执行目标工具，无需告知用户 |
| `isValid: false, canRefresh: false` | token 不存在或彻底过期，**告知用户**后继续执行（工具内部自动触发浏览器授权）：|

```
需要飞书用户授权。即将调用工具，程序会自动打开浏览器授权页，
请在 5 分钟内完成授权后结果将自动返回。
```

---

## 配置管理

### 初次配置（推荐方式）

```bash
# 查看配置指南（同时打开详细文档页面）
feishu-tool guide

# 逐项写入配置（保存到 ~/.cache/feishu-mcp/.env，全局生效）
feishu-tool config set FEISHU_APP_ID <your-app-id>
feishu-tool config set FEISHU_APP_SECRET <your-app-secret>
feishu-tool config set FEISHU_AUTH_TYPE tenant   # 或 user
feishu-tool config set FEISHU_ENABLED_MODULES document  # 或 all
```

> 配置写入 `~/.cache/feishu-mcp/.env`，对所有项目全局生效，无需在每个项目单独创建 `.env`。

### 查看当前配置

```bash
feishu-tool config
```

### 可配置项（不确定时可先执行 `feishu-tool config set` 查看说明）

```bash
feishu-tool config set   # 不带参数：显示所有可用 KEY 及含义
```

| 变量 | 必填 | 说明 | 示例 |
|------|------|------|------|
| `FEISHU_APP_ID` | ✅ | 飞书应用 ID | `cli_xxxxx` |
| `FEISHU_APP_SECRET` | ✅ | 飞书应用密钥 | `xxxxx` |
| `FEISHU_AUTH_TYPE` | 否 | 认证模式：`tenant`（默认）或 `user`（需 OAuth）| `tenant` |
| `FEISHU_ENABLED_MODULES` | 否 | 启用模块：`document`/`task`/`member`/`all`，默认 `document` | `all` |

---

## 调用格式

```bash
feishu-tool <tool-name> '<json-params>'
feishu-tool <tool-name>          # 无参数工具可省略第二个参数
```

- **stdout**：工具执行结果（JSON）
- **stderr**：日志与认证提示（不影响结果解析）
- **exit 0**：成功；**exit 1**：失败，stdout 输出 `{"error":"..."}`

### 动态获取当前可用工具列表

```bash
feishu-tool --help
```

返回当前 `authType` 下实际可用的工具列表及子命令说明。`tenant` 模式下 task/member 工具不可用，`toolsNote` 字段会说明原因。

---

## 使用场景

- **文档管理**：在飞书云盘或知识库中创建、读取、编辑文档内容（文本、标题、代码块、图片、表格、白板）
- **任务跟踪**：创建带子任务的任务、分配负责人、更新进度、批量删除（需 `FEISHU_AUTH_TYPE=user`）
- **用户查询**：按姓名搜索用户或按 open_id 批量获取用户信息（需 `FEISHU_AUTH_TYPE=user`）

---

## 工具速查

> **调用任何工具前，必须先读取对应模块的参考文档**，确认参数签名后再执行：
> - Document 模块 → `feishu-mcp/reference/document.md`
> - Task 模块 → `feishu-mcp/reference/task.md`
> - Member 模块 → `feishu-mcp/reference/member.md`
>
> 若参考文档中对某工具的使用场景或入参定义描述不足，可通过以下命令获取更详细的定义：
> ```bash
> feishu-tool help <tool-name>
> ```
>
> 下表仅供选择工具用，不含完整参数。实际可用工具以 `feishu-tool --help` 为准（受 `authType` 影响）。

### Document 模块（tenant + user 均可用，共 15 个）

| 工具名 | 用途 |
|--------|------|
| `get_feishu_root_folder_info` | 获取根文件夹、知识空间列表和我的知识库 |
| `get_feishu_folder_files` | 列出文件夹或知识库节点下的文件 |
| `create_feishu_folder` | 在云盘文件夹下创建子文件夹 |
| `create_feishu_document` | 在云盘或知识库中创建文档 |
| `get_feishu_document_info` | 获取文档元数据（标题、token、类型等）|
| `get_feishu_document_blocks` | 获取文档的完整块结构和内容 |
| `batch_create_feishu_blocks` | 在文档中批量创建块（文本/标题/代码/图片/表格等）|
| `batch_update_feishu_block_text` | 批量更新块的文本内容和样式 |
| `delete_feishu_document_blocks` | 删除文档中指定范围的块 |
| `create_feishu_table` | 在文档中创建表格 |
| `get_feishu_image_resource` | 下载图片资源，返回 base64 数据 |
| `upload_and_bind_image_to_block` | 上传本地或 URL 图片并绑定到图片块 |
| `search_feishu_documents` | 搜索飞书文档和/或知识库 |
| `get_feishu_whiteboard_content` | 获取白板节点结构和内容 |
| `fill_whiteboard_with_plantuml` | 用 PlantUML/Mermaid 图表填充白板 |

### Task 模块（仅 `FEISHU_AUTH_TYPE=user`，共 4 个）

| 工具名 | 用途 |
|--------|------|
| `list_feishu_tasks` | 列出当前用户负责的任务（支持分页）|
| `create_feishu_task` | 批量创建任务（支持嵌套子任务）|
| `update_feishu_task` | 更新任务字段（标题/描述/截止时间/完成状态/成员）|
| `delete_feishu_task` | 批量删除任务 |

### Member 模块（仅 `FEISHU_AUTH_TYPE=user`，共 1 个）

| 工具名 | 用途 |
|--------|------|
| `get_feishu_users` | 按名称搜索或按 ID 批量获取用户信息 |

---

## 快速示例

```bash
# 获取根文件夹（无需参数）
feishu-tool get_feishu_root_folder_info

# 在根文件夹下创建文档
feishu-tool create_feishu_document '{"title":"我的文档","folderToken":"FWK2xxxxx"}'

# 创建任务（需 user 模式）
feishu-tool create_feishu_task '{"tasks":[{"summary":"完成需求评审","dueTimestamp":"1742212800000"}]}'

# 按姓名搜索用户（需 user 模式）
feishu-tool get_feishu_users '{"queries":[{"query":"张三"}]}'
```

---

## 错误格式

```json
{"error": "错误描述信息"}
```

常见错误：`未知工具: "xxx"` / `参数解析失败` / `参数校验失败` / 飞书 API 错误（含 code、log_id）

---

## 参考文档

工具完整参数签名、字段类型、限制和工作流示例均在对应模块文档中：

- **Document 模块**（文件夹/文档/块/图片/白板）→ `feishu-mcp/reference/document.md`
- **Task 模块**（任务 CRUD）→ `feishu-mcp/reference/task.md`
- **Member 模块**（用户查询）→ `feishu-mcp/reference/member.md`
- **CLI 管理命令**（config/auth/guide）→ `feishu-mcp/reference/cli.md`
