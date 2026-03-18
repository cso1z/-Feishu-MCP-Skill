# feishu-mcp-tool — Task 模块参考

覆盖飞书任务的增删改查全部 4 个工具。

---

## 工具详情

### `list_feishu_tasks`

列出当前用户负责的任务，支持分页和完成状态过滤。

| 参数 | 类型 | 必填 | 含义 |
|------|------|------|------|
| `pageSize` | number | 否 | 每页数量（默认 20，最大 100）|
| `pageToken` | string | 否 | 分页 token（从上一次返回的 `pageToken` 获取）|
| `completed` | boolean | 否 | `true` 只返回已完成；`false` 只返回未完成；不传返回全部 |

```bash
# 获取未完成任务
feishu-mcp-tool list_feishu_tasks '{"completed":false}'

# 分页获取
feishu-mcp-tool list_feishu_tasks '{"pageToken":"xxxxx","pageSize":50}'

# 获取所有任务（无过滤）
feishu-mcp-tool list_feishu_tasks '{}'
```

返回示例：
```json
{
  "items": [
    {
      "guid": "4a3e075f-a198-4b1a-8d5e-d98a8a6b6e76",
      "summary": "完成需求评审",
      "completed_at": "",
      "due": {"timestamp": "1742212800000"}
    }
  ],
  "pageToken": "next_page_token",
  "hasMore": true
}
```

---

### `create_feishu_task`

批量创建任务，每个任务可嵌套子任务。

| 参数 | 类型 | 必填 | 含义 |
|------|------|------|------|
| `tasks` | array | 是 | 任务定义数组 |
| `tasks[].summary` | string | 是 | 任务标题 |
| `tasks[].description` | string | 否 | 任务描述（富文本）|
| `tasks[].dueTimestamp` | string | 否 | 截止时间（毫秒时间戳字符串）|
| `tasks[].assigneeIds` | string[] | 否 | 负责人 open_id 数组 |
| `tasks[].subTasks` | array | 否 | 子任务数组（结构同父任务，不支持再嵌套）|
| `tasks[].subTasks[].summary` | string | 是 | 子任务标题 |
| `tasks[].subTasks[].dueTimestamp` | string | 否 | 子任务截止时间 |
| `tasks[].subTasks[].assigneeIds` | string[] | 否 | 子任务负责人 |

```bash
# 创建单个任务
feishu-mcp-tool create_feishu_task '{
  "tasks": [
    {"summary": "完成需求评审", "dueTimestamp": "1742212800000"}
  ]
}'

# 创建带子任务的主任务并指定负责人
feishu-mcp-tool create_feishu_task '{
  "tasks": [
    {
      "summary": "Q2 项目启动",
      "description": "完成 Q2 各模块的开发启动工作",
      "dueTimestamp": "1745000000000",
      "assigneeIds": ["ou_xxxxxxxxxxxxxxxx"],
      "subTasks": [
        {"summary": "完成技术方案设计", "dueTimestamp": "1743000000000"},
        {"summary": "完成接口定义", "dueTimestamp": "1744000000000"},
        {"summary": "完成联调测试", "dueTimestamp": "1745000000000"}
      ]
    }
  ]
}'

# 批量创建多个任务
feishu-mcp-tool create_feishu_task '{
  "tasks": [
    {"summary": "任务A"},
    {"summary": "任务B"},
    {"summary": "任务C"}
  ]
}'
```

---

### `update_feishu_task`

更新已有任务的字段。只传需要修改的字段，其余字段保持不变。

| 参数 | 类型 | 必填 | 含义 |
|------|------|------|------|
| `taskGuid` | string | 是 | 任务唯一 ID（GUID 格式）|
| `summary` | string | 否 | 新任务标题 |
| `description` | string | 否 | 新任务描述 |
| `dueTimestamp` | string | 否 | 新截止时间（毫秒时间戳字符串）|
| `completedAt` | string | 否 | 完成时间（传毫秒时间戳字符串标记为已完成；传 `"0"` 取消完成）|

```bash
# 修改任务标题
feishu-mcp-tool update_feishu_task '{
  "taskGuid": "4a3e075f-a198-4b1a-8d5e-d98a8a6b6e76",
  "summary": "完成需求评审（已更新）"
}'

# 标记任务为已完成（传当前时间戳）
feishu-mcp-tool update_feishu_task '{
  "taskGuid": "4a3e075f-a198-4b1a-8d5e-d98a8a6b6e76",
  "completedAt": "1742212800000"
}'

# 取消完成状态
feishu-mcp-tool update_feishu_task '{
  "taskGuid": "4a3e075f-a198-4b1a-8d5e-d98a8a6b6e76",
  "completedAt": "0"
}'

# 同时更新多个字段
feishu-mcp-tool update_feishu_task '{
  "taskGuid": "4a3e075f-a198-4b1a-8d5e-d98a8a6b6e76",
  "summary": "新标题",
  "dueTimestamp": "1750000000000"
}'
```

---

### `delete_feishu_task`

批量删除任务（不可恢复）。

| 参数 | 类型 | 必填 | 含义 |
|------|------|------|------|
| `taskGuids` | string[] | 是 | 要删除的任务 GUID 数组 |

```bash
# 删除单个任务
feishu-mcp-tool delete_feishu_task '{
  "taskGuids": ["4a3e075f-a198-4b1a-8d5e-d98a8a6b6e76"]
}'

# 批量删除
feishu-mcp-tool delete_feishu_task '{
  "taskGuids": [
    "4a3e075f-a198-4b1a-8d5e-d98a8a6b6e76",
    "aa3a9647-0fdc-4280-906d-ef072c876ba4",
    "bb4b0758-1ged-5391-017e-fg183d987cb5"
  ]
}'
```

---

## 常见工作流

### 工作流 1：创建项目任务树

```bash
# 一次创建主任务 + 子任务
feishu-mcp-tool create_feishu_task '{
  "tasks": [
    {
      "summary": "新功能开发",
      "dueTimestamp": "1750000000000",
      "subTasks": [
        {"summary": "需求分析"},
        {"summary": "技术设计"},
        {"summary": "编码实现"},
        {"summary": "测试验收"}
      ]
    }
  ]
}'
```

---

### 工作流 2：批量完成已处理的任务

```bash
# 1. 查询未完成任务，找到需要完成的 taskGuid
feishu-mcp-tool list_feishu_tasks '{"completed":false}'

# 2. 逐一标记为完成（completedAt 传当前时间戳）
feishu-mcp-tool update_feishu_task '{"taskGuid":"<guid1>","completedAt":"1742212800000"}'
feishu-mcp-tool update_feishu_task '{"taskGuid":"<guid2>","completedAt":"1742212800000"}'
```

---

### 工作流 3：清理已完成的旧任务

```bash
# 1. 获取已完成任务列表
feishu-mcp-tool list_feishu_tasks '{"completed":true}'

# 2. 批量删除（收集 guid 后一次调用）
feishu-mcp-tool delete_feishu_task '{
  "taskGuids": ["<guid1>","<guid2>","<guid3>"]
}'
```