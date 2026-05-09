#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
RESULT_FILE="$(mktemp "${TMPDIR:-/tmp}/octon-validator-result.XXXXXX")"
trap 'rm -f "$RESULT_FILE"' EXIT

bash "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-publication-freshness-gates.sh" >/dev/null
OCTON_VALIDATOR_RESULT_FILE="$RESULT_FILE" bash "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-publication-freshness-gates.sh" >/dev/null
OCTON_VALIDATOR_RESULT_FILE="$RESULT_FILE" bash "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-runtime-effective-route-bundle.sh" >/dev/null

executed_count="$(yq -r 'select(.validator_id == "validate-publication-freshness-gates.sh" or .validator_id == "validate-runtime-effective-route-bundle.sh") | (.negative_controls_executed // []) | length' "$RESULT_FILE" | awk '{sum += $1} END {print sum + 0}')"
recognized_count="$(yq -r 'select(.validator_id == "validate-publication-freshness-gates.sh" or .validator_id == "validate-runtime-effective-route-bundle.sh") | (.negative_controls_recognized // []) | length' "$RESULT_FILE" | awk '{sum += $1} END {print sum + 0}')"

if [[ "$executed_count" != "0" ]]; then
  echo "expected publication validators not to claim inline negative controls were executed" >&2
  exit 1
fi
if [[ "$recognized_count" -le 0 ]]; then
  echo "expected publication validators to record recognized negative controls" >&2
  exit 1
fi
