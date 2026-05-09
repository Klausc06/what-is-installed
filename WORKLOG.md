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
