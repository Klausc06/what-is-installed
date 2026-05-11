# Changelog

## 2026-05-11

### Performance: 15x Faster on macOS

First run with curated PATH dropped from **219 seconds to 14 seconds** after two optimizations:

- **gtimeout detection** — macOS Homebrew installs GNU timeout as `gtimeout` (coreutils). The polling fallback had a 1-second floor per command due to zombie process behavior. GNU timeout avoids this entirely. `brew install coreutils` for the speedup.
- **Skip -V on timeout** — commands that timeout on `--version` no longer retry with `-V`, saving a second per unsupported command.

Added `bench/run.sh` for reproducible performance tracking.

### Architecture: Code Split by OS

- `lib/platform.sh` and `lib/providers.sh` split into per-OS files
- New structure: `lib/platform/{macos,linux,windows,bsd}.sh`, `lib/providers/{cargo,resolve}.sh`
- Each platform file exports the same function contract; main script sources only the active OS
- Shared utilities extracted to `lib/detect.sh` and `lib/shared.sh`

### Removed: Disk Cache

- Removed the 1-hour TSV disk cache (`load_cache` / `write_cache` / escape functions)
- Every run is now a fresh, live snapshot
- Speed comes from provider bulk queries (`brew list --versions`, `cargo install --list`) and GNU timeout

## 2026-05-10

### Performance: Filter-Before-Probe + Provider Architecture

- **Filter reordering** — dedup, skip patterns (`*-config`, `*.py`, `-intel64`/`-arm64`), and blocklist now checked before version probing, avoiding wasted process execution
- **Provider layer** — `brew list --versions` (0.68s for ~48 packages) and `cargo install --list` bulk version queries pre-populate cache arrays, bypassing individual `--version` probes
- **Per-command progress dots** — every 20 probes instead of one per directory

### Security & Bug Fixes

- **Removed `eval "$(brew shellenv)"`** from macOS launcher — replaced with hardcoded PATH
- **Fixed stderr discard** in version probe — `2>/dev/null` changed to `2>&1` so tools that write version to stderr (Java, Python) are no longer silently skipped
- External 6-report audit fixes landed

### Repository

- Canonical local path confirmed: `~/Documents/Projects/what-is-installed`
- Old loose clones archived to `~/Documents/Projects/repo-backups/`
- README rewritten (bilingual), stale features removed, current architecture documented

## 2026-05-09

### Cross-Platform

- **Windows CI** — GitHub Actions on `windows-latest` (shellcheck + tests), all green
- **CRLF safety** — `core.autocrlf=false`, strip CR before shellcheck
- **Windows hardening** — foreground polling timeout (no background kill), `/mingw*` filtered, `.bat` wrapper
- `install.ps1` for PowerShell users (PATH via registry)

### Fixes

- 16 bugs fixed from 3-agent review (NO_COLOR guard, atomic cache, empty array init, nullglob, iconv guard, family dedup, version regex, null byte filter, table alignment, platform detection)
- Timeout hang on Windows Git Bash (kill silently fails)
- Symlink resolution for installed entrypoints

## 2026-05-07/08

### Initial Release

- Dynamic PATH scanning, version detection (`--version` / `-V`, semver extraction, latin1→UTF-8 fallback)
- Smart deduplication (name + family, architecture suffix skip)
- Box-drawing table with ANSI colors, grouped by source category
- Cross-platform: macOS, Linux, BSD, Windows (MinGW/Cygwin)
- Bash 3.2+ compatible, zero dependencies
- `install.sh` with desktop launchers (`.command`, `.desktop`, `.bat`)
- TSV disk cache (1h TTL, safe parser)
- Removed all CLI options — zero-config philosophy
