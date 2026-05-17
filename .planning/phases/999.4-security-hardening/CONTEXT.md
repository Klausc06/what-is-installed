# 999.4: Security Hardening — Context

**Source:** gstack-security-officer audit, 2026-05-17
**Severity:** 🟠 P1
**Full Report:** `WorkBuddy/2026-05-17-task-15/deliverables/gstack/security-audit-what-is-installed-2026-05-17.md`

## Issue 1: `eval "$_orig_extglob"` — Code Injection Risk (F-002)

**Location:** `lib/providers/_common.sh:20`
**Severity:** 🟡 Medium

`_orig_extglob` captured via `shopt -p extglob` and restored with `eval "$_orig_extglob"`. If variable were overwritten, arbitrary code execution. Replace with boolean flag:

```bash
local _had_extglob=false
shopt -q extglob 2>/dev/null && _had_extglob=true
shopt -s extglob 2>/dev/null
# ... function body ...
$_had_extglob || shopt -u extglob 2>/dev/null
```

## Issue 2: No Integrity Check in install.sh (F-003)

**Location:** `install.sh` entire file
**Severity:** 🟡 Medium

No SHA256 or GPG verification of copied files. Add checksum verification to installer.

## Issue 3: install.sh Silently Modifies .bashrc (F-004)

**Location:** `install.sh`
**Severity:** 🟡 Medium

Create `.bashrc.bak` before modifying.

## Issue 4: TOCTOU Symlink Race (F-005)

**Location:** `lib/detect.sh`
**Severity:** 🟢 Low

Already mitigated by `mktemp` + `EXIT` trap. Document as known limitation.

## Issue 5: No .gitignore (F-006)

**Location:** Repo root
**Severity:** 🟢 Low

Add standard `.gitignore` for shell project.

## Acceptance Criteria

- [ ] `eval "$_orig_extglob"` replaced with boolean `shopt` management
- [ ] `install.sh` includes SHA256 verification
- [ ] `install.sh` creates `.bashrc.bak` before modification
- [ ] TOCTOU race documented in code comments
- [ ] `.gitignore` added with standard shell project entries
- [ ] No regressions in provider functionality
