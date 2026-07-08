#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_ROOT="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
ROOT_DIR="${OCTON_ROOT_DIR:-$DEFAULT_ROOT}"
TARGET=""
OUTPUT=""

usage() {
  cat <<'USAGE'
usage:
  collect-governance-efficiency-evidence.sh --target <path> [--output <path>]

Collect retained proposal lifecycle evidence by reading the target tree. Output
is advisory input only and does not authorize lifecycle transitions.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      TARGET="$1"
      ;;
    --output)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      OUTPUT="$1"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
  shift
done

[[ -n "$TARGET" ]] || { usage >&2; exit 2; }

if [[ "$TARGET" = /* ]]; then
  TARGET_ABS="$TARGET"
  TARGET_REL="${TARGET#$ROOT_DIR/}"
else
  TARGET_ABS="$ROOT_DIR/$TARGET"
  TARGET_REL="$TARGET"
fi

target_kind="mixed"
if [[ -f "$TARGET_ABS/resources/child-packet-index.yml" ]]; then
  target_kind="proposal-program"
elif [[ -f "$TARGET_ABS/proposal.yml" ]]; then
  target_kind="proposal-packet"
fi

status=""
proposal_id=""
if [[ -f "$TARGET_ABS/proposal.yml" ]]; then
  status="$(yq -r '.status // ""' "$TARGET_ABS/proposal.yml" 2>/dev/null || true)"
  proposal_id="$(yq -r '.proposal_id // ""' "$TARGET_ABS/proposal.yml" 2>/dev/null || true)"
fi

receipt_specs="
proposal-review|proposal-review|support/proposal-review.md
implementation-run|implementation-run|support/implementation-run.md
implementation-conformance|implementation-conformance|support/implementation-conformance-review.md
post-implementation-drift|post-implementation-drift|support/post-implementation-drift-churn-review.md
validation|validation|support/validation.md
closeout|closeout|support/proposal-closeout.md
terminal-proof|terminal-proof|support/proposal-terminal-closeout.yml
"

tmp="$(mktemp "${TMPDIR:-/tmp}/governance-efficiency-evidence.XXXXXX")"
{
  printf 'schema_version: "octon-governance-efficiency-evidence-v1"\n'
  printf 'artifact_role: "governance-efficiency-evidence-input"\n'
  printf 'generated_at: "%s"\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  printf 'non_authority_classification: "advisory-input-only"\n'
  printf 'target:\n'
  printf '  path: "%s"\n' "$TARGET_REL"
  printf '  target_kind: "%s"\n' "$target_kind"
  printf '  proposal_id: "%s"\n' "$proposal_id"
  printf '  status: "%s"\n' "$status"
  printf 'authority_boundaries:\n'
  printf '  mutates_repo: false\n'
  printf '  authorizes_lifecycle_transition: false\n'
  printf '  replaces_child_receipts: false\n'
  printf 'evidence_items:\n'

  present_count=0
  missing_count=0
  while IFS='|' read -r item_id item_class item_path; do
    [[ -n "$item_id" ]] || continue
    ref="$TARGET_REL/$item_path"
    if [[ -f "$TARGET_ABS/$item_path" ]]; then
      observed=true
      present_count=$((present_count + 1))
    else
      observed=false
      missing_count=$((missing_count + 1))
    fi
    printf '  - item_id: "%s"\n' "$item_id"
    printf '    ref: "%s"\n' "$ref"
    printf '    observed: %s\n' "$observed"
    printf '    evidence_class: "%s"\n' "$item_class"
  done <<<"$receipt_specs"

  child_count=0
  terminal_child_count=0
  if [[ -f "$TARGET_ABS/resources/child-packet-index.yml" ]]; then
    child_count="$(yq -r '(.children // []) | length' "$TARGET_ABS/resources/child-packet-index.yml" 2>/dev/null || echo 0)"
    for ((index=0; index<child_count; index++)); do
      child_path="$(yq -r ".children[$index].path // \"\"" "$TARGET_ABS/resources/child-packet-index.yml" 2>/dev/null || true)"
      [[ -n "$child_path" ]] || continue
      child_abs="$ROOT_DIR/$child_path"
      child_archive_abs=""
      if [[ "$child_path" == .octon/inputs/exploratory/proposals/*/* ]]; then
        suffix="${child_path#.octon/inputs/exploratory/proposals/}"
        child_archive_abs="$ROOT_DIR/.octon/inputs/exploratory/proposals/.archive/$suffix"
      fi
      child_status=""
      if [[ -f "$child_abs/proposal.yml" ]]; then
        child_status="$(yq -r '.status // ""' "$child_abs/proposal.yml" 2>/dev/null || true)"
      elif [[ -n "$child_archive_abs" && -f "$child_archive_abs/proposal.yml" ]]; then
        child_status="$(yq -r '.status // ""' "$child_archive_abs/proposal.yml" 2>/dev/null || true)"
      fi
      if [[ "$child_status" == "implemented" || "$child_status" == "archived" ]]; then
        terminal_child_count=$((terminal_child_count + 1))
      fi
    done
  fi

  printf 'summary:\n'
  printf '  evidence_items_present: %s\n' "$present_count"
  printf '  evidence_items_missing: %s\n' "$missing_count"
  printf '  child_count: %s\n' "$child_count"
  printf '  terminal_child_count: %s\n' "$terminal_child_count"
} >"$tmp"

if [[ -n "$OUTPUT" ]]; then
  cp "$tmp" "$OUTPUT"
else
  cat "$tmp"
fi
rm -f "$tmp"
