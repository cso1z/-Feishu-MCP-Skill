#!/bin/bash
# install.sh - 将 feishu-tool Skill 安装到全局或指定项目
# 用法:
#   bash install.sh                        # 安装到全局 ~/.claude（默认）
#   bash install.sh --global               # 同上
#   bash install.sh --project /path/to/project  # 安装到指定项目

set -e

SKILL_NAME="feishu-mcp"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/$SKILL_NAME"

# 解析参数
MODE="global"
PROJECT_PATH=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --global)
      MODE="global"
      shift
      ;;
    --project)
      MODE="project"
      PROJECT_PATH="$2"
      shift 2
      ;;
    *)
      echo "未知参数: $1"
      echo "用法: bash install.sh [--global] [--project /path/to/project]"
      exit 1
      ;;
  esac
done

# 确定目标目录
if [[ "$MODE" == "global" ]]; then
  TARGET_DIR="$HOME/.claude/skills/$SKILL_NAME"
else
  if [[ -z "$PROJECT_PATH" ]]; then
    echo "错误：--project 需要指定项目路径"
    exit 1
  fi
  TARGET_DIR="$PROJECT_PATH/.claude/skills/$SKILL_NAME"
fi

echo ">> 安装目标：$TARGET_DIR"

# 创建目标目录并复制文件
mkdir -p "$TARGET_DIR"
cp -r "$SOURCE_DIR/." "$TARGET_DIR/"

echo ">> Skill 已安装到：$TARGET_DIR"
echo ">> 安装完成！重启 AI 工具后生效。"
