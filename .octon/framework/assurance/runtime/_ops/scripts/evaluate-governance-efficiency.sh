#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_ROOT="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
ROOT_DIR="${OCTON_ROOT_DIR:-$DEFAULT_ROOT}"
COLLECTOR="$SCRIPT_DIR/collect-governance-efficiency-evidence.sh"
VALIDATOR="$SCRIPT_DIR/validate-governance-efficiency-report.sh"
TARGET=""
COLLECTED=""
OUTPUT=""

usage() {
  cat <<'USAGE'
usage:
  evaluate-governance-efficiency.sh --target <path> [--collected-evidence <path>] [--output <path>]

Emit an advisory-only governance efficiency report from retained evidence.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      TARGET="$1"
      ;;
    --collected-evidence)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      COLLECTED="$1"
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
  TARGET_REL="${TARGET#$ROOT_DIR/}"
else
  TARGET_REL="$TARGET"
fi

evidence_tmp=""
if [[ -n "$COLLECTED" ]]; then
  evidence_tmp="$COLLECTED"
else
  evidence_tmp="$(mktemp "${TMPDIR:-/tmp}/governance-efficiency-collected.XXXXXX")"
  bash "$COLLECTOR" --target "$TARGET" --output "$evidence_tmp"
fi

target_kind="$(yq -r '.target.target_kind // "mixed"' "$evidence_tmp" 2>/dev/null || echo mixed)"
present_count="$(yq -r '.summary.evidence_items_present // 0' "$evidence_tmp" 2>/dev/null || echo 0)"
missing_count="$(yq -r '.summary.evidence_items_missing // 0' "$evidence_tmp" 2>/dev/null || echo 0)"
child_count="$(yq -r '.summary.child_count // 0' "$evidence_tmp" 2>/dev/null || echo 0)"
terminal_child_count="$(yq -r '.summary.terminal_child_count // 0' "$evidence_tmp" 2>/dev/null || echo 0)"
confidence="medium"
if [[ "$missing_count" =~ ^[1-9][0-9]*$ ]]; then
  confidence="low"
elif [[ "$present_count" =~ ^[1-9][0-9]*$ ]]; then
  confidence="high"
fi

first_ref="$(yq -r '.evidence_items[0].ref // "'"$TARGET_REL"'"' "$evidence_tmp" 2>/dev/null || echo "$TARGET_REL")"
report_tmp="$(mktemp "${TMPDIR:-/tmp}/governance-efficiency-report.XXXXXX")"
{
  printf 'schema_version: "octon-governance-efficiency-report-v1"\n'
  printf 'artifact_role: "governance-efficiency-report"\n'
  printf 'report_id: "governance-efficiency-report@%s"\n' "$(date -u +%Y%m%dT%H%M%SZ)"
  printf 'generated_at: "%s"\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  printf 'non_authority_classification: "advisory-only"\n'
  printf 'producer:\n'
  printf '  id: "evaluate-governance-efficiency"\n'
  printf '  entrypoint_ref: ".octon/framework/assurance/runtime/_ops/scripts/evaluate-governance-efficiency.sh"\n'
  printf '  owner: "assurance/runtime"\n'
  printf 'consumer:\n'
  printf '  allowed_consumers:\n'
  printf '    - "operator-analysis"\n'
  printf '    - "future-proposal-input"\n'
  printf '  forbidden_consumers:\n'
  printf '    - "review-authorization"\n'
  printf '    - "validation-gate"\n'
  printf '    - "closeout"\n'
  printf '    - "cleanup"\n'
  printf '    - "archive"\n'
  printf '    - "terminal-proof"\n'
  printf '    - "policy-mutation"\n'
  printf '    - "lifecycle-transition"\n'
  printf '    - "child-receipt-substitution"\n'
  printf 'target:\n'
  printf '  path: "%s"\n' "$TARGET_REL"
  printf '  target_kind: "%s"\n' "$target_kind"
  printf 'authority_boundaries:\n'
  printf '  authorizes_review: false\n'
  printf '  authorizes_validation: false\n'
  printf '  authorizes_closeout: false\n'
  printf '  authorizes_cleanup: false\n'
  printf '  authorizes_archive: false\n'
  printf '  authorizes_terminal_proof: false\n'
  printf '  authorizes_policy_mutation: false\n'
  printf '  authorizes_lifecycle_transition: false\n'
  printf '  replaces_child_receipts: false\n'
  printf 'evidence_inputs:\n'
  yq -r '.evidence_items[]? | "  - ref: \"" + .ref + "\"\n    observed: " + (.observed | tostring) + "\n    evidence_class: \"" + .evidence_class + "\""' "$evidence_tmp"
  printf 'findings:\n'
  printf '  - finding_id: "GE-001"\n'
  printf '    category: "latency"\n'
  printf '    risk_covered: "Lifecycle gates retain child-owned evidence and explicit uncertainty."\n'
  printf '    latency_cost: "observed_support_receipts=%s missing_support_receipts=%s"\n' "$present_count" "$missing_count"
  printf '    evidence_refs:\n'
  printf '      - "%s"\n' "$first_ref"
  printf '    confidence: "%s"\n' "$confidence"
  printf '    recommendation: "Use retained evidence observations to draft a future proposal for any process change; do not change gates from this report."\n'
  printf '    recommendation_authority: "advisory-only"\n'
  printf '    requires_follow_up_proposal: true\n'
  if [[ "$child_count" =~ ^[1-9][0-9]*$ ]]; then
    printf '  - finding_id: "GE-002"\n'
    printf '    category: "batching"\n'
    printf '    risk_covered: "Program children remain independently terminal before parent closeout."\n'
    printf '    latency_cost: "terminal_children=%s total_children=%s"\n' "$terminal_child_count" "$child_count"
    printf '    evidence_refs:\n'
    printf '      - "%s/resources/child-packet-index.yml"\n' "$TARGET_REL"
    printf '    confidence: "%s"\n' "$confidence"
    printf '    recommendation: "Batch only advisory analysis of repeated gates; preserve child-owned lifecycle gates."\n'
    printf '    recommendation_authority: "advisory-only"\n'
    printf '    requires_follow_up_proposal: true\n'
  fi
  printf 'uncertainty:\n'
  printf '  missing_evidence_count: %s\n' "$missing_count"
  printf '  partial_evidence_count: 0\n'
  printf '  notes:\n'
  if [[ "$missing_count" =~ ^[1-9][0-9]*$ ]]; then
    printf '    - "Missing evidence lowers confidence and blocks authoritative recommendations."\n'
  else
    printf '    - "Observed evidence supports advisory analysis only."\n'
  fi
  printf 'validation:\n'
  printf '  validators_run:\n'
  printf '    - ".octon/framework/assurance/runtime/_ops/scripts/validate-governance-efficiency-report.sh"\n'
  printf '  negative_controls:\n'
  printf '    - "review-authorization"\n'
  printf '    - "validation-gate"\n'
  printf '    - "closeout"\n'
  printf '    - "cleanup"\n'
  printf '    - "archive"\n'
  printf '    - "terminal-proof"\n'
  printf '    - "policy-mutation"\n'
  printf '    - "lifecycle-transition"\n'
  printf '    - "child-receipt-substitution"\n'
} >"$report_tmp"

OCTON_ROOT_DIR="$DEFAULT_ROOT" bash "$VALIDATOR" --report "$report_tmp" >/dev/null
if [[ -n "$OUTPUT" ]]; then
  cp "$report_tmp" "$OUTPUT"
else
  cat "$report_tmp"
fi

rm -f "$report_tmp"
if [[ -z "$COLLECTED" ]]; then
  rm -f "$evidence_tmp"
fi
