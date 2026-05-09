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
CATALOG_PATH="${PRODUCT_FEATURE_CATALOG:-$OCTON_DIR/framework/product/features/catalog.yml}"

errors=0

usage() {
  cat <<'USAGE'
usage:
  validate-product-feature-catalog.sh [--catalog <path>]
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
      CATALOG_PATH="$1"
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
    publication-input-only|generated-effective-non-authority|retained-evidence|retained-evidence-pattern|validation|navigation-only)
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

validate_lifecycle_autopilot_support_claims() {
  local doc="$OCTON_DIR/framework/product/features/lifecycle-autopilot.md"
  if ! yq -e '.features[]? | select(.feature_id == "lifecycle-autopilot")' "$CATALOG_PATH" >/dev/null 2>&1; then
    return
  fi

  if [[ ! -f "$doc" ]]; then
    fail "lifecycle-autopilot feature note missing for support-claim validation"
    return
  fi

  validate_required_support_phrase "$doc" "lifecycle-autopilot feature note" "not universal transactionality"
  validate_required_support_phrase "$doc" "lifecycle-autopilot feature note" "does not create the Governed Workflow Runtime transition"
  validate_required_support_phrase "$doc" "lifecycle-autopilot feature note" "generated effective projections"
  validate_required_support_phrase "$doc" "lifecycle-autopilot feature note" "proposal-local receipts remain evidence only"
  validate_required_support_phrase "$doc" "lifecycle-autopilot feature note" "never self-approve"
  validate_no_unqualified_support_claims "$doc" "lifecycle-autopilot feature note"
}

require_yq() {
  if ! command -v yq >/dev/null 2>&1; then
    echo "[ERROR] yq is required for product feature catalog validation" >&2
    exit 1
  fi
}

require_catalog() {
  CATALOG_PATH="$(repo_abs "$CATALOG_PATH")"
  if [[ -f "$CATALOG_PATH" ]]; then
    pass "found catalog: $(rel_from_root "$CATALOG_PATH")"
  else
    fail "missing catalog: $(rel_from_root "$CATALOG_PATH")"
    exit 1
  fi
}

validate_reference_section() {
  local feature_index="$1" feature_id="$2" section="$3"
  local count index path path_pattern role authority_class label

  count="$(yq -r "(.features[$feature_index].$section // []) | length" "$CATALOG_PATH" 2>/dev/null || echo 0)"
  if [[ "$count" -lt 1 ]]; then
    fail "feature $feature_id section must be non-empty: $section"
    return
  fi

  for ((index=0; index<count; index++)); do
    label="$feature_id.$section[$index]"
    if ! yq -e ".features[$feature_index].$section[$index] | tag == \"!!map\"" "$CATALOG_PATH" >/dev/null 2>&1; then
      fail "reference entry must be a map: $label"
      continue
    fi

    path="$(yq -r ".features[$feature_index].$section[$index].path // \"\"" "$CATALOG_PATH" 2>/dev/null || true)"
    path_pattern="$(yq -r ".features[$feature_index].$section[$index].path_pattern // \"\"" "$CATALOG_PATH" 2>/dev/null || true)"
    role="$(yq -r ".features[$feature_index].$section[$index].role // \"\"" "$CATALOG_PATH" 2>/dev/null || true)"
    authority_class="$(yq -r ".features[$feature_index].$section[$index].authority_class // \"\"" "$CATALOG_PATH" 2>/dev/null || true)"

    [[ -n "$role" ]] && pass "reference role declared: $label" || fail "reference role missing: $label"
    [[ -n "$authority_class" ]] && pass "reference authority_class declared: $label" || fail "reference authority_class missing: $label"

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

validate_entrypoints() {
  local feature_index="$1" feature_id="$2"
  local count index kind value

  count="$(yq -r "(.features[$feature_index].entrypoints // []) | length" "$CATALOG_PATH" 2>/dev/null || echo 0)"
  if [[ "$count" -lt 1 ]]; then
    fail "feature $feature_id entrypoints must be non-empty"
    return
  fi

  for ((index=0; index<count; index++)); do
    kind="$(yq -r ".features[$feature_index].entrypoints[$index].kind // \"\"" "$CATALOG_PATH" 2>/dev/null || true)"
    value="$(yq -r ".features[$feature_index].entrypoints[$index].value // \"\"" "$CATALOG_PATH" 2>/dev/null || true)"
    case "$kind" in
      cli|command|skill|workflow|path)
        pass "entrypoint kind valid: $feature_id.entrypoints[$index]"
        ;;
      *)
        fail "entrypoint kind invalid: $feature_id.entrypoints[$index] -> $kind"
        ;;
    esac
    [[ -n "$value" ]] && pass "entrypoint value declared: $feature_id.entrypoints[$index]" || fail "entrypoint value missing: $feature_id.entrypoints[$index]"
  done
}

validate_non_empty_string_array() {
  local feature_index="$1" feature_id="$2" field="$3"
  local count index value

  count="$(yq -r "(.features[$feature_index].$field // []) | length" "$CATALOG_PATH" 2>/dev/null || echo 0)"
  if [[ "$count" -lt 1 ]]; then
    fail "feature $feature_id array empty: $field"
    return
  fi

  pass "feature $feature_id array non-empty: $field"
  for ((index=0; index<count; index++)); do
    value="$(yq -r ".features[$feature_index].$field[$index] // \"\"" "$CATALOG_PATH" 2>/dev/null || true)"
    [[ -n "$value" ]] \
      && pass "feature $feature_id array item declared: $field[$index]" \
      || fail "feature $feature_id array item empty: $field[$index]"
  done
}

validate_feature() {
  local index="$1" feature_id field count section
  feature_id="$(yq -r ".features[$index].feature_id // \"\"" "$CATALOG_PATH" 2>/dev/null || true)"

  if [[ "$feature_id" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
    pass "feature id valid: $feature_id"
  else
    fail "feature id must be kebab-case: features[$index]"
  fi

  for field in name implementation_status summary; do
    [[ -n "$(yq -r ".features[$index].$field // \"\"" "$CATALOG_PATH" 2>/dev/null || true)" ]] \
      && pass "feature $feature_id field declared: $field" \
      || fail "feature $feature_id field missing: $field"
  done

  case "$(yq -r ".features[$index].implementation_status // \"\"" "$CATALOG_PATH" 2>/dev/null || true)" in
    planned|stage-only|implemented|retired)
      pass "feature $feature_id implementation_status valid"
      ;;
    *)
      fail "feature $feature_id implementation_status invalid"
      ;;
  esac

  for field in primary_audiences owner_subsystems authority_notes; do
    validate_non_empty_string_array "$index" "$feature_id" "$field"
  done

  validate_entrypoints "$index" "$feature_id"

  for section in authoritative_refs runtime_surfaces extension_surfaces generated_effective_surfaces evidence_surfaces validation_refs related_docs; do
    validate_reference_section "$index" "$feature_id" "$section"
  done
}

main() {
  echo "== Product Feature Catalog Validation =="
  require_yq
  require_catalog

  if yq -e '.' "$CATALOG_PATH" >/dev/null 2>&1; then
    pass "catalog YAML parses"
  else
    fail "catalog YAML does not parse"
    exit 1
  fi

  [[ "$(yq -r '.schema_version // ""' "$CATALOG_PATH")" == "octon-product-feature-catalog-v1" ]] \
    && pass "schema version correct" \
    || fail "schema version must be octon-product-feature-catalog-v1"

  [[ "$(yq -r '.catalog_role // ""' "$CATALOG_PATH")" == "navigation-only" ]] \
    && pass "catalog role is navigation-only" \
    || fail "catalog_role must be navigation-only"

  [[ -n "$(yq -r '.authority_note // ""' "$CATALOG_PATH")" ]] \
    && pass "authority note declared" \
    || fail "authority_note is required"

  local duplicate_ids feature_count index
  duplicate_ids="$(yq -r '.features[]?.feature_id // ""' "$CATALOG_PATH" | awk 'NF' | sort | uniq -d || true)"
  if [[ -n "$duplicate_ids" ]]; then
    fail "feature ids must be unique: $duplicate_ids"
  else
    pass "feature ids are unique"
  fi

  feature_count="$(yq -r '(.features // []) | length' "$CATALOG_PATH" 2>/dev/null || echo 0)"
  if [[ "$feature_count" -lt 1 ]]; then
    fail "features must be non-empty"
  fi

  for ((index=0; index<feature_count; index++)); do
    validate_feature "$index"
  done
  validate_lifecycle_autopilot_support_claims

  echo "Validation summary: errors=$errors"
  if [[ "$errors" -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
