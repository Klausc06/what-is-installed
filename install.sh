#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"

detect_os() {
  case "$(uname -s)" in
    Darwin)           echo "macos" ;;
    Linux)            echo "linux" ;;
    MINGW* | MSYS*)   echo "windows" ;;
    CYGWIN*)          echo "windows" ;;
    *)                echo "other" ;;
  esac
}

detect_desktop_dir() {
  local xdg_desktop

  # XDG user dirs (Linux, works across locales)
  if command -v xdg-user-dir &>/dev/null; then
    xdg_desktop="$(xdg-user-dir DESKTOP 2>/dev/null)" || true
    [[ -n "$xdg_desktop" && -d "$xdg_desktop" ]] && { echo "$xdg_desktop"; return; }
  fi
  # Windows (MinGW/Cygwin): Desktop is consistently named
  if [[ "$OS" == "windows" && -d "$HOME/Desktop" ]]; then
    echo "$HOME/Desktop" && return
  fi
  # Fallback: common paths
  for d in "$HOME/Desktop" "$HOME/桌面"; do
    [[ -d "$d" ]] && { echo "$d"; return; }
  done
  # Last resort
  [[ -d "$HOME" ]] && echo "$HOME"
}

OS="$(detect_os)"

echo "==> what-is-installed installer ($OS)"
echo

# ── install binary ──────────────────────────────────
mkdir -p "$BIN_DIR"

case "$OS" in
  windows)
    # On Windows, bash symlinks don't work in CMD/PowerShell.
    # Copy the script and create a .bat wrapper so it works everywhere.
    cp "$ROOT/bin/what-is-installed" "$BIN_DIR/what-is-installed"
    cat > "$BIN_DIR/what-is-installed.bat" <<'BATEOF'
@echo off
title what-is-installed
bash "%~dp0what-is-installed" %*
echo.
pause
BATEOF
    echo "  ✓  what-is-installed       → $BIN_DIR/what-is-installed"
    echo "  ✓  what-is-installed.bat   → $BIN_DIR/what-is-installed.bat"
    ;;
  *)
    ln -sf "$ROOT/bin/what-is-installed" "$BIN_DIR/what-is-installed"
    echo "  ✓  what-is-installed → $BIN_DIR/what-is-installed"
    ;;
esac

# ── PATH check ──────────────────────────────────────
if [[ ":${PATH}:" != *":${BIN_DIR}:"* ]]; then
  echo
  case "$OS" in
    macos)
      echo "  ⚠  $BIN_DIR is not in your PATH."
      echo "     Add this to ~/.zshrc:"
      echo '       export PATH="$HOME/.local/bin:$PATH"'
      ;;
    linux)
      echo "  ⚠  $BIN_DIR is not in your PATH."
      echo "     Add this to ~/.profile:"
      echo '       export PATH="$HOME/.local/bin:$PATH"'
      ;;
    windows)
      rc="$HOME/.bashrc"
      if [[ -f "$rc" ]] && ! grep -q '$HOME/.local/bin' "$rc" 2>/dev/null; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$rc"
        echo "  ⚠  Added $BIN_DIR to $rc"
        echo "     Restart your Git Bash terminal for it to take effect."
      else
        echo "  ⚠  $BIN_DIR is not in your PATH."
        echo "     Add this to $rc:"
        echo '       export PATH="$HOME/.local/bin:$PATH"'
      fi
      ;;
    *)
      echo "  ⚠  $BIN_DIR is not in your PATH."
      echo "     Add it to your shell profile."
      ;;
  esac
  echo
fi

# ── desktop launcher ────────────────────────────────
DESKTOP="$(detect_desktop_dir)"
mkdir -p "$DESKTOP"

case "$OS" in
  macos)
    cp "$ROOT/launchers/what-is-installed.command" "$DESKTOP/what-is-installed.command"
    chmod +x "$DESKTOP/what-is-installed.command"
    echo "  ✓  Desktop launcher → $DESKTOP/what-is-installed.command"
    echo
    echo "  Double-click it in Finder to run."
    ;;

  linux)
    cat > "$DESKTOP/what-is-installed.desktop" <<'DESKTOPEOF'
[Desktop Entry]
Type=Application
Name=what-is-installed
Comment=Scan PATH for installed CLI tools
Exec=bash -c 'export PATH="$HOME/.local/bin:$PATH"; what-is-installed; read -rp "Press Enter to close..."'
Terminal=true
Categories=Utility;
DESKTOPEOF
    chmod +x "$DESKTOP/what-is-installed.desktop"
    command -v gio &>/dev/null && gio set "$DESKTOP/what-is-installed.desktop" metadata::trusted true 2>/dev/null || true
    echo "  ✓  Desktop launcher → $DESKTOP/what-is-installed.desktop"
    echo
    echo "  Double-click it in your file manager to run."
    ;;

  windows)
    # Copy .bat launcher from repo template.
    cp "$ROOT/launchers/what-is-installed.bat" "$DESKTOP/what-is-installed.bat"
    echo "  ✓  Desktop launcher → $DESKTOP/what-is-installed.bat"
    echo
    echo "  Double-click it in Explorer to run."
    echo "  Or run 'what-is-installed' in Git Bash / CMD / PowerShell."
    ;;

  *)
    echo "  ⚠  Desktop launcher not supported on this platform."
    echo "     Run 'what-is-installed' from your terminal instead."
    ;;
esac

echo
echo "Done. Try it:"
echo
echo "  what-is-installed"
