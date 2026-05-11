# shellcheck shell=bash
# lib/providers/winget.sh — Winget provider (Windows)

winget_provider() {
  local name ver
  shopt -s extglob
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    # Use .+ with {2,} column boundary instead of [^[:space:]]+ so
    # multi-word names (Microsoft Edge, Visual Studio Code) are captured.
    # Greedy .+ eats trailing spaces — trim with %%+([[:space:]]).
    if [[ "$line" =~ ^(.+)[[:space:]]{2,}[^[:space:]]+[[:space:]]+([0-9][^[:space:]]*) ]]; then
      name="${BASH_REMATCH[1]%%+([[:space:]])}"
      ver="${BASH_REMATCH[2]}"
      _wi_provider_name_exists "$name" || {
        CACHE_NAMES+=("$name")
        CACHE_VALS+=("$ver")
      }
    fi
  done < <(run_with_timeout 5 command winget list 2>/dev/null)
}
