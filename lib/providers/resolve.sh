# shellcheck shell=bash
# lib/providers/resolve.sh — Provider resolver (OS dispatcher)

_wi_provider_name_exists() {
  local name="$1" i
  for i in "${!CACHE_NAMES[@]}"; do
    [[ "${CACHE_NAMES[$i]}" == "$name" ]] && return 0
  done
  return 1
}

resolve_providers() {
  command -v cargo >/dev/null 2>&1 && cargo_provider

  case "$_PLATFORM_OS" in
    macos|linux|bsd)
      command -v brew >/dev/null 2>&1 && brew_provider
      ;;
  esac

  case "$_PLATFORM_OS" in
    mingw|cygwin)
      command -v winget >/dev/null 2>&1 && winget_provider
      command -v scoop >/dev/null 2>&1 && scoop_provider
      command -v choco >/dev/null 2>&1 && choco_provider
      ;;
  esac

  case "$_PLATFORM_OS" in
    linux|bsd)
      command -v dpkg-query >/dev/null 2>&1 && apt_provider
      command -v snap >/dev/null 2>&1 && snap_provider
      command -v flatpak >/dev/null 2>&1 && flatpak_provider
      ;;
  esac
}
