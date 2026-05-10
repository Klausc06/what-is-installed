#!/bin/bash
# what-is-installed — One-click launcher shortcut

# Ensure tools are in PATH when launched from Finder (no shell profile)
[[ -d /opt/homebrew/bin ]] && export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
[[ -d /usr/local/bin ]] && export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"

if ! command -v what-is-installed >/dev/null 2>&1; then
    echo "Error: what-is-installed not found in PATH"
    read -rp "Press Enter to close..."
    exit 1
fi

exec what-is-installed "$@"
