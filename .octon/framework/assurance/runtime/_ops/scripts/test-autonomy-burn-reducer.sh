#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
SEED_SCRIPT="$OCTON_DIR/framework/orchestration/runtime/_ops/scripts/seed-mission-autonomy-state.sh"
RECEIPT_WRITER="$OCTON_DIR/framework/orchestration/runtime/_ops/scripts/write-mission-control-receipt.sh"
REDUCER_SCRIPT="$OCTON_DIR/framework/orchestration/runtime/_ops/scripts/recompute-mission-autonomy-state.sh"

fixture_root() {
  mktemp -d
}

cleanup_root() {
  local root="$1"
  local tmp_root="${TMPDIR:-/tmp}"
  tmp_root="${tmp_root%/}"
  [[ -n "$root" ]] || return 0
  case "$root" in
    "$tmp_root"/*|/tmp/*) rm -fr -- "$root" ;;
    *) echo "refusing to remove non-temp fixture root: $root" >&2; return 1 ;;
  esac
}

seed_fixture() {
  local root="$1"
  local mission_id="${2:-demo}"
  mkdir -p \
    "$root/.octon/instance/orchestration/missions/$mission_id" \
    "$root/.octon/instance/governance/policies" \
    "$root/.octon/instance/governance/ownership" \
    "$root/.octon/framework/capabilities/governance/policy"

  cp "$OCTON_DIR/octon.yml" "$root/.octon/octon.yml"
  cp "$OCTON_DIR/instance/governance/policies/mission-autonomy.yml" "$root/.octon/instance/governance/policies/mission-autonomy.yml"
  cp "$OCTON_DIR/instance/governance/ownership/registry.yml" "$root/.octon/instance/governance/ownership/registry.yml"
  cp "$OCTON_DIR/framework/capabilities/governance/policy/deny-by-default.v2.yml" "$root/.octon/framework/capabilities/governance/policy/deny-by-default.v2.yml"

  cat > "$root/.octon/instance/orchestration/missions/registry.yml" <<'EOF'
schema_version: "octon-mission-registry-v2"
control_root: ".octon/state/control/execution/missions"
continuity_root: ".octon/state/continuity/repo/missions"
effective_route_root: ".octon/generated/effective/orchestration/missions"
summary_root: ".octon/generated/cognition/summaries/missions"
projection_root: ".octon/generated/cognition/projections/materialized/missions"
active:
  - "$mission_id"
archived: []
EOF

  cat > "$root/.octon/instance/orchestration/missions/$mission_id/mission.yml" <<EOF
schema_version: "octon-mission-v2"
mission_id: "$mission_id"
title: "Mission $mission_id"
summary: "Reducer fixture"
status: "active"
mission_class: "maintenance"
owner_ref: "operator://demo-owner"
created_at: "2026-03-25"
risk_ceiling: "ACP-1"
allowed_action_classes:
  - "git.commit"
default_safing_subset:
  - "observe_only"
  - "stage_only"
default_schedule_hint: "interruptible_scheduled"
default_overlap_policy: "skip"
scope_ids: []
success_criteria:
  - "Reducer recomputes state"
failure_conditions: []
notes_ref: "mission.md"
EOF

  OCTON_DIR_OVERRIDE="$root/.octon" OCTON_ROOT_DIR="$root" bash "$SEED_SCRIPT" --mission-id "$mission_id" --issued-by operator://demo-owner >/dev/null
}

write_breaker_trip() {
  local root="$1"
  local mission_id="$2"
  local trip_id="$3"
  OCTON_DIR_OVERRIDE="$root/.octon" OCTON_ROOT_DIR="$root" bash "$RECEIPT_WRITER" \
    --mission-id "$mission_id" \
    --receipt-type breaker_trip \
    --issued-by operator://demo-owner \
    --reason "Fixture breaker trip $trip_id" \
    --new-state-ref ".octon/state/control/execution/missions/$mission_id/circuit-breakers.yml" \
    --reason-code "FIXTURE_BREAKER_TRIP" \
    --affected-path ".octon/state/control/execution/missions/$mission_id/circuit-breakers.yml" \
    --output-root "$root/.octon/state/evidence/control/execution" \
    >/dev/null
}

main() {
  echo "== Autonomy Burn Reducer Test =="

  local root json
  root="$(fixture_root)"
  trap "cleanup_root '$root'" EXIT

  seed_fixture "$root" demo
  yq -i '.active += ["other"]' "$root/.octon/instance/orchestration/missions/registry.yml"
  seed_fixture "$root" other

  write_breaker_trip "$root" other 1
  json="$(OCTON_DIR_OVERRIDE="$root/.octon" OCTON_ROOT_DIR="$root" bash "$REDUCER_SCRIPT" --mission-id demo --issued-by operator://demo-owner)"
  jq -e '.budget.new_state == "healthy" and .breaker.new_state == "clear"' <<<"$json" >/dev/null

  sleep 1
  write_breaker_trip "$root" demo 1

  json="$(OCTON_DIR_OVERRIDE="$root/.octon" OCTON_ROOT_DIR="$root" bash "$REDUCER_SCRIPT" --mission-id demo --issued-by operator://demo-owner)"
  jq -e '.budget.new_state == "warning" and .breaker.new_state == "tripped"' <<<"$json" >/dev/null

  sleep 1
  write_breaker_trip "$root" demo 2
  json="$(OCTON_DIR_OVERRIDE="$root/.octon" OCTON_ROOT_DIR="$root" bash "$REDUCER_SCRIPT" --mission-id demo --issued-by operator://demo-owner)"
  jq -e '.budget.new_state == "exhausted" and .breaker.new_state == "tripped"' <<<"$json" >/dev/null

  grep -R 'control_mutation_class: "budget_transition"' "$root/.octon/state/evidence/control/execution" >/dev/null
  grep -R 'control_mutation_class: "breaker_trip"' "$root/.octon/state/evidence/control/execution" >/dev/null

  echo "[OK] autonomy burn reducer recomputes budget and breaker state from retained evidence"
}

main "$@"
