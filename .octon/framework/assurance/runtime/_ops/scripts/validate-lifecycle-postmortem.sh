#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

STRUCTURED_OUTPUT=""
REPORT_PATH=""
REVIEW_FINDINGS=""
EVIDENCE_MAP=""
KNOWN_LIMITS=""
READINESS_SUMMARY=""
RUN_ID=""
errors=0

REPORT_HEADINGS=(
  "1. Executive Post-Mortem Summary"
  "2. Intended Lifecycle Job"
  "3. Actual Lifecycle Reconstruction"
  "4. What Went Well"
  "5. What Did Not Go Well"
  "6. Chesterton's Fence Review"
  "7. Essential vs Accidental Lifecycle Complexity"
  "8. Valid Constraints vs Stale Constraints"
  "9. Patch-vs-Redesign Decision Gate"
  "10. Redesign Triggers"
  "11. Clean-Sheet Lifecycle Reference Design"
  "12. Alternative Improvement Paths"
  "13. Lifecycle Quality Attribute Scoring"
  "14. Octon Invariant Review, If Applicable"
  "15. Root Cause Analysis"
  "16. Improvement Plan"
  "17. Updated Lifecycle Recommendation"
  "18. Post-Mortem Closeout"
)

STRUCTURED_SECTIONS=(
  "input_context"
  "evaluation_posture"
  "executive_postmortem_summary"
  "intended_lifecycle_job"
  "actual_lifecycle_reconstruction"
  "what_went_well"
  "what_did_not_go_well"
  "chestertons_fence_review"
  "essential_vs_accidental_complexity"
  "valid_vs_stale_constraints"
  "patch_vs_redesign_decision_gate"
  "redesign_triggers"
  "clean_sheet_lifecycle_reference_design"
  "alternative_improvement_paths"
  "lifecycle_quality_attribute_scoring"
  "octon_invariant_review"
  "root_cause_analysis"
  "improvement_plan"
  "updated_lifecycle_recommendation"
  "postmortem_closeout"
)

INPUT_CONTEXT_FIELDS=(
  "lifecycle_context"
  "intended_purpose"
  "actual_run"
  "artifacts_and_evidence"
  "known_concerns"
  "octon_context"
)

POSTURE_FIELDS=(
  "role_frame_applied"
  "first_principles_traps_avoided"
  "chestertons_fence_posture_applied"
  "non_worship_non_destruction_posture_applied"
)

BASE_QUALITY_ATTRIBUTES=(
  "Purpose fit"
  "Decision quality"
  "Evidence quality"
  "Risk exposure"
  "Governance fit"
  "Authority clarity"
  "Source-of-truth clarity"
  "Operational clarity"
  "Reliability"
  "Repeatability"
  "Recoverability"
  "Reversibility"
  "Auditability"
  "Observability"
  "Simplicity"
  "Complexity calibration"
  "Maintainability"
  "Evolvability"
  "Scalability of the lifecycle"
  "Human usability"
)

OCTON_QUALITY_ATTRIBUTES=(
  "Agent/automation usability"
  "Octon invariant fit"
  "Support-proof readiness"
)

REQUIRED_OCTON_INVARIANTS=(
  "Constitutional Engineering Harness identity"
  "Governed Agent Runtime boundary"
  ".octon filesystem authority model"
  "five-class root separation"
  "engine-owned authorization"
  "deny-by-default capability governance"
  "mission-scoped reversible autonomy"
  "source-of-truth clarity"
  "evidence retention"
  "replay and rollback posture"
  "approval exception revocation materialization"
  "support-proof requirements"
  "no generated authority"
  "no raw-input authority"
  "no second control plane"
  "no force-fit integration"
)

BASELINE_PATHS=(
  "Preserve mostly as-is"
  "Targeted improvements"
  "Refactor / simplify lifecycle structure"
  "Redesign lifecycle from first principles"
)

REQUIRED_REDESIGN_TRIGGERS=(
  "The same root cause appears across multiple failures."
  "The lifecycle needs many special cases to preserve key invariants."
  "Governance is added after the fact instead of being structural."
  "Source-of-truth ambiguity is inherent to the lifecycle model."
  "Flexibility requires wrappers around most major steps."
  "Simple future changes are disproportionately expensive."
  "The lifecycle can only be made safe by adding heavy compensating controls."
  "The process duplicates existing primitives."
  "The lifecycle is understandable only through exceptions."
  "A clean-sheet lifecycle would not include the central abstraction being used."
  "The process produces approvals without sufficient evidence."
  "The process produces artifacts that look authoritative but are not."
  "The process hides rather than exposes risk."
  "The process makes hacks look legitimate."
  "The process allows technically governed but conceptually misfit subsystems to accumulate."
)

usage() {
  cat <<'USAGE'
usage:
  validate-lifecycle-postmortem.sh --structured-output <path> [--report <path>] [--review-findings <path>] [--run-id <id>]
  validate-lifecycle-postmortem.sh --structured <path> [--report <path>] [--review-findings <path>] [--run-id <id>]
  validate-lifecycle-postmortem.sh --evidence-map <path> [--known-limits <path>] [--readiness-summary <path>]
  validate-lifecycle-postmortem.sh --run-id <id>

When only --run-id is provided, the validator reads:
  .octon/state/evidence/runs/<run-id>/assurance/lifecycle-postmortem/evaluation.yml
  .octon/state/evidence/runs/<run-id>/assurance/lifecycle-postmortem/report.md
  .octon/state/evidence/runs/<run-id>/assurance/lifecycle-postmortem/evidence-map.yml
  .octon/state/evidence/runs/<run-id>/assurance/lifecycle-postmortem/known-limits.yml
  .octon/state/evidence/runs/<run-id>/assurance/lifecycle-postmortem/readiness-summary.md
USAGE
}

pass() { echo "[OK] $1"; }
fail() {
  echo "[ERROR] $1" >&2
  errors=$((errors + 1))
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 && pass "found command: $1" || fail "missing command: $1"
}

repo_path() {
  local raw="$1"
  if [[ "$raw" = /* ]]; then
    printf '%s\n' "$raw"
  else
    printf '%s\n' "$ROOT_DIR/$raw"
  fi
}

non_empty() {
  [[ -n "${1// }" && "$1" != "null" ]]
}

allowed_final_judgment() {
  case "$1" in
    "Fit to reuse as-is"|"Fit to reuse with targeted improvements"|"Fit for limited/pilot use only"|"Not fit without significant lifecycle redesign"|"Fundamentally misaligned with the system's needs")
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

allowed_updated_recommendation() {
  case "$1" in
    "Keep as-is"|"Keep with minor documentation improvements"|"Improve with targeted changes"|"Refactor / simplify"|"Split into separate lifecycles"|"Merge with another lifecycle"|"Move to pilot/lab only"|"Redesign from first principles"|"Retire and replace")
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

allowed_invariant_rating() {
  case "$1" in
    Pass|Partial|Fail|Unknown|"Not Applicable") return 0 ;;
    *) return 1 ;;
  esac
}

allowed_invariant_recommendation() {
  case "$1" in
    Keep|Clarify|Strengthen|Relax|Split|Merge|Reclassify|Replace|Remove|Add) return 0 ;;
    *) return 1 ;;
  esac
}

high_or_very_high_bar() {
  case "$1" in
    high|very_high) return 0 ;;
    *) return 1 ;;
  esac
}

line_number_for_heading() {
  local file="$1"
  local heading="$2"
  awk -v heading="## $heading" '$0 == heading { print NR; exit }' "$file"
}

yq_scalar() {
  local expr="$1"
  local file="$2"
  yq -r "$expr // \"\"" "$file"
}

yq_len() {
  local expr="$1"
  local file="$2"
  yq -r "$expr | length // 0" "$file"
}

require_yq_true() {
  local file="$1"
  local expr="$2"
  local label="$3"
  if yq -e "$expr" "$file" >/dev/null 2>&1; then
    pass "$label"
  else
    fail "$label"
  fi
}

validate_report() {
  local report="$1"
  [[ -f "$report" ]] || { fail "Markdown report missing: ${report#$ROOT_DIR/}"; return; }

  local previous_line=0
  local heading line
  for heading in "${REPORT_HEADINGS[@]}"; do
    line="$(line_number_for_heading "$report" "$heading")"
    if non_empty "$line"; then
      pass "report section present: $heading"
      if [[ "$line" -gt "$previous_line" ]]; then
        pass "report section order valid: $heading"
      else
        fail "report section out of order: $heading"
      fi
      previous_line="$line"
    else
      fail "report missing required section: $heading"
    fi
  done

  if non_empty "$(line_number_for_heading "$report" "Major Findings")"; then
    pass "report section present: Major Findings"
  else
    fail "report missing required section: Major Findings"
  fi
  if non_empty "$(line_number_for_heading "$report" "Recommendations")"; then
    pass "report section present: Recommendations"
  else
    fail "report missing required section: Recommendations"
  fi
  if non_empty "$(line_number_for_heading "$report" "Non-Authority Statement")"; then
    pass "report section present: Non-Authority Statement"
  else
    fail "report missing required section: Non-Authority Statement"
  fi
  if grep -Fiq -- "non-authority" "$report"; then
    pass "report carries non-authority statement"
  else
    fail "report must carry non-authority statement"
  fi
}

validate_evidence_ref() {
  local ref="$1"
  [[ -n "$ref" && "$ref" != "null" ]] || { fail "evidence ref is empty"; return; }
  case "$ref" in
    fixture://*|evidence://*|unavailable:*)
      pass "evidence ref uses explicit non-file scheme: $ref"
      return
      ;;
    .octon/generated/*)
      fail "generated output must not be classified as retained evidence or authority: $ref"
      return
      ;;
    .octon/inputs/*)
      fail "raw input or proposal path must not be classified as retained evidence or authority: $ref"
      return
      ;;
    .octon/*)
      local resolved
      resolved="$(repo_path "$ref")"
      if [[ -e "$resolved" ]]; then
        pass "evidence ref resolves: $ref"
      else
        fail "evidence ref does not resolve: $ref"
      fi
      ;;
    *)
      fail "evidence ref must be repo-relative .octon path, evidence://, fixture://, or unavailable: $ref"
      ;;
  esac
}

validate_evidence_refs() {
  local file="$1"
  local refs=()
  mapfile -t refs < <(
    {
      yq -r '.evidence_refs[]?' "$file"
      yq -r '.input_context.lifecycle_context.evidence_refs[]?' "$file"
      yq -r '.input_context.intended_purpose.evidence_refs[]?' "$file"
      yq -r '.input_context.actual_run.evidence_refs[]?' "$file"
      yq -r '.input_context.artifacts_and_evidence.evidence_refs[]?' "$file"
      yq -r '.input_context.known_concerns.evidence_refs[]?' "$file"
      yq -r '.input_context.octon_context.evidence_refs[]?' "$file"
      yq -r '.executive_postmortem_summary.evidence_refs[]?' "$file"
      yq -r '.actual_lifecycle_reconstruction[].evidence_refs[]?' "$file"
      yq -r '.what_went_well[].evidence_refs[]?' "$file"
      yq -r '.what_did_not_go_well[].evidence_refs[]?' "$file"
      yq -r '.chestertons_fence_review[].evidence_refs[]?' "$file"
      yq -r '.essential_vs_accidental_complexity[].evidence_refs[]?' "$file"
      yq -r '.valid_vs_stale_constraints[].evidence_refs[]?' "$file"
      yq -r '.patch_vs_redesign_decision_gate.evidence_refs[]?' "$file"
      yq -r '.patch_vs_redesign_decision_gate.weakness_classifications[].evidence_refs[]?' "$file"
      yq -r '.redesign_triggers[].evidence_refs[]?' "$file"
      yq -r '.alternative_improvement_paths[].evidence_refs[]?' "$file"
      yq -r '.lifecycle_quality_attribute_scoring[].evidence_refs[]?' "$file"
      yq -r '.octon_invariant_review.invariant_compliance[].evidence_refs[]?' "$file"
      yq -r '.root_cause_analysis[].evidence_refs[]?' "$file"
      yq -r '.improvement_plan[].evidence_refs[]?' "$file"
      yq -r '.updated_lifecycle_recommendation.evidence_refs[]?' "$file"
      yq -r '.major_findings[].evidence_refs[]?' "$file"
    } | awk 'NF'
  )
  if [[ "${#refs[@]}" -eq 0 ]]; then
    fail "structured output must contain evidence refs"
    return
  fi
  local ref
  for ref in "${refs[@]}"; do
    validate_evidence_ref "$ref"
  done
}

validate_input_context_and_posture() {
  local file="$1"
  local field
  for field in "${INPUT_CONTEXT_FIELDS[@]}"; do
    require_yq_true "$file" ".input_context.$field.summary != null and .input_context.$field.summary != \"\"" "input context summary present: $field"
    require_yq_true "$file" ".input_context.$field.evidence_refs | length > 0" "input context evidence refs present: $field"
  done
  for field in "${POSTURE_FIELDS[@]}"; do
    require_yq_true "$file" ".evaluation_posture.$field == true" "evaluation posture declared: $field"
  done
}

require_top_level_sections() {
  local file="$1"
  local section
  for section in "${STRUCTURED_SECTIONS[@]}"; do
    require_yq_true "$file" "has(\"$section\")" "structured section present: $section"
  done
}

require_array_non_empty() {
  local file="$1"
  local expr="$2"
  local label="$3"
  local count
  count="$(yq_len "$expr" "$file")"
  [[ "$count" -gt 0 ]] && pass "$label" || fail "$label"
}

validate_core_sections() {
  local file="$1"
  require_yq_true "$file" '.section_order.eighteen_sections_present == true' "eighteen-section structured order declared"
  require_yq_true "$file" '.section_order.patch_vs_redesign_present == true' "patch-versus-redesign reasoning declared"
  require_yq_true "$file" '.section_order.invariant_compliance_before_quality_scoring == true' "invariant compliance before quality scoring declared"
  require_yq_true "$file" '.section_order.invariant_validity_after_redesign_pressure_before_recommendations == true' "invariant validity/evolution ordering declared"

  require_array_non_empty "$file" '.actual_lifecycle_reconstruction' "actual lifecycle reconstruction records present"
  require_array_non_empty "$file" '.what_went_well' "what-went-well records present"
  require_array_non_empty "$file" '.what_did_not_go_well' "what-did-not-go-well records present"
  require_array_non_empty "$file" '.chestertons_fence_review' "Chesterton's Fence records present"
  require_array_non_empty "$file" '.essential_vs_accidental_complexity' "complexity records present"
  require_array_non_empty "$file" '.valid_vs_stale_constraints' "constraint records present"
  require_array_non_empty "$file" '.patch_vs_redesign_decision_gate.weakness_classifications' "patch-versus-redesign weakness classifications present"
  require_array_non_empty "$file" '.redesign_triggers' "redesign trigger records present"
  require_array_non_empty "$file" '.root_cause_analysis' "root cause records present"
  require_array_non_empty "$file" '.improvement_plan' "improvement plan records present"

  local recommendation
  recommendation="$(yq_scalar '.updated_lifecycle_recommendation.recommendation' "$file")"
  allowed_updated_recommendation "$recommendation" \
    && pass "updated lifecycle recommendation allowed" \
    || fail "invalid updated lifecycle recommendation: $recommendation"

  require_yq_true "$file" '.intended_lifecycle_job.decisions_made_safer_or_clearer != null' "intended job decisions-made-safer field present"
  require_yq_true "$file" '.intended_lifecycle_job.outcomes_needed != null' "intended job outcomes-needed field present"
  require_yq_true "$file" '.intended_lifecycle_job.artifacts_or_evidence_to_leave != null' "intended job artifacts/evidence field present"
  require_yq_true "$file" '.intended_lifecycle_job.impossible_or_difficult_if_worked != null' "intended job impossibility field present"
}

validate_summary_final_judgment() {
  local file="$1"
  local final_judgment fitness_to_reuse
  final_judgment="$(yq_scalar '.final_judgment' "$file")"
  fitness_to_reuse="$(yq_scalar '.executive_postmortem_summary.fitness_to_reuse' "$file")"
  [[ "$final_judgment" == "$fitness_to_reuse" ]] \
    && pass "executive summary fitness matches final judgment" \
    || fail "executive summary fitness must match final judgment"
}

validate_alternative_paths() {
  local file="$1"
  local count path
  count="$(yq_len '.alternative_improvement_paths' "$file")"
  [[ "$count" -ge 4 ]] && pass "at least four alternative improvement paths present" || fail "at least four alternative improvement paths required"
  for path in "${BASELINE_PATHS[@]}"; do
    if yq -e ".alternative_improvement_paths[] | select(.path == \"$path\")" "$file" >/dev/null 2>&1; then
      pass "baseline improvement path present: $path"
    else
      fail "baseline improvement path missing: $path"
    fi
  done
}

validate_redesign_triggers() {
  local file="$1"
  local count index trigger implication present required
  count="$(yq_len '.redesign_triggers' "$file")"
  [[ "$count" -gt 0 ]] && pass "redesign trigger records present" || fail "redesign trigger records required"
  for required in "${REQUIRED_REDESIGN_TRIGGERS[@]}"; do
    if yq -e ".redesign_triggers[] | select(.redesign_trigger == \"$required\")" "$file" >/dev/null 2>&1; then
      pass "required redesign trigger present: $required"
    else
      fail "required redesign trigger missing: $required"
    fi
  done
  for ((index=0; index<count; index++)); do
    trigger="$(yq_scalar ".redesign_triggers[$index].redesign_trigger" "$file")"
    present="$(yq -r ".redesign_triggers[$index].present" "$file")"
    implication="$(yq_scalar ".redesign_triggers[$index].implication" "$file")"
    non_empty "$trigger" && pass "redesign trigger label present" || fail "redesign trigger label required"
    [[ "$present" == "true" || "$present" == "false" ]] && pass "redesign trigger present flag is boolean" || fail "redesign trigger present flag must be boolean"
    non_empty "$implication" && pass "redesign trigger implication present" || fail "redesign trigger implication required"
    require_yq_true "$file" ".redesign_triggers[$index].evidence_refs | length > 0" "redesign trigger evidence refs present"
  done
}

validate_quality_scoring() {
  local file="$1"
  local octon_subject="$2"
  local attribute score count
  count="$(yq_len '.lifecycle_quality_attribute_scoring' "$file")"
  [[ "$count" -gt 0 ]] && pass "quality attribute scoring records present" || fail "quality attribute scoring records required"

  for attribute in "${BASE_QUALITY_ATTRIBUTES[@]}"; do
    if yq -e ".lifecycle_quality_attribute_scoring[] | select(.attribute == \"$attribute\")" "$file" >/dev/null 2>&1; then
      pass "quality attribute present: $attribute"
    else
      fail "quality attribute missing: $attribute"
    fi
  done
  if [[ "$octon_subject" == "true" ]]; then
    for attribute in "${OCTON_QUALITY_ATTRIBUTES[@]}"; do
      if yq -e ".lifecycle_quality_attribute_scoring[] | select(.attribute == \"$attribute\")" "$file" >/dev/null 2>&1; then
        pass "Octon quality attribute present: $attribute"
      else
        fail "Octon quality attribute missing: $attribute"
      fi
    done
  fi

  for ((index=0; index<count; index++)); do
    score="$(yq -r ".lifecycle_quality_attribute_scoring[$index].score // \"\"" "$file")"
    if [[ "$score" =~ ^[0-5]$ ]]; then
      pass "quality score in range: $score"
    else
      fail "quality score must be integer 0-5: $score"
    fi
    require_yq_true "$file" ".lifecycle_quality_attribute_scoring[$index].evidence_refs | length > 0" "quality score evidence refs present"
    require_yq_true "$file" ".lifecycle_quality_attribute_scoring[$index].rationale != null and .lifecycle_quality_attribute_scoring[$index].rationale != \"\"" "quality score rationale present"
  done
}

validate_major_findings() {
  local file="$1"
  local count index
  count="$(yq_len '.major_findings' "$file")"
  for ((index=0; index<count; index++)); do
    require_yq_true "$file" ".major_findings[$index].connection_basis | length > 0" "major finding connection_basis present"
  done
}

validate_closeout() {
  local file="$1"
  local count index
  require_yq_true "$file" '.postmortem_closeout.lessons_learned != null' "closeout lessons learned present"
  require_yq_true "$file" '.postmortem_closeout.decisions_to_record != null' "closeout decisions to record present"
  require_yq_true "$file" '.postmortem_closeout.artifacts_to_archive != null' "closeout artifacts to archive present"
  require_yq_true "$file" '.postmortem_closeout.evidence_to_retain != null' "closeout evidence to retain present"
  require_yq_true "$file" '.postmortem_closeout.process_changes_to_implement != null' "closeout process changes present"
  require_yq_true "$file" '.postmortem_closeout.risks_to_monitor != null' "closeout risks to monitor present"
  require_yq_true "$file" '.postmortem_closeout.follow_up_review_trigger != null and .postmortem_closeout.follow_up_review_trigger != ""' "closeout follow-up trigger present"

  count="$(yq_len '.postmortem_closeout.actions' "$file")"
  [[ "$count" -gt 0 ]] && pass "closeout actions present" || fail "closeout actions required"
  for ((index=0; index<count; index++)); do
    require_yq_true "$file" ".postmortem_closeout.actions[$index].finding != null and .postmortem_closeout.actions[$index].finding != \"\"" "closeout action finding present"
    require_yq_true "$file" ".postmortem_closeout.actions[$index].action != null and .postmortem_closeout.actions[$index].action != \"\"" "closeout action action present"
    require_yq_true "$file" ".postmortem_closeout.actions[$index].owner_role != null and .postmortem_closeout.actions[$index].owner_role != \"\"" "closeout action owner_role present"
    require_yq_true "$file" ".postmortem_closeout.actions[$index].priority != null and .postmortem_closeout.actions[$index].priority != \"\"" "closeout action priority present"
    require_yq_true "$file" ".postmortem_closeout.actions[$index].due_or_trigger != null and .postmortem_closeout.actions[$index].due_or_trigger != \"\"" "closeout action due_or_trigger present"
    require_yq_true "$file" ".postmortem_closeout.actions[$index].evidence_of_completion != null and .postmortem_closeout.actions[$index].evidence_of_completion != \"\"" "closeout action evidence_of_completion present"
  done
}

final_judgment_is_fit() {
  case "$1" in
    "Fit to reuse as-is"|"Fit to reuse with targeted improvements") return 0 ;;
    *) return 1 ;;
  esac
}

validate_authority_boundary() {
  local file="$1"
  require_yq_true "$file" '.authority_boundary.generated_outputs_authority == false' "generated outputs are non-authority"
  require_yq_true "$file" '.authority_boundary.raw_inputs_authority == false' "raw inputs are non-authority"
  require_yq_true "$file" '.authority_boundary.postmortem_approves_lifecycle_transition == false' "postmortem does not approve lifecycle transition"
  require_yq_true "$file" '.authority_boundary.postmortem_approves_closeout == false' "postmortem does not approve closeout"
  require_yq_true "$file" '.authority_boundary.postmortem_approves_redesign == false' "postmortem does not approve redesign"
  require_yq_true "$file" '.authority_boundary.postmortem_approves_support_widening == false' "postmortem does not approve support widening"
  require_yq_true "$file" '.authority_boundary.postmortem_approves_generated_output_publication == false' "postmortem does not approve generated output publication"
  require_yq_true "$file" '.authority_boundary.postmortem_approves_invariant_change == false' "postmortem does not approve invariant change"
  require_yq_true "$file" '.authority_boundary.non_authority_assertion == true' "non-authority assertion present"

  local count index status
  count="$(yq_len '.follow_up_recommendations' "$file")"
  for ((index=0; index<count; index++)); do
    status="$(yq_scalar ".follow_up_recommendations[$index].authority_status" "$file")"
    [[ "$status" == "proposed-evidence-only" ]] \
      && pass "follow-up recommendation is proposed evidence only" \
      || fail "follow-up recommendation must remain proposed-evidence-only"
  done
}

validate_invariant_compliance() {
  local file="$1"
  local count index rating gap blocking required material counts_as_pass invariant
  count="$(yq_len '.octon_invariant_review.invariant_compliance' "$file")"
  [[ "$count" -gt 0 ]] && pass "invariant compliance records present" || fail "Octon subject requires invariant compliance records"
  for ((index=0; index<count; index++)); do
    invariant="$(yq_scalar ".octon_invariant_review.invariant_compliance[$index].invariant" "$file")"
    rating="$(yq_scalar ".octon_invariant_review.invariant_compliance[$index].rating" "$file")"
    gap="$(yq_scalar ".octon_invariant_review.invariant_compliance[$index].evidence_gap" "$file")"
    blocking="$(yq -r ".octon_invariant_review.invariant_compliance[$index].blocking // \"false\"" "$file")"
    required="$(yq_scalar ".octon_invariant_review.invariant_compliance[$index].required_correction" "$file")"
    material="$(yq -r ".octon_invariant_review.invariant_compliance[$index].material // \"false\"" "$file")"
    counts_as_pass="$(yq -r ".octon_invariant_review.invariant_compliance[$index].counts_as_pass // \"false\"" "$file")"

    non_empty "$invariant" && pass "invariant name present: $invariant" || fail "invariant name required"
    allowed_invariant_rating "$rating" && pass "invariant rating allowed: $rating" || fail "invalid invariant rating: $rating"
    case "$rating" in
      Unknown)
        [[ "$counts_as_pass" == "false" ]] && pass "Unknown invariant rating does not count as pass" || fail "Unknown invariant rating must not count as pass"
        non_empty "$gap" && pass "Unknown invariant rating records evidence gap" || fail "Unknown invariant rating requires evidence_gap"
        ;;
      Fail)
        if [[ "$material" == "true" ]]; then
          [[ "$blocking" == "true" ]] && pass "material invariant failure is blocking" || fail "material invariant failure requires blocking=true"
          non_empty "$required" && pass "material invariant failure records required correction" || fail "material invariant failure requires required_correction"
        fi
        ;;
      Partial)
        if [[ "$material" == "true" ]]; then
          non_empty "$required" && pass "material partial invariant records required correction" || fail "material partial invariant requires required_correction"
        fi
        ;;
    esac
  done
}

validate_invariant_validity() {
  local file="$1"
  local count index recommendation required_change bar status
  count="$(yq_len '.octon_invariant_review.invariant_validity_evolution' "$file")"
  [[ "$count" -gt 0 ]] && pass "invariant validity/evolution records present" || fail "Octon subject requires invariant validity/evolution records"
  for ((index=0; index<count; index++)); do
    recommendation="$(yq_scalar ".octon_invariant_review.invariant_validity_evolution[$index].recommendation" "$file")"
    required_change="$(yq_scalar ".octon_invariant_review.invariant_validity_evolution[$index].required_change" "$file")"
    bar="$(yq_scalar ".octon_invariant_review.invariant_validity_evolution[$index].change_control_bar" "$file")"
    status="$(yq_scalar ".octon_invariant_review.invariant_validity_evolution[$index].authority_status" "$file")"
    allowed_invariant_recommendation "$recommendation" && pass "invariant recommendation allowed: $recommendation" || fail "invalid invariant recommendation: $recommendation"
    [[ "$status" == "proposed-evidence-only" ]] && pass "invariant recommendation is proposed evidence only" || fail "invariant recommendation must remain proposed-evidence-only"
    if [[ "$recommendation" != "Keep" ]]; then
      non_empty "$required_change" && pass "non-Keep invariant recommendation has required change" || fail "non-Keep invariant recommendation requires required_change"
      non_empty "$bar" && pass "non-Keep invariant recommendation has change-control bar" || fail "non-Keep invariant recommendation requires change_control_bar"
    fi
    case "$recommendation" in
      Relax|Remove|Add|Reclassify)
        high_or_very_high_bar "$bar" && pass "$recommendation recommendation uses high scrutiny" || fail "$recommendation recommendation requires high or very_high change_control_bar"
        ;;
    esac
  done
}

validate_octon_invariants() {
  local file="$1"
  local octon_subject="$2"
  if [[ "$octon_subject" != "true" ]]; then
    pass "non-Octon subject does not require Octon invariant records"
    return
  fi

  require_yq_true "$file" '.octon_invariant_review.applicable == true' "Octon invariant review marked applicable"
  local invariant
  for invariant in "${REQUIRED_OCTON_INVARIANTS[@]}"; do
    if yq -e ".octon_invariant_review.invariant_compliance[] | select(.invariant == \"$invariant\")" "$file" >/dev/null 2>&1; then
      pass "required Octon invariant present: $invariant"
    else
      fail "required Octon invariant missing: $invariant"
    fi
  done
  validate_invariant_compliance "$file"
  validate_invariant_validity "$file"
}

validate_octon_fit_gating() {
  local file="$1"
  local octon_subject="$2"
  local final_judgment="$3"
  if [[ "$octon_subject" != "true" ]]; then
    pass "non-Octon subject does not require invariant fit gating"
    return
  fi
  if ! final_judgment_is_fit "$final_judgment"; then
    pass "Octon fit gating allows non-fit final judgment"
    return
  fi

  local count index rating material blocking invariant blocking_issue=false
  count="$(yq_len '.octon_invariant_review.invariant_compliance' "$file")"
  for ((index=0; index<count; index++)); do
    invariant="$(yq_scalar ".octon_invariant_review.invariant_compliance[$index].invariant" "$file")"
    rating="$(yq_scalar ".octon_invariant_review.invariant_compliance[$index].rating" "$file")"
    material="$(yq -r ".octon_invariant_review.invariant_compliance[$index].material // \"false\"" "$file")"
    blocking="$(yq -r ".octon_invariant_review.invariant_compliance[$index].blocking // \"false\"" "$file")"
    if [[ "$rating" == "Fail" && "$material" == "true" ]]; then
      fail "fit judgment not allowed with material invariant Fail: $invariant"
      blocking_issue=true
    fi
    if [[ "$rating" == "Partial" && "$material" == "true" ]]; then
      fail "fit judgment not allowed with material invariant Partial: $invariant"
      blocking_issue=true
    fi
    if [[ "$rating" == "Unknown" && "$blocking" == "true" ]]; then
      fail "fit judgment not allowed with blocking invariant Unknown: $invariant"
      blocking_issue=true
    fi
  done
  [[ "$blocking_issue" == "false" ]] && pass "Octon fit judgment has no material invariant blockers"
}

validate_review_findings() {
  local file="$1"
  [[ -f "$file" ]] || { fail "review findings file missing: ${file#$ROOT_DIR/}"; return; }
  local line
  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    if jq -e '.schema_version == "review-finding-v1" and (.finding_id | length > 0) and (.evidence_refs | length > 0)' >/dev/null <<<"$line"; then
      pass "review-finding-v1 line shaped correctly"
    else
      fail "review finding line must match review-finding-v1 shape"
    fi
  done < "$file"
}

validate_postmortem_ref_record() {
  local file="$1"
  local expr="$2"
  local label="$3"
  local ref ref_class authority_use digest resolved actual
  ref="$(yq_scalar "$expr.ref" "$file")"
  ref_class="$(yq_scalar "$expr.ref_class" "$file")"
  authority_use="$(yq_scalar "$expr.authority_use" "$file")"
  digest="$(yq_scalar "$expr.sha256" "$file")"

  non_empty "$ref" && pass "$label ref present" || { fail "$label ref required"; return; }
  case "$ref" in
    .octon/state/control/*|.octon/state/evidence/*)
      resolved="$(repo_path "$ref")"
      [[ -f "$resolved" ]] && pass "$label ref resolves" || fail "$label ref missing: $ref"
      ;;
    .octon/generated/*)
      [[ "$authority_use" == "derived-only" ]] && pass "$label generated ref is derived-only" || fail "$label generated ref must be derived-only"
      resolved="$(repo_path "$ref")"
      [[ -f "$resolved" ]] && pass "$label generated ref resolves" || fail "$label generated ref missing: $ref"
      ;;
    .octon/inputs/*)
      [[ "$authority_use" == "non-authoritative" ]] && pass "$label proposal/input ref is non-authoritative" || fail "$label proposal/input ref must be non-authoritative"
      resolved="$(repo_path "$ref")"
      [[ -f "$resolved" ]] && pass "$label proposal/input ref resolves" || fail "$label proposal/input ref missing: $ref"
      ;;
    *)
      fail "$label ref must stay inside .octon state/control, state/evidence, generated, or inputs: $ref"
      return
      ;;
  esac

  case "$ref_class:$authority_use" in
    control:control-truth)
      pass "$label control ref authority use is explicit"
      ;;
    retained-evidence:evidence-only|retained-workflow-evidence:evidence-only)
      pass "$label retained evidence ref is evidence-only"
      ;;
    retained-child-evidence-dereference:evidence-only-non-substitutive)
      pass "$label child evidence dereference ref is non-substitutive"
      ;;
    generated:derived-only)
      pass "$label generated ref is derived-only"
      ;;
    proposal-local:non-authoritative)
      pass "$label proposal-local ref is non-authoritative"
      ;;
    *)
      fail "$label has invalid ref_class/authority_use: $ref_class/$authority_use"
      ;;
  esac

  if non_empty "$digest"; then
    if [[ "$digest" =~ ^sha256:[0-9a-f]{64}$ ]]; then
      pass "$label digest shape valid"
      if [[ -f "$resolved" ]]; then
        actual="sha256:$(shasum -a 256 "$resolved" | awk '{print $1}')"
        [[ "$digest" == "$actual" ]] && pass "$label digest matches" || fail "$label digest mismatch: $ref"
      fi
    else
      fail "$label digest shape invalid"
    fi
  fi
}

validate_ref_array() {
  local file="$1"
  local expr="$2"
  local label="$3"
  local count index
  count="$(yq_len "$expr" "$file")"
  for ((index=0; index<count; index++)); do
    validate_postmortem_ref_record "$file" "$expr[$index]" "$label[$index]"
  done
}

validate_child_evidence_ref_array() {
  local file="$1"
  local expr="$2"
  local label="$3"
  local count index ref role ref_class authority_use
  count="$(yq_len "$expr" "$file")"
  for ((index=0; index<count; index++)); do
    ref="$(yq_scalar "$expr[$index].ref" "$file")"
    role="$(yq_scalar "$expr[$index].role" "$file")"
    ref_class="$(yq_scalar "$expr[$index].ref_class" "$file")"
    authority_use="$(yq_scalar "$expr[$index].authority_use" "$file")"
    validate_postmortem_ref_record "$file" "$expr[$index]" "$label[$index]"
    non_empty "$role" && pass "$label role present" || fail "$label role required"
    [[ "$ref_class" == "retained-child-evidence-dereference" ]] \
      && pass "$label is classified as retained child evidence dereference" \
      || fail "$label must use ref_class=retained-child-evidence-dereference"
    [[ "$authority_use" == "evidence-only-non-substitutive" ]] \
      && pass "$label is evidence-only and non-substitutive" \
      || fail "$label must use authority_use=evidence-only-non-substitutive"
  done
}

validate_named_postmortem_ref_record() {
  local file="$1"
  local expr="$2"
  local label="$3"
  local path ref_class authority_role resolved
  path="$(yq_scalar "$expr.path" "$file")"
  ref_class="$(yq_scalar "$expr.ref_class" "$file")"
  authority_role="$(yq_scalar "$expr.authority_role" "$file")"

  non_empty "$path" && pass "$label path present" || { fail "$label path required"; return; }
  case "$path" in
    .octon/state/control/*|.octon/state/evidence/*)
      resolved="$(repo_path "$path")"
      [[ -e "$resolved" ]] && pass "$label path resolves" || fail "$label path missing: $path"
      ;;
    .octon/generated/*|.octon/inputs/*)
      fail "$label must not bind generated outputs or proposal inputs as retained profile evidence: $path"
      return
      ;;
    *)
      fail "$label path must stay inside .octon state/control or state/evidence: $path"
      return
      ;;
  esac
  non_empty "$ref_class" && pass "$label ref_class present" || fail "$label ref_class required"
  case "$authority_role" in
    retained-evidence|retained-evidence-diagnostic|retained-evidence-associated|retained-evidence-substitute|mutable-control-truth)
      pass "$label authority role is explicit"
      ;;
    *)
      fail "$label has invalid authority_role: $authority_role"
      ;;
  esac
}

validate_named_ref_array() {
  local file="$1"
  local expr="$2"
  local label="$3"
  local count index
  count="$(yq_len "$expr" "$file")"
  for ((index=0; index<count; index++)); do
    validate_named_postmortem_ref_record "$file" "$expr[$index]" "$label[$index]"
  done
}

validate_substitute_ref_array() {
  local file="$1"
  local expr="$2"
  local label="$3"
  local count index substitutes_for exists authority_use
  count="$(yq_len "$expr" "$file")"
  for ((index=0; index<count; index++)); do
    validate_postmortem_ref_record "$file" "$expr[$index]" "$label[$index]"
    substitutes_for="$(yq_scalar "$expr[$index].substitutes_for" "$file")"
    exists="$(yq -r "$expr[$index].exists // \"\"" "$file")"
    authority_use="$(yq_scalar "$expr[$index].authority_use" "$file")"

    non_empty "$substitutes_for" \
      && pass "$label[$index] substitutes_for present" \
      || fail "$label[$index] substitutes_for required"
    case "$substitutes_for" in
      .octon/state/control/*)
        pass "$label[$index] substitutes direct control ref"
        ;;
      *)
        fail "$label[$index] substitutes_for must name a missing direct control ref"
        ;;
    esac
    [[ "$exists" == "true" ]] \
      && pass "$label[$index] substitute source exists" \
      || fail "$label[$index] substitute source must exist"
    [[ "$authority_use" == "evidence-only" ]] \
      && pass "$label[$index] substitute is evidence-only" \
      || fail "$label[$index] substitute must be evidence-only"
  done
}

validate_proposal_program_delivery_profile() {
  local file="$1"
  local prefix="$2"
  local label="$3"
  local proof_count record_count index proof_id status authority scope

  require_yq_true "$file" "$prefix.schema_version == \"lifecycle-postmortem-proposal-program-delivery-profile-v1\"" "$label schema_version valid"
  require_yq_true "$file" "$prefix.profile_id == \"proposal-program-delivery-evaluation\"" "$label profile_id valid"
  require_yq_true "$file" "$prefix.applies_to_lifecycle_kind == \"proposal-program\"" "$label lifecycle kind binding valid"

  require_yq_true "$file" "$prefix.evidence_binding.delivery_evidence_status == \"evidence_present\" or $prefix.evidence_binding.delivery_evidence_status == \"not_applicable_no_delivery_evidence\"" "$label delivery evidence status valid"
  validate_named_ref_array "$file" "$prefix.evidence_binding.parent_status_refs" "$label parent status ref"
  validate_child_evidence_ref_array "$file" "$prefix.evidence_binding.child_terminal_status_refs" "$label child terminal status ref"
  validate_ref_array "$file" "$prefix.evidence_binding.retained_run_evidence_index_refs" "$label retained run evidence index ref"
  validate_named_ref_array "$file" "$prefix.evidence_binding.planner_refs" "$label planner ref"
  validate_named_ref_array "$file" "$prefix.evidence_binding.closeout_archive_refs" "$label closeout/archive ref"
  validate_named_ref_array "$file" "$prefix.evidence_binding.delivery_refs" "$label delivery ref"
  validate_named_ref_array "$file" "$prefix.evidence_binding.validator_generated_hygiene_refs" "$label validator/generated/hygiene ref"
  validate_named_ref_array "$file" "$prefix.evidence_binding.git_delivery_proof_refs" "$label git delivery proof ref"

  require_yq_true "$file" "$prefix.postmortem_requirement.required == true" "$label postmortem threshold required"
  require_yq_true "$file" "$prefix.postmortem_requirement.verdict == \"pass\"" "$label postmortem threshold verdict pass"
  require_yq_true "$file" "$prefix.postmortem_requirement.validator_ref == \".octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-postmortem.sh\"" "$label postmortem threshold validator bound"
  validate_named_postmortem_ref_record "$file" "$prefix.postmortem_requirement.evaluation_ref" "$label postmortem evaluation ref"
  validate_named_postmortem_ref_record "$file" "$prefix.postmortem_requirement.report_ref" "$label postmortem report ref"
  validate_named_postmortem_ref_record "$file" "$prefix.postmortem_requirement.readiness_summary_ref" "$label postmortem readiness summary ref"
  validate_named_postmortem_ref_record "$file" "$prefix.postmortem_requirement.evidence_map_ref" "$label postmortem evidence map ref"
  [[ "$(yq_len "$prefix.postmortem_requirement.digest_bound_evidence_refs" "$file")" -gt 0 ]] \
    && pass "$label postmortem digest-bound refs present" \
    || fail "$label postmortem digest-bound refs required"
  validate_ref_array "$file" "$prefix.postmortem_requirement.digest_bound_evidence_refs" "$label postmortem digest-bound ref"

  for scope in parent-program child-packet generated-artifact lifecycle-tooling-or-contract worktree-hygiene-or-residue git-delivery-state external-permission-boundary; do
    yq -e "$prefix.blocker_taxonomy[] | select(.owning_scope == \"$scope\" and .authority_status == \"evidence-only\")" "$file" >/dev/null 2>&1 \
      && pass "$label blocker taxonomy includes $scope" \
      || fail "$label blocker taxonomy missing $scope"
  done

  for expr in "$prefix.autonomy_analysis" "$prefix.efficiency_diagnostics" "$prefix.regression_test_plan"; do
    record_count="$(yq_len "$expr" "$file")"
    [[ "$record_count" -gt 0 ]] && pass "$label records present: $expr" || fail "$label records required: $expr"
    for ((index=0; index<record_count; index++)); do
      authority="$(yq_scalar "$expr[$index].authority_status" "$file")"
      [[ "$authority" == "evidence-only" ]] \
        && pass "$label record authority is evidence-only" \
        || fail "$label record authority must be evidence-only"
      require_yq_true "$file" "$expr[$index].evidence_refs | length > 0" "$label record evidence refs present"
    done
  done

  proof_count="$(yq_len "$prefix.delivery_proof_chain_audit" "$file")"
  [[ "$proof_count" -ge 7 ]] && pass "$label delivery proof chain audit covers expected scopes" || fail "$label delivery proof chain audit requires at least seven records"
  for proof_id in archive push branch-no-pr-landing sync cleanup-authorization branch-cleanup cleaned-claim; do
    yq -e "$prefix.delivery_proof_chain_audit[] | select(.proof_id == \"$proof_id\")" "$file" >/dev/null 2>&1 \
      && pass "$label delivery proof scope present: $proof_id" \
      || fail "$label delivery proof scope missing: $proof_id"
  done
  for ((index=0; index<proof_count; index++)); do
    status="$(yq_scalar "$prefix.delivery_proof_chain_audit[$index].status" "$file")"
    authority="$(yq_scalar "$prefix.delivery_proof_chain_audit[$index].authority_status" "$file")"
    case "$status" in
      evidence_present|not_applicable|evidence_gap) pass "$label delivery proof status valid: $status" ;;
      *) fail "$label invalid delivery proof status: $status" ;;
    esac
    [[ "$authority" == "evidence-only" ]] \
      && pass "$label delivery proof authority is evidence-only" \
      || fail "$label delivery proof authority must be evidence-only"
    require_yq_true "$file" "$prefix.delivery_proof_chain_audit[$index].evidence_refs | length > 0" "$label delivery proof evidence refs present"
  done

  for expr in "$prefix.recommendation_backlog" "$prefix.proposed_next_governed_routes"; do
    record_count="$(yq_len "$expr" "$file")"
    [[ "$record_count" -gt 0 ]] && pass "$label recommendations present: $expr" || fail "$label recommendations required: $expr"
    for ((index=0; index<record_count; index++)); do
      authority="$(yq_scalar "$expr[$index].authority_status" "$file")"
      [[ "$authority" == "proposed-evidence-only" ]] \
        && pass "$label recommendation is proposed evidence only" \
        || fail "$label recommendation must be proposed-evidence-only"
      require_yq_true "$file" "$expr[$index].required_governed_route != null and $expr[$index].required_governed_route != \"\"" "$label recommendation governed route present"
      require_yq_true "$file" "$expr[$index].suggested_validators | length > 0" "$label recommendation validators present"
    done
  done

  require_yq_true "$file" "$prefix.authority_boundary.profile_output_authority == false" "$label profile output is non-authority"
  require_yq_true "$file" "$prefix.authority_boundary.authorizes_lifecycle_transition == false" "$label does not authorize lifecycle transition"
  require_yq_true "$file" "$prefix.authority_boundary.authorizes_child_receipt_replacement == false" "$label does not replace child receipts"
  require_yq_true "$file" "$prefix.authority_boundary.authorizes_closeout == false" "$label does not authorize closeout"
  require_yq_true "$file" "$prefix.authority_boundary.authorizes_archive == false" "$label does not authorize archive"
  require_yq_true "$file" "$prefix.authority_boundary.authorizes_delivery == false" "$label does not authorize delivery"
  require_yq_true "$file" "$prefix.authority_boundary.authorizes_git_mutation == false" "$label does not authorize git mutation"
  require_yq_true "$file" "$prefix.authority_boundary.authorizes_cleanup == false" "$label does not authorize cleanup"
  require_yq_true "$file" "$prefix.authority_boundary.generated_outputs_authority == false" "$label generated outputs remain non-authority"
}

validate_evidence_map() {
  local file="$1"
  [[ -f "$file" ]] || { fail "evidence map missing: ${file#$ROOT_DIR/}"; return; }
  yq -e '.' "$file" >/dev/null 2>&1 && pass "evidence map parses as YAML" || fail "evidence map must parse as YAML"

  [[ "$(yq_scalar '.schema_version' "$file")" == "lifecycle-postmortem-evidence-map-v2" ]] \
    && pass "evidence map schema_version is v2" \
    || fail "evidence map schema_version must be lifecycle-postmortem-evidence-map-v2"

  require_yq_true "$file" '.authority_boundary.generated_outputs_authority == false' "evidence map keeps generated outputs non-authority"
  require_yq_true "$file" '.authority_boundary.proposal_inputs_authority == false' "evidence map keeps proposal inputs non-authority"
  require_yq_true "$file" '.authority_boundary.postmortem_authorizes_lifecycle_transition == false' "evidence map does not authorize lifecycle transition"
  require_yq_true "$file" '.authority_boundary.postmortem_authorizes_closeout == false' "evidence map does not authorize closeout"
  require_yq_true "$file" '.authority_boundary.locator_replaces_source_evidence == false' "locator does not replace source evidence"

  local direct_present lifecycle_kind substitute_count index_count validation_count rollback_count child_ref_count
  direct_present="$(yq -r '.evidence_posture.direct_control_refs_present // "false"' "$file")"
  lifecycle_kind="$(yq_scalar '.subject.lifecycle_kind' "$file")"
  substitute_count="$(yq_len '.substitute_refs' "$file")"
  index_count="$(yq_len '.retained_run_evidence_indexes' "$file")"
  validation_count="$(yq_len '.terminal_state_refs.validation' "$file")"
  rollback_count="$(yq_len '.terminal_state_refs.rollback' "$file")"
  child_ref_count="$(yq_len '.child_evidence_ref_index' "$file")"

  [[ "$direct_present" == "true" || "$direct_present" == "false" ]] \
    && pass "evidence map direct_control_refs_present is boolean" \
    || fail "evidence map direct_control_refs_present must be boolean"
  if [[ "$direct_present" == "true" ]]; then
    [[ "$(yq_len '.direct_control_refs' "$file")" -gt 0 ]] \
      && pass "evidence map includes direct control refs" \
      || fail "evidence map declares direct control refs but none are listed"
  else
    [[ "$substitute_count" -gt 0 ]] \
      && pass "evidence map includes substitutes for missing direct control refs" \
      || fail "evidence map missing direct control refs requires substitute refs"
  fi

  [[ "$index_count" -gt 0 ]] && pass "evidence map binds retained-run evidence index refs" || fail "evidence map must bind retained-run evidence index refs"
  [[ "$validation_count" -gt 0 ]] && pass "evidence map includes validation terminal evidence" || fail "evidence map missing validation terminal evidence"
  [[ "$rollback_count" -gt 0 ]] && pass "evidence map includes rollback terminal evidence" || fail "evidence map missing rollback terminal evidence"
  if [[ "$lifecycle_kind" == "proposal-program" ]]; then
    [[ "$child_ref_count" -gt 0 ]] && pass "proposal-program evidence map includes child evidence dereference refs" || fail "proposal-program evidence map missing child evidence dereference refs"
    require_yq_true "$file" 'has("proposal_program_delivery_profile")' "proposal-program evidence map includes delivery evaluation profile"
    validate_proposal_program_delivery_profile "$file" ".proposal_program_delivery_profile" "proposal-program delivery profile"
  else
    pass "child evidence dereference refs optional for lifecycle kind: ${lifecycle_kind:-unknown}"
    if yq -e 'has("proposal_program_delivery_profile")' "$file" >/dev/null 2>&1; then
      fail "non-proposal-program evidence map must not include proposal_program_delivery_profile"
    else
      pass "non-proposal-program evidence map omits proposal_program_delivery_profile"
    fi
  fi

  validate_ref_array "$file" '.retained_run_evidence_indexes' "retained-run evidence index"
  validate_ref_array "$file" '.direct_control_refs' "direct control ref"
  validate_substitute_ref_array "$file" '.substitute_refs' "substitute ref"
  validate_ref_array "$file" '.terminal_state_refs.validation' "validation terminal ref"
  validate_ref_array "$file" '.terminal_state_refs.rollback' "rollback terminal ref"
  validate_child_evidence_ref_array "$file" '.child_evidence_ref_index' "child evidence dereference ref"
  validate_ref_array "$file" '.generated_refs' "generated ref"
  validate_ref_array "$file" '.proposal_local_refs' "proposal-local ref"
}

validate_known_limits() {
  local file="$1"
  [[ -f "$file" ]] || { fail "known limits missing: ${file#$ROOT_DIR/}"; return; }
  yq -e '.' "$file" >/dev/null 2>&1 && pass "known limits parses as YAML" || fail "known limits must parse as YAML"
  [[ "$(yq_scalar '.schema_version' "$file")" == "lifecycle-postmortem-known-limits-v2" ]] \
    && pass "known limits schema_version is v2" \
    || fail "known limits schema_version must be lifecycle-postmortem-known-limits-v2"
  require_yq_true "$file" '.missing_direct_refs_recorded == true' "known limits records missing direct refs"
  require_yq_true "$file" '.substitute_refs_validated == true' "known limits records substitute validation"
  require_yq_true "$file" '.diagnostic_refs_do_not_override_terminal == true' "known limits preserves terminal-over-diagnostic posture"
  require_yq_true "$file" '.authority_boundary.locator_replaces_source_evidence == false' "known limits says locator does not replace evidence"
}

readiness_expect_line() {
  local file="$1"
  local pattern="$2"
  local label="$3"
  grep -Fqx -- "$pattern" "$file" && pass "$label" || fail "$label"
}

validate_readiness_summary() {
  local file="$1"
  local evidence_map="$2"
  local known_limits="$3"
  [[ -f "$file" ]] || { fail "readiness summary missing: ${file#$ROOT_DIR/}"; return; }
  [[ -f "$evidence_map" ]] || { fail "readiness summary requires evidence map"; return; }
  [[ -f "$known_limits" ]] || { fail "readiness summary requires known limits"; return; }

  local direct_present substitute_count validation_count rollback_count missing_recorded substitutes_validated terminal_preserved
  direct_present="$(yq -r '.evidence_posture.direct_control_refs_present // "false"' "$evidence_map")"
  substitute_count="$(yq_len '.substitute_refs' "$evidence_map")"
  validation_count="$(yq_len '.terminal_state_refs.validation' "$evidence_map")"
  rollback_count="$(yq_len '.terminal_state_refs.rollback' "$evidence_map")"
  missing_recorded="$(yq -r '.missing_direct_refs_recorded // "false"' "$known_limits")"
  substitutes_validated="$(yq -r '.substitute_refs_validated // "false"' "$known_limits")"
  terminal_preserved="$(yq -r '.diagnostic_refs_do_not_override_terminal // "false"' "$known_limits")"

  grep -Fxq "# Lifecycle Postmortem Readiness Summary" "$file" \
    && pass "readiness summary title present" \
    || fail "readiness summary title required"
  grep -Fq "derived evidence-navigation aid only" "$file" \
    && pass "readiness summary states derived non-authority status" \
    || fail "readiness summary must state derived non-authority status"

  readiness_expect_line "$file" "- Direct control refs present: $direct_present" "readiness summary direct ref posture matches evidence map"
  readiness_expect_line "$file" "- Substitute refs count: $substitute_count" "readiness summary substitute count matches evidence map"
  readiness_expect_line "$file" "- Terminal validation refs count: $validation_count" "readiness summary validation count matches evidence map"
  readiness_expect_line "$file" "- Terminal rollback refs count: $rollback_count" "readiness summary rollback count matches evidence map"
  readiness_expect_line "$file" "- Missing direct refs recorded: $missing_recorded" "readiness summary known-limits missing-ref posture matches"
  readiness_expect_line "$file" "- Substitute refs validated: $substitutes_validated" "readiness summary known-limits substitute posture matches"
  readiness_expect_line "$file" "- Diagnostic refs do not override terminal refs: $terminal_preserved" "readiness summary terminal-over-diagnostic posture matches"

  grep -Fq "Generated outputs, proposal-local inputs, raw inputs, postmortem reports, and readiness summaries are not runtime, policy, support, closeout, publication, redesign, or lifecycle-transition authority." "$file" \
    && pass "readiness summary carries full authority boundary" \
    || fail "readiness summary must carry full authority boundary"
}

validate_structured_output() {
  local file="$1"
  [[ -f "$file" ]] || { fail "structured output missing: ${file#$ROOT_DIR/}"; return; }
  yq -e '.' "$file" >/dev/null 2>&1 && pass "structured output parses as YAML" || fail "structured output must parse as YAML"

  [[ "$(yq_scalar '.schema_version' "$file")" == "lifecycle-postmortem-evaluation-v2" ]] \
    && pass "schema_version is lifecycle-postmortem-evaluation-v2" \
    || fail "schema_version must be lifecycle-postmortem-evaluation-v2"

  local subject_run lifecycle_kind final_judgment octon_subject
  subject_run="$(yq_scalar '.subject.run_id' "$file")"
  lifecycle_kind="$(yq_scalar '.subject.lifecycle_kind' "$file")"
  octon_subject="$(yq -r '.subject.octon_subject // "false"' "$file")"
  final_judgment="$(yq_scalar '.final_judgment' "$file")"

  non_empty "$subject_run" && pass "subject run id present" || fail "subject.run_id required"
  non_empty "$lifecycle_kind" && pass "lifecycle kind present" || fail "subject.lifecycle_kind required"
  allowed_final_judgment "$final_judgment" && pass "final judgment allowed" || fail "invalid final judgment: $final_judgment"

  require_top_level_sections "$file"
  validate_input_context_and_posture "$file"
  validate_core_sections "$file"
  validate_summary_final_judgment "$file"
  validate_alternative_paths "$file"
  validate_redesign_triggers "$file"
  validate_quality_scoring "$file" "$octon_subject"
  validate_octon_invariants "$file" "$octon_subject"
  validate_octon_fit_gating "$file" "$octon_subject" "$final_judgment"
  validate_major_findings "$file"
  validate_closeout "$file"
  validate_authority_boundary "$file"
  validate_evidence_refs "$file"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --structured-output|--structured)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      STRUCTURED_OUTPUT="$(repo_path "$1")"
      ;;
    --report)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      REPORT_PATH="$(repo_path "$1")"
      ;;
    --review-findings)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      REVIEW_FINDINGS="$(repo_path "$1")"
      ;;
    --evidence-map)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      EVIDENCE_MAP="$(repo_path "$1")"
      ;;
    --known-limits)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      KNOWN_LIMITS="$(repo_path "$1")"
      ;;
    --readiness-summary)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      READINESS_SUMMARY="$(repo_path "$1")"
      ;;
    --run-id)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      RUN_ID="$1"
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

if [[ -z "$STRUCTURED_OUTPUT" && -n "$RUN_ID" ]]; then
  STRUCTURED_OUTPUT="$ROOT_DIR/.octon/state/evidence/runs/$RUN_ID/assurance/lifecycle-postmortem/evaluation.yml"
fi
if [[ -z "$REPORT_PATH" && -n "$RUN_ID" ]]; then
  REPORT_PATH="$ROOT_DIR/.octon/state/evidence/runs/$RUN_ID/assurance/lifecycle-postmortem/report.md"
fi
if [[ -z "$EVIDENCE_MAP" && -n "$RUN_ID" ]]; then
  EVIDENCE_MAP="$ROOT_DIR/.octon/state/evidence/runs/$RUN_ID/assurance/lifecycle-postmortem/evidence-map.yml"
fi
if [[ -z "$KNOWN_LIMITS" && -n "$RUN_ID" ]]; then
  KNOWN_LIMITS="$ROOT_DIR/.octon/state/evidence/runs/$RUN_ID/assurance/lifecycle-postmortem/known-limits.yml"
fi
if [[ -z "$READINESS_SUMMARY" && -n "$RUN_ID" ]]; then
  READINESS_SUMMARY="$ROOT_DIR/.octon/state/evidence/runs/$RUN_ID/assurance/lifecycle-postmortem/readiness-summary.md"
fi

if [[ -z "$STRUCTURED_OUTPUT" && -z "$EVIDENCE_MAP" ]]; then
  usage >&2
  exit 2
fi

require_cmd yq
require_cmd jq
if [[ -n "$STRUCTURED_OUTPUT" ]]; then
  validate_structured_output "$STRUCTURED_OUTPUT"
fi
if [[ -n "$REPORT_PATH" ]]; then
  validate_report "$REPORT_PATH"
fi
if [[ -n "$REVIEW_FINDINGS" ]]; then
  validate_review_findings "$REVIEW_FINDINGS"
fi
if [[ -n "$EVIDENCE_MAP" ]]; then
  validate_evidence_map "$EVIDENCE_MAP"
fi
if [[ -n "$KNOWN_LIMITS" ]]; then
  validate_known_limits "$KNOWN_LIMITS"
fi
if [[ -n "$READINESS_SUMMARY" ]]; then
  validate_readiness_summary "$READINESS_SUMMARY" "$EVIDENCE_MAP" "$KNOWN_LIMITS"
fi

echo "Validation summary: errors=$errors"
[[ "$errors" -eq 0 ]]
