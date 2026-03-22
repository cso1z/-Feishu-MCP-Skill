# feishu-tool — CLI 管理命令参考

配置管理、授权管理、初始化指南相关命令。

---

## `feishu-tool config`

查看当前生效的配置。

```bash
feishu-tool config
```

返回示例：
```json
{
  "configFile": "/Users/xxx/.cache/feishu-mcp/.env",
  "loadedFrom": "/Users/xxx/.cache/feishu-mcp/.env",
  "config": {
    "FEISHU_APP_ID": "cli_xxxxx",
    "FEISHU_APP_SECRET": "4sp****",
    "FEISHU_AUTH_TYPE": "user",
    "FEISHU_ENABLED_MODULES": "all",
    "PORT": "3333 (默认)"
  },
  "globalConfigFile": { "FEISHU_APP_ID": "cli_xxxxx", "..." : "..." }
}
```

字段说明：
- `loadedFrom`：实际加载的 `.env` 文件路径（CWD 优先，其次 `~/.cache/feishu-mcp/.env`）
- `configFile`：全局配置文件路径（`config set` 的写入目标与 `loadedFrom` 一致）
- `config`：当前生效值，括号内为默认值标注

---

## `feishu-tool config set <KEY> <VALUE>`

向配置文件写入或更新一个配置项。写入位置与当前加载来源一致（`loadedFrom`）。

```bash
feishu-tool config set FEISHU_APP_ID cli_xxxxx
feishu-tool config set FEISHU_APP_SECRET your-secret
feishu-tool config set FEISHU_AUTH_TYPE user
feishu-tool config set FEISHU_ENABLED_MODULES all
```

不带参数时显示所有可用 KEY 及含义：

```bash
feishu-tool config set
```

返回示例：
```json
{
  "usage": "feishu-tool config set <KEY> <VALUE>",
  "availableKeys": {
    "FEISHU_APP_ID": "飞书应用 App ID",
    "FEISHU_APP_SECRET": "飞书应用 App Secret",
    "FEISHU_AUTH_TYPE": "认证类型：tenant（应用身份）或 user（用户身份，支持 task/member）",
    "FEISHU_ENABLED_MODULES": "启用的功能模块，逗号分隔，可选值: document,task,member,calendar,all",
    "FEISHU_BASE_URL": "飞书 API 基础地址，默认 https://open.feishu.cn/open-apis",
    "FEISHU_SCOPE_VALIDATION": "是否启用权限校验：true 或 false，默认 true",
    "PORT": "服务监听端口，默认 3333"
  }
}
```

成功返回示例：
```json
{
  "ok": true,
  "file": "/Users/xxx/.cache/feishu-mcp/.env",
  "set": { "FEISHU_AUTH_TYPE": "user" }
}
```

---

## `feishu-tool auth`

查看当前用户 token 的授权状态（仅 `FEISHU_AUTH_TYPE=user` 时有意义）。

```bash
feishu-tool auth
```

`tenant` 模式返回：
```json
{ "authType": "tenant", "status": "tenant 模式无需用户授权" }
```

`user` 模式返回：
```json
{
  "authType": "user",
  "userKey": "stdio",
  "isValid": true,
  "isExpired": false,
  "canRefresh": true,
  "shouldRefresh": false
}
```

字段说明：
- `isValid`：token 是否有效可用
- `isExpired`：access_token 是否已过期
- `canRefresh`：refresh_token 是否仍在有效期内（可静默刷新）
- `shouldRefresh`：是否建议提前刷新（距过期 < 5 分钟）

**调用工具前的建议检查逻辑：**

| 状态 | 建议操作 |
|------|---------|
| `isValid: true` | 直接调用工具 |
| `isValid: false, canRefresh: true` | 直接调用工具（SDK 内部自动刷新）|
| `isValid: false, canRefresh: false` | 告知用户将触发浏览器授权，然后调用工具 |

---

## `feishu-tool auth logout`

清除当前用户的缓存 token，下次调用工具时重新触发授权流程。

```bash
feishu-tool auth logout
```

返回示例：
```json
{ "ok": true, "message": "已退出登录，token 已清除" }
```

---

## `feishu-tool guide`

显示飞书 MCP 配置指南，并**自动在浏览器打开详细文档**。

```bash
feishu-tool guide
```

返回内容根据当前 `FEISHU_AUTH_TYPE` 和 `FEISHU_ENABLED_MODULES` 动态生成，包含：
- 步骤化的配置流程
- 当前已启用模块需申请的权限摘要
- `user` 模式下的 OAuth 回调地址配置说明
- 验证配置的测试命令

`tip` 字段包含详细文档链接，可直接提供给用户：
```json
{
  "tip": "完整配置说明（含截图）请查阅：https://github.com/cso1z/Feishu-MCP/blob/cli/FEISHU_CONFIG.md，已自动在浏览器打开，也可将此链接提供给用户手动访问"
}
```

---

## 常见工作流

### 工作流 1：全新初始化

```bash
# 1. 查看配置指南（打开浏览器文档）
feishu-tool guide

# 2. 写入配置
feishu-tool config set FEISHU_APP_ID cli_xxxxx
feishu-tool config set FEISHU_APP_SECRET your-secret
feishu-tool config set FEISHU_AUTH_TYPE user
feishu-tool config set FEISHU_ENABLED_MODULES all

# 3. 验证配置
feishu-tool config

# 4. 测试连通性
feishu-tool get_feishu_root_folder_info
```

### 工作流 2：切换认证模式

```bash
# 从 tenant 切换到 user 模式
feishu-tool config set FEISHU_AUTH_TYPE user
feishu-tool config set FEISHU_ENABLED_MODULES all

# 检查 token 状态（初次使用 user 模式时为未授权）
feishu-tool auth

# 调用任意工具触发授权（会自动打开浏览器）
feishu-tool get_feishu_root_folder_info
```

### 工作流 3：重新授权

```bash
# 清除旧 token
feishu-tool auth logout

# 调用工具触发重新授权
feishu-tool get_feishu_root_folder_info
```