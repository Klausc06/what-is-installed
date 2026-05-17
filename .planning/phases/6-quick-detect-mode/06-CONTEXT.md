# Phase 6: Quick Detect Mode — Context

**Date:** 2026-05-17
**Status:** Decisions captured — ready for research/planning

## Domain

Split `what-is-installed` into a two-phase interactive flow:
1. Quick scan (Pass 1 only) — detect tool names + paths, render table immediately
2. Optional version probe (Pass 2) — prompted interactively, appends full versioned table

Goal: user sees results instantly (<1s), chooses whether to wait for versions.

## Decisions

### Mode Design — Pure Interactive
- **No CLI flags.** Default behavior is interactive.
- **TTY:** Scan → render table → prompt "Probe versions? [y/N]" → on 'y', run providers + Pass 2 → append full table.
- **Non-TTY (pipe/CI/script):** Scan only, render table, exit. No prompt, no version probing.
- TTY detection: `[[ -t 1 ]]` (stdout is a terminal).

### Output Format
- **Scan table:** Same box-drawing table format. Columns: Name | Version | Path. Version column shows `?` for all tools.
- **Probe table:** Appended below scan table (not replacing). Full Name | Version | Path with real versions.
- **Section grouping:** Preserved. Uses `section_label()` (PATH-based) in scan mode. In probe mode, provider results may refine grouping if providers run.
- **Summary line:** After scan, print `Found N tools.` (before the prompt).

### Provider Behavior
- **Scan phase:** Providers do NOT run. Only Pass 1 (PATH walk + filter + section_label grouping).
- **Probe phase:** Providers run normally (resolve_providers), then Pass 2 probes versions in parallel batches.

### Default Behavior
- **TTY:** Scan-first (fast). User explicitly opts into version probing.
- **Non-TTY:** Scan-only. No version probing. This is a breaking change from v0.5.0 (which always probed versions), accepted.

### Prompt Design
- **Text:** `Probe versions? [y/N]`
- **Timeout:** None — waits indefinitely.
- **Case insensitive:** 'y', 'Y', 'yes' trigger probe; anything else (including Enter for default N) skips.
- **After probe completes:** The full table (with versions) is appended. No further prompt.

### Testing Strategy
- Update existing integration test (`test_path_order_keeps_first_directory`) to expect new default (scan-only output).
- Add scan-only specific tests:
  - Verify version column shows `?` in scan output
  - Verify scan output appears before probe prompt
  - Verify non-TTY does not prompt
  - Verify `--help` / `-h` works (if added)
- Performance assertion: scan mode < 1s for typical PATH.

### Implementation Notes
- Pass 1 already exists and works — scan mode is essentially running Pass 1 + render + prompt.
- Pass 2 is unchanged — triggered only on user 'y'.
- Provider execution (`resolve_providers`) is skipped in scan, run in probe.
- `NO_COLOR=1` should suppress the prompt? No — keep prompt even with NO_COLOR. Prompt goes to stderr.
- The prompt goes to stderr (`>&2`) so it doesn't pollute piped output.

## Canonical Refs

- `bin/what-is-installed` — entry point (Pass 1: lines 68-115, Pass 2: lines 117-198)
- `lib/platform/macos.sh` — `section_label()` (line 16-31)
- `lib/shared.sh` — `run_with_timeout()`, `get_command_version()`
- `lib/render.sh` — `render_table()`
- `tests/run.sh` — existing test suite
- `.planning/ROADMAP.md` — Phase 6 definition

## Deferred Ideas

- `--json` / `--csv` output format — future phase
- `--sort-by-name` / `--sort-by-path` — future phase
