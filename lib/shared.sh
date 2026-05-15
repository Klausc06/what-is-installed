# shellcheck shell=bash
# lib/shared.sh — Cross-platform utilities and version probing

CACHE_NAMES=()
CACHE_VALS=()
_CACHE_STR=$'\n'
VERSION_RESULT=""

# ── Cache utilities (Bash 3.2 compatible — no associative arrays) ──

# Insertion sort on CACHE_NAMES (ascending), moving CACHE_VALS in lockstep.
# O(n^2) but n < 200 in practice. Called once after providers complete.
_sort_cache() {
  local n=${#CACHE_NAMES[@]} i j key_name key_val
  (( n < 2 )) && return
  for ((i = 1; i < n; i++)); do
    key_name="${CACHE_NAMES[$i]}"
    key_val="${CACHE_VALS[$i]}"
    j=$i
    while (( j > 0 )) && [[ "${CACHE_NAMES[$((j-1))]}" > "$key_name" ]]; do
      CACHE_NAMES[$j]="${CACHE_NAMES[$((j-1))]}"
      CACHE_VALS[$j]="${CACHE_VALS[$((j-1))]}"
      ((j--))
    done
    CACHE_NAMES[$j]="$key_name"
    CACHE_VALS[$j]="$key_val"
  done
}

# Binary search on sorted CACHE_NAMES.
# Sets _CACHE_INDEX if found; returns 0 if found, 1 if not found.
_cache_lookup() {
  local needle="$1" low=0 high mid
  high=$((${#CACHE_NAMES[@]} - 1))
  while (( low <= high )); do
    mid=$(( (low + high) / 2 ))
    if [[ "${CACHE_NAMES[$mid]}" < "$needle" ]]; then
      low=$((mid + 1))
    elif [[ "${CACHE_NAMES[$mid]}" > "$needle" ]]; then
      high=$((mid - 1))
    else
      _CACHE_INDEX=$mid
      return 0
    fi
  done
  return 1
}

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

_escape_glob() {
  local val="$1"
  val="${val//\\/\\\\}"
  val="${val//\[/\\[}"
  val="${val//\*/\\\*}"
  val="${val//\?/\\\?}"
  printf '%s' "$val"
}

run_with_timeout() {
  local timeout="${1:-2}" tmpfile pid exit_code waited
  shift
  tmpfile="$(mktemp)" || { echo "ERROR: mktemp failed" >&2; return 1; }

  # Prefer GNU timeout if available (fast, reliable across platforms).
  # On Windows, C:\Windows\System32\timeout.exe is a completely different
  # program that just pauses — it would swallow the command and break every
  # version probe.  Detect and reject it.
  local timeout_cmd=""
  if command -v timeout >/dev/null 2>&1; then
    local _tout_ver
    _tout_ver="$(timeout --version 2>&1 || true)"
    if [[ "$_tout_ver" == *GNU* || "$_tout_ver" == *coreutils* || "$_tout_ver" == *Timeout* ]]; then
      timeout_cmd="timeout"
    fi
  fi
  if [[ -z "$timeout_cmd" ]] && command -v gtimeout >/dev/null 2>&1; then
    timeout_cmd="gtimeout"
  fi
  if [[ -n "$timeout_cmd" ]]; then
    "$timeout_cmd" "$timeout" "$@" >"$tmpfile" 2>&1
    exit_code=$?
  else
    # Fallback: foreground polling loop — no background kill needed
    # (background { sleep; kill; } & fails on Windows Git Bash)
    "$@" >"$tmpfile" 2>&1 &
    pid=$!
    # Bash can't do float arithmetic. Round fractional timeouts up to next
    # second-equivalent so that e.g. 0.3 → 5 ticks (1.0s).
    local max_ticks
    if [[ "$timeout" == *.* ]]; then
      max_ticks=$(( (${timeout%%.*} + 1) * 5 ))
    else
      max_ticks=$(( timeout * 5 ))
    fi
    waited=0
    while kill -0 "$pid" 2>/dev/null && [[ $waited -lt $max_ticks ]]; do
      sleep 0.2
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
  local cmd="$1" env_prefix output first_line

  if [[ ${#CACHE_NAMES[@]} -gt 0 ]]; then
    if _cache_lookup "$cmd"; then
      VERSION_RESULT="${CACHE_VALS[$_CACHE_INDEX]}"
      return
    fi
  fi

  env_prefix="$(get_accel_env "$cmd")"

  local ec flag tmpout
  tmpout="$(mktemp)" || { echo "ERROR: mktemp failed" >&2; VERSION_RESULT="-"; return; }
  for flag in --version -V; do
    if [[ -n "$env_prefix" ]]; then
      run_with_timeout 0.3 env "$env_prefix" "$cmd" "$flag" >"$tmpout" 2>&1 && ec=0 || ec=$?
    else
      run_with_timeout 0.3 "$cmd" "$flag" >"$tmpout" 2>&1 && ec=0 || ec=$?
    fi
    output="$(tr -d '\0' <"$tmpout" 2>/dev/null)"
    if [[ -n "$output" || "$ec" -eq 124 ]]; then
      break
    fi
  done
  rm -f "$tmpout"

  local result
  if [[ -z "$output" ]]; then
    result="-"
  else
    if command -v iconv >/dev/null 2>&1 && ! printf '%s' "$output" | iconv -f utf-8 -t utf-8 >/dev/null 2>&1; then
      output="$(printf '%s' "$output" | iconv -f latin1 -t utf-8 2>/dev/null || printf '%s' "$output")"
    fi

    first_line="${output%%$'\n'*}"
    if [[ "$first_line" =~ ([0-9]+\.[0-9]+(\.[0-9]+){0,2}) ]]; then
      result="${BASH_REMATCH[1]}"
    elif [[ "$first_line" =~ [Vv]ersion[[:space:]]+([0-9]+(\.[0-9]+)+) ]]; then
      result="${BASH_REMATCH[1]}"
    else
      result="-"
    fi
  fi

  CACHE_NAMES+=("$cmd")
  CACHE_VALS+=("$result")
  _CACHE_STR+="$cmd=$result"$'\n'
  VERSION_RESULT="$result"
}
