# shellcheck shell=bash
# lib/providers/resolve.sh — Provider resolver (OS dispatcher)

_wi_cache_add() {
  CACHE_NAMES+=("$1")
  CACHE_VALS+=("$2")
  _CACHE_STR+="$1=$2"$'\n'
}

_wi_provider_name_exists() {
  [[ "$_CACHE_STR" == *$'\n'"$1="* ]]
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
      command -v rpm >/dev/null 2>&1 && rpm_provider
      command -v pacman >/dev/null 2>&1 && pacman_provider
      command -v snap >/dev/null 2>&1 && snap_provider
      command -v flatpak >/dev/null 2>&1 && flatpak_provider
      ;;
  esac
}
