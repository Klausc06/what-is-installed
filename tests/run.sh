#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FAIL=0

fail() {
  echo "not ok - $*"
  FAIL=$((FAIL + 1))
}

assert_not_exists() {
  local path="$1" message="${2:-}"
  [[ ! -e "$path" ]] || fail "$message"
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

  out="$(XDG_CACHE_HOME="$cache" NO_COLOR=1 PATH="$d1:$d2:/usr/bin:/bin" bash "$bin" 2>/dev/null)"

  count=$(printf '%s\n' "$out" | grep -c 'sharedtool' || true)
  [[ "$count" -eq 1 ]] || fail "shared command should appear exactly once, got $count"

  local d1_line d2_path_line
  d1_line=$(printf '%s\n' "$out" | grep -n "$d1" | head -1 | cut -d: -f1 || echo 999)
  d2_path_line=$(printf '%s\n' "$out" | grep -n "$d2" | head -1 | cut -d: -f1 || echo 999)
  [[ "$d1_line" -lt 999 && "$d1_line" -lt "$d2_path_line" ]] || fail "PATH directory order should be preserved"
}

test_cache_writes_and_is_safe() {
  local bin="$ROOT/bin/what-is-installed"
  local d1 cache cache_file marker content

  d1="$(mktemp -d)"
  cache="$(mktemp -d)"
  trap "rm -rf $d1 $cache" RETURN

  printf '#!/usr/bin/env bash\necho "1.0.0"\n' > "$d1/cachetool"
  chmod +x "$d1/cachetool"

  # Run once to populate cache
  XDG_CACHE_HOME="$cache" NO_COLOR=1 PATH="$d1:/usr/bin:/bin" bash "$bin" 2>/dev/null >/dev/null

  # Verify cache was written
  cache_file="$cache/what-is-installed/versions.cache"
  [[ -f "$cache_file" ]] || fail "cache file should exist after first run"

  content="$(cat "$cache_file")"
  [[ "$content" == *"cachetool"* ]] || fail "cache should contain cachetool"

  # Second run should use cache (fast)
  out="$(XDG_CACHE_HOME="$cache" NO_COLOR=1 PATH="$d1:/usr/bin:/bin" bash "$bin" 2>/dev/null)"
  [[ "$out" == *"cachetool"* ]] || fail "cached run should show cachetool"

  # Poison: executable code in cache must NOT execute
  rm -rf "$cache"
  mkdir -p "$(dirname "$cache_file")"
  marker="/tmp/hermes_test_cache_ran_$$"
  rm -f "$marker"
  {
    printf 'ts\t%s\n' "$(date +%s)"
    printf 'entry\tfoo\tbar\n'
    printf '#!/usr/bin/env bash\necho EXPLOITED > %s\n' "$marker"
  } > "$cache_file"

  XDG_CACHE_HOME="$cache" NO_COLOR=1 PATH="$d1:/usr/bin:/bin" bash "$bin" 2>/dev/null >/dev/null || true
  assert_not_exists "$marker" "cache loader must not execute cache contents"
  rm -f "$marker"
}

test_json_and_csv_helpers() {
  source "$ROOT/lib/render.sh"

  local json csv

  json="$(json_escape '\')"
  [[ "$json" == '\\' ]] || fail "json_escape backslash: got '$json'"

  json="$(json_escape '"')"
  [[ "$json" == '\"' ]] || fail "json_escape double quote: got '$json'"

  json="$(json_escape $'\t')"
  [[ "$json" == '\t' ]] || fail "json_escape tab: got '$json'"

  json="$(json_escape $'\n')"
  [[ "$json" == '\n' ]] || fail "json_escape newline: got '$json'"

  csv="$(csv_field $'a,"b"\nc')"
  [[ "$csv" == $'"a,""b""\nc"' ]] || fail "csv_field: got '$csv'"
}

test_path_order_keeps_first_directory
test_cache_writes_and_is_safe
test_json_and_csv_helpers

[[ $FAIL -eq 0 ]] && printf 'ok - all tests passed\n'
exit $FAIL
