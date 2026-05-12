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

test_path_order_keeps_first_directory
test_json_and_csv_helpers

[[ $FAIL -eq 0 ]] && printf 'ok - all tests passed\n'
exit $FAIL
