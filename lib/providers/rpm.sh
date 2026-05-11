# shellcheck shell=bash
# lib/providers/rpm.sh — RPM provider (RHEL/Fedora/CentOS)

rpm_provider() {
  local name ver
  while IFS=' ' read -r name ver; do
    [[ -z "$name" || -z "$ver" ]] && continue
    [[ "$name" == gpg-pubkey ]] && continue
    _wi_provider_name_exists "$name" && continue
    CACHE_NAMES+=("$name")
    CACHE_VALS+=("$ver")
  done < <(run_with_timeout 5 command rpm -qa --queryformat '%{NAME} %{VERSION}\n' 2>/dev/null)
}
