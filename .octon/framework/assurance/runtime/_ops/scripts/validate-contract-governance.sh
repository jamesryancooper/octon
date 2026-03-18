#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
OCTON_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

CONTEXT_INDEX="$OCTON_DIR/cognition/runtime/context/index.yml"
SPEC_FILE="$OCTON_DIR/cognition/_meta/architecture/specification.md"
RUNTIME_OPS_CONTRACT="$OCTON_DIR/cognition/_meta/architecture/runtime-vs-ops-contract.md"
ASSURANCE_PRECEDENCE="$OCTON_DIR/assurance/governance/precedence.md"
ENGINE_GOVERNANCE="$OCTON_DIR/engine/governance/README.md"

REPORT_DIR="$OCTON_DIR/output/assurance/results"
REPORT_FILE="$REPORT_DIR/contract-coverage-latest.md"

errors=0
warnings=0

tmpdir="$(mktemp -d)"
contracts_tsv="$tmpdir/contracts.tsv"
coverage_tsv="$tmpdir/coverage.tsv"
missing_metadata_tsv="$tmpdir/missing_metadata.tsv"
missing_contract_paths_tsv="$tmpdir/missing_contract_paths.tsv"
missing_enforcement_tsv="$tmpdir/missing_enforcement.tsv"
ops_violations_tsv="$tmpdir/ops_violations.tsv"

cleanup() {
  rm -rf "$tmpdir"
}
trap cleanup EXIT

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

require_file() {
  local file="$1"
  if [[ ! -f "$file" ]]; then
    fail "missing file: ${file#$ROOT_DIR/}"
  else
    pass "found file: ${file#$ROOT_DIR/}"
  fi
}

trim_value() {
  local value="$1"
  value="${value#\"}"
  value="${value%\"}"
  printf '%s' "$value"
}

extract_contract_registry() {
  awk '
    function trim(v) {
      gsub(/^[[:space:]]+/, "", v)
      gsub(/[[:space:]]+$/, "", v)
      gsub(/^"/, "", v)
      gsub(/"$/, "", v)
      return v
    }

    function flush_entry() {
      if (in_entry == 1) {
        print contract_id "\t" contract_path "\t" owner "\t" version "\t" supersedes "\t" enforced_by
      }
      in_entry = 0
      in_enforced = 0
      contract_id = ""
      contract_path = ""
      owner = ""
      version = ""
      supersedes = ""
      enforced_by = ""
    }

    BEGIN {
      in_contracts = 0
      in_entry = 0
      in_enforced = 0
      contract_id = ""
      contract_path = ""
      owner = ""
      version = ""
      supersedes = ""
      enforced_by = ""
    }

    /^contracts:[[:space:]]*$/ {
      in_contracts = 1
      next
    }

    in_contracts == 1 {
      if ($0 ~ /^[^[:space:]]/ || $0 ~ /^files:[[:space:]]*$/ || $0 ~ /^ops_mutation_policy:[[:space:]]*$/) {
        flush_entry()
        in_contracts = 0
        next
      }

      if ($0 ~ /^  - contract_id:[[:space:]]*/) {
        flush_entry()
        in_entry = 1
        in_enforced = 0
        line = $0
        sub(/^  - contract_id:[[:space:]]*/, "", line)
        contract_id = trim(line)
        next
      }

      if (in_entry == 0) {
        next
      }

      if ($0 ~ /^    path:[[:space:]]*/) {
        line = $0
        sub(/^    path:[[:space:]]*/, "", line)
        contract_path = trim(line)
        in_enforced = 0
        next
      }

      if ($0 ~ /^    owner:[[:space:]]*/) {
        line = $0
        sub(/^    owner:[[:space:]]*/, "", line)
        owner = trim(line)
        in_enforced = 0
        next
      }

      if ($0 ~ /^    version:[[:space:]]*/) {
        line = $0
        sub(/^    version:[[:space:]]*/, "", line)
        version = trim(line)
        in_enforced = 0
        next
      }

      if ($0 ~ /^    supersedes:[[:space:]]*/) {
        line = $0
        sub(/^    supersedes:[[:space:]]*/, "", line)
        supersedes = trim(line)
        in_enforced = 0
        next
      }

      if ($0 ~ /^    enforced_by:[[:space:]]*$/) {
        in_enforced = 1
        next
      }

      if (in_enforced == 1 && $0 ~ /^      - /) {
        line = $0
        sub(/^      - /, "", line)
        line = trim(line)
        if (length(enforced_by) == 0) {
          enforced_by = line
        } else {
          enforced_by = enforced_by "|" line
        }
        next
      }

      if (in_enforced == 1 && $0 !~ /^      - /) {
        in_enforced = 0
      }
    }

    END {
      flush_entry()
    }
  ' "$CONTEXT_INDEX"
}

extract_ops_policy_list() {
  local key="$1"
  awk -v key="$key" '
    function trim(v) {
      gsub(/^[[:space:]]+/, "", v)
      gsub(/[[:space:]]+$/, "", v)
      gsub(/^"/, "", v)
      gsub(/"$/, "", v)
      return v
    }

    /^ops_mutation_policy:[[:space:]]*$/ {
      in_policy = 1
      next
    }

    in_policy == 1 {
      if ($0 ~ /^[^[:space:]]/) {
        in_policy = 0
        in_target = 0
        next
      }

      if ($0 ~ "^  " key ":[[:space:]]*$") {
        in_target = 1
        next
      }

      if (in_target == 1 && $0 ~ /^  [a-z_]+:[[:space:]]*$/ && $0 !~ "^  " key ":[[:space:]]*$") {
        in_target = 0
      }

      if (in_target == 1 && $0 ~ /^    - /) {
        line = $0
        sub(/^    - /, "", line)
        print trim(line)
      }
    }
  ' "$CONTEXT_INDEX"
}

count_lines() {
  local file="$1"
  if [[ -s "$file" ]]; then
    wc -l < "$file" | tr -d ' '
  else
    echo "0"
  fi
}

check_required_contract_text() {
  if grep -Fq "Default Mutation Allowlist (Fail-Closed)" "$RUNTIME_OPS_CONTRACT"; then
    pass "runtime-vs-ops contract declares default mutation allowlist"
  else
    fail "runtime-vs-ops contract missing default mutation allowlist section"
  fi

  if grep -Fq 'Immutable Targets for `_ops/` Automation' "$RUNTIME_OPS_CONTRACT"; then
    pass "runtime-vs-ops contract declares immutable targets"
  else
    fail "runtime-vs-ops contract missing immutable targets section"
  fi

  if grep -Fq "OCTON-SPEC-015" "$SPEC_FILE"; then
    pass "umbrella specification contains OCTON-SPEC-015"
  else
    fail "umbrella specification missing OCTON-SPEC-015"
  fi

  if grep -Fq "OCTON-SPEC-016" "$SPEC_FILE"; then
    pass "umbrella specification contains OCTON-SPEC-016"
  else
    fail "umbrella specification missing OCTON-SPEC-016"
  fi

  if grep -Fq "Runtime Authority Tie-Breaker" "$ASSURANCE_PRECEDENCE"; then
    pass "assurance precedence declares runtime authority tie-breaker"
  else
    fail "assurance precedence missing runtime authority tie-breaker section"
  fi

  if grep -Fq "Runtime Authority Contract (ENGINE-GOV-001)" "$ENGINE_GOVERNANCE"; then
    pass "engine governance declares engine/capabilities runtime split"
  else
    fail "engine governance missing runtime authority contract section"
  fi
}

check_ops_mutation_policy_metadata() {
  local list_file
  local key
  local rel
  local abs
  local found

  for key in allow_write_roots immutable_targets enforce_with; do
    list_file="$tmpdir/ops-policy-${key}.txt"
    extract_ops_policy_list "$key" > "$list_file"

    if [[ ! -s "$list_file" ]]; then
      fail "ops_mutation_policy.${key} has no entries in cognition/runtime/context/index.yml"
      continue
    fi

    pass "ops_mutation_policy.${key} entries declared"
    found=0
    while IFS= read -r rel; do
      [[ -z "$rel" ]] && continue
      found=1
      abs="$OCTON_DIR/cognition/runtime/context/$rel"
      if [[ "$key" == "enforce_with" ]]; then
        if [[ -f "$abs" ]]; then
          pass "ops_mutation_policy.${key} path resolves: $rel"
        else
          fail "ops_mutation_policy.${key} path missing: $rel"
        fi
      else
        if [[ -e "$abs" ]]; then
          pass "ops_mutation_policy.${key} target resolves: $rel"
        else
          fail "ops_mutation_policy.${key} target missing: $rel"
        fi
      fi
    done < "$list_file"

    if [[ $found -eq 0 ]]; then
      fail "ops_mutation_policy.${key} contains no usable entries"
    fi
  done
}

check_contract_registry() {
  local context_dir="$OCTON_DIR/cognition/runtime/context"
  local contract_count
  local duplicate_ids
  local contract_id
  local contract_path
  local owner
  local version
  local supersedes
  local enforced_by
  local display_id
  local status
  local notes
  local enforcement_count
  local enforcement_path
  local enforcement_abs
  local contract_abs
  local entry_num=0

  extract_contract_registry > "$contracts_tsv"

  if [[ ! -s "$contracts_tsv" ]]; then
    fail "no contracts declared in cognition/runtime/context/index.yml"
    return
  fi

  contract_count="$(wc -l < "$contracts_tsv" | tr -d ' ')"
  pass "contract registry entries found: $contract_count"

  duplicate_ids="$(cut -f1 "$contracts_tsv" | sed '/^$/d' | sort | uniq -d || true)"
  if [[ -n "$duplicate_ids" ]]; then
    while IFS= read -r duplicate_id; do
      [[ -z "$duplicate_id" ]] && continue
      fail "duplicate contract_id in registry: $duplicate_id"
      echo "$duplicate_id|duplicate contract_id" >> "$missing_metadata_tsv"
    done <<< "$duplicate_ids"
  else
    pass "contract_id values are unique"
  fi

  while IFS=$'\t' read -r contract_id contract_path owner version supersedes enforced_by; do
    entry_num=$((entry_num + 1))
    display_id="$contract_id"
    [[ -z "$display_id" ]] && display_id="(entry-$entry_num)"
    status="PASS"
    notes=""
    enforcement_count=0

    if [[ -z "$contract_id" ]]; then
      fail "contract entry $entry_num missing contract_id"
      echo "$display_id|contract_id" >> "$missing_metadata_tsv"
      status="FAIL"
      notes="missing contract_id"
    fi

    if [[ -z "$contract_path" ]]; then
      fail "contract $display_id missing path"
      echo "$display_id|path" >> "$missing_metadata_tsv"
      status="FAIL"
      notes="${notes:+$notes; }missing path"
    else
      contract_abs="$context_dir/$contract_path"
      if [[ -f "$contract_abs" ]]; then
        pass "contract path resolves: $display_id -> $contract_path"
      else
        fail "contract path missing: $display_id -> $contract_path"
        echo "$display_id|$contract_path" >> "$missing_contract_paths_tsv"
        status="FAIL"
        notes="${notes:+$notes; }missing contract path"
      fi
    fi

    if [[ -z "$owner" ]]; then
      fail "contract $display_id missing owner"
      echo "$display_id|owner" >> "$missing_metadata_tsv"
      status="FAIL"
      notes="${notes:+$notes; }missing owner"
    fi

    if [[ -z "$version" ]]; then
      fail "contract $display_id missing version"
      echo "$display_id|version" >> "$missing_metadata_tsv"
      status="FAIL"
      notes="${notes:+$notes; }missing version"
    fi

    if [[ -z "$supersedes" ]]; then
      fail "contract $display_id missing supersedes"
      echo "$display_id|supersedes" >> "$missing_metadata_tsv"
      status="FAIL"
      notes="${notes:+$notes; }missing supersedes"
    fi

    if [[ -z "$enforced_by" ]]; then
      fail "contract $display_id has no enforced_by paths"
      echo "$display_id|enforced_by" >> "$missing_enforcement_tsv"
      status="FAIL"
      notes="${notes:+$notes; }missing enforcement bindings"
    else
      IFS='|' read -r -a enforcement_paths <<< "$enforced_by"
      enforcement_count="${#enforcement_paths[@]}"
      for enforcement_path in "${enforcement_paths[@]}"; do
        enforcement_path="$(trim_value "$enforcement_path")"
        [[ -z "$enforcement_path" ]] && continue
        enforcement_abs="$context_dir/$enforcement_path"
        if [[ -e "$enforcement_abs" ]]; then
          pass "enforcement path resolves: $display_id -> $enforcement_path"
        else
          fail "enforcement path missing: $display_id -> $enforcement_path"
          echo "$display_id|$enforcement_path" >> "$missing_enforcement_tsv"
          status="FAIL"
          notes="${notes:+$notes; }missing enforcement path"
        fi
      done
    fi

    [[ -z "$notes" ]] && notes="ok"
    echo -e "${display_id}\t${owner:-<missing>}\t${version:-<missing>}\t${contract_path:-<missing>}\t${enforcement_count}\t${status}\t${notes}" >> "$coverage_tsv"
  done < "$contracts_tsv"
}

check_ops_boundary_violations() {
  local file
  local rel
  local base

  while IFS= read -r file; do
    rel="${file#$ROOT_DIR/}"
    base="$(basename "$file")"

    case "$base" in
      manifest.yml|registry.yml|capabilities.yml|SKILL.md|README.md|SERVICE.md|AGENT.md|SOUL.md|CONSTITUTION.md|DELEGATION.md|MEMORY.md)
        echo "$rel|canonical artifact under _ops/" >> "$ops_violations_tsv"
        ;;
    esac

    if [[ "$rel" == *"/_ops/"*"/governance/"* ]]; then
      echo "$rel|governance artifact nested under _ops/" >> "$ops_violations_tsv"
    fi
  done < <(find "$OCTON_DIR" -path "*/_ops/*" -type f)

  if [[ -s "$ops_violations_tsv" ]]; then
    while IFS='|' read -r path reason; do
      fail "_ops boundary violation: ${path} (${reason})"
    done < "$ops_violations_tsv"
  else
    pass "no _ops boundary violations detected"
  fi
}

write_report() {
  local generated_utc
  local status
  local contract_count
  local missing_metadata_count
  local missing_contract_paths_count
  local missing_enforcement_count
  local ops_violations_count
  local contract_id
  local owner
  local version
  local path
  local enforcement_count
  local row_status
  local notes
  local escaped_notes
  local tmp_report
  local existing_generated_utc
  local existing_normalized
  local candidate_normalized

  generated_utc="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  status="PASS"
  if [[ $errors -gt 0 ]]; then
    status="FAIL"
  fi

  contract_count="$(count_lines "$contracts_tsv")"
  missing_metadata_count="$(count_lines "$missing_metadata_tsv")"
  missing_contract_paths_count="$(count_lines "$missing_contract_paths_tsv")"
  missing_enforcement_count="$(count_lines "$missing_enforcement_tsv")"
  ops_violations_count="$(count_lines "$ops_violations_tsv")"

  mkdir -p "$REPORT_DIR"
  tmp_report="$(mktemp "${REPORT_FILE}.tmp.XXXXXX")"

  {
    echo "# Contract Coverage and Boundary Report"
    echo
    echo "- generated_utc: $generated_utc"
    echo "- status: $status"
    echo "- contracts_indexed: $contract_count"
    echo "- missing_metadata: $missing_metadata_count"
    echo "- missing_contract_paths: $missing_contract_paths_count"
    echo "- missing_enforcement_bindings: $missing_enforcement_count"
    echo "- ops_boundary_violations: $ops_violations_count"
    echo
    echo "## Coverage Table"
    echo
    echo "| Contract ID | Owner | Version | Contract Path | Enforcement Paths | Status | Notes |"
    echo "|---|---|---|---|---:|---|---|"
    while IFS=$'\t' read -r contract_id owner version path enforcement_count row_status notes; do
      escaped_notes="${notes//|/; }"
      echo "| $contract_id | $owner | $version | $path | $enforcement_count | $row_status | $escaped_notes |"
    done < "$coverage_tsv"

    if [[ -s "$missing_metadata_tsv" ]]; then
      echo
      echo "## Missing Metadata"
      while IFS='|' read -r contract_id field; do
        echo "- \`$contract_id\`: missing \`$field\`"
      done < "$missing_metadata_tsv"
    fi

    if [[ -s "$missing_contract_paths_tsv" ]]; then
      echo
      echo "## Missing Contract Paths"
      while IFS='|' read -r contract_id path; do
        echo "- \`$contract_id\`: \`$path\`"
      done < "$missing_contract_paths_tsv"
    fi

    if [[ -s "$missing_enforcement_tsv" ]]; then
      echo
      echo "## Missing Enforcement Bindings"
      while IFS='|' read -r contract_id path; do
        echo "- \`$contract_id\`: \`$path\`"
      done < "$missing_enforcement_tsv"
    fi

    if [[ -s "$ops_violations_tsv" ]]; then
      echo
      echo "## `_ops` Boundary Violations"
      while IFS='|' read -r path reason; do
        echo "- \`$path\`: $reason"
      done < "$ops_violations_tsv"
    fi
  } > "$tmp_report"

  if [[ -f "$REPORT_FILE" ]]; then
    existing_generated_utc="$(awk '/^- generated_utc:/ {print $3; exit}' "$REPORT_FILE")"
    existing_normalized="$(sed -E 's/^- generated_utc: .*/- generated_utc: __GENERATED_UTC__/' "$REPORT_FILE")"
    candidate_normalized="$(sed -E 's/^- generated_utc: .*/- generated_utc: __GENERATED_UTC__/' "$tmp_report")"
    if [[ -n "$existing_generated_utc" ]] && [[ "$existing_normalized" == "$candidate_normalized" ]]; then
      generated_utc="$existing_generated_utc"
      sed -i.bak -E "s/^- generated_utc: .*/- generated_utc: $generated_utc/" "$tmp_report"
      rm -f "$tmp_report.bak"
    fi
  fi

  mv "$tmp_report" "$REPORT_FILE"

  pass "wrote contract coverage report: ${REPORT_FILE#$ROOT_DIR/}"
}

main() {
  echo "== Contract Governance Validation =="

  require_file "$CONTEXT_INDEX"
  require_file "$SPEC_FILE"
  require_file "$RUNTIME_OPS_CONTRACT"
  require_file "$ASSURANCE_PRECEDENCE"
  require_file "$ENGINE_GOVERNANCE"

  check_required_contract_text
  check_ops_mutation_policy_metadata
  check_contract_registry
  check_ops_boundary_violations
  write_report

  echo
  echo "Validation summary: errors=$errors warnings=$warnings"
  if [[ $errors -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
