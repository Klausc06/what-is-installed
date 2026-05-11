# what-is-installed — Project Context

## Active Branches
- `main` — primary development branch

## Current State
- 100 commits — Windows optimization: 0.2s polling, path labels, winget/scoop/choco providers, CI PowerShell test
- Working tree clean
- 0 shellcheck errors, 2 tests pass
- Windows CI: .github/workflows/ci.yml (windows-latest, shell: bash, shellcheck + tests + new powershell-install job)
- CRLF safety: git config core.autocrlf=false, sed strip before shellcheck
- Canonical repo path: `/Users/klaus/Documents/Projects/what-is-installed`
- Old loose clone archived at `/Users/klaus/Documents/Projects/repo-backups/what-is-installed/20260510-124118`

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
- **Provider layer**: `lib/providers/` — cargo, winget, scoop, choco (cross-platform), resolve (OS dispatcher)
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
