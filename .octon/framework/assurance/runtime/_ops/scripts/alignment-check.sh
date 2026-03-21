#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"

PROFILE_CSV=""
LIST_PROFILES=0
DRY_RUN=0
errors=0

usage() {
  cat <<'USAGE'
Usage: alignment-check.sh --profile <aspect[,aspect...]> [--dry-run]
       alignment-check.sh --list-profiles

Run repeatable alignment checks by profile.

Examples:
  alignment-check.sh --list-profiles
  alignment-check.sh --profile commit-pr
  alignment-check.sh --profile skills,workflows
  alignment-check.sh --profile all
USAGE
}

list_profiles() {
  cat <<'PROFILES'
Profiles:
  commit-pr   Commit and PR standards alignment checks
  harness     .octon architecture and drift guardrail checks
  framing     Canonical framing drift checks
  intent-layer Intent contract, boundary, capability-map, and mode-gate checks
  agency      Agency contract and registry checks
  workflows   Workflow manifest/registry/path contract checks
  skills      Skill contract and drift checks (strict mode)
  services    Services contract and interop boundary checks
  weights     Weighted assurance score and gate checks
  all         Run all profiles above in sequence
PROFILES
}

run_step() {
  local label="$1"
  shift

  echo "==> $label"
  if [[ $DRY_RUN -eq 1 ]]; then
    printf '[DRY] '
    printf '%q ' "$@"
    printf '\n'
    return 0
  fi

  if "$@"; then
    echo "[OK] $label"
  else
    echo "[ERROR] $label"
    errors=$((errors + 1))
  fi
}

run_commit_pr() {
  run_step \
    "Validate commit/PR standards alignment" \
    bash "$SCRIPT_DIR/validate-commit-pr-alignment.sh"
}

run_harness() {
  run_step \
    "Validate harness structure contract" \
    bash "$SCRIPT_DIR/validate-harness-structure.sh"

  run_step \
    "Validate harness version compatibility contract" \
    bash "$SCRIPT_DIR/validate-harness-version-contract.sh"

  run_step \
    "Validate root manifest profile contract" \
    bash "$SCRIPT_DIR/validate-root-manifest-profiles.sh"

  run_step \
    "Validate framework and instance companion manifests" \
    bash "$SCRIPT_DIR/validate-companion-manifests.sh"

  run_step \
    "Validate framework overlay registry and enablement contract" \
    bash "$SCRIPT_DIR/validate-overlay-points.sh"

  run_step \
    "Validate framework core boundary clear-break contract" \
    bash "$SCRIPT_DIR/validate-framework-core-boundary.sh"

  run_step \
    "Validate repo-instance boundary clear-break contract" \
    bash "$SCRIPT_DIR/validate-repo-instance-boundary.sh"

  run_step \
    "Validate locality registry and scope contract" \
    bash "$SCRIPT_DIR/validate-locality-registry.sh"

  run_step \
    "Validate additive extension pack contract" \
    bash "$SCRIPT_DIR/validate-extension-pack-contract.sh"

  run_step \
    "Validate export profile contract and current snapshot completeness" \
    bash "$SCRIPT_DIR/validate-export-profile-contract.sh"

  run_step \
    "Validate contract governance coverage and _ops boundaries" \
    bash "$SCRIPT_DIR/validate-contract-governance.sh"

  run_step \
    "Validate SSOT precedence drift contract" \
    bash "$SCRIPT_DIR/validate-ssot-precedence-drift.sh"

  run_step \
    "Validate continuity memory contracts" \
    bash "$SCRIPT_DIR/validate-continuity-memory.sh"

  run_step \
    "Validate Packet 7 state-surface wording alignment" \
    bash "$SCRIPT_DIR/validate-state-surface-alignment.sh"

  run_step \
    "Validate audit-subsystem-health drift alignment" \
    bash "$SCRIPT_DIR/validate-audit-subsystem-health-alignment.sh"

  run_step \
    "Validate capability/engine consistency contract" \
    bash "$SCRIPT_DIR/validate-capability-engine-consistency.sh"

  run_step \
    "Publish capability routing state" \
    bash "$OCTON_DIR/framework/capabilities/_ops/scripts/publish-capability-routing.sh"

  run_step \
    "Validate runtime effective state and Packet 14 fail-closed trust gate" \
    bash "$SCRIPT_DIR/validate-runtime-effective-state.sh"

  run_step \
    "Publish host capability projections" \
    bash "$OCTON_DIR/framework/capabilities/_ops/scripts/publish-host-projections.sh"

  run_step \
    "Validate host capability projections" \
    bash "$SCRIPT_DIR/validate-host-projections.sh"

  run_step \
    "Validate developer context policy contract" \
    bash "$SCRIPT_DIR/validate-developer-context-policy.sh"

  run_step \
    "Validate bootstrap ingress and objective contract" \
    bash "$SCRIPT_DIR/validate-bootstrap-ingress.sh"

  run_step \
    "Validate bootstrap projection parity" \
    bash "$SCRIPT_DIR/validate-bootstrap-projections.sh"

  run_step \
    "Validate context overhead budget contract" \
    bash "$SCRIPT_DIR/validate-context-overhead-budget.sh"

  run_step \
    "Validate context-governance clean-break banlist entries" \
    rg -n "context-governance-clean-break|instruction-layer|context-acquisition" \
      "$OCTON_DIR/framework/cognition/practices/methodology/migrations/legacy-banlist.md"

  run_step \
    "Validate context-governance clean-break CI gate doctrine entries" \
    rg -n "Context governance clean-break|instruction-layer|context-acquisition|context-overhead|Profile Selection Receipt|change_profile|release_state|transitional_exception_note" \
      "$OCTON_DIR/framework/cognition/practices/methodology/migrations/ci-gates.md"

  run_step \
    "Validate execution-profile governance doctrine entries" \
    rg -n "change_profile|release_state|transitional_exception_note|Profile Selection Receipt|Impact Map|Compliance Receipt|Exceptions/Escalations" \
      "$OCTON_DIR/framework/cognition/practices/methodology/migrations/README.md" \
      "$OCTON_DIR/framework/cognition/practices/methodology/migrations/doctrine.md" \
      "$OCTON_DIR/framework/cognition/practices/methodology/migrations/ci-gates.md" \
      "$OCTON_DIR/framework/scaffolding/runtime/templates/migrations/template.clean-break-migration.md"

  run_step \
    "Validate tier downgrade governance policy contract" \
    bash "$SCRIPT_DIR/validate-tier-downgrade-policy.sh"

  run_step \
    "Validate execution-profile governance PR contract entries" \
    rg -n "Profile Selection Receipt|Implementation Plan|Impact Map \\(code, tests, docs, contracts\\)|Compliance Receipt|Exceptions/Escalations|change_profile" \
      "$OCTON_DIR/framework/agency/practices/pull-request-standards.md" \
      "$OCTON_DIR/../.github/PULL_REQUEST_TEMPLATE.md" \
      "$OCTON_DIR/../.github/PULL_REQUEST_TEMPLATE/kaizen.md"

  run_step \
    "Validate workflow execution_profile and governance change_profile disambiguation" \
    rg -n "execution_profile|core\\|external-dependent|change_profile" \
      "$OCTON_DIR/framework/orchestration/runtime/workflows/README.md"

  run_step \
    "Validate bounded-audit convergence contract" \
    bash "$SCRIPT_DIR/validate-audit-convergence-contract.sh"

  run_step \
    "Validate canonical framing alignment" \
    bash "$SCRIPT_DIR/validate-framing-alignment.sh"
}

run_framing() {
  run_step \
    "Validate canonical framing alignment" \
    bash "$SCRIPT_DIR/validate-framing-alignment.sh"
}

run_intent_layer() {
  run_step \
    "Validate intent layer contracts and enforcement wiring" \
    bash "$SCRIPT_DIR/validate-intent-layer.sh"
}

run_agency() {
  run_step \
    "Validate agency contracts" \
    bash "$OCTON_DIR/agency/_ops/scripts/validate/validate-agency.sh"
}

run_workflows() {
  run_step \
    "Validate workflow contracts" \
    bash "$OCTON_DIR/orchestration/runtime/workflows/_ops/scripts/validate-workflows.sh"

  run_step \
    "Validate architecture validation workflow package" \
    bash "$SCRIPT_DIR/validate-audit-design-proposal-workflow.sh"

  run_step \
    "Validate create-design-proposal workflow" \
    bash "$SCRIPT_DIR/validate-create-design-proposal-workflow.sh"
}

run_skills() {
  run_step \
    "Validate skill contracts (strict)" \
    bash "$OCTON_DIR/capabilities/runtime/skills/_ops/scripts/validate-skills.sh" --strict
}

run_services() {
  run_step \
    "Validate service contracts" \
    bash "$OCTON_DIR/capabilities/runtime/services/_ops/scripts/validate-services.sh"

  run_step \
    "Validate service independence boundaries" \
    bash "$OCTON_DIR/capabilities/runtime/services/_ops/scripts/validate-service-independence.sh" --mode all

  run_step \
    "Validate filesystem interface contracts" \
    bash "$OCTON_DIR/capabilities/runtime/services/_ops/scripts/validate-filesystem-interfaces.sh"
}

run_weights() {
  local out_dir="$OCTON_DIR/generated/.tmp/assurance/engine-alignment"
  run_step \
    "Compute assurance engine scorecard" \
    bash "$OCTON_DIR/assurance/runtime/_ops/scripts/compute-assurance-score.sh" \
      --weights "$OCTON_DIR/assurance/governance/weights/weights.yml" \
      --scores "$OCTON_DIR/assurance/governance/scores/scores.yml" \
      --charter "$OCTON_DIR/assurance/governance/CHARTER.md" \
      --context "$OCTON_DIR/assurance/governance/weights/inputs/context.yml" \
      --profile ci-reliability \
      --run-mode ci \
      --maturity beta \
      --repo octon \
      --out-dir "$out_dir"

  run_step \
    "Run assurance engine gate" \
    bash "$OCTON_DIR/assurance/runtime/_ops/scripts/assurance-gate.sh" \
      --scorecard "$out_dir/scorecard.yml" \
      --weights "$OCTON_DIR/assurance/governance/weights/weights.yml" \
      --scores "$OCTON_DIR/assurance/governance/scores/scores.yml" \
      --charter "$OCTON_DIR/assurance/governance/CHARTER.md" \
      --baseline-weights "$OCTON_DIR/assurance/governance/weights/weights.yml" \
      --baseline-scores "$OCTON_DIR/assurance/governance/scores/scores.yml" \
      --baseline-charter "$OCTON_DIR/assurance/governance/CHARTER.md" \
      --mode ci \
      --summary-out "$out_dir/gate-summary.md"
}

run_profile() {
  local profile="$1"
  case "$profile" in
    commit-pr) run_commit_pr ;;
    harness) run_harness ;;
    framing) run_framing ;;
    intent-layer) run_intent_layer ;;
    agency) run_agency ;;
    workflows) run_workflows ;;
    skills) run_skills ;;
    services) run_services ;;
    weights) run_weights ;;
    all)
      run_commit_pr
      run_harness
      run_intent_layer
      run_agency
      run_workflows
      run_skills
      run_services
      run_weights
      ;;
    *)
      echo "[ERROR] unknown profile: $profile" >&2
      echo "Use --list-profiles to see available options." >&2
      errors=$((errors + 1))
      ;;
  esac
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile)
      shift
      [[ $# -gt 0 ]] || { echo "[ERROR] --profile requires a value" >&2; exit 2; }
      PROFILE_CSV="$1"
      ;;
    --list-profiles)
      LIST_PROFILES=1
      ;;
    --dry-run)
      DRY_RUN=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[ERROR] unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
  shift
done

if [[ $LIST_PROFILES -eq 1 ]]; then
  list_profiles
  exit 0
fi

if [[ -z "$PROFILE_CSV" ]]; then
  echo "[ERROR] --profile is required unless --list-profiles is set" >&2
  usage >&2
  exit 2
fi

echo "== Alignment Check =="
echo "Profiles: $PROFILE_CSV"
if [[ $DRY_RUN -eq 1 ]]; then
  echo "Mode: dry-run"
fi
echo

IFS=',' read -r -a profiles <<< "$PROFILE_CSV"
for profile in "${profiles[@]}"; do
  # trim spaces around each comma-separated profile
  profile="${profile#"${profile%%[![:space:]]*}"}"
  profile="${profile%"${profile##*[![:space:]]}"}"
  [[ -z "$profile" ]] && continue
  run_profile "$profile"
done

echo
echo "Alignment check summary: errors=$errors"
if [[ $errors -gt 0 ]]; then
  exit 1
fi
