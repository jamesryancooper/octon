#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
TEST_NAME="$(basename "$0")"
VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-retained-run-evidence-index.sh"

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

make_fixture() {
  local fixture_root="$1"
  local mode="${2:-direct}"
  mkdir -p \
    "$fixture_root/.octon/state/control/execution/runs/test-run" \
    "$fixture_root/.octon/state/evidence/runs/test-run/validation" \
    "$fixture_root/.octon/state/evidence/runs/test-run/rollback" \
    "$fixture_root/.octon/state/evidence/runs/workflows/test-run" \
    "$fixture_root/.octon/generated/effective/runtime" \
    "$fixture_root/.octon/inputs/exploratory/proposals/architecture/test-proposal"

  printf 'status: completed\nrun_id: test-run\n' >"$fixture_root/.octon/state/control/execution/runs/test-run/runtime-state.yml"
  printf 'validation: pass\n' >"$fixture_root/.octon/state/evidence/runs/test-run/validation/result.yml"
  printf 'rollback: revert retained-run evidence index fixture\n' >"$fixture_root/.octon/state/evidence/runs/test-run/rollback/rollback.md"
  printf 'workflow: retained substitute evidence\n' >"$fixture_root/.octon/state/evidence/runs/workflows/test-run/summary.md"
  printf 'generated: summary only\n' >"$fixture_root/.octon/generated/effective/runtime/read-model.yml"
  printf 'proposal: context only\n' >"$fixture_root/.octon/inputs/exploratory/proposals/architecture/test-proposal/proposal.yml"

  python3 - "$fixture_root" "$mode" <<'PY'
import hashlib
import json
import pathlib
import sys

root = pathlib.Path(sys.argv[1]).resolve()
mode = sys.argv[2]

def rel(path):
    return str(path.resolve().relative_to(root))

def sha(path):
    return "sha256:" + hashlib.sha256(path.read_bytes()).hexdigest()

control = root / ".octon/state/control/execution/runs/test-run/runtime-state.yml"
validation = root / ".octon/state/evidence/runs/test-run/validation/result.yml"
rollback = root / ".octon/state/evidence/runs/test-run/rollback/rollback.md"
substitute = root / ".octon/state/evidence/runs/workflows/test-run/summary.md"
generated = root / ".octon/generated/effective/runtime/read-model.yml"
proposal = root / ".octon/inputs/exploratory/proposals/architecture/test-proposal/proposal.yml"

def record(path, role, ref_class, authority_use):
    return {
        "ref": rel(path),
        "role": role,
        "ref_class": ref_class,
        "sha256": sha(path),
        "authority_use": authority_use,
        "required": True,
    }

control_refs = [record(control, "runtime-state", "control", "control-truth")] if mode == "direct" else []
substitute_refs = [] if mode == "direct" else [
    record(substitute, "workflow-summary-substitute", "retained-workflow-evidence", "evidence-only")
]
terminal = {
    "child": [],
    "parent": [],
    "validation": [record(validation, "validation-result", "retained-evidence", "evidence-only")],
    "rollback": [record(rollback, "rollback-posture", "retained-evidence", "evidence-only")],
    "closeout": [],
    "cleanup": [],
}
indexed = []
indexed.extend(control_refs)
indexed.extend(substitute_refs)
for records in terminal.values():
    indexed.extend(records)
indexed.extend([
    record(generated, "generated-read-model", "generated", "derived-only"),
    record(proposal, "proposal-context", "proposal-local", "non-authoritative"),
])
ref_class_counts = {}
for item in indexed:
    ref_class = item.get("ref_class", "unknown")
    ref_class_counts[ref_class] = ref_class_counts.get(ref_class, 0) + 1
terminal_evidence_ref_count = sum(len(records) for records in terminal.values())

index = {
    "schema_version": "retained-run-evidence-index-v1",
    "subject": {
        "run_id": "test-run",
        "lifecycle_kind": "proposal-packet",
        "terminal_status": "implemented",
    },
    "producer": "test-retained-run-evidence-index",
    "generated_at": "2026-06-11T00:00:00Z",
    "evidence_posture": {
        "purpose": "discovery-and-replay-aid",
        "freshness_state": "digest-bound",
        "direct_control_refs_present": mode == "direct",
    },
    "control_refs": control_refs,
    "substitute_workflow_refs": substitute_refs,
    "terminal_evidence_refs": terminal,
    "indexed_refs": indexed,
    "retrieval_metrics": {
        "metric_authority": "evidence-only",
        "indexed_ref_count": len(indexed),
        "terminal_evidence_ref_count": terminal_evidence_ref_count,
        "control_ref_count": len(control_refs),
        "substitute_workflow_ref_count": len(substitute_refs),
        "retained_evidence_ref_count": (
            ref_class_counts.get("retained-evidence", 0)
            + ref_class_counts.get("retained-workflow-evidence", 0)
        ),
        "proposal_local_ref_count": ref_class_counts.get("proposal-local", 0),
        "generated_ref_count": ref_class_counts.get("generated", 0),
    },
    "freshness": {
        "mode": "digest-bound",
        "source_digest_required": True,
        "stale_behavior": "fail-closed",
    },
    "authority_boundary": {
        "replaces_source_evidence": False,
        "authorizes_execution": False,
        "satisfies_lifecycle_transition_authority": False,
        "satisfies_child_receipts": False,
        "proposal_input_authority": "non-authoritative",
        "generated_output_authority": "derived-only",
        "raw_evidence_retained": True,
    },
    "failure_behavior": [
        "fail-closed-on-source-missing",
        "fail-closed-on-source-digest-mismatch",
        "fail-closed-on-authority-boundary-conflict",
    ],
}

(root / "retained-run-evidence-index.yml").write_text(json.dumps(index, indent=2) + "\n")
PY
}

mutate_json() {
  local path="$1"
  local expression="$2"
  python3 - "$path" "$expression" <<'PY'
import json
import pathlib
import sys

path = pathlib.Path(sys.argv[1])
expression = sys.argv[2].replace("\\n", "\n")
data = json.loads(path.read_text())
exec(expression, {"data": data})
path.write_text(json.dumps(data, indent=2) + "\n")
PY
}

main() {
  local tmp
  tmp="$(mktemp -d)"
  trap "rm -rf '$tmp'" EXIT

  local direct_root="$tmp/direct"
  make_fixture "$direct_root" direct
  assert_success "valid direct-control evidence index passes" \
    bash "$VALIDATOR" --root "$direct_root" --index retained-run-evidence-index.yml

  local substitute_root="$tmp/substitute"
  make_fixture "$substitute_root" substitute
  assert_success "valid substitute workflow evidence index passes" \
    bash "$VALIDATOR" --root "$substitute_root" --index retained-run-evidence-index.yml

  local missing_terminal_root="$tmp/missing-terminal"
  make_fixture "$missing_terminal_root" direct
  mutate_json "$missing_terminal_root/retained-run-evidence-index.yml" "data['terminal_evidence_refs']['validation'] = []"
  assert_failure "missing terminal evidence refs fail closed" \
    bash "$VALIDATOR" --root "$missing_terminal_root" --index retained-run-evidence-index.yml

  local stale_root="$tmp/stale"
  make_fixture "$stale_root" direct
  printf 'tampered\n' >>"$stale_root/.octon/state/evidence/runs/test-run/validation/result.yml"
  assert_failure "stale source digest fails closed" \
    bash "$VALIDATOR" --root "$stale_root" --index retained-run-evidence-index.yml

  local unresolved_root="$tmp/unresolved-substitute"
  make_fixture "$unresolved_root" substitute
  rm "$unresolved_root/.octon/state/evidence/runs/workflows/test-run/summary.md"
  assert_failure "unresolved substitute refs fail closed" \
    bash "$VALIDATOR" --root "$unresolved_root" --index retained-run-evidence-index.yml

  local missing_rollback_root="$tmp/missing-rollback"
  make_fixture "$missing_rollback_root" direct
  mutate_json "$missing_rollback_root/retained-run-evidence-index.yml" "data['terminal_evidence_refs']['rollback'] = []"
  assert_failure "missing rollback refs fail closed" \
    bash "$VALIDATOR" --root "$missing_rollback_root" --index retained-run-evidence-index.yml

  local generated_auth_root="$tmp/generated-authority"
  make_fixture "$generated_auth_root" direct
  mutate_json "$generated_auth_root/retained-run-evidence-index.yml" "\nfor item in data['indexed_refs']:\n    if item['ref_class'] == 'generated':\n        item['authority_use'] = 'control-truth'\n"
  assert_failure "generated refs claiming authority fail closed" \
    bash "$VALIDATOR" --root "$generated_auth_root" --index retained-run-evidence-index.yml

  local proposal_auth_root="$tmp/proposal-authority"
  make_fixture "$proposal_auth_root" direct
  mutate_json "$proposal_auth_root/retained-run-evidence-index.yml" "\nfor item in data['indexed_refs']:\n    if item['ref_class'] == 'proposal-local':\n        item['authority_use'] = 'evidence-only'\n"
  assert_failure "proposal-local refs claiming authority fail closed" \
    bash "$VALIDATOR" --root "$proposal_auth_root" --index retained-run-evidence-index.yml

  local metric_mismatch_root="$tmp/metric-mismatch"
  make_fixture "$metric_mismatch_root" direct
  mutate_json "$metric_mismatch_root/retained-run-evidence-index.yml" "data['retrieval_metrics']['indexed_ref_count'] += 1"
  assert_failure "retrieval metric mismatches fail closed" \
    bash "$VALIDATOR" --root "$metric_mismatch_root" --index retained-run-evidence-index.yml

  echo
  echo "$TEST_NAME: passed=$pass_count failed=$fail_count"
  [[ "$fail_count" -eq 0 ]]
}

main "$@"
