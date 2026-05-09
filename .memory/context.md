# what-is-installed — Project Context

## Active Branches
- `main` — primary development branch

## Current State
- 28 commits (2026-05-10, Hermes review)
- Shell script project at ~/Documents/Projects/what-is-installed
- 679 LOC (bin/what-is-installed 353, lib/platform.sh 79, lib/render.sh 247)
- 136 LOC tests (tests/run.sh, all passing)
- Desktop launcher at ~/Desktop/what-is-installed.command (18 lines, Finder double-click compatible)
- Git remote is configured; verify current owner/upstream with `git remote -v` before publishing or reporting.
- `bin/what-is-installed` has ~120 lines of uncommitted changes from prior session — review before committing.
- No CI configured (no .github/workflows)
- `~/.local/bin/what-is-installed` is the stable local PATH wrapper. Source: Codex.

## Purpose
Scans PATH for commands in non-system directories and displays their version numbers. Supports cross-platform (macOS/Linux/BSD/MinGW/Cygwin), caching, timeout, multi-format output (table/JSON/CSV/plain).

## Environment
- Bash 3.2+ compatible
- Shell scripts in bin/ and lib/

## Known Issues
- No CI pipeline (shellcheck + tests should run on push)
- Uncommitted changes in bin/what-is-installed from prior agent session
