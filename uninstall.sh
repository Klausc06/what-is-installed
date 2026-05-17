#!/usr/bin/env bash
set -euo pipefail

# what-is-installed uninstaller
# Removes the binary, launcher, and PATH entries added by install.sh.

BIN_DIR="$HOME/.local/bin"
BIN="$BIN_DIR/what-is-installed"

echo "==> what-is-installed uninstaller"
echo

removed=0

# Remove binary
if [[ -f "$BIN" || -L "$BIN" ]]; then
  rm -f "$BIN"
  echo "  ✓  Removed $BIN"
  ((removed++))
else
  echo "  -  $BIN not found (skip)"
fi

# Remove Windows .bat wrapper
if [[ -f "$BIN.bat" ]]; then
  rm -f "$BIN.bat"
  echo "  ✓  Removed $BIN.bat"
  ((removed++))
fi

# Remove lib/ copy (Windows install)
if [[ -d "$HOME/.local/lib" ]]; then
  rm -rf "$HOME/.local/lib"
  echo "  ✓  Removed $HOME/.local/lib/"
  ((removed++))
fi

# Remove desktop launchers
DESKTOP="${HOME}/Desktop"
for f in "$DESKTOP/what-is-installed.command" "$DESKTOP/what-is-installed.desktop" "$DESKTOP/what-is-installed.bat"; do
  if [[ -f "$f" ]]; then
    rm -f "$f"
    echo "  ✓  Removed $f"
    ((removed++))
  fi
done

echo
if [[ $removed -eq 0 ]]; then
  echo "Nothing to remove — what-is-installed was not found."
else
  echo "Done. Removed $removed file(s)."
  echo
  echo "Note: If install.sh added PATH entries to your shell config,"
  echo "you may want to remove those lines from ~/.bashrc or ~/.zshrc."
fi
