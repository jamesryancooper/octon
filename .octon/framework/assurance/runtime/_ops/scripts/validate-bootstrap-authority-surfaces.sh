#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

START_DOC="$OCTON_DIR/instance/bootstrap/START.md"
README_DOC="$OCTON_DIR/README.md"
INGRESS_DOC="$OCTON_DIR/instance/ingress/AGENTS.md"

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
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

require_text() {
  local needle="$1"
  local file="$2"
  local label="$3"
  if file_contains "$needle" "$file"; then
    pass "$label"
  else
    fail "$label"
  fi
}

check_list_block_has_no_inputs() {
  local file="$1"
  local anchor="$2"
  local label="$3"

  if ! file_contains "$anchor" "$file"; then
    fail "${label} anchor exists"
    return
  fi

  if awk -v anchor="$anchor" '
    $0 == anchor { in_block=1; next }
    in_block && !started && /^[[:space:]]*$/ { next }
    in_block && /^[[:space:]]*-/ {
      started=1
      if ($0 ~ /inputs\//) {
        exit 1
      }
      next
    }
    in_block && started && /^[[:space:]]*$/ { exit 0 }
    in_block && started { exit 0 }
    { next }
  ' "$file"; then
    pass "$label"
  else
    fail "$label"
  fi
}

main() {
  echo "== Bootstrap Authority Surface Validation =="

  check_list_block_has_no_inputs "$START_DOC" "Instance-native repo authority lives at:" "bootstrap authored-authority list excludes raw inputs"
  check_list_block_has_no_inputs "$README_DOC" "### Instance-Native Surfaces" "README instance-native list excludes raw inputs"

  require_text "Only \`framework/**\` and \`instance/**\` are authored authority surfaces." "$INGRESS_DOC" "ingress keeps authored authority bounded to framework and instance"
  require_text "raw pack input: \`inputs/additive/extensions/<pack-id>/**\`" "$START_DOC" "bootstrap documents raw additive pack input separately"
  require_text "desired trust activation: \`instance/extensions.yml\`" "$START_DOC" "bootstrap documents additive trust activation"
  require_text "actual active state: \`state/control/extensions/active.yml\`" "$START_DOC" "bootstrap documents additive actual state"
  require_text "quarantine state: \`state/control/extensions/quarantine.yml\`" "$START_DOC" "bootstrap documents additive quarantine state"
  require_text "compiled runtime-facing outputs: \`generated/effective/extensions/**\`" "$START_DOC" "bootstrap documents additive compiled outputs"

  echo "Validation summary: errors=$errors"
  [[ $errors -eq 0 ]]
}

main "$@"
