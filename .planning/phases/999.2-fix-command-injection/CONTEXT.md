# 999.2: Fix Command Injection — Context

**Source:** gstack-security-officer audit, 2026-05-17
**Severity:** 🔴 P0 (blocking)
**Category:** OWASP A03 (Injection) / STRIDE: Tampering
**Full Report:** `WorkBuddy/2026-05-17-task-15/deliverables/gstack/security-audit-what-is-installed-2026-05-17.md`

## Current State

`lib/providers/_common.sh:19`:

```bash
done < <(run_with_timeout "$timeout" command $cmd 2>/dev/null)
```

The variable `$cmd` is used **unquoted**, causing word-splitting and glob expansion. While current callers pass fixed strings (`"winget list"`, `"scoop list"`), the lack of quoting violates defense-in-depth. If any future provider passes user-influenced input, this becomes a direct command injection vector.

Currently, the space in `"winget list"` is intentionally used as the word-split boundary between command and argument — this works but is fragile and unsafe.

## Remediation

Option A (recommended) — use array:
```bash
local -a cmd_arr=($cmd)  # intentional split for "winget list" → ["winget", "list"]
done < <(run_with_timeout "$timeout" command "${cmd_arr[@]}" 2>/dev/null)
```

Option B — change API to separate command/args parameters.

## Acceptance Criteria

- [ ] `$cmd` is never used unquoted in command position
- [ ] All existing providers (`winget list`, `scoop list`, etc.) continue working
- [ ] `shellcheck` passes with no SC2086 on this line
- [ ] No regression in provider-based version detection
