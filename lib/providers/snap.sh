# shellcheck shell=bash
# lib/providers/snap.sh — Snap provider (Ubuntu/Linux)

snap_provider() {
  local name ver
  while read -r name ver _; do
    [[ -z "$name" || -z "$ver" || "$name" == "Name" ]] && continue
    _wi_provider_name_exists "$name" && continue
    _wi_cache_add "$name" "$ver"
  done < <(run_with_timeout 3 command snap list 2>/dev/null)
}
