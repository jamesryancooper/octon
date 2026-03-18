#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
OCTON_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

MANIFEST_FILE="$OCTON_DIR/octon.yml"

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

require_file() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    fail "missing file: ${file#$ROOT_DIR/}"
  else
    pass "found file: ${file#$ROOT_DIR/}"
  fi
}

extract_root_scalar() {
  local key="$1"
  awk -v key="$key" '
    $0 ~ "^" key ":[[:space:]]*" {
      line=$0
      sub("^" key ":[[:space:]]*", "", line)
      sub(/[[:space:]]+#.*/, "", line)
      gsub(/^"/, "", line)
      gsub(/"$/, "", line)
      print line
      exit
    }
  ' "$MANIFEST_FILE"
}

extract_harness_scalar() {
  local key="$1"
  awk -v key="$key" '
    /^versioning:[[:space:]]*$/ { in_versioning=1; next }

    in_versioning == 1 {
      if ($0 ~ /^[^[:space:]]/) {
        in_versioning=0
        in_harness=0
      }

      if ($0 ~ /^  harness:[[:space:]]*$/) {
        in_harness=1
        next
      }

      if (in_harness == 1 && $0 ~ /^  [^[:space:]]/) {
        in_harness=0
      }

      if (in_harness == 1 && $0 ~ "^    " key ":[[:space:]]*") {
        line=$0
        sub("^    " key ":[[:space:]]*", "", line)
        sub(/[[:space:]]+#.*/, "", line)
        gsub(/^"/, "", line)
        gsub(/"$/, "", line)
        print line
        exit
      }
    }
  ' "$MANIFEST_FILE"
}

extract_harness_list() {
  local key="$1"
  awk -v key="$key" '
    /^versioning:[[:space:]]*$/ { in_versioning=1; next }

    in_versioning == 1 {
      if ($0 ~ /^[^[:space:]]/) {
        in_versioning=0
        in_harness=0
        in_list=0
      }

      if ($0 ~ /^  harness:[[:space:]]*$/) {
        in_harness=1
        next
      }

      if (in_harness == 1 && $0 ~ /^  [^[:space:]]/) {
        in_harness=0
        in_list=0
      }

      if (in_harness == 1 && $0 ~ "^    " key ":[[:space:]]*$") {
        in_list=1
        next
      }

      if (in_list == 1) {
        if ($0 ~ /^      - /) {
          line=$0
          sub(/^      - /, "", line)
          sub(/[[:space:]]+#.*/, "", line)
          gsub(/^"/, "", line)
          gsub(/"$/, "", line)
          print line
          next
        }

        if ($0 ~ /^    [a-zA-Z0-9_]+:[[:space:]]*/ || $0 ~ /^  [^[:space:]]/ || $0 ~ /^[^[:space:]]/) {
          in_list=0
        }
      }
    }
  ' "$MANIFEST_FILE"
}

value_in_list() {
  local needle="$1"
  shift
  local value
  for value in "$@"; do
    if [[ "$value" == "$needle" ]]; then
      return 0
    fi
  done
  return 1
}

main() {
  echo "== Harness Version Contract Validation =="

  require_file "$MANIFEST_FILE"
  if [[ ! -f "$MANIFEST_FILE" ]]; then
    echo "Validation summary: errors=$errors"
    exit 1
  fi

  local schema_version
  schema_version="$(extract_root_scalar "schema_version")"
  if [[ -z "$schema_version" ]]; then
    fail "missing root schema_version in ${MANIFEST_FILE#$ROOT_DIR/}"
  else
    pass "root schema_version detected: $schema_version"
  fi

  mapfile -t supported_versions < <(extract_harness_list "supported_schema_versions")
  if [[ "${#supported_versions[@]}" -eq 0 ]]; then
    fail "missing versioning.harness.supported_schema_versions in ${MANIFEST_FILE#$ROOT_DIR/}"
  else
    pass "supported schema versions declared (${#supported_versions[@]})"
  fi

  local rejection_mode
  rejection_mode="$(extract_harness_scalar "rejection_mode")"
  if [[ "$rejection_mode" != "fail-closed" ]]; then
    fail "versioning.harness.rejection_mode must be 'fail-closed' (found '${rejection_mode:-<empty>}')"
  else
    pass "rejection mode is fail-closed"
  fi

  local migration_workflow migration_overview
  migration_workflow="$(extract_harness_scalar "migration_workflow")"
  migration_overview="$(extract_harness_scalar "migration_overview")"

  if [[ -z "$migration_workflow" ]]; then
    fail "missing versioning.harness.migration_workflow"
  elif [[ ! -f "$OCTON_DIR/$migration_workflow" ]]; then
    fail "migration_workflow target missing: .octon/$migration_workflow"
  else
    pass "migration workflow path resolves: .octon/$migration_workflow"
  fi

  if [[ -z "$migration_overview" ]]; then
    fail "missing versioning.harness.migration_overview"
  elif [[ ! -f "$OCTON_DIR/$migration_overview" ]]; then
    fail "migration_overview target missing: .octon/$migration_overview"
  else
    pass "migration overview path resolves: .octon/$migration_overview"
  fi

  mapfile -t deterministic_steps < <(extract_harness_list "deterministic_upgrade_instructions")
  if [[ "${#deterministic_steps[@]}" -eq 0 ]]; then
    fail "missing versioning.harness.deterministic_upgrade_instructions"
  else
    pass "deterministic upgrade instructions declared (${#deterministic_steps[@]})"
  fi

  if [[ -n "$schema_version" && "${#supported_versions[@]}" -gt 0 ]]; then
    if value_in_list "$schema_version" "${supported_versions[@]}"; then
      pass "schema_version '$schema_version' is supported"
    else
      fail "unsupported harness schema_version '$schema_version' (supported: $(IFS=,; echo "${supported_versions[*]}"))"
      echo "Deterministic upgrade instructions:"
      local step
      for step in "${deterministic_steps[@]}"; do
        echo "  - $step"
      done
    fi
  fi

  echo "Validation summary: errors=$errors"
  if [[ $errors -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
