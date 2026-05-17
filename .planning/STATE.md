# STATE: what-is-installed

**Last Updated:** 2026-05-17

## Active Decisions

- Full inspection (code review + security + QA) completed 2026-05-17
- 2 P0 items must be fixed before next release
- Backlog created from 23 findings across 5 phases (999.1–999.5)

## Known Issues

| # | Severity | Location | Issue | Phase |
|---|----------|----------|-------|-------|
| 1 | 🔴 P0 | `tests/run.sh` | Test suite 2/2 fails | 999.1 |
| 2 | 🔴 P0 | `lib/providers/_common.sh:19` | `$cmd` unquoted — command injection | 999.2 |
| 3 | 🟠 P1 | `bin/what-is-installed:136-141` | Pass 2 subshell cache loss | 999.3 |
| 4 | 🟠 P1 | Entry file line 100 | `.sh` suffix not filtered | 999.3 |
| 5 | 🟠 P1 | Render output | `g[` special char breaks output | 999.3 |
| 6 | 🟠 P1 | `lib/providers/_common.sh:20` | `eval "$_orig_extglob"` unsafe | 999.4 |
| 7 | 🟡 Medium | `install.sh` | No integrity check | 999.4 |
| 8 | 🟡 Medium | `install.sh` | No .bashrc backup | 999.4 |
| 9 | 🟡 Medium | `lib/detect.sh` | TOCTOU symlink race | 999.4 |
| 10 | 🟢 Low | Repo root | No `.gitignore` | 999.4 |
| 11 | 🟡 Medium | `lib/providers/_common.sh` | No platform contract check | 999.5 |
| 12 | 🟡 Medium | `lib/shared.sh` | `run_with_timeout` temp file leak | 999.5 |
| 13 | 🟡 Medium | `tests/` | Coverage ~5%, needs 5+ unit tests | 999.5 |
| 14 | 🟡 Medium | `.github/workflows/ci.yml` | No macOS runner | 999.5 |
| 15 | 🟢 Low | `README.md` | Stale line count (127 vs 215) | 999.5 |
| 16 | 🟢 Low | Multiple | `VERSION_RESULT` vs `_CACHE_INDEX` naming | 999.5 |
| 17 | 🟢 Low | N/A | No uninstall mechanism | 999.5 |
| 18 | 🟢 Low | `ci.yml` | Shellcheck severity too lax (error only) | 999.5 |

## Reference Deliverables

- `WorkBuddy/2026-05-17-task-15/deliverables/gstack/full-inspection-what-is-installed-2026-05-17.md`
- `WorkBuddy/2026-05-17-task-15/deliverables/gstack/code-review-what-is-installed-2026-05-17.md`
- `WorkBuddy/2026-05-17-task-15/deliverables/gstack/security-audit-what-is-installed-2026-05-17.md`
- `WorkBuddy/2026-05-17-task-15/deliverables/gstack/qa-test-what-is-installed-2026-05-17.md`
