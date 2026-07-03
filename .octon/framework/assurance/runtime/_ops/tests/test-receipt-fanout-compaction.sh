#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
COMMON="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/generator-idempotency-common.sh"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-receipt-fanout-compaction.sh"
SCHEMA="$ROOT_DIR/.octon/framework/product/contracts/receipt-fanout-compaction-v1.schema.json"

source "$COMMON"

pass_count=0
fail_count=0
cleanup_paths=()

cleanup() {
  local path
  for path in "${cleanup_paths[@]}"; do
    [[ -n "$path" && -e "$path" ]] && rm -rf -- "$path"
  done
}
trap cleanup EXIT

pass() { echo "PASS: $1"; pass_count=$((pass_count + 1)); }
fail() { echo "FAIL: $1" >&2; fail_count=$((fail_count + 1)); }

assert_success() {
  local label="$1"
  shift
  if "$@"; then pass "$label"; else fail "$label"; fi
}

write_fixture_receipt() {
  local path="$1" receipt_id="$2" validated_at="$3"
  mkdir -p "$(dirname "$path")"
  cat >"$path" <<EOF
schema_version: "octon-validation-publication-receipt-v1"
receipt_id: "$receipt_id"
publication_family: "runtime-pack-routes"
generation_id: "pack-routes-fixture"
result: "published"
validated_at: "$validated_at"
validator_version: "receipt-fanout-test-v1"
source_digests:
  root_manifest_sha256: "sha256:aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
blocked_reasons: []
published_paths:
  - ".octon/generated/effective/capabilities/pack-routes.effective.yml"
required_inputs:
  - ".octon/octon.yml"
EOF
}

prepare_fixture_schema() {
  local fixture_root="$1"
  mkdir -p "$fixture_root/.octon/framework/product/contracts"
  cp "$SCHEMA" "$fixture_root/.octon/framework/product/contracts/receipt-fanout-compaction-v1.schema.json"
}

field_from_publish_output() {
  local key="$1"
  awk -v key="$key" '$1 == key { print $2; exit }'
}

snapshot_file_metadata() {
  local path="$1"
  python3 - "$path" <<'PY'
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
stat = path.stat()
print(f"{stat.st_mtime_ns}\t{stat.st_size}")
PY
}

case_equivalent_receipts_reuse_content_addressed_full_receipt() {
  local fixture_root candidate_a candidate_b output_a output_b receipt_rel receipt_abs before after pointer_rel
  fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/octon-receipt-fanout.XXXXXX")"
  cleanup_paths+=("$fixture_root")
  prepare_fixture_schema "$fixture_root"
  candidate_a="$fixture_root/a.yml"
  candidate_b="$fixture_root/b.yml"
  write_fixture_receipt "$candidate_a" "receipt-a" "2026-07-02T00:00:00Z"
  write_fixture_receipt "$candidate_b" "receipt-b" "2026-07-02T00:01:00Z"

  output_a="$(octon_churn_publish_compacted_receipt "$fixture_root" ".octon/state/evidence/validation/publication/runtime" "runtime-pack-routes" "pack-routes-fixture" "$candidate_a")"
  receipt_rel="$(printf '%s\n' "$output_a" | field_from_publish_output receipt_path)"
  pointer_rel="$(printf '%s\n' "$output_a" | field_from_publish_output pointer_path)"
  receipt_abs="$fixture_root/$receipt_rel"
  before="$(snapshot_file_metadata "$receipt_abs")"
  sleep 1
  output_b="$(octon_churn_publish_compacted_receipt "$fixture_root" ".octon/state/evidence/validation/publication/runtime" "runtime-pack-routes" "pack-routes-fixture" "$candidate_b")"
  after="$(snapshot_file_metadata "$receipt_abs")"

  [[ "$(printf '%s\n' "$output_b" | field_from_publish_output receipt_path)" == "$receipt_rel" ]]
  [[ "$(printf '%s\n' "$output_b" | field_from_publish_output receipt_write_status)" == "unchanged" ]]
  [[ "$after" == "$before" ]]
  [[ "$(find "$fixture_root/.octon/state/evidence/validation/publication/runtime/by-digest" -type f | wc -l | tr -d '[:space:]')" == "1" ]]
  OCTON_ROOT_DIR="$fixture_root" bash "$VALIDATOR" --pointer "$pointer_rel" >/dev/null
}

case_pointer_digest_drift_fails_validation() {
  local fixture_root candidate output pointer_rel pointer_abs
  fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/octon-receipt-fanout.XXXXXX")"
  cleanup_paths+=("$fixture_root")
  prepare_fixture_schema "$fixture_root"
  candidate="$fixture_root/receipt.yml"
  write_fixture_receipt "$candidate" "receipt-a" "2026-07-02T00:00:00Z"
  output="$(octon_churn_publish_compacted_receipt "$fixture_root" ".octon/state/evidence/validation/publication/runtime" "runtime-pack-routes" "pack-routes-fixture" "$candidate")"
  pointer_rel="$(printf '%s\n' "$output" | field_from_publish_output pointer_path)"
  pointer_abs="$fixture_root/$pointer_rel"
  perl -0pi -e 's/receipt_sha256: "sha256:[a-f0-9]{64}"/receipt_sha256: "sha256:0000000000000000000000000000000000000000000000000000000000000000"/' "$pointer_abs"

  ! OCTON_ROOT_DIR="$fixture_root" bash "$VALIDATOR" --pointer "$pointer_rel" >/dev/null
}

case_assurance_publishers_use_compacted_receipts() {
  local publisher
  for publisher in \
    "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/generate-pack-routes.sh" \
    "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/generate-runtime-effective-route-bundle.sh"; do
    rg -q 'octon_churn_publish_compacted_receipt' "$publisher"
    rg -q 'octon_churn_receipt_ref_is_compacted' "$publisher"
    ! rg -q 'publication_receipt_path.*"\$tmp_out" "\$tmp_lock"' "$publisher"
  done
}

assert_success \
  "equivalent receipts reuse one content-addressed full receipt" \
  case_equivalent_receipts_reuse_content_addressed_full_receipt
assert_success \
  "pointer digest drift fails validation" \
  case_pointer_digest_drift_fails_validation
assert_success \
  "assurance publishers use compacted receipts" \
  case_assurance_publishers_use_compacted_receipts

echo "Test summary: pass=$pass_count fail=$fail_count"
[[ "$fail_count" -eq 0 ]]
