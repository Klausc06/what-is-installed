# what-is-installed — Project Preferences

## Code Style
- Bash 3.2 compatible (macOS default)
- No bashisms that break on older shells
- Cross-platform first

## Testing
- Manual smoke testing on macOS
- CI: Linux (shellcheck + tests + smoke install), Windows (shellcheck + tests), PowerShell (install.ps1 e2e + tests)

## Durable State
Source: Codex, 2026-05-09.

- After any real change to scripts, Desktop wrappers, installed PATH entries, config, or repo state, update `WORKLOG.md` and relevant `.memory/*` files before claiming completion.
- Desktop launchers and published wrapper examples must not hardcode machine-specific absolute paths or expose local usernames. Prefer PATH commands, `$HOME`/`~`, repo-relative paths, or generated per-machine shortcuts.
- After repairing launchers or moving project directories, verify the actual user entrypoint and scan changed files for leaked local paths such as `/Users/<name>` or old backup roots.
