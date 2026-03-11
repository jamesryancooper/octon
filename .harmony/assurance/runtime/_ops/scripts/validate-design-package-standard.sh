#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
HARMONY_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$HARMONY_DIR/.." && pwd)"

PACKAGE_PATH=""
SCAN_ALL=0
errors=0
warnings=0

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
  validate-design-package-standard.sh --package <path>
  validate-design-package-standard.sh --all-standard-packages
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --package)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      PACKAGE_PATH="$1"
      ;;
    --all-standard-packages)
      SCAN_ALL=1
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
  shift
done

if [[ -n "$PACKAGE_PATH" && "$SCAN_ALL" -eq 1 ]]; then
  usage >&2
  exit 2
fi

if [[ -z "$PACKAGE_PATH" && "$SCAN_ALL" -ne 1 ]]; then
  usage >&2
  exit 2
fi

resolve_package_dir() {
  local raw="$1"
  local candidate
  if [[ "$raw" = /* ]]; then
    candidate="$raw"
  else
    candidate="$ROOT_DIR/$raw"
  fi
  if [[ -f "$candidate" ]]; then
    candidate="$(dirname "$candidate")"
  fi
  if [[ ! -d "$candidate" ]]; then
    fail "package path not found: ${candidate#$ROOT_DIR/}"
    return 1
  fi
  (
    cd "$candidate"
    pwd
  )
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

check_file() {
  local file="$1"
  local label="$2"
  if [[ -f "$file" ]]; then
    pass "$label"
  else
    fail "$label"
  fi
}

check_dir() {
  local dir="$1"
  local label="$2"
  if [[ -d "$dir" ]]; then
    pass "$label"
  else
    fail "$label"
  fi
}

validate_enum() {
  local value="$1"
  local label="$2"
  shift 2
  local allowed
  for allowed in "$@"; do
    if [[ "$value" == "$allowed" ]]; then
      pass "$label"
      return 0
    fi
  done
  fail "$label"
  return 1
}

check_contains() {
  local file="$1"
  local needle="$2"
  local label="$3"
  if grep -Fq -- "$needle" "$file"; then
    pass "$label"
  else
    fail "$label"
  fi
}

check_absent() {
  local file="$1"
  local needle="$2"
  local label="$3"
  if grep -Fq -- "$needle" "$file"; then
    fail "$label"
  else
    pass "$label"
  fi
}

run_nested_validator() {
  local label="$1"
  local validator_rel="$2"
  local package_rel="$3"
  local validator_abs output rc=0

  validator_abs="$ROOT_DIR/$validator_rel"
  if [[ ! -f "$validator_abs" ]]; then
    fail "$label target missing: $validator_rel"
    return 1
  fi

  if [[ "$validator_abs" == "$SCRIPT_DIR/validate-design-package-standard.sh" ]]; then
    fail "$label must not reference the general validator itself"
    return 1
  fi

  if [[ "$validator_abs" == *.py ]]; then
    output="$(python3 "$validator_abs" "$package_rel" 2>&1)" || rc=$?
  else
    output="$(bash "$validator_abs" "$package_rel" 2>&1)" || rc=$?
  fi

  if [[ "$rc" -eq 0 ]]; then
    pass "$label passed: $validator_rel"
  else
    fail "$label failed: $validator_rel"
    printf '%s\n' "$output"
  fi
}

validate_selected_modules() {
  local manifest="$1"
  local package_label="$2"
  local -a modules=()
  local module
  declare -A seen=()

  mapfile -t modules < <(yq -r '.selected_modules[]?' "$manifest")
  for module in "${modules[@]}"; do
    case "$module" in
      contracts|conformance|reference|history|canonicalization)
        ;;
      *)
        fail "$package_label has unsupported selected_modules entry '$module'"
        continue
        ;;
    esac
    if [[ -n "${seen[$module]:-}" ]]; then
      fail "$package_label repeats selected_modules entry '$module'"
    else
      seen["$module"]=1
    fi
  done
}

module_selected() {
  local manifest="$1"
  local module="$2"
  yq -e ".selected_modules[] | select(. == \"$module\")" "$manifest" >/dev/null 2>&1
}

validate_implementation_targets() {
  local manifest="$1"
  local package_label="$2"
  local package_id="$3"
  local target_rel target_abs matches

  while IFS= read -r target_rel; do
    [[ -n "$target_rel" ]] || continue

    if [[ "$target_rel" == .design-packages/* ]]; then
      fail "$package_label implementation target must point outside .design-packages/: $target_rel"
      continue
    fi

    target_abs="$ROOT_DIR/$target_rel"
    if [[ ! -e "$target_abs" ]]; then
      warn "$package_label implementation target not present yet: $target_rel"
      continue
    fi

    matches="$(grep -R -n -F -- ".design-packages/$package_id" "$target_abs" 2>/dev/null || true)"
    if [[ -n "$matches" ]]; then
      fail "$package_label implementation target retains temporary package dependency: $target_rel"
      printf '%s\n' "$matches"
    else
      pass "$package_label implementation target avoids temporary package dependencies: $target_rel"
    fi
  done < <(yq -r '.implementation_targets[]?' "$manifest")
}

validate_package() {
  local package_dir="$1"
  local manifest="$package_dir/design-package.yml"
  local package_rel package_label package_id title summary package_class status
  local lifecycle_temporary exit_expectation default_audit_mode
  local package_validator_path conformance_validator_path implementation_targets_len
  local readme

  package_rel="$(rel_path "$package_dir")"
  package_label="package '$package_rel'"

  check_file "$manifest" "$package_label manifest exists"
  [[ -f "$manifest" ]] || return 0

  if ! yq -e '.' "$manifest" >/dev/null 2>&1; then
    fail "$package_label manifest parses as YAML"
    return 0
  fi
  pass "$package_label manifest parses as YAML"

  validate_enum "$(yaml_string "$manifest" '.schema_version')" \
    "$package_label schema_version is design-package-v1" "design-package-v1"

  package_id="$(yaml_string "$manifest" '.package_id')"
  title="$(yaml_string "$manifest" '.title')"
  summary="$(yaml_string "$manifest" '.summary')"
  package_class="$(yaml_string "$manifest" '.package_class')"
  status="$(yaml_string "$manifest" '.status')"
  lifecycle_temporary="$(yq -r '.lifecycle.temporary // ""' "$manifest")"
  exit_expectation="$(yaml_string "$manifest" '.lifecycle.exit_expectation')"
  default_audit_mode="$(yaml_string "$manifest" '.validation.default_audit_mode')"
  package_validator_path="$(yq -r '.validation.package_validator_path // "null"' "$manifest")"
  conformance_validator_path="$(yq -r '.validation.conformance_validator_path // "null"' "$manifest")"
  implementation_targets_len="$(yq -r '.implementation_targets | length' "$manifest")"

  if [[ "$package_id" == "$(basename "$package_dir")" ]]; then
    pass "$package_label package_id matches directory name"
  else
    fail "$package_label package_id must match directory name"
  fi

  [[ -n "$title" ]] && pass "$package_label title present" || fail "$package_label title present"
  [[ -n "$summary" ]] && pass "$package_label summary present" || fail "$package_label summary present"

  validate_enum "$package_class" \
    "$package_label package_class valid" \
    "domain-runtime" "experience-product"
  validate_enum "$status" \
    "$package_label status valid" \
    "draft" "in-review" "implementation-ready" "archived"
  validate_enum "$default_audit_mode" \
    "$package_label default audit mode valid" \
    "rigorous" "short"

  if [[ "$lifecycle_temporary" == "true" ]]; then
    pass "$package_label lifecycle.temporary remains true"
  else
    fail "$package_label lifecycle.temporary remains true"
  fi

  [[ -n "$exit_expectation" ]] && pass "$package_label exit expectation present" || fail "$package_label exit expectation present"

  if [[ "$implementation_targets_len" =~ ^[0-9]+$ ]] && [[ "$implementation_targets_len" -gt 0 ]]; then
    pass "$package_label implementation_targets must contain at least one path"
  else
    fail "$package_label implementation_targets must contain at least one path"
  fi

  validate_implementation_targets "$manifest" "$package_label" "$package_id"

  validate_selected_modules "$manifest" "$package_label"

  check_file "$package_dir/README.md" "$package_label core README exists"
  check_file "$package_dir/navigation/artifact-catalog.md" "$package_label artifact catalog exists"
  check_file "$package_dir/navigation/source-of-truth-map.md" "$package_label source-of-truth map exists"
  check_file "$package_dir/implementation/README.md" "$package_label implementation README exists"
  check_file "$package_dir/implementation/minimal-implementation-blueprint.md" "$package_label blueprint exists"
  check_file "$package_dir/implementation/first-implementation-plan.md" "$package_label first implementation plan exists"

  case "$package_class" in
    domain-runtime)
      check_file "$package_dir/normative/architecture/domain-model.md" "$package_label domain model exists"
      check_file "$package_dir/normative/architecture/runtime-architecture.md" "$package_label runtime architecture exists"
      check_file "$package_dir/normative/execution/behavior-model.md" "$package_label behavior model exists"
      check_file "$package_dir/normative/assurance/implementation-readiness.md" "$package_label implementation readiness exists"
      ;;
    experience-product)
      check_file "$package_dir/normative/experience/user-journeys.md" "$package_label user journeys exist"
      check_file "$package_dir/normative/experience/information-architecture.md" "$package_label information architecture exists"
      check_file "$package_dir/normative/experience/screen-states-and-flows.md" "$package_label screen states and flows exist"
      check_file "$package_dir/normative/assurance/implementation-readiness.md" "$package_label implementation readiness exists"
      ;;
  esac

  if module_selected "$manifest" "reference"; then
    check_file "$package_dir/reference/README.md" "$package_label reference module exists"
  fi

  if module_selected "$manifest" "history"; then
    check_file "$package_dir/history/README.md" "$package_label history module exists"
  fi

  if module_selected "$manifest" "contracts"; then
    check_file "$package_dir/contracts/README.md" "$package_label contracts README exists"
    check_dir "$package_dir/contracts/schemas" "$package_label contracts schemas dir exists"
    check_dir "$package_dir/contracts/fixtures/valid" "$package_label contracts valid fixtures dir exists"
    check_dir "$package_dir/contracts/fixtures/invalid" "$package_label contracts invalid fixtures dir exists"
  fi

  if module_selected "$manifest" "canonicalization"; then
    check_file "$package_dir/navigation/canonicalization-target-map.md" "$package_label canonicalization map exists"
  fi

  if module_selected "$manifest" "conformance"; then
    check_file "$package_dir/conformance/README.md" "$package_label conformance README exists"
    check_dir "$package_dir/conformance/scenarios" "$package_label conformance scenarios dir exists"
    if [[ "$conformance_validator_path" == "null" || -z "$conformance_validator_path" ]]; then
      fail "$package_label conformance module requires validation.conformance_validator_path"
    else
      pass "$package_label conformance validator path declared"
      run_nested_validator "$package_label conformance validator" "$conformance_validator_path" "$package_rel"
    fi
  fi

  if [[ "$package_validator_path" != "null" && -n "$package_validator_path" ]]; then
    run_nested_validator "$package_label package validator" "$package_validator_path" "$package_rel"
  fi

  readme="$package_dir/README.md"
  check_contains "$readme" "temporary, implementation-scoped design package" "$package_label README marks package temporary"
  check_contains "$readme" "not a canonical runtime" "$package_label README forbids canonical treatment"
  check_contains "$readme" "## Implementation Targets" "$package_label README includes implementation targets section"
  check_contains "$readme" "## Exit Path" "$package_label README includes exit path section"
  check_absent "$readme" "authoritative architecture specification" "$package_label README avoids forbidden authority phrase"
  check_absent "$readme" "source of truth" "$package_label README avoids forbidden source-of-truth phrase"
}

validate_all_standard_packages() {
  local found=0 manifest
  while IFS= read -r manifest; do
    [[ -z "$manifest" ]] && continue
    found=1
    validate_package "$(dirname "$manifest")"
  done < <(find "$ROOT_DIR/.design-packages" -name design-package.yml -type f | sort)

  if [[ "$found" -eq 0 ]]; then
    warn "no standard-governed design packages found under .design-packages/"
  fi
}

main() {
  echo "== Design Package Standard Validation =="

  if [[ -n "$PACKAGE_PATH" ]]; then
    local package_dir
    package_dir="$(resolve_package_dir "$PACKAGE_PATH")" || true
    if [[ -n "$package_dir" ]]; then
      validate_package "$package_dir"
    fi
  else
    validate_all_standard_packages
  fi

  echo "Validation summary: errors=$errors warnings=$warnings"
  if [[ "$errors" -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
