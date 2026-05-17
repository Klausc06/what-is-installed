# Code Review: v0.5.0

**Date:** 2026-05-17
**Scope:** Full v0.5.0 diff (11 files, +236/-16)
**Depth:** standard

## Summary

No critical or high-severity issues found. Two minor observations.

---

## Findings

### [R-001] trap INT/TERM persists after run_with_timeout returns
- **Severity:** 🟢 Info
- **Location:** `lib/shared.sh:84`
- **Description:** `trap 'rm -f "${tmpfile:-}"' RETURN INT TERM` — the RETURN trap fires correctly on function exit, but INT/TERM traps remain set globally after the function returns. If SIGINT is delivered later, the trap runs `rm -f ""` (harmless but messy).
- **Impact:** None — `${tmpfile:-}` handles unset variable. In a CLI tool that exits shortly after, this is purely cosmetic.
- **Recommendation:** Consider saving/restoring previous trap, or accept as-is for simplicity.

### [R-002] Blocklist pattern readability
- **Severity:** 🟢 Info
- **Location:** `bin/what-is-installed:108`
- **Description:** `*[[]*)` matches names containing `[`. The pattern `[[]` in a case statement is correct (character class containing literal `[`), but may confuse readers.
- **Impact:** None — pattern works correctly.
- **Recommendation:** Add a comment explaining the pattern: `*[[]*)  # names containing '['`

---

## Verified Correct

### Security
- ✅ `eval "$_orig_extglob"` → boolean `shopt` — eliminates code injection risk
- ✅ `command $cmd` → `command "${cmd_arr[@]}"` — safe array expansion
- ✅ `install.sh` integrity pre-flight checks
- ✅ `.bashrc.bak` created before modification

### Correctness
- ✅ Platform contract validation (`declare -F` guard)
- ✅ `_cache_lookup` test assertion direction is correct (returns 0=found, 1=not found)
- ✅ `run_with_timeout` timeout test: `cmd && fail` only fails if cmd returns 0
- ✅ `_sort_cache` insertion sort verified with 3-element test

### Bash Practices
- ✅ `set -euo pipefail` maintained throughout
- ✅ `${tmpfile:-}` safe with `set -u`
- ✅ `shellcheck disable=SC2206` for intentional word-split
- ✅ `2>/dev/null` guards on optional operations

### Tests
- ✅ 7 tests all pass (`bash tests/run.sh` → exit 0)
- ✅ Cache operations: insert, sort, lookup
- ✅ Timeout: success + timeout paths
- ✅ Version probing: known command (bash)
- ✅ Platform files: syntax check all 4 platforms

---

## Verdict

🟢 **Approved.** No blocking issues. The two Info-level observations are cosmetic and do not warrant changes before release.
