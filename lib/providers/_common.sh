# shellcheck shell=bash
# lib/providers/_common.sh — Shared provider utilities

# Parse pipe-delimited command output with regex, populating CACHE_NAMES/CACHE_VALS.
# Args: timeout cmd regex
_wi_provider_parse_regex() {
  local timeout="$1" cmd="$2" regex="$3"
  local name ver _orig_extglob
  _orig_extglob="$(shopt -p extglob 2>/dev/null)"
  shopt -s extglob 2>/dev/null
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    if [[ "$line" =~ $regex ]]; then
      name="${BASH_REMATCH[1]}"
      ver="${BASH_REMATCH[2]}"
      name="${name%%+([[:space:]])}"
      _wi_provider_name_exists "$name" || _wi_cache_add "$name" "$ver"
    fi
  done < <(run_with_timeout "$timeout" command $cmd 2>/dev/null)
  eval "$_orig_extglob"
}
