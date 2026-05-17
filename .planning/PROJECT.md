# PROJECT: what-is-installed

**Repository**: https://github.com/what-is-installed/what-is-installed
**Language**: Pure Bash (Shell)
**Current Version**: v0.4.3
**Description**: CLI tool that scans $PATH for executables, probes versions, and renders a grouped table.

## Stack

- Bash 3.2+ compatible (cross-platform: macOS, Linux, Windows/Git Bash)
- No external dependencies beyond standard Unix tools
- CI: GitHub Actions (ubuntu-latest only)
- Testing: custom Bash test framework (`tests/run.sh`)

## Architecture

```
bin/what-is-installed          # Entry point (215 lines), two-pass: collect→probe
lib/
  detect.sh                   # OS detection
  shared.sh                   # Cache, timeout, version probing
  render.sh                   # Box-drawing table output
  platform/                   # Platform contracts (macos, linux, windows, bsd)
  providers/                  # Provider contracts (brew, cargo, winget, etc.)
    _common.sh                # Shared provider utilities
    resolve.sh                # Provider resolution
```

## Conventions

- Bash 3.2 compatible (no `declare -A`, no `mapfile`)
- `shellcheck` CI (currently `--severity=error` only)
- Provider/platform plugin contracts for extensibility
- Two-pass execution: collect tool names → probe versions in parallel batches of 32
- Cross-platform: tested on macOS, Ubuntu, Windows (via CI only)

## Current State (2026-05-17)

- Functional: detects 237 tools on macOS in ~6s
- Test suite: **BROKEN** (2/2 fail, CI should be red)
- Security: 1 high-severity command injection vector, 4 medium findings
- Coverage: ~5% estimated
- 23 total findings from full inspection (code review + security audit + QA)
