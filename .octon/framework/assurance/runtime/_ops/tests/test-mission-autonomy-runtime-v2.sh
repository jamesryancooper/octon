#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
VALIDATOR="$SCRIPT_DIR/../scripts/validate-mission-autonomy-runtime-v2.sh"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)}"

"$VALIDATOR" --root "$ROOT_DIR" "$@"

tmp="$(mktemp -d)"
trap 'rm -r -f "$tmp"' EXIT

mkdir -p "$tmp/.octon/state/control/missions"
if "$VALIDATOR" --root "$tmp" >/tmp/octon-mar-v2-negative.out 2>&1; then
  echo "[ERROR] validator accepted rival state/control/missions root" >&2
  cat /tmp/octon-mar-v2-negative.out >&2
  exit 1
fi
grep -q "mission control may exist only under state/control/execution/missions" /tmp/octon-mar-v2-negative.out

echo "[OK] Mission Autonomy Runtime v2 negative placement control failed closed."
