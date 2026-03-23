#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
REGISTRY_FILE="${ALIGNMENT_REGISTRY_FILE:-$OCTON_DIR/framework/assurance/runtime/contracts/alignment-profiles.yml}"
RUNNER_FILE="${ALIGNMENT_RUNNER_FILE:-$OCTON_DIR/framework/assurance/runtime/_ops/scripts/alignment-check.sh}"
WORKFLOW_FILE="${ALIGNMENT_WORKFLOW_FILE:-$ROOT_DIR/.github/workflows/alignment-check.yml}"

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

has_pattern() {
  local pattern="$1"
  local file="$2"
  if command -v rg >/dev/null 2>&1; then
    rg -q "$pattern" "$file"
  else
    grep -Eq "$pattern" "$file"
  fi
}

has_text() {
  local text="$1"
  local file="$2"
  if command -v rg >/dev/null 2>&1; then
    rg -Fq "$text" "$file"
  else
    grep -Fq "$text" "$file"
  fi
}

require_file() {
  local file="$1"
  if [[ -f "$file" ]]; then
    pass "found file: ${file#$ROOT_DIR/}"
  else
    fail "missing file: ${file#$ROOT_DIR/}"
  fi
}

check_workflow_contract() {
  if has_pattern 'type:[[:space:]]*choice' "$WORKFLOW_FILE"; then
    fail "alignment-check workflow must not duplicate profile ids through a choice input"
  else
    pass "alignment-check workflow keeps profile input freeform"
  fi

  if has_text 'bash .octon/framework/assurance/runtime/_ops/scripts/alignment-check.sh "${args[@]}"' "$WORKFLOW_FILE"; then
    pass "alignment-check workflow delegates to the shared runner"
  else
    fail "alignment-check workflow must delegate to the shared runner"
  fi
}

main() {
  echo "== Alignment Profile Registry Validation =="

  require_file "$REGISTRY_FILE"
  require_file "$RUNNER_FILE"
  require_file "$WORKFLOW_FILE"

  if ! command -v yq >/dev/null 2>&1; then
    fail "yq is required for alignment profile validation"
    exit 1
  fi

  if [[ "$(yq -r '.schema_version // ""' "$REGISTRY_FILE")" == "alignment-profiles-v1" ]]; then
    pass "alignment profile registry schema version is correct"
  else
    fail "alignment profile registry schema version must be alignment-profiles-v1"
  fi

  local duplicate_ids
  duplicate_ids="$(yq -r '.profiles[]?.id // ""' "$REGISTRY_FILE" | awk 'NF' | sort | uniq -d || true)"
  if [[ -n "$duplicate_ids" ]]; then
    fail "alignment profile ids must be unique"
    printf '%s\n' "$duplicate_ids"
  else
    pass "alignment profile ids are unique"
  fi

  local profile_id
  while IFS= read -r profile_id; do
    [[ -n "$profile_id" ]] || continue

    local entrypoint label dry_run_safe consumers
    entrypoint="$(yq -r ".profiles[] | select(.id == \"$profile_id\") | .entrypoint // \"\"" "$REGISTRY_FILE")"
    label="$(yq -r ".profiles[] | select(.id == \"$profile_id\") | .label // \"\"" "$REGISTRY_FILE")"
    dry_run_safe="$(yq -r ".profiles[] | select(.id == \"$profile_id\") | .dry_run_safe" "$REGISTRY_FILE")"
    consumers="$(yq -r ".profiles[] | select(.id == \"$profile_id\") | .consumers[]?" "$REGISTRY_FILE" | tr '\n' ' ')"

    [[ -n "$label" ]] && pass "profile $profile_id declares a label" || fail "profile $profile_id must declare a label"
    [[ "$dry_run_safe" == "true" || "$dry_run_safe" == "false" ]] \
      && pass "profile $profile_id declares a boolean dry_run_safe" \
      || fail "profile $profile_id must declare a boolean dry_run_safe"

    if [[ -n "$entrypoint" ]] && has_pattern "^${entrypoint}[[:space:]]*\\(" "$RUNNER_FILE"; then
      pass "profile $profile_id entrypoint exists in alignment-check.sh"
    else
      fail "profile $profile_id entrypoint '$entrypoint' is missing from alignment-check.sh"
    fi

    if [[ -n "$consumers" ]]; then
      local consumers_valid=true consumer
      while IFS= read -r consumer; do
        [[ -n "$consumer" ]] || continue
        if [[ "$consumer" != "local" && "$consumer" != "ci" ]]; then
          consumers_valid=false
          break
        fi
      done < <(yq -r ".profiles[] | select(.id == \"$profile_id\") | .consumers[]?" "$REGISTRY_FILE")

      if [[ "$consumers_valid" == "true" ]]; then
        pass "profile $profile_id consumer set is valid"
      else
        fail "profile $profile_id consumers must be a non-empty subset of [local, ci]"
      fi
    else
      fail "profile $profile_id consumers must be a non-empty subset of [local, ci]"
    fi

    local required_path
    while IFS= read -r required_path; do
      [[ -n "$required_path" ]] || continue
      if [[ "$required_path" =~ ^\.octon/(agency|orchestration|capabilities|assurance)(/|$) ]]; then
        fail "profile $profile_id references retired top-level root: $required_path"
        continue
      fi

      if [[ -e "$ROOT_DIR/$required_path" ]]; then
        pass "profile $profile_id required path exists: $required_path"
      else
        fail "profile $profile_id required path is missing: $required_path"
      fi
    done < <(yq -r ".profiles[] | select(.id == \"$profile_id\") | .required_paths[]?" "$REGISTRY_FILE")
  done < <(yq -r '.profiles[]?.id // ""' "$REGISTRY_FILE")

  check_workflow_contract

  echo "Validation summary: errors=$errors"
  if [[ "$errors" -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
