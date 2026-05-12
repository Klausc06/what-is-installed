# shellcheck shell=bash
# lib/providers/apt.sh — APT/dpkg provider (Debian/Ubuntu)

apt_provider() {
  local name ver
  while IFS=$'\t' read -r name ver _; do
    [[ -z "$name" || -z "$ver" ]] && continue
    _wi_provider_name_exists "$name" && continue
    _wi_cache_add "$name" "$ver"
  done < <(run_with_timeout 3 command dpkg-query -W -f '${Package}\t${Version}\n' 2>/dev/null)
}
