# shellcheck shell=bash
# lib/shared.sh — Cross-platform utilities and version probing

CACHE_NAMES=()
CACHE_VALS=()
VERSION_RESULT=""

short_path() {
  local p="$1"
  p="${p/#$HOME/~}"
  printf '%s' "$p"
}

repeat_char() {
  local char="$1" count="$2" out=""
  while [[ $count -gt 0 ]]; do
    out+="$char"
    ((count--))
  done
  printf '%s' "$out"
}

run_with_timeout() {
  local timeout="${1:-2}" tmpfile pid exit_code waited
  shift
  tmpfile="$(mktemp)"

  # Prefer GNU timeout if available (fast, reliable across platforms)
  if command -v timeout >/dev/null 2>&1; then
    timeout "$timeout" "$@" >"$tmpfile" 2>&1
    exit_code=$?
  else
    # Fallback: foreground polling loop — no background kill needed
    # (background { sleep; kill; } & fails on Windows Git Bash)
    "$@" >"$tmpfile" 2>&1 &
    pid=$!
    waited=0
    while kill -0 "$pid" 2>/dev/null && [[ $waited -lt $timeout ]]; do
      sleep 1
      ((waited++))
    done
    if kill -0 "$pid" 2>/dev/null; then
      kill "$pid" 2>/dev/null || true
      wait "$pid" 2>/dev/null || true
      rm -f "$tmpfile"
      return 124
    fi
    wait "$pid" 2>/dev/null
    exit_code=$?
  fi

  if [[ $exit_code -eq 124 || $exit_code -eq 143 || $exit_code -eq 137 ]]; then
    rm -f "$tmpfile"
    return 124
  fi
  tr -d '\0' <"$tmpfile" 2>/dev/null
  rm -f "$tmpfile"
  return ${exit_code:-0}
}

get_command_version() {
  local cmd="$1" env_prefix output first_line i

  if [[ ${#CACHE_NAMES[@]} -gt 0 ]]; then
    for i in "${!CACHE_NAMES[@]}"; do
      [[ "${CACHE_NAMES[$i]}" == "$cmd" ]] && { VERSION_RESULT="${CACHE_VALS[$i]}"; return; }
    done
  fi

  env_prefix="$(get_accel_env "$cmd")"

  local ec tmpout
  tmpout="$(mktemp)"
  if [[ -n "$env_prefix" ]]; then
    run_with_timeout 1 env $env_prefix "$cmd" --version >"$tmpout" 2>&1 && ec=0 || ec=$?
  else
    run_with_timeout 1 "$cmd" --version >"$tmpout" 2>&1 && ec=0 || ec=$?
  fi
  output="$(tr -d '\0' <"$tmpout" 2>/dev/null)"
  # Timeout: skip -V fallback, mark unknown immediately
  if [[ "$ec" -ne 124 && -z "$output" ]]; then
    if [[ -n "$env_prefix" ]]; then
      run_with_timeout 1 env $env_prefix "$cmd" -V >"$tmpout" 2>&1 && ec=0 || ec=$?
    else
      run_with_timeout 1 "$cmd" -V >"$tmpout" 2>&1 && ec=0 || ec=$?
    fi
    output="$(tr -d '\0' <"$tmpout" 2>/dev/null)"
  fi
  rm -f "$tmpout"

  local result
  if [[ -z "$output" ]]; then
    result="-"
  else
    if command -v iconv >/dev/null 2>&1 && ! printf '%s' "$output" | iconv -f utf-8 -t utf-8 >/dev/null 2>&1; then
      output="$(printf '%s' "$output" | iconv -f latin1 -t utf-8 2>/dev/null || printf '%s' "$output")"
    fi

    first_line="${output%%$'\n'*}"
    if [[ "$first_line" =~ ([0-9]+\.[0-9]+(\.[0-9]+){1,2}) ]]; then
      result="${BASH_REMATCH[1]}"
    elif [[ "$first_line" =~ [Vv]ersion[[:space:]]+([0-9]+(\.[0-9]+)+) ]]; then
      result="${BASH_REMATCH[1]}"
    else
      result="-"
    fi
  fi

  CACHE_NAMES+=("$cmd")
  CACHE_VALS+=("$result")
  VERSION_RESULT="$result"

  _PROBE_COUNT=$(( ${_PROBE_COUNT:-0} + 1 ))
  if [[ $(( _PROBE_COUNT % 20 )) -eq 0 ]]; then
    printf '.' >&2
  fi
}
