# Changelog

## v0.3.0 (2026-05-11)

### Speed (15x on macOS)
- Detect `gtimeout` (Homebrew coreutils) — avoids polling fallback that slept 1s per command. `brew install coreutils` for the boost.
- Skip `-V` retry when `--version` times out.
- Baseline: 219s → 14s (curated PATH, 101 tools). Added `bench/run.sh`.

### Architecture
- Split `lib/platform.sh` and `lib/providers.sh` by OS: `lib/platform/{macos,linux,windows,bsd}.sh`, `lib/providers/{cargo,resolve}.sh`.
- Extracted shared code to `lib/detect.sh` and `lib/shared.sh`.

### Removed
- Disk cache (1h TSV). Every run is a fresh snapshot. Speed is from provider bulk queries + GNU timeout.

## v0.2.0 (2026-05-10)

### Performance
- Filter-before-probe: dedup, skip patterns, blocklist checked before version probing.
- Provider layer: `brew list --versions` + `cargo install --list` bulk version queries.
- Per-command progress dots (every 20 probes).

### Security
- Removed `eval "$(brew shellenv)"` from macOS launcher — hardcoded PATH.
- Stderr capture: `2>/dev/null` → `2>&1` so Java/Python tools aren't silently skipped.

### Repository
- Canonical path: `~/Documents/Projects/what-is-installed`. Old clones archived to `repo-backups/`.
- README rewritten (bilingual), stale features removed.

## v0.1.0 (2026-05-07 ~ 2026-05-09)

- Dynamic PATH scanning, `--version` / `-V` probing, semver extraction
- Smart dedup (name + family), architecture suffix skip
- Box-drawing table with ANSI colors, grouped by source
- Cross-platform: macOS, Linux, BSD, Windows (MinGW/Cygwin)
- Bash 3.2+, zero dependencies
- `install.sh` + desktop launchers (`.command`, `.desktop`, `.bat`)
- `install.ps1` (PowerShell)
- Windows CI (shellcheck + tests), CRLF safety
- 16 bugs fixed from 3-agent review
- Zero CLI options — just run `what-is-installed`
