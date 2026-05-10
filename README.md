# what-is-installed

[English](#english) | [中文](#中文)

---

<a id="english"></a>

Scan your `$PATH` and see every CLI tool you have — with versions, grouped by source, in a beautiful table.

No dependencies. Works on macOS, Linux, BSD, and Windows (MinGW/Cygwin). Zero-config. Every run is a live snapshot.

## Features

- **Dynamic PATH scanning** — no hardcoded lists, reads `$PATH` directly
- **Fast provider layer** — queries `brew list --versions`, `cargo install --list` in bulk instead of probing each command individually
- **Filter-before-probe** — dedup, skip patterns, and blocklist checked before version probing
- **Version detection** — probes `--version` then `-V`, extracts semver, handles encoding fallback
- **Smart deduplication** — same command shown once; family variants (python3.12 / python3) deduplicated
- **Beautiful output** — box-drawing tables with ANSI colors, grouped by source category
- **Cross-platform** — macOS, Linux, BSD, MinGW, Cygwin. Bash 3.2+ compatible.
- **System directory filtering** — skips `/bin`, `/sbin`, `/usr/*`, `/System/` by default
- **Timeout protection** — per-command 1s timeout with polling fallback for Windows
- **Zero dependencies** — pure Bash, not even `jq`

## Quick Install

### Prerequisites

The only thing you need is **Bash** — it's built into macOS and Linux. Windows users need Git Bash (included with Git for Windows).

| Platform | What you need | How to get it |
|----------|--------------|---------------|
| macOS | Nothing — Terminal is built-in | — |
| Linux | Nothing — any terminal works | — |
| Windows | **Git for Windows** (includes Git Bash) | [git-scm.com](https://git-scm.com) — install, then open "Git Bash" from Start Menu |

### Install

**macOS / Linux**

Open Terminal and run:

```bash
git clone https://github.com/Klausc06/what-is-installed.git
cd what-is-installed
./install.sh
```

**Windows (Git Bash)**

Open Git Bash from Start Menu and run:

```bash
git clone https://github.com/Klausc06/what-is-installed.git
cd what-is-installed
./install.sh
```

**Windows (PowerShell)**

Open PowerShell and run:

```powershell
git clone https://github.com/Klausc06/what-is-installed.git
cd what-is-installed
powershell -ExecutionPolicy Bypass -File install.ps1
```

That's it. You'll get:
- `what-is-installed` linked to `~/.local/bin/`
- **macOS**: A double-clickable `.command` launcher on your Desktop
- **Linux**: A `.desktop` entry on your Desktop (detected via `xdg-user-dir`, works across locales)
- **Windows**: A `.bat` launcher on your Desktop — double-click to run (Git Bash required)

### Verify

```bash
what-is-installed
```

If you see a colored table of your CLI tools, it's working. If you get "command not found", make sure `~/.local/bin` is in your PATH (the installer warns you if it isn't).

## Usage

```bash
what-is-installed
```

That's it. No flags, no options, no config. Run it and get a live snapshot of every CLI tool on your system.

### Sample Output

```
┌─────────────── Homebrew ────────────────┐
│ Name   │ Version │ Path                 │
├───────┼────────┼─────────────────────┤
│ gh     │ 2.89.0  │ /opt/homebrew/bin/gh │
│ node   │ 24.14.0 │ /opt/homebrew/bin/node│
│ python │ 3.14.0  │ /opt/homebrew/bin/python│
└───────┴────────┴─────────────────────┘

┌─────────────── User Local ───────────────┐
│ Name │ Version │ Path                    │
├─────┼────────┼────────────────────────┤
│ uv   │ 0.11.8  │ ~/.local/bin/uv         │
│ fcc  │ 1.2.3   │ ~/.local/bin/fcc        │
└─────┴────────┴────────────────────────┘
```

## Supported Platforms

| OS | Detection | System dirs filtered | Launcher |
|----|-----------|---------------------|----------|
| macOS | `Darwin` | `/bin`, `/sbin`, `/usr/*`, `/System/`, `/Library/Apple/` | `.command` |
| Linux | `Linux` | `/bin`, `/sbin`, `/usr/*`, `/lib/systemd/` | `.desktop` |
| BSD | `*BSD` | `/bin`, `/sbin`, `/usr/*`, `/rescue/` | — |
| MinGW | `MINGW*` | `/c/Windows/` | `.bat` |
| Cygwin | `CYGWIN*` | `/c/Windows/` | `.bat` |

Source categories are auto-detected per platform (Homebrew, Snap, npm Global, Python Framework, etc.).

## How It Works

1. Detects your OS and loads the matching platform support
2. Queries available package managers (`brew list --versions`, `cargo install --list`) for bulk version data
3. Reads `$PATH`, deduplicates directories while preserving order
4. For each non-system directory, filters executables (dedup, skip patterns, blocklist) **before** probing
5. Probes `--version` on remaining commands (falls back to `-V`, handles latin1→UTF-8); cache-hit from provider data skips the probe
6. Extracts semver via regex; marks `-` if undetectable
7. Deduplicates by name + family (e.g. `python3.12` and `python3.11` with same version)
8. Groups results by source category with colored box-drawing tables

## Architecture

```
bin/what-is-installed       # Main entry point (~160 lines)
lib/
  detect.sh                 # OS detection
  shared.sh                 # Cross-platform utils + version probing
  render.sh                 # Table rendering + ANSI colors
  platform/
    macos.sh                # macOS: system dirs, section labels, brew provider
    linux.sh                # Linux: system dirs, apt/snap/flatpak providers
    windows.sh              # Windows (MinGW/Cygwin) support
    bsd.sh                  # BSD support
  providers/
    cargo.sh                # Cargo provider (cross-platform)
    resolve.sh              # OS-dispatched provider resolver
```

Each `platform/*.sh` exports the same function contract (`get_system_dirs`, `section_label`, `section_color`, `get_accel_env`). The main script sources only the active OS file. Adding a new platform or package manager means changing one file.

## Built With

[Hermes](https://github.com/nousresearch/hermes-agent) ·
[Claude Code](https://claude.ai) ·
[Codex](https://github.com/openai/codex) ·
[DeepSeek](https://deepseek.com) ·
[OpenCode](https://github.com/anthropics/opencode) ·
[WorkBuddy](https://workbuddy.dev) ·
[free-claude-code](https://github.com/Klausc06/free-claude-code) ·
[Homebrew](https://brew.sh) ·
Bash

## License

MIT

---

<a id="中文"></a>

扫描你的 `$PATH`，查看所有已安装的 CLI 工具——带版本号、按来源分组、精美表格展示。

零依赖。支持 macOS、Linux、BSD 和 Windows（MinGW/Cygwin）。开箱即用。每次运行都是实时快照。

## 功能特性

- **动态 PATH 扫描** — 无硬编码列表，直接读取 `$PATH`
- **快速 Provider 层** — 用 `brew list --versions`、`cargo install --list` 批量拿版本，不逐条执行
- **先过滤后探测** — 去重、跳过规则、屏蔽列表在版本探测前执行，减少无效进程调用
- **版本检测** — 先探测 `--version`，再降级到 `-V`，提取 semver，处理编码回退
- **智能去重** — 同名命令只显示一次；家族变体（python3.12 / python3）自动去重
- **精美输出** — ANSI 色彩 + 制表符边框，按来源分组
- **跨平台** — macOS、Linux、BSD、MinGW、Cygwin，兼容 Bash 3.2+
- **系统目录过滤** — 默认跳过 `/bin`、`/sbin`、`/usr/*`、`/System/`
- **超时保护** — 每个命令 1 秒超时，Windows 用前台轮询
- **零依赖** — 纯 Bash，连 `jq` 都不需要

## 快速安装

### 前置依赖

只需要 **Bash** — macOS 和 Linux 自带。Windows 用户需要 Git Bash（安装 Git for Windows 时自带）。

| 平台 | 需要的工具 | 怎么获取 |
|------|-----------|---------|
| macOS | 不需要 — 终端自带 | — |
| Linux | 不需要 — 任何终端都行 | — |
| Windows | **Git for Windows**（自带 Git Bash） | [git-scm.com](https://git-scm.com) — 安装后从开始菜单打开 "Git Bash" |

### 安装

**macOS / Linux**

打开终端，运行：

```bash
git clone https://github.com/Klausc06/what-is-installed.git
cd what-is-installed
./install.sh
```

**Windows（Git Bash）**

从开始菜单打开 Git Bash，运行：

```bash
git clone https://github.com/Klausc06/what-is-installed.git
cd what-is-installed
./install.sh
```

**Windows（PowerShell）**

打开 PowerShell，运行：

```powershell
git clone https://github.com/Klausc06/what-is-installed.git
cd what-is-installed
powershell -ExecutionPolicy Bypass -File install.ps1
```

搞定。你会得到：
- `what-is-installed` 链接到 `~/.local/bin/`
- **macOS**：桌面上一个双击即可运行的 `.command` 启动器
- **Linux**：桌面上一个 `.desktop` 快捷方式（通过 `xdg-user-dir` 检测桌面路径，适配各种语言环境）
- **Windows**：桌面上一个 `.bat` 启动器，双击运行（需要安装 Git Bash）

### 验证

```bash
what-is-installed
```

如果看到一张彩色表格列出你的 CLI 工具，就成功了。如果提示 "command not found"，检查 `~/.local/bin` 是否在 PATH 中（安装脚本会提示你）。

## 用法

```bash
what-is-installed
```

就这一条命令。没有参数，没有选项，没有配置。直接运行，得到一张实时的系统工具清单。

### 输出样例

```
┌─────────────── Homebrew ────────────────┐
│ 名称   │ 版本   │ 路径                  │
├───────┼───────┼──────────────────────┤
│ gh     │ 2.89.0 │ /opt/homebrew/bin/gh │
│ node   │ 24.14.0│ /opt/homebrew/bin/node│
│ python │ 3.14.0 │ /opt/homebrew/bin/python│
└───────┴───────┴──────────────────────┘

┌─────────────── User Local ───────────────┐
│ 名称 │ 版本  │ 路径                      │
├─────┼──────┼──────────────────────────┤
│ uv   │ 0.11.8│ ~/.local/bin/uv           │
│ fcc  │ 1.2.3 │ ~/.local/bin/fcc          │
└─────┴──────┴──────────────────────────┘
```

## 支持平台

| 操作系统 | 检测标识 | 过滤的系统目录 | 启动器 |
|---------|---------|--------------|--------|
| macOS | `Darwin` | `/bin`、`/sbin`、`/usr/*`、`/System/`、`/Library/Apple/` | `.command` |
| Linux | `Linux` | `/bin`、`/sbin`、`/usr/*`、`/lib/systemd/` | `.desktop` |
| BSD | `*BSD` | `/bin`、`/sbin`、`/usr/*`、`/rescue/` | — |
| MinGW | `MINGW*` | `/c/Windows/` | `.bat` |
| Cygwin | `CYGWIN*` | `/c/Windows/` | `.bat` |

来源分类按平台自动检测（Homebrew、Snap、npm Global、Python Framework 等）。

## 工作原理

1. 检测操作系统，加载对应的平台支持
2. 查询可用的包管理器（`brew list --versions`、`cargo install --list`）批量拿版本
3. 读取 `$PATH`，去重同时保留原始顺序
4. 遍历每个非系统目录，**在版本探测前**先过滤（去重、跳过规则、屏蔽列表）
5. 对剩余命令探测 `--version`（降级到 `-V`，处理编码）；provider 缓存的命令直接跳过
6. 用正则提取 semver；无法检测则显示 `-`
7. 按名称 + 家族去重（如同一版本的 `python3.12` 和 `python3.11`）
8. 按来源分类，用彩色制表符表格展示

## 架构

```
bin/what-is-installed       # 主入口（~160 行）
lib/
  detect.sh                 # 系统检测
  shared.sh                 # 跨平台工具函数 + 版本探测
  render.sh                 # 表格渲染 + ANSI 色彩
  platform/
    macos.sh                # macOS：系统目录、段标签、brew provider
    linux.sh                # Linux：系统目录、apt/snap/flatpak provider
    windows.sh              # Windows（MinGW/Cygwin）支持
    bsd.sh                  # BSD 支持
  providers/
    cargo.sh                # Cargo provider（跨平台）
    resolve.sh              # OS 调度器
```

每个 `platform/*.sh` 导出相同的函数签名（`get_system_dirs`、`section_label`、`section_color`、`get_accel_env`）。主脚本只加载当前 OS 对应的文件。新增平台或包管理器只需改动一个文件。

## 致谢

[Hermes](https://github.com/nousresearch/hermes-agent) ·
[Claude Code](https://claude.ai) ·
[Codex](https://github.com/openai/codex) ·
[DeepSeek](https://deepseek.com) ·
[OpenCode](https://github.com/anthropics/opencode) ·
[WorkBuddy](https://workbuddy.dev) ·
[free-claude-code](https://github.com/Klausc06/free-claude-code) ·
[Homebrew](https://brew.sh) ·
Bash

## 许可证

MIT
