#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
FRAMEWORK_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
OCTON_DIR="$(cd -- "$FRAMEWORK_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

PROGRAM_PATH=""
errors=0
warnings=0

STANDARD_SCRIPT="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh"
READINESS_SCRIPT="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh"
REVIEW_GATE_SCRIPT="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh"

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
  printf '%s/%s\n' "$ROOT_DIR" "$rel"
}

run_child_validator() {
  local label="$1"
  shift
  local output rc=0
  output="$("$@" 2>&1)" || rc=$?
  if [[ "$rc" -eq 0 ]]; then
    pass "$label"
  else
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
    fail "child $child_id readiness evidence mentions: $phrase"
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
      fail "child $child_id declares change_profile"
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
  local child_abs manifest required_metadata_count metadata requirement_count requirement_id mention_count mention
  child_abs="$(child_abs_path "$child_path")"
  manifest="$child_abs/proposal.yml"

  if [[ ! -d "$child_abs" ]]; then
    fail "child $child_id packet directory exists"
    return 0
  fi
  if [[ ! -f "$manifest" ]]; then
    fail "child $child_id proposal manifest exists"
    return 0
  fi

  run_child_validator \
    "child $child_id proposal standard passes" \
    bash "$STANDARD_SCRIPT" --package "$child_path" --skip-registry-check --skip-promotion-target-checks
  validate_child_metadata "$child_id" "$child_abs"
  run_child_validator \
    "child $child_id implementation-grade completeness review passes" \
    bash "$READINESS_SCRIPT" --package "$child_path"
  run_child_validator \
    "child $child_id accepted proposal-review gate is fresh" \
    bash "$REVIEW_GATE_SCRIPT" --package "$child_path" --require-implementation-authorization

  required_metadata_count="$(yq -r "(.children[$index].required_metadata // []) | length" "$REGISTRY" 2>/dev/null || echo 0)"
  for ((metadata_index=0; metadata_index<required_metadata_count; metadata_index++)); do
    metadata="$(yq -r ".children[$index].required_metadata[$metadata_index] // \"\"" "$REGISTRY" 2>/dev/null || true)"
    case "$metadata" in
      change_profile)
        pass "child $child_id declared required metadata is enforced: change_profile"
        ;;
      *)
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
  fail "program packet exists"
  echo "Validation summary: errors=$errors warnings=$warnings"
  exit 1
fi

if [[ ! -f "$REGISTRY" ]]; then
  fail "program child registry exists"
  echo "Validation summary: errors=$errors warnings=$warnings"
  exit 1
fi

if yq -e '.' "$REGISTRY" >/dev/null 2>&1; then
  pass "program child registry parses"
else
  fail "program child registry parses"
  echo "Validation summary: errors=$errors warnings=$warnings"
  exit 1
fi

child_count="$(yq -r '(.children // []) | length' "$REGISTRY" 2>/dev/null || echo 0)"
if [[ "$child_count" =~ ^[1-9][0-9]*$ ]]; then
  pass "program child registry declares children"
else
  fail "program child registry declares children"
fi

for ((index=0; index<child_count; index++)); do
  child_id="$(yq -r ".children[$index].child_id // \"\"" "$REGISTRY" 2>/dev/null || true)"
  child_path="$(yq -r ".children[$index].path // \"\"" "$REGISTRY" 2>/dev/null || true)"
  required="$(yq -r ".children[$index].required // true" "$REGISTRY" 2>/dev/null || true)"
  deferred="$(yq -r ".children[$index].deferred // false" "$REGISTRY" 2>/dev/null || true)"
  dependencies="$(yq -r ".children[$index].dependencies[]? // \"\"" "$REGISTRY" 2>/dev/null | awk 'NF' || true)"

  valid_child_id "$child_id" && pass "child id valid: $child_id" || fail "child id valid: $child_id"
  if [[ -n "${CHILD_SEEN[$child_id]:-}" ]]; then
    fail "child id unique: $child_id"
  else
    CHILD_SEEN["$child_id"]=1
    pass "child id unique: $child_id"
  fi
  safe_rel_path "$child_path" && pass "child $child_id path is repo-relative" || fail "child $child_id path is repo-relative"

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
