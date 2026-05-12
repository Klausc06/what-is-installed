# shellcheck shell=bash
# lib/providers/choco.sh — Chocolatey provider (Windows)

choco_provider() {
  local name ver
  while IFS='|' read -r name ver; do
    [[ -z "$name" || "$name" =~ ^Chocolatey ]] && continue
    _wi_provider_name_exists "$name" || _wi_cache_add "$name" "$ver"
  done < <(run_with_timeout 5 command choco list --local-only --limit-output 2>/dev/null)
}
