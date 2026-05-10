# what-is-installed — Project Context

## Active Branches
- `main` — primary development branch

## Current State
- 82 commits (2026-05-10) — Phase 1+2+5 perf optimizations landed
- Working tree clean
- 0 shellcheck bugs, all tests pass
- Windows CI: .github/workflows/ci.yml (windows-latest, shell: bash, shellcheck + tests)
- CRLF safety: git config core.autocrlf=false, sed strip before shellcheck
- Canonical repo path: `/Users/klaus/Documents/Projects/what-is-installed`
- Old loose clone archived at `/Users/klaus/Documents/Projects/repo-backups/what-is-installed/20260510-124118`

## Platform Support
- macOS: .command launcher, Homebrew detection, Apple Silicon + Intel
- Linux: .desktop launcher (xdg-user-dir), snap/Linuxbrew detection
- Windows: .bat launcher + .bat wrapper, install.ps1 (auto-add PATH to registry)
- BSD: basic support, DragonFly detected

## Critical Windows Knowledge
- `run_with_timeout` uses foreground polling (NO background kill — Git Bash kill fails)
- `/mingw*`, `/c/Windows/*`, `/proc`, `/usr/bin`, `/usr/lib/git-core` filtered
- install.sh on Windows: copies script + creates .bat wrapper (no symlinks)
- PowerShell: needs .bat wrapper, PATH via registry (SetEnvironmentVariable)

## Performance Architecture
- **Provider layer** (`lib/providers.sh`): brew + cargo bulk version queries pre-populate cache
- **Filter-before-probe**: dedup, skip patterns, blocklist checked before version probing
- **Two-tier cache** (planned): provider data 24h TTL, PATH scan 1h TTL

## Key Design Decisions
- Zero CLI options — no flags, no config, just run it
- TSV cache (safe parser, not `source`-based), 1-hour TTL
- ANSI box-drawing table with color, dot-drawing fallback for ASCII mode
- Bilingual README with language switcher

## Install Methods
- `bash install.sh` (all platforms, one command)
- `powershell -ExecutionPolicy Bypass -File install.ps1` (Windows)

## Local Backup Policy
- Keep timestamped old repo snapshots under `/Users/klaus/Documents/Projects/repo-backups/<project>/<YYYYMMDD-HHMMSS>`.
- Do not leave loose project clones such as `/Users/klaus/what-is-installed` around after they are archived.
