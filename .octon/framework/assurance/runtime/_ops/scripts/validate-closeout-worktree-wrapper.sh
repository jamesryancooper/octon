#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
REPORT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --report) shift; REPORT="${1:-}" ;;
    -h|--help) echo "Usage: validate-closeout-worktree-wrapper.sh [--report <yaml>]"; exit 0 ;;
    *) echo "[ERROR] unknown argument: $1" >&2; exit 2 ;;
  esac
  shift
done

POLICY="$OCTON_DIR/framework/product/contracts/default-work-unit.yml"
WRAPPER="$OCTON_DIR/framework/capabilities/runtime/skills/remediation/closeout-worktree/SKILL.md"
REGISTRY="$OCTON_DIR/framework/capabilities/runtime/skills/registry.yml"

yq -e '.worktree_wrapper.id == "closeout-worktree" and .worktree_wrapper.default_work_unit_replacement == false' "$POLICY" >/dev/null
yq -e '.routine_closeout_autonomy.generic_closeout_target == "preserved"' "$POLICY" >/dev/null
yq -e '.skills."closeout-worktree".parameters[] | select(.name == "target_lifecycle_outcome" and (.description | test("default to preserved")))' "$REGISTRY" >/dev/null
grep -Fq 'RP00_CONTAINMENT_PUBLICATION_DISABLED' "$WRAPPER"
grep -Fq 'RP00_CONTAINMENT_CLEANUP_DISABLED' "$WRAPPER"
grep -Fq 'repo_hygiene_cleanup_actions_performed' "$WRAPPER"
grep -Fq 'repo_hygiene_cleanup_ref' "$WRAPPER"
if grep -Eq 'target_lifecycle_outcome:[[:space:]]*cleaned|default(s|ed)? to `?cleaned`?' "$WRAPPER"; then
  echo "[ERROR] closeout-worktree still defaults current SI-00 work to cleaned" >&2
  exit 1
fi

if [[ -n "$REPORT" ]]; then
  yq -e . "$REPORT" >/dev/null
  if yq -e '.. | select(tag == "!!str") | select(. == "direct-main" or . == "cleaned" or . == "synced")' "$REPORT" >/dev/null 2>&1; then
    echo "[ERROR] worktree report contains a forbidden SI-00 route/outcome" >&2
    exit 1
  fi
  if [[ "$(yq -r '.repo_hygiene_cleanup_actions_performed // false' "$REPORT")" != "false" ]]; then
    echo "[ERROR] closeout-worktree report claims wrapper cleanup authority" >&2
    exit 1
  fi
  cleanup_ref="$(yq -r '.repo_hygiene_cleanup_ref // "none"' "$REPORT")"
  if [[ -n "$cleanup_ref" && "$cleanup_ref" != "none" ]]; then
    case "$cleanup_ref" in
      .octon/state/evidence/runs/skills/repo-hygiene-cleanup/*)
        [[ -f "$OCTON_DIR/../$cleanup_ref" ]] || {
          echo "[ERROR] delegated repo-hygiene cleanup evidence does not resolve" >&2
          exit 1
        }
        ;;
      *)
        echo "[ERROR] delegated repo-hygiene cleanup evidence is outside its owning receipt root" >&2
        exit 1
        ;;
    esac
  fi
fi

echo "[OK] closeout-worktree is preservation-only during SI-00"
