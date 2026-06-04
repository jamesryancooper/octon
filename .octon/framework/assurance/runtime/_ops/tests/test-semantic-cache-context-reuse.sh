#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
TEST_NAME="$(basename "$0")"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-semantic-cache-context-reuse.sh"
GENERATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/generate-semantic-cache-context-reuse.sh"

pass_count=0
fail_count=0

pass() {
  echo "PASS: $1"
  pass_count=$((pass_count + 1))
}

fail() {
  echo "FAIL: $1" >&2
  fail_count=$((fail_count + 1))
}

assert_success() {
  local label="$1"
  shift
  if "$@"; then
    pass "$label"
  else
    fail "$label"
  fi
}

assert_failure() {
  local label="$1"
  shift
  if "$@"; then
    fail "$label"
  else
    pass "$label"
  fi
}

write_file() {
  local path="$1"
  shift
  mkdir -p "$(dirname "$path")"
  printf '%s\n' "$@" >"$path"
}

make_fixture() {
  local fixture_root="$1"
  mkdir -p "$fixture_root"
  write_file "$fixture_root/.octon/framework/constitution/CHARTER.md" \
    '# Fixture Charter' \
    'Fixture authority source.'
  write_file "$fixture_root/.octon/framework/engine/runtime/spec/context-pack-builder-v1.md" \
    '# Context Pack Builder Fixture' \
    'semantic-cache-context-reuse-v1.schema.json'
  write_file "$fixture_root/.octon/framework/engine/runtime/spec/semantic-cache-context-reuse-v1.schema.json" \
    '{"title":"Semantic Cache Context Reuse Fixture"}'
  write_file "$fixture_root/.octon/framework/engine/runtime/spec/token-budget-ledger-v1.md" \
    '# Token Budget Ledger Fixture'
  write_file "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/validate-semantic-cache-context-reuse.sh" \
    '#!/usr/bin/env bash' \
    'exit 0'
  write_file "$fixture_root/.octon/framework/assurance/runtime/_ops/scripts/generate-semantic-cache-context-reuse.sh" \
    '#!/usr/bin/env bash' \
    'exit 0'
  write_file "$fixture_root/.octon/instance/governance/policies/context-packing.yml" \
    'schema_version: fixture-context-packing-v1' \
    'stage_defaults:' \
    '  lifecycle-route: digest-only'
  write_file "$fixture_root/.octon/generated/effective/runtime/route-bundle.yml" \
    'schema_version: fixture-route-bundle-v1' \
    'authority_status: derived-only'
  write_file "$fixture_root/.octon/state/evidence/runs/run-1/context/context-pack-receipt.json" \
    '{"schema_version":"context-pack-receipt-v1","receipt_id":"receipt-1"}'
  write_file "$fixture_root/.octon/state/evidence/runs/run-1/replay/context.ndjson" \
    '{"event_type":"context-pack-built"}'
  write_file "$fixture_root/.octon/state/evidence/runs/run-1/raw/source-a.md" \
    '# Source A' \
    'Raw retained evidence stays reachable.'

  python3 - "$fixture_root" <<'PY'
import hashlib
import json
import pathlib
import sys

root = pathlib.Path(sys.argv[1])
artifact_dir = root / ".octon/state/evidence/runs/run-1/semantic-cache"
artifact_dir.mkdir(parents=True, exist_ok=True)

def sha(ref):
    return "sha256:" + hashlib.sha256((root / ref).read_bytes()).hexdigest()

def fake_sha(seed):
    return "sha256:" + hashlib.sha256(seed.encode()).hexdigest()

source_refs = [
    ".octon/framework/constitution/CHARTER.md",
    ".octon/generated/effective/runtime/route-bundle.yml",
    ".octon/state/evidence/runs/run-1/context/context-pack-receipt.json",
]
source_digests = [{"source_ref": ref, "sha256": sha(ref)} for ref in source_refs]
source_records = [
    {
        "source_ref": ".octon/framework/constitution/CHARTER.md",
        "sha256": sha(".octon/framework/constitution/CHARTER.md"),
        "source_class": "authority",
        "authority_label": "authoritative",
        "inclusion_mode": "summary",
        "model_visible": False,
        "estimated_tokens": 12,
    },
    {
        "source_ref": ".octon/generated/effective/runtime/route-bundle.yml",
        "sha256": sha(".octon/generated/effective/runtime/route-bundle.yml"),
        "source_class": "generated",
        "authority_label": "derived",
        "inclusion_mode": "handle-only",
        "model_visible": False,
        "estimated_tokens": 6,
    },
    {
        "source_ref": ".octon/state/evidence/runs/run-1/context/context-pack-receipt.json",
        "sha256": sha(".octon/state/evidence/runs/run-1/context/context-pack-receipt.json"),
        "source_class": "evidence",
        "authority_label": "evidence",
        "inclusion_mode": "handle-only",
        "model_visible": False,
        "estimated_tokens": 8,
    },
]
common = {
    "authority_status": "non-authoritative retained evidence read model",
    "producer": {"id": "fixture-semantic-cache-producer", "version": "semantic-cache-context-reuse-v1"},
    "consumer": {
        "preferred": "compact-default",
        "allowed_consumers": ["validators", "operators", "context-pack-builder"],
        "forbidden_consumers": ["runtime-authority", "policy-authority", "support-proof", "closure-authority"],
    },
    "source_refs": source_refs,
    "source_digests": source_digests,
    "source_records": source_records,
    "policy_ref": ".octon/instance/governance/policies/context-packing.yml",
    "policy_sha256": sha(".octon/instance/governance/policies/context-packing.yml"),
    "route_binding": {
        "lifecycle_id": "proposal-packet",
        "route_id": "run-packet-implementation",
        "route_purpose": "semantic-cache-fixture",
        "trust_class": "repo-local",
        "request_binding_sha256": fake_sha("request-binding"),
    },
    "freshness": {"state": "fresh", "generated_at": "2026-06-03T00:00:00Z", "valid_until": None},
    "validation": {
        "status": "pass",
        "validator_ref": ".octon/framework/assurance/runtime/_ops/scripts/validate-semantic-cache-context-reuse.sh",
        "model_visible_sha256": fake_sha("model-visible"),
        "model_visible_token_estimate": 500,
    },
    "evidence_refs": [".octon/state/evidence/runs/run-1/context/context-pack-receipt.json"],
    "failure_behavior": {
        "fail_closed_on": [
            "missing-source",
            "source-digest-mismatch",
            "policy-digest-mismatch",
            "request-binding-mismatch",
            "expired-freshness",
            "missing-retained-evidence",
            "trust-downgrade",
            "explicit-governance-invalidation",
            "authority-boundary-violation",
            "missing-model-visible-hash",
            "missing-replay-ref",
        ]
    },
    "authority_boundary": {
        "artifact_class": "retained-evidence-read-model",
        "replaces_source_evidence": False,
        "authorizes_execution": False,
        "raw_evidence_retained": True,
        "proposal_input_authority": "non-authoritative",
        "generated_output_authority": "derived-only",
    },
}

semantic = {
    **common,
    "schema_version": "proposal-semantic-cache-v1",
    "artifact_kind": "proposal-semantic-cache",
    "semantic_entries": [
        {
            "summary_id": "summary-charter",
            "source_ref": ".octon/framework/constitution/CHARTER.md",
            "source_sha256": sha(".octon/framework/constitution/CHARTER.md"),
            "policy_sha256": sha(".octon/instance/governance/policies/context-packing.yml"),
            "route_purpose": "semantic-cache-fixture",
            "trust_class": "repo-local",
            "model_visible_sha256": fake_sha("semantic-entry"),
            "token_estimate": 400,
            "raw_evidence_ref": ".octon/state/evidence/runs/run-1/raw/source-a.md",
        }
    ],
}
layer = {
    **common,
    "schema_version": "context-pack-layer-cache-v1",
    "artifact_kind": "context-pack-layer-cache",
    "layers": [
        {
            "layer_id": "stable-governance",
            "source_refs": source_refs,
            "source_digests": source_digests,
            "reuse_binding": {"stage_ids": ["review", "implementation"]},
            "replay_refs": [".octon/state/evidence/runs/run-1/replay/context.ndjson"],
            "model_visible_sha256": fake_sha("layer-visible"),
            "token_estimate": 450,
        }
    ],
}
events = {
    **common,
    "schema_version": "cache-invalidation-events-v1",
    "artifact_kind": "cache-invalidation-events",
    "supported_triggers": [
        "source-digest-drift",
        "policy-digest-drift",
        "request-binding-mismatch",
        "expired-freshness",
        "missing-retained-evidence",
        "trust-downgrade",
        "explicit-governance-invalidation",
    ],
    "events": [
        {
            "event_id": "recorded-clean-source-check",
            "trigger": "source-digest-drift",
            "state": "recorded",
            "source_ref": ".octon/framework/constitution/CHARTER.md",
            "previous_sha256": sha(".octon/framework/constitution/CHARTER.md"),
            "current_sha256": sha(".octon/framework/constitution/CHARTER.md"),
            "fail_closed": True,
        }
    ],
}

for name, data in {
    "proposal-semantic-cache.yml": semantic,
    "context-pack-layer-cache.yml": layer,
    "cache-invalidation-events.yml": events,
}.items():
    (artifact_dir / name).write_text(json.dumps(data, indent=2, sort_keys=True) + "\n")

def ledger(total, model_visible):
    return {
        "schema_version": "token-budget-ledger-v1",
        "schema_ref": ".octon/framework/engine/runtime/spec/token-budget-ledger-v1.schema.json",
        "ledger_id": f"ledger-{total}",
        "run_id": "run-1",
        "lifecycle_id": "proposal-packet",
        "route_id": "run-packet-implementation",
        "ledger_scope": {
            "level": "route",
            "target_ref": ".octon/state/evidence/runs/run-1/semantic-cache",
            "evidence_root_ref": ".octon/state/evidence/runs/run-1",
        },
        "produced_by": {"name": "fixture", "version": "token-budget-ledger-v1", "recorded_at": "2026-06-03T00:00:00Z"},
        "ledger_role": "retained-token-measurement-evidence-not-authority",
        "token_generation_mode": "deterministic-byte-estimate-provider-usage-when-present",
        "provider_usage": {"status": "not_available", "usage_mismatch_detected": False, "notes": []},
        "token_summary": {
            "estimated_total_tokens": total,
            "model_visible_estimated_tokens": model_visible,
            "prompt_estimated_tokens": 100,
            "context_estimated_tokens": model_visible,
            "completion_estimated_tokens": 0,
            "tool_output_estimated_tokens": 0,
            "evidence_estimated_tokens": 0,
            "repeated_source_percentage": 10,
            "repeated_source_token_estimate": 50,
            "prompt_boilerplate_percentage": 5,
            "prompt_boilerplate_token_estimate": 10,
            "generated_state_reread_count": 0,
            "raw_log_reread_count": 0,
            "high_reasoning_call_count": 0,
        },
        "levels": [
            {"level": "parent", "subject_id": "program", "estimated_tokens": 1, "source_count": 1, "notes": []},
            {"level": "child", "subject_id": "child", "estimated_tokens": 1, "source_count": 1, "notes": []},
            {"level": "stage", "subject_id": "stage", "estimated_tokens": 1, "source_count": 1, "notes": []},
            {"level": "source", "subject_id": "source", "estimated_tokens": 1, "source_count": 1, "notes": []},
            {"level": "model", "subject_id": "model", "estimated_tokens": 1, "source_count": 1, "notes": []},
        ],
        "source_records": [
            {
                "source_ref": ".octon/framework/constitution/CHARTER.md",
                "sha256": sha(".octon/framework/constitution/CHARTER.md"),
                "bytes": 10,
                "estimated_tokens": 3,
                "source_class": "authority",
                "model_visible": False,
                "inclusion_mode": "digest-bound",
            }
        ],
        "regression_guard": {
            "baseline_ref": None,
            "candidate_ref": "token-budget/candidate.json",
            "avoidable_regression_threshold_percent": 30,
            "status": "measurement-only",
            "notes": [],
        },
        "authority_boundary": {
            "artifact_class": "retained-evidence-read-model",
            "replaces_source_evidence": False,
            "authorizes_execution": False,
            "raw_evidence_retained": True,
            "proposal_input_authority": "non-authoritative",
            "generated_output_authority": "derived-only",
            "failure_behavior": "fail-closed-for-regression-claims-not-for-authorization",
        },
    }

budget_dir = root / "token-budget"
budget_dir.mkdir(parents=True, exist_ok=True)
(budget_dir / "baseline.json").write_text(json.dumps(ledger(1000, 1000), indent=2, sort_keys=True) + "\n")
(budget_dir / "candidate.json").write_text(json.dumps(ledger(800, 800), indent=2, sort_keys=True) + "\n")
(budget_dir / "regression.json").write_text(json.dumps(ledger(2000, 2000), indent=2, sort_keys=True) + "\n")
PY
}

artifact_dir() {
  printf '%s\n' ".octon/state/evidence/runs/run-1/semantic-cache"
}

case_valid_artifacts_pass() {
  local root="$1"
  bash "$VALIDATOR" --root "$root" --artifact-dir "$(artifact_dir)"
}

case_generator_writes_valid_artifacts() {
  local root="$1"
  rm -rf "$root/$(artifact_dir)"
  bash "$GENERATOR" \
    --root "$root" \
    --artifact-dir "$(artifact_dir)" \
    --source-ref .octon/framework/constitution/CHARTER.md \
    --source-ref .octon/generated/effective/runtime/route-bundle.yml \
    --source-ref .octon/state/evidence/runs/run-1/context/context-pack-receipt.json \
    --evidence-ref .octon/state/evidence/runs/run-1/context/context-pack-receipt.json \
    --replay-ref .octon/state/evidence/runs/run-1/replay/context.ndjson \
    --stage-id review \
    --stage-id implementation \
    --write >/dev/null
}

case_source_digest_drift_fails() {
  local root="$1"
  printf '%s\n' 'drift' >>"$root/.octon/framework/constitution/CHARTER.md"
  ! bash "$VALIDATOR" --root "$root" --artifact-dir "$(artifact_dir)" >/dev/null 2>&1
}

case_policy_digest_drift_fails() {
  local root="$1"
  printf '%s\n' 'policy drift' >>"$root/.octon/instance/governance/policies/context-packing.yml"
  ! bash "$VALIDATOR" --root "$root" --artifact-dir "$(artifact_dir)" >/dev/null 2>&1
}

case_generated_authority_fails() {
  local root="$1"
  python3 - "$root/.octon/state/evidence/runs/run-1/semantic-cache/proposal-semantic-cache.yml" <<'PY'
import json
import pathlib
import sys
path = pathlib.Path(sys.argv[1])
data = json.loads(path.read_text())
for record in data["source_records"]:
    if record["source_class"] == "generated":
        record["authority_label"] = "authoritative"
path.write_text(json.dumps(data, indent=2, sort_keys=True) + "\n")
PY
  ! bash "$VALIDATOR" --root "$root" --artifact-dir "$(artifact_dir)" >/dev/null 2>&1
}

case_missing_replay_fails() {
  local root="$1"
  rm "$root/.octon/state/evidence/runs/run-1/replay/context.ndjson"
  ! bash "$VALIDATOR" --root "$root" --artifact-dir "$(artifact_dir)" >/dev/null 2>&1
}

case_active_invalidation_fails() {
  local root="$1"
  python3 - "$root/.octon/state/evidence/runs/run-1/semantic-cache/cache-invalidation-events.yml" <<'PY'
import json
import pathlib
import sys
path = pathlib.Path(sys.argv[1])
data = json.loads(path.read_text())
data["events"][0]["state"] = "active"
path.write_text(json.dumps(data, indent=2, sort_keys=True) + "\n")
PY
  ! bash "$VALIDATOR" --root "$root" --artifact-dir "$(artifact_dir)" >/dev/null 2>&1
}

case_cache_overhead_fails() {
  local root="$1"
  python3 - "$root/.octon/state/evidence/runs/run-1/semantic-cache/proposal-semantic-cache.yml" <<'PY'
import json
import pathlib
import sys
path = pathlib.Path(sys.argv[1])
data = json.loads(path.read_text())
data["validation"]["model_visible_token_estimate"] = 2500
data["semantic_entries"][0]["token_estimate"] = 2500
path.write_text(json.dumps(data, indent=2, sort_keys=True) + "\n")
PY
  ! bash "$VALIDATOR" --root "$root" --artifact-dir "$(artifact_dir)" >/dev/null 2>&1
}

case_token_regression_passes() {
  local root="$1"
  bash "$VALIDATOR" \
    --root "$root" \
    --artifact-dir "$(artifact_dir)" \
    --baseline-ledger token-budget/baseline.json \
    --candidate-ledger token-budget/candidate.json \
    --threshold-percent 30 >/dev/null
}

case_token_regression_fails() {
  local root="$1"
  ! bash "$VALIDATOR" \
    --root "$root" \
    --artifact-dir "$(artifact_dir)" \
    --baseline-ledger token-budget/baseline.json \
    --candidate-ledger token-budget/regression.json \
    --threshold-percent 30 >/dev/null 2>&1
}

main() {
  local tmp
  tmp="$(mktemp -d)"
  trap "rm -rf '$tmp'" EXIT

  local root
  root="$tmp/valid"
  make_fixture "$root"
  assert_success "valid semantic cache artifacts pass" case_valid_artifacts_pass "$root"

  root="$tmp/generator"
  make_fixture "$root"
  assert_success "generator writes valid semantic cache artifacts" case_generator_writes_valid_artifacts "$root"

  root="$tmp/source-drift"
  make_fixture "$root"
  assert_success "source digest drift fails closed" case_source_digest_drift_fails "$root"

  root="$tmp/policy-drift"
  make_fixture "$root"
  assert_success "policy digest drift fails closed" case_policy_digest_drift_fails "$root"

  root="$tmp/generated-authority"
  make_fixture "$root"
  assert_success "generated source as authority fails closed" case_generated_authority_fails "$root"

  root="$tmp/missing-replay"
  make_fixture "$root"
  assert_success "missing layer replay ref fails closed" case_missing_replay_fails "$root"

  root="$tmp/active-invalidation"
  make_fixture "$root"
  assert_success "active invalidation event fails closed" case_active_invalidation_fails "$root"

  root="$tmp/cache-overhead"
  make_fixture "$root"
  assert_success "cache hit overhead above ceiling fails closed" case_cache_overhead_fails "$root"

  root="$tmp/token-pass"
  make_fixture "$root"
  assert_success "token regression threshold accepts improved candidate" case_token_regression_passes "$root"

  root="$tmp/token-fail"
  make_fixture "$root"
  assert_success "token regression threshold rejects oversized candidate" case_token_regression_fails "$root"

  echo
  echo "$TEST_NAME: passed=$pass_count failed=$fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
