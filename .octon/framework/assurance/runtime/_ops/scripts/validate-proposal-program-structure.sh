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

program_structure_rerun_gate() {
  printf 'validate-proposal-program-structure.sh --package %s\n' "$PROGRAM_PATH"
}

program_structure_repo_rel() {
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
  validate-proposal-program-structure.sh --package <program-packet-path>
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
  if [[ "$PROGRAM_PATH" == "$ROOT_DIR/"* ]]; then
    PROGRAM_REL="${PROGRAM_PATH#$ROOT_DIR/}"
  else
    PROGRAM_REL="$(basename "$PROGRAM_PATH")"
  fi
else
  PROGRAM_DIR="$ROOT_DIR/$PROGRAM_PATH"
  PROGRAM_REL="$PROGRAM_PATH"
fi

MANIFEST="$PROGRAM_DIR/proposal.yml"
REGISTRY="$PROGRAM_DIR/resources/child-packet-index.yml"
HUMAN_INDEX="$PROGRAM_DIR/resources/child-packet-index.md"
SEQUENCE="$PROGRAM_DIR/architecture/packet-sequence.md"
CHILD_CONTRACT="$PROGRAM_DIR/architecture/child-packet-contract.md"
CLOSEOUT_PLAN="$PROGRAM_DIR/architecture/program-closeout-plan.md"

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

require_file() {
  local file="$1" label="$2"
  if [[ -f "$file" ]]; then
    pass "$label exists"
  else
    emit_recovery_diagnostic \
      --recovery-class "missing_required_file" \
      --failing-path "$(program_structure_repo_rel "$file")" \
      --minimal-repair-hint "create the required program packet artifact and rerun the structure gate" \
      --rerun-gate "$(program_structure_rerun_gate)"
    fail "$label exists"
  fi
}

require_yaml() {
  local file="$1" label="$2"
  if [[ -f "$file" ]] && yq -e '.' "$file" >/dev/null 2>&1; then
    pass "$label parses"
  else
    emit_recovery_diagnostic \
      --recovery-class "invalid_yaml" \
      --failing-path "$(program_structure_repo_rel "$file")" \
      --minimal-repair-hint "repair YAML syntax for the program packet artifact" \
      --rerun-gate "$(program_structure_rerun_gate)"
    fail "$label parses"
  fi
}

require_mentions_child_ids() {
  local file="$1" label="$2" id
  [[ -f "$file" ]] || return 0
  while IFS= read -r id; do
    [[ -n "$id" ]] || continue
    if grep -Fq -- "$id" "$file"; then
      pass "$label mentions child id: $id"
    else
      fail "$label mentions child id: $id"
    fi
  done < <(registry_child_ids)
}

registry_child_ids() {
  yq -r '.children[]?.child_id // ""' "$REGISTRY" 2>/dev/null | awk 'NF' | sort -u
}

related_child_ids() {
  {
    yq -r '.related_proposals[]? | select(tag == "!!str")' "$MANIFEST" 2>/dev/null || true
    yq -r '.related_proposals[]? | select(tag == "!!map") | (.proposal_id // .child_id // .id // "")' "$MANIFEST" 2>/dev/null || true
  } | awk 'NF' | sort -u
}

compare_registry_to_related_proposals() {
  local missing extra
  missing="$(comm -23 <(registry_child_ids) <(related_child_ids) || true)"
  extra="$(comm -13 <(registry_child_ids) <(related_child_ids) || true)"

  if [[ -z "$missing" ]]; then
    pass "related_proposals covers registry children"
  else
    emit_recovery_diagnostic \
      --recovery-class "child_registry_error" \
      --failing-path "$(program_structure_repo_rel "$MANIFEST")#related_proposals" \
      --observed-value "$missing" \
      --minimal-repair-hint "add every child-packet-index.yml child_id to proposal.yml related_proposals" \
      --rerun-gate "$(program_structure_rerun_gate)"
    fail "related_proposals covers registry children: ${missing//$'\n'/, }"
  fi

  if [[ -z "$extra" ]]; then
    pass "related_proposals contains no extra child ids"
  else
    emit_recovery_diagnostic \
      --recovery-class "child_registry_error" \
      --failing-path "$(program_structure_repo_rel "$MANIFEST")#related_proposals" \
      --observed-value "$extra" \
      --minimal-repair-hint "remove related_proposals entries that are not present in child-packet-index.yml" \
      --rerun-gate "$(program_structure_rerun_gate)"
    fail "related_proposals contains no extra child ids: ${extra//$'\n'/, }"
  fi
}

validate_no_nested_children() {
  local child_path="$1" child_id="$2"
  if [[ "$child_path" == "$PROGRAM_REL" || "$child_path" == "$PROGRAM_REL"/* ]]; then
    emit_hard_blocker_recovery_diagnostic \
      "$(program_structure_repo_rel "$REGISTRY")#children[$child_id].path" \
      "child packet path is nested under the parent program packet" \
      "$(program_structure_rerun_gate)" \
      "$child_path"
    fail "child $child_id path is not nested under parent program"
  else
    pass "child $child_id path is not nested under parent program"
  fi
}

validate_no_forbidden_parent_authority_surfaces() {
  local output
  if [[ ! -d "$PROGRAM_DIR" ]]; then
    return 0
  fi
  output="$(
    grep -RInE '^[[:space:]]*(child_validation_verdicts|child_archive_metadata|child_receipts|child_promotion_targets|child_terminal_outcomes|child_archive_authorized|satisfies_child_receipts):' "$PROGRAM_DIR" 2>/dev/null || true
  )"
  if [[ -z "$output" ]]; then
    pass "parent package contains no child-owned authority surfaces"
  else
    emit_hard_blocker_recovery_diagnostic \
      "$(program_structure_repo_rel "$PROGRAM_DIR")" \
      "parent package contains child-owned authority surfaces" \
      "$(program_structure_rerun_gate)" \
      "$output"
    fail "parent package contains child-owned authority surfaces"
    printf '%s\n' "$output"
  fi
}

if [[ ! -d "$PROGRAM_DIR" ]]; then
  emit_hard_blocker_recovery_diagnostic \
    "$(program_structure_repo_rel "$PROGRAM_DIR")" \
    "program packet directory is missing" \
    "$(program_structure_rerun_gate)"
  fail "program packet exists"
  echo "Validation summary: errors=$errors warnings=$warnings"
  exit 1
fi

require_file "$MANIFEST" "parent proposal.yml"
require_file "$REGISTRY" "program child registry"
require_file "$HUMAN_INDEX" "human child index"
require_file "$SEQUENCE" "packet sequence"
require_file "$CHILD_CONTRACT" "child packet contract"
require_file "$CLOSEOUT_PLAN" "program closeout plan"
require_yaml "$MANIFEST" "parent proposal.yml"
require_yaml "$REGISTRY" "program child registry"

if [[ -d "$PROGRAM_DIR/children" ]]; then
  emit_hard_blocker_recovery_diagnostic \
    "$(program_structure_repo_rel "$PROGRAM_DIR/children")" \
    "program packets must not own nested child directories" \
    "$(program_structure_rerun_gate)"
  fail "program has no nested children directory"
else
  pass "program has no nested children directory"
fi

child_count="$(yq -r '(.children // []) | length' "$REGISTRY" 2>/dev/null || echo 0)"
if [[ "$child_count" =~ ^[1-9][0-9]*$ ]]; then
  pass "program child registry declares children"
else
  emit_recovery_diagnostic \
    --recovery-class "child_registry_error" \
    --failing-path "$(program_structure_repo_rel "$REGISTRY")#children" \
    --observed-value "$child_count" \
    --minimal-repair-hint "declare at least one child in resources/child-packet-index.yml" \
    --rerun-gate "$(program_structure_rerun_gate)"
  fail "program child registry declares children"
fi

for ((index=0; index<child_count; index++)); do
  child_id="$(yq -r ".children[$index].child_id // \"\"" "$REGISTRY" 2>/dev/null || true)"
  child_path="$(yq -r ".children[$index].path // \"\"" "$REGISTRY" 2>/dev/null || true)"
  dependencies="$(yq -r ".children[$index].dependencies[]? // \"\"" "$REGISTRY" 2>/dev/null | awk 'NF' || true)"

  valid_child_id "$child_id" && pass "child id valid: $child_id" || {
    emit_recovery_diagnostic \
      --recovery-class "child_registry_error" \
      --failing-path "$(program_structure_repo_rel "$REGISTRY")#children[$index].child_id" \
      --observed-value "$child_id" \
      --minimal-repair-hint "use a child_id matching ^[a-z][a-z0-9-]*$" \
      --rerun-gate "$(program_structure_rerun_gate)"
    fail "child id valid: $child_id"
  }
  if [[ -n "${CHILD_SEEN[$child_id]:-}" ]]; then
    emit_recovery_diagnostic \
      --recovery-class "child_registry_error" \
      --failing-path "$(program_structure_repo_rel "$REGISTRY")#children[$index].child_id" \
      --observed-value "$child_id" \
      --minimal-repair-hint "make every child_id unique in resources/child-packet-index.yml" \
      --rerun-gate "$(program_structure_rerun_gate)"
    fail "child id unique: $child_id"
  else
    CHILD_SEEN["$child_id"]=1
    pass "child id unique: $child_id"
  fi

  safe_rel_path "$child_path" && pass "child $child_id path is repo-relative" || {
    emit_recovery_diagnostic \
      --recovery-class "child_registry_error" \
      --failing-path "$(program_structure_repo_rel "$REGISTRY")#children[$index].path" \
      --observed-value "$child_path" \
      --minimal-repair-hint "set child path to a safe repo-relative proposal packet path" \
      --rerun-gate "$(program_structure_rerun_gate)"
    fail "child $child_id path is repo-relative"
  }
  validate_no_nested_children "$child_path" "$child_id"

  while IFS= read -r dependency; do
    [[ -n "$dependency" ]] || continue
    if [[ -n "${CHILD_SEEN[$dependency]:-}" ]] || yq -e ".children[]? | select(.child_id == \"$dependency\")" "$REGISTRY" >/dev/null 2>&1; then
      pass "child $child_id dependency references registry child: $dependency"
    else
      fail "child $child_id dependency references registry child: $dependency"
      emit_recovery_diagnostic \
        --recovery-class "child_registry_error" \
        --failing-path "$(program_structure_repo_rel "$REGISTRY")#children[$index].dependencies" \
        --observed-value "$dependency" \
        --minimal-repair-hint "make dependencies reference existing child_id values" \
        --rerun-gate "$(program_structure_rerun_gate)"
    fi
  done <<<"$dependencies"
done

compare_registry_to_related_proposals
require_mentions_child_ids "$HUMAN_INDEX" "human child index"
require_mentions_child_ids "$SEQUENCE" "packet sequence"
validate_no_forbidden_parent_authority_surfaces

echo "Validation summary: errors=$errors warnings=$warnings"
[[ "$errors" -eq 0 ]]
