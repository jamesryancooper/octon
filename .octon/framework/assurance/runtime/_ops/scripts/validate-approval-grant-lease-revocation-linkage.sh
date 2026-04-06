#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/closure-packet-common.sh"
for file in \
  "$OCTON_DIR/state/evidence/control/execution/authority-grant-bundle-uec-safe-stage-approval-exercise-20260402.yml" \
  "$OCTON_DIR/state/evidence/control/execution/authority-grant-bundle-uec-safe-stage-lease-revocation-exercise-20260402.yml" \
  "$OCTON_DIR/state/evidence/control/execution/authority-decision-uec-safe-stage-approval-exercise-20260402.yml" \
  "$OCTON_DIR/state/evidence/control/execution/authority-decision-uec-safe-stage-lease-revocation-exercise-20260402.yml"; do
  [[ -f "$file" ]] || exit 1
done
yq -e '.quorum_policy_ref == ".octon/instance/governance/contracts/quorum-policies/default.yml"' \
  "$OCTON_DIR/state/evidence/control/execution/authority-grant-bundle-uec-safe-stage-approval-exercise-20260402.yml" >/dev/null
yq -e '.quorum_policy_ref == ".octon/instance/governance/contracts/quorum-policies/default.yml"' \
  "$OCTON_DIR/state/evidence/control/execution/authority-grant-bundle-uec-safe-stage-lease-revocation-exercise-20260402.yml" >/dev/null
yq -e '.exception_refs[0] == ".octon/state/control/execution/exceptions/leases/lease-uec-safe-stage-lease-revocation-exercise-20260402.yml"' \
  "$OCTON_DIR/state/evidence/control/execution/authority-grant-bundle-uec-safe-stage-lease-revocation-exercise-20260402.yml" >/dev/null
yq -e '.revocation_refs[0] == ".octon/state/control/execution/revocations/revoke-uec-safe-stage-lease-revocation-exercise-20260402.yml"' \
  "$OCTON_DIR/state/evidence/control/execution/authority-grant-bundle-uec-safe-stage-lease-revocation-exercise-20260402.yml" >/dev/null

