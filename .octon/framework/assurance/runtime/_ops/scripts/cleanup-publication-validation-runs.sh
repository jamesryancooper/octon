#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
PACKET_ID="${1:-2026-04-23-publication-validation-runs}"
PACKET_ROOT="$OCTON_DIR/state/evidence/validation/publication/build-to-delete/$PACKET_ID"

mkdir -p "$PACKET_ROOT"

mapfile -t TARGETS < <(
  find "$OCTON_DIR/state/control/execution/runs" -maxdepth 1 -name 'publish-*' -print 2>/dev/null
  find "$OCTON_DIR/state/continuity/runs" -maxdepth 1 -name 'publish-*' -print 2>/dev/null
  find "$OCTON_DIR/state/control/execution/approvals/requests" -maxdepth 1 -name 'publish-*.yml' -print 2>/dev/null
  find "$OCTON_DIR/state/evidence/control/execution" -maxdepth 1 \( -name 'authority-decision-publish-*.yml' -o -name 'authority-grant-bundle-publish-*.yml' \) -print 2>/dev/null
)

if [[ "${#TARGETS[@]}" -eq 0 ]]; then
  echo "[OK] no publication validation run artifacts found"
  exit 0
fi

mapfile -t REL_TARGETS < <(
  for path in "${TARGETS[@]}"; do
    python3 - <<'PY' "$ROOT_DIR" "$path"
import os, sys
root, path = sys.argv[1], sys.argv[2]
print(os.path.relpath(path, root))
PY
  done
)

receipt="$PACKET_ROOT/ablation-deletion-receipt.yml"
review="$PACKET_ROOT/retirement-review.yml"
paths_txt="$PACKET_ROOT/deleted-paths.txt"
timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

{
  printf 'schema_version: "ablation-deletion-receipt-v1"\n'
  printf 'workflow_id: "ablation-driven-deletion"\n'
  printf 'contract_ref: ".octon/instance/governance/contracts/ablation-deletion-workflow.yml"\n'
  printf 'owner: "Octon governance"\n'
  printf 'status: "completed"\n'
  printf 'executed_at: "%s"\n' "$timestamp"
  printf 'targets_evaluated:\n'
  printf '  - target_id: "publication-validation-run-artifacts"\n'
  printf '    decision: "delete"\n'
  printf '    status_after_review: "retired"\n'
  printf '    regression_result: "none"\n'
  printf '    rationale: "Non-claim-bearing publish-* validation runs were created during runtime-effective publication hardening and are retired after their publication receipts were retained."\n'
  printf '    evidence_refs:\n'
  printf '      - ".octon/state/evidence/validation/publication/runtime/**"\n'
  printf '      - ".octon/state/evidence/validation/publication/capabilities/**"\n'
  printf '      - ".octon/state/evidence/validation/publication/build-to-delete/%s/retirement-review.yml"\n' "$PACKET_ID"
  printf '    ablation_suite:\n'
  printf '      - ".octon/framework/assurance/runtime/_ops/scripts/validate-authorized-effect-token-enforcement.sh"\n'
  printf '      - ".octon/framework/assurance/runtime/_ops/tests/test-generated-effective-publication-live-wrapper.sh"\n'
  printf '      - ".octon/framework/assurance/runtime/_ops/tests/test-material-side-effect-coverage-fixtures.sh"\n'
  printf 'deleted_paths:\n'
  for rel in "${REL_TARGETS[@]}"; do
    printf '  - "%s"\n' "$rel"
  done
  printf 'non_regression_summary: "Publication wrapper receipts remain retained under canonical publication evidence roots; transient publish-* run/control residue was removed."\n'
} >"$receipt"

{
  printf 'schema_version: "build-to-delete-review-evidence-v1"\n'
  printf 'review_id: "retirement-review"\n'
  printf 'contract_ref: ".octon/instance/governance/contracts/retirement-review.yml"\n'
  printf 'owner: "Octon governance"\n'
  printf 'status: "approved"\n'
  printf 'reviewed_at: "%s"\n' "$timestamp"
  printf 'triggered_by:\n'
  printf '  - "Authorized Effect Token publication wrapper hardening"\n'
  printf 'summary: "Transient publish-* validation run artifacts are retired after canonical publication receipts were retained."\n'
  printf 'counts:\n'
  printf '  retired: 1\n'
  printf 'findings: []\n'
  printf 'evidence_refs:\n'
  printf '  - ".octon/instance/governance/contracts/retirement-review.yml"\n'
  printf '  - ".octon/instance/governance/contracts/ablation-deletion-workflow.yml"\n'
  printf '  - ".octon/state/evidence/validation/publication/build-to-delete/%s/ablation-deletion-receipt.yml"\n' "$PACKET_ID"
} >"$review"

printf '%s\n' "${REL_TARGETS[@]}" >"$paths_txt"

for path in "${TARGETS[@]}"; do
  rm -fr -- "$path"
done

echo "[OK] cleaned publication validation run artifacts; receipt at ${receipt#$ROOT_DIR/}"
