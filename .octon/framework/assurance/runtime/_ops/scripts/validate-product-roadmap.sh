#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
if [[ -n "${OCTON_DIR_OVERRIDE:-}" ]]; then
  OCTON_DIR="$(cd -- "$OCTON_DIR_OVERRIDE" && pwd)"
  ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"
elif [[ -n "${OCTON_ROOT_DIR:-}" ]]; then
  ROOT_DIR="$(cd -- "$OCTON_ROOT_DIR" && pwd)"
  OCTON_DIR="$ROOT_DIR/.octon"
else
  OCTON_DIR="$DEFAULT_OCTON_DIR"
  ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"
fi
ROADMAP_PATH="${PRODUCT_ROADMAP_CATALOG:-$OCTON_DIR/framework/product/roadmap/catalog.yml}"
FEATURE_CATALOG_PATH="${PRODUCT_FEATURE_CATALOG:-$OCTON_DIR/framework/product/features/catalog.yml}"

errors=0

usage() {
  cat <<'USAGE'
usage:
  validate-product-roadmap.sh [--catalog <path>] [--feature-catalog <path>]
USAGE
}

pass() { echo "[OK] $1"; }
fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --catalog)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      ROADMAP_PATH="$1"
      ;;
    --feature-catalog)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      FEATURE_CATALOG_PATH="$1"
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

repo_abs() {
  local path="$1"
  if [[ "$path" = /* ]]; then
    printf '%s\n' "$path"
  else
    printf '%s/%s\n' "$ROOT_DIR" "$path"
  fi
}

rel_from_root() {
  local path="$1"
  if [[ "$path" = "$ROOT_DIR/"* ]]; then
    printf '%s\n' "${path#$ROOT_DIR/}"
  else
    printf '%s\n' "$path"
  fi
}

valid_rel_path() {
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

is_safe_non_authority_class() {
  case "$1" in
    publication-input-only|generated-effective-non-authority|retained-evidence|retained-evidence-pattern|validation|navigation-only|planning-only)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

validate_authority_class_for_path() {
  local path="$1" authority_class="$2" label="$3"

  case "$path" in
    .octon/generated/*)
      if [[ "$authority_class" == "generated-effective-non-authority" ]]; then
        pass "generated path is non-authority: $label"
      else
        fail "generated path must be classified as generated-effective-non-authority: $label -> $path"
      fi
      ;;
    .octon/inputs/*)
      if [[ "$authority_class" == "publication-input-only" ]]; then
        pass "input path is publication-input-only: $label"
      else
        fail "input path must be classified as publication-input-only: $label -> $path"
      fi
      ;;
    */support/*|support/*)
      if is_safe_non_authority_class "$authority_class"; then
        pass "support receipt path is not authority: $label"
      else
        fail "proposal-local support paths cannot be classified as authority: $label -> $path"
      fi
      ;;
  esac
}

support_claim_line_is_qualified() {
  local line="$1"
  [[ "$line" == *"not "* \
    || "$line" == *"does not"* \
    || "$line" == *"do not"* \
    || "$line" == *"no "* \
    || "$line" == *"never "* \
    || "$line" == *"without "* \
    || "$line" == *"unsupported"* \
    || "$line" == *"out of scope"* \
    || "$line" == *"outside "* \
    || "$line" == *"follow-on"* \
    || "$line" == *"future"* ]]
}

validate_no_unqualified_support_claims() {
  local doc="$1" label="$2" line lower
  while IFS= read -r line; do
    lower="$(printf '%s' "$line" | tr '[:upper:]' '[:lower:]')"
    case "$lower" in
      *"universal transactionality"*|*"fully transactional"*|*"external workflow engine"*|*"durable object"*|*"mcp integration"*|*"workflow runtime statechart"*|*"task-specific execution harness"*|*"agent-node contract"*|*"recovers all"*|*"guarantees recovery"*|*"self-healing"*|*"self-approve"*|*"governed workflow runtime transition program"*)
        if support_claim_line_is_qualified "$lower"; then
          pass "support claim qualified: $label"
        else
          fail "support claim overstates implemented scope: $label -> $line"
        fi
        ;;
    esac
  done <"$doc"
}

validate_required_support_phrase() {
  local doc="$1" label="$2" phrase="$3"
  if rg -i --fixed-strings "$phrase" "$doc" >/dev/null 2>&1; then
    pass "support boundary phrase present: $label -> $phrase"
  else
    fail "support boundary phrase missing: $label -> $phrase"
  fi
}

validate_lifecycle_autopilot_roadmap_claims() {
  local doc="$OCTON_DIR/framework/product/roadmap/lifecycle-autopilot.md"
  if [[ ! -f "$doc" ]]; then
    return
  fi

  validate_required_support_phrase "$doc" "lifecycle-autopilot roadmap note" "planning-only"
  validate_required_support_phrase "$doc" "lifecycle-autopilot roadmap note" "does not add runtime behavior"
  validate_no_unqualified_support_claims "$doc" "lifecycle-autopilot roadmap note"
}

require_yq() {
  if ! command -v yq >/dev/null 2>&1; then
    echo "[ERROR] yq is required for product roadmap validation" >&2
    exit 1
  fi
}

require_inputs() {
  ROADMAP_PATH="$(repo_abs "$ROADMAP_PATH")"
  FEATURE_CATALOG_PATH="$(repo_abs "$FEATURE_CATALOG_PATH")"

  if [[ -f "$ROADMAP_PATH" ]]; then
    pass "found roadmap catalog: $(rel_from_root "$ROADMAP_PATH")"
  else
    fail "missing roadmap catalog: $(rel_from_root "$ROADMAP_PATH")"
    exit 1
  fi

  if [[ -f "$FEATURE_CATALOG_PATH" ]]; then
    pass "found feature catalog: $(rel_from_root "$FEATURE_CATALOG_PATH")"
  else
    fail "missing feature catalog: $(rel_from_root "$FEATURE_CATALOG_PATH")"
    exit 1
  fi
}

feature_id_exists() {
  local feature_id="$1"
  yq -e ".features[]? | select(.feature_id == \"$feature_id\")" "$FEATURE_CATALOG_PATH" >/dev/null 2>&1
}

validate_reference_section() {
  local item_index="$1" item_id="$2" section="$3" allow_empty="${4:-0}"
  local count index path path_pattern role authority_class label

  count="$(yq -r "(.items[$item_index].$section // []) | length" "$ROADMAP_PATH" 2>/dev/null || echo 0)"
  if [[ "$count" -lt 1 ]]; then
    if [[ "$allow_empty" -eq 1 ]]; then
      pass "item $item_id section may be empty: $section"
    else
      fail "item $item_id section must be non-empty: $section"
    fi
    return
  fi

  for ((index=0; index<count; index++)); do
    label="$item_id.$section[$index]"
    if ! yq -e ".items[$item_index].$section[$index] | tag == \"!!map\"" "$ROADMAP_PATH" >/dev/null 2>&1; then
      fail "reference entry must be a map: $label"
      continue
    fi

    path="$(yq -r ".items[$item_index].$section[$index].path // \"\"" "$ROADMAP_PATH" 2>/dev/null || true)"
    path_pattern="$(yq -r ".items[$item_index].$section[$index].path_pattern // \"\"" "$ROADMAP_PATH" 2>/dev/null || true)"
    role="$(yq -r ".items[$item_index].$section[$index].role // \"\"" "$ROADMAP_PATH" 2>/dev/null || true)"
    authority_class="$(yq -r ".items[$item_index].$section[$index].authority_class // \"\"" "$ROADMAP_PATH" 2>/dev/null || true)"

    [[ -n "$role" ]] && pass "reference role declared: $label" || fail "reference role missing: $label"
    [[ -n "$authority_class" ]] && pass "reference authority_class declared: $label" || fail "reference authority_class missing: $label"

    case "$authority_class" in
      authored-authority|product-contract|runtime-spec|runtime-implementation|runtime-command|publication-input-only|generated-effective-non-authority|retained-evidence|retained-evidence-pattern|validation|navigation-only|planning-only)
        pass "reference authority_class valid: $label"
        ;;
      *)
        fail "reference authority_class invalid: $label -> $authority_class"
        ;;
    esac

    if [[ -n "$path" && -n "$path_pattern" ]]; then
      fail "reference must use path or path_pattern, not both: $label"
      continue
    fi

    if [[ -n "$path" ]]; then
      if valid_rel_path "$path"; then
        pass "reference path is repo-relative: $label"
      else
        fail "reference path must be repo-relative and traversal-free: $label -> $path"
        continue
      fi

      if [[ -e "$ROOT_DIR/$path" ]]; then
        pass "reference path exists: $path"
      else
        fail "reference path missing: $path"
      fi
      validate_authority_class_for_path "$path" "$authority_class" "$label"
    elif [[ -n "$path_pattern" ]]; then
      if valid_rel_path "$path_pattern" && [[ "$path_pattern" == *"<"*">"* || "$path_pattern" == *"*"* ]]; then
        pass "reference path pattern declared: $label"
      else
        fail "path_pattern must be repo-relative and visibly parameterized: $label -> $path_pattern"
        continue
      fi
      validate_authority_class_for_path "$path_pattern" "$authority_class" "$label"
    else
      fail "reference must declare path or path_pattern: $label"
    fi
  done
}

validate_non_empty_string_array() {
  local item_index="$1" item_id="$2" field="$3" allow_empty="${4:-0}"
  local count index value

  count="$(yq -r "(.items[$item_index].$field // []) | length" "$ROADMAP_PATH" 2>/dev/null || echo 0)"
  if [[ "$count" -lt 1 ]]; then
    if [[ "$allow_empty" -eq 1 ]]; then
      pass "item $item_id array may be empty: $field"
    else
      fail "item $item_id array empty: $field"
    fi
    return
  fi

  pass "item $item_id array non-empty: $field"
  for ((index=0; index<count; index++)); do
    value="$(yq -r ".items[$item_index].$field[$index] // \"\"" "$ROADMAP_PATH" 2>/dev/null || true)"
    [[ -n "$value" ]] \
      && pass "item $item_id array item declared: $field[$index]" \
      || fail "item $item_id array item empty: $field[$index]"
  done
}

validate_item() {
  local index="$1" item_id feature_id status field
  item_id="$(yq -r ".items[$index].roadmap_item_id // \"\"" "$ROADMAP_PATH" 2>/dev/null || true)"
  feature_id="$(yq -r ".items[$index].feature_id // \"\"" "$ROADMAP_PATH" 2>/dev/null || true)"
  status="$(yq -r ".items[$index].status // \"\"" "$ROADMAP_PATH" 2>/dev/null || true)"

  if [[ "$item_id" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
    pass "roadmap item id valid: $item_id"
  else
    fail "roadmap item id must be kebab-case: items[$index]"
  fi

  for field in title status feature_id summary why_deferred; do
    [[ -n "$(yq -r ".items[$index].$field // \"\"" "$ROADMAP_PATH" 2>/dev/null || true)" ]] \
      && pass "item $item_id field declared: $field" \
      || fail "item $item_id field missing: $field"
  done

  case "$status" in
    suggested|accepted|planned|in-progress|completed|rejected|superseded)
      pass "item $item_id status valid"
      ;;
    *)
      fail "item $item_id status invalid: $status"
      ;;
  esac

  if feature_id_exists "$feature_id"; then
    pass "item $item_id feature_id resolves: $feature_id"
  else
    fail "item $item_id feature_id does not resolve in feature catalog: $feature_id"
  fi

  validate_non_empty_string_array "$index" "$item_id" "owner_subsystems"
  validate_non_empty_string_array "$index" "$item_id" "acceptance_criteria"
  validate_non_empty_string_array "$index" "$item_id" "authority_notes"

  validate_reference_section "$index" "$item_id" "source_refs"
  validate_reference_section "$index" "$item_id" "validation_refs"
  validate_reference_section "$index" "$item_id" "completion_refs" 1

  local completion_count
  completion_count="$(yq -r "(.items[$index].completion_refs // []) | length" "$ROADMAP_PATH" 2>/dev/null || echo 0)"
  if [[ "$status" == "completed" && "$completion_count" -lt 1 ]]; then
    fail "completed item $item_id requires at least one completion_ref"
  elif [[ "$status" == "completed" ]]; then
    pass "completed item $item_id has completion refs"
  fi
}

main() {
  echo "== Product Roadmap Validation =="
  require_yq
  require_inputs

  if yq -e '.' "$ROADMAP_PATH" >/dev/null 2>&1; then
    pass "roadmap YAML parses"
  else
    fail "roadmap YAML does not parse"
    exit 1
  fi

  if yq -e '.' "$FEATURE_CATALOG_PATH" >/dev/null 2>&1; then
    pass "feature catalog YAML parses"
  else
    fail "feature catalog YAML does not parse"
    exit 1
  fi

  [[ "$(yq -r '.schema_version // ""' "$ROADMAP_PATH")" == "octon-product-roadmap-v1" ]] \
    && pass "schema version correct" \
    || fail "schema version must be octon-product-roadmap-v1"

  [[ "$(yq -r '.roadmap_role // ""' "$ROADMAP_PATH")" == "planning-only" ]] \
    && pass "roadmap role is planning-only" \
    || fail "roadmap_role must be planning-only"

  [[ -n "$(yq -r '.authority_note // ""' "$ROADMAP_PATH")" ]] \
    && pass "authority note declared" \
    || fail "authority_note is required"

  local duplicate_ids item_count index
  duplicate_ids="$(yq -r '.items[]?.roadmap_item_id // ""' "$ROADMAP_PATH" | awk 'NF' | sort | uniq -d || true)"
  if [[ -n "$duplicate_ids" ]]; then
    fail "roadmap item ids must be unique: $duplicate_ids"
  else
    pass "roadmap item ids are unique"
  fi

  item_count="$(yq -r '(.items // []) | length' "$ROADMAP_PATH" 2>/dev/null || echo 0)"
  if [[ "$item_count" -lt 1 ]]; then
    fail "items must be non-empty"
  fi

  for ((index=0; index<item_count; index++)); do
    validate_item "$index"
  done
  validate_lifecycle_autopilot_roadmap_claims

  echo "Validation summary: errors=$errors"
  if [[ "$errors" -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
