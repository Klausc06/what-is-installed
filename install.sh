#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"
DESKTOP_DIR="$HOME/Desktop"

echo "==> what-is-installed installer"
echo

# ── symlink binary ──────────────────────────────────
mkdir -p "$BIN_DIR"
ln -sf "$ROOT/bin/what-is-installed" "$BIN_DIR/what-is-installed"
echo "  ✓  what-is-installed → $BIN_DIR/what-is-installed"

# ── PATH check ──────────────────────────────────────
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
  echo
  echo "  ⚠  $BIN_DIR is not in your PATH."
  echo "     Add this to your ~/.zshrc or ~/.bashrc:"
  echo
  echo "       export PATH=\"\$HOME/.local/bin:\$PATH\""
  echo
fi

# ── desktop launcher ────────────────────────────────
if [[ -d "$DESKTOP_DIR" ]]; then
  cp "$ROOT/launchers/what-is-installed.command" "$DESKTOP_DIR/what-is-installed.command"
  chmod +x "$DESKTOP_DIR/what-is-installed.command"
  echo "  ✓  Desktop launcher → $DESKTOP_DIR/what-is-installed.command"
  echo
  echo "  Double-click it in Finder to run."
else
  echo "  ⚠  No Desktop directory found, skipping launcher."
fi

echo
echo "Done. Try it:"
echo
echo "  what-is-installed"
