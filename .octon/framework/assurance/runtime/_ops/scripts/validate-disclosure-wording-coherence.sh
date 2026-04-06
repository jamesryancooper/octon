#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/closure-packet-common.sh"
pattern="$(forbidden_phrase_pattern)"
if rg -n -i "$pattern" \
  "$OCTON_DIR/instance/governance/disclosure/harness-card.yml" \
  "$OCTON_DIR/instance/governance/closure/closure-summary.yml" \
  "$OCTON_DIR/state/evidence/disclosure/runs" >/dev/null 2>&1; then
  echo "[ERROR] forbidden closure wording still present" >&2
  exit 1
fi

