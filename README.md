# Feishu-Skill

> AI Skill，让 AI 通过 `feishu-tool` CLI 自动操作飞书文档、任务与用户。

## 简介

本项目是一个 AI Skill，配合 [Feishu-MCP](https://github.com/cso1z/Feishu-MCP) 使用。支持 Claude Code、Cursor 等主流 AI 编程工具，安装后 AI 能在合适场景下自动调用 `feishu-tool` CLI，完成飞书文档、任务、用户的增删改查操作，无需手动执行命令。

## 安装

### 第一步：安装 feishu-tool

```bash
npm install -g feishu-mcp@latest
```

> 要求 Node.js >= 20.17.0

### 第二步：安装 Skill

> 支持环境：macOS、Linux、Windows（Git Bash），不支持 CMD / PowerShell。

克隆本仓库后，运行安装脚本：

```bash
# 安装到全局（默认）
bash install.sh

# 或安装到指定项目
bash install.sh --project /path/to/your/project
```

### 第三步：配置环境变量

`feishu-tool` 支持通过命令直接配置，无需手动创建 `.env` 文件：

```bash
feishu-tool config set FEISHU_APP_ID <your-app-id>
feishu-tool config set FEISHU_APP_SECRET <your-app-secret>
```

| 变量 | 必填 | 说明 |
|------|------|------|
| `FEISHU_APP_ID` | ✅ | 飞书应用 ID |
| `FEISHU_APP_SECRET` | ✅ | 飞书应用密钥 |
| `FEISHU_AUTH_TYPE` | 否 | `tenant`（默认）或 `user` |
| `FEISHU_ENABLED_MODULES` | 否 | `document` / `task` / `member` / `all` |

### 让 AI 自动完成全部安装配置

将以下 prompt 直接发给 AI（Claude Code、Cursor 等），它会自动执行上述所有步骤：

```
请帮我安装 Feishu-Skill：

1. 将项目克隆到本地临时目录：
   git clone https://github.com/cso1z/Feishu-Skill.git /tmp/Feishu-Skill

2. 执行安装脚本（安装到全局 ~/.claude/skills）：
   bash /tmp/Feishu-Skill/install.sh

3. 安装完成后，检查 feishu-mcp skill 是否已加载（确认 ~/.claude/skills/feishu-skill/SKILL.md 存在）：
   - 若已加载，直接告知我已就绪，无需重启
   - 若未加载，告知我需要重启 AI 工具以加载 Skill
```

## 功能

| 模块 | 工具数 | 能力 |
|------|--------|------|
| Document | 15 | 文件夹/文档/块/图片/白板的创建、读取、编辑、搜索 |
| Task | 4 | 任务创建（含子任务）、更新、删除、列表 |
| Member | 1 | 按姓名搜索或按 ID 批量获取用户 |

## 使用方式

安装后，直接用自然语言告诉 AI 你的飞书需求，Skill 会自动触发：

- "在飞书创建一个文档，标题是『需求评审』"
- "帮我列出今天截止的飞书任务"
- "搜索飞书里关于架构设计的文档"

也可以直接使用 `feishu-tool` CLI：

```bash
# 查看 CLI 概览（子命令 + 可用工具集）
feishu-tool --help

# 查看初始化指南（获取 App ID / Secret 的步骤说明）
feishu-tool guide

# 写入凭证
feishu-tool config set FEISHU_APP_ID cli_xxxxx

# 查看当前配置（确认写入正确）
feishu-tool config

# 查看某个工具的详细参数
feishu-tool help create_feishu_document

# 调用工具
feishu-tool create_feishu_document '{"title": "测试文档"}'
```

## 版本历史

| 版本 | 说明 |
|------|------|
| 1.3.0 | 命令名统一为 feishu-tool；修正 stdout 纯净性声明；补充 auth canRefresh 分支；新增表格单元格更新工作流；新增安装引导 prompt |
| 1.0.0 | 初始版本，支持 Document（15个）、Task（4个）、Member（1个）模块 |

## 依赖

- [Feishu-MCP](https://github.com/cso1z/Feishu-MCP) — 提供 `feishu-tool` CLI 命令

## License

MIT
