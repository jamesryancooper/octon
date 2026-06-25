#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
FRAMEWORK_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
OCTON_DIR="$(cd -- "$FRAMEWORK_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"
source "$SCRIPT_DIR/validator-recovery-diagnostics.sh"

PROGRAM_PATH=""
errors=0
warnings=0

STANDARD_SCRIPT="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh"
READINESS_SCRIPT="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh"
REVIEW_GATE_SCRIPT="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh"
RETAINED_INDEX_SCRIPT="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-retained-run-evidence-index.sh"

declare -A CHILD_PATHS=()
declare -A CHILD_REQUIRED=()
declare -A CHILD_DEFERRED=()
declare -A CHILD_READY=()
declare -A CHILD_DEPENDENCIES=()
declare -A CHILD_SEEN=()

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

warn() {
  echo "[WARN] $1"
  warnings=$((warnings + 1))
}

pass() {
  echo "[OK] $1"
}

child_readiness_rerun_gate() {
  printf 'validate-proposal-program-child-readiness.sh --package %s\n' "$PROGRAM_PATH"
}

child_readiness_repo_rel() {
  local path="$1"
  case "$path" in
    "$ROOT_DIR"/*)
      printf '%s\n' "${path#$ROOT_DIR/}"
      ;;
    *)
      printf '%s\n' "$path"
      ;;
  esac
}

usage() {
  cat <<'EOF'
usage:
  validate-proposal-program-child-readiness.sh --package <program-packet-path>
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --package)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      PROGRAM_PATH="$1"
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
  shift
done

[[ -n "$PROGRAM_PATH" ]] || { usage >&2; exit 2; }

if [[ "$PROGRAM_PATH" = /* ]]; then
  PROGRAM_DIR="$PROGRAM_PATH"
else
  PROGRAM_DIR="$ROOT_DIR/$PROGRAM_PATH"
fi

REGISTRY="$PROGRAM_DIR/resources/child-packet-index.yml"

safe_rel_path() {
  local value="$1"
  [[ -n "$value" \
    && "$value" != /* \
    && "$value" != "." \
    && "$value" != ./* \
    && "$value" != */./* \
    && "$value" != */. \
    && "$value" != *"../"* \
    && "$value" != ../* \
    && "$value" != *"/.." \
    && "$value" != ".." ]]
}

valid_child_id() {
  [[ "$1" =~ ^[a-z][a-z0-9-]*$ ]]
}

contains_id() {
  local haystack="$1" needle="$2" item
  for item in $haystack; do
    [[ "$item" == "$needle" ]] && return 0
  done
  return 1
}

child_abs_path() {
  local rel="$1"
  local active="$ROOT_DIR/$rel"
  if [[ -d "$active" ]]; then
    printf '%s\n' "$active"
    return 0
  fi
  case "$rel" in
    .octon/inputs/exploratory/proposals/*/*)
      local suffix archive manifest original_path
      suffix="${rel#.octon/inputs/exploratory/proposals/}"
      archive="$ROOT_DIR/.octon/inputs/exploratory/proposals/.archive/$suffix"
      manifest="$archive/proposal.yml"
      original_path="$(yq -r '.archive.original_path // ""' "$manifest" 2>/dev/null || true)"
      if [[ -d "$archive" && "$original_path" == "$rel" ]]; then
        printf '%s\n' "$archive"
        return 0
      fi
      ;;
  esac
  printf '%s\n' "$active"
}

repo_rel_path() {
  local abs="$1"
  case "$abs" in
    "$ROOT_DIR"/*)
      printf '%s\n' "${abs#$ROOT_DIR/}"
      ;;
    *)
      printf '%s\n' "$abs"
      ;;
  esac
}

run_child_validator() {
  local label="$1"
  shift
  local output rc=0
  output="$("$@" 2>&1)" || rc=$?
  if [[ "$rc" -eq 0 ]]; then
    pass "$label"
  else
    emit_recovery_diagnostic \
      --recovery-class "child_readiness_gate_failed" \
      --failing-path "$label" \
      --observed-value "$output" \
      --minimal-repair-hint "inspect the child validator output, repair the child packet gate, and rerun child-readiness validation" \
      --rerun-gate "$(child_readiness_rerun_gate)"
    fail "$label"
    printf '%s\n' "$output"
  fi
}

require_existing_ref() {
  local label="$1" ref="$2"
  if ! safe_rel_path "$ref"; then
    fail "$label is repo-relative: $ref"
  elif [[ -e "$ROOT_DIR/$ref" ]]; then
    pass "$label exists: $ref"
  else
    emit_recovery_diagnostic \
      --recovery-class "child_registry_error" \
      --failing-path "$label" \
      --observed-value "$ref" \
      --minimal-repair-hint "point the child registry reference at an existing repo-relative artifact" \
      --rerun-gate "$(child_readiness_rerun_gate)"
    fail "$label exists: $ref"
  fi
}

require_review_mentions() {
  local child_id="$1" child_abs="$2" phrase="$3"
  local completeness_review="$child_abs/support/implementation-grade-completeness-review.md"
  local proposal_review="$child_abs/support/proposal-review.md"
  if grep -Fqi -- "$phrase" "$completeness_review" "$proposal_review" 2>/dev/null; then
    pass "child $child_id readiness evidence mentions: $phrase"
  else
    emit_recovery_diagnostic \
      --recovery-class "child_readiness_evidence_gap" \
      --failing-path "$(child_readiness_repo_rel "$child_abs")/support" \
      --observed-value "$phrase" \
      --minimal-repair-hint "update child readiness/review evidence so it mentions the required phrase" \
      --rerun-gate "$(child_readiness_rerun_gate)"
    fail "child $child_id readiness evidence mentions: $phrase"
  fi
}

child_is_archived_implemented() {
  local manifest="$1"
  [[ "$(yq -r '.status // ""' "$manifest" 2>/dev/null || true)" == "archived" \
    && "$(yq -r '.archive.archived_from_status // ""' "$manifest" 2>/dev/null || true)" == "implemented" \
    && "$(yq -r '.archive.disposition // ""' "$manifest" 2>/dev/null || true)" == "implemented" ]]
}

child_is_implemented() {
  local manifest="$1"
  [[ "$(yq -r '.status // ""' "$manifest" 2>/dev/null || true)" == "implemented" ]]
}

receipt_field_equals() {
  local file="$1" field="$2" expected="$3"
  [[ -f "$file" ]] && grep -Eq "^${field}:[[:space:]]*\"?${expected}\"?[[:space:]]*$" "$file"
}

validation_receipt_records_pass() {
  local file="$1" table_rows
  [[ -f "$file" ]] || return 1
  if receipt_field_equals "$file" verdict pass; then
    return 0
  fi
  if grep -Eiq 'All listed commands exited successfully\.?' "$file"; then
    return 0
  fi
  table_rows="$(grep -E '^\|[[:space:]]*`[^`]+`[[:space:]]*\|[[:space:]]*[^|]+[[:space:]]*\|' "$file" || true)"
  if [[ -z "$table_rows" ]]; then
    return 1
  fi
  if grep -Eiq '\|[[:space:]]*(fail|failed|error|blocked)[[:space:]]*\|' <<<"$table_rows"; then
    return 1
  fi
  grep -Eiq '\|[[:space:]]*pass[[:space:]]*\|' <<<"$table_rows"
}

validate_implemented_child_ready() {
  local child_id="$1" child_abs="$2"

  receipt_field_equals "$child_abs/support/implementation-run.md" verdict pass \
    && pass "child $child_id implemented implementation-run receipt passes" \
    || fail "child $child_id implemented implementation-run receipt passes"
  receipt_field_equals "$child_abs/support/implementation-conformance-review.md" verdict pass \
    && pass "child $child_id implemented conformance receipt passes" \
    || fail "child $child_id implemented conformance receipt passes"
  receipt_field_equals "$child_abs/support/post-implementation-drift-churn-review.md" verdict pass \
    && pass "child $child_id implemented post-implementation drift receipt passes" \
    || fail "child $child_id implemented post-implementation drift receipt passes"
}

validate_archived_implemented_child_ready() {
  local child_id="$1" child_abs="$2" index="$3" manifest="$child_abs/proposal.yml"
  local promotion_evidence_count evidence_index_count ref ref_index

  if child_is_archived_implemented "$manifest"; then
    pass "child $child_id archive metadata records implemented disposition"
  else
    fail "child $child_id archive metadata records implemented disposition"
  fi

  promotion_evidence_count="$(yq -r '(.archive.promotion_evidence // []) | length' "$manifest" 2>/dev/null || echo 0)"
  if [[ "$promotion_evidence_count" =~ ^[1-9][0-9]*$ ]]; then
    pass "child $child_id archive metadata records promotion evidence"
  else
    fail "child $child_id archive metadata records promotion evidence"
  fi

  receipt_field_equals "$child_abs/support/implementation-run.md" verdict pass \
    && pass "child $child_id archived implementation-run receipt passes" \
    || fail "child $child_id archived implementation-run receipt passes"
  receipt_field_equals "$child_abs/support/implementation-conformance-review.md" verdict pass \
    && pass "child $child_id archived implementation conformance receipt passes" \
    || fail "child $child_id archived implementation conformance receipt passes"
  receipt_field_equals "$child_abs/support/post-implementation-drift-churn-review.md" verdict pass \
    && pass "child $child_id archived post-implementation drift receipt passes" \
    || fail "child $child_id archived post-implementation drift receipt passes"
  receipt_field_equals "$child_abs/support/proposal-closeout.md" verdict pass \
    && pass "child $child_id archived closeout receipt passes" \
    || fail "child $child_id archived closeout receipt passes"
  receipt_field_equals "$child_abs/support/proposal-closeout.md" archive_authorized yes \
    && pass "child $child_id archived closeout authorizes archive" \
    || fail "child $child_id archived closeout authorizes archive"
  receipt_field_equals "$child_abs/support/proposal-terminal-closeout.yml" terminal_verdict archive-ready \
    && pass "child $child_id archived terminal closeout records archive-ready verdict" \
    || fail "child $child_id archived terminal closeout records archive-ready verdict"
  receipt_field_equals "$child_abs/support/proposal-terminal-closeout.yml" archive_ready yes \
    && pass "child $child_id archived terminal closeout records archive_ready" \
    || fail "child $child_id archived terminal closeout records archive_ready"
  validation_receipt_records_pass "$child_abs/support/validation.md" \
    && pass "child $child_id archived validation receipt passes" \
    || fail "child $child_id archived validation receipt passes"

  evidence_index_count="$(yq -r "(.children[$index].evidence_index_refs // []) | length" "$REGISTRY" 2>/dev/null || echo 0)"
  if [[ "$evidence_index_count" -eq 0 ]]; then
    warn "child $child_id archived terminal evidence has no registry evidence_index_refs"
  else
    for ((ref_index=0; ref_index<evidence_index_count; ref_index++)); do
      ref="$(yq -r ".children[$index].evidence_index_refs[$ref_index] // \"\"" "$REGISTRY" 2>/dev/null || true)"
      require_existing_ref "child $child_id retained evidence index ref" "$ref"
      run_child_validator \
        "child $child_id retained evidence index validates: $ref" \
        bash "$RETAINED_INDEX_SCRIPT" --index "$ref"
    done
  fi
}

validate_child_metadata() {
  local child_id="$1" child_abs="$2" manifest="$child_abs/proposal.yml"
  local change_profile transitional_note
  change_profile="$(yq -r '.change_profile // ""' "$manifest" 2>/dev/null || true)"
  case "$change_profile" in
    atomic|transitional)
      pass "child $child_id declares change_profile"
      ;;
    "")
      if child_is_archived_implemented "$manifest"; then
        pass "child $child_id archived implemented child satisfies change_profile gate"
      elif child_is_implemented "$manifest"; then
        pass "child $child_id implemented child satisfies change_profile gate"
      else
        fail "child $child_id declares change_profile"
      fi
      ;;
    *)
      fail "child $child_id change_profile is atomic or transitional"
      ;;
  esac
  if [[ "$change_profile" == "transitional" ]]; then
    transitional_note="$(yq -r '.transitional_exception_note // ""' "$manifest" 2>/dev/null || true)"
    [[ -n "$transitional_note" ]] \
      && pass "child $child_id transitional change_profile has exception note" \
      || fail "child $child_id transitional change_profile has exception note"
  fi
}

validate_child_readiness() {
  local index="$1" child_id="$2" child_path="$3"
  local child_abs child_validation_path manifest required_metadata_count metadata requirement_count requirement_id mention_count mention
  child_abs="$(child_abs_path "$child_path")"
  child_validation_path="$(repo_rel_path "$child_abs")"
  manifest="$child_abs/proposal.yml"

  if [[ ! -d "$child_abs" ]]; then
    emit_hard_blocker_recovery_diagnostic \
      "$(child_readiness_repo_rel "$child_abs")" \
      "required child packet directory is missing" \
      "$(child_readiness_rerun_gate)"
    fail "child $child_id packet directory exists"
    return 0
  fi
  if [[ ! -f "$manifest" ]]; then
    emit_hard_blocker_recovery_diagnostic \
      "$(child_readiness_repo_rel "$manifest")" \
      "required child proposal manifest is missing" \
      "$(child_readiness_rerun_gate)"
    fail "child $child_id proposal manifest exists"
    return 0
  fi

  run_child_validator \
    "child $child_id proposal standard passes" \
    bash "$STANDARD_SCRIPT" --package "$child_validation_path" --skip-registry-check --skip-promotion-target-checks
  validate_child_metadata "$child_id" "$child_abs"
  run_child_validator \
    "child $child_id implementation-grade completeness review passes" \
    bash "$READINESS_SCRIPT" --package "$child_validation_path"
  if child_is_archived_implemented "$manifest"; then
    validate_archived_implemented_child_ready "$child_id" "$child_abs" "$index"
  elif child_is_implemented "$manifest"; then
    run_child_validator \
      "child $child_id implemented proposal-review evidence is preserved" \
      bash "$REVIEW_GATE_SCRIPT" --package "$child_validation_path"
    validate_implemented_child_ready "$child_id" "$child_abs"
  else
    run_child_validator \
      "child $child_id accepted proposal-review gate is fresh" \
      bash "$REVIEW_GATE_SCRIPT" --package "$child_validation_path" --require-implementation-authorization
  fi

  required_metadata_count="$(yq -r "(.children[$index].required_metadata // []) | length" "$REGISTRY" 2>/dev/null || echo 0)"
  for ((metadata_index=0; metadata_index<required_metadata_count; metadata_index++)); do
    metadata="$(yq -r ".children[$index].required_metadata[$metadata_index] // \"\"" "$REGISTRY" 2>/dev/null || true)"
    case "$metadata" in
      change_profile)
        if [[ "$(yq -r '.change_profile // ""' "$manifest" 2>/dev/null || true)" == "" ]] \
          && child_is_archived_implemented "$manifest"; then
          pass "child $child_id required metadata satisfied by archived implemented terminal evidence: change_profile"
        elif [[ "$(yq -r '.change_profile // ""' "$manifest" 2>/dev/null || true)" == "" ]] \
          && child_is_implemented "$manifest"; then
          pass "child $child_id required metadata satisfied by implemented evidence: change_profile"
        else
          pass "child $child_id declared required metadata is enforced: change_profile"
        fi
        ;;
      *)
        emit_recovery_diagnostic \
          --recovery-class "child_registry_error" \
          --failing-path "$(child_readiness_repo_rel "$REGISTRY")#children[$index].required_metadata" \
          --observed-value "$metadata" \
          --accepted-values "change_profile" \
          --minimal-repair-hint "use only supported required_metadata values" \
          --rerun-gate "$(child_readiness_rerun_gate)"
        fail "child $child_id required_metadata is supported: $metadata"
        ;;
    esac
  done

  while IFS= read -r ref; do
    [[ -n "$ref" ]] || continue
    require_existing_ref "child $child_id source lineage ref" "$ref"
  done < <(yq -r ".children[$index].source_lineage_refs[]? // \"\"" "$REGISTRY" 2>/dev/null || true)

  while IFS= read -r ref; do
    [[ -n "$ref" ]] || continue
    require_existing_ref "child $child_id parent contract ref" "$ref"
  done < <(yq -r ".children[$index].parent_contract_refs[]? // \"\"" "$REGISTRY" 2>/dev/null || true)

  requirement_count="$(yq -r "(.children[$index].readiness_requirements // []) | length" "$REGISTRY" 2>/dev/null || echo 0)"
  for ((requirement_index=0; requirement_index<requirement_count; requirement_index++)); do
    requirement_id="$(yq -r ".children[$index].readiness_requirements[$requirement_index].requirement_id // \"\"" "$REGISTRY" 2>/dev/null || true)"
    if valid_child_id "$requirement_id"; then
      pass "child $child_id readiness requirement id valid: $requirement_id"
    else
      fail "child $child_id readiness requirement id valid: $requirement_id"
    fi
    mention_count="$(yq -r "(.children[$index].readiness_requirements[$requirement_index].review_must_mention // []) | length" "$REGISTRY" 2>/dev/null || echo 0)"
    if [[ "$mention_count" -eq 0 ]]; then
      require_review_mentions "$child_id" "$child_abs" "$requirement_id"
    else
      for ((mention_index=0; mention_index<mention_count; mention_index++)); do
        mention="$(yq -r ".children[$index].readiness_requirements[$requirement_index].review_must_mention[$mention_index] // \"\"" "$REGISTRY" 2>/dev/null || true)"
        require_review_mentions "$child_id" "$child_abs" "$mention"
      done
    fi
  done
}

validate_cross_packet_constraints() {
  local index="$1" child_id="$2" predecessor_count successor_count cutover_requires predecessor required_predecessors
  local predecessor_id successor_id successor_dependencies

  predecessor_count="$(yq -r "(.children[$index].predecessor_constraints // []) | length" "$REGISTRY" 2>/dev/null || echo 0)"
  for ((constraint_index=0; constraint_index<predecessor_count; constraint_index++)); do
    predecessor_id="$(yq -r ".children[$index].predecessor_constraints[$constraint_index].predecessor_child_id // \"\"" "$REGISTRY" 2>/dev/null || true)"
    if [[ -z "${CHILD_SEEN[$predecessor_id]:-}" ]]; then
      emit_recovery_diagnostic \
        --recovery-class "child_registry_error" \
        --failing-path "$(child_readiness_repo_rel "$REGISTRY")#children[$index].predecessor_constraints" \
        --observed-value "$predecessor_id" \
        --minimal-repair-hint "reference an existing predecessor child_id" \
        --rerun-gate "$(child_readiness_rerun_gate)"
      fail "child $child_id predecessor constraint references existing child: $predecessor_id"
    elif contains_id "${CHILD_DEPENDENCIES[$child_id]:-}" "$predecessor_id"; then
      pass "child $child_id predecessor constraint is reflected in dependencies: $predecessor_id"
    else
      fail "child $child_id predecessor constraint is reflected in dependencies: $predecessor_id"
    fi
  done

  successor_count="$(yq -r "(.children[$index].successor_constraints // []) | length" "$REGISTRY" 2>/dev/null || echo 0)"
  for ((constraint_index=0; constraint_index<successor_count; constraint_index++)); do
    successor_id="$(yq -r ".children[$index].successor_constraints[$constraint_index].successor_child_id // \"\"" "$REGISTRY" 2>/dev/null || true)"
    successor_dependencies="${CHILD_DEPENDENCIES[$successor_id]:-}"
    if [[ -z "${CHILD_SEEN[$successor_id]:-}" ]]; then
      emit_recovery_diagnostic \
        --recovery-class "child_registry_error" \
        --failing-path "$(child_readiness_repo_rel "$REGISTRY")#children[$index].successor_constraints" \
        --observed-value "$successor_id" \
        --minimal-repair-hint "reference an existing successor child_id" \
        --rerun-gate "$(child_readiness_rerun_gate)"
      fail "child $child_id successor constraint references existing child: $successor_id"
    elif contains_id "$successor_dependencies" "$child_id"; then
      pass "child $child_id successor constraint is reflected in successor dependencies: $successor_id"
    else
      fail "child $child_id successor constraint is reflected in successor dependencies: $successor_id"
    fi
  done

  cutover_requires="$(yq -r "(.children[$index].cutover_constraints.compatibility_retirement_requires_predecessor_evidence // false) or (.children[$index].cutover_constraints.canonical_runtime_support_requires_predecessor_evidence // false)" "$REGISTRY" 2>/dev/null || echo false)"
  [[ "$cutover_requires" == "true" ]] || return 0

  required_predecessors="$(yq -r ".children[$index].cutover_constraints.required_predecessor_child_ids[]? // \"\"" "$REGISTRY" 2>/dev/null | awk 'NF' || true)"
  if [[ -z "$required_predecessors" ]]; then
    required_predecessors="${CHILD_DEPENDENCIES[$child_id]:-}"
  fi
  if [[ -z "$required_predecessors" ]]; then
    fail "child $child_id cutover constraints declare predecessor evidence"
    return 0
  fi
  for predecessor in $required_predecessors; do
    if [[ -z "${CHILD_SEEN[$predecessor]:-}" ]]; then
      fail "child $child_id cutover predecessor exists: $predecessor"
    elif [[ "${CHILD_READY[$predecessor]:-0}" == "1" ]]; then
      pass "child $child_id cutover predecessor is proposal-ready: $predecessor"
    else
      fail "child $child_id cutover predecessor is proposal-ready: $predecessor"
    fi
  done
}

if [[ ! -d "$PROGRAM_DIR" ]]; then
  emit_hard_blocker_recovery_diagnostic \
    "$(child_readiness_repo_rel "$PROGRAM_DIR")" \
    "program packet directory is missing" \
    "$(child_readiness_rerun_gate)"
  fail "program packet exists"
  echo "Validation summary: errors=$errors warnings=$warnings"
  exit 1
fi

if [[ ! -f "$REGISTRY" ]]; then
  emit_hard_blocker_recovery_diagnostic \
    "$(child_readiness_repo_rel "$REGISTRY")" \
    "program child registry is missing" \
    "$(child_readiness_rerun_gate)"
  fail "program child registry exists"
  echo "Validation summary: errors=$errors warnings=$warnings"
  exit 1
fi

if yq -e '.' "$REGISTRY" >/dev/null 2>&1; then
  pass "program child registry parses"
else
  emit_recovery_diagnostic \
    --recovery-class "invalid_yaml" \
    --failing-path "$(child_readiness_repo_rel "$REGISTRY")" \
    --minimal-repair-hint "repair child-packet-index.yml YAML syntax" \
    --rerun-gate "$(child_readiness_rerun_gate)"
  fail "program child registry parses"
  echo "Validation summary: errors=$errors warnings=$warnings"
  exit 1
fi

child_count="$(yq -r '(.children // []) | length' "$REGISTRY" 2>/dev/null || echo 0)"
if [[ "$child_count" =~ ^[1-9][0-9]*$ ]]; then
  pass "program child registry declares children"
else
  emit_recovery_diagnostic \
    --recovery-class "child_registry_error" \
    --failing-path "$(child_readiness_repo_rel "$REGISTRY")#children" \
    --observed-value "$child_count" \
    --minimal-repair-hint "declare at least one child in resources/child-packet-index.yml" \
    --rerun-gate "$(child_readiness_rerun_gate)"
  fail "program child registry declares children"
fi

for ((index=0; index<child_count; index++)); do
  child_id="$(yq -r ".children[$index].child_id // \"\"" "$REGISTRY" 2>/dev/null || true)"
  child_path="$(yq -r ".children[$index].path // \"\"" "$REGISTRY" 2>/dev/null || true)"
  required="$(yq -r ".children[$index].required // true" "$REGISTRY" 2>/dev/null || true)"
  deferred="$(yq -r ".children[$index].deferred // false" "$REGISTRY" 2>/dev/null || true)"
  dependencies="$(yq -r ".children[$index].dependencies[]? // \"\"" "$REGISTRY" 2>/dev/null | awk 'NF' || true)"

  valid_child_id "$child_id" && pass "child id valid: $child_id" || {
    emit_recovery_diagnostic \
      --recovery-class "child_registry_error" \
      --failing-path "$(child_readiness_repo_rel "$REGISTRY")#children[$index].child_id" \
      --observed-value "$child_id" \
      --minimal-repair-hint "use a child_id matching ^[a-z][a-z0-9-]*$" \
      --rerun-gate "$(child_readiness_rerun_gate)"
    fail "child id valid: $child_id"
  }
  if [[ -n "${CHILD_SEEN[$child_id]:-}" ]]; then
    emit_recovery_diagnostic \
      --recovery-class "child_registry_error" \
      --failing-path "$(child_readiness_repo_rel "$REGISTRY")#children[$index].child_id" \
      --observed-value "$child_id" \
      --minimal-repair-hint "make every child_id unique in resources/child-packet-index.yml" \
      --rerun-gate "$(child_readiness_rerun_gate)"
    fail "child id unique: $child_id"
  else
    CHILD_SEEN["$child_id"]=1
    pass "child id unique: $child_id"
  fi
  safe_rel_path "$child_path" && pass "child $child_id path is repo-relative" || {
    emit_recovery_diagnostic \
      --recovery-class "child_registry_error" \
      --failing-path "$(child_readiness_repo_rel "$REGISTRY")#children[$index].path" \
      --observed-value "$child_path" \
      --minimal-repair-hint "set child path to a safe repo-relative proposal packet path" \
      --rerun-gate "$(child_readiness_rerun_gate)"
    fail "child $child_id path is repo-relative"
  }

  CHILD_PATHS["$child_id"]="$child_path"
  CHILD_REQUIRED["$child_id"]="$required"
  CHILD_DEFERRED["$child_id"]="$deferred"
  CHILD_DEPENDENCIES["$child_id"]="$dependencies"
done

for ((index=0; index<child_count; index++)); do
  child_id="$(yq -r ".children[$index].child_id // \"\"" "$REGISTRY" 2>/dev/null || true)"
  [[ "${CHILD_REQUIRED[$child_id]:-true}" == "true" && "${CHILD_DEFERRED[$child_id]:-false}" != "true" ]] || {
    CHILD_READY["$child_id"]=0
    continue
  }
  before_errors="$errors"
  validate_child_readiness "$index" "$child_id" "${CHILD_PATHS[$child_id]}"
  if [[ "$errors" -eq "$before_errors" ]]; then
    CHILD_READY["$child_id"]=1
  else
    CHILD_READY["$child_id"]=0
  fi
done

for ((index=0; index<child_count; index++)); do
  child_id="$(yq -r ".children[$index].child_id // \"\"" "$REGISTRY" 2>/dev/null || true)"
  [[ "${CHILD_REQUIRED[$child_id]:-true}" == "true" && "${CHILD_DEFERRED[$child_id]:-false}" != "true" ]] || continue
  validate_cross_packet_constraints "$index" "$child_id"
done

pass "proposal readiness check does not require implementation receipts"

echo "Validation summary: errors=$errors warnings=$warnings"
[[ "$errors" -eq 0 ]]
