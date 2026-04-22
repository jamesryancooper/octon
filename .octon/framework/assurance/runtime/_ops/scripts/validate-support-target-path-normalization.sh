#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
SUPPORT_TARGETS="$OCTON_DIR/instance/governance/support-targets.yml"

errors=0
fail(){ echo "[ERROR] $1"; errors=$((errors+1)); }
pass(){ echo "[OK] $1"; }

echo "== Support Target Path Normalization Validation =="

for rel in \
  ".octon/instance/governance/support-target-admissions/live" \
  ".octon/instance/governance/support-target-admissions/stage-only" \
  ".octon/instance/governance/support-target-admissions/unadmitted" \
  ".octon/instance/governance/support-target-admissions/retired" \
  ".octon/instance/governance/support-dossiers/live" \
  ".octon/instance/governance/support-dossiers/stage-only" \
  ".octon/instance/governance/support-dossiers/unadmitted" \
  ".octon/instance/governance/support-dossiers/retired"
do
  [[ -d "$ROOT_DIR/$rel" ]] && pass "partition root present: $rel" || fail "missing partition root: $rel"
done

flat_admissions="$(find "$OCTON_DIR/instance/governance/support-target-admissions" -maxdepth 1 -type f -name '*.yml' -print)"
[[ -z "$flat_admissions" ]] && pass "no flat support admission files remain canonical" || fail "flat support admission files must not remain canonical"
flat_dossiers="$(find "$OCTON_DIR/instance/governance/support-dossiers" -maxdepth 1 -type f -name '*.yml' -print)"
[[ -z "$flat_dossiers" ]] && pass "no flat support dossier files remain canonical" || fail "flat support dossier files must not remain canonical"

while IFS=$'\t' read -r tuple_id claim_effect admission_ref dossier_ref; do
  [[ -n "$tuple_id" ]] || continue
  case "$claim_effect" in
    admitted-live-claim)
      [[ "$admission_ref" == .octon/instance/governance/support-target-admissions/live/* ]] && pass "$tuple_id admission ref normalized to live partition" || fail "$tuple_id live admission ref drift"
      [[ "$dossier_ref" == .octon/instance/governance/support-dossiers/live/* ]] && pass "$tuple_id dossier ref normalized to live partition" || fail "$tuple_id live dossier ref drift"
      ;;
    stage-only-non-live)
      [[ "$admission_ref" == .octon/instance/governance/support-target-admissions/stage-only/* ]] && pass "$tuple_id admission ref normalized to stage-only partition" || fail "$tuple_id stage-only admission ref drift"
      [[ "$dossier_ref" == .octon/instance/governance/support-dossiers/stage-only/* ]] && pass "$tuple_id dossier ref normalized to stage-only partition" || fail "$tuple_id stage-only dossier ref drift"
      ;;
    *)
      fail "$tuple_id has unsupported claim effect: $claim_effect"
      ;;
  esac
done < <(yq -r '.tuple_admissions[] | [.tuple_id, .claim_effect, .admission_ref, .support_dossier_ref] | @tsv' "$SUPPORT_TARGETS")

echo "Validation summary: errors=$errors"
[[ $errors -eq 0 ]]
