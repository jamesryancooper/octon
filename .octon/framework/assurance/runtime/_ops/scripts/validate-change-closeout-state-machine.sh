#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
MACHINE="$OCTON_DIR/framework/product/contracts/change-closeout-state-machine.yml"
DOC="$OCTON_DIR/framework/product/contracts/change-closeout-state-machine.md"
WORKFLOW="$OCTON_DIR/framework/orchestration/runtime/workflows/meta/closeout/workflow.yml"
POLICY="$OCTON_DIR/framework/product/contracts/default-work-unit.yml"

yq -e '.version == "1.1.0" and (.routes | length) == 3' "$MACHINE" >/dev/null
! yq -e '.routes[] | select(. == "direct-main")' "$MACHINE" >/dev/null 2>&1
yq -e '.containment.direct_main_admission == "denied" and .containment.branch_no_pr_landing == "denied" and .containment.cleanup_effects == "denied"' "$MACHINE" >/dev/null
yq -e '.target_lifecycle_defaults.unspecified_closeout_request == "preserved"' "$MACHINE" >/dev/null
! yq -e '.lifecycle_outcomes[] | select(. == "cleaned")' "$MACHINE" >/dev/null 2>&1
yq -e '.phases[] | select(.phase_id == "effect-denial")' "$MACHINE" >/dev/null
yq -e '.side_effect_class == "read_only" and .constraints.forbidden_effects | length > 0' "$WORKFLOW" >/dev/null
yq -e '.state_machine_ref == ".octon/framework/product/contracts/change-closeout-state-machine.yml"' "$POLICY" >/dev/null
grep -Fq 'RP00_CONTAINMENT_PUBLICATION_DISABLED' "$DOC"
grep -Fq 'RP00_CONTAINMENT_CLEANUP_DISABLED' "$DOC"
echo "[OK] SI-00 Change closeout state machine is aligned"
