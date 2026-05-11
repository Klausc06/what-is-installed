# shellcheck shell=bash
# lib/platform/windows.sh — Windows (MinGW/Cygwin) platform support

get_system_dirs() {
  # /mingw/ (with trailing slash) filters only the /mingw root directory,
  # NOT /mingw64/bin, /clang64/bin etc. — those get MinGW labels below.
  printf '%s' '^(/c/Windows/|/proc/|/usr/bin|/usr/lib/git-core|/mingw/)'
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
    */scoop/*)          printf '%s' 'Scoop' ;;
    */chocolatey/*|*/choco/*) printf '%s' 'Chocolatey' ;;
    */AppData/Roaming/npm) printf '%s' 'npm Global' ;;
    */AppData/Local/Programs/*|*/AppData/Roaming/*) printf '%s' 'AppData' ;;
    *)                 printf '%s' 'Other' ;;
  esac
}

section_color() {
  case "$1" in
    'User Local')       printf '%s%s' "$C_GREEN" "$C_BOLD" ;;
    'System Local')      printf '%s%s' "$C_DIM" "$C_BOLD" ;;
    'MinGW')            printf '%s%s' "$C_MAGENTA" "$C_BOLD" ;;
    'Scoop')            printf '%s%s' "$C_CYAN" "$C_BOLD" ;;
    'Chocolatey')       printf '%s%s' "$C_YELLOW" "$C_BOLD" ;;
    'AppData')          printf '%s%s' "$C_BLUE" "$C_BOLD" ;;
    'npm Global')       printf '%s%s' "$C_YELLOW" "$C_BOLD" ;;
    *)                   printf '%s%s' "$C_RESET" "$C_BOLD" ;;
  esac
}
