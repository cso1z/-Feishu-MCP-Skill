# feishu-tool — Task 模块参考

覆盖飞书任务的增删改查全部 4 个工具。仅 `FEISHU_AUTH_TYPE=user` 时可用。

---

## 共用说明

- **`dueTimestamp`** / **`startTimestamp`**：毫秒时间戳字符串，如 `"1742212800000"`（1970-01-01 00:00:00 UTC 起）。

---

## 工具列表

### `list_feishu_tasks`

列出当前用户「我负责的」任务，支持分页和完成状态过滤。每次最多返回 100 条。

**参数：**

- `pageToken`? string：分页 token，首次不传，翻页时传上次返回的 `page_token`
- `completed`? boolean：true=仅已完成，false=仅未完成，不传=全部

```bash
feishu-tool list_feishu_tasks '{"completed":false}'
feishu-tool list_feishu_tasks '{"pageToken":"xxxxx"}'
feishu-tool list_feishu_tasks '{}'
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
  "page_token": "next_page_token",
  "has_more": true
}
```

---

### `create_feishu_task`

批量创建任务，支持嵌套子任务。每次最多 50 个顶层任务，每层最多 50 个子任务。

**参数：**

- `tasks`* array（1~50 项）：
  - `summary`* string：任务标题，最多 3000 字符
  - `description`? string：任务描述，最多 3000 字符
  - `parentTaskGuid`? string：父任务 GUID，传此值则创建为已有任务的子任务
  - `dueTimestamp`? → 见共用说明
  - `isDueAllDay`? boolean：是否全天任务，true 时只取时间戳日期部分，默认 false
  - `startTimestamp`? → 见共用说明
  - `isStartAllDay`? boolean：开始时间是否全天，默认 false
  - `completedAt`? string：完成时间戳（ms），传此值则创建为已完成任务，`"0"` 或不传=未完成
  - `assigneeIds`? string[]：负责人 open_id 数组，从 `get_feishu_users` 获取，最多 50 个
  - `followerIds`? string[]：关注人 open_id 数组，最多 50 个
  - `repeatRule`? string：重复规则，如 `"FREQ=WEEKLY;INTERVAL=1;BYDAY=MO,TU,WE,TH,FR"`
  - `mode`? number：完成模式，1=所有负责人需完成，2=任意负责人完成即可（默认 2）
  - `isMilestone`? boolean：是否里程碑，默认 false
  - `subTasks`? array：子任务数组，结构同父任务，支持多级嵌套，每层最多 50 项

返回示例：
```json
{
  "results": [
    {
      "task": {
        "guid": "3a40bfaa-6044-4f0d-a00e-e8d0cd7f7263",
        "summary": "完成需求评审",
        "completed_at": "",
        "due": {"timestamp": "1742212800000", "is_all_day": false}
      }
    }
  ],
  "errors": []
}
```

> 任务 GUID 在 `results[0].task.guid`，批量创建时按 `results[n].task.guid` 顺序对应入参。

```bash
# 创建单个任务
feishu-tool create_feishu_task '{
  "tasks": [{"summary":"完成需求评审","dueTimestamp":"1742212800000"}]
}'

# 创建带子任务的主任务
feishu-tool create_feishu_task '{
  "tasks": [
    {
      "summary": "Q2 项目启动",
      "dueTimestamp": "1745000000000",
      "assigneeIds": ["ou_xxxxxxxxxxxxxxxx"],
      "subTasks": [
        {"summary":"完成技术方案设计","dueTimestamp":"1743000000000"},
        {"summary":"完成接口定义","dueTimestamp":"1744000000000"}
      ]
    }
  ]
}'
```

---

### `update_feishu_task`

更新已有任务的字段。只传需要修改的字段，其余保持不变。至少传一个更新字段。

> ⚠️ **标记完成/取消完成**：使用 **`completedAt`**（毫秒时间戳字符串），不存在 `completed`/`is_completed` 字段。传具体时间戳=标记已完成，传 `"0"`=取消完成状态。

**参数：**

- `taskGuid`* string：任务 GUID，从 `list_feishu_tasks` 返回的 `guid` 获取
- `summary`? string：新任务标题，最多 3000 字符
- `description`? string：新任务描述，最多 3000 字符
- `dueTimestamp`? → 见共用说明
- `isDueAllDay`? boolean：截止时间是否全天
- `startTimestamp`? → 见共用说明
- `isStartAllDay`? boolean：开始时间是否全天
- `completedAt`? string：完成时间戳（ms），传具体值=标记已完成，传 `"0"`=取消完成状态
- `repeatRule`? string：新重复规则
- `mode`? number：1=所有负责人需完成，2=任意负责人完成即可
- `isMilestone`? boolean：是否里程碑
- `addAssigneeIds`? string[]：新增负责人 open_id 数组，最多 50 个
- `removeAssigneeIds`? string[]：移除负责人 open_id 数组
- `addFollowerIds`? string[]：新增关注人 open_id 数组，最多 50 个
- `removeFollowerIds`? string[]：移除关注人 open_id 数组
- `addReminderRelativeMinutes`? integer：新增提醒，截止前 N 分钟（0=到期时提醒）。任务须有截止时间；每任务限 1 个提醒，已有提醒需先用 `removeReminderIds` 删除
- `removeReminderIds`? string[]：删除提醒 ID 数组，从任务 `reminders[].id` 获取

```bash
# 修改标题
feishu-tool update_feishu_task '{"taskGuid":"4a3e075f-...","summary":"新标题"}'

# 标记已完成
feishu-tool update_feishu_task '{"taskGuid":"4a3e075f-...","completedAt":"1742212800000"}'

# 取消完成状态
feishu-tool update_feishu_task '{"taskGuid":"4a3e075f-...","completedAt":"0"}'
```

---

### `delete_feishu_task`

批量删除任务（不可恢复）。

**参数：**

- `taskGuids`* string[]（1~50 项）：要删除的任务 GUID 数组

```bash
feishu-tool delete_feishu_task '{"taskGuids":["4a3e075f-a198-4b1a-8d5e-d98a8a6b6e76"]}'
```

---

## 常见工作流

### 工作流 1：创建项目任务树

```bash
feishu-tool create_feishu_task '{
  "tasks": [{
    "summary": "新功能开发",
    "dueTimestamp": "1750000000000",
    "subTasks": [
      {"summary":"需求分析"},
      {"summary":"技术设计"},
      {"summary":"编码实现"},
      {"summary":"测试验收"}
    ]
  }]
}'
```

---

### 工作流 2：批量完成已处理的任务

```bash
# 1. 查询未完成任务，获取 guid
feishu-tool list_feishu_tasks '{"completed":false}'

# 2. 标记为完成
feishu-tool update_feishu_task '{"taskGuid":"<guid1>","completedAt":"1742212800000"}'
feishu-tool update_feishu_task '{"taskGuid":"<guid2>","completedAt":"1742212800000"}'
```

---

### 工作流 3：清理已完成的旧任务

```bash
# 1. 获取已完成任务列表
feishu-tool list_feishu_tasks '{"completed":true}'

# 2. 批量删除
feishu-tool delete_feishu_task '{"taskGuids":["<guid1>","<guid2>","<guid3>"]}'
```
