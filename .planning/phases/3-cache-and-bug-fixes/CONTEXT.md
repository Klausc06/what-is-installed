# 999.3: Cache & Bug Fixes — Context

**Source:** Code review + QA testing, 2026-05-17
**Severity:** 🟠 P1
**Reports:**
- `WorkBuddy/2026-05-17-task-15/deliverables/gstack/code-review-what-is-installed-2026-05-17.md`
- `WorkBuddy/2026-05-17-task-15/deliverables/gstack/qa-test-what-is-installed-2026-05-17.md`

## Issue 1: Pass 2 Subshell Cache Loss

**Location:** `bin/what-is-installed:136-141`

```bash
for ((i=batch_start; i<batch_end; i++)); do
  (
    source "$_LIB_DIR/detect.sh"
    source "$_LIB_DIR/shared.sh"
    get_command_version "${CANDIDATE_NAMES[$i]}"
    printf '%s' "$VERSION_RESULT" > "$_PROBE_TMPDIR/result_$i"
  ) &
done
```

Each subshell re-sources `detect.sh` and `shared.sh` but **does not** inherit populated `CACHE_NAMES`/`CACHE_VALS` arrays. Provider cache hits (e.g., `brew list --versions`) are lost — `get_command_version` re-probes every tool.

**Impact:** 100+ Homebrew tools add ~30s (each `brew --version` ~0.3s even with `HOMEBREW_NO_AUTO_UPDATE=1`).

**Fix options:**
- Option A: Write cache arrays to temp file, subshell reads it
- Option B: Pass cached version as argument to subshell function

## Issue 2: `.sh` Suffix Not Filtered

**Location:** Entry file, tool name filter (~line 100)

Currently only `.py` is in the blacklist for tool name filtering. Tools like `gettext.sh` appear in output. Add `.sh` to the filter.

## Issue 3: `g[` Special Character in Output

**Location:** Render output

The `g[` tool (coreutils test bracket binary) appears in output. The `[` character can break downstream parsers/consumers. Either escape the name or filter out special-character tools.

## Acceptance Criteria

- [ ] Pass 2 no longer loses provider cache — verify with 100+ Homebrew tools (performance delta <5s vs cached)
- [ ] `.sh` suffix tools are filtered from output
- [ ] `g[` and similar special-char tools are either escaped or filtered
- [ ] All existing tests still pass
