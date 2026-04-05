#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../.." && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
CONFIG_FILE="$OCTON_DIR/instance/governance/closure/uec-packet-certification-runs.yml"
LEGACY_PATTERN='MT-|WT-|LT-|LOC-|repo-local-consequential'

errors=0
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }
pass() { echo "[OK] $1"; }
role_run_id() { yq -r ".run_roles.${1}.run_id" "$CONFIG_FILE"; }

check_clean() {
  local label="$1"
  shift
  if command -v rg >/dev/null 2>&1; then
    if rg -n "$LEGACY_PATTERN" "$@" >/dev/null 2>&1; then
      rg -n "$LEGACY_PATTERN" "$@" || true
      fail "$label contains legacy support-target vocabulary"
    else
      pass "$label uses semantic support-target vocabulary"
    fi
  else
    if grep -REn "$LEGACY_PATTERN" "$@" >/dev/null 2>&1; then
      grep -REn "$LEGACY_PATTERN" "$@" || true
      fail "$label contains legacy support-target vocabulary"
    else
      pass "$label uses semantic support-target vocabulary"
    fi
  fi
}

main() {
  echo "== Support-Target Normalization Validation =="

  check_clean "support-target declaration" "$OCTON_DIR/instance/governance/support-targets.yml"
  check_clean "governance exclusions" "$OCTON_DIR/instance/governance/exclusions/action-classes.yml"
  check_clean "closure manifest" "$OCTON_DIR/instance/governance/closure/unified-execution-constitution.yml"
  check_clean "support surface ledger" "$OCTON_DIR/instance/governance/closure/global-support-surface-ledger.yml"
  check_clean "runtime adapters and capability manifests" \
    "$OCTON_DIR/framework/engine/runtime/adapters/host" \
    "$OCTON_DIR/framework/engine/runtime/adapters/model" \
    "$OCTON_DIR/framework/capabilities/packs/browser/manifest.yml" \
    "$OCTON_DIR/framework/capabilities/packs/api/manifest.yml" \
    "$OCTON_DIR/instance/capabilities/runtime/packs/registry.yml"
  check_clean "current release disclosure" \
    "$OCTON_DIR/instance/governance/disclosure/harness-card.yml" \
    "$OCTON_DIR/state/evidence/disclosure/releases/2026-04-04-uec-global-completion/harness-card.yml" \
    "$OCTON_DIR/state/evidence/disclosure/releases/2026-04-04-uec-global-completion/closure/support-universe-coverage.yml" \
    "$OCTON_DIR/state/evidence/disclosure/releases/2026-04-04-uec-global-completion/closure/closure-certificate.yml" \
    "$OCTON_DIR/state/evidence/disclosure/releases/2026-04-04-uec-global-completion/closure/proof-plane-coverage.yml" \
    "$OCTON_DIR/state/evidence/control/execution/authority-decision-uec-global-frontier-browser-api-studio-20260404.yml" \
    "$OCTON_DIR/state/evidence/control/execution/authority-grant-bundle-uec-global-frontier-browser-api-studio-20260404.yml"

  local run_id
  for run_id in \
    "$(role_run_id supported_run_only)" \
    "$(role_run_id authority_exercise)" \
    "$(role_run_id external_evidence)" \
    "$(role_run_id intervention_control)" \
    "$(role_run_id github_projection)" \
    "$(role_run_id ci_projection)"; do
    [[ -n "$run_id" ]] || continue
    check_clean "run bundle $run_id" \
      "$OCTON_DIR/state/control/execution/runs/$run_id" \
      "$OCTON_DIR/state/evidence/runs/$run_id" \
      "$OCTON_DIR/state/evidence/disclosure/runs/$run_id"
  done

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
