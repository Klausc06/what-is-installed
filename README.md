# what-is-installed

[English](#english) | [中文](#中文)

---

<a id="english"></a>

Scan your `$PATH` and see every CLI tool you have — with versions, grouped by source, in a beautiful table.

No dependencies. Works on macOS, Linux, BSD, and Windows (MinGW/Cygwin). Zero-config.

## Features

- **Dynamic PATH scanning** — no hardcoded lists, reads `$PATH` directly
- **Version detection** — probes `--version` then `-V`, extracts semver, handles encoding fallback
- **Smart deduplication** — same command shown once; family variants (python3.12 / python3) deduplicated
- **Beautiful output** — box-drawing tables with ANSI colors, grouped by source category
- **Multiple formats** — table (default), JSON, CSV, and plain text
- **File cache** — TSV-based cache (1h TTL) speeds up repeat runs; safe parser, no `source` exec
- **Filtering & sorting** — fuzzy filter by name, sort by name/version/path
- **Cross-platform** — macOS, Linux, BSD, MinGW, Cygwin. Bash 3.2+ compatible.
- **System directory filtering** — skips `/bin`, `/sbin`, `/usr/*`, `/System/` by default
- **Timeout protection** — per-command 1s timeout with job-control killer
- **Zero dependencies** — pure Bash, not even `jq`

## Quick Install

```bash
# Works in any Bash terminal: macOS Terminal, Linux shell, Git Bash on Windows
git clone https://github.com/Klausc06/what-is-installed.git
cd what-is-installed
./install.sh
```

That's it. You'll get:
- `what-is-installed` symlinked to `~/.local/bin/`
- **macOS**: A double-clickable `.command` launcher on your Desktop
- **Linux**: A `.desktop` entry on your Desktop (detected via `xdg-user-dir`, works across locales)
- **Windows**: A `.bat` launcher on your Desktop (requires Git Bash / MinGW in PATH)
- **Other platforms**: Terminal-only; run `what-is-installed` directly

## Usage

```bash
what-is-installed
```

That's it. No flags, no options, no config. Run it and get a beautiful table of every CLI tool on your system.

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

1. Reads `$PATH`, deduplicates directories while preserving order
2. For each non-system directory, finds executable files
3. Probes `--version` on each command (falls back to `-V`, handles latin1→UTF-8)
4. Extracts semver via regex; marks `-` if undetectable
5. Deduplicates by name + family (e.g. `python3.12` and `python3.11` with same version)
6. Groups results by source category with colored box-drawing tables
7. Caches results to `~/.cache/what-is-installed/versions.cache` (1-hour TTL)

## Architecture

```
bin/what-is-installed     # Main script (353 lines)
lib/platform.sh           # OS detection, system dirs, category labels (79 lines)
lib/render.sh             # Table/JSON/CSV/plain rendering, colors, cache escaping (247 lines)
```

## Built With

Built with tools this project itself can inventory —

[Hermes](https://github.com/nousresearch/hermes-agent) ·
[Claude Code](https://claude.ai) ·
[Codex](https://github.com/openai/codex) ·
[OpenCode](https://github.com/anthropics/opencode) ·
[WorkBuddy](https://workbuddy.dev) ·
[free-claude-code](https://github.com/Klausc06/free-claude-code) ·
[DeepSeek](https://deepseek.com) ·
[Homebrew](https://brew.sh) ·
Bash

## License

MIT

---

<a id="中文"></a>

扫描你的 `$PATH`，查看所有已安装的 CLI 工具——带版本号、按来源分组、精美表格展示。

零依赖。支持 macOS、Linux、BSD 和 Windows（MinGW/Cygwin）。开箱即用。

## 功能特性

- **动态 PATH 扫描** — 无硬编码列表，直接读取 `$PATH`
- **版本检测** — 先探测 `--version`，再降级到 `-V`，提取 semver，处理编码回退
- **智能去重** — 同名命令只显示一次；家族变体（python3.12 / python3）自动去重
- **精美输出** — ANSI 色彩 + 制表符边框，按来源分组
- **多格式支持** — 表格（默认）、JSON、CSV、纯文本
- **文件缓存** — TSV 格式缓存（1 小时有效期），安全解析器，不用 `source` 执行
- **过滤与排序** — 按名称模糊过滤，按名称/版本/路径排序
- **跨平台** — macOS、Linux、BSD、MinGW、Cygwin，兼容 Bash 3.2+
- **系统目录过滤** — 默认跳过 `/bin`、`/sbin`、`/usr/*`、`/System/`
- **超时保护** — 每个命令 1 秒超时，job-control 杀手模式
- **零依赖** — 纯 Bash，连 `jq` 都不需要

## 快速安装

```bash
# 适用于任何 Bash 终端：macOS 终端、Linux shell、Windows Git Bash
git clone https://github.com/Klausc06/what-is-installed.git
cd what-is-installed
./install.sh
```

搞定。你会得到：
- `what-is-installed` 软链接到 `~/.local/bin/`
- **macOS**：桌面上一个双击即可运行的 `.command` 启动器
- **Linux**：桌面上一个 `.desktop` 快捷方式（通过 `xdg-user-dir` 检测桌面路径，适配各种语言环境）
- **Windows**：桌面上一个 `.bat` 启动器（需要 Git Bash / MinGW 在 PATH 中）
- **其他平台**：仅终端模式；直接运行 `what-is-installed`

## 用法

```bash
what-is-installed
```

就这一条命令。没有参数，没有选项，没有配置。直接运行，得到一张漂亮的系统工具清单表格。

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

1. 读取 `$PATH`，去重同时保留原始顺序
2. 遍历每个非系统目录，找出可执行文件
3. 对每个命令探测 `--version`（降级到 `-V`，处理 latin1→UTF-8 编码）
4. 用正则提取 semver；无法检测则显示 `-`
5. 按名称 + 家族去重（如同一版本的 `python3.12` 和 `python3.11`）
6. 按来源分类，用彩色制表符表格展示
7. 结果缓存到 `~/.cache/what-is-installed/versions.cache`（1 小时有效）

## 架构

```
bin/what-is-installed     # 主脚本（353 行）
lib/platform.sh           # 系统检测、系统目录、分类标签（79 行）
lib/render.sh             # 表格/JSON/CSV/纯文本渲染、颜色、缓存转义（247 行）
```

## 致谢

本项目由以下工具共同打造——

[Hermes](https://github.com/nousresearch/hermes-agent) ·
[Claude Code](https://claude.ai) ·
[Codex](https://github.com/openai/codex) ·
[OpenCode](https://github.com/anthropics/opencode) ·
[WorkBuddy](https://workbuddy.dev) ·
[free-claude-code](https://github.com/Klausc06/free-claude-code) ·
[DeepSeek](https://deepseek.com) ·
[Homebrew](https://brew.sh) ·
Bash

## 许可证

MIT
