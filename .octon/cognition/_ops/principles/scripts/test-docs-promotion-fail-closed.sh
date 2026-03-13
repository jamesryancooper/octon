#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)"
cd "$ROOT_DIR"

POLICY=".octon/capabilities/governance/policy/deny-by-default.v2.yml"
RUNNER=".octon/engine/runtime/policy"

assert_pattern() {
  local value="$1"
  local pattern="$2"
  local label="$3"

  if ! printf '%s' "$value" | grep -E -q -- "$pattern"; then
    echo "[fail] $label"
    echo "value: $value"
    exit 1
  fi
}

tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/docs-gate-acp.XXXXXX")"
trap 'rm -rf "$tmp_dir"' EXIT

request_stage="$tmp_dir/request-stage-only.json"
request_deny="$tmp_dir/request-deny.json"

cat >"$request_stage" <<'JSON'
{
  "run_id": "docs-gate-stage-only",
  "actor": {"id": "agent.test", "type": "agent"},
  "profile": "refactor",
  "phase": "promote",
  "operation": {"class": "git.commit", "target": {"material_side_effect": true, "telemetry_profile": "minimal"}, "targets": [], "resources": []},
  "break_glass": false,
  "reversibility": {
    "reversible": true,
    "primitive": "git.revert_commit",
    "rollback_handle": "git:revert:stage",
    "recovery_window": "P30D"
  },
  "evidence": [
    {"type": "diff", "ref": "artifacts/diff.patch", "sha256": "aaa"},
    {"type": "tests", "ref": "artifacts/tests.json", "sha256": "bbb"}
  ],
  "attestations": [],
  "budgets": {},
  "counters": {
    "repo.max_files_touched": 4,
    "repo.max_loc_delta": 120,
    "repo.max_commits": 1,
    "time.max_seconds": 30
  },
  "circuit_signals": [],
  "intent": "docs-gate-test",
  "boundaries": "docs-gate-test"
}
JSON

stage_output="$("$RUNNER" acp-enforce --policy "$POLICY" --request "$request_stage" --emit-receipt --run-id docs-gate-stage-only || true)"
assert_pattern "$stage_output" '"decision"[[:space:]]*:[[:space:]]*"STAGE_ONLY"' 'ACP-1 missing docs evidence should stage-only'
assert_pattern "$stage_output" '"ACP_DOCS_EVIDENCE_MISSING"' 'ACP-1 missing docs should emit docs gate reason code'
assert_pattern "$stage_output" '"ACP_EVIDENCE_MISSING"' 'ACP-1 missing docs should emit evidence reason code'

stage_receipt=".octon/continuity/runs/docs-gate-stage-only/receipt.latest.json"
if [[ ! -f "$stage_receipt" ]]; then
  echo "[fail] missing receipt for stage-only docs gate case: $stage_receipt"
  exit 1
fi
assert_pattern "$(jq -c . "$stage_receipt")" '"decision"[[:space:]]*:[[:space:]]*"STAGE_ONLY"' 'stage-only receipt should be emitted'
assert_pattern "$(jq -c '.requirements.missing_evidence' "$stage_receipt")" 'docs\.spec|docs\.adr|docs\.runbook' 'stage-only receipt should include missing docs evidence'

cat >"$request_deny" <<'JSON'
{
  "run_id": "docs-gate-deny",
  "actor": {"id": "agent.test", "type": "agent"},
  "profile": "operate",
  "phase": "promote",
  "operation": {"class": "git.merge", "target": {"branch": "main", "material_side_effect": true, "telemetry_profile": "full"}, "targets": [], "resources": []},
  "break_glass": false,
  "reversibility": {
    "reversible": true,
    "primitive": "git.revert_merge",
    "rollback_handle": "git:revert:deny",
    "recovery_window": "P30D",
    "rollback_proof": "artifacts/rollback.log"
  },
  "evidence": [
    {"type": "diff", "ref": "artifacts/diff.patch", "sha256": "aaa"},
    {"type": "tests", "ref": "artifacts/tests.json", "sha256": "bbb"}
  ],
  "attestations": [
    {"role": "proposer", "actor_id": "agent.a", "timestamp": "2026-02-20T00:00:00Z", "plan_hash": "plan-hash-1", "evidence_hash": "evidence-hash-1", "signature": "sig-a"},
    {"role": "verifier", "actor_id": "agent.b", "timestamp": "2026-02-20T00:01:00Z", "plan_hash": "plan-hash-1", "evidence_hash": "evidence-hash-1", "signature": "sig-b"}
  ],
  "budgets": {},
  "counters": {
    "repo.max_files_touched": 20,
    "repo.max_loc_delta": 600,
    "repo.max_commits": 1,
    "time.max_seconds": 60
  },
  "circuit_signals": [],
  "plan_hash": "plan-hash-1",
  "evidence_hash": "evidence-hash-1",
  "intent": "docs-gate-test",
  "boundaries": "docs-gate-test"
}
JSON

deny_output="$("$RUNNER" acp-enforce --policy "$POLICY" --request "$request_deny" --emit-receipt --run-id docs-gate-deny || true)"
assert_pattern "$deny_output" '"decision"[[:space:]]*:[[:space:]]*"DENY"' 'ACP-2 missing docs evidence should deny per policy docs gate map'
assert_pattern "$deny_output" '"ACP_DOCS_EVIDENCE_MISSING"' 'ACP-2 deny should emit docs gate reason code'

deny_receipt=".octon/continuity/runs/docs-gate-deny/receipt.latest.json"
if [[ ! -f "$deny_receipt" ]]; then
  echo "[fail] missing receipt for deny docs gate case: $deny_receipt"
  exit 1
fi
assert_pattern "$(jq -c . "$deny_receipt")" '"decision"[[:space:]]*:[[:space:]]*"DENY"' 'deny receipt should be emitted'
assert_pattern "$(jq -c '.requirements.missing_evidence' "$deny_receipt")" 'docs\.spec|docs\.adr|docs\.runbook' 'deny receipt should include missing docs evidence'

echo "Documentation promotion fail-closed contract test passed."
