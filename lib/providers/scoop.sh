# shellcheck shell=bash
# lib/providers/scoop.sh — Scoop provider (Windows)

scoop_provider() {
  _wi_provider_parse_regex 3 "scoop list" \
    '^([^[:space:]]+)[[:space:]]+([0-9][^[:space:]]*)'
}
