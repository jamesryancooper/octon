#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
TEST_NAME="$(basename "$0")"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-postmortem.sh"
FIXTURE_ROOT="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/fixtures/lifecycle-postmortem"
TMP_DIR=""

pass_count=0
fail_count=0

cleanup() {
  if [[ -n "$TMP_DIR" && -d "$TMP_DIR" ]]; then
    rm -rf "$TMP_DIR"
  fi
}

setup_tmp() {
  TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/lifecycle-postmortem-test.XXXXXX")"
}

pass() {
  echo "PASS: $1"
  pass_count=$((pass_count + 1))
}

fail() {
  echo "FAIL: $1" >&2
  fail_count=$((fail_count + 1))
}

assert_success() {
  local label="$1"
  shift
  if "$@"; then
    pass "$label"
  else
    fail "$label"
  fi
}

assert_failure() {
  local label="$1"
  shift
  if "$@"; then
    fail "$label"
  else
    pass "$label"
  fi
}

positive_passes() {
  bash "$VALIDATOR" \
    --structured-output "$FIXTURE_ROOT/positive/evaluation.yml" \
    --report "$FIXTURE_ROOT/positive/report.md" \
    --review-findings "$FIXTURE_ROOT/positive/review-findings.ndjson" >/dev/null
}

make_evidence_map_fixture() {
  local fixture_root="$1"
  local mode="${2:-direct}"
  local delivery_mode="${3:-without-delivery}"
  mkdir -p \
    "$fixture_root/.octon/state/control/execution/runs/test-run" \
    "$fixture_root/.octon/state/evidence/runs/test-run/assurance/lifecycle-postmortem" \
    "$fixture_root/.octon/state/evidence/runs/test-run/validation" \
    "$fixture_root/.octon/state/evidence/runs/test-run/rollback" \
    "$fixture_root/.octon/state/evidence/runs/skills/closeout-change" \
    "$fixture_root/.octon/state/evidence/runs/workflows/test-run" \
    "$fixture_root/.octon/state/evidence/runs/workflows/child-run" \
    "$fixture_root/.octon/generated/effective/runtime" \
    "$fixture_root/.octon/inputs/exploratory/proposals/architecture/test-proposal"

  printf 'status: completed\nrun_id: test-run\n' >"$fixture_root/.octon/state/control/execution/runs/test-run/runtime-state.yml"
  printf 'index: retained locator\n' >"$fixture_root/.octon/state/evidence/runs/test-run/retained-run-evidence-index.yml"
  printf 'validation: pass\n' >"$fixture_root/.octon/state/evidence/runs/test-run/validation/result.yml"
  printf 'rollback: available\n' >"$fixture_root/.octon/state/evidence/runs/test-run/rollback/rollback.md"
  printf 'workflow: substitute\n' >"$fixture_root/.octon/state/evidence/runs/workflows/test-run/program-events.ndjson"
  printf 'child validation: pass\n' >"$fixture_root/.octon/state/evidence/runs/workflows/child-run/validation.yml"
  printf 'generated: read model\n' >"$fixture_root/.octon/generated/effective/runtime/read-model.yml"
  printf 'proposal: context only\n' >"$fixture_root/.octon/inputs/exploratory/proposals/architecture/test-proposal/proposal.yml"
  if [[ "$delivery_mode" == "with-delivery" ]]; then
    printf 'run_id: test-run\ndelivery: branch-no-pr\nlanded: true\nsynced: true\ncleaned: true\n' >"$fixture_root/.octon/state/evidence/runs/skills/closeout-change/test-run-delivery.yml"
  fi

  python3 - "$fixture_root" "$mode" "$delivery_mode" <<'PY'
import hashlib
import json
import pathlib
import sys

root = pathlib.Path(sys.argv[1]).resolve()
mode = sys.argv[2]
delivery_mode = sys.argv[3]

def rel(path):
    return str(path.resolve().relative_to(root))

def sha(path):
    return "sha256:" + hashlib.sha256(path.read_bytes()).hexdigest()

def record(path, role, ref_class, authority_use, **extra):
    result = {
        "ref": rel(path),
        "role": role,
        "ref_class": ref_class,
        "sha256": sha(path),
        "authority_use": authority_use,
    }
    result.update(extra)
    return result

def named(path, ref_name, ref_class, authority_role):
    return {
        "ref_name": ref_name,
        "path": rel(path),
        "ref_class": ref_class,
        "authority_role": authority_role,
        "exists": True,
    }

control = root / ".octon/state/control/execution/runs/test-run/runtime-state.yml"
index = root / ".octon/state/evidence/runs/test-run/retained-run-evidence-index.yml"
validation = root / ".octon/state/evidence/runs/test-run/validation/result.yml"
rollback = root / ".octon/state/evidence/runs/test-run/rollback/rollback.md"
substitute = root / ".octon/state/evidence/runs/workflows/test-run/program-events.ndjson"
child_validation = root / ".octon/state/evidence/runs/workflows/child-run/validation.yml"
generated = root / ".octon/generated/effective/runtime/read-model.yml"
proposal = root / ".octon/inputs/exploratory/proposals/architecture/test-proposal/proposal.yml"
delivery = root / ".octon/state/evidence/runs/skills/closeout-change/test-run-delivery.yml"
postmortem_dir = root / ".octon/state/evidence/runs/test-run/assurance/lifecycle-postmortem"
postmortem_evaluation = postmortem_dir / "evaluation.yml"
postmortem_report = postmortem_dir / "report.md"
postmortem_readiness = postmortem_dir / "readiness-summary.md"
postmortem_evidence_map = postmortem_dir / "evidence-map.yml"

direct_refs = [record(control, "runtime-state", "control", "control-truth")] if mode == "direct" else []
substitute_refs = [] if mode == "direct" else [record(
    substitute,
    "program-events-substitute",
    "retained-workflow-evidence",
    "evidence-only",
    substitutes_for=rel(control),
    exists=True,
)]
delivery_refs = [named(delivery, "associated-delivery-receipt-1", "associated-closeout-receipt", "retained-evidence-associated")] if delivery.exists() else []
delivery_status = "evidence_present" if delivery_refs else "not_applicable_no_delivery_evidence"
proof_status = "evidence_present" if delivery_refs else "not_applicable"
proof_evidence = [rel(delivery)] if delivery_refs else ["unavailable:no-retained-profile-evidence-ref"]
parent_status_refs = [
    named(validation, "program-summary", "retained-terminal-state", "retained-evidence"),
    named(substitute, "program-events", "control-event-log", "mutable-control-truth"),
]
planner_refs = [named(substitute, "program-events", "control-event-log", "mutable-control-truth")]
validator_refs = [named(validation, "validation-result", "retained-terminal-state", "retained-evidence")]
child_refs = [
    record(
        child_validation,
        "child-validation-ref-index",
        "retained-child-evidence-dereference",
        "evidence-only-non-substitutive",
    )
]

def profile_records(prefix, scopes, evidence_refs):
    return [
        {
            "record_id": f"{prefix}-{idx}",
            "owning_scope": scope,
            "summary": f"{scope} evidence-only profile fixture record",
            "evidence_refs": evidence_refs,
            "authority_status": "evidence-only",
        }
        for idx, scope in enumerate(scopes, start=1)
    ]

def recommendations(prefix, evidence_refs):
    return [
        {
            "recommendation_id": f"{prefix}-1",
            "problem": "fixture problem",
            "proposed_change": "fixture proposed governed follow-up",
            "owning_scope": "lifecycle-tooling-or-contract",
            "expected_autonomy_or_efficiency_gain": "fixture gain",
            "safety_rationale": "fixture remains evidence-only",
            "risks": "fixture risk",
            "acceptance_criteria": "fixture acceptance criteria",
            "suggested_validators": ["validate-lifecycle-postmortem.sh"],
            "required_governed_route": "future-governed-route",
            "evidence_refs": evidence_refs,
            "authority_status": "proposed-evidence-only",
        }
    ]

profile = {
    "schema_version": "lifecycle-postmortem-proposal-program-delivery-profile-v1",
    "profile_id": "proposal-program-delivery-evaluation",
    "applies_to_lifecycle_kind": "proposal-program",
    "evidence_binding": {
        "parent_status_refs": parent_status_refs,
        "child_terminal_status_refs": child_refs,
        "retained_run_evidence_index_refs": [record(index, "retained-run-evidence-index", "retained-evidence", "evidence-only")],
        "planner_refs": planner_refs,
        "closeout_archive_refs": [],
        "delivery_refs": delivery_refs,
        "validator_generated_hygiene_refs": validator_refs,
        "git_delivery_proof_refs": delivery_refs,
        "delivery_evidence_status": delivery_status,
    },
    "postmortem_requirement": {
        "required": True,
        "verdict": "pass",
        "validator_ref": ".octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-postmortem.sh",
        "evaluation_ref": named(postmortem_evaluation, "postmortem-evaluation", "retained-postmortem-output", "retained-evidence"),
        "report_ref": named(postmortem_report, "postmortem-report", "retained-postmortem-output", "retained-evidence"),
        "readiness_summary_ref": named(postmortem_readiness, "postmortem-readiness-summary", "retained-postmortem-summary", "retained-evidence"),
        "evidence_map_ref": named(postmortem_evidence_map, "postmortem-evidence-map", "retained-postmortem-map", "retained-evidence"),
        "digest_bound_evidence_refs": [record(validation, "postmortem-validation-result", "retained-evidence", "evidence-only")],
    },
    "blocker_taxonomy": profile_records(
        "blocker",
        [
            "parent-program",
            "child-packet",
            "generated-artifact",
            "lifecycle-tooling-or-contract",
            "worktree-hygiene-or-residue",
            "git-delivery-state",
            "external-permission-boundary",
        ],
        [rel(validation)],
    ),
    "autonomy_analysis": profile_records("autonomy", ["deterministic-governed-recovery"], [rel(validation)]),
    "efficiency_diagnostics": profile_records("efficiency", ["registry-and-freshness-churn"], [rel(validation)]),
    "delivery_proof_chain_audit": [
        {
            "proof_id": proof_id,
            "proof_scope": proof_id,
            "status": proof_status,
            "evidence_refs": proof_evidence,
            "not_applicable_reason": "" if delivery_refs else "No retained delivery evidence in fixture.",
            "authority_status": "evidence-only",
        }
        for proof_id in [
            "archive",
            "push",
            "branch-no-pr-landing",
            "sync",
            "cleanup-authorization",
            "branch-cleanup",
            "cleaned-claim",
        ]
    ],
    "recommendation_backlog": recommendations("backlog", [rel(validation)]),
    "regression_test_plan": profile_records("regression", ["with-delivery-evidence", "without-delivery-evidence", "non-authority-negative"], [rel(validation)]),
    "proposed_next_governed_routes": recommendations("route", [rel(validation)]),
    "authority_boundary": {
        "profile_output_authority": False,
        "authorizes_lifecycle_transition": False,
        "authorizes_child_receipt_replacement": False,
        "authorizes_closeout": False,
        "authorizes_archive": False,
        "authorizes_delivery": False,
        "authorizes_git_mutation": False,
        "authorizes_cleanup": False,
        "generated_outputs_authority": False,
        "statement": "Fixture proposal-program delivery profile is evidence-only.",
    },
}

evidence_map = {
    "schema_version": "lifecycle-postmortem-evidence-map-v2",
    "subject": {"run_id": "test-run", "lifecycle_kind": "proposal-program"},
    "evidence_posture": {
        "purpose": "discovery-and-replay-aid",
        "direct_control_refs_present": mode == "direct",
    },
    "retained_run_evidence_indexes": [record(index, "retained-run-evidence-index", "retained-evidence", "evidence-only")],
    "direct_control_refs": direct_refs,
    "substitute_refs": substitute_refs,
    "terminal_state_refs": {
        "validation": [record(validation, "validation-result", "retained-evidence", "evidence-only")],
        "rollback": [record(rollback, "rollback-posture", "retained-evidence", "evidence-only")],
    },
    "child_evidence_ref_index": child_refs,
    "generated_refs": [record(generated, "generated-read-model", "generated", "derived-only")],
    "proposal_local_refs": [record(proposal, "proposal-context", "proposal-local", "non-authoritative")],
    "proposal_program_delivery_profile": profile,
    "authority_boundary": {
        "generated_outputs_authority": False,
        "proposal_inputs_authority": False,
        "postmortem_authorizes_lifecycle_transition": False,
        "postmortem_authorizes_closeout": False,
        "locator_replaces_source_evidence": False,
    },
}
known_limits = {
    "schema_version": "lifecycle-postmortem-known-limits-v2",
    "missing_direct_refs_recorded": True,
    "substitute_refs_validated": True,
    "diagnostic_refs_do_not_override_terminal": True,
    "authority_boundary": {"locator_replaces_source_evidence": False},
}

out_dir = root / ".octon/state/evidence/runs/test-run/assurance/lifecycle-postmortem"
(out_dir / "evidence-map.yml").write_text(json.dumps(evidence_map, indent=2) + "\n")
(out_dir / "known-limits.yml").write_text(json.dumps(known_limits, indent=2) + "\n")
PY

  local postmortem_dir="$fixture_root/.octon/state/evidence/runs/test-run/assurance/lifecycle-postmortem"
  local evidence_map="$postmortem_dir/evidence-map.yml"
  local known_limits="$postmortem_dir/known-limits.yml"
  printf 'verdict: pass\n' >"$postmortem_dir/evaluation.yml"
  printf '# Lifecycle Postmortem Report\n\nValidated fixture report.\n' >"$postmortem_dir/report.md"
  {
    printf '# Lifecycle Postmortem Readiness Summary\n\n'
    printf 'This summary is a derived evidence-navigation aid only. It is generated from evidence-map.yml and known-limits.yml and does not replace either retained evidence artifact.\n\n'
    printf '## Evidence Posture\n\n'
    printf -- '- Direct control refs present: %s\n' "$(yq -r '.evidence_posture.direct_control_refs_present // "false"' "$evidence_map")"
    printf -- '- Substitute refs count: %s\n' "$(yq -r '.substitute_refs | length // 0' "$evidence_map")"
    printf -- '- Terminal validation refs count: %s\n' "$(yq -r '.terminal_state_refs.validation | length // 0' "$evidence_map")"
    printf -- '- Terminal rollback refs count: %s\n' "$(yq -r '.terminal_state_refs.rollback | length // 0' "$evidence_map")"
    printf -- '- Missing direct refs recorded: %s\n' "$(yq -r '.missing_direct_refs_recorded // "false"' "$known_limits")"
    printf -- '- Substitute refs validated: %s\n' "$(yq -r '.substitute_refs_validated // "false"' "$known_limits")"
    printf -- '- Diagnostic refs do not override terminal refs: %s\n\n' "$(yq -r '.diagnostic_refs_do_not_override_terminal // "false"' "$known_limits")"
    printf '## Authority Boundary\n\n'
    printf 'Generated outputs, proposal-local inputs, raw inputs, postmortem reports, and readiness summaries are not runtime, policy, support, closeout, publication, redesign, or lifecycle-transition authority.\n'
  } >"$postmortem_dir/readiness-summary.md"
}

mutate_json_file() {
  local path="$1"
  local expression="$2"
  python3 - "$path" "$expression" <<'PY'
import json
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
expression = sys.argv[2].replace("\\n", "\n")
data = json.loads(path.read_text())
exec(expression, {"data": data})
path.write_text(json.dumps(data, indent=2) + "\n")
PY
}

mutate_profile_authorizes_delivery() {
  mutate_json_file \
    "$1/.octon/state/evidence/runs/test-run/assurance/lifecycle-postmortem/evidence-map.yml" \
    "data['proposal_program_delivery_profile']['authority_boundary']['authorizes_delivery'] = True"
}

mutate_profile_replaces_child_receipts() {
  mutate_json_file \
    "$1/.octon/state/evidence/runs/test-run/assurance/lifecycle-postmortem/evidence-map.yml" \
    "data['proposal_program_delivery_profile']['authority_boundary']['authorizes_child_receipt_replacement'] = True"
}

mutate_profile_generated_authority() {
  mutate_json_file \
    "$1/.octon/state/evidence/runs/test-run/assurance/lifecycle-postmortem/evidence-map.yml" \
    "data['proposal_program_delivery_profile']['authority_boundary']['generated_outputs_authority'] = True"
}

mutate_profile_missing_postmortem_report() {
  rm "$1/.octon/state/evidence/runs/test-run/assurance/lifecycle-postmortem/report.md"
}

mutate_profile_postmortem_digest_mismatch() {
  mutate_json_file \
    "$1/.octon/state/evidence/runs/test-run/assurance/lifecycle-postmortem/evidence-map.yml" \
    "data['proposal_program_delivery_profile']['postmortem_requirement']['digest_bound_evidence_refs'][0]['sha256'] = 'sha256:1111111111111111111111111111111111111111111111111111111111111111'"
}

validate_evidence_map_fixture() {
  local root="$1"
  OCTON_ROOT_DIR="$root" bash "$VALIDATOR" \
    --evidence-map "$root/.octon/state/evidence/runs/test-run/assurance/lifecycle-postmortem/evidence-map.yml" \
    --known-limits "$root/.octon/state/evidence/runs/test-run/assurance/lifecycle-postmortem/known-limits.yml" \
    --readiness-summary "$root/.octon/state/evidence/runs/test-run/assurance/lifecycle-postmortem/readiness-summary.md" >/dev/null
}

make_structured_case() {
  local case_id="$1"
  local output="$TMP_DIR/$case_id-evaluation.yml"
  cp "$FIXTURE_ROOT/positive/evaluation.yml" "$output"
  printf '%s\n' "$output"
}

make_report_case() {
  local case_id="$1"
  local output="$TMP_DIR/$case_id-report.md"
  cp "$FIXTURE_ROOT/positive/report.md" "$output"
  printf '%s\n' "$output"
}

derived_structured_fails() {
  local case_id="$1"
  local mutator="$2"
  local candidate
  candidate="$(make_structured_case "$case_id")"
  "$mutator" "$candidate"
  ! bash "$VALIDATOR" \
    --structured-output "$candidate" >/dev/null 2>&1
}

derived_report_fails() {
  local case_id="$1"
  local mutator="$2"
  local candidate
  candidate="$(make_report_case "$case_id")"
  "$mutator" "$candidate"
  ! bash "$VALIDATOR" \
    --structured-output "$FIXTURE_ROOT/positive/evaluation.yml" \
    --report "$candidate" >/dev/null 2>&1
}

mutate_generated_authority() {
  yq -i '.evidence_refs[0] = ".octon/generated/forbidden.yml" | .authority_boundary.generated_outputs_authority = true' "$1"
}

mutate_raw_input_authority() {
  yq -i '.evidence_refs[0] = ".octon/inputs/exploratory/forbidden.yml" | .authority_boundary.raw_inputs_authority = true' "$1"
}

mutate_unresolved_ref() {
  yq -i '.evidence_refs[0] = ".octon/state/evidence/missing-lifecycle-postmortem-fixture.yml"' "$1"
}

mutate_invalid_final_judgment() {
  yq -i '.final_judgment = "Approved"' "$1"
}

mutate_invalid_updated_recommendation() {
  yq -i '.updated_lifecycle_recommendation.recommendation = "Preserve"' "$1"
}

mutate_missing_structured_section() {
  yq -i 'del(.clean_sheet_lifecycle_reference_design)' "$1"
}

mutate_missing_input_context() {
  yq -i 'del(.input_context.known_concerns)' "$1"
}

mutate_missing_posture() {
  yq -i '.evaluation_posture.first_principles_traps_avoided = false' "$1"
}

mutate_missing_patch_redesign_report() {
  perl -0pi -e 's/^## 9\. Patch-vs-Redesign Decision Gate\n\n//m' "$1"
}

mutate_insufficient_alternative_paths() {
  yq -i '.alternative_improvement_paths = .alternative_improvement_paths[0:3]' "$1"
}

mutate_missing_quality_attribute() {
  yq -i '.lifecycle_quality_attribute_scoring = (.lifecycle_quality_attribute_scoring | map(select(.attribute != "Support-proof readiness")))' "$1"
}

mutate_missing_octon_invariant() {
  yq -i '.octon_invariant_review.invariant_compliance = (.octon_invariant_review.invariant_compliance | map(select(.invariant != "support-proof requirements")))' "$1"
}

mutate_unknown_as_pass() {
  yq -i '.octon_invariant_review.invariant_compliance[0].rating = "Unknown" | .octon_invariant_review.invariant_compliance[0].evidence_gap = "missing fixture evidence" | .octon_invariant_review.invariant_compliance[0].counts_as_pass = true' "$1"
}

mutate_missing_invariant_gap() {
  yq -i '.octon_invariant_review.invariant_compliance[0].rating = "Unknown" | .octon_invariant_review.invariant_compliance[0].evidence_gap = "" | .octon_invariant_review.invariant_compliance[0].counts_as_pass = false' "$1"
}

mutate_missing_blocking_correction() {
  yq -i '.octon_invariant_review.invariant_compliance[0].rating = "Fail" | .octon_invariant_review.invariant_compliance[0].material = true | .octon_invariant_review.invariant_compliance[0].blocking = false | .octon_invariant_review.invariant_compliance[0].required_correction = "" | .octon_invariant_review.invariant_compliance[0].counts_as_pass = false' "$1"
}

mutate_missing_invariant_validity_evolution() {
  yq -i '.octon_invariant_review.invariant_validity_evolution = []' "$1"
}

mutate_missing_redesign_trigger() {
  yq -i '.redesign_triggers = (.redesign_triggers | map(select(.redesign_trigger != "The process hides rather than exposes risk.")))' "$1"
}

mutate_invalid_invariant_recommendation_category() {
  yq -i '.octon_invariant_review.invariant_validity_evolution[0].recommendation = "Preserve"' "$1"
}

mutate_missing_invariant_required_change() {
  yq -i '.octon_invariant_review.invariant_validity_evolution[0].recommendation = "Clarify" | .octon_invariant_review.invariant_validity_evolution[0].required_change = ""' "$1"
}

mutate_weak_change_control_bar() {
  yq -i '.octon_invariant_review.invariant_validity_evolution[0].recommendation = "Relax" | .octon_invariant_review.invariant_validity_evolution[0].required_change = "narrow invariant scope" | .octon_invariant_review.invariant_validity_evolution[0].change_control_bar = "medium"' "$1"
}

mutate_invariant_change_approved() {
  yq -i '.authority_boundary.postmortem_approves_invariant_change = true' "$1"
}

mutate_recommendation_claims_authority() {
  yq -i '.authority_boundary.postmortem_approves_redesign = true | .follow_up_recommendations[0].authority_status = "approved"' "$1"
}

mutate_missing_closeout_owner() {
  yq -i '.postmortem_closeout.actions[0].owner_role = ""' "$1"
}

mutate_fit_judgment_with_material_invariant_failure() {
  yq -i '.octon_invariant_review.invariant_compliance[0].rating = "Fail" | .octon_invariant_review.invariant_compliance[0].material = true | .octon_invariant_review.invariant_compliance[0].blocking = true | .octon_invariant_review.invariant_compliance[0].required_correction = "correct invariant conflict" | .octon_invariant_review.invariant_compliance[0].counts_as_pass = false' "$1"
}

mutate_major_finding_without_connection_basis() {
  yq -i 'del(.major_findings[0].connection_basis)' "$1"
}

mutate_summary_final_judgment_mismatch() {
  yq -i '.executive_postmortem_summary.fitness_to_reuse = "Fit for limited/pilot use only"' "$1"
}

main() {
  setup_tmp
  trap cleanup EXIT

  assert_success "positive lifecycle postmortem fixture passes" positive_passes

  local direct_map_root="$TMP_DIR/direct-map"
  make_evidence_map_fixture "$direct_map_root" direct
  assert_success "direct-control lifecycle postmortem evidence map passes" validate_evidence_map_fixture "$direct_map_root"

  local substitute_map_root="$TMP_DIR/substitute-map"
  make_evidence_map_fixture "$substitute_map_root" substitute
  assert_success "substitute-only lifecycle postmortem evidence map passes" validate_evidence_map_fixture "$substitute_map_root"

  local delivery_profile_root="$TMP_DIR/delivery-profile-map"
  make_evidence_map_fixture "$delivery_profile_root" direct with-delivery
  assert_success "proposal-program delivery postmortem profile with delivery evidence passes" validate_evidence_map_fixture "$delivery_profile_root"

  local no_delivery_profile_root="$TMP_DIR/no-delivery-profile-map"
  make_evidence_map_fixture "$no_delivery_profile_root" direct without-delivery
  assert_success "proposal-program delivery postmortem profile without delivery evidence passes" validate_evidence_map_fixture "$no_delivery_profile_root"

  local profile_delivery_authority_root="$TMP_DIR/profile-delivery-authority-map"
  make_evidence_map_fixture "$profile_delivery_authority_root" direct with-delivery
  mutate_profile_authorizes_delivery "$profile_delivery_authority_root"
  assert_failure "proposal-program postmortem profile authorizing delivery fails" validate_evidence_map_fixture "$profile_delivery_authority_root"

  local profile_child_receipt_authority_root="$TMP_DIR/profile-child-receipt-authority-map"
  make_evidence_map_fixture "$profile_child_receipt_authority_root" direct with-delivery
  mutate_profile_replaces_child_receipts "$profile_child_receipt_authority_root"
  assert_failure "proposal-program postmortem profile replacing child receipts fails" validate_evidence_map_fixture "$profile_child_receipt_authority_root"

  local profile_generated_authority_root="$TMP_DIR/profile-generated-authority-map"
  make_evidence_map_fixture "$profile_generated_authority_root" direct with-delivery
  mutate_profile_generated_authority "$profile_generated_authority_root"
  assert_failure "proposal-program postmortem profile generated authority fails" validate_evidence_map_fixture "$profile_generated_authority_root"

  local profile_missing_postmortem_root="$TMP_DIR/profile-missing-postmortem-map"
  make_evidence_map_fixture "$profile_missing_postmortem_root" direct with-delivery
  mutate_profile_missing_postmortem_report "$profile_missing_postmortem_root"
  assert_failure "proposal-program postmortem profile missing report fails" validate_evidence_map_fixture "$profile_missing_postmortem_root"

  local profile_postmortem_digest_root="$TMP_DIR/profile-postmortem-digest-map"
  make_evidence_map_fixture "$profile_postmortem_digest_root" direct with-delivery
  mutate_profile_postmortem_digest_mismatch "$profile_postmortem_digest_root"
  assert_failure "proposal-program postmortem profile digest-bound ref mismatch fails" validate_evidence_map_fixture "$profile_postmortem_digest_root"

  local stale_map_root="$TMP_DIR/stale-map"
  make_evidence_map_fixture "$stale_map_root" direct
  printf 'tampered\n' >>"$stale_map_root/.octon/state/evidence/runs/test-run/validation/result.yml"
  assert_failure "stale lifecycle postmortem evidence-map digest fails" validate_evidence_map_fixture "$stale_map_root"

  local unresolved_map_root="$TMP_DIR/unresolved-map"
  make_evidence_map_fixture "$unresolved_map_root" substitute
  rm "$unresolved_map_root/.octon/state/evidence/runs/workflows/test-run/program-events.ndjson"
  assert_failure "unresolved lifecycle postmortem substitute refs fail" validate_evidence_map_fixture "$unresolved_map_root"

  local missing_substitutes_for_root="$TMP_DIR/missing-substitutes-for-map"
  make_evidence_map_fixture "$missing_substitutes_for_root" substitute
  mutate_json_file "$missing_substitutes_for_root/.octon/state/evidence/runs/test-run/assurance/lifecycle-postmortem/evidence-map.yml" "del data['substitute_refs'][0]['substitutes_for']"
  assert_failure "missing lifecycle postmortem substitutes_for fails" validate_evidence_map_fixture "$missing_substitutes_for_root"

  local false_substitute_exists_root="$TMP_DIR/false-substitute-exists-map"
  make_evidence_map_fixture "$false_substitute_exists_root" substitute
  mutate_json_file "$false_substitute_exists_root/.octon/state/evidence/runs/test-run/assurance/lifecycle-postmortem/evidence-map.yml" "data['substitute_refs'][0]['exists'] = False"
  assert_failure "nonexistent lifecycle postmortem substitute refs fail" validate_evidence_map_fixture "$false_substitute_exists_root"

  local substitute_authority_map_root="$TMP_DIR/substitute-authority-map"
  make_evidence_map_fixture "$substitute_authority_map_root" substitute
  mutate_json_file "$substitute_authority_map_root/.octon/state/evidence/runs/test-run/assurance/lifecycle-postmortem/evidence-map.yml" "data['substitute_refs'][0]['authority_use'] = 'control-truth'"
  assert_failure "substitute lifecycle postmortem refs claiming authority fail" validate_evidence_map_fixture "$substitute_authority_map_root"

  local missing_validation_map_root="$TMP_DIR/missing-validation-map"
  make_evidence_map_fixture "$missing_validation_map_root" direct
  mutate_json_file "$missing_validation_map_root/.octon/state/evidence/runs/test-run/assurance/lifecycle-postmortem/evidence-map.yml" "data['terminal_state_refs']['validation'] = []"
  assert_failure "missing lifecycle postmortem validation terminal evidence fails" validate_evidence_map_fixture "$missing_validation_map_root"

  local missing_rollback_map_root="$TMP_DIR/missing-rollback-map"
  make_evidence_map_fixture "$missing_rollback_map_root" direct
  mutate_json_file "$missing_rollback_map_root/.octon/state/evidence/runs/test-run/assurance/lifecycle-postmortem/evidence-map.yml" "data['terminal_state_refs']['rollback'] = []"
  assert_failure "missing lifecycle postmortem rollback terminal evidence fails" validate_evidence_map_fixture "$missing_rollback_map_root"

  local missing_child_refs_map_root="$TMP_DIR/missing-child-refs-map"
  make_evidence_map_fixture "$missing_child_refs_map_root" direct
  mutate_json_file "$missing_child_refs_map_root/.octon/state/evidence/runs/test-run/assurance/lifecycle-postmortem/evidence-map.yml" "data['child_evidence_ref_index'] = []"
  assert_failure "missing lifecycle postmortem child evidence dereference refs fail" validate_evidence_map_fixture "$missing_child_refs_map_root"

  local child_authority_map_root="$TMP_DIR/child-authority-map"
  make_evidence_map_fixture "$child_authority_map_root" direct
  mutate_json_file "$child_authority_map_root/.octon/state/evidence/runs/test-run/assurance/lifecycle-postmortem/evidence-map.yml" "data['child_evidence_ref_index'][0]['authority_use'] = 'evidence-only'"
  assert_failure "substitutive lifecycle postmortem child evidence dereference refs fail" validate_evidence_map_fixture "$child_authority_map_root"

  local generated_authority_map_root="$TMP_DIR/generated-authority-map"
  make_evidence_map_fixture "$generated_authority_map_root" direct
  mutate_json_file "$generated_authority_map_root/.octon/state/evidence/runs/test-run/assurance/lifecycle-postmortem/evidence-map.yml" "data['generated_refs'][0]['authority_use'] = 'control-truth'"
  assert_failure "generated lifecycle postmortem refs claiming authority fail" validate_evidence_map_fixture "$generated_authority_map_root"

  local proposal_authority_map_root="$TMP_DIR/proposal-authority-map"
  make_evidence_map_fixture "$proposal_authority_map_root" direct
  mutate_json_file "$proposal_authority_map_root/.octon/state/evidence/runs/test-run/assurance/lifecycle-postmortem/evidence-map.yml" "data['proposal_local_refs'][0]['authority_use'] = 'evidence-only'"
  assert_failure "proposal-local lifecycle postmortem refs claiming authority fail" validate_evidence_map_fixture "$proposal_authority_map_root"

  assert_success "generated authority fixture fails" derived_structured_fails generated-authority mutate_generated_authority
  assert_success "raw input authority fixture fails" derived_structured_fails raw-input-authority mutate_raw_input_authority
  assert_success "unresolved evidence ref fixture fails" derived_structured_fails unresolved-ref mutate_unresolved_ref
  assert_success "invalid final judgment fixture fails" derived_structured_fails invalid-final-judgment mutate_invalid_final_judgment
  assert_success "invalid updated recommendation fixture fails" derived_structured_fails invalid-updated-recommendation mutate_invalid_updated_recommendation
  assert_success "missing structured section fixture fails" derived_structured_fails missing-structured-section mutate_missing_structured_section
  assert_success "missing input context fixture fails" derived_structured_fails missing-input-context mutate_missing_input_context
  assert_success "missing evaluation posture fixture fails" derived_structured_fails missing-posture mutate_missing_posture
  assert_success "missing patch-versus-redesign report fixture fails" derived_report_fails missing-patch-redesign mutate_missing_patch_redesign_report
  assert_success "insufficient alternative paths fixture fails" derived_structured_fails insufficient-alternative-paths mutate_insufficient_alternative_paths
  assert_success "missing quality attribute fixture fails" derived_structured_fails missing-quality-attribute mutate_missing_quality_attribute
  assert_success "missing invariant compliance fixture fails" derived_structured_fails missing-invariant-compliance mutate_missing_octon_invariant
  assert_success "missing redesign trigger fixture fails" derived_structured_fails missing-redesign-trigger mutate_missing_redesign_trigger
  assert_success "Unknown-as-Pass fixture fails" derived_structured_fails unknown-as-pass mutate_unknown_as_pass
  assert_success "missing invariant evidence gap fixture fails" derived_structured_fails missing-invariant-gap mutate_missing_invariant_gap
  assert_success "missing blocking correction fixture fails" derived_structured_fails missing-blocking-correction mutate_missing_blocking_correction
  assert_success "missing invariant validity/evolution fixture fails" derived_structured_fails missing-invariant-validity-evolution mutate_missing_invariant_validity_evolution
  assert_success "invalid invariant recommendation category fixture fails" derived_structured_fails invalid-recommendation-category mutate_invalid_invariant_recommendation_category
  assert_success "missing invariant required change fixture fails" derived_structured_fails missing-required-change mutate_missing_invariant_required_change
  assert_success "weak invariant change-control bar fixture fails" derived_structured_fails weak-change-control-bar mutate_weak_change_control_bar
  assert_success "invariant change approved fixture fails" derived_structured_fails invariant-change-approved mutate_invariant_change_approved
  assert_success "authority-claiming recommendation fixture fails" derived_structured_fails recommendation-claims-authority mutate_recommendation_claims_authority
  assert_success "missing closeout owner fixture fails" derived_structured_fails missing-closeout-owner mutate_missing_closeout_owner
  assert_success "fit judgment with material invariant failure fixture fails" derived_structured_fails fit-with-material-invariant-failure mutate_fit_judgment_with_material_invariant_failure
  assert_success "major finding without connection basis fixture fails" derived_structured_fails missing-major-finding-connection-basis mutate_major_finding_without_connection_basis
  assert_success "summary/final judgment mismatch fixture fails" derived_structured_fails summary-final-judgment-mismatch mutate_summary_final_judgment_mismatch

  echo
  echo "$TEST_NAME: passed=$pass_count failed=$fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
