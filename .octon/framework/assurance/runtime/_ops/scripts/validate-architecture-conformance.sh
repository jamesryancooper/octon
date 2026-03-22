#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
REGISTRY_FILE="$OCTON_DIR/framework/cognition/_meta/architecture/contract-registry.yml"

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

has_text() {
  local needle="$1"
  local path="$2"
  if command -v rg >/dev/null 2>&1; then
    rg -Fq "$needle" "$path"
  else
    grep -Fq "$needle" "$path"
  fi
}

has_pattern() {
  local pattern="$1"
  local path="$2"
  if command -v rg >/dev/null 2>&1; then
    rg -q "$pattern" "$path"
  else
    grep -Eq "$pattern" "$path"
  fi
}

require_file() {
  local path="$1"
  if [[ -f "$path" ]]; then
    pass "found ${path#$ROOT_DIR/}"
  else
    fail "missing ${path#$ROOT_DIR/}"
  fi
}

require_contains() {
  local path="$1"
  local needle="$2"
  local label="$3"
  if has_text "$needle" "$path"; then
    pass "$label"
  else
    fail "$label"
  fi
}

main() {
  echo "== Architecture Conformance Validation =="

  local -a search_roots=(".octon")
  if [[ -d "$ROOT_DIR/.github" ]]; then
    search_roots+=(".github")
  fi

  require_file "$REGISTRY_FILE"
  local run_root execution_control_root execution_tmp_root network_policy budget_policy budget_state exception_leases
  run_root="$(yq -r '.execution.write_roots.run_evidence_root' "$REGISTRY_FILE")"
  execution_control_root="$(yq -r '.execution.write_roots.execution_control_root' "$REGISTRY_FILE")"
  execution_tmp_root="$(yq -r '.execution.write_roots.execution_tmp_root' "$REGISTRY_FILE")"
  network_policy="$(yq -r '.execution.policy_roots.network_egress' "$REGISTRY_FILE")"
  budget_policy="$(yq -r '.execution.policy_roots.execution_budgets' "$REGISTRY_FILE")"
  budget_state="$(yq -r '.execution.control_state.budget_state' "$REGISTRY_FILE")"
  exception_leases="$(yq -r '.execution.control_state.exception_leases' "$REGISTRY_FILE")"

  require_file "$ROOT_DIR/$network_policy"
  require_file "$ROOT_DIR/$budget_policy"
  require_file "$ROOT_DIR/$budget_state"
  require_file "$ROOT_DIR/$exception_leases"

  require_contains \
    "$OCTON_DIR/framework/engine/runtime/crates/core/src/config.rs" \
    "run_evidence_root" \
    "RuntimeConfig exposes explicit retained run evidence root"
  require_contains \
    "$OCTON_DIR/framework/engine/runtime/crates/core/src/config.rs" \
    "execution_control_root" \
    "RuntimeConfig exposes explicit execution control root"
  require_contains \
    "$OCTON_DIR/framework/engine/runtime/crates/core/src/config.rs" \
    "execution_tmp_root" \
    "RuntimeConfig exposes explicit execution scratch root"

  if (
    has_pattern 'state_dir' "$OCTON_DIR/framework/engine/runtime/crates/core/src/config.rs" ||
    has_pattern 'state_dir' "$OCTON_DIR/framework/engine/runtime/crates/kernel/src/main.rs" ||
    has_pattern 'state_dir' "$OCTON_DIR/framework/engine/runtime/crates/kernel/src/stdio.rs" ||
    has_pattern 'state_dir' "$OCTON_DIR/framework/engine/runtime/crates/wasm_host/src/invoke.rs"
  ); then
    fail "legacy ambiguous runtime state_dir references remain in engine runtime entrypoints"
  else
    pass "legacy ambiguous runtime state_dir references are removed from engine runtime entrypoints"
  fi

  require_contains \
    "$OCTON_DIR/framework/engine/runtime/crates/core/src/trace.rs" \
    "trace.ndjson" \
    "TraceWriter targets trace.ndjson in the bound run root"
  if has_pattern 'join\\("traces"\\)' "$OCTON_DIR/framework/engine/runtime/crates/core/src/trace.rs"; then
    fail "TraceWriter must not recreate framework-local traces directories"
  else
    pass "TraceWriter no longer writes through a traces directory indirection"
  fi

  if [[ "$(yq -r '.services."execution/flow".allow[]?' "$OCTON_DIR/framework/engine/runtime/config/policy.yml" | grep -Fx 'net.http' || true)" != "" ]]; then
    fail "execution/flow default policy must not grant net.http"
  else
    pass "execution/flow default policy omits ambient net.http"
  fi

  local forbidden_prefix
  while IFS= read -r forbidden_prefix; do
    [[ -n "$forbidden_prefix" ]] || continue
    if (
      cd "$ROOT_DIR"
      if command -v rg >/dev/null 2>&1; then
        rg -n --hidden --no-heading \
          --glob '!**/target/**' \
          --glob '!**/.git/**' \
          --glob '!.octon/state/evidence/**' \
          --glob '!.octon/instance/cognition/decisions/**' \
          --glob '!.octon/instance/cognition/context/shared/migrations/**' \
          --glob '!.octon/inputs/exploratory/proposals/**' \
          --glob '!.octon/inputs/exploratory/proposals/.archive/**' \
          --glob '!.octon/framework/assurance/runtime/_ops/scripts/validate-architecture-conformance.sh' \
          --glob '!.octon/framework/assurance/runtime/_ops/scripts/validate-framework-core-boundary.sh' \
          --glob '!.octon/framework/assurance/runtime/_ops/tests/**' \
          --glob '!.octon/framework/cognition/_meta/architecture/contract-registry.yml' \
          "${forbidden_prefix#./}" \
          "${search_roots[@]}" >/dev/null
      else
        mapfile -t candidate_files < <(
          find "${search_roots[@]}" \
            \( -path '*/target/*' -o -path '*/.git/*' -o -path '.octon/state/evidence/*' -o -path '.octon/instance/cognition/decisions/*' -o -path '.octon/instance/cognition/context/shared/migrations/*' -o -path '.octon/inputs/exploratory/proposals/*' -o -path '.octon/framework/assurance/runtime/_ops/tests/*' \) -prune \
            -o -type f \
            ! -name 'validate-architecture-conformance.sh' \
            ! -name 'validate-framework-core-boundary.sh' \
            ! -path '.octon/framework/cognition/_meta/architecture/contract-registry.yml' \
            -print
        )
        if ((${#candidate_files[@]} > 0)); then
          grep -n -E "${forbidden_prefix#./}" "${candidate_files[@]}" >/dev/null
        else
          false
        fi
      fi
    ); then
      fail "live runtime or doc references still mention forbidden execution write prefix: $forbidden_prefix"
    else
      pass "forbidden execution write prefix is absent from live runtime/doc surfaces: $forbidden_prefix"
    fi
  done < <(yq -r '.execution.forbidden_write_prefixes[]' "$REGISTRY_FILE")

  require_contains \
    "$OCTON_DIR/framework/cognition/_meta/architecture/specification.md" \
    "$execution_control_root" \
    "umbrella specification references canonical execution control root"
  require_contains \
    "$OCTON_DIR/framework/cognition/_meta/architecture/specification.md" \
    "$execution_tmp_root" \
    "umbrella specification references canonical execution scratch root"
  require_contains \
    "$OCTON_DIR/framework/cognition/_meta/architecture/specification.md" \
    "$network_policy" \
    "umbrella specification references repo-owned network egress policy"
  require_contains \
    "$OCTON_DIR/framework/cognition/_meta/architecture/specification.md" \
    "$budget_policy" \
    "umbrella specification references repo-owned execution budget policy"

  require_contains \
    "$OCTON_DIR/framework/cognition/_meta/architecture/runtime-vs-ops-contract.md" \
    "$execution_control_root/**" \
    "runtime-vs-ops contract references canonical execution control root"
  require_contains \
    "$OCTON_DIR/framework/cognition/_meta/architecture/runtime-vs-ops-contract.md" \
    "$execution_tmp_root/**" \
    "runtime-vs-ops contract references canonical execution scratch root"

  require_contains \
    "$OCTON_DIR/instance/bootstrap/START.md" \
    "portable operational support" \
    "bootstrap START describes ops as portable operational support"
  require_contains \
    "$OCTON_DIR/framework/engine/README.md" \
    "Portable operational assets | helper binaries and portable support scripts" \
    "engine README aligns ops semantics with portable support-only contract"

  require_contains \
    "$OCTON_DIR/framework/engine/runtime/spec/policy-interface-v1.md" \
    "$network_policy" \
    "policy interface spec references repo-owned network egress policy"
  require_contains \
    "$OCTON_DIR/framework/engine/runtime/spec/policy-interface-v1.md" \
    "$budget_policy" \
    "policy interface spec references repo-owned execution budget policy"

  require_contains \
    "$OCTON_DIR/framework/engine/runtime/spec/policy-receipt-v1.schema.json" \
    "\"budget_rule_id\"" \
    "policy receipt schema exposes budget metadata fields"

  echo "Validation summary: errors=$errors"
  if [[ "$errors" -gt 0 ]]; then
    exit 1
  fi
}

main "$@"
