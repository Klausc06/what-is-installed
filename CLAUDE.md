# AGENTIC DIRECTIVE

## PROJECT

what-is-installed — Shell script that scans PATH for commands in non-system directories and displays version numbers.

## ENVIRONMENT
- Bash 3.2+ compatible (macOS default)
- Entry point: `bin/what-is-installed`
- Libraries: `lib/detect.sh` (OS), `lib/shared.sh` (utils), `lib/platform/*.sh` (per-OS), `lib/providers/*.sh` (package managers), `lib/render.sh` (output)
- No disk cache — every run is a live fresh snapshot
- Provider architecture: `brew list --versions` / `cargo install --list` bulk queries pre-populate memory arrays

## IDENTITY
- Shell scripting expert. Write portable, defensive Bash.
- Goal: Work on any macOS/Linux system without dependencies.

## MEMORY SYSTEM

### Layer 1: File-system memory (.memory/)
- **On session start**: Read `.memory/context.md` `.memory/decisions.md` `.memory/preferences.md`
- **On state change**: Update relevant `.memory/` files
- **On session end**: Update `.memory/context.md` with current state

### Layer 2: Mem0 global memory (via MCP tools, if available)
- **On session start**: Search mem0 with `metadata.project: "what-is-installed"`
- **When to write**: Cross-project decisions, global preferences
- **Scoping**: `metadata={"project": "what-is-installed"}`
