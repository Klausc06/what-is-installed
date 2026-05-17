# what-is-installed

[English](#english) | [中文](#中文)

---

<a id="english"></a>

**One command. No config. See every CLI tool on your machine — with versions, grouped by where they came from.**

Runs anywhere Bash runs. Zero dependencies. Works on macOS, Linux, BSD, and Windows (Git Bash).

```bash
what-is-installed
```

<img width="762" height="332" alt="A terminal window running what-is-installed, showing a colored table of CLI tools grouped by source — Homebrew, Cargo, User Local, and npm Global — each with name, version, and path." src="data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='762' height='332'%3E%3Crect width='762' height='332' fill='%231a1a2e' rx='8'/%3E%3Ctext x='20' y='28' font-family='Menlo,monospace' font-size='13' fill='%23888'%3E┌─────────────────────────────── Homebrew ───────────────────────────────┐%3C/text%3E%3Ctext x='20' y='48' font-family='Menlo,monospace' font-size='13' fill='%23888'%3E│%3C/text%3E%3Ctext x='28' y='48' font-family='Menlo,monospace' font-size='13' fill='%23fff'%3EName%3C/text%3E%3Ctext x='160' y='48' font-family='Menlo,monospace' font-size='13' fill='%23888'%3E│%3C/text%3E%3Ctext x='168' y='48' font-family='Menlo,monospace' font-size='13' fill='%23fff'%3EVersion%3C/text%3E%3Ctext x='260' y='48' font-family='Menlo,monospace' font-size='13' fill='%23888'%3E│%3C/text%3E%3Ctext x='268' y='48' font-family='Menlo,monospace' font-size='13' fill='%23fff'%3EPath%3C/text%3E%3Ctext x='740' y='48' font-family='Menlo,monospace' font-size='13' fill='%23888'%3E│%3C/text%3E%3Ctext x='20' y='66' font-family='Menlo,monospace' font-size='13' fill='%23888'%3E├─────────┼──────────┼───────────────────────────────────────┤%3C/text%3E%3Ctext x='28' y='86' font-family='Menlo,monospace' font-size='13' fill='%23fff'%3Egh%3C/text%3E%3Ctext x='168' y='86' font-family='Menlo,monospace' font-size='13' fill='%230f0'%3E2.89.0%3C/text%3E%3Ctext x='268' y='86' font-family='Menlo,monospace' font-size='13' fill='%23888'%3E/opt/homebrew/bin/gh%3C/text%3E%3Ctext x='28' y='104' font-family='Menlo,monospace' font-size='13' fill='%23fff'%3Enode%3C/text%3E%3Ctext x='168' y='104' font-family='Menlo,monospace' font-size='13' fill='%230f0'%3E24.14.0%3C/text%3E%3Ctext x='268' y='104' font-family='Menlo,monospace' font-size='13' fill='%23888'%3E/opt/homebrew/bin/node%3C/text%3E%3Ctext x='28' y='122' font-family='Menlo,monospace' font-size='13' fill='%23fff'%3Epython%3C/text%3E%3Ctext x='168' y='122' font-family='Menlo,monospace' font-size='13' fill='%230f0'%3E3.14.0%3C/text%3E%3Ctext x='268' y='122' font-family='Menlo,monospace' font-size='13' fill='%23888'%3E/opt/homebrew/bin/python%3C/text%3E%3Ctext x='20' y='140' font-family='Menlo,monospace' font-size='13' fill='%23888'%3E└─────────┴──────────┴───────────────────────────────────────┘%3C/text%3E%3Ctext x='20' y='168' font-family='Menlo,monospace' font-size='13' fill='%23888'%3E┌─────────────────────────────── Cargo ─────────────────────────────────┐%3C/text%3E%3Ctext x='20' y='188' font-family='Menlo,monospace' font-size='13' fill='%23888'%3E│%3C/text%3E%3Ctext x='28' y='188' font-family='Menlo,monospace' font-size='13' fill='%23fff'%3EName%3C/text%3E%3Ctext x='160' y='188' font-family='Menlo,monospace' font-size='13' fill='%23888'%3E│%3C/text%3E%3Ctext x='168' y='188' font-family='Menlo,monospace' font-size='13' fill='%23fff'%3EVersion%3C/text%3E%3Ctext x='260' y='188' font-family='Menlo,monospace' font-size='13' fill='%23888'%3E│%3C/text%3E%3Ctext x='268' y='188' font-family='Menlo,monospace' font-size='13' fill='%23fff'%3EPath%3C/text%3E%3Ctext x='740' y='188' font-family='Menlo,monospace' font-size='13' fill='%23888'%3E│%3C/text%3E%3Ctext x='20' y='206' font-family='Menlo,monospace' font-size='13' fill='%23888'%3E├─────────┼──────────┼───────────────────────────────────────┤%3C/text%3E%3Ctext x='28' y='226' font-family='Menlo,monospace' font-size='13' fill='%23fff'%3Eripgrep%3C/text%3E%3Ctext x='168' y='226' font-family='Menlo,monospace' font-size='13' fill='%230f0'%3E15.1.0%3C/text%3E%3Ctext x='268' y='226' font-family='Menlo,monospace' font-size='13' fill='%23888'%3E~/.cargo/bin/rg%3C/text%3E%3Ctext x='28' y='244' font-family='Menlo,monospace' font-size='13' fill='%23fff'%3Ebat%3C/text%3E%3Ctext x='168' y='244' font-family='Menlo,monospace' font-size='13' fill='%230f0'%3E0.26.0%3C/text%3E%3Ctext x='268' y='244' font-family='Menlo,monospace' font-size='13' fill='%23888'%3E~/.cargo/bin/bat%3C/text%3E%3Ctext x='20' y='262' font-family='Menlo,monospace' font-size='13' fill='%23888'%3E└─────────┴──────────┴───────────────────────────────────────┘%3C/text%3E%3Ctext x='20' y='290' font-family='Menlo,monospace' font-size='13' fill='%23888'%3E┌──────────────────────────── User Local ───────────────────────────────┐%3C/text%3E%3Ctext x='20' y='310' font-family='Menlo,monospace' font-size='13' fill='%23888'%3E│%3C/text%3E%3Ctext x='28' y='310' font-family='Menlo,monospace' font-size='13' fill='%23fff'%3Euv%3C/text%3E%3Ctext x='160' y='310' font-family='Menlo,monospace' font-size='13' fill='%23888'%3E│%3C/text%3E%3Ctext x='168' y='310' font-family='Menlo,monospace' font-size='13' fill='%230f0'%3E0.11.8%3C/text%3E%3Ctext x='268' y='310' font-family='Menlo,monospace' font-size='13' fill='%23888'%3E~/.local/bin/uv%3C/text%3E%3Ctext x='20' y='330' font-family='Menlo,monospace' font-size='13' fill='%23888'%3E└─────────┴──────────┴───────────────────────────────────────┘%3C/text%3E%3C/svg%3E">

## Quick Install

Pick your OS:

**macOS / Linux / Windows (Git Bash)**
```bash
git clone https://github.com/what-is-installed/what-is-installed.git && cd what-is-installed && ./install.sh
```

**Windows (PowerShell)**
```powershell
git clone https://github.com/what-is-installed/what-is-installed.git; cd what-is-installed; powershell -ExecutionPolicy Bypass -File install.ps1
```

Done. Run `what-is-installed` — if you see a table, it works.

| Platform | Needs | Optional boost |
|----------|-------|----------------|
| macOS | Nothing | `brew install coreutils` (~15x faster probing) |
| Linux | Nothing | `coreutils` if not already installed |
| Windows | [Git for Windows](https://git-scm.com) | — |

## What It Shows

Each command gets a **name**, **version**, **install path**, and **source label** — auto-detected by where it lives on disk:

| Platform | Labels detected |
|----------|----------------|
| macOS | Homebrew, User Local, npm Global, Python Framework, System Local |
| Linux | Homebrew, Cargo, Go, nvm, pyenv, Deno, Nix, Snap, User Local, npm Global, System Local |
| Windows | MinGW, Scoop, Chocolatey, AppData, npm Global, User Local, System Local |

Commands from `/bin`, `/usr/bin`, and other system directories are skipped — you only see tools you actually installed.

## How It Works

1. **Detect OS** — loads platform-specific rules (system dirs, path labels)
2. **Bulk-query package managers** — `brew`, `cargo`, `winget`, `scoop`, `choco`, `rpm`, `pacman`, `apt`, `snap`, `flatpak` (whichever are present)
3. **Scan PATH** — deduplicate directories, skip system paths, filter out arch-variant siblings
4. **Probe versions** — `--version` then `-V`, semver extraction, Latin1→UTF-8 fallback. Cache hits from step 2 skip probing entirely.
5. **Deduplicate** — same-name shown once; same-version family variants merged
6. **Render** — ANSI box-drawing table, grouped and color-coded by source

`brew install coreutils` gives you GNU `timeout` for fast probing. Without it, the script falls back to a foreground polling loop — works everywhere but is slower.

## No Flags. No Config. No Caches.

- **Every run is live** — no stale disk cache, always a fresh snapshot
- **Zero dependencies** — pure Bash 3.2+, not even `jq`
- **Cross-platform** — macOS, Linux, BSD, MinGW, Cygwin

## Architecture

```
bin/what-is-installed       # Entry point (213 lines)
lib/
  detect.sh                 # OS detection
  shared.sh                 # timeout runner, version probing, cache
  render.sh                 # Box-drawing table + ANSI colors
  platform/
    macos.sh                # macOS: system dirs, section labels
    linux.sh                # Linux: system dirs, apt/snap/flatpak providers
    windows.sh              # Windows (MinGW/Cygwin): Mingw/Scoop/Choco labels
    bsd.sh                  # BSD: system dirs
  providers/
    brew.sh                 # Homebrew (macOS + Linux)
    cargo.sh                # Cargo (cross-platform)
    winget.sh               # Winget (Windows)
    scoop.sh                # Scoop (Windows)
    choco.sh                # Chocolatey (Windows)
    rpm.sh                  # RPM (RHEL/Fedora)
    pacman.sh               # Pacman (Arch/Manjaro)
    _common.sh              # Shared regex parser for winget/scoop
    resolve.sh              # OS-dispatched provider resolver + cache helpers
```

Each platform file exports the same function contract. Adding a platform or package manager means changing one file.

## License

MIT

---

<a id="中文"></a>

**一条命令。零配置。查看你机器上所有的 CLI 工具 —— 带版本号，按来源分组。**

只要有 Bash 就能跑。零依赖。支持 macOS、Linux、BSD 和 Windows（Git Bash）。

```bash
what-is-installed
```

## 快速安装

按系统选择：

**macOS / Linux / Windows（Git Bash）**
```bash
git clone https://github.com/what-is-installed/what-is-installed.git && cd what-is-installed && ./install.sh
```

**Windows（PowerShell）**
```powershell
git clone https://github.com/what-is-installed/what-is-installed.git; cd what-is-installed; powershell -ExecutionPolicy Bypass -File install.ps1
```

搞定。运行 `what-is-installed`，看到彩色表格就说明成功了。

| 平台 | 需要什么 | 可选加速 |
|------|---------|---------|
| macOS | 不用装 | `brew install coreutils`（探测快 ~15 倍） |
| Linux | 不用装 | 装 `coreutils`（如果还没有的话） |
| Windows | [Git for Windows](https://git-scm.com) | — |

## 展示什么

每个命令显示**名称**、**版本**、**安装路径**和**来源标签**——根据文件所在目录自动识别：

| 平台 | 可识别的标签 |
|------|------------|
| macOS | Homebrew、User Local、npm Global、Python Framework、System Local |
| Linux | Homebrew、Cargo、Go、nvm、pyenv、Deno、Nix、Snap、User Local、npm Global、System Local |
| Windows | MinGW、Scoop、Chocolatey、AppData、npm Global、User Local、System Local |

`/bin`、`/usr/bin` 等系统目录中的命令会被自动跳过——你看到的都是自己装的东西。

## 工作原理

1. **检测系统** — 加载对应平台的规则（系统目录、路径标签）
2. **批量查询包管理器** — `brew`、`cargo`、`winget`、`scoop`、`choco`、`rpm`、`pacman`、`apt`、`snap`、`flatpak`（检测到哪个用哪个）
3. **扫描 PATH** — 目录去重，跳过系统路径，过滤架构变体
4. **探测版本** — 先 `--version` 再 `-V`，正则提取 semver，编码 Latin1→UTF-8。步骤 2 已缓存的直接跳过
5. **去重** — 同名命令只显示一次；同版本家族变体合并
6. **渲染** — ANSI 制表符表格，按来源分组，彩色区分

装 `coreutils`（`brew install coreutils`）可以用 GNU `timeout` 快速探测。没有的话脚本会自动降级为前台轮询——到处都能跑，只是慢一点。

## 没有参数。没有配置。没有缓存。

- **每次运行都是实时快照** — 没有磁盘缓存，永远是最新状态
- **零依赖** — 纯 Bash 3.2+，连 `jq` 都不需要
- **跨平台** — macOS、Linux、BSD、MinGW、Cygwin

## 架构

```
bin/what-is-installed       # 入口（127 行）
lib/
  detect.sh                 # 系统检测
  shared.sh                 # 超时执行、版本探测、缓存
  render.sh                 # 制表符表格 + ANSI 色彩
  platform/
    macos.sh                # macOS：系统目录、路径标签
    linux.sh                # Linux：系统目录、apt/snap/flatpak provider
    windows.sh              # Windows（MinGW/Cygwin）：MinGW/Scoop/Choco 标签
    bsd.sh                  # BSD：系统目录
  providers/
    brew.sh                 # Homebrew（macOS + Linux）
    cargo.sh                # Cargo（跨平台）
    winget.sh               # Winget（Windows）
    scoop.sh                # Scoop（Windows）
    choco.sh                # Chocolatey（Windows）
    rpm.sh                  # RPM（RHEL/Fedora）
    pacman.sh               # Pacman（Arch/Manjaro）
    _common.sh              # winget/scoop 共享正则解析
    resolve.sh              # OS 调度 + 缓存辅助
```

每个 platform 文件导出相同接口。新增平台或包管理器只需改一个文件。

## 许可证

MIT
