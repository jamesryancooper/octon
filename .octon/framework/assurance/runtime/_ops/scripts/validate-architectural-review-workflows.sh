#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"

# --root points WORKFLOW_ROOT at an alternate audit-workflow root (a directory
# holding review-occasion subdirectories) and runs ONLY the method-recording
# checks, mirroring the sibling routing validator's fixture override. It lets the
# workflow-method-recording negative-control fixture be exercised without
# mutating the live workflows and without a manifest/registry, so NC-01 fails
# closed for exactly one reason: missing_method_record.
FIXTURE_MODE=0
WORKFLOW_ROOT="$ROOT_DIR/.octon/framework/orchestration/runtime/workflows/audit"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)
      WORKFLOW_ROOT="$(cd -- "$2" && pwd)"
      FIXTURE_MODE=1
      shift 2
      ;;
    *)
      printf '[ERROR] unknown argument: %s\n' "$1" >&2
      exit 2
      ;;
  esac
done

MANIFEST="$ROOT_DIR/.octon/framework/orchestration/runtime/workflows/manifest.yml"
REGISTRY="$ROOT_DIR/.octon/framework/orchestration/runtime/workflows/registry.yml"
errors=0

pass() { printf '[OK] %s\n' "$1"; }
fail() { printf '[ERROR] %s\n' "$1" >&2; errors=$((errors + 1)); }

occasions=(
  pre-integration-architecture-review
  post-integration-architecture-review
  current-state-mechanism-architecture-review
  architecture-readiness-audit
)

# --- Method-id run-evidence recording (integration child) ----------------------
# Each review occasion must record the selected method id and the applied lens
# profile in run evidence through a v2 routing-decision/report artifact, while the
# v1 support receipt stays method-free. The assertion is contract-level: the
# workflow.yml must declare a `*_method_selection_record` artifact bound to the v2
# artifact family under the occasion's existing architectural-review run-evidence
# root, the configure stage must carry the Balanced-default per-occasion advisory,
# and no support-receipt artifact may carry method-recording semantics. A workflow
# that omits the record fails with missing_method_record (NC-01).
assert_method_recording() {
  local dir="$1" occasion="$2" wf="$1/workflow.yml"

  if [[ ! -f "$wf" ]] || ! yq -e '.' "$wf" >/dev/null 2>&1; then
    fail "method-recording: workflow contract present and parses: $occasion"
    return
  fi

  local rec_path
  rec_path="$(yq -r '.artifacts[]? | select((.name // "") | test("_method_selection_record$")) | .path // ""' "$wf" 2>/dev/null | rg -F "/architectural-review/$occasion/" || true)"
  if [[ -n "$rec_path" ]]; then
    pass "method-id recording artifact present in run evidence: $occasion"
  else
    fail "missing_method_record: $occasion does not declare a *_method_selection_record artifact under architectural-review/$occasion/"
  fi

  if [[ -n "$rec_path" ]]; then
    local desc token
    desc="$(yq -r '.artifacts[]? | select((.name // "") | test("_method_selection_record$")) | .description // ""' "$wf" 2>/dev/null || true)"
    for token in '-v2' 'method' 'lenses_applied'; do
      if rg -Fq -- "$token" <<<"$desc"; then
        pass "method record binds v2 method evidence ('$token'): $occasion"
      else
        fail "missing_method_record: $occasion method record omits '$token'"
      fi
    done
  fi

  # AC-05: the configure stage states the Balanced-default per-occasion advisory.
  local cfg_asset
  cfg_asset="$(yq -r '.stages[]? | select(.id == "configure") | .asset // ""' "$wf" 2>/dev/null | head -1)"
  if [[ -n "$cfg_asset" && -f "$dir/$cfg_asset" ]] \
    && rg -Fq 'balanced-architecture-review-method' "$dir/$cfg_asset" \
    && rg -Fqi 'method selection' "$dir/$cfg_asset"; then
    pass "configure stage records selected method with advisory: $occasion"
  else
    fail "$occasion configure stage missing Balanced-default method-selection advisory"
  fi

  # AC-02: no support-receipt artifact may carry method-recording semantics.
  local sr_bad
  sr_bad="$(yq -r '.artifacts[]? | select((.path // "") | test("support-receipt")) | (.name // "") + " " + (.description // "")' "$wf" 2>/dev/null | rg -i 'method_selection_record|lenses_applied' || true)"
  if [[ -n "$sr_bad" ]]; then
    fail "receipt_method_drift: $occasion support-receipt artifact must stay method-free"
  else
    pass "support receipt artifact stays method-free: $occasion"
  fi
}

assert_external_tool_integrity() {
  local dir="$1" occasion="$2"
  local cfg="$dir/stages/01-configure.md"

  if [[ -f "$cfg" ]] \
    && rg -Fq '.octon/instance/governance/policies/external-tool-integrity.yml' "$cfg"; then
    pass "external-tool integrity policy loaded: $occasion"
  else
    fail "$occasion configure stage does not load the external-tool integrity policy"
  fi

  if rg -Fqi 'external-tool integrity' "$dir"/stages/*.md \
    && rg -Fqi 'unmodified' "$dir"/stages/*.md \
    && rg -Fqi 'supported interface' "$dir"/stages/*.md; then
    pass "external-tool integrity review behavior is explicit: $occasion"
  else
    fail "$occasion does not explicitly preserve unmodified tools through supported interfaces"
  fi
}

if [[ "$FIXTURE_MODE" -eq 1 ]]; then
  found=0
  for workflow in "${occasions[@]}"; do
    dir="$WORKFLOW_ROOT/$workflow"
    [[ -d "$dir" ]] || continue
    found=1
    assert_method_recording "$dir" "$workflow"
    assert_external_tool_integrity "$dir" "$workflow"
  done
  [[ "$found" -eq 1 ]] \
    && pass "fixture root exposes at least one review occasion" \
    || fail "fixture root declares no recognized review occasion: $WORKFLOW_ROOT"
else
  for workflow in "${occasions[@]}"; do
    dir="$WORKFLOW_ROOT/$workflow"
    [[ -d "$dir" ]] && pass "workflow directory exists: $workflow" || fail "workflow directory exists: $workflow"
    [[ -f "$dir/workflow.yml" ]] && pass "workflow contract exists: $workflow" || fail "workflow contract exists: $workflow"
    if [[ -f "$dir/workflow.yml" ]] && yq -e '.' "$dir/workflow.yml" >/dev/null 2>&1; then
      pass "workflow contract parses: $workflow"
      [[ "$(yq -r '.name // ""' "$dir/workflow.yml")" == "$workflow" ]] && pass "workflow contract name matches directory: $workflow" || fail "workflow contract name matches directory: $workflow"
      [[ "$(yq -r '.schema_version // ""' "$dir/workflow.yml")" == "workflow-contract-v2" ]] && pass "workflow schema current: $workflow" || fail "workflow schema current: $workflow"
    else
      fail "workflow contract parses: $workflow"
    fi
    yq -e ".workflows[]? | select(.id == \"$workflow\" and .path == \"audit/$workflow/\")" "$MANIFEST" >/dev/null 2>&1 && pass "workflow manifest registers $workflow" || fail "workflow manifest registers $workflow"
    yq -e ".workflows.\"$workflow\"" "$REGISTRY" >/dev/null 2>&1 && pass "workflow registry registers $workflow" || fail "workflow registry registers $workflow"
    assert_method_recording "$dir" "$workflow"
    assert_external_tool_integrity "$dir" "$workflow"
  done

  [[ ! -e "$WORKFLOW_ROOT/audit-architecture-readiness" ]] && pass "legacy audit-architecture-readiness workflow route absent" || fail "legacy audit-architecture-readiness workflow route absent"
fi

printf 'Validation summary: errors=%s\n' "$errors"
[[ "$errors" -eq 0 ]]
