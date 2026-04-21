#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../.." && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
CONFIG_FILE="$OCTON_DIR/instance/governance/closure/uec-packet-certification-runs.yml"
MAIN_RS="$OCTON_DIR/framework/engine/runtime/crates/kernel/src/main.rs"
COMMANDS_RS="$OCTON_DIR/framework/engine/runtime/crates/kernel/src/commands/mod.rs"
RUN_BINDING_RS="$OCTON_DIR/framework/engine/runtime/crates/kernel/src/run_binding.rs"

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }
require_file() { [[ -f "$1" ]] && pass "found $1" || fail "missing $1"; }
require_text() {
  local pattern="$1"
  local path="$2"
  local label="$3"
  if command -v rg >/dev/null 2>&1; then
    rg -q "$pattern" "$path" && pass "$label" || fail "$label"
  else
    grep -Eq "$pattern" "$path" && pass "$label" || fail "$label"
  fi
}
role_run_id() { yq -r ".run_roles.${1}.run_id" "$CONFIG_FILE"; }

main() {
  echo "== Run-Binding Enforcement Validation =="

  require_file "$RUN_BINDING_RS"
  require_file "$COMMANDS_RS"
  require_file "$OCTON_DIR/framework/engine/runtime/policies/run-required.yml"
  require_file "$OCTON_DIR/framework/engine/runtime/policies/materiality-classification.yml"
  require_text '^mod run_binding;' "$MAIN_RS" "kernel loads run_binding module"
  require_text 'ensure_canonical_run_binding\(&ctx\.cfg, &request, &grant, "tool"\)' "$COMMANDS_RS" "tool command is run-bound"
  require_text 'ensure_canonical_run_binding\(&ctx\.cfg, &request, &grant, "studio"\)' "$COMMANDS_RS" "studio command is run-bound"
  require_text 'ensure_canonical_run_binding\(&ctx\.cfg, &request, &grant, "service"\)' "$COMMANDS_RS" "service commands are run-bound"

  local run_id
  for run_id in \
    "$(role_run_id supported_run_only)" \
    "$(role_run_id authority_exercise)" \
    "$(role_run_id external_evidence)" \
    "$(role_run_id intervention_control)" \
    "$(role_run_id github_projection)" \
    "$(role_run_id ci_projection)"; do
    [[ -n "$run_id" ]] || continue
    require_file "$OCTON_DIR/state/control/execution/runs/$run_id/run-contract.yml"
    require_file "$OCTON_DIR/state/control/execution/runs/$run_id/run-manifest.yml"
    require_file "$OCTON_DIR/state/control/execution/runs/$run_id/runtime-state.yml"
  done

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
