#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

DEFAULT_FIXTURE_SPEC="$OCTON_DIR/framework/engine/governance/inputs/additive/governed-incoming-intake-routing-fixtures.yml"
INTAKE_VALIDATOR="$OCTON_DIR/framework/assurance/runtime/_ops/scripts/validate-incoming-intake-unit.sh"

SCHEMA_VERSION="governed-incoming-intake-routing-fixtures-v1"
fixture_spec="$DEFAULT_FIXTURE_SPEC"
require_synthetic_intakes="false"
errors=0

required_routes=(
  "single-work-unit-handoff"
  "coordinated-program-handoff"
  "target-owned-direct-handoff"
  "blocked-rejected-deferred"
)

required_fixtures=(
  "real-rust-source-authority-invalid-envelope"
  "simple-extension-pack-single-unit"
  "simple-core-skill-single-unit"
  "multi-skill-program"
  "governance-plus-runtime-program"
  "ambiguous-packet-vs-program"
  "unsafe-provenance-or-license"
  "secret-or-private-data"
  "malicious-authority-confusion"
  "direct-target-without-contract"
)

required_negative_controls=(
  "autonomous-incoming-scan"
  "raw-intake-as-authority"
  "generated-output-as-authority"
  "host-state-as-authority"
  "chat-history-as-authority"
  "model-memory-as-authority"
  "tool-availability-as-authority"
  "lifecycle-interaction-as-authorization"
  "parent-program-evidence-as-child-receipt"
  "proposal-handoff-authorizes-git"
  "proposal-handoff-authorizes-cleanup"
)

required_forbidden_authorizations=(
  "git-ref-mutation"
  "hosted-provider-authorization"
  "branch-cleanup-authorization"
  "worktree-cleanup-authorization"
  "repo-hygiene-deletion"
  "promotion-authorization"
  "archive-authorization"
  "scope-expansion"
)

required_malicious_denied_claims=(
  "git-ref-mutation"
  "worktree-cleanup-authorization"
  "repo-hygiene-deletion"
  "generated-output-as-authority"
  "direct-install-authority"
)

fail() {
  echo "[ERROR] $1" >&2
  errors=$((errors + 1))
}

usage() {
  cat <<'EOF'
Usage:
  validate-governed-incoming-intake-routing.sh [--fixture-spec <path>] [--require-synthetic-intakes]

Validates static Governed Incoming Intake Routing fixtures and expected route
decisions. This validator does not process intake, create proposals, dispatch
GLO, install skills, normalize packs, archive intake, close Changes, clean
worktrees, or delete repo hygiene residue.

When --require-synthetic-intakes is set, synthetic fixture intake ids must exist
in .octon/inputs/additive/.incoming/<id>/ and pass the existing incoming intake
envelope validator before route expectations are evaluated.
EOF
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --fixture-spec)
        [[ $# -ge 2 ]] || { fail "--fixture-spec requires a value"; return; }
        fixture_spec="$2"
        shift 2
        ;;
      --require-synthetic-intakes)
        require_synthetic_intakes="true"
        shift
        ;;
      --help|-h)
        usage
        exit 0
        ;;
      *)
        fail "unknown argument: $1"
        shift
        ;;
    esac
  done
}

yq_value() {
  local expr="$1"
  local value
  value="$(yq -r "$expr" "$fixture_spec")"
  if [[ "$value" == "null" ]]; then
    value=""
  fi
  printf '%s\n' "$value"
}

yq_count() {
  local expr="$1"
  yq -r "($expr // []) | length" "$fixture_spec"
}

signal_true() {
  local expr="$1"
  [[ "$(yq -r "$expr // false" "$fixture_spec")" == "true" ]]
}

array_contains() {
  local array_expr="$1"
  local expected="$2"
  local count
  count="$(yq -r "[${array_expr}[]? | select(. == \"$expected\")] | length" "$fixture_spec")"
  [[ "$count" == "1" ]]
}

stream_contains() {
  local stream_expr="$1"
  local expected="$2"
  local count
  count="$(yq -r "[${stream_expr} | select(. == \"$expected\")] | length" "$fixture_spec")"
  [[ "$count" == "1" ]]
}

route_is_known_or_none() {
  local route="$1"
  case "$route" in
    none|single-work-unit-handoff|coordinated-program-handoff|target-owned-direct-handoff|blocked-rejected-deferred)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

run_intake_validator() {
  local intake_id="$1"
  local output_var="$2"
  local status_var="$3"
  local validator_output validator_status

  if [[ ! -f "$INTAKE_VALIDATOR" ]]; then
    fail "missing incoming intake validator: $INTAKE_VALIDATOR"
    printf -v "$output_var" '%s' ""
    printf -v "$status_var" '%s' "127"
    return
  fi

  set +e
  validator_output="$(
    OCTON_DIR_OVERRIDE="$OCTON_DIR" OCTON_ROOT_DIR="$ROOT_DIR" \
      bash "$INTAKE_VALIDATOR" --intake-id "$intake_id" 2>&1
  )"
  validator_status=$?
  set -e

  printf -v "$output_var" '%s' "$validator_output"
  printf -v "$status_var" '%s' "$validator_status"
}

derive_route_triplet() {
  local fixture_expr="$1"
  local prevalidation surfaces_count target_contract

  prevalidation="$(yq_value "$fixture_expr.preclassification_validation")"
  if [[ "$prevalidation" == "expected-fail" ]]; then
    printf '%s|%s|%s\n' "none" "block-before-route-classification" "blocked-rejected-deferred"
    return
  fi

  if signal_true "$fixture_expr.classification_signals.malicious_authority_confusion" \
    || signal_true "$fixture_expr.classification_signals.unsafe_provenance_or_license" \
    || signal_true "$fixture_expr.classification_signals.contains_secret_or_private_data" \
    || signal_true "$fixture_expr.classification_signals.ambiguous_packet_vs_program"; then
    printf '%s|%s|%s\n' "blocked-rejected-deferred" "route-selected" "blocked-rejected-deferred"
    return
  fi

  target_contract="$(yq_value "$fixture_expr.classification_signals.target_owned_intake_contract")"
  if signal_true "$fixture_expr.classification_signals.direct_target_requested"; then
    if [[ "$target_contract" == "absent" ]]; then
      printf '%s|%s|%s\n' "target-owned-direct-handoff" "rejected-no-target-owned-contract" "blocked-rejected-deferred"
    else
      printf '%s|%s|%s\n' "target-owned-direct-handoff" "unsupported-target-contract-present" "blocked-rejected-deferred"
    fi
    return
  fi

  surfaces_count="$(yq_count "$fixture_expr.classification_signals.target_surfaces")"
  if signal_true "$fixture_expr.classification_signals.child_sequencing_required" \
    || signal_true "$fixture_expr.classification_signals.migration_or_cutover" \
    || signal_true "$fixture_expr.classification_signals.cross_surface_dependency" \
    || signal_true "$fixture_expr.classification_signals.governance_and_runtime" \
    || [[ "$surfaces_count" -gt 1 ]]; then
    printf '%s|%s|%s\n' "coordinated-program-handoff" "route-selected" "coordinated-program-handoff"
    return
  fi

  if signal_true "$fixture_expr.classification_signals.coherent_work_unit"; then
    printf '%s|%s|%s\n' "single-work-unit-handoff" "route-selected" "single-work-unit-handoff"
    return
  fi

  printf '%s|%s|%s\n' "blocked-rejected-deferred" "route-selected" "blocked-rejected-deferred"
}

check_exact_route_set() {
  local route count enabled dispatch route_id known

  count="$(yq_count ".routes")"
  if [[ "$count" != "4" ]]; then
    fail "route set must contain exactly four routes; found $count"
  fi

  for route in "${required_routes[@]}"; do
    count="$(yq -r "[.routes[]? | select(.route_id == \"$route\")] | length" "$fixture_spec")"
    if [[ "$count" != "1" ]]; then
      fail "route set must contain exactly one $route route; found $count"
    fi
  done

  while IFS= read -r route_id; do
    [[ -z "$route_id" ]] && continue
    known="false"
    for route in "${required_routes[@]}"; do
      if [[ "$route_id" == "$route" ]]; then
        known="true"
        break
      fi
    done
    if [[ "$known" != "true" ]]; then
      fail "unknown route in fixture spec: $route_id"
    fi
  done < <(yq -r '.routes[]?.route_id // ""' "$fixture_spec")

  enabled="$(yq_value '.routes[]? | select(.route_id == "target-owned-direct-handoff") | .enabled')"
  dispatch="$(yq_value '.routes[]? | select(.route_id == "target-owned-direct-handoff") | .dispatch_allowed')"
  if [[ "$enabled" != "false" ]]; then
    fail "target-owned-direct-handoff must remain disabled until a target-owned intake admission contract exists"
  fi
  if [[ "$dispatch" != "false" ]]; then
    fail "target-owned-direct-handoff must not allow dispatch in the current fixture spec"
  fi

  for route in "${required_routes[@]}"; do
    dispatch="$(yq_value ".routes[]? | select(.route_id == \"$route\") | .dispatch_allowed")"
    if [[ "$dispatch" != "false" ]]; then
      fail "$route must not allow dispatch in this non-mutating fixture spec"
    fi
  done
}

check_required_fixture_coverage() {
  local fixture count
  count="$(yq_count ".fixtures")"
  if [[ "$count" -lt "${#required_fixtures[@]}" ]]; then
    fail "fixture matrix must include at least ${#required_fixtures[@]} fixtures; found $count"
  fi

  for fixture in "${required_fixtures[@]}"; do
    if ! stream_contains ".fixtures[]?.fixture_id" "$fixture"; then
      fail "missing required fixture: $fixture"
    fi
  done
}

check_negative_controls() {
  local control
  for control in "${required_negative_controls[@]}"; do
    if ! array_contains ".required_negative_controls" "$control"; then
      fail "missing required negative control: $control"
    fi
  done
}

check_forbidden_handoff_authorizations() {
  local fixture_expr="$1"
  local fixture_id="$2"
  local forbidden global_forbidden

  if [[ "$(yq_value "$fixture_expr.authority_boundary.handoff_context_is_advisory")" != "true" ]]; then
    fail "$fixture_id handoff context must be advisory"
  fi

  for forbidden in "${required_forbidden_authorizations[@]}"; do
    if ! array_contains "$fixture_expr.authority_boundary.forbidden_transfer" "$forbidden"; then
      fail "$fixture_id handoff must forbid authorization transfer: $forbidden"
    fi
    if ! array_contains ".forbidden_handoff_authorizations" "$forbidden"; then
      global_forbidden="missing"
    else
      global_forbidden="present"
    fi
    if [[ "$global_forbidden" != "present" ]]; then
      fail "global forbidden handoff authorization list missing: $forbidden"
    fi
  done
}

check_program_receipt_boundary() {
  local fixture_expr="$1"
  local fixture_id="$2"
  local parent_satisfies_child child_required

  parent_satisfies_child="$(yq_value "$fixture_expr.program_receipt_boundary.parent_program_evidence_satisfies_child_receipts")"
  child_required="$(yq_value "$fixture_expr.program_receipt_boundary.child_packet_receipts_required")"
  if [[ "$parent_satisfies_child" != "false" ]]; then
    fail "$fixture_id must not allow parent program evidence to satisfy child packet receipts"
  fi
  if [[ "$child_required" != "true" ]]; then
    fail "$fixture_id must require child packet receipts"
  fi
}

check_denial_evidence() {
  local fixture_expr="$1"
  local fixture_id="$2"
  local denial_count authority_claim_count claim

  denial_count="$(yq_count "$fixture_expr.denial_evidence")"
  authority_claim_count="$(yq_count "$fixture_expr.denied_authority_claims")"
  if [[ "$denial_count" == "0" && "$authority_claim_count" == "0" ]]; then
    fail "$fixture_id blocked or denied route must retain denial evidence"
  fi

  if signal_true "$fixture_expr.classification_signals.malicious_authority_confusion"; then
    for claim in "${required_malicious_denied_claims[@]}"; do
      if ! array_contains "$fixture_expr.denied_authority_claims" "$claim"; then
        fail "$fixture_id malicious authority-confusion fixture must deny claim: $claim"
      fi
    done
  fi

  if signal_true "$fixture_expr.classification_signals.direct_target_requested"; then
    if ! array_contains "$fixture_expr.denial_evidence" "target-owned-intake-admission-contract-absent"; then
      fail "$fixture_id direct target denial must record missing target-owned intake admission contract"
    fi
    if ! array_contains "$fixture_expr.denial_evidence" "direct-handoff-denied"; then
      fail "$fixture_id direct target denial must record direct handoff denial"
    fi
  fi
}

check_preclassification_validation() {
  local fixture_expr="$1"
  local fixture_id="$2"
  local prevalidation observed synthetic intake_id output status substring

  prevalidation="$(yq_value "$fixture_expr.preclassification_validation")"
  observed="$(yq_value "$fixture_expr.observed_intake_id")"
  synthetic="$(yq_value "$fixture_expr.synthetic_intake_id")"
  intake_id="$observed"
  if [[ -z "$intake_id" ]]; then
    intake_id="$synthetic"
  fi

  if [[ -z "$intake_id" ]]; then
    fail "$fixture_id must declare observed_intake_id or synthetic_intake_id"
    return
  fi

  case "$prevalidation" in
    expected-fail)
      run_intake_validator "$intake_id" output status
      if [[ "$status" == "0" ]]; then
        fail "$fixture_id expected envelope validation to fail before route classification"
      fi
      while IFS= read -r substring; do
        [[ -z "$substring" ]] && continue
        if [[ "$output" != *"$substring"* ]]; then
          fail "$fixture_id expected envelope validation output to contain: $substring"
        fi
      done < <(yq -r "$fixture_expr.expected_validation_error_substrings[]? // \"\"" "$fixture_spec")
      ;;
    expected-pass)
      if [[ "$require_synthetic_intakes" == "true" && -n "$synthetic" ]]; then
        run_intake_validator "$synthetic" output status
        if [[ "$status" != "0" ]]; then
          fail "$fixture_id expected synthetic envelope validation to pass before route classification: $output"
        fi
      fi
      ;;
    *)
      fail "$fixture_id has unknown preclassification_validation: $prevalidation"
      ;;
  esac
}

check_fixture() {
  local index="$1"
  local fixture_expr=".fixtures[$index]"
  local fixture_id fixture_type prevalidation expected_route expected_result expected_terminal
  local mutation_allowed dispatch_allowed derived first_triplet second_triplet derived_route derived_result derived_terminal
  local rejected_count target_contract

  fixture_id="$(yq_value "$fixture_expr.fixture_id")"
  fixture_type="$(yq_value "$fixture_expr.fixture_type")"
  prevalidation="$(yq_value "$fixture_expr.preclassification_validation")"
  expected_route="$(yq -r "$fixture_expr.expected_route // \"none\"" "$fixture_spec")"
  expected_result="$(yq_value "$fixture_expr.expected_result")"
  expected_terminal="$(yq_value "$fixture_expr.expected_terminal_disposition")"
  mutation_allowed="$(yq_value "$fixture_expr.mutation_allowed")"
  dispatch_allowed="$(yq_value "$fixture_expr.target_dispatch_allowed")"
  target_contract="$(yq_value "$fixture_expr.classification_signals.target_owned_intake_contract")"

  if [[ -z "$fixture_id" ]]; then
    fail "fixture at index $index is missing fixture_id"
    return
  fi

  case "$fixture_type" in
    real-observed|synthetic) ;;
    *) fail "$fixture_id has unknown fixture_type: $fixture_type" ;;
  esac

  if ! route_is_known_or_none "$expected_route"; then
    fail "$fixture_id expected unknown route: $expected_route"
  fi

  if [[ "$mutation_allowed" != "false" ]]; then
    fail "$fixture_id must not allow mutation in fixture validation"
  fi
  if [[ "$dispatch_allowed" != "false" ]]; then
    fail "$fixture_id must not allow target dispatch in fixture validation"
  fi
  if [[ "$target_contract" != "absent" ]]; then
    fail "$fixture_id must not claim a target-owned intake admission contract exists in the current fixture spec"
  fi

  check_preclassification_validation "$fixture_expr" "$fixture_id"

  first_triplet="$(derive_route_triplet "$fixture_expr")"
  second_triplet="$(derive_route_triplet "$fixture_expr")"
  if [[ "$first_triplet" != "$second_triplet" ]]; then
    fail "$fixture_id route derivation is not replay-idempotent"
  fi

  derived_route="${first_triplet%%|*}"
  derived="${first_triplet#*|}"
  derived_result="${derived%%|*}"
  derived_terminal="${first_triplet##*|}"

  if [[ "$derived_route" != "$expected_route" ]]; then
    fail "$fixture_id expected route $expected_route but derived $derived_route"
  fi
  if [[ "$derived_result" != "$expected_result" ]]; then
    fail "$fixture_id expected result $expected_result but derived $derived_result"
  fi
  if [[ "$derived_terminal" != "$expected_terminal" ]]; then
    fail "$fixture_id expected terminal disposition $expected_terminal but derived $derived_terminal"
  fi

  rejected_count="$(yq_count "$fixture_expr.rejected_routes")"
  if [[ "$prevalidation" == "expected-fail" ]]; then
    if [[ "$expected_route" != "none" ]]; then
      fail "$fixture_id must not select a route when envelope validation fails"
    fi
    if [[ "$rejected_count" != "0" ]]; then
      fail "$fixture_id must not report rejected routes when classification did not run"
    fi
    return
  fi

  if [[ "$rejected_count" == "0" ]]; then
    fail "$fixture_id must record rejected route candidates after successful envelope validation"
  fi
  if array_contains "$fixture_expr.rejected_routes" "$expected_route"; then
    fail "$fixture_id rejected routes must not include selected route $expected_route"
  fi

  if [[ "$expected_terminal" == "blocked-rejected-deferred" ]]; then
    check_denial_evidence "$fixture_expr" "$fixture_id"
  fi

  case "$expected_route" in
    single-work-unit-handoff|coordinated-program-handoff)
      check_forbidden_handoff_authorizations "$fixture_expr" "$fixture_id"
      ;;
    target-owned-direct-handoff)
      if [[ "$expected_result" != "rejected-no-target-owned-contract" ]]; then
        fail "$fixture_id direct target handoff must be rejected without a target-owned intake admission contract"
      fi
      if [[ "$expected_terminal" != "blocked-rejected-deferred" ]]; then
        fail "$fixture_id direct target handoff denial must end as blocked-rejected-deferred"
      fi
      ;;
  esac

  if [[ "$expected_route" == "coordinated-program-handoff" ]]; then
    check_program_receipt_boundary "$fixture_expr" "$fixture_id"
  fi
}

main() {
  local schema fixture_count i

  parse_args "$@"

  if [[ "$errors" -gt 0 ]]; then
    exit 1
  fi

  if ! command -v yq >/dev/null 2>&1; then
    fail "yq is required for governed incoming intake routing fixture validation"
  fi
  if [[ ! -f "$fixture_spec" ]]; then
    fail "missing fixture spec: $fixture_spec"
  fi
  if [[ "$errors" -gt 0 ]]; then
    exit 1
  fi

  schema="$(yq_value ".schema_version")"
  if [[ "$schema" != "$SCHEMA_VERSION" ]]; then
    fail "expected schema_version $SCHEMA_VERSION, found $schema"
  fi

  check_exact_route_set
  check_required_fixture_coverage
  check_negative_controls

  fixture_count="$(yq_count ".fixtures")"
  for ((i = 0; i < fixture_count; i++)); do
    check_fixture "$i"
  done

  if [[ "$errors" -gt 0 ]]; then
    echo "Governed incoming intake routing fixture validation failed: errors=$errors" >&2
    exit 1
  fi

  echo "Governed incoming intake routing fixture validation passed: fixtures=$fixture_count"
}

main "$@"
