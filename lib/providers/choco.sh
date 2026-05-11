# shellcheck shell=bash
# lib/providers/choco.sh — Chocolatey provider (Windows)

choco_provider() {
  local name ver
  while IFS='|' read -r name ver; do
    [[ -z "$name" || "$name" =~ ^Chocolatey ]] && continue
    _wi_provider_name_exists "$name" || {
      CACHE_NAMES+=("$name")
      CACHE_VALS+=("$ver")
    }
  done < <(run_with_timeout 5 command choco list --local-only --limit-output 2>/dev/null || true)
}
