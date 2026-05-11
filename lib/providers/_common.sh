# shellcheck shell=bash
# lib/providers/_common.sh — Shared provider utilities

# Parse pipe-delimited command output with regex, populating CACHE_NAMES/CACHE_VALS.
# Args: timeout cmd regex [need_trim]
#   need_trim=1: apply %%+([[:space:]]) to captured name (for greedy regexes)
_wi_provider_parse_regex() {
  local timeout="$1" cmd="$2" regex="$3" need_trim="${4:-0}"
  local name ver
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    if [[ "$line" =~ $regex ]]; then
      name="${BASH_REMATCH[1]}"
      ver="${BASH_REMATCH[2]}"
      if [[ "$need_trim" -eq 1 ]]; then
        shopt -s extglob 2>/dev/null
        name="${name%%+([[:space:]])}"
      fi
      _wi_provider_name_exists "$name" || {
        CACHE_NAMES+=("$name")
        CACHE_VALS+=("$ver")
      }
    fi
  done < <(run_with_timeout "$timeout" command $cmd 2>/dev/null)
}
