# 配置同步文件清单

## 📋 快速参考

### ✅ 需要同步的文件（配置文件）

#### Claude (~/.claude)
- ✅ `settings.json` - 主配置文件
- ✅ `rules/` - 自定义规则文件
- ✅ `skills/` - 自定义技能文件  
- ✅ `plugins/` - 插件配置（排除 cache 子目录）

#### OpenCode (~/.config/opencode)
- ✅ `opencode.json` - 主配置文件
- ✅ `prompts/` - 提示词模板
- ✅ `.agents/` - Agent 配置和技能
- ✅ `package.json` - 依赖配置
- ✅ `.gitignore` - Git 忽略规则

---

### ❌ 不需要同步的文件（已排除）

#### Claude (~/.claude)
- ❌ `cache/` - 缓存文件（~88KB）
- ❌ `debug/` - 调试日志（~2.7MB）
- ❌ `transcripts/` - **聊天记录**（~1.4MB）
- ❌ `sessions/` - 会话数据（~84KB）
- ❌ `history.jsonl` - **历史记录**（~20KB）
- ❌ `file-history/` - 文件历史（~608KB）
- ❌ `shell-snapshots/` - Shell 快照（~384KB）
- ❌ `stats-cache.json` - 统计缓存（~4KB）
- ❌ `statsig/` - 统计分析（~36KB）
- ❌ `projects/` - 项目数据（~10MB）
- ❌ `todos/` - 待办事项（~104KB）
- ❌ `tasks/` - 任务数据（~8KB）
- ❌ `plans/` - 计划数据（~12KB）
- ❌ `session-env/` - 会话环境
- ❌ `downloads/` - 下载文件
- ❌ `ide/` - IDE 相关（可能包含缓存）

#### OpenCode (~/.config/opencode)
- ❌ `node_modules/` - **依赖包**（~6.2MB，可通过 npm install 重新安装）
- ❌ `oh-my-opencode-dev/` - **开发目录**（~23MB）
- ❌ `.git/` - Git 仓库
- ❌ `*.bak` - 备份文件
- ❌ `bun.lock` - Bun 锁定文件
- ❌ `TODO` - 待办事项
- ❌ `comment.md` - 注释文件
- ❌ `dockerps` - Docker 相关
- ❌ `start.sh` - 启动脚本
- ❌ `oh-my-opencode.json` - 其他配置
- ❌ `oh-my-opencode copy.json` - 备份配置

---

## 🚀 使用方法

### 1. 预览模式（推荐首次使用）
```bash
cd ~/.config/opencode
./sync-config.sh --dry-run
```

### 2. 执行同步
```bash
./sync-config.sh
```

### 3. 在远程服务器安装依赖
```bash
ssh root@remote_ip
cd ~/.config/opencode
npm install
```

---

## 📊 文件大小估算

### 需要同步的文件大小
- Claude 配置: ~50MB（主要是 plugins 目录）
- OpenCode 配置: ~50KB（排除 node_modules 和开发目录）

### 排除的文件大小
- Claude 排除: ~15MB（主要是 transcripts, projects, debug）
- OpenCode 排除: ~29MB（主要是 node_modules 和开发目录）

**总计节省**: ~44MB 的传输量

---

## 🔍 排除原因说明

### 为什么排除这些文件？

1. **聊天记录 (transcripts/)** - 个人使用历史，不同机器不需要共享
2. **缓存文件 (cache/)** - 可以重新生成，同步浪费带宽
3. **日志文件 (debug/, *.log)** - 调试信息，本地特定
4. **会话数据 (sessions/)** - 会话状态，本地特定
5. **node_modules/** - 依赖包可通过包管理器重新安装
6. **开发目录** - 开发相关的临时文件和目录
7. **历史记录** - 使用历史，本地特定

### 为什么同步这些文件？

1. **配置文件** - 包含个人设置和偏好
2. **规则和技能** - 自定义的工作流程
3. **提示词模板** - 自定义的提示词
4. **插件配置** - 插件设置需要同步

---

## ⚙️ 自定义排除规则

如果需要修改排除规则，编辑 `sync-exclude.txt` 文件：

```bash
vim ~/.config/opencode/sync-exclude.txt
```

排除规则使用 rsync 的排除模式语法。
