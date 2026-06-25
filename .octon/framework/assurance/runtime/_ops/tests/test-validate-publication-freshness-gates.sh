#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
RESULT_FILE="$(mktemp "${TMPDIR:-/tmp}/octon-validator-result.XXXXXX")"
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/octon-publication-freshness.XXXXXX")"
trap 'rm -f "$RESULT_FILE"; rm -rf "$TMP_ROOT"' EXIT

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

fixture_scripts="$TMP_ROOT/.octon/framework/assurance/runtime/_ops/scripts"
fixture_spec="$TMP_ROOT/.octon/framework/engine/runtime/spec"
fixture_receipt_dir="$TMP_ROOT/.octon/state/evidence/validation/architecture/10of10-target-transition/publication"
mkdir -p "$fixture_scripts" "$fixture_spec" "$fixture_receipt_dir"
cp "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-publication-freshness-gates.sh" "$fixture_scripts/validate-publication-freshness-gates.sh"
cp "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validator-result-common.sh" "$fixture_scripts/validator-result-common.sh"
cat > "$fixture_spec/publication-freshness-gates-v4.md" <<'EOF'
# Publication freshness fixture
EOF
cat > "$fixture_receipt_dir/freshness.yml" <<'EOF'
schema_version: generated-effective-freshness-receipt-v2
generated_effective_outputs:
  - output_ref: ".octon/generated/effective/extensions/catalog.effective.yml"
    evidence_ref: ".octon/state/evidence/validation/publication/extensions/fixture.yml"
    freshness_refs: ["fixture"]
  - output_ref: ".octon/generated/effective/capabilities/routing.effective.yml"
    evidence_ref: ".octon/state/evidence/validation/publication/capabilities/fixture.yml"
    freshness_refs: ["fixture"]
  - output_ref: ".octon/generated/effective/capabilities/pack-routes.effective.yml"
    evidence_ref: ".octon/state/evidence/validation/publication/capabilities/pack-routes-fixture.yml"
    freshness_refs: ["fixture"]
  - output_ref: ".octon/generated/effective/runtime/route-bundle.yml"
    evidence_ref: ".octon/state/evidence/validation/publication/runtime/fixture.yml"
    freshness_refs: ["fixture"]
EOF

for script in \
  validate-generated-effective-freshness.sh \
  validate-runtime-effective-artifact-handles.sh \
  validate-no-raw-generated-effective-runtime-reads.sh \
  validate-capability-publication-state.sh \
  validate-extension-publication-state.sh \
  validate-runtime-effective-route-bundle.sh \
  validate-host-projections.sh
do
  cat > "$fixture_scripts/$script" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
  chmod +x "$fixture_scripts/$script"
done
cat > "$fixture_scripts/validate-run-health-read-model.sh" <<'EOF'
#!/usr/bin/env bash
echo "run-health digest drift" >&2
exit 9
EOF
chmod +x "$fixture_scripts/validate-run-health-read-model.sh"

set +e
fixture_output="$(OCTON_DIR_OVERRIDE="$TMP_ROOT/.octon" OCTON_ROOT_DIR="$TMP_ROOT" bash "$fixture_scripts/validate-publication-freshness-gates.sh" 2>&1)"
fixture_status=$?
set -e
if [[ "$fixture_status" -eq 0 ]]; then
  echo "expected publication freshness gate to fail when run-health read model is stale" >&2
  exit 1
fi
if [[ "$fixture_output" != *"validate-run-health-read-model.sh failed"* ]]; then
  echo "expected publication freshness gate to report run-health validator failure" >&2
  echo "$fixture_output" >&2
  exit 1
fi
