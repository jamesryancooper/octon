#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_DIR="$(cd -- "$SCRIPT_DIR/../../../../" && pwd)"
ROOT_DIR="$(cd -- "$FRAMEWORK_DIR/.." && pwd)"
SCHEMA_PATH="$FRAMEWORK_DIR/product/contracts/governed-mechanism-integration-profile-v1.schema.json"
PROFILE_PATH=""
errors=0

usage() {
  cat <<'USAGE'
usage:
  validate-governed-mechanism-integration-profile.sh [--profile <path>]
USAGE
}

pass() { echo "[OK] $1"; }
fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      PROFILE_PATH="$1"
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

need_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "[ERROR] $1 is required" >&2
    exit 1
  fi
}

scalar() {
  yq -r "$1" "$PROFILE_PATH" 2>/dev/null || true
}

require_scalar() {
  local path="$1" label="$2" value
  value="$(scalar "$path")"
  if [[ -n "$value" && "$value" != "null" ]]; then
    pass "$label declared"
  else
    fail "$label missing"
  fi
}

require_surface() {
  local path="$1" surface_class="$2" label="$3" count na_count
  count="$(yq -r "($path // []) | length" "$PROFILE_PATH" 2>/dev/null || echo 0)"
  if [[ "$count" -gt 0 ]]; then
    pass "$label covered"
    return
  fi
  na_count="$(yq -r "(.not_applicable // []) | map(select(.surface_class == \"$surface_class\" and (.rationale // \"\") != \"\")) | length" "$PROFILE_PATH" 2>/dev/null || echo 0)"
  if [[ "$na_count" -gt 0 ]]; then
    pass "$label explicitly not applicable"
  else
    fail "$label missing and not_applicable rationale absent"
  fi
}

validate_refs_are_repo_relative() {
  local path="$1" label="$2" refs ref
  refs="$(yq -r "($path // [])[]?.ref // empty" "$PROFILE_PATH" 2>/dev/null || true)"
  while IFS= read -r ref; do
    [[ -n "$ref" ]] || continue
    if [[ "$ref" == /* || "$ref" == *".."* ]]; then
      fail "$label has non-repo-relative ref: $ref"
    else
      pass "$label repo-relative ref: $ref"
    fi
  done <<<"$refs"
}

require_non_authority_value() {
  local key="$1" expected="$2" value
  value="$(scalar ".non_authority_boundaries.$key")"
  [[ "$value" == "$expected" ]] && pass "non_authority_boundaries.$key is $expected" || fail "non_authority_boundaries.$key must be $expected"
}

need_tool jq
need_tool yq

echo "== Governed Mechanism Integration Profile Validation =="

if [[ -f "$SCHEMA_PATH" ]]; then
  pass "profile schema exists"
else
  fail "profile schema missing: $SCHEMA_PATH"
fi

if jq -e '.' "$SCHEMA_PATH" >/dev/null 2>&1; then
  pass "profile schema JSON parses"
else
  fail "profile schema JSON does not parse"
fi

for token in \
  '"governed-mechanism-integration-profile-v1"' \
  '"mechanism_id"' \
  '"product_feature_refs"' \
  '"generated_projections"' \
  '"lifecycle_hooks"' \
  '"non_authority_boundaries"'; do
  grep -Fq "$token" "$SCHEMA_PATH" && pass "schema token present: $token" || fail "schema token missing: $token"
done

if [[ -n "$PROFILE_PATH" ]]; then
  if [[ -f "$PROFILE_PATH" ]]; then
    pass "profile file exists: $PROFILE_PATH"
  else
    fail "profile file missing: $PROFILE_PATH"
    echo "Validation summary: errors=$errors"
    exit 1
  fi

  if yq -e '.' "$PROFILE_PATH" >/dev/null 2>&1; then
    pass "profile YAML parses"
  else
    fail "profile YAML does not parse"
  fi

  [[ "$(scalar '.schema_version')" == "governed-mechanism-integration-profile-v1" ]] \
    && pass "profile schema_version correct" \
    || fail "profile schema_version must be governed-mechanism-integration-profile-v1"

  require_scalar '.profile_id' "profile_id"
  require_scalar '.mechanism.mechanism_id' "mechanism.mechanism_id"
  require_scalar '.mechanism.display_name' "mechanism.display_name"
  require_scalar '.mechanism.index_ref' "mechanism.index_ref"

  require_surface '.owners' owners owners
  require_surface '.product_feature_refs' product_feature_refs "product feature refs"
  require_surface '.doctrine_refs' doctrine_refs "doctrine refs"
  require_surface '.documentation_refs' documentation_refs "documentation refs"
  require_surface '.workflows' workflows workflows
  require_surface '.skills' skills skills
  require_surface '.commands' commands commands
  require_surface '.schemas' schemas schemas
  require_surface '.validators' validators validators
  require_surface '.generated_projections' generated_projections "generated projections"
  require_surface '.evidence_roots' evidence_roots "evidence roots"
  require_surface '.lifecycle_hooks' lifecycle_hooks "lifecycle hooks"
  require_surface '.extension_boundaries' extension_boundaries "extension boundaries"

  authority_count="$(yq -r '(.authority_boundaries // {}) | length' "$PROFILE_PATH" 2>/dev/null || echo 0)"
  [[ "$authority_count" -gt 0 ]] && pass "authority_boundaries non-empty" || fail "authority_boundaries must be non-empty"

  require_non_authority_value proposal_inputs non-authority
  require_non_authority_value generated_outputs derived-only-non-authority
  require_non_authority_value generated_prompts non-authority
  require_non_authority_value host_state non-authority
  require_non_authority_value dashboards non-authority
  require_non_authority_value chat non-authority
  require_non_authority_value tool_state non-authority
  require_non_authority_value model_memory non-authority
  require_non_authority_value current_state_architecture_review evidence-only
  require_non_authority_value lifecycle_postmortem evidence-only

  for ref_path in \
    '.owners' \
    '.product_feature_refs' \
    '.doctrine_refs' \
    '.documentation_refs' \
    '.workflows' \
    '.skills' \
    '.commands' \
    '.schemas' \
    '.validators' \
    '.generated_projections' \
    '.evidence_roots' \
    '.lifecycle_hooks' \
    '.extension_boundaries'; do
    validate_refs_are_repo_relative "$ref_path" "$ref_path"
  done

  if grep -Eiq 'TODO|TBD|FIXME|placeholder|stale alias|stale proposal backref' "$PROFILE_PATH"; then
    fail "profile contains placeholder or stale marker text"
  else
    pass "profile contains no placeholder or stale marker text"
  fi
fi

echo "Validation summary: errors=$errors"
[[ "$errors" -eq 0 ]]
