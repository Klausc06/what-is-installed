# Roadmap: what-is-installed

**Project:** what-is-installed CLI | **Updated:** 2026-05-17
**Full Inspection:** 2026-05-17 (code review + security audit + QA)

## Milestones

- ✅ **v0.4.3** — Current release (shipped)
- ✅ **v0.5.0** — P0+P1 fixes from full inspection (shipped 2026-05-17)

## Phases

### Phase 1: Fix Test Suite ✅
**Status:** Complete (commit 23a2ee8)
**Fix:** Removed unnecessary subshell re-sourcing + changed version sentinel `-` → `?`
**Source:** QA testing (2026-05-17)
**Goal:** Fix broken test suite (2/2 fail, exit code 2, CI red). Root cause: custom tools in temp PATH dirs not appearing in output (unrecognized section_label), and `json_escape`/`csv_field` string comparison issues.
**Impact:** CI is currently red on main — no reliable automated safety net.
**Depends on:** None
**Artifacts:** `deliverables/gstack/qa-test-what-is-installed-2026-05-17.md`

### Phase 2: Fix Command Injection ✅
**Status:** Complete (commit 2cde3da)
**Fix:** Array expansion `"${cmd_arr[@]}"` replaces bare `$cmd` in `command` invocation
**Source:** Security audit (OWASP A03, F-001) — 2026-05-17
**Goal:** Fix unquoted `$cmd` expansion in `lib/providers/_common.sh:19`. Use array expansion `"${cmd_arr[@]}"` instead of bare `$cmd`.
**Impact:** Command injection vector if future providers pass user-influenced input.
**Depends on:** None
**Artifacts:** `deliverables/gstack/security-audit-what-is-installed-2026-05-17.md`

### Phase 3: Cache & Bug Fixes ✅
**Status:** Complete (commit 73c0440)
**Fix:** Cache loss resolved by Phase 1 (subshells inherit cache). `.sh` and `*[[]*` added to blocklist.
**Source:** Code review + QA testing (2026-05-17)
**Goal:**
- Fix Pass 2 subshell cache loss (parallel probing re-probes cached tools, adds 30s+)
- Filter `.sh` suffix tools (currently only `.py` in blacklist)
- Handle `g[` special character in output (breaks parsers)
**Impact:** Performance regression with 100+ Homebrew tools; rendering bugs in edge cases.
**Depends on:** None
**Artifacts:** `deliverables/gstack/code-review-what-is-installed-2026-05-17.md`, `deliverables/gstack/qa-test-what-is-installed-2026-05-17.md`

### Phase 4: Security Hardening ✅
**Status:** Complete (commit a72ca10)
**Source:** Security audit (F-002..F-007) — 2026-05-17
**Goal:**
- Replace `eval "$_orig_extglob"` with `shopt -u extglob` boolean management (F-002)
- Add SHA256 integrity check to `install.sh` (F-003)
- Create `.bashrc.bak` before modifying in `install.sh` (F-004)
- Document TOCTOU symlink race as known limitation (F-005)
- Add `.gitignore` (F-006)
**Impact:** Medium-severity security gaps; supply chain hardening.
**Depends on:** None
**Artifacts:** `deliverables/gstack/security-audit-what-is-installed-2026-05-17.md`

### Phase 5: CI & Code Quality ✅
**Status:** Complete (commit b87f8d7)
**Source:** Code review + QA testing (2026-05-17)
**Goal:**
- Add `macos-latest` CI runner (currently only ubuntu)
- Downgrade `shellcheck` severity from error to warning
- Add platform file contract validation (prevent crashes like v0.4.2)
- Fix `run_with_timeout` temp file leak with trap
- Unify `VERSION_RESULT` / `_CACHE_INDEX` naming
- Update README line count (claims 127, actual 215)
- Add 5+ core unit tests (coverage ~5% → 20%+)
- Add uninstall mechanism
**Impact:** Quality and maintainability baseline.
**Depends on:** None
**Artifacts:** `deliverables/gstack/code-review-what-is-installed-2026-05-17.md`, `deliverables/gstack/qa-test-what-is-installed-2026-05-17.md`
