# feishu-mcp-tool — Member 模块参考

覆盖飞书用户查询工具。

---

## 工具详情

### `get_feishu_users`

按姓名搜索飞书用户，或按 open_id / user_id / union_id 批量获取用户详情。两种查询模式互斥，按需选用。

---

### 模式一：按名称搜索

| 参数 | 类型 | 必填 | 含义 |
|------|------|------|------|
| `queries` | array | 是 | 搜索条件数组 |
| `queries[].query` | string | 是 | 搜索关键词（姓名、拼音或邮箱前缀）|

```bash
# 搜索单个用户
feishu-mcp-tool get_feishu_users '{"queries":[{"query":"张三"}]}'

# 同时搜索多个关键词
feishu-mcp-tool get_feishu_users '{"queries":[{"query":"张三"},{"query":"李四"}]}'
```

返回示例：
```json
{
  "results": [
    {
      "query": "张三",
      "users": [
        {
          "name": "张三",
          "open_id": "ou_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
          "user_id": "xxxxxxxx",
          "union_id": "on_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
          "email": "zhangsan@company.com",
          "avatar_url": "https://..."
        }
      ]
    }
  ]
}
```

---

### 模式二：按 ID 批量查询

| 参数 | 类型 | 必填 | 含义 |
|------|------|------|------|
| `userIdsParam` | array | 是 | 用户 ID 查询数组 |
| `userIdsParam[].id` | string | 是 | 用户 ID 值 |
| `userIdsParam[].idType` | string | 是 | ID 类型：`open_id` / `user_id` / `union_id` |

```bash
# 按 open_id 批量查询
feishu-mcp-tool get_feishu_users '{
  "userIdsParam": [
    {"id": "ou_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", "idType": "open_id"},
    {"id": "ou_yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy", "idType": "open_id"}
  ]
}'

# 按 user_id 查询
feishu-mcp-tool get_feishu_users '{
  "userIdsParam": [
    {"id": "xxxxxxxx", "idType": "user_id"}
  ]
}'
```

---

## 常见工作流

### 工作流 1：搜索用户并创建任务时指定负责人

```bash
# 1. 按姓名搜索用户，获取 open_id
feishu-mcp-tool get_feishu_users '{"queries":[{"query":"张三"}]}'
# 从返回结果中取 open_id: "ou_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

# 2. 创建任务并指定负责人
feishu-mcp-tool create_feishu_task '{
  "tasks": [
    {
      "summary": "完成代码 Review",
      "dueTimestamp": "1742212800000",
      "assigneeIds": ["ou_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"]
    }
  ]
}'
```

---

### 工作流 2：从任务列表中反查负责人信息

```bash
# 1. 获取任务列表（返回中含 assignee open_id）
feishu-mcp-tool list_feishu_tasks '{}'

# 2. 批量查询负责人详情
feishu-mcp-tool get_feishu_users '{
  "userIdsParam": [
    {"id": "<open_id_from_task>", "idType": "open_id"}
  ]
}'
```
