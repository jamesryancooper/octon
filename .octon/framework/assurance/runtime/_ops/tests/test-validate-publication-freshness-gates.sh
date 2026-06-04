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

yq -e 'select(.validator_id == "validate-publication-freshness-gates.sh") | .manifest_schema_version == "octon-validator-result-manifest-v1"' "$RESULT_FILE" >/dev/null
yq -e 'select(.validator_id == "validate-publication-freshness-gates.sh") | .source_digests[] | select(.ref == ".octon/state/evidence/validation/architecture/10of10-target-transition/publication/freshness.yml" and .status == "present" and (.sha256 | test("^sha256:[0-9a-f]{64}$")))' "$RESULT_FILE" >/dev/null
yq -e 'select(.validator_id == "validate-publication-freshness-gates.sh") | .consumer.forbidden_consumers[] | select(. == "runtime")' "$RESULT_FILE" >/dev/null
yq -e 'select(.validator_id == "validate-publication-freshness-gates.sh") | .failure_behavior.fail_closed_on[] | select(. == "stale-freshness")' "$RESULT_FILE" >/dev/null
