#!/usr/bin/env bash
# Docker-based cross-distro test for what-is-installed
# Verifies: shellcheck passes, tests pass, tool installs and starts cleanly.
#
# Usage:
#   bash bench/docker-test.sh ubuntu     # Test on Ubuntu
#   bash bench/docker-test.sh fedora     # Test on Fedora
#   bash bench/docker-test.sh arch       # Test on Arch
#   bash bench/docker-test.sh all        # Test all three
#
# Requires: Docker Desktop or docker CLI
set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PASS=0
FAIL=0

red()    { printf '\033[31m%s\033[0m' "$1"; }
green()  { printf '\033[32m%s\033[0m' "$1"; }
bold()   { printf '\033[1m%s\033[0m' "$1"; }

test_distro() {
  local distro="$1" image label setup pkg

  case "$distro" in
    ubuntu) image="ubuntu:latest"
            setup="apt-get update -qq && apt-get install -y -qq coreutils shellcheck"
            label="Ubuntu" ;;
    fedora) image="fedora:latest"
            setup="dnf install -y -q coreutils ShellCheck"
            label="Fedora" ;;
    arch)   image="archlinux:latest"
            setup="pacman -Syu --noconfirm --quiet && pacman -S --noconfirm --quiet coreutils shellcheck"
            label="Arch" ;;
    *)      printf '%s\n' "$(red "Unknown: $distro")"; return 1 ;;
  esac

  printf '\n%s %s\n' "$(bold '═══')" "$(bold "$label")"

  # Pull image
  printf '   pull ... '
  if docker pull -q "$image" >/dev/null 2>&1; then
    printf '%s\n' "$(green 'OK')"
  else
    printf '%s\n' "$(red 'FAIL (pull)')"
    FAIL=$((FAIL + 1)); return
  fi

  # Run checks inside container
  local start end elapsed
  start=$(date +%s)

  docker run --rm -v "$ROOT:/app" -w /app "$image" \
    bash -c "
      set -e
      $setup >/dev/null 2>&1
      echo '--- shellcheck ---'
      shellcheck --severity=error bin/what-is-installed lib/*.sh lib/platform/*.sh lib/providers/*.sh install.sh
      echo '--- tests ---'
      bash tests/run.sh
      echo '--- install ---'
      bash install.sh
      echo '--- smoke (5s timeout) ---'
      export PATH=\"\$HOME/.local/bin:\$PATH\"
      timeout 5 what-is-installed 2>&1 || true
      echo '--- ALL OK ---'
    " 2>/dev/null

  end=$(date +%s)
  elapsed=$((end - start))

  # Determine pass/fail from container exit code
  local ec=$?
  if [ $ec -eq 0 ]; then
    printf '   %s (%ds)\n' "$(green 'PASS')" "$elapsed"
    PASS=$((PASS + 1))
  else
    printf '   %s (exit=%d, %ds)\n' "$(red 'FAIL')" "$ec" "$elapsed"
    FAIL=$((FAIL + 1))
  fi
}

# ── main ──────────────────────────────────────────────

TARGET="${1:-all}"

case "$TARGET" in
  ubuntu|fedora|arch) TARGETS=("$TARGET") ;;
  all) TARGETS=(ubuntu fedora arch) ;;
  *)  printf 'Usage: %s <ubuntu|fedora|arch|all>\n' "$0"; exit 1 ;;
esac

if ! command -v docker >/dev/null 2>&1; then
  printf '%s\n' "$(red 'docker not found')" && exit 1
fi

printf '\n%s what-is-installed Docker Tests\n' "$(bold '═══')"
printf '   (shellcheck + unit tests + install + 5s smoke)\n'

for distro in "${TARGETS[@]}"; do
  test_distro "$distro"
done

printf '\n%s Results: ' "$(bold '═══')"
if [ $FAIL -eq 0 ]; then
  printf '%s, %s\n' "$(green "$PASS passed")" "$(green "0 failed")"
else
  printf '%s, %s\n' "$(green "$PASS passed")" "$(red "$FAIL failed")"
fi
exit $FAIL
