#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
EVALUATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/evaluate-governance-efficiency.sh"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-governance-efficiency-report.sh"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/governance-efficiency-evaluator-test.XXXXXX")"
trap 'rm -rf "$TMP_DIR"' EXIT

target="$TMP_DIR/proposal-example"
mkdir -p "$target/support"
cat >"$target/proposal.yml" <<'YAML'
schema_version: proposal-v1
proposal_id: proposal-example
status: accepted
proposal_kind: architecture
YAML
printf 'verdict: accepted\n' >"$target/support/proposal-review.md"

report="$TMP_DIR/report.yml"
OCTON_ROOT_DIR="$TMP_DIR" bash "$EVALUATOR" --target proposal-example --output "$report"
bash "$VALIDATOR" --report "$report" >/dev/null

[[ "$(yq -r '.non_authority_classification' "$report")" == "advisory-only" ]] || { echo "[ERROR] report is not advisory-only"; exit 1; }
[[ "$(yq -r '.authority_boundaries.authorizes_lifecycle_transition' "$report")" == "false" ]] || { echo "[ERROR] report authorizes lifecycle transition"; exit 1; }
if yq -e '.findings[]? | select(.confidence == "high")' "$report" >/dev/null 2>&1; then
  echo "[ERROR] missing evidence produced high confidence"
  exit 1
fi

echo "test-evaluate-governance-efficiency: pass"
