#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/closure-packet-common.sh"
require_yq
POLICY="$OCTON_DIR/instance/governance/contracts/quorum-policies/default.yml"
yq -e '.quorum_policy_id == "default"' "$POLICY" >/dev/null
for file in \
  "$OCTON_DIR/state/control/execution/approvals/requests/uec-safe-stage-approval-exercise-20260402.yml" \
  "$OCTON_DIR/state/control/execution/approvals/grants/grant-uec-safe-stage-approval-exercise-20260402.yml" \
  "$OCTON_DIR/state/control/execution/approvals/requests/uec-safe-stage-lease-revocation-exercise-20260402.yml" \
  "$OCTON_DIR/state/control/execution/approvals/grants/grant-uec-safe-stage-lease-revocation-exercise-20260402.yml"; do
  yq -e '.quorum_policy_ref == ".octon/instance/governance/contracts/quorum-policies/default.yml"' "$file" >/dev/null
done

