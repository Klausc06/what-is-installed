# shellcheck shell=bash
# lib/providers/brew.sh — Homebrew provider (cross-platform)

brew_provider() {
  local name ver
  while IFS=' ' read -r name ver _; do
    [[ -z "$name" || -z "$ver" ]] && continue
    _wi_provider_name_exists "$name" && continue
    _wi_cache_add "$name" "$ver"
  done < <(run_with_timeout 3 command brew list --versions 2>/dev/null)
}
