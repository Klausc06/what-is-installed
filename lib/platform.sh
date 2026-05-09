detect_os() {
  case "$(uname -s)" in
    Darwin)         printf '%s' 'macos' ;;
    Linux)          printf '%s' 'linux' ;;
    *BSD|DragonFly) printf '%s' 'bsd' ;;
    MINGW* | MSYS*) printf '%s' 'mingw' ;;
    CYGWIN*)        printf '%s' 'cygwin' ;;
    *)              printf '%s' 'unknown' ;;
  esac
}

_PLATFORM_OS="$(detect_os)"

get_system_dirs() {
  case "$_PLATFORM_OS" in
    macos)        printf '%s' '^(/bin|/sbin|/usr/bin|/usr/sbin|/System/|/Library/Apple/)' ;;
    linux)        printf '%s' '^(/bin|/sbin|/usr/bin|/usr/sbin|/lib/systemd/)' ;;
    bsd)          printf '%s' '^(/bin|/sbin|/usr/bin|/usr/sbin|/rescue/)' ;;
    mingw|cygwin) printf '%s' '^(/c/Windows/|/proc/|/usr/bin|/usr/lib/git-core)' ;;
    *)            printf '%s' '^(/bin|/sbin|/usr/bin|/usr/sbin)' ;;
  esac
}

get_family_skip_patterns() {
  case "$_PLATFORM_OS" in
    macos) printf '%s' '.*-(intel64|arm64)$' ;;
    *)     printf '%s' '' ;;
  esac
}

get_accel_env() {
  case "$1" in
    brew) printf '%s' 'HOMEBREW_NO_AUTO_UPDATE=1' ;;
    *)    printf '%s' '' ;;
  esac
}

section_label() {
  case "$_PLATFORM_OS" in
    macos)
      case "$1" in
        */.local/bin)      printf '%s' 'User Local' ;;
        */.npm-global/bin) printf '%s' 'npm Global' ;;
        /opt/homebrew/bin) printf '%s' 'Homebrew' ;;
        */usr/local/bin|*/usr/local/sbin)
          # Intel Mac: /usr/local is Homebrew's default prefix
          if [[ -x /usr/local/bin/brew ]]; then
            printf '%s' 'Homebrew'
          else
            printf '%s' 'System Local'
          fi
          ;;
        */Library/Frameworks/Python.framework/*/bin) printf '%s' 'Python Framework' ;;
        *)                 printf '%s' 'Other' ;;
      esac
      ;;
    linux)
      case "$1" in
        */.local/bin)      printf '%s' 'User Local' ;;
        */.npm-global/bin) printf '%s' 'npm Global' ;;
        */usr/local/bin|*/usr/local/sbin) printf '%s' 'System Local' ;;
        */snap/bin)         printf '%s' 'Snap' ;;
        */linuxbrew/*/bin)  printf '%s' 'Homebrew' ;;
        *)                 printf '%s' 'Other' ;;
      esac
      ;;
    *)
      case "$1" in
        */.local/bin)      printf '%s' 'User Local' ;;
        */usr/local/bin|*/usr/local/sbin) printf '%s' 'System Local' ;;
        */mingw64/bin|*/mingw32/bin) printf '%s' 'MinGW' ;;
        */clang64/bin|*/ucrt64/bin)  printf '%s' 'MinGW' ;;
        */mingw*/bin)       printf '%s' 'MinGW' ;;
        *)                 printf '%s' 'Other' ;;
      esac
      ;;
  esac
}

section_color() {
  case "$1" in
    'User Local')       printf '%s%s' "$C_GREEN" "$C_BOLD" ;;
    'npm Global')        printf '%s%s' "$C_YELLOW" "$C_BOLD" ;;
    'Homebrew')          printf '%s%s' "$C_CYAN" "$C_BOLD" ;;
    'Python Framework')  printf '%s%s' "$C_BLUE" "$C_BOLD" ;;
    'Snap')              printf '%s%s' "$C_MAGENTA" "$C_BOLD" ;;
    'System Local')      printf '%s%s' "$C_DIM" "$C_BOLD" ;;
    *)                   printf '%s%s' "$C_RESET" "$C_BOLD" ;;
  esac
}
