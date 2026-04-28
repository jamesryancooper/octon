#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
VALIDATOR="$SCRIPT_DIR/../scripts/validate-continuous-stewardship-runtime-v3.sh"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)}"
PROGRAM_ID="${PROGRAM_ID:-octon-continuous-stewardship}"

"$VALIDATOR" --root "$ROOT_DIR" --program-id "$PROGRAM_ID" "$@"

tmp="$(mktemp -d)"
trap 'rm -r -f "$tmp"' EXIT

mkdir -p "$tmp/.octon"
ln -s "$ROOT_DIR/.octon/framework" "$tmp/.octon/framework"
ln -s "$ROOT_DIR/.octon/instance" "$tmp/.octon/instance"
mkdir -p "$tmp/.octon/state/control/stewardship/programs"
mkdir -p "$tmp/.octon/state/evidence/stewardship/programs"
mkdir -p "$tmp/.octon/state/continuity/stewardship/programs"
mkdir -p "$tmp/.octon/generated/cognition/projections/materialized"
cp -R "$ROOT_DIR/.octon/state/control/stewardship/programs/$PROGRAM_ID" "$tmp/.octon/state/control/stewardship/programs/$PROGRAM_ID"
cp -R "$ROOT_DIR/.octon/state/evidence/stewardship/programs/$PROGRAM_ID" "$tmp/.octon/state/evidence/stewardship/programs/$PROGRAM_ID"
cp -R "$ROOT_DIR/.octon/state/continuity/stewardship/programs/$PROGRAM_ID" "$tmp/.octon/state/continuity/stewardship/programs/$PROGRAM_ID"
cp -R "$ROOT_DIR/.octon/generated/cognition/projections/materialized/stewardship" "$tmp/.octon/generated/cognition/projections/materialized/stewardship"

status_file="$tmp/.octon/generated/cognition/projections/materialized/stewardship/status.yml"
control_status="$(yq -r '.status' "$tmp/.octon/state/control/stewardship/programs/$PROGRAM_ID/status.yml")"
replacement="active"
if [[ "$control_status" == "active" ]]; then
  replacement="idle"
fi
yq -i ".status = \"$replacement\"" "$status_file"

if "$VALIDATOR" --root "$tmp" --program-id "$PROGRAM_ID" >/tmp/octon-csrv3-negative.out 2>&1; then
  echo "[ERROR] validator accepted generated stewardship projection drift" >&2
  cat /tmp/octon-csrv3-negative.out >&2
  exit 1
fi
grep -q "generated stewardship status must mirror canonical control status" /tmp/octon-csrv3-negative.out

echo "[OK] Continuous Stewardship Runtime v3 generated-projection negative control failed closed."
