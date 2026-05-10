# shellcheck shell=bash
# lib/platform/linux.sh — Linux platform support

get_system_dirs() {
  printf '%s' '^(/bin|/sbin|/usr/bin|/usr/sbin|/lib/systemd/)'
}

get_family_skip_patterns() {
  printf '%s' ''
}

get_accel_env() {
  case "$1" in
    brew) printf '%s' 'HOMEBREW_NO_AUTO_UPDATE=1' ;;
    *)    printf '%s' '' ;;
  esac
}

section_label() {
  case "$1" in
    */.local/bin)      printf '%s' 'User Local' ;;
    */.npm-global/bin) printf '%s' 'npm Global' ;;
    */usr/local/bin|*/usr/local/sbin) printf '%s' 'System Local' ;;
    */snap/bin)         printf '%s' 'Snap' ;;
    */linuxbrew/*/bin)  printf '%s' 'Homebrew' ;;
    *)                 printf '%s' 'Other' ;;
  esac
}

section_color() {
  case "$1" in
    'User Local')       printf '%s%s' "$C_GREEN" "$C_BOLD" ;;
    'npm Global')        printf '%s%s' "$C_YELLOW" "$C_BOLD" ;;
    'Homebrew')          printf '%s%s' "$C_CYAN" "$C_BOLD" ;;
    'Snap')              printf '%s%s' "$C_MAGENTA" "$C_BOLD" ;;
    'System Local')      printf '%s%s' "$C_DIM" "$C_BOLD" ;;
    *)                   printf '%s%s' "$C_RESET" "$C_BOLD" ;;
  esac
}

brew_provider() {
  local name ver
  while IFS=' ' read -r name ver _; do
    [[ -z "$name" || -z "$ver" ]] && continue
    _wi_provider_name_exists "$name" && continue
    CACHE_NAMES+=("$name")
    CACHE_VALS+=("$ver")
  done < <(run_with_timeout 3 command brew list --versions 2>/dev/null)
}

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
