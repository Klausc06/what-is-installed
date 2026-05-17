# shellcheck shell=bash
# lib/detect.sh — OS detection
#
# Note: This file checks symlink targets at runtime. A TOCTOU race is
# theoretically possible if a symlink is swapped between check and use,
# but the risk is low — the main script uses mktemp + EXIT trap for
# all temporary files, and the detection runs once at startup.

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
