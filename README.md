# Feishu-MCP-Skill

> Claude Code Skill，让 AI 通过 `feishu-mcp-tool` CLI 自动操作飞书文档、任务与用户。

## 简介

本项目是一个 [Claude Code Skill](https://docs.anthropic.com/zh-CN/docs/claude-code/skills)，配合 [Feishu-MCP](https://github.com/cso1z/Feishu-MCP) 使用。安装后，Claude Code 能在合适场景下自动调用 `feishu-mcp-tool` CLI，完成飞书文档、任务、用户的增删改查操作，无需手动执行命令。

## 安装

### 第一步：安装 feishu-mcp-tool

```bash
npm install -g feishu-mcp
```

> 要求 Node.js >= 20.17.0

### 第二步：配置环境变量

在项目根目录创建 `.env` 文件（参考 [Feishu-MCP](https://github.com/cso1z/Feishu-MCP) 仓库的 `.env.example`）：

| 变量 | 必填 | 说明 |
|------|------|------|
| `FEISHU_APP_ID` | ✅ | 飞书应用 ID |
| `FEISHU_APP_SECRET` | ✅ | 飞书应用密钥 |
| `FEISHU_AUTH_TYPE` | 否 | `tenant`（默认）或 `user` |
| `FEISHU_ENABLED_MODULES` | 否 | `document` / `task` / `member` / `all` |

### 第三步：安装 Skill

将本仓库的 `feishu-mcp-tool` 目录（包含 `SKILL.md` 和 `reference/`）放置到 Claude Code 的 Skills 目录：

```
~/.claude/skills/feishu-mcp-tool/
```

或在项目级别使用：

```
<your-project>/.claude/skills/feishu-mcp-tool/
```

## 功能

| 模块 | 工具数 | 能力 |
|------|--------|------|
| Document | 15 | 文件夹/文档/块/图片/白板的创建、读取、编辑、搜索 |
| Task | 4 | 任务创建（含子任务）、更新、删除、列表 |
| Member | 1 | 按姓名搜索或按 ID 批量获取用户 |

## 使用方式

安装后，直接用自然语言告诉 Claude Code 你的飞书需求，Skill 会自动触发：

- "在飞书创建一个文档，标题是『需求评审』"
- "帮我列出今天截止的飞书任务"
- "搜索飞书里关于架构设计的文档"

## 版本历史

| 版本 | 说明 |
|------|------|
| 1.0.0 | 初始版本，支持 Document（15个）、Task（4个）、Member（1个）模块 |

## 依赖

- [Feishu-MCP](https://github.com/cso1z/Feishu-MCP) — 提供 `feishu-mcp-tool` CLI 命令

## License

MIT
