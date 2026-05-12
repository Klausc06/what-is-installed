# what-is-installed 改进方案（修订版）

> **状态：全部完成 ✅** — 截至 v0.4.1，本文档中提出的所有改进均已实现。
> Phase 1（超时 + 加速 + 转码）、Phase 2（平台抽象）、Phase 3（模块化 + JSON/CSV/plain 输出）全部就绪。
> CI（GitHub Actions macOS + Ubuntu + Windows）已配置。本文件保留作为设计记录。

## 核心原则

what-is-installed 是一个纯 Bash 工具，零外部依赖。改进必须遵循两条硬约束：

1. **不引入任何外部依赖** — 不依赖 jq、python、GNU coreutils
2. **改进幅度与当前规模匹配** — 不过度工程化，不做 500 行设计来服务 300 行代码

## 当前代码的主要问题

基于对 `bin/what-is-installed` 的实际审查：

| 问题 | 位置 | 影响 |
|---|---|---|
| 无超时机制 | 72-74 行 | 任一命令卡住（等待 stdin、挂死），整个扫描永久阻塞 |
| 无跨调用缓存 | 62-93 行（仅内存缓存） | 每次运行重新探测所有命令版本，~12s |
| brew 无加速 | 72 行 | `brew --version` 每次都触发 `brew update` 检查，耗时数秒 |
| macOS 硬编码 | 133 行、101-109 行 | system_dirs 正则在 Linux 下语义错误，section_label 把 `/opt/homebrew/bin` 写死 |
| family 去重是 macOS-ism | 178 行 | 过滤 `*-intel64`、`*-arm64`、`*.py`、`*-config`，Linux 下无意义且可能误杀 |
| `BASH_REMATCH` 无 fallback | 81-87 行 | 命令输出非 UTF-8 时正则静默失败，返回 `-` 但无诊断 |

---

## Phase 1 — 修复真实痛点（预计 +80 行，不改架构）

**目标：运行时间 12s → < 2s，消除卡死风险。**

### 1.1 纯 Bash 超时机制

当前 72-74 行没有超时保护。使用双 fork 模式实现跨平台超时：

```bash
# 可移植的超时执行：后台运行 cmd，同时启动一个 sleep-killer
run_with_timeout() {
  local cmd="$1" timeout="${2:-3}" pid killer output exit_code

  output="$("$cmd" --version 2>/dev/null)" &
  pid=$!

  { sleep "$timeout"; kill "$pid" 2>/dev/null; } &
  killer=$!

  wait "$pid" 2>/dev/null
  exit_code=$?

  kill "$killer" 2>/dev/null
  wait "$killer" 2>/dev/null  # 回收僵尸，避免 SIGCHLD 堆积

  if [[ $exit_code -eq 143 || $exit_code -eq 137 ]]; then
    echo ""  # 被 SIGTERM/SIGKILL 杀掉
    return 124
  fi
  echo "$output"
  return $exit_code
}
```

**跨平台分析：** `&`、`$!`、`wait`、`kill`、`$SECONDS` 全部是 POSIX/Bash 内建，macOS 自带 Bash 3.2、Linux Bash 4+、Git Bash 均支持。Bash 3.2 兼容性关键点：`kill` 不带信号名时默认 SIGTERM（POSIX 保证），`wait` 返回被信号杀死的进程的 128+signal 退出码。

### 1.2 文件缓存

用 `declare -p` 导出关联数组（而非 JSON），这是纯 Bash 下唯一零依赖且可靠的序列化方案：

```
缓存文件：$XDG_CACHE_HOME/what-is-installed/versions.cache（fallback: ~/.cache/what-is-installed/）
```

```bash
# 写入缓存 —— declare -p 生成合法的 Bash 赋值语句
write_cache() {
  local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/what-is-installed"
  mkdir -p "$cache_dir"
  {
    echo "CACHE_TS=$SECONDS_AT_START"
    declare -p CACHE_NAMES 2>/dev/null || echo "declare -a CACHE_NAMES=()"
    declare -p CACHE_VALS  2>/dev/null || echo "declare -a CACHE_VALS=()"
  } > "$cache_dir/versions.cache"
}

# 读取缓存 —— source 即可恢复变量
load_cache() {
  local cache_file="${XDG_CACHE_HOME:-$HOME/.cache}/what-is-installed/versions.cache"
  [[ -f "$cache_file" ]] || return 1
  local now=${SECONDS}
  source "$cache_file"
  [[ -n "${CACHE_TS:-}" && $(( now - CACHE_TS )) -lt ${CACHE_TTL:-3600} ]] || return 1
}
```

**为什么不 JSON：** 纯 Bash 解析 JSON 要么引入 jq 依赖，要么写出上百行的脆弱解析器。`declare -p` / `source` 组合是 Bash 原生的序列化/反序列化方案，零依赖、零风险。

### 1.3 条件性命令加速

替代当前方案中把 brew 写死的做法，用一个可扩展但轻量的加速表：

```bash
# 命令加速映射：在探测命令版本时注入环境变量
declare -A VERSION_PROBE_ENV=(
  ["brew"]="HOMEBREW_NO_AUTO_UPDATE=1"
  # 未来可扩展：["snap"]="SNAP_NO_UPDATE_CHECK=1"
  # 不需要任何平台判断，规则为空的环境变量在本平台不存在的命令上天然无匹配
)
```

用于 `get_command_version()` 改造：

```bash
local env_prefix="${VERSION_PROBE_ENV[$cmd]:-}"
if [[ -n "$env_prefix" ]]; then
  output="$(env $env_prefix "$cmd" --version 2>/dev/null)"
else
  output="$("$cmd" --version 2>/dev/null)"
fi
```

### 1.4 版本探测加固

当前代码不处理命令输出为非 UTF-8 的情况。增加一层 `iconv` fallback：

```bash
# 尝试 UTF-8 → 如果失败，用 iconv 从 Latin-1 转码（iconv 是 POSIX 工具，非额外依赖）
sanitize_output() {
  local raw="$1"
  if printf '%s' "$raw" | iconv -f utf-8 -t utf-8 >/dev/null 2>&1; then
    printf '%s' "$raw"
  else
    printf '%s' "$raw" | iconv -f latin1 -t utf-8 2>/dev/null || printf '%s' "$raw"
  fi
}
```

---

## Phase 2 — 平台抽象（预计 +60 行，新增 1 个文件）

**目标：让工具在 Linux/WSL/macOS/Git Bash 上都行为正确。**

### 2.1 新增 lib/platform.sh

单个文件，职责明确：检测 OS，暴露平台相关配置函数。所有其他模块通过它获取平台信息，不做自己的 `uname` 检测。

```bash
# lib/platform.sh — OS 检测与平台差异配置
#
# 被所有其他模块 source，提供以下函数：
#   detect_os()        → macos | linux | bsd | mingw | cygwin
#   get_system_dirs()  → 正则字符串（用于过滤系统目录）
#   get_accel_rules()  → 命令→环境变量的键值对
#   supports_utf8()    → true/false

detect_os() {
  local os
  os="$(uname -s)"
  case "$os" in
    Darwin)  echo macos ;;
    Linux)   echo linux ;;
    *BSD)    echo bsd ;;
    MINGW*|MSYS*) echo mingw ;;
    CYGWIN*) echo cygwin ;;
    *)       echo unknown ;;
  esac
}
```

**重要修正：** 原方案 `detect_os()` 对 Git Bash 返回 `windows`。实际 `uname -s` 在 Git Bash 下返回 `MINGW64_NT-*`、`MSYS_NT-*`，在 MSYS2 下类似，Cygwin 返回 `CYGWIN_NT-*`。必须用通配符匹配。

```bash
get_system_dirs() {
  case "$(detect_os)" in
    macos) printf '%s' '^(/bin|/sbin|/usr/bin|/usr/sbin|/System/|/Library/Apple/)' ;;
    linux) printf '%s' '^(/bin|/sbin|/usr/bin|/usr/sbin|/lib/systemd/)' ;;
    bsd)   printf '%s' '^(/bin|/sbin|/usr/bin|/usr/sbin|/rescue/)' ;;
    mingw|cygwin) printf '%s' '^(/c/Windows/)' ;;
    *)     printf '%s' '^(/bin|/sbin|/usr/bin|/usr/sbin)' ;;
  esac
}

get_family_skip_patterns() {
  case "$(detect_os)" in
    macos) printf '%s' '.*-(intel64|arm64)$' ;;
    *)     printf '%s' '' ;;
  esac
}
```

**修正了原方案遗漏：** 原来代码 178 行的 `*-intel64`、`*-arm64` 过滤是 macOS-ism，在这里收归 `get_family_skip_patterns()` 管理。Linux/BSD 下直接不生效。

### 2.2 新增 --ascii 参数

定位为平台兼容性退路，非美化选项。UTF-8 box-drawing 字符在以下场景显示异常：

- Windows 原生 cmd（非 Windows Terminal）
- 部分 CI 系统的日志渲染器（如 Jenkins 旧版）
- 终端 `$LANG` 不是 UTF-8 的环境

实现：扫描阶段产生的结构化数据不变，仅在渲染层根据 `--ascii` 切换字符集。

### 2.3 新增 --json、--filter、--sort

所有参数在所有平台上语义一致，纯字符串操作。

| 参数 | 实现要点 |
|---|---|
| `--json` | 将结构化中间数据格式化为 JSON。不需要解析 JSON，只做**生成**，`printf` 即可完成 |
| `--filter <pat>` | 模糊匹配命令名，纯 Bash 的 `[[ $name == *$pat* ]]` |
| `--sort name/version/path` | `sort` 命令是 POSIX 的，所有平台都有；或在 Bash 内用数组排序 |

---

## Phase 3 — 模块化（适度拆分，3 文件）

原方案提出 5 个模块，对当前 291 行代码来说过重。建议拆为 3 文件：

```
bin/what-is-installed    # 入口 + 参数解析 + 调度（~100 行）
lib/platform.sh          # OS 检测 + 平台差异配置（~40 行）
lib/core.sh              # 扫描 + 版本探测 + 去重 + 缓存（~200 行）
lib/render.sh            # 表格/JSON/CSV/plain 渲染（~120 行）
```

总行数约 460 行，比原来的 291 行增加约 170 行，但功能覆盖完全不一样。

### 3.1 中间数据格式

扫描层与渲染层之间用统一的中间格式解耦：

```
NAME|VERSION|FULL_PATH|SECTION_LABEL
```

每行一条记录，`|` 分隔。这个格式在 291 行版本里就已经在用了（184 行 `ALL_SECTION_ITEMS`），不需要改，只需要把渲染逻辑从扫描循环中拆出来。

### 3.2 CI 配置

GitHub Actions matrix 在 macOS + Ubuntu 上运行。Bats 测试框架引入为开发依赖（不影响用户安装）。

```yaml
strategy:
  matrix:
    os: [macos-latest, ubuntu-latest]
```

---

## 暂不纳入的项（原 Phase 4）

以下特性当前阶段不做，等工具被实际使用并积累反馈后再评估：

- `--watch` 持续监控模式 — 一个 while 循环不值得单独做功能
- 交互模式 / fzf 集成 — 引入外部依赖
- Homebrew formula / Linuxbrew tap — 分发层面的事，有用户才有意义
- man 手册 — 同样是有用户之后的事
- `command -v` 支持 — 可以检测 shell builtin，但改变了工具定位（从"已安装的命令"变成"可用的命令"），需要单独讨论

---

## 跨平台兼容性汇总

| 功能 | 实现方式 | macOS | Linux | WSL | Git Bash | 需要分岔？ |
|---|---|---|---|---|---|---|
| 文件缓存 | `declare -p` / `source` | ✅ | ✅ | ✅ | ✅ | 否 |
| 超时 | 双 fork + kill + wait | ✅ | ✅ | ✅ | ✅ | 否 |
| 命令加速 | 环境变量映射表 | ✅ | ✅ | ✅ | ✅ | 仅表内容 |
| 系统目录过滤 | `get_system_dirs()` | ✅ | ✅ | ✅ | ✅ | 是，集中到 platform.sh |
| family 去重 | `get_family_skip_patterns()` | ✅ | ✅ | ✅ | ✅ | 是，集中到 platform.sh |
| UTF-8 表格 | box-drawing / --ascii | ✅ | ✅ | ✅ | --ascii 退路 | 否 |
| JSON 输出 | printf 生成 | ✅ | ✅ | ✅ | ✅ | 否 |
| 探测输出转码 | iconv fallback | ✅ | ✅ | ✅ | ✅ | 否 |
| 模块化 | 3 文件 source | ✅ | ✅ | ✅ | ✅ | 否 |
| CI 多平台 | GitHub Actions | ✅ | ✅ | — | — | 仅配置差异 |

---

## 实施顺序建议

```
第 1 轮（一次性）：超时机制 + brew 加速 + 版本探测加固
    → 产出：12s → ~8s，不再卡死，非 UTF-8 输出不炸

第 2 轮（一次性）：文件缓存 + --json + --filter + --ascii
    → 产出：二次运行 ~8s → < 0.5s，JSON 输出可被脚本消费

第 3 轮（一次性）：新增 lib/platform.sh + 模块化拆分
    → 产出：Linux/BSD/Git Bash 行为正确，代码可维护

第 4 轮（按需）：--sort、--include-system、CI 配置
    → 产出：日常使用体验打磨
```
