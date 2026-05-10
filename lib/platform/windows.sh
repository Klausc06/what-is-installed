# shellcheck shell=bash
# lib/platform/windows.sh — Windows (MinGW/Cygwin) platform support

get_system_dirs() {
  printf '%s' '^(/c/Windows/|/proc/|/usr/bin|/usr/lib/git-core|/mingw)'
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
    */mingw64/bin|*/mingw32/bin) printf '%s' 'MinGW' ;;
    */clang64/bin|*/ucrt64/bin)  printf '%s' 'MinGW' ;;
    */mingw*/bin)       printf '%s' 'MinGW' ;;
    *)                 printf '%s' 'Other' ;;
  esac
}

section_color() {
  case "$1" in
    'User Local')       printf '%s%s' "$C_GREEN" "$C_BOLD" ;;
    'System Local')      printf '%s%s' "$C_DIM" "$C_BOLD" ;;
    'MinGW')            printf '%s%s' "$C_MAGENTA" "$C_BOLD" ;;
    *)                   printf '%s%s' "$C_RESET" "$C_BOLD" ;;
  esac
}
