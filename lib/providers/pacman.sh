# shellcheck shell=bash
# lib/providers/pacman.sh — Pacman provider (Arch/Manjaro)

pacman_provider() {
  local name ver
  while read -r name ver _; do
    [[ -z "$name" || -z "$ver" ]] && continue
    _wi_provider_name_exists "$name" && continue
    CACHE_NAMES+=("$name")
    CACHE_VALS+=("$ver")
  done < <(run_with_timeout 3 command pacman -Q 2>/dev/null)
}
