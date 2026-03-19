#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

main() {
  echo "== Framework Core Boundary Validation =="

  local unexpected_octon_entries=()
  local entry rel
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
    pass "top-level .octon remains restricted to the five-class topology"
  fi

  local unexpected_framework_entries=()
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
    pass "framework top-level entries remain inside the Packet 3 bundle boundary"
  fi

  local state_hits
  state_hits="$(find "$OCTON_DIR/framework" -path '*/_ops/state*' -print || true)"
  if [[ -n "$state_hits" ]]; then
    fail "framework/**/_ops/state/** is forbidden after Packet 3"
    printf '%s\n' "$state_hits" | sed "s|$ROOT_DIR/||"
  else
    pass "no framework-local _ops/state paths remain"
  fi

  if command -v git >/dev/null 2>&1; then
    local tracked_legacy
    tracked_legacy="$(git -C "$ROOT_DIR" ls-files '.octon/framework/**/_ops/state/**' 2>/dev/null || true)"
    if [[ -n "$tracked_legacy" ]]; then
      fail "tracked legacy framework _ops/state paths remain in the git index"
      printf '%s\n' "$tracked_legacy"
    else
      pass "legacy framework _ops/state paths are removed from the git index"
    fi
  fi

  local legacy_refs
  legacy_refs="$(
    (
      cd "$ROOT_DIR"
      rg -n --hidden --no-heading \
        --glob '!**/target/**' \
        --glob '!**/node_modules/**' \
        --glob '!**/.git/**' \
        --glob '!.octon/generated/**' \
        --glob '!.octon/state/evidence/**' \
        --glob '!.octon/inputs/exploratory/ideation/**' \
        --glob '!.octon/inputs/exploratory/packages/**' \
        --glob '!.octon/inputs/exploratory/proposals/.archive/**' \
        --glob '!.octon/instance/cognition/decisions/**' \
        --glob '!.octon/instance/cognition/context/shared/migrations/**' \
        --glob '!.octon/framework/cognition/practices/methodology/migrations/legacy-banlist.md' \
        --glob '!.octon/framework/cognition/_meta/architecture/bounded-surfaces-contract.md' \
        --glob '!.octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh' \
        --glob '!.octon/framework/assurance/runtime/_ops/scripts/validate-framework-core-boundary.sh' \
        'framework/capabilities/_ops/state|framework/engine/_ops/state|runtime/skills/_ops/state|runtime/services/_ops/state|assurance/runtime/_ops/state|\.octon/engine/|framework/continuity/|\.octon/continuity|\.octon/ideation' \
        .octon \
        .github \
        .gitignore 2>/dev/null || true
    )
  )"

  if [[ -n "$legacy_refs" ]]; then
    fail "live legacy framework-state references remain"
    printf '%s\n' "$legacy_refs"
  else
    pass "no live legacy framework-state references remain"
  fi

  local output_refs
  output_refs="$(
    (
      cd "$ROOT_DIR"
      rg -n --hidden --no-heading \
        --glob '!**/target/**' \
        --glob '!**/node_modules/**' \
        --glob '!**/.git/**' \
        --glob '!.octon/inputs/exploratory/proposals/.archive/**' \
        --glob '!.octon/framework/assurance/runtime/_ops/scripts/validate-framework-core-boundary.sh' \
        --glob '!.octon/framework/assurance/runtime/_ops/scripts/validate-harness-structure.sh' \
        'OCTON_DIR/output|\.octon/output|\*\*/output/\*\*|generated/output/README\.md|\.\./output/assurance/|\.\./\.\./output/|\.\./\.\./\.\./output/' \
        .octon/framework \
        .octon/inputs/exploratory/plans \
        .octon/inputs/exploratory/proposals \
        .octon/instance/cognition/context/shared/migrations \
        .github 2>/dev/null || true
    )
  )"

  if [[ -n "$output_refs" ]]; then
    fail "live control-plane references still target the retired output root"
    printf '%s\n' "$output_refs"
  else
    pass "no live control-plane references target the retired output root"
  fi

  if [[ "$errors" -gt 0 ]]; then
    echo "Validation summary: errors=$errors"
    exit 1
  fi

  echo "Validation summary: errors=0"
}

main "$@"
