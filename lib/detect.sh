# shellcheck shell=bash
# lib/detect.sh — OS detection

_detect_os() {
  case "$(uname -s)" in
    Darwin)  echo macos ;;
    Linux)   echo linux ;;
    *BSD*|DragonFly*) echo bsd ;;
    MINGW*|MSYS*) echo mingw ;;
    CYGWIN*) echo cygwin ;;
    *)       echo unknown ;;
  esac
}

_PLATFORM_OS="$(_detect_os)"
