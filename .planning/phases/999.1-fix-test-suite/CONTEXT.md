# 999.1: Fix Test Suite — Context

**Source:** gstack-qa-lead inspection, 2026-05-17
**Severity:** 🔴 P0 (blocking)
**Full Report:** `WorkBuddy/2026-05-17-task-15/deliverables/gstack/qa-test-what-is-installed-2026-05-17.md`

## Current State

Running `bash tests/run.sh` produces:

```
not ok - shared command should appear exactly once, got 0
not ok - PATH directory order should be preserved
```

Exit code: 2 (both assertions failed). CI runs these tests as required check → CI is red on main.

## Root Causes

### Test 1: `test_path_order_keeps_first_directory`
- Custom tools (`sharedtool`, `onlyind1`) placed in temp PATH directories are NOT appearing in output
- Temp directory paths (e.g., `/var/folders/...`) don't match any `section_label` pattern in `lib/platform/macos.sh`
- Tools from unrecognized directories land in "Other" section, but the grep for `sharedtool` returns 0 matches
- Likely cause: temp dirs being filtered as "system" or tools skipped by dedup/family logic

### Test 2: `test_json_and_csv_helpers`
- `json_escape` and `csv_field` unit tests have Bash string comparison issues
- `$'\\\\'` vs literal backslash escape sequences are ambiguous in test assertions
- The `source "$ROOT/lib/render.sh"` may fail silently or redefine functions unexpectedly

## Acceptance Criteria

- [ ] `bash tests/run.sh` passes 2/2 on macOS
- [ ] `bash tests/run.sh` passes 2/2 on Linux (CI ubuntu-latest)
- [ ] CI workflow shows green checkmark
- [ ] No regressions in tool detection accuracy
