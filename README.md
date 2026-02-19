# 🔄 配置同步工具

快速将 Claude 和 OpenCode 配置同步到远程服务器 `remote_ip`。

## 🚀 快速开始

```bash
cd ~/.config/opencode

# 1. 预览将要同步的文件（推荐）
./sync-config.sh --dry-run

# 2. 执行同步
./sync-config.sh

# 3. 在远程服务器安装依赖
ssh root@remote_ip 'cd ~/.config/opencode && npm install'
```

## 📁 文件说明

| 文件 | 说明 |
|------|------|
| `sync-config.sh` | 主同步脚本 |
| `sync-exclude.txt` | 排除文件列表 |
| `SYNC_SUMMARY.md` | 文件清单（快速参考） |
| `SYNC_GUIDE.md` | 详细使用指南 |

## ✅ 同步的文件

### Claude
- `settings.json` - 主配置
- `rules/` - 规则文件
- `skills/` - 技能文件
- `plugins/` - 插件配置

### OpenCode
- `opencode.json` - 主配置
- `prompts/` - 提示词模板
- `.agents/` - Agent 配置
- `package.json` - 依赖配置

## ❌ 排除的文件

### 已排除（不需要同步）
- **聊天记录**: `transcripts/`, `history.jsonl`
- **缓存**: `cache/`, `*.cache`
- **日志**: `debug/`, `*.log`
- **会话数据**: `sessions/`, `session-env/`
- **依赖包**: `node_modules/`（可通过 npm install 安装）
- **开发目录**: `oh-my-opencode-dev/`
- **其他**: `.git/`, `*.bak`, 临时文件等

## 📊 同步统计

- **需要同步**: ~50MB（主要是 plugins）
- **已排除**: ~44MB（节省传输量）

## 🔧 自定义

编辑 `sync-exclude.txt` 来修改排除规则。

## 📖 更多信息

- 详细指南: `SYNC_GUIDE.md`
- 文件清单: `SYNC_SUMMARY.md`
