#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"

detect_os() {
  case "$(uname -s)" in
    Darwin)  echo "macos" ;;
    Linux)   echo "linux" ;;
    *)       echo "other" ;;
  esac
}

detect_desktop_dir() {
  # XDG user dirs (Linux, works across locales)
  if command -v xdg-user-dir &>/dev/null; then
    xdg-user-dir DESKTOP 2>/dev/null && return
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

# ── symlink binary ──────────────────────────────────
mkdir -p "$BIN_DIR"
ln -sf "$ROOT/bin/what-is-installed" "$BIN_DIR/what-is-installed"
echo "  ✓  what-is-installed → $BIN_DIR/what-is-installed"

# ── PATH check ──────────────────────────────────────
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
  echo
  echo "  ⚠  $BIN_DIR is not in your PATH."
  case "$OS" in
    macos) rc="$HOME/.zshrc" ;;
    linux) rc="$HOME/.bashrc" ;;
    *)     rc="your shell profile" ;;
  esac
  echo "     Add this to $rc:"
  echo
  echo "       export PATH=\"\$HOME/.local/bin:\$PATH\""
  echo
fi

# ── desktop launcher ────────────────────────────────
DESKTOP="$(detect_desktop_dir)"

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
Exec=bash -c 'what-is-installed; read -p "Press Enter to close..."'
Terminal=true
Categories=Utility;
DESKTOPEOF
    chmod +x "$DESKTOP/what-is-installed.desktop"
    # Some file managers need the executable bit, others need trust
    command -v gio &>/dev/null && gio set "$DESKTOP/what-is-installed.desktop" metadata::trusted true 2>/dev/null || true
    echo "  ✓  Desktop launcher → $DESKTOP/what-is-installed.desktop"
    echo
    echo "  Double-click it in your file manager to run."
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
