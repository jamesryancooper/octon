#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
cd "$ROOT_DIR"

PRINCIPLES_DIR="${PRINCIPLES_DIR_OVERRIDE:-.octon/framework/cognition/governance/principles}"
REFERENCE_LINT="${REFERENCE_LINT_OVERRIDE:-.octon/framework/cognition/_ops/principles/scripts/reference-lint.sh}"
OVERRIDE_LEDGER="${PRINCIPLES_OVERRIDE_LEDGER_OVERRIDE:-.octon/framework/cognition/governance/exceptions/principles-charter-overrides.md}"
PRINCIPLES_INDEX="$PRINCIPLES_DIR/index.yml"
CHARTER_MAP="$PRINCIPLES_DIR/charter-map.yml"
CONTROLS_DIR=".octon/framework/cognition/governance/controls"
CONVIVIAL_CONTROL_MD="$CONTROLS_DIR/convivial-impact-minimums.md"
CONVIVIAL_CONTROL_YML="$CONTROLS_DIR/convivial-impact-minimums.yml"
CONTROLS_INDEX="$CONTROLS_DIR/index.yml"
TIER2_TEMPLATE=".octon/framework/cognition/practices/methodology/templates/spec-tier2.yaml"
TIER3_TEMPLATE=".octon/framework/cognition/practices/methodology/templates/spec-tier3.yaml"
PR_TEMPLATE=".github/PULL_REQUEST_TEMPLATE.md"
PR_TEMPLATE_KAIZEN=".github/PULL_REQUEST_TEMPLATE/kaizen.md"
PRINCIPLES_README="$PRINCIPLES_DIR/README.md"

declare -i failures=0

if [[ ! -d "$PRINCIPLES_DIR" ]]; then
  echo "[missing-dir] principles directory not found: $PRINCIPLES_DIR"
  exit 1
fi

if ! command -v rg >/dev/null 2>&1; then
  rg() {
    local opt_n=0 opt_i=0 opt_q=0 opt_c=0 opt_v=0 opt_x=0 opt_fixed=0
    local pattern=""
    local token=""
    local -a targets=()

    while (($#)); do
      token="$1"
      case "$token" in
        -n) opt_n=1 ;;
        -i) opt_i=1 ;;
        -q) opt_q=1 ;;
        -c) opt_c=1 ;;
        -v) opt_v=1 ;;
        -x) opt_x=1 ;;
        -F) opt_fixed=1 ;;
        --glob|--type|--type-not|--max-columns)
          shift
          ;;
        --glob=*|--type=*|--type-not=*|--max-columns=*)
          ;;
        --hidden|--no-ignore|--multiline|--pcre2)
          ;;
        --)
          shift
          break
          ;;
        -*)
          ;;
        *)
          if [[ -z "$pattern" ]]; then
            pattern="$token"
          else
            targets+=("$token")
          fi
          ;;
      esac
      shift
    done

    while (($#)); do
      targets+=("$1")
      shift
    done

    local -a grep_opts=()
    ((opt_n)) && grep_opts+=("-n")
    ((opt_i)) && grep_opts+=("-i")
    ((opt_q)) && grep_opts+=("-q")
    ((opt_c)) && grep_opts+=("-c")
    ((opt_v)) && grep_opts+=("-v")
    ((opt_x)) && grep_opts+=("-x")
    if ((opt_fixed)); then
      grep_opts+=("-F")
    else
      grep_opts+=("-E")
    fi

    if [[ -z "$pattern" ]]; then
      echo "[rg-shim] missing search pattern" >&2
      return 2
    fi

    if ((${#targets[@]} == 0)); then
      grep "${grep_opts[@]}" -- "$pattern"
      return
    fi

    local recurse=0
    local p=""
    for p in "${targets[@]}"; do
      if [[ -d "$p" ]]; then
        recurse=1
        break
      fi
    done

    if ((recurse)); then
      grep "${grep_opts[@]}" -R -- "$pattern" "${targets[@]}"
    else
      grep "${grep_opts[@]}" -- "$pattern" "${targets[@]}"
    fi
  }
fi

file_changed_in_active_scope() {
  local target="$1"
  local base_ref="${LINT_BASE_REF:-}"

  if ! command -v git >/dev/null 2>&1; then
    return 1
  fi

  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    return 1
  fi

  if git diff --name-only -- "$target" | rg -q '.'; then
    return 0
  fi

  if git diff --cached --name-only -- "$target" | rg -q '.'; then
    return 0
  fi

  if git ls-files --others --exclude-standard -- "$target" | rg -q '.'; then
    return 0
  fi

  if [[ -n "$base_ref" ]] && git rev-parse -q --verify "${base_ref}^{commit}" >/dev/null 2>&1; then
    if git diff --name-only "${base_ref}"...HEAD -- "$target" | rg -q '.'; then
      return 0
    fi
  elif git rev-parse -q --verify HEAD~1 >/dev/null 2>&1; then
    if git diff --name-only HEAD~1..HEAD -- "$target" | rg -q '.'; then
      return 0
    fi
  fi

  return 1
}

extract_latest_override_record_block() {
  local ledger="$1"
  local start end

  start="$(rg -n '^### OVR-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{3}$' "$ledger" | tail -n1 | cut -d: -f1 || true)"
  if [[ -z "$start" ]]; then
    return 1
  fi

  end="$(awk -v start="$start" '
    NR > start && /^### OVR-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{3}$/ {
      print NR - 1
      found = 1
      exit
    }
    END {
      if (!found) {
        print NR
      }
    }
  ' "$ledger")"

  sed -n "${start},${end}p" "$ledger"
}

check_principles_charter_change_control() {
  local charter="$PRINCIPLES_DIR/principles.md"
  local override_ledger="$OVERRIDE_LEDGER"
  local field=""
  local -a required_fields=(
    'rationale'
    'responsible owner'
    'review date'
    'override scope'
    'review-and-agreement evidence'
    'intentional, non-automated exception'
  )
  local -a ledger_required_fields=(
    'date'
    'rationale'
    'responsible_owner'
    'review_date'
    'override_scope'
    'review_and_agreement_evidence'
    'exception_log_ref'
    'authorized_by'
    'authorization_source'
    'break_glass'
    'status'
  )
  local latest_record=""

  if [[ ! -f "$charter" ]]; then
    echo "[charter-policy] missing charter: $charter"
    failures+=1
    return
  fi

  if ! rg -q -i '^status:[[:space:]]*binding$' "$charter"; then
    echo "[charter-policy] charter must declare 'status: Binding'."
    failures+=1
  fi

  if ! rg -q '^mutability:[[:space:]]*immutable$' "$charter"; then
    echo "[charter-policy] charter must declare 'mutability: immutable'."
    failures+=1
  fi

  if ! rg -q '^agent_editable:[[:space:]]*false$' "$charter"; then
    echo "[charter-policy] charter must declare 'agent_editable: false'."
    failures+=1
  fi

  if ! rg -q '^risk_tier:[[:space:]]*critical$' "$charter"; then
    echo "[charter-policy] charter must declare 'risk_tier: critical'."
    failures+=1
  fi

  if ! rg -q '^change_policy:[[:space:]]*human-override-only$' "$charter"; then
    echo "[charter-policy] charter must declare 'change_policy: human-override-only'."
    failures+=1
  fi

  if ! rg -q '^## 0C\) Charter Evolution Contract' "$charter"; then
    echo "[charter-policy] charter must define '0C) Charter Evolution Contract'."
    failures+=1
  fi

  if ! rg -q -i 'explicit human override' "$charter"; then
    echo "[charter-policy] charter must require explicit human override for governed edits."
    failures+=1
  fi

  for field in "${required_fields[@]}"; do
    if ! rg -q -i "$field" "$charter"; then
      echo "[charter-policy] charter missing required override field: $field"
      failures+=1
    fi
  done

  if ! rg -q -i 'Automation may propose framing changes' "$charter"; then
    echo "[charter-policy] charter must define automation limits for major framing-shift overrides."
    failures+=1
  fi

  if ! rg -q -i 'must not approve or apply major' "$charter"; then
    echo "[charter-policy] charter must prevent automation from approving/applying major framing-shift overrides."
    failures+=1
  fi

  if ! rg -q 'principles-charter-overrides\.md' "$charter"; then
    echo "[charter-policy] charter must reference the principles charter override ledger."
    failures+=1
  fi

  if [[ ! -f "$override_ledger" ]]; then
    echo "[charter-policy] missing override ledger: $override_ledger"
    failures+=1
    return
  fi

  if ! rg -q '^## Record Format \(Required Fields\)' "$override_ledger"; then
    echo "[charter-policy] override ledger must define a 'Record Format (Required Fields)' section."
    failures+=1
  fi

  if ! rg -q '^## Records \(Append-Only\)' "$override_ledger"; then
    echo "[charter-policy] override ledger must define a 'Records (Append-Only)' section."
    failures+=1
  fi

  if file_changed_in_active_scope "$charter"; then
    if ! file_changed_in_active_scope "$override_ledger"; then
      echo "[charter-policy] charter changed without corresponding append-only override ledger update."
      failures+=1
    fi
  fi

  latest_record="$(extract_latest_override_record_block "$override_ledger" || true)"
  if [[ -z "$latest_record" ]]; then
    echo "[charter-policy] override ledger must contain at least one override record heading (### OVR-YYYY-MM-DD-NNN)."
    failures+=1
    return
  fi

  if ! printf '%s\n' "$latest_record" | head -n1 | rg -q '^### OVR-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{3}$'; then
    echo "[charter-policy] latest override ledger record must use id format OVR-YYYY-MM-DD-NNN."
    failures+=1
  fi

  for field in "${ledger_required_fields[@]}"; do
    if ! printf '%s\n' "$latest_record" | rg -q "^- ${field}:[[:space:]]*[^[:space:]].*$"; then
      echo "[charter-policy] latest override ledger record missing required field: $field"
      failures+=1
    fi
  done

  if ! printf '%s\n' "$latest_record" | rg -q '^- break_glass:[[:space:]]*(true|false)$'; then
    echo "[charter-policy] override ledger break_glass must be true or false."
    failures+=1
  fi

  if ! printf '%s\n' "$latest_record" | rg -q '^- status:[[:space:]]*(active|closed|retired)$'; then
    echo "[charter-policy] override ledger status must be active, closed, or retired."
    failures+=1
  fi
}

check_forbidden_terms() {
  local file=""
  local line=""
  local pattern=""

  local -a forbidden=(
    '\bHITL\b'
    'hard checkpoint'
    'must approve'
    'authorization checkpoint'
    'hitl-checkpoints\.md'
  )

  while IFS= read -r file; do
    for pattern in "${forbidden[@]}"; do
      while IFS= read -r line; do
        if [[ "$line" =~ [Dd]eprecated || "$line" =~ [Nn]o[[:space:]]+longer || "$line" =~ [Rr]emoved ]]; then
          continue
        fi
        echo "[forbidden-term] $file: $line"
        failures+=1
      done < <(rg -n -i "$pattern" "$file" || true)
    done
  done < <(find "$PRINCIPLES_DIR" -type f -name '*.md' | sort)
}

check_pr_only_runtime_gating() {
  local raw_hits filtered_hits

  raw_hits="$(rg -n -i '\b(must|required|requires)\b[^\n]{0,120}\bPR\b' "$PRINCIPLES_DIR" --glob '*.md' || true)"

  filtered_hits="$(printf '%s\n' "$raw_hits" | rg -i -v 'if a PR exists|projection|receipt|acp|promot|guidance' || true)"
  if [[ -n "$filtered_hits" ]]; then
    echo "[pr-only-gating] Found PR-only normative language without ACP/receipt equivalence:"
    printf '%s\n' "$filtered_hits"
    failures+=1
  fi
}

check_human_approval_runtime_dependency() {
  local pattern negation_pattern raw_hits hits

  pattern='require[sd]?(ing)?[^[:cntrl:]\n]{0,80}human approval|must[^[:cntrl:]\n]{0,80}be[^[:cntrl:]\n]{0,40}approved[^[:cntrl:]\n]{0,40}by[^[:cntrl:]\n]{0,20}human|block[^[:cntrl:]\n]{0,80}until[^[:cntrl:]\n]{0,40}approved'
  negation_pattern='does not require[^[:cntrl:]\n]{0,80}human approval|do not require[^[:cntrl:]\n]{0,80}human approval|not[^[:cntrl:]\n]{0,40}human approval|no[^[:cntrl:]\n]{0,40}human[^[:cntrl:]\n]{0,20}approval|not[^[:cntrl:]\n]{0,40}default runtime gate|optional review'

  raw_hits="$(rg -n -i "$pattern" "$PRINCIPLES_DIR" --glob '*.md' || true)"
  hits="$(printf '%s\n' "$raw_hits" | rg -i -v "$negation_pattern" || true)"
  if [[ -n "$hits" ]]; then
    echo "[runtime-human-gate] Found runtime dependency on human approval language:"
    printf '%s\n' "$hits"
    failures+=1
  fi
}

check_arbitration_ssot_drift() {
  local arbitration_doc="$PRINCIPLES_DIR/arbitration-and-precedence.md"
  local duplicate

  duplicate="$(rg -n '^##[[:space:]]+Arbitration and Precedence' "$PRINCIPLES_DIR" --glob '*.md' --glob '!**/arbitration-and-precedence.md' || true)"
  if [[ -n "$duplicate" ]]; then
    echo "[arbitration-drift] duplicate 'Arbitration and Precedence' section outside SSOT:"
    printf '%s\n' "$duplicate"
    failures+=1
  fi

  if [[ ! -f "$arbitration_doc" ]]; then
    echo "[arbitration-drift] missing arbitration SSOT: $arbitration_doc"
    failures+=1
  fi
}

check_stale_migration_phrasing() {
  local acp_doc="$PRINCIPLES_DIR/autonomous-control-points.md"
  local stale_hits

  if [[ ! -f "$acp_doc" ]]; then
    echo "[stale-migration] missing ACP principle file: $acp_doc"
    failures+=1
    return
  fi

  if ! rg -q '## Historical Note \(Non-Normative\)' "$acp_doc"; then
    echo "[stale-migration] ACP historical note heading missing."
    failures+=1
  fi

  stale_hits="$(rg -n -i 'manual runtime checkpoint|manual review gate|human-on-the-loop' "$PRINCIPLES_DIR" --glob '*.md' --glob '!**/autonomous-control-points.md' || true)"
  if [[ -n "$stale_hits" ]]; then
    echo "[stale-migration] stale migration phrasing found outside ACP historical note:"
    printf '%s\n' "$stale_hits"
    failures+=1
  fi
}

check_arbitration_pointer_standardization() {
  local legacy
  local file
  local pointer='See \[Arbitration and Precedence\]\(\./arbitration-and-precedence\.md\) \(SSOT\) for conflict resolution\.'
  local -a required=(
    "$PRINCIPLES_DIR/autonomous-control-points.md"
    "$PRINCIPLES_DIR/deny-by-default.md"
    "$PRINCIPLES_DIR/determinism.md"
    "$PRINCIPLES_DIR/guardrails.md"
    "$PRINCIPLES_DIR/no-silent-apply.md"
    "$PRINCIPLES_DIR/observability-as-a-contract.md"
    "$PRINCIPLES_DIR/ownership-and-boundaries.md"
    "$PRINCIPLES_DIR/reversibility.md"
    "$PRINCIPLES_DIR/small-diffs-trunk-based.md"
  )

  legacy="$(rg -n 'If this principle conflicts with another, apply|normative arbitration rules live only in the|This section is informational only' "$PRINCIPLES_DIR" --glob '*.md' || true)"
  if [[ -n "$legacy" ]]; then
    echo "[arbitration-pointer] legacy arbitration boilerplate detected:"
    printf '%s\n' "$legacy"
    failures+=1
  fi

  for file in "${required[@]}"; do
    if [[ ! -f "$file" ]]; then
      echo "[arbitration-pointer] missing required principle file: $file"
      failures+=1
      continue
    fi
    if ! rg -q "$pointer" "$file"; then
      echo "[arbitration-pointer] missing standardized arbitration pointer: $file"
      failures+=1
    fi
  done
}

check_contraction_finalize_glossary() {
  local glossary=".octon/framework/cognition/governance/controls/ra-acp-glossary.md"

  if [[ ! -f "$glossary" ]]; then
    echo "[glossary-contraction] missing glossary: $glossary"
    failures+=1
    return
  fi

  if ! rg -q '`finalize`' "$glossary"; then
    echo "[glossary-contraction] glossary must define `finalize`."
    failures+=1
  fi

  if ! rg -q '`contraction`:[^[:cntrl:]\n]{0,120}alias' "$glossary"; then
    echo "[glossary-contraction] glossary must define `contraction` as alias semantics."
    failures+=1
  fi
}

check_waiver_exception_ssot_links() {
  local file
  local references_pattern='waivers-and-exceptions\.md'
  local terms_pattern='\bwaiver(s)?\b|\bexception(s)?\b'
  local -a required=(
    "$PRINCIPLES_DIR/accessibility-baseline.md"
    "$PRINCIPLES_DIR/guardrails.md"
    "$PRINCIPLES_DIR/security-and-privacy-baseline.md"
    "$PRINCIPLES_DIR/small-diffs-trunk-based.md"
    "$PRINCIPLES_DIR/deny-by-default.md"
    "$PRINCIPLES_DIR/autonomous-control-points.md"
  )

  for file in "${required[@]}"; do
    if [[ ! -f "$file" ]]; then
      echo "[waiver-exception-ssot] missing required principle file: $file"
      failures+=1
      continue
    fi
    if ! rg -q -i "$terms_pattern" "$file"; then
      continue
    fi
    if ! rg -q "$references_pattern" "$file"; then
      echo "[waiver-exception-ssot] $file uses waiver/exception language without SSOT reference"
      failures+=1
    fi
  done
}

check_canonical_matrix_links() {
  local file count
  local -a required=(
    "$PRINCIPLES_DIR/autonomous-control-points.md"
    "$PRINCIPLES_DIR/documentation-is-code.md"
    "$PRINCIPLES_DIR/observability-as-a-contract.md"
    "$PRINCIPLES_DIR/contract-first.md"
  )

  for file in "${required[@]}"; do
    if [[ ! -f "$file" ]]; then
      echo "[canonical-matrix] missing required principle file: $file"
      failures+=1
      continue
    fi
    count="$(rg -c 'ra-acp-promotion-inputs-matrix\.md' "$file" || true)"
    if [[ "$count" -ne 1 ]]; then
      echo "[canonical-matrix] $file must include exactly one matrix link; found $count"
      failures+=1
    fi
  done
}

check_canonical_glossary_links() {
  local file count
  local -a required=(
    "$PRINCIPLES_DIR/autonomous-control-points.md"
    "$PRINCIPLES_DIR/deny-by-default.md"
    "$PRINCIPLES_DIR/documentation-is-code.md"
    "$PRINCIPLES_DIR/observability-as-a-contract.md"
    "$PRINCIPLES_DIR/contract-first.md"
    "$PRINCIPLES_DIR/no-silent-apply.md"
    "$PRINCIPLES_DIR/ownership-and-boundaries.md"
    "$PRINCIPLES_DIR/determinism.md"
    "$PRINCIPLES_DIR/determinism-and-provenance.md"
  )

  for file in "${required[@]}"; do
    if [[ ! -f "$file" ]]; then
      echo "[canonical-glossary] missing required principle file: $file"
      failures+=1
      continue
    fi
    count="$(rg -c 'ra-acp-glossary\.md' "$file" || true)"
    if [[ "$count" -lt 1 ]]; then
      echo "[canonical-glossary] $file must reference RA/ACP glossary."
      failures+=1
    fi
  done
}

check_risk_mapping_reference() {
  local file
  local -a required=(
    "$PRINCIPLES_DIR/autonomous-control-points.md"
    "$PRINCIPLES_DIR/observability-as-a-contract.md"
  )

  for file in "${required[@]}"; do
    if [[ ! -f "$file" ]]; then
      echo "[risk-mapping] missing required principle file: $file"
      failures+=1
      continue
    fi
    if ! rg -q 'acp\.risk_tier_mapping|risk tier to ACP mapping is policy-canonical' "$file"; then
      echo "[risk-mapping] $file must reference policy-canonical risk tier mapping."
      failures+=1
    fi
  done

  local redeclared
  redeclared="$(rg -n '\|[[:space:]]*Risk tier[[:space:]]*\|[[:space:]]*ACP level[[:space:]]*\|' "$PRINCIPLES_DIR" --glob '*.md' || true)"
  if [[ -n "$redeclared" ]]; then
    echo "[risk-mapping] Risk tier to ACP table is re-declared outside canonical matrix:"
    printf '%s\n' "$redeclared"
    failures+=1
  fi
}

check_principles_index_contract() {
  local missing_fields duplicate_ids duplicate_paths
  local -a indexed_markdown actual_markdown

  if [[ ! -f "$PRINCIPLES_INDEX" ]]; then
    echo "[index-contract] missing principles index: $PRINCIPLES_INDEX"
    failures+=1
    return
  fi

  missing_fields="$(awk '
    function trim(v) { gsub(/^[[:space:]]+|[[:space:]]+$/, "", v); return v }
    function flush_entry() {
      if (!in_entry) return
      if (!has_class) print id " missing classification"
      if (!has_lifecycle) print id " missing lifecycle"
      if (!has_path) print id " missing path"
      if (!has_summary) print id " missing summary"
      if (!has_when) print id " missing when"
    }
    /^[[:space:]]*-[[:space:]]id:[[:space:]]*/ {
      flush_entry()
      in_entry = 1
      line = $0
      sub(/^[[:space:]]*-[[:space:]]id:[[:space:]]*/, "", line)
      id = trim(line)
      has_class = has_lifecycle = has_path = has_summary = has_when = 0
      next
    }
    in_entry && /^[[:space:]]+classification:[[:space:]]*/ { has_class = 1; next }
    in_entry && /^[[:space:]]+lifecycle:[[:space:]]*/ { has_lifecycle = 1; next }
    in_entry && /^[[:space:]]+path:[[:space:]]*/ { has_path = 1; next }
    in_entry && /^[[:space:]]+summary:[[:space:]]*/ { has_summary = 1; next }
    in_entry && /^[[:space:]]+when:[[:space:]]*/ { has_when = 1; next }
    END { flush_entry() }
  ' "$PRINCIPLES_INDEX")"
  if [[ -n "$missing_fields" ]]; then
    echo "[index-contract] principles index entries missing required fields:"
    printf '%s\n' "$missing_fields"
    failures+=1
  fi

  duplicate_ids="$(awk '/^[[:space:]]*-[[:space:]]id:[[:space:]]*/ { sub(/^[[:space:]]*-[[:space:]]id:[[:space:]]*/, "", $0); print $0 }' "$PRINCIPLES_INDEX" | sort | uniq -d || true)"
  if [[ -n "$duplicate_ids" ]]; then
    echo "[index-contract] duplicate principle index ids detected:"
    printf '%s\n' "$duplicate_ids"
    failures+=1
  fi

  duplicate_paths="$(awk '/^[[:space:]]+path:[[:space:]]*/ { sub(/^[[:space:]]+path:[[:space:]]*/, "", $0); print $0 }' "$PRINCIPLES_INDEX" | sort | uniq -d || true)"
  if [[ -n "$duplicate_paths" ]]; then
    echo "[index-contract] duplicate principle index paths detected:"
    printf '%s\n' "$duplicate_paths"
    failures+=1
  fi

  mapfile -t indexed_markdown < <(awk '/^[[:space:]]+path:[[:space:]]*/ { sub(/^[[:space:]]+path:[[:space:]]*/, "", $0); if ($0 ~ /\.md$/) print $0 }' "$PRINCIPLES_INDEX" | sort -u)
  mapfile -t actual_markdown < <(find "$PRINCIPLES_DIR" -maxdepth 1 -type f -name '*.md' -exec basename {} \; | sort)

  local missing_from_index=""
  local stale_in_index=""
  local f=""
  for f in "${actual_markdown[@]}"; do
    if ! printf '%s\n' "${indexed_markdown[@]}" | rg -qx "$f"; then
      missing_from_index+="$f"$'\n'
    fi
  done
  for f in "${indexed_markdown[@]}"; do
    if ! printf '%s\n' "${actual_markdown[@]}" | rg -qx "$f"; then
      stale_in_index+="$f"$'\n'
    fi
  done

  if [[ -n "$missing_from_index" ]]; then
    echo "[index-coverage] markdown files present in principles dir but not indexed:"
    printf '%s' "$missing_from_index"
    failures+=1
  fi

  if [[ -n "$stale_in_index" ]]; then
    echo "[index-coverage] indexed markdown paths missing from principles dir:"
    printf '%s' "$stale_in_index"
    failures+=1
  fi
}

check_superseded_principle_clutter() {
  local hits
  hits="$(rg -n -i '^status:[[:space:]]*superseded$' "$PRINCIPLES_DIR" --glob '*.md' || true)"
  if [[ -n "$hits" ]]; then
    echo "[superseded-clutter] superseded principle files are not allowed in active principles directory:"
    printf '%s\n' "$hits"
    failures+=1
  fi
}

check_charter_map_contract() {
  local id count mapped_guides

  if [[ ! -f "$CHARTER_MAP" ]]; then
    echo "[charter-map] missing charter map: $CHARTER_MAP"
    failures+=1
    return
  fi

  if ! rg -q '^schema_version:[[:space:]]*"1\.0"$' "$CHARTER_MAP"; then
    echo "[charter-map] charter map must declare schema_version 1.0."
    failures+=1
  fi

  for id in P1 P2 P3 P4 P5 P6 P7 P8 P9 P10; do
    count="$(rg -c "^[[:space:]]*-[[:space:]]id:[[:space:]]*$id$" "$CHARTER_MAP" || true)"
    if [[ "$count" -ne 1 ]]; then
      echo "[charter-map] expected exactly one charter map entry for $id; found $count"
      failures+=1
    fi
  done

  mapped_guides="$(awk '
    /^[[:space:]]+guides:[[:space:]]*$/ { in_guides = 1; next }
    in_guides && /^[[:space:]]+-[[:space:]]+[a-z0-9._-]+\.md$/ {
      line = $0
      sub(/^[[:space:]]+-[[:space:]]+/, "", line)
      print line
      next
    }
    in_guides && !/^[[:space:]]+-[[:space:]]+/ { in_guides = 0 }
  ' "$CHARTER_MAP" | sort -u)"
  if [[ -z "$mapped_guides" ]]; then
    echo "[charter-map] charter map must contain at least one mapped guide."
    failures+=1
  else
    while IFS= read -r id; do
      [[ -z "$id" ]] && continue
      if [[ ! -f "$PRINCIPLES_DIR/$id" ]]; then
        echo "[charter-map] mapped guide does not exist: $id"
        failures+=1
      fi
    done <<< "$mapped_guides"
  fi

  if [[ ! -f "$PRINCIPLES_README" ]]; then
    echo "[charter-map] missing principles README: $PRINCIPLES_README"
    failures+=1
  elif ! rg -q 'charter-map\.yml' "$PRINCIPLES_README"; then
    echo "[charter-map] principles README must reference charter-map.yml."
    failures+=1
  fi

  if ! rg -q 'path:[[:space:]]*charter-map\.yml' "$PRINCIPLES_INDEX"; then
    echo "[charter-map] principles index must include charter-map.yml entry."
    failures+=1
  fi
}

check_convivial_alignment_contract() {
  local file
  local -a templates=("$TIER2_TEMPLATE" "$TIER3_TEMPLATE")
  local -a pr_templates=("$PR_TEMPLATE" "$PR_TEMPLATE_KAIZEN")

  if [[ ! -f "$CONVIVIAL_CONTROL_MD" ]]; then
    echo "[convivial-contract] missing control doc: $CONVIVIAL_CONTROL_MD"
    failures+=1
  fi

  if [[ ! -f "$CONVIVIAL_CONTROL_YML" ]]; then
    echo "[convivial-contract] missing control yaml: $CONVIVIAL_CONTROL_YML"
    failures+=1
  fi

  if [[ -f "$CONTROLS_INDEX" ]]; then
    if ! rg -q 'path:[[:space:]]*convivial-impact-minimums\.md' "$CONTROLS_INDEX"; then
      echo "[convivial-contract] controls index must include convivial-impact-minimums.md."
      failures+=1
    fi
    if ! rg -q 'path:[[:space:]]*convivial-impact-minimums\.yml' "$CONTROLS_INDEX"; then
      echo "[convivial-contract] controls index must include convivial-impact-minimums.yml."
      failures+=1
    fi
  else
    echo "[convivial-contract] missing controls index: $CONTROLS_INDEX"
    failures+=1
  fi

  for file in "${templates[@]}"; do
    if [[ ! -f "$file" ]]; then
      echo "[convivial-contract] missing spec template: $file"
      failures+=1
      continue
    fi
    if ! rg -q '^convivial_impact:[[:space:]]*$' "$file"; then
      echo "[convivial-contract] $file must define convivial_impact section."
      failures+=1
    fi
    if ! rg -q '^[[:space:]]+capability_expansion:[[:space:]]*' "$file"; then
      echo "[convivial-contract] $file must define convivial_impact.capability_expansion."
      failures+=1
    fi
    if ! rg -q '^[[:space:]]+attention_class:[[:space:]]*(peripheral|on_demand|active|interruptive)' "$file"; then
      echo "[convivial-contract] $file must define convivial_impact.attention_class with valid domain value."
      failures+=1
    fi
    if ! rg -q '^[[:space:]]+extraction_risk:[[:space:]]*(none|minimal_local|moderate_shared|high_centralized)' "$file"; then
      echo "[convivial-contract] $file must define convivial_impact.extraction_risk with valid domain value."
      failures+=1
    fi
    if ! rg -q '^[[:space:]]+manipulation_vectors:[[:space:]]*' "$file"; then
      echo "[convivial-contract] $file must define convivial_impact.manipulation_vectors."
      failures+=1
    fi
    if ! rg -q '^[[:space:]]+mitigations:[[:space:]]*' "$file"; then
      echo "[convivial-contract] $file must define convivial_impact.mitigations."
      failures+=1
    fi
  done

  for file in "${pr_templates[@]}"; do
    if [[ ! -f "$file" ]]; then
      echo "[convivial-contract] missing PR template: $file"
      failures+=1
      continue
    fi
    if ! rg -q '^## Convivial Purpose Check$' "$file"; then
      echo "[convivial-contract] $file must include Convivial Purpose checklist section."
      failures+=1
    fi
    if ! rg -q 'Feature expands genuine user capability' "$file"; then
      echo "[convivial-contract] $file missing capability expansion checklist item."
      failures+=1
    fi
    if ! rg -q 'Attention and interruption behavior are justified and user-controllable' "$file"; then
      echo "[convivial-contract] $file missing attention-control checklist item."
      failures+=1
    fi
    if ! rg -q 'No manipulative patterns or dark-pattern mechanics are introduced' "$file"; then
      echo "[convivial-contract] $file missing anti-manipulation checklist item."
      failures+=1
    fi
    if ! rg -q 'Data collection/extraction risk is minimal and explicitly justified' "$file"; then
      echo "[convivial-contract] $file missing extraction-risk checklist item."
      failures+=1
    fi
  done
}

if [[ ! -x "$REFERENCE_LINT" ]]; then
  echo "[missing-script] reference lint script is missing or not executable: $REFERENCE_LINT"
  failures+=1
else
  if ! PRINCIPLES_DIR_OVERRIDE="$PRINCIPLES_DIR" "$REFERENCE_LINT"; then
    failures+=1
  fi
fi

check_canonical_matrix_links
check_canonical_glossary_links
check_risk_mapping_reference
check_principles_index_contract
check_superseded_principle_clutter
check_charter_map_contract
check_convivial_alignment_contract
check_forbidden_terms
check_pr_only_runtime_gating
check_human_approval_runtime_dependency
check_arbitration_ssot_drift
check_waiver_exception_ssot_links
check_stale_migration_phrasing
check_arbitration_pointer_standardization
check_contraction_finalize_glossary
check_principles_charter_change_control

if [[ "$failures" -gt 0 ]]; then
  echo "Principles governance lint failed with $failures issue(s)."
  exit 1
fi

echo "Principles governance lint passed."
