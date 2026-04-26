#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
SCRIPT_DIR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts"
FIXTURE_DIR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/fixtures/support-envelope-reconciliation"
TMP_ROOT="$(mktemp -d)"

cleanup_tmp_root() {
  local dir="$1"
  [[ -d "$dir" ]] || return 0
  find "$dir" -depth -mindepth 1 \( -type f -o -type l \) -exec rm -f {} +
  find "$dir" -depth -type d -empty -exec rmdir {} +
}
trap 'cleanup_tmp_root "$TMP_ROOT"' EXIT

copy_file() {
  local rel="$1"
  local dest="$TMP_FIXTURE/$rel"
  mkdir -p "$(dirname "$dest")"
  cp "$ROOT_DIR/$rel" "$dest"
}

copy_tree() {
  local rel="$1"
  local dest="$TMP_FIXTURE/$rel"
  [[ -d "$ROOT_DIR/$rel" ]] || return 0
  mkdir -p "$(dirname "$dest")"
  cp -R "$ROOT_DIR/$rel" "$dest"
}

build_fixture_root() {
  TMP_FIXTURE="$TMP_ROOT/$1"
  mkdir -p "$TMP_FIXTURE/.octon"

  copy_file ".octon/octon.yml"
  copy_file ".octon/framework/engine/runtime/spec/support-envelope-reconciliation-v1.md"
  copy_file ".octon/framework/engine/runtime/spec/support-envelope-reconciliation-result-v1.schema.json"
  copy_tree ".octon/instance/governance"
  copy_tree ".octon/generated/effective/capabilities"
  copy_tree ".octon/generated/effective/governance"
  copy_tree ".octon/generated/effective/runtime"
  copy_tree ".octon/generated/cognition/projections/materialized/support-cards"
  copy_tree ".octon/state/evidence/validation/support-targets"
  copy_tree ".octon/state/evidence/validation/publication"
  copy_tree ".octon/state/evidence/disclosure/releases/2026-04-18-frontier-governance-bounded-complete"
  copy_tree ".octon/state/control/execution/revocations"

  rm -f "$TMP_FIXTURE/.octon/generated/effective/governance/support-envelope-reconciliation.yml"
}

apply_mutation() {
  local fixture_id="$1"
  local target_live_tuple="tuple://repo-local-governed/observe-and-read/reference-owned/english-primary/repo-shell"
  local target_ci_tuple="tuple://repo-local-governed/observe-and-read/reference-owned/english-primary/ci-control-plane"
  local stage_tuple="tuple://repo-local-governed/boundary-sensitive/reference-owned/english-primary/repo-shell"

  case "$fixture_id" in
    coherent-live)
      ;;
    support-target-live-route-stage-only)
      yq -i "(.routes[] | select(.tuple_id == \"$target_live_tuple\") | .route) = \"stage_only\"" \
        "$TMP_FIXTURE/.octon/generated/effective/runtime/route-bundle.yml"
      ;;
    pack-route-allow-route-stage-only)
      yq -i "(.routes[] | select(.tuple_id == \"$target_live_tuple\") | .route) = \"stage_only\"" \
        "$TMP_FIXTURE/.octon/generated/effective/runtime/route-bundle.yml"
      ;;
    generated-matrix-widens-support)
      yq -i ".supported_tuples += [{\"tuple_id\":\"$stage_tuple\",\"route\":\"allow\",\"requires_mission\":false,\"claim_effect\":\"admitted-live-claim\",\"capability_packs\":[\"repo\",\"git\",\"shell\",\"telemetry\"]}]" \
        "$TMP_FIXTURE/.octon/generated/effective/governance/support-target-matrix.yml"
      ;;
    generated-matrix-omits-live-claim)
      yq -i "del(.supported_tuples[] | select(.tuple_id == \"$target_ci_tuple\"))" \
        "$TMP_FIXTURE/.octon/generated/effective/governance/support-target-matrix.yml"
      ;;
    stale-proof-bundle)
      yq -i '.freshness.status = "stale" | .freshness.review_due_at = "2026-01-01T00:00:00Z"' \
        "$TMP_FIXTURE/.octon/state/evidence/validation/support-targets/repo-shell-observe-read-en.yml"
      ;;
    missing-proof-bundle)
      rm -f "$TMP_FIXTURE/.octon/state/evidence/validation/support-targets/repo-shell-observe-read-en.yml"
      ;;
    support-card-overclaims)
      yq -i '.claim_effect = "admitted-live-claim"' \
        "$TMP_FIXTURE/.octon/generated/cognition/projections/materialized/support-cards/repo-shell-boundary-sensitive-en.yml"
      ;;
    excluded-target-presented-live)
      yq -i "(.tuple_admissions[] | select(.tuple_id == \"$stage_tuple\") | .claim_effect) = \"admitted-live-claim\"" \
        "$TMP_FIXTURE/.octon/instance/governance/support-targets.yml"
      ;;
    *)
      echo "unknown fixture mutation: $fixture_id" >&2
      exit 1
      ;;
  esac
}

run_fixture() {
  local descriptor="$1"
  local fixture_id expected_status result_path validate_log
  fixture_id="$(yq -r '.fixture_id' "$descriptor")"
  expected_status="$(yq -r '.expected_status' "$descriptor")"

  build_fixture_root "$fixture_id"
  apply_mutation "$fixture_id"

  result_path="$TMP_FIXTURE/result.yml"
  OCTON_CURRENT_DATE="2026-04-24" \
    OCTON_DIR_OVERRIDE="$TMP_FIXTURE/.octon" \
    OCTON_ROOT_DIR="$TMP_FIXTURE" \
    bash "$SCRIPT_DIR/generate-support-envelope-reconciliation.sh" "$result_path"

  actual_status="$(yq -r '.status' "$result_path")"
  if [[ "$actual_status" != "$expected_status" ]]; then
    echo "fixture $fixture_id expected status $expected_status but got $actual_status" >&2
    sed -n '1,220p' "$result_path" >&2
    exit 1
  fi

  while IFS= read -r expected_diag; do
    [[ -n "$expected_diag" ]] || continue
    if ! yq -e ".tuples[]?.diagnostics[]? | select(. == \"$expected_diag\")" "$result_path" >/dev/null 2>&1; then
      echo "fixture $fixture_id did not emit expected diagnostic $expected_diag" >&2
      sed -n '1,260p' "$result_path" >&2
      exit 1
    fi
  done < <(yq -r '.expected_diagnostics[]?' "$descriptor")

  validate_log="$TMP_FIXTURE/validate.log"
  if [[ "$expected_status" == "reconciled" ]]; then
    OCTON_CURRENT_DATE="2026-04-24" \
      OCTON_DIR_OVERRIDE="$TMP_FIXTURE/.octon" \
      OCTON_ROOT_DIR="$TMP_FIXTURE" \
      bash "$SCRIPT_DIR/validate-support-envelope-reconciliation.sh" >"$validate_log"
  else
    if OCTON_CURRENT_DATE="2026-04-24" \
      OCTON_DIR_OVERRIDE="$TMP_FIXTURE/.octon" \
      OCTON_ROOT_DIR="$TMP_FIXTURE" \
      bash "$SCRIPT_DIR/validate-support-envelope-reconciliation.sh" >"$validate_log" 2>&1; then
      echo "fixture $fixture_id expected validator failure" >&2
      cat "$validate_log" >&2
      exit 1
    fi
  fi

  echo "[OK] $fixture_id"
}

for descriptor in "$FIXTURE_DIR"/*/fixture.yml; do
  run_fixture "$descriptor"
done
