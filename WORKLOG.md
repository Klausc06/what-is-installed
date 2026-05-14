# WORKLOG -- what-is-installed

A shell tool that dynamically scans `$PATH` to report every installed CLI tool with its version. Zero dependencies, zero CLI options.

## 2026-05-12 — install.sh crash fix

- Fixed `detect_desktop_dir()` crash on headless Linux: xdg-user-dir paths now validated with `[[ -d ]]` before return. Falls through to `$HOME` when Desktop doesn't exist. 4 CI failures resolved.
- Code review polish: Windows Desktop check gated on OS, `local` hoisted, test timeout diagnostic, `skip()` reason parameter.

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

### OS Code Split

- Split `lib/platform.sh` and `lib/providers.sh` into per-OS files
- New structure: `lib/detect.sh` (OS detection), `lib/shared.sh` (cross-platform utils), `lib/platform/{macos,linux,windows,bsd}.sh`, `lib/providers/{cargo,resolve}.sh`
- Each platform file exports the same function contract; main script sources only the active OS

### Performance Optimizations Round 2

- **Skip -V on timeout**: commands that timeout on `--version` no longer retry with `-V`, saving 1s per unsupported command.
- **gtimeout detection**: macOS Homebrew installs GNU timeout as `gtimeout` (coreutils). `run_with_timeout` now checks both `timeout` and `gtimeout`. Using GNU timeout avoids the polling fallback which had a 1s floor per command due to zombie process behavior.
- **Benchmark script**: `bench/run.sh` with curated PATH for reproducible performance tracking.
- Results: 219s (baseline) → 212s (skip -V) → 14s (gtimeout). **15x speedup.**

### Performance Optimization (Phase 1+2+5)

- **Phase 1**: Reordered filter before probe — SEEN_NAMES, FAMILY_SKIP, *-config/*.py checks now run before get_command_version(), eliminating wasted version probing for commands that would be skipped.
- **Phase 2**: Added `lib/providers.sh` — brew_provider (`brew list --versions`, 0.68s for 48 packages) and cargo_provider bulk version queries. Providers populate cache arrays before PATH scan; get_command_version() returns cached hits without process execution.
- **Phase 5**: Per-command progress dots every 20 probes (was per-directory).

## Current State

100 commits on main. Clean tree. 0 shellcheck errors. All tests pass.
Windows CI: ✅ all-green (shellcheck + tests on windows-latest). PowerShell install test added.

## 2026-05-11 — Windows Optimization (Hermes, subagent-driven)

### Plan → Subagent Execution
- Plan written to `.hermes/plans/2026-05-11_windows-optimization.md`
- 5 tasks dispatched: 3 parallel implementers + 2 serial; each with 2-stage review (spec compliance → code quality)

### Performance: Polling Granularity (`c4086e4`)
- `run_with_timeout` fallback loop: `sleep 1` → `sleep 0.2` with `max_ticks = timeout * 5`
- ~5x faster probing on Windows Git Bash (no GNU timeout)
- macOS/Linux unaffected (use GNU timeout path)

### Windows Path Labels (`0ff6c65`, `d9d80d8`)
- Added labels: Scoop, Chocolatey, AppData, npm Global — no more "Other"
- Color-coded: Cyan (Scoop), Yellow (Choco), Blue (AppData)
- **Review catching** (`d9d80d8`): Quality review found MinGW labels were dead code — `/mingw` in get_system_dirs matched `/mingw64/bin` too, filtering before section_label ran. Fixed: `/mingw` → `/mingw/` (trailing slash). Also added npm Global with correct case ordering (before broader AppData pattern)
- shellcheck SC2221/SC2222 caught the ordering bug — npm before AppData

### Windows Package Manager Providers (`b5d03ff`)
- 3 new files: `lib/providers/{winget,scoop,choco}.sh`
- Pattern: bulk-query versions before PATH scan (like brew/cargo providers)
- Gated on `mingw|cygwin` platform + `command -v` availability
- Modified `resolve.sh` (new case block) + `bin/what-is-installed` (source 3 files)
- **Review finding**: winget regex misses multi-word names (Microsoft Edge, VS Code) — fallback probing still works, non-blocking

### CI: PowerShell Install Test (`3c04112`)
- New `powershell-install` job in `.github/workflows/ci.yml`
- Runs `install.ps1`, verifies PATH, runs tool via bash, runs tests

### Session Stats
- 8 files changed, 88 insertions, 3 deletions
- 0 shellcheck errors, all tests pass
- 5 commits, 3 subagent implementers, 5 review stages
- Commit count: 92 → 100

## 2026-05-11 — Linux Optimization (Hermes, subagent-driven)

### Subagent Execution
- Plan written to `.hermes/plans/2026-05-11_linux-optimization.md`
- 3 tasks dispatched in parallel; each with verification (shellcheck + tests)

### Path Labels (`7be1d1f`)
- Added 6 Linux dev tool labels: Cargo, Go, nvm, pyenv, Deno, Nix
- Color-coded: Cargo (Yellow), Go (Cyan), nvm (Green), pyenv (Blue), Deno (Green), Nix (Blue)
- Total Linux labels: 5 → 11

### Architecture Skip Patterns (`7be1d1f`)
- `get_family_skip_patterns`: added `.*-(x86_64|aarch64|i686|armv7l|armhf)$`
- Mirrors macOS `.*-(intel64|arm64)$` — skips arch-variant siblings on multi-arch systems

### rpm and pacman Providers (`068616c`)
- 2 new files: `lib/providers/{rpm,pacman}.sh`
- rpm: `rpm -qa --queryformat '%{NAME} %{VERSION}\n'` with 5s timeout, skips gpg-pubkey
- pacman: `pacman -Q` with 3s timeout
- Modified `resolve.sh` + `bin/what-is-installed` (source new files)
- Linux providers: 3 → 5 (apt, snap, flatpak, rpm, pacman)

### Session Stats
- 5 files changed, 42 insertions, 1 deletion
- 0 shellcheck errors, all tests pass
- 3 commits (2 subagent, 1 docs)
- Commit count: 100 → 103

## Current State

103 commits on main. Clean tree. 0 shellcheck errors. All tests pass.
Windows CI: ✅ all-green

## 2026-05-11 — Code Review Fixes (Hermes)

### Review Findings
- Code review against v0.4.0 changes found 3 non-blocking suggestions

### Fix: Remove unnecessary `|| true` (`c793539`)
- winget.sh, scoop.sh, choco.sh had `|| true` on process substitution — bash `set -e` doesn't propagate subshell exit codes from process substitutions, making it redundant. Aligned with the other 5 providers.

### Fix: Winget multi-word package names (`a28790c`)
- Old regex `^([^[:space:]]+)` only captured single-token names. New regex `^(.+)[[:space:]]{2,}` uses column-boundary matching, then trims trailing spaces with `%%+([[:space:]])`. Now captures all 14/14 test cases including 5-word names.
- Two independent subagent regex audits confirmed the fix (first audit caught `\s`/`.+?` incompatibility with bash POSIX ERE)

### Refactor: Extract shared provider regex parser (`5074bae`)
- New `lib/providers/_common.sh` with `_wi_provider_parse_regex(timeout, cmd, regex, need_trim)`
- winget.sh: 17→5 lines, scoop.sh: 17→5 lines
- `bin/what-is-installed`: source `_common.sh` before winget/scoop

### Session Stats
- 4 commits, 4 files changed (+ new _common.sh)
- Commit count: 103 → 108

## 2026-05-12 — Simplify: Code Review + Performance (Claude Code /simplify)

### Review Process
- Three parallel agents (Reuse, Quality, Efficiency) reviewed recent changes + full codebase
- 8 issues identified and fixed in a single commit

### Perf: O(1) lookups with string-based dedup
- Replaced `_wi_provider_name_exists` O(n) array scan with `[[ $str == *$'\n'$name=* ]]` glob match
- Replaced `get_command_version` cache linear scan with string-based lookup
- Replaced `SEEN_NAMES` and `SEEN_FAMILIES`/`SEEN_VERSIONS` O(n) scans with newline-delimited strings
- Added `_wi_cache_add()` helper in resolve.sh to keep CACHE_NAMES/VALS + `_CACHE_STR` in sync
- All provider files updated to use `_wi_cache_add`

### Perf: Hoist extglob + remove need_trim
- `shopt -s extglob` was inside per-line while loop — moved before loop, restored after
- Removed `need_trim` parameter — always trim trailing whitespace (idempotent operation)
- winget.sh/scoop.sh callers simplified

### Refactor: Dedup brew_provider
- `brew_provider()` was byte-identical in macos.sh and linux.sh
- Extracted to `lib/providers/brew.sh`, sourced before resolve.sh

### Refactor: Dedup env_prefix in get_command_version
- `--version` / `-V` blocks duplicated env_prefix conditional — replaced with flag loop

### Perf: Single-pass render_table
- Column widths now computed once globally (not per-section), `short_path` results cached
- Fixes visual inconsistency where columns shifted between sections

### Cleanup
- Removed dead `SEEN_PATH_DIRS` array (populated but never read)
- Deleted 6 "Filter N:" comments

### Session Stats
- 1 commit, 14 files changed (+ new brew.sh)
- +76 -126 (net -50)
- Commit count: 108 → 109

## 2026-05-12 — README Rewrite + Repo Cleanup

### README Rewrite
- Condensed opening to one-sentence value prop
- Single-command install per platform (clone + install in one line)
- Platform label table (macOS/Linux/Windows)
- Updated architecture tree with all 12 provider files
- Removed verbose feature list and "Built With" section
- Simplified "How It Works" to 6 steps, accurate 127-line count

### Repo Cleanup
- Removed `XIAOHONGSHU-COMMENTS.md` — unrelated social media content
- Marked `IMPROVEMENT-PROPOSAL.md` as completed (all proposals implemented)
- Updated `CLAUDE.md` architecture section to v0.4.1
- Fixed stale commit counts in `.memory/context.md`

### Session Stats
- 1 commit (README) + pending cleanup commit
- Commit count: 109 → 111

## Current State

131 commits on main. 0 shellcheck errors, 2 tests pass. Linux CI: shellcheck + tests + smoke (install + run). Windows CI: shellcheck + tests. PowerShell CI: install.ps1 e2e + tests.

## 2026-05-14 — Performance + Safety Session (Hermes)

### Base merge (1313bab)
- Reset main to origin/main (v0.4.1 + code review fixes)
- Cherry-picked 3 improvements from backup/phase-1-3:
  - `declare -f` guards on all 9 provider dispatch calls (resolve.sh)
  - Insertion sort (_sort_cache) + binary search (_cache_lookup) in shared.sh
  - Two-pass loop structure: Pass 1 collect candidates, Pass 2 probe versions

### Parallel probing (d588c91)
- Reduced probe timeout 1s → 0.3s (most tools return in ~10ms)
- Pass 2 refactored to 32-way parallel batch probing (subshell + wait)
- Result: 16.5s → 4.5s (3.7x speedup on macOS, 366 candidates)

### GUI skip filter (e28411c)
- Added `get_gui_skip_patterns()` to all 4 platform files
- Wired `GUI_SKIP` into Pass 1 candidate collection
- Blacklists per platform:
  - Windows: ~40 system GUI tools (notepad, mspaint, explorer, regedit...)
  - Linux: ~30 desktop GUI tools (xdg-open, zenity, gnome-terminal...)
  - BSD: ~9 X11 utilities (xterm, xclock, startx...)
  - macOS: empty (GUI apps live in /Applications/*.app, not PATH)
- Fixes: friend's classroom monitoring detecting window launches during probing

### Session Stats
- 3 commits pushed. Local backup retained as `backup/phase-1-3`
