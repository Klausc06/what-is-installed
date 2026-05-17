# 999.5: CI & Code Quality — Context

**Source:** Code review + QA testing, 2026-05-17
**Severity:** 🟠 P1
**Reports:**
- `WorkBuddy/2026-05-17-task-15/deliverables/gstack/code-review-what-is-installed-2026-05-17.md`
- `WorkBuddy/2026-05-17-task-15/deliverables/gstack/qa-test-what-is-installed-2026-05-17.md`

## Items

### CI Infrastructure

1. **Add macOS CI runner** — `.github/workflows/ci.yml` currently only has `ubuntu-latest`. macOS is the primary dev platform.
2. **Downgrade shellcheck severity** — from `--severity=error` to `--severity=warning` to catch more issues.

### Code Robustness

3. **Platform file contract validation** — `lib/providers/_common.sh` doesn't verify platform files export required functions. This caused the v0.4.2 crash. Add `_assert_platform_contract()` check.
4. **`run_with_timeout` temp file leak** — `lib/shared.sh`: signal interrupt can leave temp files. Add `trap` inside the function.
5. **Naming consistency** — `VERSION_RESULT` vs `_CACHE_INDEX` convention mismatch. Unify naming.

### Documentation

6. **README line count** — claims "127 lines" for entry point, actual is 215. Update.

### Testing

7. **Add 5+ core unit tests** — coverage is ~5%. Target functions: `run_with_timeout`, `get_command_version`, cache operations. Target 20%+.
8. **Add uninstall mechanism** — no way to cleanly remove the tool.

## Acceptance Criteria

- [ ] macOS CI runner added and passing
- [ ] `shellcheck --severity=warning` passes with 0 errors
- [ ] Platform contract validation catches missing functions
- [ ] `run_with_timeout` temp files cleaned on signal
- [ ] Naming convention unified
- [ ] README line count accurate
- [ ] 5+ new unit tests added and passing
- [ ] Uninstall command/script available
