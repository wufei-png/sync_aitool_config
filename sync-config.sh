#!/bin/bash

# 同步 Claude 和 OpenCode 配置到远程服务器
# 排除聊天记录、缓存、日志等不必要的文件

set -e

REMOTE_HOST="remote_ip"
REMOTE_USER="root"
REMOTE_BASE="~"
LOCAL_CLAUDE="$HOME/.claude"
LOCAL_OPENCODE="$HOME/.config/opencode"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXCLUDE_FILE="${SCRIPT_DIR}/sync-exclude.txt"

# 检查是否使用 dry-run 模式
DRY_RUN=false
if [[ "$1" == "--dry-run" ]] || [[ "$1" == "-n" ]]; then
    DRY_RUN=true
    RSYNC_OPTS="--dry-run"
    echo "⚠️  DRY-RUN 模式：只显示将要同步的文件，不会实际传输"
else
    RSYNC_OPTS=""
fi

echo "开始同步配置到 ${REMOTE_HOST}..."
echo "排除文件列表: ${EXCLUDE_FILE}"
echo ""

# 创建远程目录
if [ "$DRY_RUN" = false ]; then
    ssh ${REMOTE_USER}@${REMOTE_HOST} "mkdir -p ${REMOTE_BASE}/.claude ${REMOTE_BASE}/.config/opencode"
fi

# ========== 同步 Claude 配置 ==========
echo ""
echo "========== 同步 Claude 配置 =========="

# 同步 settings.json
echo "同步 settings.json..."
if [ "$DRY_RUN" = false ]; then
    scp ${LOCAL_CLAUDE}/settings.json ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_BASE}/.claude/
else
    echo "  [DRY-RUN] 将同步: ${LOCAL_CLAUDE}/settings.json"
fi

# 同步 rules 目录（规则文件）
if [ -d "${LOCAL_CLAUDE}/rules" ]; then
    echo "同步 rules/ 目录..."
    rsync -av ${RSYNC_OPTS} --exclude-from="${EXCLUDE_FILE}" \
        ${LOCAL_CLAUDE}/rules/ ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_BASE}/.claude/rules/
fi

# 同步 skills 目录（技能文件）
if [ -d "${LOCAL_CLAUDE}/skills" ]; then
    echo "同步 skills/ 目录..."
    rsync -av ${RSYNC_OPTS} --exclude-from="${EXCLUDE_FILE}" \
        ${LOCAL_CLAUDE}/skills/ ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_BASE}/.claude/skills/
fi

# 同步 plugins 目录（插件配置，排除缓存）
if [ -d "${LOCAL_CLAUDE}/plugins" ]; then
    echo "同步 plugins/ 目录（排除缓存）..."
    rsync -av ${RSYNC_OPTS} --exclude-from="${EXCLUDE_FILE}" \
        ${LOCAL_CLAUDE}/plugins/ ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_BASE}/.claude/plugins/
fi

# ========== 同步 OpenCode 配置 ==========
echo ""
echo "========== 同步 OpenCode 配置 =========="

# 同步主配置文件
echo "同步 opencode.json..."
if [ "$DRY_RUN" = false ]; then
    scp ${LOCAL_OPENCODE}/opencode.json ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_BASE}/.config/opencode/
else
    echo "  [DRY-RUN] 将同步: ${LOCAL_OPENCODE}/opencode.json"
fi

# 同步 prompts 目录
if [ -d "${LOCAL_OPENCODE}/prompts" ]; then
    echo "同步 prompts/ 目录..."
    rsync -av ${RSYNC_OPTS} --exclude-from="${EXCLUDE_FILE}" \
        ${LOCAL_OPENCODE}/prompts/ ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_BASE}/.config/opencode/prompts/
fi

# 同步 .agents 目录
if [ -d "${LOCAL_OPENCODE}/.agents" ]; then
    echo "同步 .agents/ 目录..."
    rsync -av ${RSYNC_OPTS} --exclude-from="${EXCLUDE_FILE}" \
        ${LOCAL_OPENCODE}/.agents/ ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_BASE}/.config/opencode/.agents/
fi

# 同步 package.json（用于重新安装依赖）
if [ -f "${LOCAL_OPENCODE}/package.json" ]; then
    echo "同步 package.json..."
    if [ "$DRY_RUN" = false ]; then
        scp ${LOCAL_OPENCODE}/package.json ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_BASE}/.config/opencode/
    else
        echo "  [DRY-RUN] 将同步: ${LOCAL_OPENCODE}/package.json"
    fi
fi

# 同步 .gitignore
if [ -f "${LOCAL_OPENCODE}/.gitignore" ]; then
    echo "同步 .gitignore..."
    if [ "$DRY_RUN" = false ]; then
        scp ${LOCAL_OPENCODE}/.gitignore ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_BASE}/.config/opencode/
    else
        echo "  [DRY-RUN] 将同步: ${LOCAL_OPENCODE}/.gitignore"
    fi
fi

echo ""
if [ "$DRY_RUN" = true ]; then
    echo "========== DRY-RUN 完成 =========="
    echo ""
    echo "这是预览模式，没有实际传输文件。"
    echo "要执行实际同步，请运行: $0"
else
    echo "========== 同步完成 =========="
fi
echo ""
echo "已排除的文件/目录（详见 ${EXCLUDE_FILE}）："
echo ""
echo "Claude 排除项："
echo "  - cache/, debug/, transcripts/, sessions/ (缓存和会话)"
echo "  - history.jsonl, file-history/ (历史记录)"
echo "  - shell-snapshots/, stats-cache.json, statsig/ (快照和统计)"
echo "  - projects/, todos/, tasks/, plans/ (项目数据)"
echo ""
echo "OpenCode 排除项："
echo "  - node_modules/ (依赖包，可通过 npm install 重新安装)"
echo "  - oh-my-opencode-dev/ (开发目录)"
echo "  - .git/, *.bak, bun.lock (版本控制和备份)"
echo "  - TODO, comment.md, dockerps, start.sh (临时文件)"
echo ""
if [ "$DRY_RUN" = false ]; then
    echo "下一步："
    echo "  1. 在远程服务器安装 OpenCode 依赖："
    echo "     ssh ${REMOTE_USER}@${REMOTE_HOST} 'cd ${REMOTE_BASE}/.config/opencode && npm install'"
    echo ""
    echo "  2. 验证配置是否正确："
    echo "     ssh ${REMOTE_USER}@${REMOTE_HOST} 'ls -la ${REMOTE_BASE}/.claude ${REMOTE_BASE}/.config/opencode'"
fi
