# 更新日志

## v0.3.0（2026-05-11）

### 性能（macOS 15 倍加速）
- 检测 `gtimeout`（Homebrew coreutils）—— 原来轮询回退每条命令至少等 1 秒。`brew install coreutils` 即可加速。
- `--version` 超时时跳过 `-V` 重试。
- 基线：219 秒 → 14 秒（精选 PATH，101 个工具）。新增 `bench/run.sh`。

### 架构
- 按 OS 拆分 `lib/platform.sh` 和 `lib/providers.sh`：`lib/platform/{macos,linux,windows,bsd}.sh`、`lib/providers/{cargo,resolve}.sh`。
- 提取共享代码到 `lib/detect.sh` 和 `lib/shared.sh`。

### 移除
- 磁盘缓存（1 小时 TSV）。每次运行都是实时快照。速度来自 provider 批量查询 + GNU timeout。

## v0.2.0（2026-05-10）

### 性能
- 先过滤后探测：去重、跳过规则、屏蔽列表在版本探测前执行。
- Provider 层：`brew list --versions` + `cargo install --list` 批量取版本号。
- 进度点细化（每 20 次探测）。

### 安全
- 移除 macOS 启动器的 `eval "$(brew shellenv)"`，改为硬编码 PATH。
- stderr 捕获：`2>/dev/null` → `2>&1`，Java/Python 等工具不再被静默跳过。

### 仓库
- 规范路径：`~/Documents/Projects/what-is-installed`。旧克隆归档到 `repo-backups/`。
- README 双语重写，删除过期功能描述。

## v0.1.0（2026-05-07 ~ 2026-05-09）

- 动态 PATH 扫描，`--version` / `-V` 探测，semver 提取
- 智能去重（名称 + 家族），架构后缀跳过
- 盒形表格 + ANSI 色彩，按来源分组
- 跨平台：macOS、Linux、BSD、Windows（MinGW/Cygwin）
- Bash 3.2+，零依赖
- `install.sh` + 桌面启动器（`.command`、`.desktop`、`.bat`）
- `install.ps1`（PowerShell）
- Windows CI（shellcheck + 测试），CRLF 安全
- 3-agent 审查修复 16 个 bug
- 零 CLI 参数 —— 直接运行 `what-is-installed`
