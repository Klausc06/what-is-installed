# shellcheck shell=bash
# lib/providers/winget.sh — Winget provider (Windows)

winget_provider() {
  local name ver
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    if [[ "$line" =~ ^([^[:space:]]+)[[:space:]]+[^[:space:]]+[[:space:]]+([0-9][^[:space:]]*) ]]; then
      name="${BASH_REMATCH[1]}"
      ver="${BASH_REMATCH[2]}"
      _wi_provider_name_exists "$name" || {
        CACHE_NAMES+=("$name")
        CACHE_VALS+=("$ver")
      }
    fi
  done < <(run_with_timeout 5 command winget list 2>/dev/null)
}
