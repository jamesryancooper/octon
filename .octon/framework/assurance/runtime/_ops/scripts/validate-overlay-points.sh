#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

REGISTRY_FILE="$OCTON_DIR/framework/overlay-points/registry.yml"
INSTANCE_MANIFEST="$OCTON_DIR/instance/manifest.yml"

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

require_yaml_file() {
  local file="$1"
  local label="$2"
  if [[ ! -f "$file" ]]; then
    fail "$label"
    return 1
  fi
  if yq -e '.' "$file" >/dev/null 2>&1; then
    pass "$label"
    return 0
  fi
  fail "$label (YAML parse failed)"
  return 1
}

main() {
  echo "== Overlay Points Validation =="

  require_yaml_file "$REGISTRY_FILE" "found overlay registry: ${REGISTRY_FILE#$ROOT_DIR/}" || true
  require_yaml_file "$INSTANCE_MANIFEST" "found instance manifest: ${INSTANCE_MANIFEST#$ROOT_DIR/}" || true

  [[ "$(yq -r '.schema_version // ""' "$REGISTRY_FILE" 2>/dev/null)" == "octon-overlay-points-registry-v1" ]] \
    && pass "overlay registry schema version valid" \
    || fail "overlay registry schema_version must be octon-overlay-points-registry-v1"

  if ! yq -e '.overlay_points | tag == "!!seq"' "$REGISTRY_FILE" >/dev/null 2>&1; then
    fail "overlay registry must declare overlay_points as a list"
  fi

  local ids
  ids="$(yq -r '.overlay_points[]?.overlay_point_id // ""' "$REGISTRY_FILE" 2>/dev/null || true)"
  if [[ -z "$ids" ]]; then
    fail "overlay registry must declare at least one overlay point"
  fi

  local dupes
  dupes="$(printf '%s\n' "$ids" | sed '/^$/d' | sort | uniq -d || true)"
  if [[ -n "$dupes" ]]; then
    fail "overlay_point_id values must be unique: $(printf '%s\n' "$dupes" | tr '\n' ',' | sed 's/,$//')"
  else
    pass "overlay_point_id values are unique"
  fi

  local count idx overlay_id owning_domain instance_glob merge_mode validator precedence
  count="$(yq -r '.overlay_points | length' "$REGISTRY_FILE" 2>/dev/null || echo 0)"
  for idx in $(seq 0 $((count - 1))); do
    overlay_id="$(yq -r ".overlay_points[$idx].overlay_point_id // \"\"" "$REGISTRY_FILE")"
    owning_domain="$(yq -r ".overlay_points[$idx].owning_domain // \"\"" "$REGISTRY_FILE")"
    instance_glob="$(yq -r ".overlay_points[$idx].instance_glob // \"\"" "$REGISTRY_FILE")"
    merge_mode="$(yq -r ".overlay_points[$idx].merge_mode // \"\"" "$REGISTRY_FILE")"
    validator="$(yq -r ".overlay_points[$idx].validator // \"\"" "$REGISTRY_FILE")"
    precedence="$(yq -r ".overlay_points[$idx].precedence // \"\"" "$REGISTRY_FILE")"

    [[ -n "$overlay_id" ]] || fail "overlay point #$idx missing overlay_point_id"
    [[ -n "$owning_domain" ]] || fail "overlay point '$overlay_id' missing owning_domain"

    case "$instance_glob" in
      .octon/instance/*) pass "overlay point '$overlay_id' instance_glob is instance-scoped" ;;
      *) fail "overlay point '$overlay_id' instance_glob must stay under .octon/instance/** (got: $instance_glob)" ;;
    esac

    case "$merge_mode" in
      replace_by_path|merge_by_id|append_only)
        pass "overlay point '$overlay_id' merge_mode valid"
        ;;
      *)
        fail "overlay point '$overlay_id' uses unsupported merge_mode '$merge_mode'"
        ;;
    esac

    if [[ -z "$validator" ]]; then
      fail "overlay point '$overlay_id' missing validator path"
    elif [[ -f "$ROOT_DIR/$validator" ]]; then
      pass "overlay point '$overlay_id' validator resolves"
    else
      fail "overlay point '$overlay_id' validator path missing: $validator"
    fi

    [[ "$precedence" =~ ^[0-9]+$ ]] \
      && pass "overlay point '$overlay_id' precedence is numeric" \
      || fail "overlay point '$overlay_id' precedence must be numeric"

    case "$owning_domain" in
      engine)
        fail "overlay point '$overlay_id' must not target closed engine surfaces"
        ;;
    esac
  done

  while IFS= read -r enabled; do
    [[ -n "$enabled" ]] || continue
    if printf '%s\n' "$ids" | grep -Fxq "$enabled"; then
      pass "enabled overlay point '$enabled' is declared by framework"
    else
      fail "instance manifest enables undeclared overlay point '$enabled'"
    fi
  done < <(yq -r '.enabled_overlay_points[]? // ""' "$INSTANCE_MANIFEST" 2>/dev/null || true)

  if [[ "$errors" -gt 0 ]]; then
    echo "Validation summary: errors=$errors"
    exit 1
  fi

  echo "Validation summary: errors=0"
}

main "$@"
