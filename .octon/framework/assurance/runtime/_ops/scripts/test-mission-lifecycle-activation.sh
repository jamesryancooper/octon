#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
SEED_SCRIPT="$OCTON_DIR/framework/orchestration/runtime/_ops/scripts/seed-mission-autonomy-state.sh"

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
  mkdir -p \
    "$root/.octon/instance/orchestration/missions/demo" \
    "$root/.octon/instance/governance/policies" \
    "$root/.octon/instance/governance/ownership" \
    "$root/.octon/framework/capabilities/governance/policy" \
    "$root/.octon/state/evidence"

  cp "$OCTON_DIR/octon.yml" "$root/.octon/octon.yml"
  cp -R "$OCTON_DIR/framework/cognition" "$root/.octon/framework/"
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
  - "demo"
archived: []
EOF

  cat > "$root/.octon/instance/orchestration/missions/demo/mission.yml" <<'EOF'
schema_version: "octon-mission-v2"
mission_id: "demo"
title: "Demo Mission"
summary: "Lifecycle fixture"
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
  - "Fixture seeds cleanly"
failure_conditions: []
notes_ref: "mission.md"
EOF

  OCTON_DIR_OVERRIDE="$root/.octon" OCTON_ROOT_DIR="$root" bash "$SEED_SCRIPT" --mission-id demo --issued-by operator://demo-owner >/dev/null
}

assert_exists() {
  local path="$1"
  [[ -e "$path" ]]
}

main() {
  echo "== Mission Lifecycle Activation Test =="

  local root
  root="$(fixture_root)"
  trap "cleanup_root '$root'" EXIT

  seed_fixture "$root"

  for path in \
    "$root/.octon/state/control/execution/missions/demo/lease.yml" \
    "$root/.octon/state/control/execution/missions/demo/mode-state.yml" \
    "$root/.octon/state/control/execution/missions/demo/intent-register.yml" \
    "$root/.octon/state/control/execution/missions/demo/action-slices/.gitkeep" \
    "$root/.octon/state/control/execution/missions/demo/directives.yml" \
    "$root/.octon/state/control/execution/missions/demo/authorize-updates.yml" \
    "$root/.octon/state/control/execution/missions/demo/schedule.yml" \
    "$root/.octon/state/control/execution/missions/demo/autonomy-budget.yml" \
    "$root/.octon/state/control/execution/missions/demo/circuit-breakers.yml" \
    "$root/.octon/state/control/execution/missions/demo/subscriptions.yml" \
    "$root/.octon/state/continuity/repo/missions/demo/next-actions.yml" \
    "$root/.octon/state/continuity/repo/missions/demo/handoff.md" \
    "$root/.octon/generated/effective/orchestration/missions/demo/scenario-resolution.yml" \
    "$root/.octon/generated/cognition/summaries/missions/demo/now.md" \
    "$root/.octon/generated/cognition/summaries/missions/demo/next.md" \
    "$root/.octon/generated/cognition/summaries/missions/demo/recent.md" \
    "$root/.octon/generated/cognition/summaries/missions/demo/recover.md" \
    "$root/.octon/generated/cognition/projections/materialized/missions/demo/mission-view.yml"
  do
    assert_exists "$path"
  done

  [[ "$(yq -r '.effective_scenario_resolution_ref // ""' "$root/.octon/state/control/execution/missions/demo/mode-state.yml")" == ".octon/generated/effective/orchestration/missions/demo/scenario-resolution.yml" ]]
  grep -F '/.octon/generated/effective/orchestration/missions/demo/scenario-resolution.yml' "$root/.octon/generated/cognition/summaries/missions/demo/now.md" >/dev/null
  grep -F 'summary_refs:' "$root/.octon/generated/cognition/projections/materialized/missions/demo/mission-view.yml" >/dev/null
  grep -F '/.octon/generated/cognition/summaries/missions/demo/now.md' "$root/.octon/generated/cognition/projections/materialized/missions/demo/mission-view.yml" >/dev/null
  grep -R 'control_mutation_class: "mission_seed"' "$root/.octon/state/evidence/control/execution" >/dev/null

  echo "[OK] lifecycle seed fixture produced the full mission family"
}

main "$@"
