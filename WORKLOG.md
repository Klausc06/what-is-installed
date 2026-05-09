# WORKLOG -- what-is-installed

A shell tool that dynamically scans `$PATH` to report every installed CLI tool with its version. Zero dependencies.

## 2026-04-30 -- Project Inception and Core Scanner

- Published `what-is-installed` as a small CLI for macOS/Linux.
- Built core engine: read `$PATH`, find executables, probe `--version`/`-V` per command.
- Replaced hardcoded directory list with dynamic PATH scanning.
- Achieved ~10x speedup over the initial naive implementation.
- Added deduplication by command name (same name only probed once).
- Added filtering: skip system directories (`/bin`, `/sbin`, `/usr/*`, `/System/`), helper scripts without version info, and redundant entry variants.
- Removed hardcoded rules for Homebrew/npm/pip -- all filtering is now automatic.
- Added `--quiet` (clean output), `--version`, and `--all` flags.
- Grouped output by source category.
- Fixed multiple compatibility issues with macOS Bash 3.2 (`case` patterns, `set -e`).
- Prevented Homebrew auto-update from blocking the scanner with a sudo prompt.
- Settled on Chinese output with minimal UI after an i18n/English detour.

## 2026-05-05 -- Table Layout and Filtering Refinements

- Introduced box-drawing table layout with ANSI colors for readable output.
- Replaced `find` with shell glob for performance and compatibility.
- Added filtering of `-arm64` suffix variants.
- Simplified deduplication logic.

## 2026-05-07/08 -- Full Paths and Cross-Platform Architecture

- Added full install path display in output.
- Refactored to a cross-platform architecture with result caching, per-command timeout (3s), and multi-format output support.
- Fixed `set -e` exit bug during version probing on macOS Bash 3.2 by using `|| true`.

## 2026-05-08 -- Safety Hardening and Core Tests

- Preserved original `$PATH` directory order while still deduplicating repeated directories by first occurrence.
- Added validation for `--filter` and `--sort`, including missing-value errors and strict `name|version|path` sort fields.
- Replaced executable `source`-based cache loading with a safe TSV parser that does not run user cache contents.
- Strengthened JSON and CSV escaping for quotes, backslashes, tabs, newlines, and carriage returns.
- Added a lightweight Bash test suite covering PATH order, cache behavior, filter/sort validation, sorting, and JSON/CSV escaping.
- Verified with `/bin/bash -n bin/what-is-installed`, `/bin/bash -n lib/render.sh`, and `/bin/bash tests/run.sh`.

## 2026-05-09 -- Desktop Wrapper Repair

- Updated the Desktop wrapper to call `what-is-installed` from `PATH` instead of a machine-specific project checkout path.
- Verified the desktop wrapper syntax and `--help` path.
- Installed a local PATH wrapper at `~/.local/bin/what-is-installed` and added project memory rules requiring logs/memory updates plus local-path leak scans after launcher or wrapper changes. Source: Codex.

## 2026-05-10 — Hermes Review + Bug Fix

- Full project review using requesting-code-review skill and project-review-pattern.
- shellcheck audit: 2 errors (expected, library files), 9 warnings (2 real bugs fixed, 7 false positives from cross-file sourcing), 12 info.
- Fixed SC2183 bug: `lib/render.sh:127` and `:150` printf format strings had 10 `%s` placeholders but only 7 arguments — leftover from when the table had more columns. Border lines were printing 3 empty trailing characters.
- Commit `e7a05f4`: corrected format strings to 7 `%s` matching 7 arguments.
- Desktop `.command` launcher reviewed and confirmed clean (1 info-only shellcheck finding).
- Shell metrics: 679 LOC (353 bin + 79 platform.sh + 247 render.sh), 136 LOC tests.
- Architecture: clean separation (platform → render → main), cross-platform (5 OS families), built-in cache with TSV parser, version probing with encoding fallback, job-control timeouts.
- Clean: no secrets, no eval/exec, no external deps beyond tput.
- Known: `bin/what-is-installed` has 120 lines of uncommitted changes from prior session — not yet committed/pushed.
- CI gap: no GitHub Actions configured (no .github/workflows). Source: Hermes.

### `876d762` — feat: commit prior session safety hardening (Hermes)

Previously uncommitted changes from 2026-05-08 session, committed by Hermes:
- Replaced `source "$cache_file"` with safe TSV parser — cache files are no longer executed as code
- Added `escape_cache_field`/`unescape_cache_field` for safe special-character handling
- Rewrote PATH deduplication to preserve original directory order (was `sort -u`)
- Added `die_usage()` helper for consistent error+usage output
- Added `--filter`/`--sort` missing-value checks and sort field validation (name|version|path)
- Fixed `CACHE_NAMES=("")` empty-element bug → `CACHE_NAMES=()`
- Added `SEEN_PATH_DIRS` for proper duplicate detection
- All tests passing, syntax check clean

30 commits on main, working tree clean.

### `e4afe89` — docs: rewrite README (Hermes)

Complete rewrite from the old Chinese-only output example to a modern English README:
- Full feature list: PATH scanning, version detection, dedup, caching, filtering, sorting, multi-format
- Quick install via git clone + symlink
- All CLI flags documented with examples
- Platform support table (macOS/Linux/BSD/MinGW/Cygwin)
- Architecture diagram
- Sample output showing the current box-drawing table layout

### `65135ce` — refactor: remove all CLI options (Hermes)

Stripped all flags: --help, --no-color, --json, --csv, --plain, --ascii, --filter,
--sort, --no-cache, --include-system. The tool now has zero options — just run it.
- Removed usage(), die_usage(), flag parsing, OUTPUT_FORMAT dispatch
- Cache is always on (transparent), colors auto-detect terminal, system dirs always filtered
- Tests simplified: removed filter/sort tests, kept PATH order + cache safety + escape helpers
- `42eebc7`: README updated to reflect flagless design (both English and Chinese)

Lines: 353 → 261 in bin/what-is-installed (-92)

### `c0f8cf1` — feat: install.sh with Desktop launcher (Hermes)

Created `install.sh` that does everything in one command:
- Symlinks `bin/what-is-installed` → `~/.local/bin/what-is-installed`
- Copies `launchers/what-is-installed.command` → `~/Desktop/` (macOS Finder double-click)
- Checks if `~/.local/bin` is in PATH, warns if not
- Added launcher template to repo (`launchers/what-is-installed.command`)

User experience: `git clone && cd && ./install.sh` — done. Desktop icon appears.

### `b7a58f7` — feat: cross-platform Desktop launcher detection (Hermes)

Replaced hardcoded `~/Desktop` with `xdg-user-dir DESKTOP` (Linux locale-safe) +
fallback chain (`~/Desktop`, `~/桌面`, `$HOME`). Platform-specific launchers:
- macOS: `.command` file (Finder double-click)
- Linux: `.desktop` entry (freedesktop.org standard, `Terminal=true`)
- Other: terminal-only, graceful skip

Added `launchers/what-is-installed.desktop` template to repo.

### `eeb36f7` — feat: Windows .bat launcher (Hermes)

Added MinGW/Cygwin/Git Bash support to `install.sh`:
- Detects `MINGW*`/`MSYS*`/`CYGWIN*` via `uname -s`
- Creates `what-is-installed.bat` on Desktop (chcp 65001 for UTF-8, calls bash)
- PATH check uses `~/.bashrc`
- Added `launchers/what-is-installed.bat` template

Now all three major platforms have Desktop launchers: .command (macOS), .desktop (Linux), .bat (Windows).

### `ace0767` — `376222f` — docs: Built With / 致谢 section

Added acknowledgments section in both English and Chinese, listing all tools used:
Hermes, Claude Code, Codex, DeepSeek, OpenCode, WorkBuddy, free-claude-code, Homebrew, Bash.

---

## 2026-05-10 — Hermes Final Review

Comprehensive audit of all 44 commits:
- shellcheck: 0 real bugs (all warnings are false positives: library files, cross-file source, intentional patterns)
- tests: all passing
- bash -n: 5/5 scripts syntax clean
- git: working tree clean
- Lines: bin/what-is-installed 261, lib/platform.sh 79, lib/render.sh 247, install.sh 120, tests/run.sh 111

Project state: production-ready. Zero CLI options, three-platform desktop launchers, safe TSV cache, bilingual README.

### `03561c5` — docs: bilingual README with language switcher (Hermes)

Added `[English](#english) | [中文](#中文)` toggle bar at top. Full Chinese translation
of all sections: features, install, usage, examples, platform table, architecture. Uses
GitHub-compatible `<a id>` anchors — no JavaScript required.
