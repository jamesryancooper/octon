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
require_file "$OCTON_DIR/framework/overlay-points/registry.yml"
require_dir "$OCTON_DIR/framework/agency"
require_dir "$OCTON_DIR/framework/assurance"
require_dir "$OCTON_DIR/framework/capabilities"
require_dir "$OCTON_DIR/framework/cognition"
require_dir "$OCTON_DIR/framework/engine"
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
require_file "$OCTON_DIR/instance/cognition/context/index.yml"
require_file "$OCTON_DIR/instance/cognition/context/shared/intent.contract.yml"
require_dir "$OCTON_DIR/instance/cognition/decisions"

require_dir "$OCTON_DIR/inputs/exploratory"
require_dir "$OCTON_DIR/inputs/exploratory/proposals"
require_dir "$OCTON_DIR/inputs/exploratory/ideation"
require_dir "$OCTON_DIR/inputs/exploratory/plans"
require_dir "$OCTON_DIR/inputs/exploratory/drafts"
require_dir "$OCTON_DIR/inputs/exploratory/packages"

require_dir "$OCTON_DIR/state/continuity/repo"
require_file "$OCTON_DIR/state/continuity/repo/log.md"
require_file "$OCTON_DIR/state/continuity/repo/tasks.json"
require_file "$OCTON_DIR/state/continuity/repo/entities.json"
require_file "$OCTON_DIR/state/continuity/repo/next.md"
require_dir "$OCTON_DIR/state/control/extensions"
require_file "$OCTON_DIR/state/control/extensions/active.yml"
require_file "$OCTON_DIR/state/control/extensions/quarantine.yml"
require_dir "$OCTON_DIR/state/control/capabilities"
require_dir "$OCTON_DIR/state/control/skills"
require_dir "$OCTON_DIR/state/control/engine"
require_dir "$OCTON_DIR/state/evidence/decisions/repo"
require_dir "$OCTON_DIR/state/evidence/decisions/repo/capabilities"
require_dir "$OCTON_DIR/state/evidence/runs"
require_dir "$OCTON_DIR/state/evidence/runs/skills"
require_dir "$OCTON_DIR/state/evidence/runs/services"
require_dir "$OCTON_DIR/state/evidence/runs/engine"
require_dir "$OCTON_DIR/state/evidence/validation"
require_dir "$OCTON_DIR/state/evidence/migration"

require_dir "$OCTON_DIR/generated/effective"
require_dir "$OCTON_DIR/generated/effective/assurance"
require_dir "$OCTON_DIR/generated/effective/capabilities"
require_dir "$OCTON_DIR/generated/effective/capabilities/filesystem-snapshots"
require_dir "$OCTON_DIR/generated/proposals"

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
    manifest.yml|overlay-points|agency|assurance|capabilities|cognition|engine|orchestration|scaffolding)
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
