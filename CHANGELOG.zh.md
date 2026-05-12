# 更新日志

## v0.4.1（2026-05-12）

### 性能优化
- **O(1) 查找**：将 provider 去重、版本缓存、名称去重、家族去重中的 O(n) 线性数组扫描替换为换行分隔字符串 glob 匹配——C 级别实现，兼容 bash 3.2。
- **extglob 外提**：`shopt -s extglob` 从逐行循环内移到循环外，并在函数结束后恢复——消除 winget 大批量输出时数百次冗余 shell 选项切换。
- **单遍渲染**：`render_table` 列宽从逐 section 计算改为全局一次计算，short_path 结果缓存——`short_path` 调用减半。

### 重构
- **移除 `need_trim` 参数**：`_wi_provider_parse_regex` 始终去除名称尾部空格——调用方不再需要了解正则内部细节。
- **提取 `brew_provider`**：原在 `macos.sh` 和 `linux.sh` 中逐字节重复——现在统一在 `lib/providers/brew.sh`。
- **合并 `env_prefix` 逻辑**：`get_command_version` 改为 flag 循环，消除 `--version` / `-V` 中重复的 env_prefix 条件分支。
- **移除死代码**：`SEEN_PATH_DIRS` 数组、6 条 "Filter N" 注释。

## v0.4.0（2026-05-11）

### Windows
- **5 倍提速**：Windows Git Bash 上轮询粒度从 1s 降至 0.2s。
- **路径标签**：Scoop、Chocolatey、AppData、npm Global 目录不再显示为 "Other"。
- **包管理器 provider**：新增 `winget`、`scoop`、`choco` 批量查询，仅 `mingw|cygwin` 平台激活。
- **PowerShell CI**：新增 `powershell-install` job，端到端测试 `install.ps1`。
- **MinGW 过滤修复**：`/mingw` → `/mingw/`，使 MSYS2 环境（`/mingw64/bin`、`/clang64/bin`）显示 "MinGW" 标签。

### Linux
- **路径标签**：Cargo（~/.cargo/bin）、Go（~/go/bin）、nvm、pyenv、Deno、Nix 现可识别。
- **包管理器 provider**：新增 `rpm`（RHEL/Fedora）和 `pacman`（Arch）。
- **架构跳过规则**：`.*-(x86_64|aarch64|i686|armv7l|armhf)$`，跳过多架构系统的变体。（对应 macOS 的 `.*-(intel64|arm64)$`）

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
