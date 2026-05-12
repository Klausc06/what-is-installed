# shellcheck shell=bash
# lib/providers/flatpak.sh — Flatpak provider (Linux)

flatpak_provider() {
  local name ver
  while read -r name _ ver _; do
    [[ -z "$name" || -z "$ver" ]] && continue
    _wi_provider_name_exists "$name" && continue
    _wi_cache_add "$name" "$ver"
  done < <(run_with_timeout 3 command flatpak list --columns=application,version 2>/dev/null)
}
