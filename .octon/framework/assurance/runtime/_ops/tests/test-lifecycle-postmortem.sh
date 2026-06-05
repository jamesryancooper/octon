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

positive_passes() {
  bash "$VALIDATOR" \
    --structured-output "$FIXTURE_ROOT/positive/evaluation.yml" \
    --report "$FIXTURE_ROOT/positive/report.md" \
    --review-findings "$FIXTURE_ROOT/positive/review-findings.ndjson" >/dev/null
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
