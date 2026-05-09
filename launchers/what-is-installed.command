#!/bin/bash
# what-is-installed — One-click launcher shortcut

# Ensure tools are in PATH when launched from Finder (no shell profile)
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"

if ! command -v what-is-installed >/dev/null 2>&1; then
    echo "Error: what-is-installed not found in PATH"
    read -p "Press Enter to close..."
    exit 1
fi

exec what-is-installed "$@"
