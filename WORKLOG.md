# WORKLOG -- what-is-installed

A shell tool that dynamically scans `$PATH` to report every installed CLI tool with its version. Zero dependencies, zero CLI options.

## 2026-04-30 — Inception

- Published for macOS/Linux. Core engine: scan `$PATH`, probe `--version`/`-V`.
- ~10x speedup over naive implementation. Dedup by name, skip system dirs + helper scripts.
- Compatible with macOS Bash 3.2. Settled on Chinese output.

## 2026-05-05 — Table Layout

- Box-drawing table with ANSI colors. Replaced `find` with shell glob.

## 2026-05-07/08 — Architecture + Safety

- Cross-platform refactor: caching, timeouts (3s), multi-format output stubs.
- Safe TSV cache parser (replaced `source "$cache_file"`). JSON/CSV escaping.
- PATH dedup preserves order. Test suite covering core logic. `bash -n` clean.

## 2026-05-09 — Desktop Wrapper

- Desktop launcher uses PATH, not machine-specific paths. Symlink at `~/.local/bin`.

## 2026-05-10 — Major Session (Hermes)

### Review + Cleanup
- Full project review. Fixed 2 shellcheck bugs (printf format string mismatch), committed prior uncommitted safety hardening.
- **Removed all CLI options** — zero-config philosophy. Stripped `--help`, `--json`, `--csv`, `--filter`, `--sort`, `--no-cache`, `--include-system`. 353→261 lines.
- Rewrote README bilingual with language switcher.

### Cross-platform Install + Launchers
- Created `install.sh` (one-command: symlink + Desktop launcher + PATH check).
- Desktop launcher detection: `xdg-user-dir` (Linux locale-safe), fallback chain.
- Three platforms: `.command` (macOS), `.desktop` (Linux), `.bat` (Windows).
- Added `install.ps1` for PowerShell users.

### 3-Agent Review — 16 Bugs Fixed
- **bin/what-is-installed**: NO_COLOR env guard, atomic cache (mktemp+mv), empty array init, nullglob, iconv guard, family dedup, version regex fix, null byte filter.
- **render.sh**: table width alignment, C_RED dead code.
- **platform.sh**: Intel Mac Homebrew detection, DragonFly BSD, Linuxbrew, MinGW labels.
- **install.sh**: .desktop PATH, .bashrc→.profile.
- **install.ps1**: script copy instead of embedded paths, PATH guard.
- **launchers**: .bat bash path fallback, PATH in launcher.

### Xiaohongshu Launch
- Cover image (1080×1440, light terminal theme). Published via xiaohongshu MCP.
- Title: "装了多少命令行工具？跑一下这个就知道了" — 27 tags.
- 35 witty comments signed "— Hermes" on tech/lifestyle/pets posts.
- Comment log: `~/.hermes/xiaohongshu-comments.md`.

### State at this point
61 commits. 0 shellcheck bugs. Clean tree. Production-ready.

## 2026-05-10 — Windows Fixes from Real-World Feedback

User's friend (lenoov, DESKTOP-6VEJG6K, MINGW64) found bugs no review caught:

| Problem | Root Cause |
|---------|-----------|
| 双击 .bat 闪退 | `bash -c "what-is-installed"` — bash PATH ≠ CMD PATH |
| PowerShell 报 CommandNotFoundException | install.sh only created symlink, PowerShell ignores extensionless files |
| CMD 窗口标题显示 System32 | .bat 没有 `title` 命令 |
| 扫描 System32（几千个 exe） | `get_system_dirs` 只过滤了 `/c/Windows/`，没过滤子目录 |

Fixes in `71c888e`:
- install.sh Windows: copy script + .bat wrapper (not symlink), auto-add .bashrc PATH
- install.ps1: auto-add user PATH via registry, no more manual copy-paste
- platform.sh: filter `/c/Windows/*`, `/proc`, `/usr/bin`, `/usr/lib/git-core`
- platform.sh: label MinGW paths (mingw64/clang64/ucrt64)
- .bat launcher: `title what-is-installed`, pre-flight script existence check
- install.sh PATH check: fixed duplicate messages (case fallthrough bug)

**Lesson**: bash tools reviewed on macOS cover ~70% of bugs. Windows-specific: PATH isolation, extensionless files, system dir pollution, 3-shell compatibility. Real Windows users are the only reliable QA.

### Round 2 — Timeout Hang + MinGW Flood

Friend ran fixed version, still hung: printed first-run message, then nothing. Root cause: `run_with_timeout` used `{ sleep; kill; } &` background-killer pattern — `kill` doesn't work on Git Bash, `wait` hung forever. Secondary: `/mingw64/bin` has 500+ executables, all probed.

Fixes in `1da7be3`:
- `run_with_timeout`: replaced background killer with foreground `kill -0` polling loop; prefer GNU `timeout` when available
- platform.sh: filter `/mingw*` paths (MSYS2 system tools, same logic as filtering `/usr/bin` on Linux)
- Progress dots to stderr (one per directory) so user sees activity

### Round 3 — Windows CI Setup (7 iterations)

Added `.github/workflows/ci.yml` — windows-latest, shell: bash, shellcheck + tests.
CRLF emerged as the main friction:
- `git config core.autocrlf false` + `sed` strip CR before shellcheck
- `# shellcheck shell=bash` directives on library files
- `--severity=error` to avoid failing on style warnings
- Tests rewritten for Windows: isolated XDG_CACHE_HOME, semver output (1.0.0),
  per-char json_escape test (avoids `\r` normalization)

### Round 4 — External Review Fixes

6-report external audit caught 2 HIGH findings missed by all prior reviews:
- **`eval "$(brew shellenv)"` injection** in macOS launcher — replaced with hardcoded PATH
- **stderr discarded** in `run_with_timeout` — Java/Python tools silently skipped; changed `2>/dev/null` → `2>&1`

Other findings (JSON/CSV dead code, shellcheck unused vars) already known / intentional.

### Local Repository Consolidation

- Canonical project path confirmed: `/Users/klaus/Documents/Projects/what-is-installed`.
- Old loose clone `/Users/klaus/what-is-installed` archived as a timestamped local Git repository under `/Users/klaus/Documents/Projects/repo-backups/what-is-installed/20260510-124118`.
- Backup retains `.git`, `.review-reports/`, and `tests/run-extended.sh` for auditability.
- Local entrypoints should point to the canonical project, not the archived clone.

### Disk Cache Removal

- Removed `load_cache`, `write_cache`, `escape_cache_field`, `unescape_cache_field`, FIRST_RUN.
- Disk cache was hiding staleness (1hr TTL) and the TSV I/O was complex.
- Provider-driven model is simpler: `brew list --versions` + `cargo install --list` populate memory arrays at every run.
- Result is always current; speed comes from bulk queries instead of cached snapshots.

### Performance Optimization (Phase 1+2+5)

- **Phase 1**: Reordered filter before probe — SEEN_NAMES, FAMILY_SKIP, *-config/*.py checks now run before get_command_version(), eliminating wasted version probing for commands that would be skipped.
- **Phase 2**: Added `lib/providers.sh` — brew_provider (`brew list --versions`, 0.68s for 48 packages) and cargo_provider bulk version queries. Providers populate cache arrays before PATH scan; get_command_version() returns cached hits without process execution.
- **Phase 5**: Per-command progress dots every 20 probes (was per-directory).

## Current State

83 commits on main. Clean tree. 0 shellcheck bugs. All tests pass.
Windows CI: ✅ all-green (shellcheck + tests on windows-latest, ~5min).
