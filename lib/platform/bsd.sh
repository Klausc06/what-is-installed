# shellcheck shell=bash
# lib/platform/bsd.sh — BSD platform support

get_system_dirs() {
  printf '%s' '^(/bin|/sbin|/usr/bin|/usr/sbin|/rescue/)'
}

get_family_skip_patterns() {
  printf '%s' ''
}

get_accel_env() {
  printf '%s' ''
}

section_label() {
  case "$1" in
    */.local/bin)      printf '%s' 'User Local' ;;
    */usr/local/bin|*/usr/local/sbin) printf '%s' 'System Local' ;;
    *)                 printf '%s' 'Other' ;;
  esac
}

section_color() {
  case "$1" in
    'User Local')       printf '%s%s' "$C_GREEN" "$C_BOLD" ;;
    'System Local')      printf '%s%s' "$C_DIM" "$C_BOLD" ;;
    *)                   printf '%s%s' "$C_RESET" "$C_BOLD" ;;
  esac
}
