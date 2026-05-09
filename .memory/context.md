# what-is-installed — Project Context

## Active Branches
- `main` — primary development branch

## Current State
- 66 commits (2026-05-10)
- Working tree clean
- 0 shellcheck bugs, all tests pass
- 3-platform launchers: .command (macOS), .desktop (Linux), .bat (Windows)
- install.sh creates .bat wrapper on Windows (CMD/PowerShell compat)
- install.ps1 auto-adds PATH to registry
- Bilingual README with language switcher
- Xiaohongshu published + 35 comments
- Progress dots to stderr during scanning
- No CI configured (Windows CI pending, shell: bash on windows-latest)

## Critical Windows Knowledge
- `run_with_timeout` uses foreground polling (NOT background kill — Git Bash kill fails)
- `/mingw*` paths filtered as system dirs (500+ MSYS2 executables)
- System32, /proc, /usr/bin, /usr/lib/git-core also filtered on mingw/cygwin

## Purpose
Scans PATH for commands in non-system directories and displays version numbers.
Cross-platform: macOS/Linux/BSD/MinGW/Cygwin. Caching, timeout, TSV-based safe cache.

## Environment
- Bash 3.2+ compatible
- Shell scripts in bin/ and lib/
