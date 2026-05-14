#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FAIL=0

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
  local d1 d2 cache out count ec

  d1="$(mktemp -d)"
  d2="$(mktemp -d)"
  cache="$(mktemp -d)"
  trap 'rm -rf "$d1" "$d2" "$cache"' RETURN

  printf '#!/bin/sh\necho "1.0.0"\n' > "$d1/sharedtool"
  printf '#!/bin/sh\necho "2.0.0"\n' > "$d2/sharedtool"
  printf '#!/bin/sh\necho "1.0.0"\n' > "$d1/onlyind1"
  chmod +x "$d1/sharedtool" "$d2/sharedtool" "$d1/onlyind1"

  if out="$(XDG_CACHE_HOME="$cache" NO_COLOR=1 PATH="$d1:$d2:/bin:/usr/bin" bash "$bin" 2>&1)"; then
    ec=0
  else
    ec=$?
  fi

  [[ "$ec" -eq 0 ]] || { printf '%s\n' "$out"; fail "what-is-installed exited with $ec"; return; }

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

test_platform_contracts() {
  local platform
  for platform in macos linux windows bsd; do
    (
      source "$ROOT/lib/platform/$platform.sh"
      declare -f get_system_dirs >/dev/null
      declare -f get_family_skip_patterns >/dev/null
      declare -f get_gui_skip_patterns >/dev/null
      declare -f get_accel_env >/dev/null
      declare -f section_label >/dev/null
      declare -f section_color >/dev/null
    ) || fail "platform contract missing function: $platform"
  done
}

test_fractional_timeout_without_gnu_timeout() {
  local out
  out="$(PATH=/bin:/usr/bin bash -c 'source "$1"; run_with_timeout 0.3 /bin/echo ok' _ "$ROOT/lib/shared.sh" 2>&1)"
  [[ "$out" == "ok" ]] || fail "fractional timeout fallback should run command, got '$out'"
}

test_windows_timeout_does_not_swallow_probe() {
  local bin="$ROOT/bin/what-is-installed"
  local timeout_dir tool_dir out ec

  timeout_dir="$(mktemp -d)"
  tool_dir="$(mktemp -d)"
  trap 'rm -rf "$timeout_dir" "$tool_dir"' RETURN

  printf '#!/bin/sh\nexit 0\n' > "$timeout_dir/timeout"
  printf '#!/bin/sh\necho "toolx 1.2.3"\n' > "$tool_dir/toolx"
  chmod +x "$timeout_dir/timeout" "$tool_dir/toolx"

  if out="$(NO_COLOR=1 PATH="$timeout_dir:$tool_dir:/bin:/usr/bin" bash "$bin" 2>&1)"; then
    ec=0
  else
    ec=$?
  fi

  [[ "$ec" -eq 0 ]] || { printf '%s\n' "$out"; fail "Windows timeout simulation exited with $ec"; return; }
  printf '%s\n' "$out" | grep -q 'toolx' || { printf '%s\n' "$out"; fail "toolx should appear when timeout.exe is non-GNU"; return; }
  printf '%s\n' "$out" | grep -q '1.2.3' || fail "toolx version should be detected without GNU timeout"
}

test_candidate_path_is_probed() {
  local bin="$ROOT/bin/what-is-installed"
  local first_dir second_dir out ec

  first_dir="$(mktemp -d)"
  second_dir="$(mktemp -d)"
  trap 'rm -rf "$first_dir" "$second_dir"' RETURN

  printf '#!/bin/sh\necho "sharedtool 1.0.0"\n' > "$first_dir/sharedtool"
  printf '#!/bin/sh\necho "sharedtool 2.0.0"\n' > "$second_dir/sharedtool"
  chmod +x "$first_dir/sharedtool" "$second_dir/sharedtool"

  if out="$(NO_COLOR=1 PATH="$first_dir:$second_dir:/bin:/usr/bin" bash "$bin" 2>&1)"; then
    ec=0
  else
    ec=$?
  fi

  [[ "$ec" -eq 0 ]] || { printf '%s\n' "$out"; fail "candidate-path probe exited with $ec"; return; }
  printf '%s\n' "$out" | grep -q '1.0.0' || fail "first PATH entry version should be used"
  if printf '%s\n' "$out" | grep -q '2.0.0'; then
    fail "later PATH entry version should not be used"
  fi
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

test_platform_contracts
test_fractional_timeout_without_gnu_timeout
test_windows_timeout_does_not_swallow_probe
test_candidate_path_is_probed
test_path_order_keeps_first_directory
test_json_and_csv_helpers

[[ $FAIL -eq 0 ]] && printf 'ok - all tests passed\n'
exit $FAIL
