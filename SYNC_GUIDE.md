# 配置同步指南

## 概述
本指南说明如何将 Claude 和 OpenCode 的配置同步到远程服务器 `remote_ip`，同时排除不必要的文件（聊天记录、缓存、日志等）。

## 同步目标
- **远程服务器**: `remote_ip`
- **远程用户**: `root`
- **远程路径**: `~`

## Claude 配置 (~/.claude)

### ✅ 需要同步的文件/目录

| 文件/目录 | 说明 | 大小 |
|---------|------|------|
| `settings.json` | Claude 主配置文件 | ~4KB |
| `rules/` | 自定义规则文件（agents.md, coding-style.md 等） | ~32KB |
| `skills/` | 自定义技能文件 | ~0KB |
| `plugins/` | 插件配置（排除 cache 子目录） | ~47MB |

**注意**: `plugins/` 目录较大，但包含重要的插件配置。如果只需要配置而不需要插件代码，可以只同步配置文件。

### ❌ 不需要同步的文件/目录（已排除）

| 文件/目录 | 说明 | 大小 | 排除原因 |
|---------|------|------|---------|
| `cache/` | 缓存文件 | ~88KB | 本地缓存，可重新生成 |
| `debug/` | 调试日志 | ~2.7MB | 调试信息，不需要 |
| `transcripts/` | 聊天记录 | ~1.4MB | 个人聊天历史，不需要同步 |
| `sessions/` | 会话数据 | ~84KB | 会话状态，本地特定 |
| `history.jsonl` | 历史记录 | ~20KB | 使用历史，本地特定 |
| `file-history/` | 文件历史 | ~608KB | 文件操作历史 |
| `shell-snapshots/` | Shell 快照 | ~384KB | Shell 状态快照 |
| `stats-cache.json` | 统计缓存 | ~4KB | 统计数据缓存 |
| `statsig/` | 统计分析 | ~36KB | 统计相关数据 |
| `projects/` | 项目数据 | ~10MB | 项目特定数据 |
| `todos/` | 待办事项 | ~104KB | 本地待办事项 |
| `tasks/` | 任务数据 | ~8KB | 任务状态 |
| `plans/` | 计划数据 | ~12KB | 计划状态 |
| `session-env/` | 会话环境 | ~0KB | 环境变量 |
| `downloads/` | 下载文件 | ~0KB | 临时下载文件 |
| `ide/` | IDE 相关 | ~32KB | 可能包含缓存 |

## OpenCode 配置 (~/.config/opencode)

### ✅ 需要同步的文件/目录

| 文件/目录 | 说明 | 大小 |
|---------|------|------|
| `opencode.json` | OpenCode 主配置文件 | ~4KB |
| `prompts/` | 提示词模板文件 | ~28KB |
| `.agents/` | Agent 配置和技能 | ~几KB |
| `package.json` | 依赖配置（用于重新安装） | ~4KB |
| `.gitignore` | Git 忽略规则 | ~45B |

### ❌ 不需要同步的文件/目录（已排除）

| 文件/目录 | 说明 | 大小 | 排除原因 |
|---------|------|------|---------|
| `node_modules/` | Node.js 依赖包 | ~6.2MB | 可通过 `npm install` 重新安装 |
| `oh-my-opencode-dev/` | 开发目录 | ~23MB | 开发相关，不需要 |
| `.git/` | Git 仓库 | ~几KB | 版本控制，不需要同步 |
| `*.bak` | 备份文件 | ~几KB | 备份文件 |
| `bun.lock` | Bun 锁定文件 | ~4KB | 锁定文件，可重新生成 |
| `TODO` | 待办事项 | ~4KB | 临时文件 |
| `comment.md` | 注释文件 | ~12KB | 临时文件 |
| `dockerps` | Docker 相关 | ~4KB | 临时文件 |
| `start.sh` | 启动脚本 | ~289B | 临时文件 |
| `oh-my-opencode.json` | 其他配置 | ~4KB | 重复配置 |
| `oh-my-opencode copy.json` | 备份配置 | ~4KB | 备份文件 |

## 使用方法

### 快速同步
运行同步脚本：
```bash
cd ~/.config/opencode
./sync-config.sh
```

### 手动同步
如果需要手动同步特定目录，可以使用：

```bash
# 同步 Claude settings.json
scp ~/.claude/settings.json root@remote_ip:~/.claude/

# 同步 Claude rules
rsync -av ~/.claude/rules/ root@remote_ip:~/.claude/rules/

# 同步 OpenCode 配置
scp ~/.config/opencode/opencode.json root@remote_ip:~/.config/opencode/
rsync -av ~/.config/opencode/prompts/ root@remote_ip:~/.config/opencode/prompts/
```

### 在远程服务器上安装依赖
同步完成后，在远程服务器上运行：
```bash
cd ~/.config/opencode
npm install
```

## 同步策略说明

### 为什么排除这些文件？

1. **聊天记录和会话数据**: 这些是个人使用历史，不同机器之间不需要共享
2. **缓存文件**: 缓存可以重新生成，同步会浪费带宽和时间
3. **日志文件**: 调试日志是本地特定的，不需要同步
4. **node_modules**: 依赖包可以通过包管理器重新安装，避免同步大量文件
5. **开发目录**: 开发相关的临时文件和目录不需要同步

### 为什么同步这些文件？

1. **配置文件**: 包含个人设置和偏好，需要同步以保持一致性
2. **规则和技能**: 自定义的规则和技能是工作流程的一部分
3. **提示词模板**: 自定义的提示词模板需要同步
4. **插件配置**: 插件配置需要同步，但排除缓存目录

## 注意事项

1. **首次同步**: 首次同步可能需要一些时间，特别是 `plugins/` 目录较大
2. **后续同步**: 后续同步会更快，因为只同步变更的文件
3. **权限**: 确保远程服务器有足够的权限创建目录和文件
4. **网络**: 确保网络连接稳定，大文件传输可能需要一些时间
5. **备份**: 建议在同步前备份远程服务器的现有配置

## 故障排除

### 如果同步失败
1. 检查 SSH 连接：`ssh root@remote_ip`
2. 检查远程目录权限：`ls -la ~`
3. 检查磁盘空间：`df -h ~`

### 如果配置不生效
1. 检查文件权限：确保配置文件有正确的读取权限
2. 检查路径：确保配置文件在正确的位置
3. 重启应用：某些配置需要重启应用才能生效
