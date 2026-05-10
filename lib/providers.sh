# shellcheck shell=bash
# lib/providers.sh — Package manager version providers
#
# Each provider populates CACHE_NAMES / CACHE_VALS with name→version
# mappings.  During PATH scanning, get_command_version() checks these
# arrays first and skips the expensive --version process execution for
# any pre-resolved name.

_wi_provider_name_exists() {
  local name="$1" i
  for i in "${!CACHE_NAMES[@]}"; do
    [[ "${CACHE_NAMES[$i]}" == "$name" ]] && return 0
  done
  return 1
}

# ── Homebrew provider ───────────────────────────────────────
# brew list --versions format: name version (one per line)
#   ca-certificates 2026-03-19
#   node 24.14.0
#   openssl@3 3.6.2

brew_provider() {
  local name ver
  while IFS=' ' read -r name ver _; do
    [[ -z "$name" || -z "$ver" ]] && continue
    _wi_provider_name_exists "$name" && continue
    CACHE_NAMES+=("$name")
    CACHE_VALS+=("$ver")
  done < <(run_with_timeout 3 command brew list --versions 2>/dev/null)
}

# ── Cargo provider ──────────────────────────────────────────
# cargo install --list format (one stanza per crate):
#   ripgrep v14.1.1:
#       ripgrep
#       other-binary

cargo_provider() {
  local name ver
  while IFS= read -r line; do
    if [[ "$line" =~ ^([^[:space:]]+)[[:space:]]+v([0-9][^:]*): ]]; then
      name="${BASH_REMATCH[1]}"
      ver="${BASH_REMATCH[2]}"
      _wi_provider_name_exists "$name" || {
        CACHE_NAMES+=("$name")
        CACHE_VALS+=("$ver")
      }
    fi
  done < <(run_with_timeout 3 command cargo install --list 2>/dev/null)
}

# ── Linux providers (stubs for future) ─────────────────────

apt_provider() {
  local name ver
  while IFS=$'\t' read -r name ver _; do
    [[ -z "$name" || -z "$ver" ]] && continue
    _wi_provider_name_exists "$name" && continue
    CACHE_NAMES+=("$name")
    CACHE_VALS+=("$ver")
  done < <(run_with_timeout 3 command dpkg-query -W -f '${Package}\t${Version}\n' 2>/dev/null)
}

snap_provider() {
  local name ver
  while read -r name ver _; do
    [[ -z "$name" || -z "$ver" || "$name" == "Name" ]] && continue
    _wi_provider_name_exists "$name" && continue
    CACHE_NAMES+=("$name")
    CACHE_VALS+=("$ver")
  done < <(run_with_timeout 3 command snap list 2>/dev/null)
}

flatpak_provider() {
  local name ver
  while read -r name _ ver _; do
    [[ -z "$name" || -z "$ver" ]] && continue
    _wi_provider_name_exists "$name" && continue
    CACHE_NAMES+=("$name")
    CACHE_VALS+=("$ver")
  done < <(run_with_timeout 3 command flatpak list --columns=application,version 2>/dev/null)
}

# ── Provider resolver ──────────────────────────────────────

resolve_providers() {
  local os
  os="$(detect_os)"

  case "$os" in
    macos|linux|bsd)
      command -v brew >/dev/null 2>&1 && brew_provider
      ;;
  esac

  command -v cargo >/dev/null 2>&1 && cargo_provider

  case "$os" in
    linux|bsd)
      command -v dpkg-query >/dev/null 2>&1 && apt_provider
      command -v snap >/dev/null 2>&1 && snap_provider
      command -v flatpak >/dev/null 2>&1 && flatpak_provider
      ;;
  esac
}
