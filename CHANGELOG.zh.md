# 更新日志

## v0.6.0（2026-05-17）

### 新功能
- **交互式快速检测模式**：先扫描后询问——Pass 1 立即运行（<1s），表格版本列显示 `?`，然后提示"Probe versions? [y/N]"。输入 `y` 则运行 provider + Pass 2 完整版本探测。
- **非 TTY 行为**：管道、CI、脚本中只扫描不提示（破坏性变更——之前默认探测版本）。

### 变更
- `resolve_providers` 仅在用户选择探测版本时运行（扫描模式节省 ~2s）。
- 版本占位符从 `-` 改为 `?`。

### 修复
- **P0**：测试套件（2/2 失败 → 10/10 通过）
- **P0**：`_wi_provider_parse_regex` 命令注入（裸 `$cmd` → `${cmd_arr[@]}`）
- **P1**：Pass 2 子 shell 缓存丢失（不再 re-source detect.sh/shared.sh）
- **P1**：`.sh` 后缀和 `g[` 工具从输出中过滤
- **P1**：`eval "$_orig_extglob"` → 布尔 `shopt` 管理
- **P1**：`install.sh` 完整性预检 + `.bashrc` 备份
- **P1**：`run_with_timeout` 临时文件 trap 清理

### CI
- 新增 macOS runner（`macos-latest`）
- shellcheck 严重度：`error` → `warning`

### 测试
- 7→10 个测试，包括缓存操作、超时、平台契约、扫描模式

## v0.4.3（2026-05-16）

### 安全
- **去重 glob 元字符转义**：PATH 目录和命令名含 `[]*?` 字符可能导致去重误判。添加 `_escape_glob()` 辅助函数，应用到全部三处去重点。
- **临时目录信号清理**：`_PROBE_TMPDIR` 仅在正常退出时删除——被 kill 或中断会残留临时目录。添加 `trap ... EXIT`。
- **mktemp 失败处理**：两处 `mktemp` 调用失败时静默继续，导致下游混乱错误。现在都输出清晰错误消息并优雅退出。

### 重构
- **删除死渲染代码**：`render_json`、`render_csv`、`render_plain`、`dispatch_render`（占 `lib/render.sh` 46%）从未被调用——已删除（-85 行）。
- **去重 `get_accel_env`**：`macos.sh` 和 `linux.sh` 中完全相同的函数——提取到 `lib/shared.sh`。
- **删除未使用变量 `C_RED`**：定义但从未引用。

### 代码质量
- 引用 `$env_prefix`。
- 引用数组追加中的 `$_section_start`。
- 简化 `get_accel_env` 分发——移除冗余的 `declare -f` 守卫。

## v0.4.2（2026-05-15）

### Bug 修复
- **`get_gui_skip_patterns` 缺失导致 Windows/macOS 崩溃**：该函数仅在 `linux.sh` 和 `bsd.sh` 中定义，但主脚本在所有平台无条件调用——在 Windows 和 macOS 上导致 `command not found`。已在 `windows.sh` 和 `macos.sh` 中添加。
- **Windows 下 `install.sh` 不复制 `lib/`**：安装器现在在 Windows 上将 `lib/` 复制到 `~/.local/lib/`。


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

### Bug 修复
- **install.sh 在无桌面 Linux 上崩溃**：`detect_desktop_dir()` 未验证 `xdg-user-dir` 返回的路径是否真实存在就直接返回。在 GitHub Actions runner 及其他无桌面环境中，`cat > "$DESKTOP/..."` 因目录不存在而报错退出。现在函数在返回 xdg 路径前增加 `[[ -d ]]` 检查，失败时 fallback 到 `$HOME`。
- **代码审查优化**：Windows Desktop 检查增加 `$OS == "windows"` 守卫，`local` 声明提到函数顶部。测试增加 `timeout` 缺失诊断和安装提示；`skip()` 支持调用方传入跳过原因。

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
