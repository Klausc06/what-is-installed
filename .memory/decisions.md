# what-is-installed — Decisions Log

## 2026-05-12: install.sh desktop detection fix
- `detect_desktop_dir()` must validate `xdg-user-dir` output with `[[ -d ]]` before returning — headless Linux (CI runners) may have xdg configured but no actual Desktop directory.
- Fallback chain: xdg-user-dir (validated) → `$HOME/Desktop` (Windows only) → `$HOME/Desktop` + `$HOME/桌面` (universal) → `$HOME`.
- Code review feedback: gate Windows Desktop check on `$OS == "windows"`, hoist `local` declarations to function top, add `timeout` diagnostic to tests, make `skip()` accept reason parameter.

## 2026-05-10: Local backup layout
- Canonical repo is `/Users/klaus/Documents/Projects/what-is-installed`.
- Old repo snapshots go under `/Users/klaus/Documents/Projects/repo-backups/what-is-installed/<timestamp>` as full local Git repositories.
- Loose old clones should be removed after backup, while executable entrypoints (`~/.local/bin`, Desktop launcher) must be repointed to the canonical repo first.

## 2026-05-07/08: Cross-platform refactor
- Added caching, timeout, multi-format output
- Bash 3.2 compatibility fixes (set -e, local outside functions)
- show-full-install-paths branch merged to main (via rebase)

## 2026-05-05: Table rendering
- Added box-drawing table layout with ANSI colors
- Replaced find with glob for performance

## 2026-04-30: Initial release
- PATH scanner engine with dedup, auto-filtering
- Bash 3.2 compatibility
