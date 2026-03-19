# feishu-mcp-tool — Member 模块参考

覆盖飞书用户查询工具。仅 `FEISHU_AUTH_TYPE=user` 时可用。

---

## 工具列表

### `get_feishu_users`

按姓名搜索飞书用户，或按 ID 批量获取用户详情。

**参数：**

- `queries`? array（1~20 项）：按姓名搜索模式
  - `query`* string：搜索关键词，匹配显示名称及拼音（全拼/缩写/首字母，不区分大小写）。不匹配 user_id，按 ID 查询请用 `userIdsParam`
  - `pageToken`? string：该关键词的分页 token，首次不传，翻页时传上次返回值

- `userIdsParam`? array（1~50 项）：按 ID 批量查询模式
  - `id`* string：用户 ID 值
  - `idType`? string：ID 类型，默认 `open_id`
    - `open_id`：应用维度唯一 ID（推荐）
    - `union_id`：开发者维度唯一 ID
    - `user_id`：企业维度唯一 ID

> `queries` 与 `userIdsParam` 二选一，不可同时传。

> ⚠️ **`queries` 数组的每个元素必须是对象 `{query: string}`，字段名为 `query` 而非 `name`。** 常见错误见下方示例。

```bash
# ✅ 正确：按姓名搜索
feishu-mcp-tool get_feishu_users '{"queries":[{"query":"张三"}]}'

# ✅ 正确：同时搜索多个关键词
feishu-mcp-tool get_feishu_users '{"queries":[{"query":"张三"},{"query":"李四"}]}'

# ❌ 错误示例（常见误用，均会报错）：
# {"names":["张三"]}                    -> 字段名错误，应为 queries
# {"queries":["张三"]}                  -> 元素应为对象 {query: string}，而非字符串
# {"queries":[{"name":"张三"}]}         -> 字段应为 query，不是 name

# 按 open_id 批量查询
feishu-mcp-tool get_feishu_users '{
  "userIdsParam": [
    {"id":"ou_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx","idType":"open_id"},
    {"id":"ou_yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy","idType":"open_id"}
  ]
}'
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
          "email": "zhangsan@company.com"
        }
      ]
    }
  ]
}
```

---

## 常见工作流

### 工作流 1：搜索用户并创建任务时指定负责人

```bash
# 1. 搜索用户，获取 open_id
feishu-mcp-tool get_feishu_users '{"queries":[{"query":"张三"}]}'

# 2. 创建任务并指定负责人
feishu-mcp-tool create_feishu_task '{
  "tasks": [{
    "summary": "完成代码 Review",
    "dueTimestamp": "1742212800000",
    "assigneeIds": ["ou_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"]
  }]
}'
```

---

### 工作流 2：从任务列表中反查负责人信息

```bash
# 1. 获取任务列表（返回含负责人 open_id）
feishu-mcp-tool list_feishu_tasks '{}'

# 2. 批量查询负责人详情
feishu-mcp-tool get_feishu_users '{
  "userIdsParam": [{"id":"<open_id_from_task>","idType":"open_id"}]
}'
```