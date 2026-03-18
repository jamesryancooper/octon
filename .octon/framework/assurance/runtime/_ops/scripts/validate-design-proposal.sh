#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
OCTON_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

PROPOSAL_PATH=""
errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

usage() {
  cat <<'EOF'
usage:
  validate-design-proposal.sh --package <path>
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --package)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      PROPOSAL_PATH="$1"
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
  shift
done

[[ -n "$PROPOSAL_PATH" ]] || { usage >&2; exit 2; }

if [[ "$PROPOSAL_PATH" = /* ]]; then
  PROPOSAL_DIR="$PROPOSAL_PATH"
else
  PROPOSAL_DIR="$ROOT_DIR/$PROPOSAL_PATH"
fi

MANIFEST="$PROPOSAL_DIR/design-proposal.yml"
PROPOSAL_MANIFEST="$PROPOSAL_DIR/proposal.yml"

[[ -f "$PROPOSAL_MANIFEST" ]] || fail "base proposal manifest exists"
[[ -f "$MANIFEST" ]] || fail "design proposal manifest exists"

if [[ -f "$MANIFEST" ]] && yq -e '.' "$MANIFEST" >/dev/null 2>&1; then
  pass "design proposal manifest parses as YAML"
  [[ "$(yq -r '.schema_version' "$MANIFEST")" == "design-proposal-v1" ]] && pass "design proposal schema_version valid" || fail "design proposal schema_version valid"
  case "$(yq -r '.design_class' "$MANIFEST")" in
    domain-runtime|experience-product) pass "design class valid" ;;
    *) fail "design class valid" ;;
  esac
else
  fail "design proposal manifest parses as YAML"
fi

if [[ -f "$PROPOSAL_MANIFEST" ]] && [[ "$(yq -r '.archive.archived_from_status // ""' "$PROPOSAL_MANIFEST" 2>/dev/null)" == "legacy-unknown" ]]; then
  for f in README.md; do
    [[ -f "$PROPOSAL_DIR/$f" ]] && pass "legacy archive required file exists: $f" || fail "legacy archive required file exists: $f"
  done
  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
  exit $?
fi

for f in README.md navigation/artifact-catalog.md navigation/source-of-truth-map.md implementation/README.md implementation/minimal-implementation-blueprint.md implementation/first-implementation-plan.md; do
  [[ -f "$PROPOSAL_DIR/$f" ]] && pass "required file exists: $f" || fail "required file exists: $f"
done

if [[ "$(yq -r '.design_class // ""' "$MANIFEST" 2>/dev/null)" == "domain-runtime" ]]; then
  for f in normative/architecture/domain-model.md normative/architecture/runtime-architecture.md normative/execution/behavior-model.md normative/assurance/implementation-readiness.md; do
    [[ -f "$PROPOSAL_DIR/$f" ]] && pass "domain-runtime file exists: $f" || fail "domain-runtime file exists: $f"
  done
else
  for f in normative/experience/user-journeys.md normative/experience/information-architecture.md normative/experience/screen-states-and-flows.md normative/assurance/implementation-readiness.md; do
    [[ -f "$PROPOSAL_DIR/$f" ]] && pass "experience-product file exists: $f" || fail "experience-product file exists: $f"
  done
fi

while IFS= read -r module; do
  [[ -n "$module" ]] || continue
  case "$module" in
    contracts)
      [[ -f "$PROPOSAL_DIR/contracts/README.md" ]] && pass "contracts module README exists" || fail "contracts module README exists"
      ;;
    conformance)
      [[ -f "$PROPOSAL_DIR/conformance/README.md" ]] && pass "conformance module README exists" || fail "conformance module README exists"
      [[ -d "$PROPOSAL_DIR/conformance/scenarios" ]] && pass "conformance scenarios dir exists" || fail "conformance scenarios dir exists"
      ;;
    reference)
      [[ -f "$PROPOSAL_DIR/reference/README.md" ]] && pass "reference module README exists" || fail "reference module README exists"
      ;;
    history)
      [[ -f "$PROPOSAL_DIR/history/README.md" ]] && pass "history module README exists" || fail "history module README exists"
      ;;
    canonicalization)
      [[ -f "$PROPOSAL_DIR/navigation/canonicalization-target-map.md" ]] && pass "canonicalization target map exists" || fail "canonicalization target map exists"
      ;;
    *)
      fail "unsupported selected_modules entry '$module'"
      ;;
  esac
done < <(yq -r '.selected_modules[]?' "$MANIFEST" 2>/dev/null || true)

echo "Validation summary: errors=$errors"
if [[ $errors -gt 0 ]]; then
  exit 1
fi
