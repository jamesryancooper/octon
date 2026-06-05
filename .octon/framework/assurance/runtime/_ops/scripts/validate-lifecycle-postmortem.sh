#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

STRUCTURED_OUTPUT=""
REPORT_PATH=""
REVIEW_FINDINGS=""
RUN_ID=""
errors=0

usage() {
  cat <<'USAGE'
usage:
  validate-lifecycle-postmortem.sh --structured-output <path> [--report <path>] [--review-findings <path>] [--run-id <id>]
  validate-lifecycle-postmortem.sh --structured <path> [--report <path>] [--review-findings <path>] [--run-id <id>]
  validate-lifecycle-postmortem.sh --run-id <id>

When only --run-id is provided, the validator reads:
  .octon/state/evidence/runs/<run-id>/assurance/lifecycle-postmortem/evaluation.yml
  .octon/state/evidence/runs/<run-id>/assurance/lifecycle-postmortem/report.md
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
  grep -n -F -- "## $heading" "$file" | head -1 | cut -d: -f1
}

validate_report() {
  local report="$1"
  [[ -f "$report" ]] || { fail "Markdown report missing: ${report#$ROOT_DIR/}"; return; }

  local required=(
    "Lifecycle Reconstruction"
    "Evidence Map"
    "Bad Implementation Versus Wrong Architecture"
    "Patch Versus Redesign Reasoning"
    "Redesign Triggers"
    "Invariant Evaluation"
    "Quality Scoring"
    "Root Cause Analysis"
    "Invariant Validity and Evolution Review"
    "Final Judgment"
    "Recommendations"
    "Non-Authority Statement"
  )
  local heading
  for heading in "${required[@]}"; do
    if grep -Fq -- "## $heading" "$report"; then
      pass "report section present: $heading"
    else
      fail "report missing required section: $heading"
    fi
  done

  local invariant_line quality_line redesign_line validity_line recommendation_line
  invariant_line="$(line_number_for_heading "$report" "Invariant Evaluation")"
  quality_line="$(line_number_for_heading "$report" "Quality Scoring")"
  redesign_line="$(line_number_for_heading "$report" "Redesign Triggers")"
  validity_line="$(line_number_for_heading "$report" "Invariant Validity and Evolution Review")"
  recommendation_line="$(line_number_for_heading "$report" "Recommendations")"

  if non_empty "$invariant_line" && non_empty "$quality_line" && [[ "$invariant_line" -lt "$quality_line" ]]; then
    pass "Invariant Evaluation appears before Quality Scoring"
  else
    fail "Invariant Evaluation must appear before Quality Scoring"
  fi

  if non_empty "$redesign_line" && non_empty "$validity_line" && non_empty "$recommendation_line" \
    && [[ "$redesign_line" -lt "$validity_line" && "$validity_line" -lt "$recommendation_line" ]]; then
    pass "Invariant Validity and Evolution Review is after Redesign Triggers and before Recommendations"
  else
    fail "Invariant Validity and Evolution Review must appear after Redesign Triggers and before Recommendations"
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
      yq -r '.invariant_compliance[].evidence_refs[]?' "$file"
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

validate_structured_output() {
  local file="$1"
  [[ -f "$file" ]] || { fail "structured output missing: ${file#$ROOT_DIR/}"; return; }
  yq -e '.' "$file" >/dev/null 2>&1 && pass "structured output parses as YAML" || fail "structured output must parse as YAML"

  [[ "$(yq -r '.schema_version // ""' "$file")" == "lifecycle-postmortem-evaluation-v1" ]] \
    && pass "schema_version is lifecycle-postmortem-evaluation-v1" \
    || fail "schema_version must be lifecycle-postmortem-evaluation-v1"

  local subject_run lifecycle_kind final_judgment octon_subject
  subject_run="$(yq -r '.subject.run_id // ""' "$file")"
  lifecycle_kind="$(yq -r '.subject.lifecycle_kind // ""' "$file")"
  octon_subject="$(yq -r '.subject.octon_subject // "false"' "$file")"
  final_judgment="$(yq -r '.final_judgment // ""' "$file")"

  non_empty "$subject_run" && pass "subject run id present" || fail "subject.run_id required"
  non_empty "$lifecycle_kind" && pass "lifecycle kind present" || fail "subject.lifecycle_kind required"
  allowed_final_judgment "$final_judgment" && pass "final judgment allowed" || fail "invalid final judgment: $final_judgment"

  yq -e '.authority_boundary.generated_outputs_authority == false' "$file" >/dev/null 2>&1 \
    && pass "generated outputs are non-authority" \
    || fail "generated outputs must not be authority"
  yq -e '.authority_boundary.raw_inputs_authority == false' "$file" >/dev/null 2>&1 \
    && pass "raw inputs are non-authority" \
    || fail "raw inputs must not be authority"
  yq -e '.authority_boundary.postmortem_approves_lifecycle_transition == false' "$file" >/dev/null 2>&1 \
    && pass "postmortem does not approve lifecycle transition" \
    || fail "postmortem must not approve lifecycle transition"
  yq -e '.authority_boundary.postmortem_approves_invariant_change == false' "$file" >/dev/null 2>&1 \
    && pass "postmortem does not approve invariant change" \
    || fail "postmortem must not approve invariant change"
  yq -e '.authority_boundary.non_authority_assertion == true' "$file" >/dev/null 2>&1 \
    && pass "non-authority assertion present" \
    || fail "non-authority assertion required"

  yq -e '.section_order.patch_vs_redesign_present == true' "$file" >/dev/null 2>&1 \
    && pass "patch-versus-redesign reasoning declared" \
    || fail "patch-versus-redesign reasoning required"

  validate_evidence_refs "$file"

  if [[ "$octon_subject" == "true" ]]; then
    validate_invariant_compliance "$file"
    validate_invariant_validity "$file"
  else
    pass "non-Octon subject does not require invariant sections"
  fi
}

validate_invariant_compliance() {
  local file="$1"
  local count index rating gap blocking required material counts_as_pass
  yq -e '.section_order.invariant_compliance_before_quality_scoring == true' "$file" >/dev/null 2>&1 \
    && pass "invariant compliance is before quality scoring" \
    || fail "invariant compliance must be before quality scoring"
  count="$(yq -r '.invariant_compliance | length // 0' "$file")"
  [[ "$count" -gt 0 ]] && pass "invariant compliance records present" || fail "Octon subject requires invariant compliance records"
  for ((index=0; index<count; index++)); do
    rating="$(yq -r ".invariant_compliance[$index].rating // \"\"" "$file")"
    gap="$(yq -r ".invariant_compliance[$index].evidence_gap // \"\"" "$file")"
    blocking="$(yq -r ".invariant_compliance[$index].blocking // \"false\"" "$file")"
    required="$(yq -r ".invariant_compliance[$index].required_correction // \"\"" "$file")"
    material="$(yq -r ".invariant_compliance[$index].material // \"false\"" "$file")"
    counts_as_pass="$(yq -r ".invariant_compliance[$index].counts_as_pass // \"false\"" "$file")"

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
  yq -e '.section_order.invariant_validity_after_redesign_pressure_before_recommendations == true' "$file" >/dev/null 2>&1 \
    && pass "invariant validity/evolution order declared" \
    || fail "invariant validity/evolution must be after redesign pressure and before recommendations"
  count="$(yq -r '.invariant_validity_evolution | length // 0' "$file")"
  [[ "$count" -gt 0 ]] && pass "invariant validity/evolution records present" || fail "Octon subject requires invariant validity/evolution records"
  for ((index=0; index<count; index++)); do
    recommendation="$(yq -r ".invariant_validity_evolution[$index].recommendation // \"\"" "$file")"
    required_change="$(yq -r ".invariant_validity_evolution[$index].required_change // \"\"" "$file")"
    bar="$(yq -r ".invariant_validity_evolution[$index].change_control_bar // \"\"" "$file")"
    status="$(yq -r ".invariant_validity_evolution[$index].authority_status // \"\"" "$file")"
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

if [[ -z "$STRUCTURED_OUTPUT" ]]; then
  usage >&2
  exit 2
fi

require_cmd yq
require_cmd jq
validate_structured_output "$STRUCTURED_OUTPUT"
if [[ -n "$REPORT_PATH" ]]; then
  validate_report "$REPORT_PATH"
fi
if [[ -n "$REVIEW_FINDINGS" ]]; then
  validate_review_findings "$REVIEW_FINDINGS"
fi

echo "Validation summary: errors=$errors"
[[ "$errors" -eq 0 ]]
