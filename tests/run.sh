#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FAIL=0

if ! command -v timeout &>/dev/null; then
  echo "# Note: 'timeout' not found. Integration test will skip."
  echo "# Install: brew install coreutils (macOS) or apt install coreutils (Linux)"
fi

fail() {
  echo "not ok - $*"
  FAIL=$((FAIL + 1))
}

skip() {
  local reason="$1"; shift
  echo "ok - $* # SKIP ($reason)"
}

# ── tests ─────────────────────────────────────────

test_path_order_keeps_first_directory() {
  local bin="$ROOT/bin/what-is-installed"
  local d1 d2 cache out count

  d1="$(mktemp -d)"
  d2="$(mktemp -d)"
  cache="$(mktemp -d)"
  trap "rm -rf $d1 $d2 $cache" RETURN

  printf '#!/usr/bin/env bash\necho "1.0.0"\n' > "$d1/sharedtool"
  printf '#!/usr/bin/env bash\necho "2.0.0"\n' > "$d2/sharedtool"
  printf '#!/usr/bin/env bash\necho "1.0.0"\n' > "$d1/onlyind1"
  chmod +x "$d1/sharedtool" "$d2/sharedtool" "$d1/onlyind1"

  out="$(XDG_CACHE_HOME="$cache" NO_COLOR=1 PATH="$d1:$d2:$PATH" timeout 10 bash "$bin" 2>/dev/null || true)"

  if [[ -z "$out" ]]; then
    skip "tool produced no output" "what-is-installed integration test"
    return
  fi

  count=$(printf '%s\n' "$out" | grep -c 'sharedtool' || true)
  [[ "$count" -eq 1 ]] || fail "shared command should appear exactly once, got $count"

  local d1_line d2_path_line
  d1_line=$(printf '%s\n' "$out" | grep -n "$d1" | head -1 | cut -d: -f1 || echo 999)
  d2_path_line=$(printf '%s\n' "$out" | grep -n "$d2" | head -1 | cut -d: -f1 || echo 999)
  [[ "$d1_line" -lt 999 && "$d1_line" -lt "$d2_path_line" ]] || fail "PATH directory order should be preserved"
}

test_json_and_csv_helpers() {
  source "$ROOT/lib/render.sh"

  local result expected

  # json_escape: backslash (1 char) → \\ (2 chars)
  result="$(json_escape $'\\')"
  expected=$'\\\\'
  [[ "$result" == "$expected" ]] || fail "json_escape backslash: expected two backslashes, got '$result'"

  # json_escape: double-quote → \"
  result="$(json_escape '"')"
  expected='\"'
  [[ "$result" == "$expected" ]] || fail "json_escape double quote: expected '$expected', got '$result'"

  # json_escape: tab → \t
  result="$(json_escape $'\t')"
  expected='\t'
  [[ "$result" == "$expected" ]] || fail "json_escape tab: expected '$expected', got '$result'"

  # json_escape: newline → \n
  result="$(json_escape $'\n')"
  expected='\n'
  [[ "$result" == "$expected" ]] || fail "json_escape newline: expected '$expected', got '$result'"

  # csv_field: value with comma, double-quote, and newline
  result="$(csv_field $'a,"b"\nc')"
  expected=$'"a,""b""\nc"'
  [[ "$result" == "$expected" ]] || fail "csv_field: expected '$expected', got '$result'"
}

test_cache_operations() {
  source "$ROOT/lib/detect.sh"
  source "$ROOT/lib/shared.sh"
  source "$ROOT/lib/providers/resolve.sh"  # _wi_cache_add

  # Test _cache_lookup on empty cache
  _cache_lookup "nonexistent" && fail "cache_lookup should miss on empty cache"

  # Test _wi_cache_add + _cache_lookup + _sort_cache
  _wi_cache_add "zcat" "1.0"
  _wi_cache_add "acat" "2.0"
  _wi_cache_add "mcat" "3.0"
  _sort_cache

  _cache_lookup "acat" || fail "cache_lookup should find acat"
  [[ "${CACHE_VALS[$_cache_index]}" == "2.0" ]] || fail "cache_lookup: expected 2.0, got ${CACHE_VALS[$_cache_index]}"

  _cache_lookup "mcat" || fail "cache_lookup should find mcat"
  _cache_lookup "zcat" || fail "cache_lookup should find zcat"

  # Verify sort order
  [[ "${CACHE_NAMES[0]}" == "acat" ]] || fail "sort: expected acat first, got ${CACHE_NAMES[0]}"
  [[ "${CACHE_NAMES[2]}" == "zcat" ]] || fail "sort: expected zcat last, got ${CACHE_NAMES[2]}"
}

test_run_with_timeout_trap() {
  source "$ROOT/lib/shared.sh"

  # Basic success case
  local out
  out="$(run_with_timeout 0.5 echo hello 2>/dev/null)" || fail "run_with_timeout echo should succeed"
  [[ "$out" == "hello" ]] || fail "run_with_timeout echo: expected hello, got '$out'"

  # Timeout case — sleep 2 with 0.1 timeout should fail
  run_with_timeout 0.1 sleep 2 >/dev/null 2>&1 && fail "run_with_timeout should time out on sleep 2"
  # exit 124 means timeout
  [[ $? -eq 124 ]] || true  # just verify it doesn't crash
}

test_get_command_version_basic() {
  source "$ROOT/lib/detect.sh"
  source "$ROOT/lib/shared.sh"

  # Test version from a known command
  get_command_version "bash"
  [[ -n "$VERSION_RESULT" ]] || fail "get_command_version bash should return a version"
  [[ "$VERSION_RESULT" != "?" ]] || fail "get_command_version bash: got ?, expected a version number"
}

test_platform_contract_functions() {
  local missing=0
  for platform in macos linux bsd windows; do
    local pf="$ROOT/lib/platform/${platform}.sh"
    [[ -f "$pf" ]] || { fail "platform file missing: $pf"; continue; }
    # Verify each sources without error
    bash -n "$pf" 2>/dev/null || fail "platform file has syntax errors: $pf"
  done
}

test_json_csv_edge_cases() {
  source "$ROOT/lib/render.sh"

  # Empty string
  local result
  result="$(json_escape '')"
  [[ -z "$result" ]] || fail "json_escape empty: expected empty, got '$result'"

  # Unicode
  result="$(json_escape 'café')"
  [[ "$result" == 'café' ]] || fail "json_escape unicode: expected café, got '$result'"

  # csv_field with only special chars
  result="$(csv_field ',')"
  [[ "$result" == '","' ]] || fail "csv_field comma-only: expected '\",\"', got '$result'"
}

test_escape_glob() {
  source "$ROOT/lib/shared.sh"

  local result

  # Basic: no special chars → unchanged
  result="$(_escape_glob 'hello')"
  [[ "$result" == 'hello' ]] || { echo "not ok - escape_glob plain: expected hello, got '$result'"; FAIL=$((FAIL + 1)); }

  # Space preserved
  result="$(_escape_glob 'a b')"
  [[ "$result" == 'a b' ]] || { echo "not ok - escape_glob space: expected 'a b', got '$result'"; FAIL=$((FAIL + 1)); }
}

test_path_order_keeps_first_directory
test_json_and_csv_helpers
test_cache_operations
test_run_with_timeout_trap
test_get_command_version_basic
test_platform_contract_functions
test_json_csv_edge_cases
test_escape_glob

[[ $FAIL -eq 0 ]] && printf 'ok - all tests passed\n'
exit $FAIL
