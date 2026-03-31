#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

CHARTER="$OCTON_DIR/framework/constitution/charter.yml"
FAMILY_GLOB="$OCTON_DIR/framework/constitution/contracts"/*/family.yml
PHASE2_RECEIPT=".octon/instance/cognition/context/shared/migrations/2026-03-28-unified-execution-constitution-phase2-objective-authority-cutover/plan.md"
PHASE3_RECEIPT=".octon/instance/cognition/context/shared/migrations/2026-03-29-unified-execution-constitution-phase3-runtime-evidence-normalization/plan.md"
PHASE4_RECEIPT=".octon/instance/cognition/context/shared/migrations/2026-03-29-unified-execution-constitution-phase4-proof-evaluation-lab-expansion/plan.md"
PHASE5_RECEIPT=".octon/instance/cognition/context/shared/migrations/2026-03-29-unified-execution-constitution-phase5-adapter-support-target-hardening/plan.md"

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

require_yq() {
  if command -v yq >/dev/null 2>&1; then
    return 0
  fi
  echo "[ERROR] yq is required" >&2
  exit 1
}

yaml_value() {
  local expr="$1"
  local file="$2"
  yq -r "${expr} // \"\"" "$file"
}

file_contains() {
  local needle="$1"
  local file="$2"
  if command -v rg >/dev/null 2>&1; then
    rg -Fq -- "$needle" "$file"
  else
    grep -Fq -- "$needle" "$file"
  fi
}

ensure_lineage_ref() {
  local family_file="$1"
  local family_id="$2"
  local receipt="$3"

  if yq -e ".activation_lineage_refs[] | select(. == \"$receipt\")" "$family_file" >/dev/null 2>&1; then
    pass "${family_id} preserves historical lineage for ${receipt##*/migrations/}"
  else
    fail "${family_id} is missing historical lineage for ${receipt##*/migrations/}"
  fi
}

main() {
  require_yq

  echo "== Constitutional Family Live-Model Validation =="

  local live_selector live_profile family_file family_id status
  live_selector="$(yaml_value '.live_model.profile_selection_receipt_ref' "$CHARTER")"
  live_profile="$(yaml_value '.live_model.change_profile' "$CHARTER")"

  for family_file in $FAMILY_GLOB; do
    status="$(yaml_value '.status' "$family_file")"
    [[ "$status" == "active" ]] || continue

    family_id="$(yaml_value '.family_id' "$family_file")"

    if [[ "$(yaml_value '.change_profile' "$family_file")" == "$live_profile" ]]; then
      pass "${family_id} uses live change_profile ${live_profile}"
    else
      fail "${family_id} change_profile diverges from charter live profile"
    fi

    if [[ "$(yaml_value '.profile_selection_receipt_ref' "$family_file")" == "$live_selector" ]]; then
      pass "${family_id} uses the charter live selector"
    else
      fail "${family_id} live selector does not match the charter"
    fi

    case "$family_id" in
      objective|authority)
        ensure_lineage_ref "$family_file" "$family_id" "$PHASE2_RECEIPT"
        ;;
      runtime|retention)
        ensure_lineage_ref "$family_file" "$family_id" "$PHASE3_RECEIPT"
        ;;
      assurance)
        ensure_lineage_ref "$family_file" "$family_id" "$PHASE4_RECEIPT"
        ;;
      adapters)
        ensure_lineage_ref "$family_file" "$family_id" "$PHASE5_RECEIPT"
        ;;
    esac
  done

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
