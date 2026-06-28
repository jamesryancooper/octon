#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_DIR="$(cd -- "$SCRIPT_DIR/../../../../" && pwd)"
ROOT_DIR="$(cd -- "$FRAMEWORK_DIR/../.." && pwd)"
SCHEMA_PATH="$FRAMEWORK_DIR/product/contracts/feature-catalog-drift-receipt-v1.schema.json"
CATALOG_PATH="$FRAMEWORK_DIR/product/features/catalog.yml"
CATALOG_VALIDATOR="$SCRIPT_DIR/validate-product-feature-catalog.sh"

RECEIPT_PATH=""
FIXTURE=""
TMP_DIR=""
errors=0

usage() {
  cat <<'USAGE'
usage:
  validate-feature-catalog-drift-closeout.sh [--receipt <path>] [--fixture <name>]

fixtures:
  missing-catalog-entry
  stale-ref
  status-mismatch
  probably-not-product-feature
USAGE
}

pass() { echo "[OK] $1"; }
fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

need_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "[ERROR] $1 is required" >&2
    exit 1
  fi
}

scalar() {
  yq -r "$1" "$RECEIPT_PATH" 2>/dev/null || true
}

require_scalar() {
  local expr="$1" label="$2" value
  value="$(scalar "$expr")"
  if [[ -n "$value" && "$value" != "null" ]]; then
    pass "$label declared"
  else
    fail "$label missing"
  fi
}

require_value() {
  local expr="$1" expected="$2" label="$3" value
  value="$(scalar "$expr")"
  [[ "$value" == "$expected" ]] && pass "$label is $expected" || fail "$label must be $expected"
}

require_bool_true() {
  local expr="$1" label="$2" value
  value="$(scalar "$expr")"
  [[ "$value" == "true" ]] && pass "$label true" || fail "$label must be true"
}

require_array() {
  local expr="$1" label="$2"
  if yq -e "$expr | tag == \"!!seq\"" "$RECEIPT_PATH" >/dev/null 2>&1; then
    pass "$label array declared"
  else
    fail "$label must be an array"
  fi
}

require_nonempty_array() {
  local expr="$1" label="$2" count
  count="$(yq -r "($expr // []) | length" "$RECEIPT_PATH" 2>/dev/null || echo 0)"
  [[ "$count" -gt 0 ]] && pass "$label non-empty" || fail "$label must be non-empty"
}

classification_allowed() {
  case "$1" in
    missing-catalog-entry|missing-feature-note|under-documented|status-mismatch|probably-not-a-product-feature|stale-ref|obsolete-catalog-entry|incorrect-grouping|rename-required|split-required|merge-required|downgrade-required|documented-change|documented-retirement|no-change)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

status_allowed() {
  case "$1" in
    resolved|unresolved|excluded)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

write_fixture() {
  local name="$1" outcome unresolved status classification feature_id feature_name action next_route blocker_block
  TMP_DIR="$(mktemp -d)"
  RECEIPT_PATH="$TMP_DIR/$name.yml"

  outcome="documented-change"
  unresolved=0
  status="resolved"
  classification="documented-change"
  feature_id="run-first-runtime-lifecycle"
  feature_name="Run-First Runtime Lifecycle"
  action="catalog entry and feature note are present and current"
  next_route="continue-closeout"
  blocker_block="[]"

  case "$name" in
    missing-catalog-entry)
      outcome="blocked-unresolved-drift"
      unresolved=1
      status="unresolved"
      classification="missing-catalog-entry"
      feature_id="fixture-missing-runtime-feature"
      feature_name="Fixture Missing Runtime Feature"
      action="add implemented catalog entry with runtime, evidence, validation, and authority refs"
      next_route="revise-product-feature-catalog"
      blocker_block="[{
        \"class\": \"feature-catalog-drift\",
        \"detail\": \"implemented feature lacks a catalog entry\",
        \"evidence_ref\": \".octon/framework/capabilities/runtime/commands/fixture.md\",
        \"status\": \"open\"
      }]"
      ;;
    stale-ref)
      outcome="blocked-unresolved-drift"
      unresolved=1
      status="unresolved"
      classification="stale-ref"
      feature_id="run-first-runtime-lifecycle"
      feature_name="Run-First Runtime Lifecycle"
      action="replace stale catalog reference with existing authored runtime or validation ref"
      next_route="revise-product-feature-catalog"
      blocker_block="[{
        \"class\": \"feature-catalog-drift\",
        \"detail\": \"catalog entry cites a removed or non-existent reference\",
        \"evidence_ref\": \".octon/framework/product/features/catalog.yml\",
        \"status\": \"open\"
      }]"
      ;;
    status-mismatch)
      outcome="blocked-unresolved-drift"
      unresolved=1
      status="unresolved"
      classification="status-mismatch"
      feature_id="extension-packs"
      feature_name="Extension Packs"
      action="align implementation_status with authored implementation evidence"
      next_route="revise-product-feature-catalog"
      blocker_block="[{
        \"class\": \"feature-catalog-drift\",
        \"detail\": \"catalog implementation_status does not match runtime evidence\",
        \"evidence_ref\": \".octon/framework/product/features/catalog.yml\",
        \"status\": \"open\"
      }]"
      ;;
    probably-not-product-feature)
      outcome="no-change"
      unresolved=0
      status="excluded"
      classification="probably-not-a-product-feature"
      feature_id="fixture-one-off-helper"
      feature_name="Fixture One-Off Helper"
      action="exclude from product feature catalog and record rationale"
      next_route="continue-closeout"
      ;;
    *)
      echo "[ERROR] unknown fixture: $name" >&2
      exit 2
      ;;
  esac

  cat >"$RECEIPT_PATH" <<YAML
schema_version: feature-catalog-drift-receipt-v1
receipt_id: fixture-$name
emitted_at: "2026-06-27T00:00:00Z"
target:
  path: .octon/inputs/exploratory/proposals/architecture/fixture
  target_type: fixture
  promotion_targets:
    - .octon/framework/product/features/catalog.yml
catalog_validation:
  validator_ref: .octon/framework/assurance/runtime/_ops/scripts/validate-product-feature-catalog.sh
  catalog_ref: .octon/framework/product/features/catalog.yml
  schema_ref: .octon/framework/product/contracts/product-feature-catalog-v1.schema.json
  verdict: pass
drift_result:
  outcome: $outcome
  unresolved_count: $unresolved
  affected_feature_ids:
    - $feature_id
  required_documentation_actions:
    - "$action"
findings:
  - feature_id: $feature_id
    feature_name: "$feature_name"
    classification: $classification
    status: $status
    evidence_refs:
      - .octon/framework/product/features/catalog.yml
    documentation_action: "$action"
    authority_note: "generated outputs, raw inputs, host UI state, chat/model memory, and tool availability are non-authority"
blockers: $blocker_block
non_authority_boundary:
  raw_inputs_non_authority: true
  generated_outputs_non_authority: true
  host_ui_state_non_authority: true
  chat_model_memory_non_authority: true
  tool_availability_non_authority: true
  evidence_not_authorization: true
  catalog_navigation_only: true
authority_notes:
  - "feature catalog drift receipts are retained evidence only"
  - "unresolved drift blocks closeout claims but does not authorize catalog mutation"
next_route: $next_route
YAML
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --receipt)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      RECEIPT_PATH="$1"
      ;;
    --fixture)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      FIXTURE="$1"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
  shift
done

need_tool jq
need_tool yq

trap '[[ -n "$TMP_DIR" ]] && rm -rf "$TMP_DIR"' EXIT

echo "== Feature Catalog Drift Closeout Validation =="

[[ -f "$SCHEMA_PATH" ]] && pass "feature catalog drift receipt schema exists" || fail "feature catalog drift receipt schema missing"
jq -e '.' "$SCHEMA_PATH" >/dev/null 2>&1 && pass "feature catalog drift receipt schema parses" || fail "feature catalog drift receipt schema does not parse"

for token in \
  '"feature-catalog-drift-receipt-v1"' \
  '"missing-catalog-entry"' \
  '"stale-ref"' \
  '"status-mismatch"' \
  '"probably-not-a-product-feature"' \
  '"blocked-unresolved-drift"' \
  '"catalog_navigation_only"'; do
  grep -Fq "$token" "$SCHEMA_PATH" && pass "schema token present: $token" || fail "schema token missing: $token"
done

[[ -f "$CATALOG_PATH" ]] && pass "product feature catalog exists" || fail "product feature catalog missing"
[[ -f "$CATALOG_VALIDATOR" ]] && pass "product feature catalog validator exists" || fail "product feature catalog validator missing"

if [[ -n "$FIXTURE" ]]; then
  write_fixture "$FIXTURE"
fi

if [[ -n "$RECEIPT_PATH" ]]; then
  if [[ -f "$RECEIPT_PATH" ]]; then
    pass "receipt file exists: $RECEIPT_PATH"
  else
    fail "receipt file missing: $RECEIPT_PATH"
    echo "Validation summary: errors=$errors"
    exit 1
  fi

  yq -e '.' "$RECEIPT_PATH" >/dev/null 2>&1 && pass "receipt YAML parses" || fail "receipt YAML does not parse"

  require_value '.schema_version' 'feature-catalog-drift-receipt-v1' "receipt schema_version"
  require_scalar '.receipt_id' "receipt_id"
  require_scalar '.emitted_at' "emitted_at"
  require_scalar '.target.path' "target.path"
  require_scalar '.target.target_type' "target.target_type"
  case "$(scalar '.target.target_type')" in
    proposal-packet|proposal-program|delivery-receipt|terminal-closeout|fixture)
      pass "target target_type allowed"
      ;;
    *)
      fail "target.target_type must be proposal-packet, proposal-program, delivery-receipt, terminal-closeout, or fixture"
      ;;
  esac
  require_array '.target.promotion_targets' "target promotion targets"
  require_value '.catalog_validation.validator_ref' '.octon/framework/assurance/runtime/_ops/scripts/validate-product-feature-catalog.sh' "catalog validator ref"
  require_value '.catalog_validation.catalog_ref' '.octon/framework/product/features/catalog.yml' "catalog ref"
  require_value '.catalog_validation.schema_ref' '.octon/framework/product/contracts/product-feature-catalog-v1.schema.json' "catalog schema ref"
  case "$(scalar '.catalog_validation.verdict')" in
    pass|fail|blocked|not-run)
      pass "catalog validation verdict allowed"
      ;;
    *)
      fail "catalog validation verdict must be pass, fail, blocked, or not-run"
      ;;
  esac

  outcome="$(scalar '.drift_result.outcome')"
  unresolved_count="$(scalar '.drift_result.unresolved_count')"
  case "$outcome" in
    no-change|documented-change|documented-retirement|blocked-unresolved-drift)
      pass "drift outcome allowed"
      ;;
    *)
      fail "drift outcome invalid"
      ;;
  esac
  [[ "$unresolved_count" =~ ^[0-9]+$ ]] && pass "unresolved count numeric" || fail "unresolved count must be numeric"
  require_array '.drift_result.affected_feature_ids' "affected feature ids"
  require_array '.drift_result.required_documentation_actions' "required documentation actions"
  require_array '.findings' "findings"
  require_array '.blockers' "blockers"
  require_nonempty_array '.authority_notes' "authority notes"
  require_scalar '.next_route' "next route"

  require_bool_true '.non_authority_boundary.raw_inputs_non_authority' "raw inputs non-authority"
  require_bool_true '.non_authority_boundary.generated_outputs_non_authority' "generated outputs non-authority"
  require_bool_true '.non_authority_boundary.host_ui_state_non_authority' "host UI state non-authority"
  require_bool_true '.non_authority_boundary.chat_model_memory_non_authority' "chat/model memory non-authority"
  require_bool_true '.non_authority_boundary.tool_availability_non_authority' "tool availability non-authority"
  require_bool_true '.non_authority_boundary.evidence_not_authorization' "evidence not authorization"
  require_bool_true '.non_authority_boundary.catalog_navigation_only' "catalog navigation-only"

  finding_count="$(yq -r '(.findings // []) | length' "$RECEIPT_PATH" 2>/dev/null || echo 0)"
  unresolved_findings=0
  for ((index=0; index<finding_count; index++)); do
    require_scalar ".findings[$index].feature_id" "finding[$index] feature_id"
    require_scalar ".findings[$index].feature_name" "finding[$index] feature_name"
    require_scalar ".findings[$index].documentation_action" "finding[$index] documentation_action"
    require_scalar ".findings[$index].authority_note" "finding[$index] authority_note"
    require_array ".findings[$index].evidence_refs" "finding[$index] evidence refs"
    classification="$(scalar ".findings[$index].classification")"
    status="$(scalar ".findings[$index].status")"
    classification_allowed "$classification" && pass "finding[$index] classification allowed" || fail "finding[$index] classification invalid: $classification"
    status_allowed "$status" && pass "finding[$index] status allowed" || fail "finding[$index] status invalid: $status"
    [[ "$status" == "unresolved" ]] && unresolved_findings=$((unresolved_findings + 1))
    if [[ "$classification" != "probably-not-a-product-feature" && "$status" != "excluded" ]]; then
      feature_id="$(scalar ".findings[$index].feature_id")"
      if yq -e ".features[]? | select(.feature_id == \"$feature_id\")" "$CATALOG_PATH" >/dev/null 2>&1; then
        pass "finding[$index] feature is represented in catalog or being blocked"
      elif [[ "$status" == "unresolved" && "$classification" == "missing-catalog-entry" ]]; then
        pass "finding[$index] unresolved missing catalog entry recorded"
      else
        fail "finding[$index] feature_id not represented in catalog: $feature_id"
      fi
    fi
  done

  if [[ "$outcome" == "blocked-unresolved-drift" ]]; then
    [[ "$unresolved_count" -gt 0 ]] && pass "blocked outcome has unresolved count" || fail "blocked outcome requires unresolved_count > 0"
    require_nonempty_array '.blockers' "blocked outcome blockers"
    open_blocker_count="$(yq -r '[.blockers[]? | select(.status == "open")] | length' "$RECEIPT_PATH" 2>/dev/null || echo 0)"
    [[ "$open_blocker_count" -gt 0 ]] && pass "blocked outcome has open blocker" || fail "blocked outcome requires an open blocker"
    [[ "$(scalar '.next_route')" != "none" ]] && pass "blocked outcome has next route" || fail "blocked outcome next_route must not be none"
  else
    [[ "$unresolved_count" == "0" ]] && pass "non-blocked outcome has zero unresolved count" || fail "non-blocked outcome requires unresolved_count 0"
    [[ "$unresolved_findings" -eq 0 ]] && pass "non-blocked outcome has no unresolved findings" || fail "non-blocked outcome must not include unresolved findings"
  fi
fi

echo "Validation summary: errors=$errors"
[[ "$errors" -eq 0 ]]
