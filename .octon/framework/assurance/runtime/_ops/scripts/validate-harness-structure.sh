#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
FRAMEWORK_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
OCTON_DIR="$(cd -- "$FRAMEWORK_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

require_file() {
  local path="$1"
  if [[ -f "$path" ]]; then
    pass "found file: ${path#$ROOT_DIR/}"
  else
    fail "missing file: ${path#$ROOT_DIR/}"
  fi
}

require_dir() {
  local path="$1"
  if [[ -d "$path" ]]; then
    pass "found directory: ${path#$ROOT_DIR/}"
  else
    fail "missing directory: ${path#$ROOT_DIR/}"
  fi
}

echo "== Harness Structure Validation =="

require_file "$OCTON_DIR/README.md"
require_file "$OCTON_DIR/AGENTS.md"
require_file "$OCTON_DIR/octon.yml"

require_dir "$OCTON_DIR/framework"
require_dir "$OCTON_DIR/instance"
require_dir "$OCTON_DIR/inputs"
require_dir "$OCTON_DIR/inputs/additive"
require_dir "$OCTON_DIR/inputs/additive/extensions"
require_dir "$OCTON_DIR/state"
require_dir "$OCTON_DIR/generated"

require_file "$OCTON_DIR/framework/manifest.yml"
require_dir "$OCTON_DIR/framework/constitution"
require_file "$OCTON_DIR/framework/constitution/CHARTER.md"
require_file "$OCTON_DIR/framework/constitution/charter.yml"
require_dir "$OCTON_DIR/framework/constitution/precedence"
require_file "$OCTON_DIR/framework/constitution/precedence/normative.yml"
require_file "$OCTON_DIR/framework/constitution/precedence/epistemic.yml"
require_dir "$OCTON_DIR/framework/constitution/obligations"
require_file "$OCTON_DIR/framework/constitution/obligations/fail-closed.yml"
require_file "$OCTON_DIR/framework/constitution/obligations/evidence.yml"
require_dir "$OCTON_DIR/framework/constitution/ownership"
require_file "$OCTON_DIR/framework/constitution/ownership/roles.yml"
require_dir "$OCTON_DIR/framework/constitution/contracts"
require_file "$OCTON_DIR/framework/constitution/contracts/registry.yml"
require_dir "$OCTON_DIR/framework/constitution/contracts/authority"
require_file "$OCTON_DIR/framework/constitution/contracts/authority/README.md"
require_file "$OCTON_DIR/framework/constitution/contracts/authority/family.yml"
require_file "$OCTON_DIR/framework/constitution/contracts/authority/approval-request-v1.schema.json"
require_file "$OCTON_DIR/framework/constitution/contracts/authority/approval-grant-v1.schema.json"
require_file "$OCTON_DIR/framework/constitution/contracts/authority/exception-lease-v1.schema.json"
require_file "$OCTON_DIR/framework/constitution/contracts/authority/revocation-v1.schema.json"
require_file "$OCTON_DIR/framework/constitution/contracts/authority/decision-artifact-v1.schema.json"
require_file "$OCTON_DIR/framework/constitution/contracts/authority/grant-bundle-v1.schema.json"
require_file "$OCTON_DIR/framework/constitution/support-targets.schema.json"
require_file "$OCTON_DIR/framework/overlay-points/registry.yml"
require_dir "$OCTON_DIR/framework/agency"
require_dir "$OCTON_DIR/framework/assurance"
require_dir "$OCTON_DIR/framework/capabilities"
require_dir "$OCTON_DIR/framework/cognition"
require_dir "$OCTON_DIR/framework/cognition/_meta/architecture/inputs/additive/extensions"
require_file "$OCTON_DIR/framework/cognition/_meta/architecture/inputs/additive/extensions/README.md"
require_file "$OCTON_DIR/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas/README.md"
require_file "$OCTON_DIR/framework/cognition/_meta/architecture/inputs/additive/extensions/schemas/extension-pack.schema.json"
require_dir "$OCTON_DIR/framework/cognition/_meta/architecture/instance/extensions"
require_file "$OCTON_DIR/framework/cognition/_meta/architecture/instance/extensions/README.md"
require_file "$OCTON_DIR/framework/cognition/_meta/architecture/instance/extensions/schemas/README.md"
require_file "$OCTON_DIR/framework/cognition/_meta/architecture/instance/extensions/schemas/instance-extensions.schema.json"
require_file "$OCTON_DIR/framework/cognition/_meta/architecture/state/README.md"
require_file "$OCTON_DIR/framework/cognition/_meta/architecture/state/evidence/README.md"
require_file "$OCTON_DIR/framework/cognition/_meta/architecture/state/control/README.md"
require_file "$OCTON_DIR/framework/cognition/_meta/architecture/state/control/schemas/README.md"
require_file "$OCTON_DIR/framework/cognition/_meta/architecture/state/control/schemas/extension-active-state.schema.json"
require_file "$OCTON_DIR/framework/cognition/_meta/architecture/state/control/schemas/extension-quarantine-state.schema.json"
require_file "$OCTON_DIR/framework/cognition/_meta/architecture/state/control/schemas/locality-quarantine-state.schema.json"
require_file "$OCTON_DIR/framework/cognition/_meta/architecture/contract-registry.yml"
require_dir "$OCTON_DIR/framework/assurance/runtime/contracts"
require_file "$OCTON_DIR/framework/assurance/runtime/contracts/README.md"
require_file "$OCTON_DIR/framework/assurance/runtime/contracts/alignment-profiles.yml"
require_file "$OCTON_DIR/framework/assurance/runtime/contracts/github-action-pin-policy.yml"
require_file "$OCTON_DIR/framework/cognition/_meta/architecture/generated/README.md"
require_file "$OCTON_DIR/framework/cognition/_meta/architecture/generated/effective/README.md"
require_dir "$OCTON_DIR/framework/cognition/_meta/architecture/generated/effective/locality"
require_file "$OCTON_DIR/framework/cognition/_meta/architecture/generated/effective/locality/README.md"
require_file "$OCTON_DIR/framework/cognition/_meta/architecture/generated/effective/locality/schemas/README.md"
require_file "$OCTON_DIR/framework/cognition/_meta/architecture/generated/effective/locality/schemas/locality-effective-scopes.schema.json"
require_file "$OCTON_DIR/framework/cognition/_meta/architecture/generated/effective/locality/schemas/locality-artifact-map.schema.json"
require_file "$OCTON_DIR/framework/cognition/_meta/architecture/generated/effective/locality/schemas/locality-generation-lock.schema.json"
require_dir "$OCTON_DIR/framework/cognition/_meta/architecture/generated/effective/capabilities"
require_file "$OCTON_DIR/framework/cognition/_meta/architecture/generated/effective/capabilities/README.md"
require_file "$OCTON_DIR/framework/cognition/_meta/architecture/generated/effective/capabilities/schemas/README.md"
require_file "$OCTON_DIR/framework/cognition/_meta/architecture/generated/effective/capabilities/schemas/capability-routing-effective.schema.json"
require_file "$OCTON_DIR/framework/cognition/_meta/architecture/generated/effective/capabilities/schemas/capability-routing-artifact-map.schema.json"
require_file "$OCTON_DIR/framework/cognition/_meta/architecture/generated/effective/capabilities/schemas/capability-routing-generation-lock.schema.json"
require_dir "$OCTON_DIR/framework/cognition/_meta/architecture/generated/effective/extensions"
require_file "$OCTON_DIR/framework/cognition/_meta/architecture/generated/effective/extensions/README.md"
require_file "$OCTON_DIR/framework/cognition/_meta/architecture/generated/effective/extensions/schemas/README.md"
require_file "$OCTON_DIR/framework/cognition/_meta/architecture/generated/effective/extensions/schemas/extension-effective-catalog.schema.json"
require_file "$OCTON_DIR/framework/cognition/_meta/architecture/generated/effective/extensions/schemas/extension-artifact-map.schema.json"
require_file "$OCTON_DIR/framework/cognition/_meta/architecture/generated/effective/extensions/schemas/extension-generation-lock.schema.json"
require_dir "$OCTON_DIR/framework/cognition/_meta/architecture/generated/cognition"
require_file "$OCTON_DIR/framework/cognition/_meta/architecture/generated/cognition/README.md"
require_file "$OCTON_DIR/framework/cognition/_meta/architecture/generated/cognition/projections/README.md"
require_file "$OCTON_DIR/framework/cognition/_meta/architecture/generated/cognition/summaries/README.md"
require_dir "$OCTON_DIR/framework/cognition/_meta/architecture/generated/proposals"
require_file "$OCTON_DIR/framework/cognition/_meta/architecture/generated/proposals/README.md"
require_file "$OCTON_DIR/framework/cognition/_meta/architecture/generated/proposals/schemas/README.md"
require_file "$OCTON_DIR/framework/cognition/_meta/architecture/generated/proposals/schemas/proposal-registry.schema.json"
require_dir "$OCTON_DIR/framework/engine"
require_dir "$OCTON_DIR/framework/engine/governance/extensions"
require_file "$OCTON_DIR/framework/engine/governance/extensions/README.md"
require_file "$OCTON_DIR/framework/engine/governance/extensions/boundary-contract.md"
require_file "$OCTON_DIR/framework/engine/governance/extensions/trust-and-compatibility.md"
require_file "$OCTON_DIR/framework/engine/runtime/release-targets.yml"
require_dir "$OCTON_DIR/framework/orchestration"
require_dir "$OCTON_DIR/framework/scaffolding"

require_file "$OCTON_DIR/instance/manifest.yml"
require_file "$OCTON_DIR/instance/ingress/AGENTS.md"
require_file "$OCTON_DIR/instance/bootstrap/START.md"
require_file "$OCTON_DIR/instance/bootstrap/OBJECTIVE.md"
require_file "$OCTON_DIR/instance/bootstrap/scope.md"
require_file "$OCTON_DIR/instance/bootstrap/conventions.md"
require_file "$OCTON_DIR/instance/bootstrap/catalog.md"
require_file "$OCTON_DIR/instance/bootstrap/init.sh"
require_file "$OCTON_DIR/instance/extensions.yml"
require_file "$OCTON_DIR/instance/locality/README.md"
require_file "$OCTON_DIR/instance/locality/manifest.yml"
require_file "$OCTON_DIR/instance/locality/registry.yml"
require_dir "$OCTON_DIR/instance/locality/scopes"
require_file "$OCTON_DIR/instance/cognition/context/index.yml"
require_file "$OCTON_DIR/instance/cognition/context/shared/intent.contract.yml"
require_dir "$OCTON_DIR/instance/cognition/context/scopes"
require_file "$OCTON_DIR/instance/cognition/context/scopes/README.md"
require_dir "$OCTON_DIR/instance/cognition/decisions"
require_dir "$OCTON_DIR/instance/capabilities/runtime"
require_dir "$OCTON_DIR/instance/capabilities/runtime/skills"
require_dir "$OCTON_DIR/instance/capabilities/runtime/commands"
require_file "$OCTON_DIR/instance/capabilities/runtime/commands/README.md"
require_file "$OCTON_DIR/instance/capabilities/runtime/commands/manifest.yml"
require_file "$OCTON_DIR/instance/capabilities/runtime/skills/README.md"
require_file "$OCTON_DIR/instance/capabilities/runtime/skills/manifest.yml"
require_dir "$OCTON_DIR/instance/orchestration/missions"
require_file "$OCTON_DIR/instance/orchestration/missions/README.md"
require_file "$OCTON_DIR/instance/orchestration/missions/registry.yml"
require_dir "$OCTON_DIR/instance/orchestration/missions/.archive"
require_dir "$OCTON_DIR/instance/orchestration/missions/_scaffold/template"
require_file "$OCTON_DIR/instance/orchestration/missions/_scaffold/template/mission.yml"
require_file "$OCTON_DIR/instance/orchestration/missions/_scaffold/template/mission.md"
require_file "$OCTON_DIR/instance/orchestration/missions/_scaffold/template/tasks.json"
require_file "$OCTON_DIR/instance/orchestration/missions/_scaffold/template/log.md"
require_dir "$OCTON_DIR/instance/governance/policies"
require_file "$OCTON_DIR/instance/governance/policies/README.md"
require_file "$OCTON_DIR/instance/governance/policies/network-egress.yml"
require_file "$OCTON_DIR/instance/governance/policies/execution-budgets.yml"
require_file "$OCTON_DIR/instance/governance/support-targets.yml"
require_dir "$OCTON_DIR/instance/governance/contracts"
require_file "$OCTON_DIR/instance/governance/contracts/README.md"
require_dir "$OCTON_DIR/instance/agency/runtime"
require_file "$OCTON_DIR/instance/agency/runtime/README.md"
require_dir "$OCTON_DIR/instance/assurance/runtime"
require_file "$OCTON_DIR/instance/assurance/runtime/README.md"

require_dir "$OCTON_DIR/inputs/exploratory"
require_dir "$OCTON_DIR/inputs/exploratory/proposals"
require_dir "$OCTON_DIR/inputs/exploratory/ideation"
require_dir "$OCTON_DIR/inputs/exploratory/plans"
require_dir "$OCTON_DIR/inputs/exploratory/drafts"
require_dir "$OCTON_DIR/inputs/exploratory/packages"

require_dir "$OCTON_DIR/state/continuity/repo"
require_file "$OCTON_DIR/state/continuity/README.md"
require_file "$OCTON_DIR/state/continuity/repo/log.md"
require_file "$OCTON_DIR/state/continuity/repo/tasks.json"
require_file "$OCTON_DIR/state/continuity/repo/entities.json"
require_file "$OCTON_DIR/state/continuity/repo/next.md"
require_dir "$OCTON_DIR/state/continuity/scopes"
require_file "$OCTON_DIR/state/evidence/README.md"
require_file "$OCTON_DIR/state/control/README.md"
require_dir "$OCTON_DIR/state/control/locality"
require_file "$OCTON_DIR/state/control/locality/quarantine.yml"
require_dir "$OCTON_DIR/state/control/extensions"
require_file "$OCTON_DIR/state/control/extensions/active.yml"
require_file "$OCTON_DIR/state/control/extensions/quarantine.yml"
require_dir "$OCTON_DIR/state/control/capabilities"
require_dir "$OCTON_DIR/state/control/execution"
require_file "$OCTON_DIR/state/control/execution/budget-state.yml"
require_dir "$OCTON_DIR/state/control/execution/approvals"
require_file "$OCTON_DIR/state/control/execution/approvals/README.md"
require_dir "$OCTON_DIR/state/control/execution/approvals/requests"
require_dir "$OCTON_DIR/state/control/execution/approvals/grants"
require_dir "$OCTON_DIR/state/control/execution/exceptions"
require_file "$OCTON_DIR/state/control/execution/exceptions/README.md"
require_file "$OCTON_DIR/state/control/execution/exceptions/leases.yml"
require_dir "$OCTON_DIR/state/control/execution/revocations"
require_file "$OCTON_DIR/state/control/execution/revocations/README.md"
require_file "$OCTON_DIR/state/control/execution/revocations/grants.yml"
require_dir "$OCTON_DIR/state/control/skills"
require_dir "$OCTON_DIR/state/control/engine"
require_dir "$OCTON_DIR/state/evidence/decisions/repo"
require_dir "$OCTON_DIR/state/evidence/decisions/repo/capabilities"
require_dir "$OCTON_DIR/state/evidence/decisions/scopes"
require_file "$OCTON_DIR/state/evidence/decisions/scopes/README.md"
require_dir "$OCTON_DIR/state/evidence/runs"
require_dir "$OCTON_DIR/state/evidence/runs/skills"
require_dir "$OCTON_DIR/state/evidence/runs/services"
require_dir "$OCTON_DIR/state/evidence/runs/engine"
require_dir "$OCTON_DIR/state/evidence/validation"
require_dir "$OCTON_DIR/state/evidence/validation/assurance"
require_file "$OCTON_DIR/state/evidence/validation/assurance/README.md"
require_dir "$OCTON_DIR/state/evidence/validation/assurance/effective"
require_dir "$OCTON_DIR/state/evidence/validation/assurance/results"
require_dir "$OCTON_DIR/state/evidence/validation/assurance/scorecards"
require_dir "$OCTON_DIR/state/evidence/validation/publication"
require_file "$OCTON_DIR/state/evidence/validation/publication/README.md"
require_dir "$OCTON_DIR/state/evidence/validation/publication/locality"
require_dir "$OCTON_DIR/state/evidence/validation/publication/extensions"
require_dir "$OCTON_DIR/state/evidence/validation/publication/capabilities"
require_dir "$OCTON_DIR/state/evidence/migration"

require_dir "$OCTON_DIR/generated/effective"
require_dir "$OCTON_DIR/generated/effective/capabilities"
require_dir "$OCTON_DIR/generated/effective/capabilities/filesystem-snapshots"
require_file "$OCTON_DIR/generated/effective/capabilities/routing.effective.yml"
require_file "$OCTON_DIR/generated/effective/capabilities/artifact-map.yml"
require_file "$OCTON_DIR/generated/effective/capabilities/generation.lock.yml"
require_dir "$OCTON_DIR/generated/effective/extensions"
require_file "$OCTON_DIR/generated/effective/extensions/catalog.effective.yml"
require_file "$OCTON_DIR/generated/effective/extensions/artifact-map.yml"
require_file "$OCTON_DIR/generated/effective/extensions/generation.lock.yml"
require_file "$OCTON_DIR/framework/capabilities/_ops/scripts/publish-host-projections.sh"
require_file "$OCTON_DIR/framework/assurance/runtime/_ops/scripts/validate-host-projections.sh"
require_file "$OCTON_DIR/framework/assurance/runtime/_ops/scripts/validate-architecture-conformance.sh"
require_file "$OCTON_DIR/framework/assurance/runtime/_ops/scripts/validate-alignment-profile-registry.sh"
require_file "$OCTON_DIR/framework/assurance/runtime/_ops/scripts/classify-authoritative-doc-change.sh"
require_file "$OCTON_DIR/framework/assurance/runtime/_ops/scripts/validate-authoritative-doc-triggers.sh"
require_file "$OCTON_DIR/framework/assurance/runtime/_ops/scripts/validate-github-action-pins.sh"
require_file "$OCTON_DIR/framework/assurance/runtime/_ops/scripts/validate-runtime-target-parity.sh"
require_file "$OCTON_DIR/framework/assurance/runtime/_ops/scripts/validate-runtime-effective-state.sh"
require_dir "$OCTON_DIR/generated/effective/locality"
require_file "$OCTON_DIR/generated/effective/locality/scopes.effective.yml"
require_file "$OCTON_DIR/generated/effective/locality/artifact-map.yml"
require_file "$OCTON_DIR/generated/effective/locality/generation.lock.yml"
require_dir "$OCTON_DIR/generated/cognition"
require_dir "$OCTON_DIR/generated/proposals"
require_file "$OCTON_DIR/generated/proposals/registry.yml"
require_file "$ROOT_DIR/.github/workflows/dependency-review.yml"

if [[ -e "$OCTON_DIR/instance/cognition/context/shared/decisions.md" ]]; then
  fail "retired generated decisions summary still exists: .octon/instance/cognition/context/shared/decisions.md"
else
  pass "retired instance-local generated decisions summary removed"
fi

unexpected_octon_entries=()
while IFS= read -r entry; do
  rel="${entry#$OCTON_DIR/}"
  case "$rel" in
    README.md|AGENTS.md|octon.yml|framework|instance|inputs|state|generated)
      ;;
    *)
      unexpected_octon_entries+=(".octon/$rel")
      ;;
  esac
done < <(find "$OCTON_DIR" -mindepth 1 -maxdepth 1 -print | sort)

if [[ "${#unexpected_octon_entries[@]}" -gt 0 ]]; then
  fail "unexpected top-level .octon entries remain outside the five-class topology"
  printf '%s\n' "${unexpected_octon_entries[@]}"
else
  pass "no unexpected top-level .octon entries remain"
fi

unexpected_framework_entries=()
while IFS= read -r entry; do
  rel="${entry#$OCTON_DIR/framework/}"
  case "$rel" in
    manifest.yml|overlay-points|agency|assurance|capabilities|cognition|constitution|engine|orchestration|scaffolding)
      ;;
    *)
      unexpected_framework_entries+=("framework/$rel")
      ;;
  esac
done < <(find "$OCTON_DIR/framework" -mindepth 1 -maxdepth 1 -print | sort)

if [[ "${#unexpected_framework_entries[@]}" -gt 0 ]]; then
  fail "unexpected framework top-level entries remain outside the Packet 3 framework bundle"
  printf '%s\n' "${unexpected_framework_entries[@]}"
else
  pass "no unexpected framework top-level entries remain"
fi

if [[ -e "$OCTON_DIR/continuity" ]]; then
  fail "legacy continuity root still exists: .octon/continuity"
else
  pass "legacy continuity root removed"
fi

if [[ -e "$OCTON_DIR/output" ]]; then
  fail "legacy output root still exists: .octon/output"
else
  pass "legacy output root removed"
fi

if [[ -e "$OCTON_DIR/generated/artifacts" ]]; then
  fail "legacy generated artifacts bucket still exists: .octon/generated/artifacts"
else
  pass "legacy generated artifacts bucket removed"
fi

if [[ -e "$OCTON_DIR/generated/assurance" ]]; then
  fail "legacy generated assurance bucket still exists: .octon/generated/assurance"
else
  pass "legacy generated assurance bucket removed"
fi

if [[ -e "$OCTON_DIR/generated/effective/assurance" ]]; then
  fail "legacy generated effective assurance surface still exists: .octon/generated/effective/assurance"
else
  pass "legacy generated effective assurance surface removed"
fi

if [[ -e "$OCTON_DIR/ideation" ]]; then
  fail "legacy ideation root still exists: .octon/ideation"
else
  pass "legacy ideation root removed"
fi

if [[ -e "$ROOT_DIR/.proposals" ]]; then
  fail "legacy repo-root .proposals still exists"
else
  pass "legacy repo-root .proposals removed"
fi

if [[ "$errors" -gt 0 ]]; then
  echo ""
  echo "Validation summary: errors=$errors warnings=0"
  exit 1
fi

echo ""
echo "Validation summary: errors=0 warnings=0"
