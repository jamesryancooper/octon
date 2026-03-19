#!/usr/bin/env bash
# validate-service-independence.sh - Validate service independence and interop coupling boundaries.

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
FRAMEWORK_DIR="$(cd "$SERVICES_DIR/../../.." && pwd)"
OCTON_DIR="$(cd "$FRAMEWORK_DIR/.." && pwd)"
REPO_ROOT="$(cd "$OCTON_DIR/.." && pwd)"
AGENT_PLATFORM_DIR="$SERVICES_DIR/interfaces/agent-platform"
ADAPTERS_DIR="$AGENT_PLATFORM_DIR/adapters"
ALLOWLIST_FILE="$FRAMEWORK_DIR/capabilities/governance/policy/provider-term-allowlist.tsv"
TODAY="$(date +%F)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

errors=0
warnings=0

declare -a allowlist_path_regex=()
declare -a allowlist_term=()
declare -a allowlist_owner=()
declare -a allowlist_expires=()

HAS_RG=false
if command -v rg >/dev/null 2>&1; then
  HAS_RG=true
fi

usage() {
  cat <<USAGE
Usage: $0 [--mode all|services-core|platform-core|adapters|conformance|degradation]

Modes:
  all            Run all checks (default)
  services-core  Validate forbidden external package references in core services.
  platform-core  Validate provider-term boundaries in native interop core files.
  adapters       Validate adapter registry and required adapter artifacts.
  conformance    Validate adapter conformance fixtures and compatibility ranges.
  degradation    Validate deterministic degraded-path behavior and evidence hooks.
USAGE
}

log_error() {
  echo -e "${RED}ERROR:${NC} $1"
  ((errors++)) || true
}

log_warning() {
  echo -e "${YELLOW}WARNING:${NC} $1"
  ((warnings++)) || true
}

log_success() {
  echo -e "${GREEN}✓${NC} $1"
}

search_regex() {
  local pattern="$1"
  shift

  if [[ "$HAS_RG" == "true" ]]; then
    rg -n "$pattern" "$@" || true
    return 0
  fi

  local target
  for target in "$@"; do
    if [[ -d "$target" ]]; then
      grep -R -n -E -- "$pattern" "$target" 2>/dev/null || true
    else
      grep -n -E -- "$pattern" "$target" 2>/dev/null || true
    fi
  done
}

search_regex_quiet() {
  local pattern="$1"
  shift

  if [[ "$HAS_RG" == "true" ]]; then
    rg -n "$pattern" "$@" >/dev/null 2>&1
    return $?
  fi

  local target
  for target in "$@"; do
    if [[ -d "$target" ]]; then
      if grep -R -n -E -- "$pattern" "$target" >/dev/null 2>&1; then
        return 0
      fi
    else
      if grep -n -E -- "$pattern" "$target" >/dev/null 2>&1; then
        return 0
      fi
    fi
  done

  return 1
}

search_fixed_icase() {
  local term="$1"
  shift

  if [[ "$HAS_RG" == "true" ]]; then
    rg -n -i -F "$term" "$@" || true
    return 0
  fi

  grep -n -i -F -- "$term" "$@" 2>/dev/null || true
}

to_repo_relative() {
  local path="$1"
  if [[ "$path" == "$REPO_ROOT/"* ]]; then
    echo "${path#$REPO_ROOT/}"
  else
    echo "$path"
  fi
}

load_allowlist() {
  if [[ ! -f "$ALLOWLIST_FILE" ]]; then
    log_warning "Allowlist file not found: $ALLOWLIST_FILE"
    return 0
  fi

  while IFS=$'\t' read -r path_regex term owner expires note; do
    [[ -z "$path_regex" ]] && continue
    [[ "$path_regex" =~ ^# ]] && continue

    if [[ -z "$term" || -z "$owner" || -z "$expires" ]]; then
      log_error "Invalid allowlist row (must include path_regex, term, owner, expires): $path_regex"
      continue
    fi

    if [[ ! "$expires" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
      log_error "Invalid allowlist expiry date format for term '$term': $expires"
      continue
    fi

    if [[ "$expires" < "$TODAY" ]]; then
      log_error "Expired allowlist entry for term '$term' (owner: $owner, expired: $expires)"
      continue
    fi

    allowlist_path_regex+=("$path_regex")
    allowlist_term+=("$(echo "$term" | tr '[:upper:]' '[:lower:]')")
    allowlist_owner+=("$owner")
    allowlist_expires+=("$expires")
  done < "$ALLOWLIST_FILE"
}

is_allowlisted() {
  local rel_path="$1"
  local term="$2"
  local i
  for i in "${!allowlist_term[@]}"; do
    if [[ "${allowlist_term[$i]}" != "$term" ]]; then
      continue
    fi
    if [[ "$rel_path" =~ ${allowlist_path_regex[$i]} ]]; then
      return 0
    fi
  done
  return 1
}

scan_pattern() {
  local target="$1"
  local pattern="$2"
  local description="$3"
  local hits

  if [[ ! -e "$target" ]]; then
    log_error "Missing path for check '$description': $target"
    return
  fi

  hits="$(search_regex "$pattern" "$target")"
  if [[ -n "$hits" ]]; then
    log_error "Found $description in $target"
    echo "$hits"
  else
    log_success "No $description in $target"
  fi
}

collect_provider_terms() {
  local registry="$ADAPTERS_DIR/registry.yml"

  if [[ ! -f "$registry" ]]; then
    return 0
  fi

  awk '
    BEGIN { in_aliases = 0 }

    /^[[:space:]]*-[[:space:]]id:/ {
      value = $3
      gsub(/["'\'' ]/, "", value)
      if (length(value) > 0) print tolower(value)
      in_aliases = 0
      next
    }

    /^[[:space:]]*provider:/ {
      value = $2
      gsub(/["'\'' ]/, "", value)
      if (length(value) > 0) print tolower(value)
      in_aliases = 0
      next
    }

    /^[[:space:]]*aliases:/ {
      in_aliases = 1
      next
    }

    in_aliases && /^[[:space:]]*-[[:space:]]*/ {
      value = $2
      gsub(/["'\'' ]/, "", value)
      if (length(value) > 0) print tolower(value)
      next
    }

    in_aliases && !/^[[:space:]]*-[[:space:]]*/ {
      in_aliases = 0
    }
  ' "$registry" | sort -u
}

get_adapter_ids() {
  local registry="$ADAPTERS_DIR/registry.yml"
  if [[ ! -f "$registry" ]]; then
    return 0
  fi

  awk '
    /^[[:space:]]*-[[:space:]]id:/ {
      id = $3
      gsub(/["'\'' ]/, "", id)
      if (length(id) > 0) print id
    }
  ' "$registry"
}

run_services_core_checks() {
  echo "Running mode: services-core"

  scan_pattern "$SERVICES_DIR/manifest.yml" "packages/kits|@octon/" "forbidden external package references"
  scan_pattern "$SERVICES_DIR/registry.yml" "packages/kits|@octon/" "forbidden external package references"
  scan_pattern "$SERVICES_DIR/governance/guard" "packages/kits|@octon/" "forbidden external package references"
  scan_pattern "$SERVICES_DIR/modeling/prompt" "packages/kits|@octon/" "forbidden external package references"
  scan_pattern "$SERVICES_DIR/operations/cost" "packages/kits|@octon/" "forbidden external package references"
  scan_pattern "$SERVICES_DIR/execution/flow" "packages/kits|@octon/" "forbidden external package references"
  scan_pattern "$SERVICES_DIR/execution/agent" "packages/kits|@octon/" "forbidden external package references"
  scan_pattern "$SERVICES_DIR/interfaces/agent-platform" "packages/kits|@octon/" "forbidden external package references"
  scan_pattern "$SERVICES_DIR/interfaces/filesystem-snapshot" "packages/kits|@octon/" "forbidden external package references"
  scan_pattern "$SERVICES_DIR/interfaces/filesystem-discovery" "packages/kits|@octon/" "forbidden external package references"
  scan_pattern "$SERVICES_DIR/interfaces/filesystem-watch" "packages/kits|@octon/" "forbidden external package references"
  scan_pattern "$SERVICES_DIR/retrieval/query" "packages/kits|@octon/" "forbidden external package references"
}

run_platform_core_checks() {
  echo "Running mode: platform-core"

  load_allowlist

  local registry="$ADAPTERS_DIR/registry.yml"
  if [[ ! -f "$registry" ]]; then
    log_error "Adapter registry not found: $registry"
    return
  fi

  local terms=()
  mapfile -t terms < <(collect_provider_terms)

  if [[ ${#terms[@]} -eq 0 ]]; then
    log_error "No provider terms could be derived from adapter registry: $registry"
    return
  fi

  local targets=(
    "$OCTON_DIR/instance/cognition/context/shared/agent-platform-interop.md"
    "$OCTON_DIR/instance/cognition/decisions/012-agent-platform-interop-native-first.md"
    "$OCTON_DIR/framework/capabilities/runtime/commands/context-budget.md"
    "$OCTON_DIR/framework/capabilities/runtime/commands/validate-session-policy.md"
    "$OCTON_DIR/framework/capabilities/runtime/commands/validate-platform-interop.md"
    "$AGENT_PLATFORM_DIR/README.md"
    "$AGENT_PLATFORM_DIR/contract.md"
    "$AGENT_PLATFORM_DIR/SERVICE.md"
    "$AGENT_PLATFORM_DIR/schema/capabilities.schema.json"
    "$AGENT_PLATFORM_DIR/schema/session-policy.schema.json"
  )

  local missing=0
  local t
  for t in "${targets[@]}"; do
    if [[ ! -f "$t" ]]; then
      log_error "Missing platform-core target: $t"
      missing=1
    fi
  done

  if [[ $missing -eq 1 ]]; then
    return
  fi

  local term
  for term in "${terms[@]}"; do
    local hits
    hits="$(search_fixed_icase "$term" "${targets[@]}")"

    if [[ -z "$hits" ]]; then
      continue
    fi

    while IFS= read -r hit; do
      [[ -z "$hit" ]] && continue

      local hit_file
      hit_file="${hit%%:*}"
      local rel_path
      rel_path="$(to_repo_relative "$hit_file")"

      if is_allowlisted "$rel_path" "$term"; then
        log_warning "Allowlisted provider-term hit '$term' at $rel_path"
        continue
      fi

      log_error "Provider-term leak '$term' outside adapters: $hit"
    done <<< "$hits"
  done

  if [[ $errors -eq 0 ]]; then
    log_success "No provider-term leaks detected in platform core files"
  fi
}

run_adapters_checks() {
  echo "Running mode: adapters"

  local registry="$ADAPTERS_DIR/registry.yml"
  if [[ ! -f "$registry" ]]; then
    log_error "Adapter registry not found: $registry"
    return
  fi

  local adapter_ids=()
  mapfile -t adapter_ids < <(get_adapter_ids)

  if [[ ${#adapter_ids[@]} -lt 2 ]]; then
    log_error "Expected at least two adapters in registry; found ${#adapter_ids[@]}"
    return
  fi

  local id
  for id in "${adapter_ids[@]}"; do
    local base="$ADAPTERS_DIR/$id"

    if [[ ! -d "$base" ]]; then
      log_error "Adapter directory missing: $base"
      continue
    fi

    [[ -f "$base/adapter.yml" ]] || log_error "Missing adapter descriptor: $base/adapter.yml"
    [[ -f "$base/mapping.md" ]] || log_error "Missing adapter mapping doc: $base/mapping.md"
    [[ -f "$base/compatibility.yml" ]] || log_error "Missing adapter compatibility profile: $base/compatibility.yml"
    [[ -d "$base/fixtures" ]] || log_error "Missing fixtures directory: $base/fixtures"

    local fixture_count=0
    if [[ -d "$base/fixtures" ]]; then
      fixture_count="$(find "$base/fixtures" -maxdepth 1 -type f | wc -l | tr -d ' ')"
      if [[ "$fixture_count" == "0" ]]; then
        log_error "No fixture files found for adapter: $id"
      fi
    fi

    if [[ -f "$base/adapter.yml" ]]; then
      search_regex_quiet "^id:[[:space:]]*$id$" "$base/adapter.yml" || log_error "Adapter id mismatch in $base/adapter.yml"
      search_regex_quiet '^interop_contract_version:[[:space:]]*"?1\.0\.0"?$' "$base/adapter.yml" || log_error "interop_contract_version must be 1.0.0 in $base/adapter.yml"
    fi

    if [[ -f "$base/adapter.yml" && -f "$base/mapping.md" && -f "$base/compatibility.yml" ]]; then
      log_success "Adapter artifacts valid for '$id'"
    fi
  done
}

run_conformance_checks() {
  echo "Running mode: conformance"

  local registry="$ADAPTERS_DIR/registry.yml"
  if [[ ! -f "$registry" ]]; then
    log_error "Adapter registry not found: $registry"
    return
  fi

  local adapter_ids=()
  mapfile -t adapter_ids < <(get_adapter_ids)
  if [[ ${#adapter_ids[@]} -eq 0 ]]; then
    log_error "No adapters found in registry: $registry"
    return
  fi

  local id
  for id in "${adapter_ids[@]}"; do
    local base="$ADAPTERS_DIR/$id"
    local adapter_file="$base/adapter.yml"
    local compatibility_file="$base/compatibility.yml"
    local capabilities_fixture="$base/fixtures/capabilities.json"
    local session_policy_fixture="$base/fixtures/session-policy.json"

    [[ -f "$adapter_file" ]] || { log_error "Missing adapter file for conformance: $adapter_file"; continue; }
    [[ -f "$compatibility_file" ]] || { log_error "Missing compatibility file for conformance: $compatibility_file"; continue; }
    [[ -f "$capabilities_fixture" ]] || { log_error "Missing capabilities fixture for conformance: $capabilities_fixture"; continue; }
    [[ -f "$session_policy_fixture" ]] || { log_error "Missing session-policy fixture for conformance: $session_policy_fixture"; continue; }

    if ! node - "$capabilities_fixture" "$id" <<'NODE'
const fs = require('fs');

const fixturePath = process.argv[2];
const adapterId = process.argv[3];
const requiredCaps = ['session_policy', 'context_budget', 'pruning', 'memory_flush', 'routing', 'presence'];
const allowedStates = new Set(['supported', 'degraded', 'unsupported']);
const allowedVia = new Set(['adapter']);
const errors = [];

let payload;
try {
  payload = JSON.parse(fs.readFileSync(fixturePath, 'utf8'));
} catch (err) {
  console.error(`invalid-json:${fixturePath}`);
  process.exit(1);
}

if (payload.mode !== 'adapter') errors.push('mode-must-be-adapter');
if (payload.adapter_id !== adapterId) errors.push('adapter_id-mismatch');
if (payload.interop_contract_version !== '1.0.0') errors.push('interop_contract_version-must-be-1.0.0');

const caps = payload.capabilities || {};
for (const cap of requiredCaps) {
  const state = caps[cap];
  if (!state || typeof state !== 'object') {
    errors.push(`missing-capability:${cap}`);
    continue;
  }
  if (!allowedStates.has(state.state)) {
    errors.push(`invalid-state:${cap}`);
  }
  if (!allowedVia.has(state.via)) {
    errors.push(`invalid-via:${cap}`);
  }
  if (typeof state.evidence_required !== 'boolean') {
    errors.push(`invalid-evidence-required:${cap}`);
  } else if (state.state !== 'supported' && state.evidence_required !== true) {
    errors.push(`degraded-without-evidence:${cap}`);
  }
}

if (errors.length > 0) {
  console.error(errors.join('\n'));
  process.exit(1);
}
NODE
    then
      log_error "Capability matrix validation failed for adapter '$id'"
    else
      log_success "Capability matrix validation passed for adapter '$id'"
    fi

    if ! node - "$session_policy_fixture" <<'NODE'
const fs = require('fs');
const fixturePath = process.argv[2];
const errors = [];
let payload;

try {
  payload = JSON.parse(fs.readFileSync(fixturePath, 'utf8'));
} catch (err) {
  console.error(`invalid-json:${fixturePath}`);
  process.exit(1);
}

if (payload.interop_contract_version !== '1.0.0') errors.push('interop_contract_version-must-be-1.0.0');
if ((payload.context_budget || {}).warning_threshold_percent !== 80) errors.push('warning-threshold-must-be-80');
if ((payload.context_budget || {}).flush_threshold_percent !== 90) errors.push('flush-threshold-must-be-90');
if ((payload.memory || {}).flush_before_compaction !== true) errors.push('flush-before-compaction-must-be-true');
if ((payload.memory || {}).fail_closed_on_flush_failure !== true) errors.push('fail-closed-must-be-true');

const precedence = (((payload.routing || {}).precedence) || []);
const expected = ['human-safety', 'governance-policy', 'agent-policy', 'adapter-execution'];
if (!Array.isArray(precedence) || precedence.length !== expected.length || precedence.some((v, i) => v !== expected[i])) {
  errors.push('routing-precedence-invalid');
}

if (errors.length > 0) {
  console.error(errors.join('\n'));
  process.exit(1);
}
NODE
    then
      log_error "Session-policy conformance failed for adapter '$id'"
    else
      log_success "Session-policy conformance passed for adapter '$id'"
    fi

    search_regex_quiet '^[[:space:]]*unsupported_critical:[[:space:]]*fail-closed$' "$adapter_file" || log_error "Fallback behavior must be fail-closed in $adapter_file"
    search_regex_quiet '^[[:space:]]*evidence_required:[[:space:]]*true$' "$adapter_file" || log_error "Evidence hook must be required in $adapter_file"
    search_regex_quiet '^[[:space:]]*interop_contract:[[:space:]]*"1\.x"$' "$compatibility_file" || log_error "Compatibility range must pin interop_contract 1.x in $compatibility_file"
    search_regex_quiet '^[[:space:]]*adapter_schema:[[:space:]]*"1\.x"$' "$compatibility_file" || log_error "Compatibility range must pin adapter_schema 1.x in $compatibility_file"
  done
}

run_degradation_checks() {
  echo "Running mode: degradation"

  local negotiate_script="$AGENT_PLATFORM_DIR/impl/negotiate-capabilities.sh"
  local flush_script="$AGENT_PLATFORM_DIR/impl/memory-flush-evidence.sh"

  [[ -x "$negotiate_script" ]] || { log_error "Missing executable negotiate script: $negotiate_script"; return; }
  [[ -x "$flush_script" ]] || { log_error "Missing executable memory flush script: $flush_script"; return; }

  local unavailable_json
  unavailable_json="$("$negotiate_script" --mode adapter --adapter-id unavailable-provider)"
  if ! printf '%s' "$unavailable_json" | node -e 'const fs=require("fs"); const payload=JSON.parse(fs.readFileSync(0,"utf8")); if(payload.mode!=="native"||payload.fallback_reason!=="adapter-unavailable") process.exit(1);'
  then
    log_error "Provider-unavailable degradation behavior is invalid"
  else
    log_success "Provider-unavailable degradation behavior is deterministic"
  fi

  local partial_json
  partial_json="$("$negotiate_script" --mode adapter --adapter-id crewai)"
  if ! printf '%s' "$partial_json" | node -e 'const fs=require("fs"); const payload=JSON.parse(fs.readFileSync(0,"utf8")); const pruning=(((payload || {}).capabilities || {}).pruning || {}); if(payload.mode!=="adapter" || pruning.state!=="degraded" || pruning.evidence_required!==true) process.exit(1);'
  then
    log_error "Partial capability degradation behavior is invalid"
  else
    log_success "Partial capability degradation behavior is deterministic"
  fi

  local stale_json
  stale_json="$("$negotiate_script" --mode adapter --adapter-id openclaw --require-adapter-major 1)"
  if ! printf '%s' "$stale_json" | node -e 'const fs=require("fs"); const payload=JSON.parse(fs.readFileSync(0,"utf8")); if(payload.mode!=="native"||payload.fallback_reason!=="stale-adapter-version") process.exit(1);'
  then
    log_error "Stale adapter version degradation behavior is invalid"
  else
    log_success "Stale adapter version degradation behavior is deterministic"
  fi

  local blocked_report="${TMPDIR:-/tmp}/memory-flush-evidence-blocked-$$.md"
  local waiver_report="${TMPDIR:-/tmp}/memory-flush-evidence-waived-$$.md"

  if "$flush_script" --session-id "degradation-blocked" --limit 1000 --used 950 --compaction-requested true --flush-ok false --output "$blocked_report" >/dev/null 2>&1; then
    log_error "Permission-denied critical action should fail closed without waiver"
  else
    if search_regex_quiet 'Compaction decision:[[:space:]]*fail-closed' "$blocked_report"; then
      log_success "Permission-denied critical action fails closed with evidence"
    else
      log_error "Fail-closed decision evidence missing for permission-denied critical action"
    fi
  fi

  if "$flush_script" --session-id "degradation-waived" --limit 1000 --used 950 --compaction-requested true --flush-ok false --waiver-id "WAIVER-001" --output "$waiver_report" >/dev/null 2>&1; then
    if search_regex_quiet 'Compaction decision:[[:space:]]*allow-with-waiver' "$waiver_report"; then
      log_success "Waived critical-action path records explicit waiver evidence"
    else
      log_error "Waiver evidence missing in waived critical-action path"
    fi
  else
    log_error "Waived critical-action path should succeed when waiver is present"
  fi

  rm -f "$blocked_report" "$waiver_report"
}

main() {
  local mode="all"

  if [[ $# -gt 0 ]]; then
    case "$1" in
      --mode)
        mode="${2:-}"
        if [[ -z "$mode" ]]; then
          usage
          exit 2
        fi
        shift 2
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        mode="$1"
        shift
        ;;
    esac
  fi

  case "$mode" in
    all)
      run_services_core_checks
      run_platform_core_checks
      run_adapters_checks
      run_conformance_checks
      run_degradation_checks
      ;;
    services-core)
      run_services_core_checks
      ;;
    platform-core)
      run_platform_core_checks
      ;;
    adapters)
      run_adapters_checks
      ;;
    conformance)
      run_conformance_checks
      ;;
    degradation)
      run_degradation_checks
      ;;
    *)
      usage
      exit 2
      ;;
  esac

  echo
  if [[ $errors -gt 0 ]]; then
    echo "Independence validation failed: $errors error(s), $warnings warning(s)."
    exit 1
  fi

  echo "Independence validation passed: 0 error(s), $warnings warning(s)."
}

main "$@"
