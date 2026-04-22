#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

MANIFEST="$OCTON_DIR/instance/ingress/manifest.yml"
INGRESS="$OCTON_DIR/instance/ingress/AGENTS.md"
START="$OCTON_DIR/instance/bootstrap/START.md"

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

require_literal() {
  local file="$1"
  local needle="$2"
  local ok_msg="$3"
  local fail_msg="$4"
  if grep -Fq -- "$needle" "$file"; then
    pass "$ok_msg"
  else
    fail "$fail_msg"
  fi
}

main() {
  echo "== Operator Boot Surface Validation =="

  [[ -f "$MANIFEST" ]] && pass "ingress manifest exists" || fail "missing ingress manifest"
  [[ -f "$INGRESS" ]] && pass "ingress AGENTS exists" || fail "missing ingress AGENTS"
  [[ -f "$START" ]] && pass "bootstrap START exists" || fail "missing bootstrap START"

  yq -e '.schema_version == "ingress-manifest-v2"' "$MANIFEST" >/dev/null 2>&1 \
    && pass "ingress manifest schema is current" \
    || fail "ingress manifest schema must be ingress-manifest-v2"
  yq -e '.mandatory_reads | length > 0' "$MANIFEST" >/dev/null 2>&1 \
    && pass "ingress manifest carries mandatory reads" \
    || fail "ingress manifest must carry mandatory reads"
  yq -e '.optional_orientation | length > 0' "$MANIFEST" >/dev/null 2>&1 \
    && pass "ingress manifest carries optional orientation" \
    || fail "ingress manifest must carry optional orientation"
  yq -e '.adapter_parity_targets | length > 0' "$MANIFEST" >/dev/null 2>&1 \
    && pass "ingress manifest carries adapter parity targets" \
    || fail "ingress manifest must carry adapter parity targets"

  if yq -e 'has("branch_closeout_gate") | not and has("branch_closeout_prompt") | not' "$MANIFEST" >/dev/null 2>&1; then
    pass "ingress manifest is boot-only and free of inline closeout policy"
  else
    fail "ingress manifest must not carry inline branch/PR closeout policy"
  fi

  closeout_workflow_ref="$(yq -r '.closeout_workflow_ref // ""' "$MANIFEST")"
  if [[ -n "$closeout_workflow_ref" && -f "$ROOT_DIR/$closeout_workflow_ref" ]]; then
    pass "closeout workflow reference resolves"
  else
    fail "closeout workflow reference missing or unresolved"
  fi

  require_literal \
    "$INGRESS" \
    "Ingress does not own branch or PR closeout policy." \
    "ingress AGENTS keeps closeout out of ingress" \
    "ingress AGENTS must explicitly keep closeout out of ingress"
  require_literal \
    "$INGRESS" \
    "Build-to-delete or claim-closeout governance remains distinct" \
    "ingress AGENTS distinguishes branch/PR closeout from governance closeout" \
    "ingress AGENTS must distinguish branch/PR closeout from governance closeout"
  require_literal \
    "$START" \
    "octon doctor --architecture" \
    "bootstrap START includes architecture doctor path" \
    "bootstrap START must include architecture doctor path"
  require_literal \
    "$START" \
    "octon run start --contract <path>" \
    "bootstrap START includes first-run lifecycle path" \
    "bootstrap START must include first-run lifecycle path"

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
