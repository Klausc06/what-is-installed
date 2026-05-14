# what-is-installed — Project Context

## Active Branches
- `main` — primary development branch

## Current State
- 129 commits at base `origin/main` (`693a189`) plus pending 2026-05-15 Windows Git Bash regression fix in `/Users/klaus/Documents/Projects/what-is-installed-latest-fix`
- Working tree has focused fixes for missing `get_gui_skip_patterns`, non-GNU Windows `timeout.exe`, 5s fallback timeout floor, candidate-path probing, and CI pipefail
- 0 shellcheck errors at severity=error; `bash tests/run.sh` passes
- Regression coverage includes platform function contracts, fractional timeout fallback, Windows timeout simulation, and candidate-path probing
- Windows CI: .github/workflows/ci.yml (windows-latest, shell: bash, shellcheck + tests + new powershell-install job)
- CRLF safety: git config core.autocrlf=false, sed strip before shellcheck
- Current working path: `/Users/klaus/WorkBuddy/what-is-installed`

## Platform Support
- macOS: .command launcher, Homebrew detection, Apple Silicon + Intel
- Linux: .desktop launcher (xdg-user-dir), snap/Linuxbrew/dpkg-query detection
- Windows: .bat launcher + .bat wrapper, install.ps1 (auto-add PATH to registry), winget/scoop/choco providers
- BSD: basic support, DragonFly detected

## Critical Windows Knowledge
- `run_with_timeout` uses foreground polling at 0.2s granularity (NO background kill — Git Bash kill fails)
- `/mingw/` (with trailing slash), `/c/Windows/*`, `/proc`, `/usr/bin`, `/usr/lib/git-core` filtered
- install.sh on Windows: copies script + creates .bat wrapper (no symlinks)
- PowerShell: needs .bat wrapper, PATH via registry (SetEnvironmentVariable)
- Windows path labels: Scoop (Cyan), Chocolatey (Yellow), AppData (Blue), npm Global (Yellow)
- Winget/scoop/choco providers: bulk-query before PATH scan, gated on mingw|cygwin platform

## Architecture
- **Per-OS platform files**: `lib/platform/{macos,linux,windows,bsd}.sh` — each exports same contract
- **Provider layer**: `lib/providers/` — cargo, brew, winget, scoop, choco, rpm, pacman, _common (shared parser), resolve (OS dispatcher)
- **Shared core**: `lib/detect.sh` (OS detection), `lib/shared.sh` (utils, version probing), `lib/render.sh` (output)
- **Filter-before-probe**: dedup, skip patterns, blocklist checked before version probing
- **No disk cache**: every run is a fresh snapshot; speed comes from bulk queries + GNU timeout

## Key Design Decisions
- Zero CLI options — no flags, no config, just run it
- ANSI box-drawing table with color, dot-drawing fallback for ASCII mode
- Bilingual README with language switcher, bilingual CHANGELOG

## Install Methods
- `bash install.sh` (all platforms, one command)
- `powershell -ExecutionPolicy Bypass -File install.ps1` (Windows)

## Local Backup Policy
- Keep timestamped old repo snapshots under `/Users/klaus/Documents/Projects/repo-backups/<project>/<YYYYMMDD-HHMMSS>`.
- Do not leave loose project clones such as `/Users/klaus/what-is-installed` around after they are archived.
