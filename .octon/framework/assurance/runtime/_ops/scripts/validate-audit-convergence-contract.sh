#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
OCTON_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

METHODOLOGY_DIR="$OCTON_DIR/cognition/practices/methodology/audits"
RUNTIME_DIR="$OCTON_DIR/cognition/runtime/audits"
REPORTS_DIR="$OCTON_DIR/output/reports/audits"
RUNTIME_INDEX="$RUNTIME_DIR/index.yml"

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

matches_pattern() {
  local pattern="$1"
  local file="$2"
  if command -v rg >/dev/null 2>&1; then
    rg -q -- "$pattern" "$file"
  else
    grep -Eq -- "$pattern" "$file"
  fi
}

require_file() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    fail "missing file: ${file#$ROOT_DIR/}"
  else
    pass "found file: ${file#$ROOT_DIR/}"
  fi
}

require_dir() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    fail "missing directory: ${dir#$ROOT_DIR/}"
  else
    pass "found directory: ${dir#$ROOT_DIR/}"
  fi
}

extract_runtime_records() {
  local index_file="$1"
  awk '
    /^[[:space:]]+- id:[[:space:]]*/ {
      id=$0
      sub(/^[[:space:]]+- id:[[:space:]]*/, "", id)
      gsub(/"/, "", id)
    }
    /^[[:space:]]+path:[[:space:]]*/ {
      path=$0
      sub(/^[[:space:]]+path:[[:space:]]*/, "", path)
      gsub(/"/, "", path)
    }
    /^[[:space:]]+evidence:[[:space:]]*/ {
      evidence=$0
      sub(/^[[:space:]]+evidence:[[:space:]]*/, "", evidence)
      gsub(/"/, "", evidence)
      print id "\t" path "\t" evidence
      id=""
      path=""
      evidence=""
    }
  ' "$index_file"
}

validate_runtime_index_records() {
  if [[ ! -f "$RUNTIME_INDEX" ]]; then
    fail "missing runtime audit index: ${RUNTIME_INDEX#$ROOT_DIR/}"
    return
  fi

  local matched=0
  local id path evidence
  while IFS=$'\t' read -r id path evidence; do
    [[ -z "$id" ]] && continue
    matched=1

    if [[ -z "$path" || -z "$evidence" ]]; then
      fail "audit runtime record missing required path/evidence fields: $id"
      continue
    fi

    if [[ ! -f "$RUNTIME_DIR/$path" ]]; then
      fail "audit runtime record plan path missing on disk: ${RUNTIME_INDEX#$ROOT_DIR/} -> $path"
    else
      pass "audit runtime record plan exists: ${RUNTIME_INDEX#$ROOT_DIR/} -> $path"
    fi

    if [[ ! -f "$RUNTIME_DIR/$evidence" ]]; then
      fail "audit runtime record evidence pointer missing on disk: ${RUNTIME_INDEX#$ROOT_DIR/} -> $evidence"
    else
      pass "audit runtime record evidence exists: ${RUNTIME_INDEX#$ROOT_DIR/} -> $evidence"
    fi
  done < <(extract_runtime_records "$RUNTIME_INDEX")

  if [[ $matched -eq 0 ]]; then
    pass "runtime audit index contains no records (allowed)"
  fi
}

validate_findings_ids() {
  local findings_file="$1"

  local ids
  ids="$(awk '/^[[:space:]]*-[[:space:]]+id:[[:space:]]*/ {line=$0; sub(/^[[:space:]]*-[[:space:]]+id:[[:space:]]*/, "", line); gsub(/"/, "", line); print line}' "$findings_file")"

  if [[ -z "$ids" ]]; then
    pass "findings.yml has no finding IDs (empty set allowed): ${findings_file#$ROOT_DIR/}"
    return
  fi

  local dupes
  dupes="$(printf '%s\n' "$ids" | sort | uniq -d || true)"
  if [[ -n "$dupes" ]]; then
    fail "duplicate finding IDs in ${findings_file#$ROOT_DIR/}: $(echo "$dupes" | paste -sd ', ' -)"
  else
    pass "finding IDs are unique: ${findings_file#$ROOT_DIR/}"
  fi

  local missing_acceptance
  missing_acceptance="$(
    awk '
      function flush() {
        if (current_id != "" && has_acceptance == 0) {
          print current_id
        }
      }
      /^[[:space:]]*-[[:space:]]+id:[[:space:]]*/ {
        flush()
        current_id=$0
        sub(/^[[:space:]]*-[[:space:]]+id:[[:space:]]*/, "", current_id)
        gsub(/"/, "", current_id)
        has_acceptance=0
        next
      }
      /^[[:space:]]+acceptance_criteria:[[:space:]]*/ {
        if (current_id != "") {
          has_acceptance=1
        }
      }
      END { flush() }
    ' "$findings_file"
  )"

  if [[ -n "$missing_acceptance" ]]; then
    fail "findings missing acceptance_criteria in ${findings_file#$ROOT_DIR/}: $(echo "$missing_acceptance" | paste -sd ', ' -)"
  else
    pass "acceptance_criteria present for findings in ${findings_file#$ROOT_DIR/}"
  fi
}

validate_coverage_file() {
  local coverage_file="$1"

  local unaccounted
  unaccounted="$(awk '
    /^[[:space:]]*unaccounted_files:[[:space:]]*/ {
      line=$0
      sub(/^[[:space:]]*unaccounted_files:[[:space:]]*/, "", line)
      gsub(/"/, "", line)
      print line
      exit
    }
  ' "$coverage_file")"

  if [[ -z "$unaccounted" ]]; then
    fail "coverage file missing unaccounted_files field: ${coverage_file#$ROOT_DIR/}"
    return
  fi

  if [[ ! "$unaccounted" =~ ^[0-9]+$ ]]; then
    fail "coverage file has non-numeric unaccounted_files value (${unaccounted}): ${coverage_file#$ROOT_DIR/}"
    return
  fi

  if [[ "$unaccounted" -gt 0 ]]; then
    fail "coverage has unaccounted files (${unaccounted}) in ${coverage_file#$ROOT_DIR/}"
  else
    pass "coverage unaccounted_files is zero: ${coverage_file#$ROOT_DIR/}"
  fi
}

validate_convergence_receipt() {
  local convergence_file="$1"

  local required_keys
  required_keys=(commit_sha scope_hash prompt_hash findings_hash params_hash)

  local key
  for key in "${required_keys[@]}"; do
    if matches_pattern "^[[:space:]]*${key}:[[:space:]]*" "$convergence_file"; then
      pass "convergence metadata includes ${key}: ${convergence_file#$ROOT_DIR/}"
    else
      fail "convergence metadata missing ${key}: ${convergence_file#$ROOT_DIR/}"
    fi
  done

  if matches_pattern "^[[:space:]]*seed:[[:space:]]*" "$convergence_file" || matches_pattern "^[[:space:]]*seed_unsupported:[[:space:]]*true" "$convergence_file"; then
    pass "convergence metadata includes seed policy: ${convergence_file#$ROOT_DIR/}"
  else
    fail "convergence metadata missing seed policy: ${convergence_file#$ROOT_DIR/}"
  fi

  if matches_pattern "^[[:space:]]*system_fingerprint:[[:space:]]*" "$convergence_file" || matches_pattern "^[[:space:]]*fingerprint_unsupported:[[:space:]]*true" "$convergence_file"; then
    pass "convergence metadata includes fingerprint policy: ${convergence_file#$ROOT_DIR/}"
  else
    fail "convergence metadata missing fingerprint policy: ${convergence_file#$ROOT_DIR/}"
  fi

  local done_gate_keys
  done_gate_keys=(stable union_blocking_findings open_findings_at_or_above_threshold done)

  for key in "${done_gate_keys[@]}"; do
    if matches_pattern "^[[:space:]]*${key}:[[:space:]]*" "$convergence_file"; then
      pass "convergence metadata includes done-gate key ${key}: ${convergence_file#$ROOT_DIR/}"
    else
      fail "convergence metadata missing done-gate key ${key}: ${convergence_file#$ROOT_DIR/}"
    fi
  done

  local stable_value union_value open_value done_value
  stable_value="$(awk '/^[[:space:]]*stable:[[:space:]]*/ {line=$0; sub(/^[[:space:]]*stable:[[:space:]]*/, "", line); gsub(/"/, "", line); print line; exit}' "$convergence_file")"
  union_value="$(awk '/^[[:space:]]*union_blocking_findings:[[:space:]]*/ {line=$0; sub(/^[[:space:]]*union_blocking_findings:[[:space:]]*/, "", line); gsub(/"/, "", line); print line; exit}' "$convergence_file")"
  open_value="$(awk '/^[[:space:]]*open_findings_at_or_above_threshold:[[:space:]]*/ {line=$0; sub(/^[[:space:]]*open_findings_at_or_above_threshold:[[:space:]]*/, "", line); gsub(/"/, "", line); print line; exit}' "$convergence_file")"
  done_value="$(awk '/^[[:space:]]*done:[[:space:]]*/ {line=$0; sub(/^[[:space:]]*done:[[:space:]]*/, "", line); gsub(/"/, "", line); print line; exit}' "$convergence_file")"

  if [[ ! "$union_value" =~ ^[0-9]+$ ]]; then
    fail "convergence union_blocking_findings must be numeric: ${convergence_file#$ROOT_DIR/}"
  fi

  if [[ ! "$open_value" =~ ^[0-9]+$ ]]; then
    fail "convergence open_findings_at_or_above_threshold must be numeric: ${convergence_file#$ROOT_DIR/}"
  fi

  if [[ "$done_value" == "true" ]]; then
    if [[ "$stable_value" != "true" ]]; then
      fail "done=true requires stable=true: ${convergence_file#$ROOT_DIR/}"
    else
      pass "done=true stable gate satisfied: ${convergence_file#$ROOT_DIR/}"
    fi

    if [[ "$union_value" != "0" ]]; then
      fail "done=true requires union_blocking_findings=0: ${convergence_file#$ROOT_DIR/}"
    else
      pass "done=true union gate satisfied: ${convergence_file#$ROOT_DIR/}"
    fi

    if [[ "$open_value" != "0" ]]; then
      fail "done=true requires open_findings_at_or_above_threshold=0: ${convergence_file#$ROOT_DIR/}"
    else
      pass "done=true open-finding gate satisfied: ${convergence_file#$ROOT_DIR/}"
    fi
  fi
}

validate_bundle_metadata() {
  local bundle_dir="$1"
  local bundle_file="$bundle_dir/bundle.yml"
  local bundle_name
  bundle_name="$(basename "$bundle_dir")"

  if [[ ! -f "$bundle_file" ]]; then
    fail "bundle missing metadata file: ${bundle_file#$ROOT_DIR/}"
    return
  fi

  if matches_pattern '^kind:[[:space:]]*"?audit-evidence-bundle"?$' "$bundle_file"; then
    pass "bundle kind valid: ${bundle_file#$ROOT_DIR/}"
  else
    fail "bundle kind must be audit-evidence-bundle: ${bundle_file#$ROOT_DIR/}"
  fi

  if matches_pattern "^id:[[:space:]]*\"?${bundle_name}\"?$" "$bundle_file"; then
    pass "bundle id matches directory: ${bundle_file#$ROOT_DIR/}"
  else
    fail "bundle id must match directory name (${bundle_name}): ${bundle_file#$ROOT_DIR/}"
  fi

  if matches_pattern '^findings:[[:space:]]*"?findings\.yml"?$' "$bundle_file"; then
    pass "bundle findings pointer valid: ${bundle_file#$ROOT_DIR/}"
  else
    fail "bundle findings pointer must be findings.yml: ${bundle_file#$ROOT_DIR/}"
  fi

  if matches_pattern '^coverage:[[:space:]]*"?coverage\.yml"?$' "$bundle_file"; then
    pass "bundle coverage pointer valid: ${bundle_file#$ROOT_DIR/}"
  else
    fail "bundle coverage pointer must be coverage.yml: ${bundle_file#$ROOT_DIR/}"
  fi

  if matches_pattern '^convergence:[[:space:]]*"?convergence\.yml"?$' "$bundle_file"; then
    pass "bundle convergence pointer valid: ${bundle_file#$ROOT_DIR/}"
  else
    fail "bundle convergence pointer must be convergence.yml: ${bundle_file#$ROOT_DIR/}"
  fi

  if matches_pattern '^evidence:[[:space:]]*"?evidence\.md"?$' "$bundle_file"; then
    pass "bundle evidence pointer valid: ${bundle_file#$ROOT_DIR/}"
  else
    fail "bundle evidence pointer must be evidence.md: ${bundle_file#$ROOT_DIR/}"
  fi

  if matches_pattern '^commands:[[:space:]]*"?commands\.md"?$' "$bundle_file"; then
    pass "bundle commands pointer valid: ${bundle_file#$ROOT_DIR/}"
  else
    fail "bundle commands pointer must be commands.md: ${bundle_file#$ROOT_DIR/}"
  fi

  if matches_pattern '^validation:[[:space:]]*"?validation\.md"?$' "$bundle_file"; then
    pass "bundle validation pointer valid: ${bundle_file#$ROOT_DIR/}"
  else
    fail "bundle validation pointer must be validation.md: ${bundle_file#$ROOT_DIR/}"
  fi

  if matches_pattern '^inventory:[[:space:]]*"?inventory\.md"?$' "$bundle_file"; then
    pass "bundle inventory pointer valid: ${bundle_file#$ROOT_DIR/}"
  else
    fail "bundle inventory pointer must be inventory.md: ${bundle_file#$ROOT_DIR/}"
  fi
}

bundle_dir_has_materialized_contract_files() {
  local bundle_dir="$1"
  local contract_file
  local contract_files
  contract_files=(bundle.yml findings.yml coverage.yml convergence.yml evidence.md commands.md validation.md inventory.md)

  for contract_file in "${contract_files[@]}"; do
    if [[ -f "$bundle_dir/$contract_file" ]]; then
      return 0
    fi
  done

  return 1
}

bundle_dir_has_tracked_files() {
  local bundle_dir="$1"
  local bundle_rel="$1"

  bundle_rel="${bundle_dir#$ROOT_DIR/}"
  if ! git -C "$ROOT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    return 1
  fi

  if [[ -n "$(git -C "$ROOT_DIR" ls-files -- "$bundle_rel")" ]]; then
    return 0
  fi

  return 1
}

bundle_dir_is_authoritative() {
  local bundle_dir="$1"

  if bundle_dir_has_tracked_files "$bundle_dir"; then
    return 0
  fi

  if bundle_dir_has_materialized_contract_files "$bundle_dir"; then
    return 0
  fi

  return 1
}

validate_report_bundles() {
  require_dir "$REPORTS_DIR"
  require_file "$REPORTS_DIR/README.md"

  local flat_files
  flat_files="$(find "$REPORTS_DIR" -mindepth 1 -maxdepth 1 -type f -name '20*-*.md' | sort || true)"
  if [[ -n "$flat_files" ]]; then
    fail "flat bounded-audit markdown files are forbidden in output/reports/audits/"
  else
    pass "no flat bounded-audit markdown files in output/reports/audits/"
  fi

  local discovered_bundle_dirs
  mapfile -t discovered_bundle_dirs < <(find "$REPORTS_DIR" -mindepth 1 -maxdepth 1 -type d -name '20*-*' | sort)

  if [[ ${#discovered_bundle_dirs[@]} -eq 0 ]]; then
    pass "no bounded-audit bundles found yet (allowed)"
    return
  fi

  local bundle_dirs=()
  local discovered_bundle
  for discovered_bundle in "${discovered_bundle_dirs[@]}"; do
    if bundle_dir_is_authoritative "$discovered_bundle"; then
      bundle_dirs+=("$discovered_bundle")
    else
      pass "skipping non-authoritative audit workspace directory: ${discovered_bundle#$ROOT_DIR/}"
    fi
  done

  if [[ ${#bundle_dirs[@]} -eq 0 ]]; then
    pass "no authoritative bounded-audit bundles found yet (allowed)"
    return
  fi

  pass "found ${#bundle_dirs[@]} authoritative bounded-audit bundle directories"

  local required_files
  required_files=(bundle.yml findings.yml coverage.yml convergence.yml evidence.md commands.md validation.md inventory.md)

  local bundle required
  for bundle in "${bundle_dirs[@]}"; do
    validate_bundle_metadata "$bundle"

    for required in "${required_files[@]}"; do
      if [[ ! -f "$bundle/$required" ]]; then
        fail "bundle missing required file (${required}): ${bundle#$ROOT_DIR/}"
      else
        pass "bundle file present (${required}): ${bundle#$ROOT_DIR/}"
      fi
    done

    if [[ -f "$bundle/findings.yml" ]]; then
      validate_findings_ids "$bundle/findings.yml"
    fi

    if [[ -f "$bundle/coverage.yml" ]]; then
      validate_coverage_file "$bundle/coverage.yml"
    fi

    if [[ -f "$bundle/convergence.yml" ]]; then
      validate_convergence_receipt "$bundle/convergence.yml"
    fi
  done
}

main() {
  echo "== Audit Convergence Contract Validation =="

  require_dir "$METHODOLOGY_DIR"
  require_file "$METHODOLOGY_DIR/README.md"
  require_file "$METHODOLOGY_DIR/index.yml"
  require_file "$METHODOLOGY_DIR/doctrine.md"
  require_file "$METHODOLOGY_DIR/invariants.md"
  require_file "$METHODOLOGY_DIR/exceptions.md"
  require_file "$METHODOLOGY_DIR/ci-gates.md"
  require_file "$METHODOLOGY_DIR/findings-contract.md"

  require_dir "$RUNTIME_DIR"
  require_file "$RUNTIME_DIR/README.md"
  require_file "$RUNTIME_INDEX"

  validate_runtime_index_records
  validate_report_bundles

  echo
  echo "Validation summary: errors=$errors warnings=$warnings"
  if [[ $errors -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
