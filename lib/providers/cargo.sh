# shellcheck shell=bash
# lib/providers/cargo.sh — Cargo provider (cross-platform)

cargo_provider() {
  local name ver
  while IFS= read -r line; do
    if [[ "$line" =~ ^([^[:space:]]+)[[:space:]]+v([0-9][^:]*): ]]; then
      name="${BASH_REMATCH[1]}"
      ver="${BASH_REMATCH[2]}"
      _wi_provider_name_exists "$name" || _wi_cache_add "$name" "$ver"
    fi
  done < <(run_with_timeout 3 command cargo install --list 2>/dev/null)
}
