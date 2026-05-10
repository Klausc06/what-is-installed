#!/usr/bin/env bash
# Performance benchmark for what-is-installed
# Usage: bash bench/run.sh [runs]

set -euo pipefail
cd "$(dirname "$0")/.."

RUNS="${1:-3}"
export NO_COLOR=1

# Curated PATH — same directories the Desktop launcher exposes
BENCH_PATH="/opt/homebrew/bin:/opt/homebrew/sbin"
BENCH_PATH="$BENCH_PATH:/usr/local/bin:/usr/local/sbin"
BENCH_PATH="$BENCH_PATH:$HOME/.local/bin"
BENCH_PATH="$BENCH_PATH:$HOME/.npm-global/bin"
BENCH_PATH="$BENCH_PATH:$HOME/.cargo/bin"
BENCH_PATH="$BENCH_PATH:/usr/bin:/bin"
export PATH="$BENCH_PATH"

echo "=== what-is-installed benchmark ==="
echo "  runs: $RUNS"
echo "  path: $PATH"
echo

total_s=0
for i in $(seq 1 "$RUNS"); do
  start=$(date +%s)
  result=$(bash bin/what-is-installed 2>/dev/null)
  end=$(date +%s)
  elapsed=$((end - start))
  total_s=$((total_s + elapsed))
  tools=$(printf '%s\n' "$result" | grep -c '│' 2>/dev/null || echo 0)
  printf '  run %d: %ds, %d tools\n' "$i" "$elapsed" "$tools"
done

avg=$((total_s / RUNS))
echo
echo "avg: ${avg}s over $RUNS runs"
