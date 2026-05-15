# Changelog


## v0.4.3 (2026-05-16)

### Security
- **Glob metacharacter escaping in dedup**: PATH directories and command names containing `[]*?` characters could cause false-positive dedup matches. Added `_escape_glob()` helper and applied to all three dedup points (directory, name, family+version).
- **Temp dir cleanup on signal**: `_PROBE_TMPDIR` was only removed on clean exit — killed or interrupted processes leaked temp directories. Added `trap ... EXIT`.
- **mktemp failure handling**: Two `mktemp` calls silently continued on failure. Both now emit clear error messages and exit/return gracefully.

### Refactoring
- **Remove dead rendering code**: `render_json`, `render_csv`, `render_plain`, `dispatch_render` (46% of `lib/render.sh`) never called — removed (-85 lines).
- **Deduplicate `get_accel_env`**: Identical function in `macos.sh` and `linux.sh` — extracted to `lib/shared.sh`.
- **Remove unused `C_RED` color variable**: Defined but never referenced.

### Code Quality
- Quote `$env_prefix` in `get_command_version`.
- Quote `$_section_start` in array append.
- Simplify `get_accel_env` dispatch — removed redundant `declare -f` guard.


## v0.4.2 (2026-05-15)

### Bug Fixes
- **Missing `get_gui_skip_patterns` crashes on Windows and macOS**: The function was only defined in `linux.sh` and `bsd.sh`, but the main script calls it unconditionally on all platforms — causing `command not found` on Windows (MinGW/Cygwin) and a crash-on-start on macOS. Added the function to `windows.sh` (empty pattern) and `macOS.sh` (GUI-only tools: `open`, `say`, `screencapture`, etc.).
- **`install.sh` doesn't copy `lib/` on Windows**: On macOS/Linux the installer symlinks the script, resolving `lib/` through the repo source. On Windows it copies only the binary, leaving `lib/` missing. The installer now copies `lib/` to `~/.local/lib/` on Windows.

## v0.4.1 (2026-05-12)

### Performance
- **O(1) lookups**: Replaced O(n) linear array scans in provider dedup (`_wi_provider_name_exists`), version cache (`get_command_version`), name dedup, and family dedup with newline-delimited string glob matching — C-level, bash 3.2 compatible.
- **Hoist extglob**: `shopt -s extglob` moved out of per-line loop in `_wi_provider_parse_regex` — eliminates hundreds of redundant shell-option mutations for large winget outputs.
- **Single-pass render**: `render_table` column widths now computed once globally instead of per-section, with shortened paths cached — halves `short_path` calls.

### Refactoring
- **Remove `need_trim` parameter**: `_wi_provider_parse_regex` always trims trailing whitespace from captured names — callers no longer need to know regex internals.
- **Extract `brew_provider`**: Duplicated byte-for-byte in `macos.sh` and `linux.sh` — now in `lib/providers/brew.sh`, sourced once.
- **Deduplicate `env_prefix` logic**: `get_command_version` uses a flag loop instead of duplicating the env_prefix conditional for `--version` / `-V`.
- **Remove dead code**: `SEEN_PATH_DIRS` array (never read after PATH dedup), 6 "Filter N" comments.

### Bug Fixes
- **install.sh crash on headless Linux**: `detect_desktop_dir()` returned paths from `xdg-user-dir` without verifying the directory existed. On GitHub Actions runners (and other headless environments) this caused `cat > "$DESKTOP/..."` to fail with `No such file or directory`. The function now checks `[[ -d ]]` before returning xdg paths, falling through to `$HOME` as last resort.
- **Code review polish**: Windows Desktop check gated on `$OS == "windows"`, `local` declaration hoisted to function top. Tests now diagnose missing `timeout` dependency with install hints; `skip()` accepts caller-provided reason.

## v0.4.0 (2026-05-11)

### Windows
- **5x faster probing** on Windows Git Bash — polling granularity reduced from 1s to 0.2s in `run_with_timeout` fallback.
- **Path labels**: Scoop, Chocolatey, AppData, and npm Global directories are now labeled (no more "Other").
- **Package manager providers**: `winget`, `scoop`, and `choco` bulk-query versions before PATH scan. Gated on `mingw|cygwin`.
- **PowerShell CI**: new `powershell-install` job tests `install.ps1` end-to-end.
- **MinGW filter fix**: `/mingw` → `/mingw/` so MSYS2 environments (`/mingw64/bin`, `/clang64/bin`) are labeled "MinGW" instead of being filtered as system dirs.

### Linux
- **Path labels**: Cargo (~/.cargo/bin), Go (~/go/bin), nvm, pyenv, Deno, and Nix are now recognized.
- **Package manager providers**: `rpm` (RHEL/Fedora) and `pacman` (Arch) bulk-query versions.
- **Architecture skip patterns**: `.*-(x86_64|aarch64|i686|armv7l|armhf)$` — skips arch-variant siblings on multi-arch systems (mirrors macOS `.*-(intel64|arm64)$`).

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
