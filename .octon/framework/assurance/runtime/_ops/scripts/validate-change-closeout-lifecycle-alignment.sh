#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
RECEIPT=""
errors=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --receipt) shift; RECEIPT="${1:-}" ;;
    --skip-schema|--skip-live-remote) ;;
    -h|--help) echo "Usage: validate-change-closeout-lifecycle-alignment.sh [--receipt <json>]"; exit 0 ;;
    *) echo "[ERROR] unknown argument: $1" >&2; exit 2 ;;
  esac
  shift
done

ok() { echo "[OK] $1"; }
fail() { echo "[ERROR] $1" >&2; errors=$((errors + 1)); }
check() { local label="$1"; shift; if "$@"; then ok "$label"; else fail "$label"; fi; }

POLICY="$OCTON_DIR/framework/product/contracts/default-work-unit.yml"
MACHINE="$OCTON_DIR/framework/product/contracts/change-closeout-state-machine.yml"
SKILL="$OCTON_DIR/framework/capabilities/runtime/skills/remediation/closeout-change/SKILL.md"
WORKFLOW="$OCTON_DIR/framework/orchestration/runtime/workflows/meta/closeout/workflow.yml"

check "state machine exposes only active SI-00 routes" yq -e '(.routes | length) == 3 and .routes[0] == "branch-no-pr" and .routes[1] == "branch-pr" and .routes[2] == "stage-only-escalate"' "$MACHINE"
check "state machine defaults to preservation" yq -e '.target_lifecycle_defaults.unspecified_closeout_request == "preserved"' "$MACHINE"
check "state machine denies publication and cleanup" yq -e '.containment.publication_denial_reason == "RP00_CONTAINMENT_PUBLICATION_DISABLED" and .containment.cleanup_denial_reason == "RP00_CONTAINMENT_CLEANUP_DISABLED"' "$MACHINE"
check "closeout skill excludes Git effect tools" bash -c '! grep -Eq "Bash\(git (add|commit|push|checkout|merge)" "$1"' _ "$SKILL"
check "closeout skill carries publication stop" grep -Fq 'RP00_CONTAINMENT_PUBLICATION_DISABLED' "$SKILL"
check "closeout skill carries cleanup stop" grep -Fq 'RP00_CONTAINMENT_CLEANUP_DISABLED' "$SKILL"
check "workflow is read-only" yq -e '.side_effect_class == "read_only" and .constraints.fail_closed == true' "$WORKFLOW"
check "policy default matches lifecycle" yq -e '.closeout_defaults.target_lifecycle_outcome.unspecified_closeout_request == "preserved"' "$POLICY"

if [[ -n "$RECEIPT" ]]; then
  [[ -f "$RECEIPT" ]] || { fail "receipt exists"; RECEIPT=""; }
fi

if [[ -n "$RECEIPT" ]]; then
  check "receipt parses" jq -e . "$RECEIPT"
  check "receipt uses active route" jq -e '.selected_route == "branch-no-pr" or .selected_route == "branch-pr" or .selected_route == "stage-only-escalate"' "$RECEIPT"
  check "receipt does not claim cleaned" jq -e '.lifecycle_outcome != "cleaned" and .target_lifecycle_outcome != "cleaned"' "$RECEIPT"
  check "receipt does not claim completed cleanup" jq -e '(.cleanup_status // "not_applicable") != "completed"' "$RECEIPT"
  check "receipt has no hosted no-PR effect evidence" jq -e '(.hosted_landing // null) == null and (.landing_authorization_ref // null) == null' "$RECEIPT"
  check "receipt retains rollback posture" jq -e '((.rollback_handle // "") | length) > 0' "$RECEIPT"
fi

echo "Validation summary: errors=$errors"
[[ "$errors" -eq 0 ]]
