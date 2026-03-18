#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
MANIFEST_FILE="$OCTON_DIR/octon.yml"

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

require_manifest() {
  if [[ ! -f "$MANIFEST_FILE" ]]; then
    fail "missing file: ${MANIFEST_FILE#$ROOT_DIR/}"
    return 1
  fi
  if yq -e '.' "$MANIFEST_FILE" >/dev/null 2>&1; then
    pass "root manifest parses as YAML"
    return 0
  fi
  fail "root manifest must parse as YAML"
  return 1
}

check_scalar() {
  local query="$1"
  local expected="$2"
  local label="$3"
  local actual
  actual="$(yq -r "$query // \"\"" "$MANIFEST_FILE")"
  if [[ "$actual" == "$expected" ]]; then
    pass "$label"
  else
    fail "$label (found '${actual:-<empty>}')"
  fi
}

check_absent() {
  local query="$1"
  local label="$2"
  if yq -e "$query" "$MANIFEST_FILE" >/dev/null 2>&1; then
    fail "$label"
  else
    pass "$label"
  fi
}

check_list_equals() {
  local query="$1"
  local label="$2"
  shift 2
  local expected=("$@")
  mapfile -t actual < <(yq -r "$query[]?" "$MANIFEST_FILE" 2>/dev/null || true)
  if [[ "${#actual[@]}" -ne "${#expected[@]}" ]]; then
    fail "$label"
    return
  fi
  local i
  for i in "${!expected[@]}"; do
    if [[ "${actual[$i]}" != "${expected[$i]}" ]]; then
      fail "$label"
      return
    fi
  done
  pass "$label"
}

main() {
  echo "== Root Manifest Profile Validation =="

  require_manifest || {
    echo "Validation summary: errors=$errors"
    exit 1
  }

  check_scalar '.schema_version' 'octon-root-manifest-v2' "root schema_version is octon-root-manifest-v2"
  check_scalar '.topology.super_root' '.octon/' "topology.super_root resolves to .octon/"
  check_scalar '.topology.class_roots.framework' 'framework/' "framework class-root binding valid"
  check_scalar '.topology.class_roots.instance' 'instance/' "instance class-root binding valid"
  check_scalar '.topology.class_roots.inputs' 'inputs/' "inputs class-root binding valid"
  check_scalar '.topology.class_roots.state' 'state/' "state class-root binding valid"
  check_scalar '.topology.class_roots.generated' 'generated/' "generated class-root binding valid"
  check_scalar '.versioning.extensions.api_version' '1.0' "versioning.extensions.api_version declared"
  check_scalar '.policies.raw_input_dependency' 'fail-closed' "raw_input_dependency policy is fail-closed"
  check_scalar '.policies.generated_staleness' 'fail-closed' "generated_staleness policy is fail-closed"

  check_absent 'has("class_roots") and .class_roots != null' "legacy top-level class_roots key removed"
  check_absent 'has("extensions") and .extensions != null' "legacy top-level extensions key removed"
  check_absent 'has("human_led") and .human_led != null' "legacy top-level human_led key removed"
  check_absent '.profiles.full_fidelity.include' "full_fidelity no longer defines an include payload"

  local unexpected_profiles missing_profiles
  unexpected_profiles="$(
    yq -r '.profiles | keys[]' "$MANIFEST_FILE" 2>/dev/null \
      | grep -vxF 'bootstrap_core' \
      | grep -vxF 'repo_snapshot' \
      | grep -vxF 'pack_bundle' \
      | grep -vxF 'full_fidelity' || true
  )"
  missing_profiles="$(
    for expected in bootstrap_core repo_snapshot pack_bundle full_fidelity; do
      yq -e ".profiles | has(\"$expected\")" "$MANIFEST_FILE" >/dev/null 2>&1 || echo "$expected"
    done
  )"
  if [[ -z "$unexpected_profiles" && -z "$missing_profiles" ]]; then
    pass "only canonical v1 profile names are declared"
  else
    fail "unknown or non-canonical profile names detected"
  fi

  check_list_equals '.profiles.bootstrap_core.include' "bootstrap_core include contract matches Packet 2" \
    "octon.yml" "framework/**" "instance/manifest.yml"
  check_list_equals '.profiles.repo_snapshot.include' "repo_snapshot include contract matches Packet 2" \
    "octon.yml" "framework/**" "instance/**" "inputs/additive/extensions/<enabled-and-dependent>/**"
  check_list_equals '.profiles.repo_snapshot.exclude' "repo_snapshot exclude contract matches Packet 2" \
    "inputs/exploratory/**" "state/**" "generated/**"
  check_scalar '.profiles.pack_bundle.selector' 'inputs/additive/extensions/<selected>/**' "pack_bundle selector contract matches Packet 2"
  check_scalar '.profiles.pack_bundle.include_dependency_closure' 'true' "pack_bundle dependency closure is enabled"
  check_list_equals '.profiles.pack_bundle.exclude' "pack_bundle exclude contract matches Packet 2" \
    "framework/**" "instance/**" "inputs/exploratory/**" "state/**" "generated/**"

  local advisory
  advisory="$(yq -r '.profiles.full_fidelity.advisory // ""' "$MANIFEST_FILE")"
  if [[ -n "$advisory" ]]; then
    pass "full_fidelity advisory is declared"
  else
    fail "full_fidelity must declare an advisory message"
  fi

  if yq -e '.zones.human_led | length > 0' "$MANIFEST_FILE" >/dev/null 2>&1; then
    pass "zones.human_led declarations present"
  else
    fail "zones.human_led declarations missing"
  fi

  echo "Validation summary: errors=$errors"
  if [[ $errors -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
