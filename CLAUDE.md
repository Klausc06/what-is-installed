# AGENTIC DIRECTIVE

## PROJECT

what-is-installed — Shell script that scans PATH for commands in non-system directories and displays version numbers.

## ENVIRONMENT
- Bash 3.2+ compatible (macOS default)
- Entry point: `bin/what-is-installed` (127 lines)
- Libraries: `lib/detect.sh` (OS), `lib/shared.sh` (utils + cache), `lib/render.sh` (output), `lib/platform/{macos,linux,windows,bsd}.sh` (per-OS), `lib/providers/{cargo,brew,winget,scoop,choco,rpm,pacman,_common,resolve}.sh` (package managers)
- No disk cache — every run is a live fresh snapshot
- No dependencies, but `brew install coreutils` on macOS enables GNU timeout (gtimeout) for ~15x faster version probing
- Provider architecture: 10 package managers bulk-query versions before PATH scan; `_wi_cache_add` + `_CACHE_STR` O(1) lookup

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
