---
version: 1.0.0
description: 使用 feishu-mcp-tool CLI 操作飞书文档、任务、用户等资源。当用户需要读写飞书（创建/查询/更新/删除文档、块、任务、文件夹、用户）时调用此 skill。
argument-hint: "[tool-name] [json-params]"
allowed-tools: Bash(feishu-mcp-tool *), Bash(command -v feishu-mcp-tool), Bash(npm install -g feishu-mcp), Bash(node --version)
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

# feishu-mcp-tool CLI

命令行工具，支持直接调用全部飞书 MCP 工具。专为 LLM Agent 设计：参数以 JSON 传入，结果以纯 JSON 输出到 stdout，日志和授权提示输出到 stderr。

## 前置条件

此 skill 依赖 [Feishu-MCP](https://github.com/cso1z/Feishu-MCP) 项目提供的 `feishu-mcp-tool` 命令。

### 第一步：安装

```bash
npm install -g feishu-mcp
```

> 要求 Node.js >= 20.17.0。安装后 `feishu-mcp-tool` 命令即注册到全局 PATH。

### 第二步：配置环境变量

在项目根目录创建 `.env` 文件（参考仓库中的 `.env.example`），或在系统环境变量中设置：

| 变量 | 必填 | 说明 | 示例 |
|------|------|------|------|
| `FEISHU_APP_ID` | ✅ | 飞书应用 ID | `cli_xxxxx` |
| `FEISHU_APP_SECRET` | ✅ | 飞书应用密钥 | `xxxxx` |
| `FEISHU_AUTH_TYPE` | 否 | 认证模式：`tenant`（默认）或 `user`（需 OAuth）| `tenant` |
| `FEISHU_ENABLED_MODULES` | 否 | 启用模块：`document`/`task`/`member`/`all`，默认 `document` | `all` |

## 执行规则

**调用任何工具前，必须先检查命令是否可用：**

```bash
command -v feishu-mcp-tool
```

- **有输出（路径）**：命令就绪，正常执行
- **无输出 / 报错**：停止执行，向用户输出以下提示后不再继续：

```
feishu-mcp-tool 命令未找到，请先完成以下安装步骤：

1. 确认 Node.js >= 20.17.0：node --version
2. 全局安装：npm install -g feishu-mcp
3. 配置环境变量 FEISHU_APP_ID 和 FEISHU_APP_SECRET（参考 .env.example）

项目地址：https://github.com/cso1z/Feishu-MCP
```

## 调用格式

```bash
feishu-mcp-tool <tool-name> '<json-params>'
feishu-mcp-tool <tool-name>          # 无参数工具可省略第二个参数
```

- **stdout**：工具执行结果（JSON）
- **stderr**：日志与认证提示（不影响结果解析）
- **exit 0**：成功；**exit 1**：失败，stdout 输出 `{"error":"..."}`

## 使用场景

- **文档管理**：在飞书云盘或知识库中创建、读取、编辑文档内容（文本、标题、代码块、图片、表格、白板）
- **任务跟踪**：创建带子任务的任务、分配负责人、更新进度、批量删除
- **用户查询**：按姓名搜索用户或按 open_id 批量获取用户信息

## 工具速查

### Document 模块（15个）

| 工具名 | 用途 |
|--------|------|
| `get_feishu_root_folder_info` | 获取根文件夹、知识空间列表和我的知识库 |
| `get_feishu_folder_files` | 列出文件夹或知识库节点下的文件 |
| `create_feishu_folder` | 在指定文件夹下创建子文件夹 |
| `create_feishu_document` | 在文件夹或知识库中创建文档 |
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

### Task 模块（4个）

| 工具名 | 用途 |
|--------|------|
| `list_feishu_tasks` | 列出当前用户负责的任务（支持分页）|
| `create_feishu_task` | 批量创建任务（支持嵌套子任务）|
| `update_feishu_task` | 更新任务字段（标题/描述/截止时间/完成状态）|
| `delete_feishu_task` | 批量删除任务 |

### Member 模块（1个）

| 工具名 | 用途 |
|--------|------|
| `get_feishu_users` | 按名称搜索或按 ID 批量获取用户信息 |

## 快速示例

```bash
# 获取根文件夹（无需参数）
feishu-mcp-tool get_feishu_root_folder_info

# 在根文件夹下创建文档
feishu-mcp-tool create_feishu_document '{"title":"我的文档","folderToken":"FWK2xxxxx"}'

# 创建任务
feishu-mcp-tool create_feishu_task '{"tasks":[{"summary":"完成需求评审","dueTimestamp":"1742212800000"}]}'
```

## 错误格式

```json
{"error": "错误描述信息"}
```

常见错误：`未知工具: "xxx"` / `参数解析失败` / `参数校验失败` / 飞书 API 错误（含 code、log_id）

## 详细参考文档

需要了解工具完整参数和工作流时，读取对应模块文档：

- **Document 模块**（文件夹/文档/块/图片/白板）→ `feishu-mcp-tool/reference/document.md`
- **Task 模块**（任务 CRUD）→ `feishu-mcp-tool/reference/task.md`
- **Member 模块**（用户查询）→ `feishu-mcp-tool/reference/member.md`
