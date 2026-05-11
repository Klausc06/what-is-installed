# shellcheck shell=bash
# lib/providers/winget.sh — Winget provider (Windows)

winget_provider() {
  _wi_provider_parse_regex 5 "winget list" \
    '^(.+)[[:space:]]{2,}[^[:space:]]+[[:space:]]+([0-9][^[:space:]]*)' 1
}
