#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
FRAMEWORK_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
OCTON_DIR="$(cd -- "$FRAMEWORK_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

REGISTRY_PATH="$ROOT_DIR/.octon/generated/proposals/registry.yml"
SCHEMA_PATH="$ROOT_DIR/.octon/framework/cognition/_meta/architecture/generated/proposals/schemas/proposal-registry.schema.json"
BASE_VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh"

MODE=""
errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

usage() {
  cat <<'EOF'
usage:
  generate-proposal-registry.sh --write
  generate-proposal-registry.sh --check
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --write)
      MODE="write"
      ;;
    --check)
      MODE="check"
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
  shift
done

[[ -n "$MODE" ]] || {
  usage >&2
  exit 2
}

rel_path() {
  local path="$1"
  if [[ "$path" == "$ROOT_DIR" ]]; then
    printf '.\n'
  else
    printf '%s\n' "${path#$ROOT_DIR/}"
  fi
}

yaml_string() {
  local file="$1"
  local query="$2"
  yq -r "$query // \"\"" "$file"
}

yaml_quote() {
  python3 - "$1" <<'PY'
import json
import sys
print(json.dumps(sys.argv[1]))
PY
}

subtype_validator_for_kind() {
  case "$1" in
    design)
      printf '%s\n' "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-design-proposal.sh"
      ;;
    migration)
      printf '%s\n' "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-migration-proposal.sh"
      ;;
    policy)
      printf '%s\n' "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-policy-proposal.sh"
      ;;
    architecture)
      printf '%s\n' "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh"
      ;;
    *)
      return 1
      ;;
  esac
}

emit_target_lines() {
  local manifest="$1"
  local indent="$2"
  local prefix
  prefix="$(printf '%*s' "$indent" '')"
  while IFS= read -r target; do
    [[ -n "$target" ]] || continue
    printf '%s- %s\n' "$prefix" "$(yaml_quote "$target")"
  done < <(yq -r '.promotion_targets[]?' "$manifest")
}

validate_package() {
  local proposal_dir="$1"
  local proposal_rel="$2"
  local manifest="$proposal_dir/proposal.yml"
  local kind status archived_from_status validator

  kind="$(yaml_string "$manifest" '.proposal_kind')"
  status="$(yaml_string "$manifest" '.status')"
  archived_from_status="$(yaml_string "$manifest" '.archive.archived_from_status')"
  if [[ "$kind" == "design" \
    && "$status" == "archived" \
    && "$proposal_rel" == .octon/inputs/exploratory/proposals/.archive/design/* \
    && "$archived_from_status" == "legacy-unknown" ]]; then
    pass "legacy-unknown design import excluded from main registry projection: $proposal_rel"
    return 0
  fi
  if ! bash "$BASE_VALIDATOR" --package "$proposal_rel" --skip-registry-check; then
    fail "proposal package validates without registry recursion: $proposal_rel"
    return 1
  fi
  pass "proposal package validates without registry recursion: $proposal_rel"

  validator="$(subtype_validator_for_kind "$kind")" || {
    fail "subtype validator exists for proposal kind '$kind' ($proposal_rel)"
    return 1
  }

  if ! bash "$validator" --package "$proposal_rel"; then
    fail "subtype validator passes for $proposal_rel"
    return 1
  fi
  pass "subtype validator passes for $proposal_rel"
}

render_registry() {
  local output_file="$1"
  local tmp_dir="$2"
  local active_dir="$tmp_dir/active"
  local archived_dir="$tmp_dir/archived"
  local fragment

  {
    printf 'schema_version: "proposal-registry-v1"\n\n'
    if find "$active_dir" -type f | grep -q .; then
      printf 'active:\n'
      while IFS= read -r fragment; do
        cat "$fragment"
      done < <(find "$active_dir" -type f | sort)
    else
      printf 'active: []\n'
    fi

    if find "$archived_dir" -type f | grep -q .; then
      printf 'archived:\n'
      while IFS= read -r fragment; do
        cat "$fragment"
      done < <(find "$archived_dir" -type f | sort)
    else
      printf 'archived: []\n'
    fi
  } >"$output_file"
}

main() {
  local tmp_dir generated_registry
  declare -A seen=()

  if [[ -f "$SCHEMA_PATH" ]]; then
    pass "proposal registry schema exists"
    if yq -e '.' "$SCHEMA_PATH" >/dev/null 2>&1; then
      pass "proposal registry schema parses as JSON"
    else
      fail "proposal registry schema parses as JSON"
    fi
  else
    fail "proposal registry schema exists"
  fi

  tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/proposal-registry.XXXXXX")"
  trap '[[ -n "${tmp_dir:-}" && -d "${tmp_dir:-}" ]] && rm -r "$tmp_dir"' EXIT
  mkdir -p "$tmp_dir/active" "$tmp_dir/archived"

  while IFS= read -r manifest; do
    [[ -n "$manifest" ]] || continue

    local proposal_dir proposal_rel kind proposal_id scope title status key fragment archived_at archived_from_status disposition original_path
    proposal_dir="$(dirname "$manifest")"
    proposal_rel="$(rel_path "$proposal_dir")"

    if ! validate_package "$proposal_dir" "$proposal_rel"; then
      continue
    fi

    kind="$(yaml_string "$manifest" '.proposal_kind')"
    proposal_id="$(yaml_string "$manifest" '.proposal_id')"
    scope="$(yaml_string "$manifest" '.promotion_scope')"
    title="$(yaml_string "$manifest" '.title')"
    status="$(yaml_string "$manifest" '.status')"
    archived_from_status="$(yaml_string "$manifest" '.archive.archived_from_status')"
    key="${kind}:${proposal_id}"

    if [[ "$kind" == "design" \
      && "$status" == "archived" \
      && "$proposal_rel" == .octon/inputs/exploratory/proposals/.archive/design/* \
      && "$archived_from_status" == "legacy-unknown" ]]; then
      pass "legacy-unknown design import excluded from main registry projection: $proposal_rel"
      continue
    fi

    if [[ -n "${seen[$key]:-}" ]]; then
      fail "duplicate proposal key '${key}' across ${seen[$key]} and $proposal_rel"
      continue
    fi
    seen["$key"]="$proposal_rel"

    if [[ "$status" == "archived" ]]; then
      fragment="$tmp_dir/archived/${kind}__${proposal_id}.yml"
      archived_at="$(yaml_string "$manifest" '.archive.archived_at')"
      disposition="$(yaml_string "$manifest" '.archive.disposition')"
      original_path="$(yaml_string "$manifest" '.archive.original_path')"
      {
        printf '  - id: %s\n' "$(yaml_quote "$proposal_id")"
        printf '    kind: %s\n' "$(yaml_quote "$kind")"
        printf '    scope: %s\n' "$(yaml_quote "$scope")"
        printf '    path: %s\n' "$(yaml_quote "$proposal_rel")"
        printf '    title: %s\n' "$(yaml_quote "$title")"
        printf '    status: "archived"\n'
        printf '    disposition: %s\n' "$(yaml_quote "$disposition")"
        printf '    archived_at: %s\n' "$(yaml_quote "$archived_at")"
        printf '    archived_from_status: %s\n' "$(yaml_quote "$archived_from_status")"
        printf '    original_path: %s\n' "$(yaml_quote "$original_path")"
        printf '    promotion_targets:\n'
        emit_target_lines "$manifest" 6
      } >"$fragment"
    else
      fragment="$tmp_dir/active/${kind}__${proposal_id}.yml"
      {
        printf '  - id: %s\n' "$(yaml_quote "$proposal_id")"
        printf '    kind: %s\n' "$(yaml_quote "$kind")"
        printf '    scope: %s\n' "$(yaml_quote "$scope")"
        printf '    path: %s\n' "$(yaml_quote "$proposal_rel")"
        printf '    title: %s\n' "$(yaml_quote "$title")"
        printf '    status: %s\n' "$(yaml_quote "$status")"
        printf '    promotion_targets:\n'
        emit_target_lines "$manifest" 6
      } >"$fragment"
    fi
  done < <(find "$ROOT_DIR/.octon/inputs/exploratory/proposals" -name proposal.yml -type f | sort)

  generated_registry="$tmp_dir/registry.yml"
  render_registry "$generated_registry" "$tmp_dir"

  if yq -e '.' "$generated_registry" >/dev/null 2>&1; then
    pass "generated proposal registry parses as YAML"
  else
    fail "generated proposal registry parses as YAML"
  fi

  if [[ $errors -gt 0 ]]; then
    echo "Registry generation summary: errors=$errors"
    exit 1
  fi

  if [[ "$MODE" == "check" ]]; then
    if [[ ! -f "$REGISTRY_PATH" ]]; then
      fail "proposal registry exists at .octon/generated/proposals/registry.yml"
    elif cmp -s "$generated_registry" "$REGISTRY_PATH"; then
      pass "proposal registry matches generated projection"
    else
      fail "proposal registry matches generated projection"
      diff -u "$REGISTRY_PATH" "$generated_registry" || true
    fi
  else
    mkdir -p "$(dirname "$REGISTRY_PATH")"
    if [[ -f "$REGISTRY_PATH" ]] && cmp -s "$generated_registry" "$REGISTRY_PATH"; then
      pass "proposal registry already matches generated projection"
    else
      cp "$generated_registry" "$REGISTRY_PATH"
      pass "proposal registry written from manifest projection"
    fi
  fi

  echo "Registry generation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
