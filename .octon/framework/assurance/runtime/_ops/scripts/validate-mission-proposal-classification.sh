#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

SCHEMA_FILE="$OCTON_DIR/framework/engine/runtime/spec/mission-classification-v1.schema.json"
POLICY_FILE="$OCTON_DIR/instance/governance/policies/mission-autonomy.yml"
CONTROL_FILE="$OCTON_DIR/state/control/execution/missions/mission-autonomy-live-validation/mission-classification.yml"
RUN_CONTRACT_SCHEMA="$OCTON_DIR/framework/constitution/contracts/runtime/run-contract-v3.schema.json"
SEED_SCRIPT="$OCTON_DIR/framework/orchestration/runtime/_ops/scripts/seed-mission-autonomy-state.sh"
PUBLISH_SCRIPT="$OCTON_DIR/framework/orchestration/runtime/_ops/scripts/publish-mission-effective-route.sh"
EVALUATE_SCRIPT="$OCTON_DIR/framework/orchestration/runtime/_ops/scripts/evaluate-mission-control-state.sh"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }

cleanup_dir() {
  local path="$1"
  find "$path" -type f -delete
  find "$path" -depth -type d -exec rmdir {} + 2>/dev/null || true
}

proposal_gate() {
  local file="$1"
  local requirement refs_count
  requirement="$(yq -r '.proposal_requirement // "not_required"' "$file")"
  refs_count="$(yq -r '(.proposal_refs // []) | length' "$file")"
  if [[ "$requirement" == "required" && "$refs_count" -eq 0 ]]; then
    return 1
  fi
}

main() {
  echo "== Mission Proposal Classification Validation =="

  for path in "$SCHEMA_FILE" "$POLICY_FILE" "$CONTROL_FILE" "$RUN_CONTRACT_SCHEMA" "$SEED_SCRIPT" "$PUBLISH_SCRIPT" "$EVALUATE_SCRIPT"; do
    [[ -f "$path" || -x "$path" ]] && pass "found ${path#$ROOT_DIR/}" || fail "missing ${path#$ROOT_DIR/}"
  done

  yq -e '.schema_version == "mission-classification-v1" and .proposal_requirement == "not_required"' "$CONTROL_FILE" >/dev/null 2>&1 \
    && pass "active mission classification is materialized" \
    || fail "active mission classification must be materialized"

  yq -e '.proposal_classification_defaults.by_mission_class.maintenance.classification_id == "maintenance-operational-known-pattern"' "$POLICY_FILE" >/dev/null 2>&1 \
    && pass "mission autonomy policy exposes proposal classification defaults" \
    || fail "mission autonomy policy must expose proposal classification defaults"

  jq -e '.properties.mission_classification_ref and .properties.proposal_requirement and .properties.proposal_refs' "$RUN_CONTRACT_SCHEMA" >/dev/null 2>&1 \
    && pass "run-contract-v3 exposes proposal-classification fields" \
    || fail "run-contract-v3 must expose proposal-classification fields"

  if rg -q 'mission-classification\.yml' "$SEED_SCRIPT" "$PUBLISH_SCRIPT" "$EVALUATE_SCRIPT" && \
     rg -q 'MISSION_PROPOSAL_REF_REQUIRED|proposal_refs_required' "$PUBLISH_SCRIPT" "$EVALUATE_SCRIPT"; then
    pass "mission control scripts wire proposal-classification enforcement"
  else
    fail "mission control scripts must wire proposal-classification enforcement"
  fi

  local tmpdir required_file satisfied_file
  tmpdir="$(mktemp -d)"
  required_file="$tmpdir/required.yml"
  satisfied_file="$tmpdir/satisfied.yml"

  cat > "$required_file" <<'EOF'
schema_version: "mission-classification-v1"
mission_id: "fixture"
mission_class: "migration"
classification_id: "migration-structural-change"
ambiguity_level: "high"
novelty_level: "mixed"
proposal_requirement: "required"
proposal_refs: []
acceptance_basis:
  - "fixture"
policy_ref: ".octon/instance/governance/policies/mission-autonomy.yml#proposal_classification_defaults.by_mission_class.migration"
recorded_at: "2026-04-11T00:00:00Z"
EOF

  cat > "$satisfied_file" <<'EOF'
schema_version: "mission-classification-v1"
mission_id: "fixture"
mission_class: "migration"
classification_id: "migration-structural-change"
ambiguity_level: "high"
novelty_level: "mixed"
proposal_requirement: "required"
proposal_refs:
  - ".octon/inputs/exploratory/proposals/.archive/architecture/octon-selected-harness-concepts-integration-packet/README.md"
acceptance_basis:
  - "fixture"
policy_ref: ".octon/instance/governance/policies/mission-autonomy.yml#proposal_classification_defaults.by_mission_class.migration"
recorded_at: "2026-04-11T00:00:00Z"
EOF

  if proposal_gate "$required_file"; then
    fail "required proposal classification without refs must fail closed"
  else
    pass "required proposal classification without refs fails closed"
  fi

  if proposal_gate "$satisfied_file"; then
    pass "required proposal classification with refs passes"
  else
    fail "required proposal classification with refs should pass"
  fi

  cleanup_dir "$tmpdir"

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
