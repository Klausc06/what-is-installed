# shellcheck shell=bash
# lib/platform/macos.sh — macOS platform support

get_system_dirs() {
  printf '%s' '^(/bin|/sbin|/usr/bin|/usr/sbin|/System/|/Library/Apple/)'
}

get_family_skip_patterns() {
  printf '%s' '.*-(intel64|arm64)$'
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
    /opt/homebrew/bin) printf '%s' 'Homebrew' ;;
    */usr/local/bin|*/usr/local/sbin)
      if [[ -x /usr/local/bin/brew ]]; then
        printf '%s' 'Homebrew'
      else
        printf '%s' 'System Local'
      fi
      ;;
    */Library/Frameworks/Python.framework/*/bin) printf '%s' 'Python Framework' ;;
    *)                 printf '%s' 'Other' ;;
  esac
}

section_color() {
  case "$1" in
    'User Local')       printf '%s%s' "$C_GREEN" "$C_BOLD" ;;
    'npm Global')        printf '%s%s' "$C_YELLOW" "$C_BOLD" ;;
    'Homebrew')          printf '%s%s' "$C_CYAN" "$C_BOLD" ;;
    'Python Framework')  printf '%s%s' "$C_BLUE" "$C_BOLD" ;;
    'System Local')      printf '%s%s' "$C_DIM" "$C_BOLD" ;;
    *)                   printf '%s%s' "$C_RESET" "$C_BOLD" ;;
  esac
}
