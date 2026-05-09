#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOL="$ROOT/bin/what-is-installed"
TMP_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

fail() {
  printf 'not ok - %s\n' "$1" >&2
  exit 1
}

assert_contains() {
  local haystack="$1" needle="$2" message="$3"
  [[ "$haystack" == *"$needle"* ]] || fail "$message"
}

assert_not_exists() {
  local path="$1" message="$2"
  [[ ! -e "$path" ]] || fail "$message"
}

make_cmd() {
  local dir="$1" name="$2" version="$3"
  mkdir -p "$dir"
  cat > "$dir/$name" <<EOF
#!/usr/bin/env bash
printf '%s\n' "$name version $version"
EOF
  chmod +x "$dir/$name"
}

run_tool() {
  local path_value="$1" cache_home="$2"
  shift 2
  PATH="$path_value" XDG_CACHE_HOME="$cache_home" "$TOOL"
}

test_path_order_keeps_first_directory() {
  local first="$TMP_DIR/path-first" second="$TMP_DIR/path-second" cache="$TMP_DIR/cache-path"
  make_cmd "$first" shared 1.0
  make_cmd "$second" shared 2.0
  make_cmd "$second" secondonly 3.0

  # Fresh cache dir so no cached results interfere.
  local output
  output="$(run_tool "$first:$second:$first:/usr/bin:/bin" "$cache")"

  assert_contains "$output" "shared" "PATH order should include shared command"
  assert_contains "$output" "secondonly" "PATH order should include secondonly"

  # shared should appear once, from first directory.
  local count
  count="$(printf '%s\n' "$output" | grep -c "shared")"
  [[ "$count" -eq 1 ]] || fail "shared command should appear exactly once, got $count"

  # first occurrence of shared should come before secondonly.
  local shared_pos secondonly_pos
  shared_pos="$(printf '%s\n' "$output" | grep -n "shared" | head -n 1 | cut -d: -f1)"
  secondonly_pos="$(printf '%s\n' "$output" | grep -n "secondonly" | head -n 1 | cut -d: -f1)"
  [[ "$shared_pos" -lt "$secondonly_pos" ]] || fail "PATH directory order should be preserved"
}

test_cache_works_and_safe_parser() {
  local bin="$TMP_DIR/cache-bin" cache="$TMP_DIR/cache-home" marker="$TMP_DIR/cache-sourced"
  make_cmd "$bin" cachetool 1.0

  # First run: populate cache.
  run_tool "$bin:/usr/bin:/bin" "$cache" >/dev/null

  # Change the binary but keep cache fresh.
  make_cmd "$bin" cachetool 2.0

  local cached
  cached="$(run_tool "$bin:/usr/bin:/bin" "$cache")"
  assert_contains "$cached" "cachetool" "should return cached version (1.0, not 2.0)"

  # Inject malicious content into cache — must not be executed.
  local cache_file="$cache/what-is-installed/versions.cache"
  {
    printf 'ts\t%s\n' "$(date +%s)"
    printf 'entry\tcachetool\t3.0\n'
    printf 'touch %s\n' "$marker"
  } > "$cache_file"

  cached="$(run_tool "$bin:/usr/bin:/bin" "$cache")"
  assert_contains "$cached" "cachetool" "safe parser should load valid cache entries"
  assert_not_exists "$marker" "cache loader must not execute cache contents"
}

test_json_and_csv_escape_helpers() {
  # shellcheck source=/dev/null
  source "$ROOT/lib/render.sh"

  local json csv
  json="$(json_escape $'a\\b"c\td\ne\r')"
  [[ "$json" == 'a\\b\"c\td\ne\r' ]] || fail "json_escape should escape quotes, slashes, tab, newline, and carriage return"

  csv="$(csv_field $'a,"b"\nc')"
  [[ "$csv" == $'"a,""b""\nc"' ]] || fail "csv_field should quote newlines and double embedded quotes"
}

test_path_order_keeps_first_directory
test_cache_works_and_safe_parser
test_json_and_csv_escape_helpers

printf 'ok - all tests passed\n'
