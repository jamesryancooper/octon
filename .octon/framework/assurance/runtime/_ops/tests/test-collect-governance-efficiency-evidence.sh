#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
COLLECTOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/collect-governance-efficiency-evidence.sh"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/governance-efficiency-collector-test.XXXXXX")"
trap 'rm -rf "$TMP_DIR"' EXIT

target="$TMP_DIR/proposal-example"
mkdir -p "$target/support"
cat >"$target/proposal.yml" <<'YAML'
schema_version: proposal-v1
proposal_id: proposal-example
status: implemented
proposal_kind: architecture
YAML
printf 'verdict: pass\n' >"$target/support/proposal-review.md"
printf 'verdict: pass\n' >"$target/support/implementation-run.md"

before_count="$(find "$target" -type f | wc -l | tr -d ' ')"
out="$TMP_DIR/evidence.yml"
OCTON_ROOT_DIR="$TMP_DIR" bash "$COLLECTOR" --target proposal-example --output "$out"
after_count="$(find "$target" -type f | wc -l | tr -d ' ')"

[[ "$before_count" == "$after_count" ]] || { echo "[ERROR] collector mutated target tree"; exit 1; }
[[ "$(yq -r '.schema_version' "$out")" == "octon-governance-efficiency-evidence-v1" ]] || { echo "[ERROR] evidence schema mismatch"; exit 1; }
[[ "$(yq -r '.authority_boundaries.mutates_repo' "$out")" == "false" ]] || { echo "[ERROR] collector authority boundary missing"; exit 1; }
[[ "$(yq -r '.summary.evidence_items_present' "$out")" == "2" ]] || { echo "[ERROR] present evidence count mismatch"; exit 1; }
[[ "$(yq -r '.summary.evidence_items_missing' "$out")" == "5" ]] || { echo "[ERROR] missing evidence count mismatch"; exit 1; }

echo "test-collect-governance-efficiency-evidence: pass"
