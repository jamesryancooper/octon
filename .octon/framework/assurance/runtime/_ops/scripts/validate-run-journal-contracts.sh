#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
VALIDATION_ROOT="$OCTON_DIR/state/evidence/validation/run-journal-runtime-hardening"

errors=0

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

pass() {
  echo "[OK] $1"
}

require_tool() {
  if command -v "$1" >/dev/null 2>&1; then
    pass "$1 available"
  else
    fail "$1 is required"
    exit 1
  fi
}

require_file() {
  local path="$1"
  if [[ -f "$path" ]]; then
    pass "found ${path#$ROOT_DIR/}"
  else
    fail "missing ${path#$ROOT_DIR/}"
  fi
}

echo "== Run Journal Contract Validation =="

require_tool yq
require_tool python3

require_file "$OCTON_DIR/framework/constitution/contracts/runtime/run-event-v2.schema.json"
require_file "$OCTON_DIR/framework/constitution/contracts/runtime/run-event-ledger-v2.schema.json"
require_file "$OCTON_DIR/framework/constitution/contracts/runtime/runtime-state-v2.schema.json"
require_file "$OCTON_DIR/framework/constitution/contracts/runtime/state-reconstruction-v2.md"
require_file "$OCTON_DIR/framework/engine/runtime/spec/run-journal-v1.md"
require_file "$OCTON_DIR/framework/engine/runtime/spec/runtime-event-v1.schema.json"
require_file "$OCTON_DIR/framework/engine/runtime/spec/run-lifecycle-v1.md"
require_file "$OCTON_DIR/framework/engine/runtime/spec/evidence-store-v1.md"
require_file "$OCTON_DIR/framework/engine/runtime/spec/operator-read-models-v1.md"
require_file "$OCTON_DIR/framework/engine/runtime/spec/authorization-boundary-coverage-v1.md"

python3 - "$VALIDATION_ROOT" <<'PY'
import copy
import hashlib
import json
import subprocess
import sys
from pathlib import Path

root = Path(sys.argv[1])
repo_root = root.parents[4]

def load_yaml(path: Path):
    return json.loads(subprocess.check_output(["yq", "-o=json", ".", str(path)], text=True))

def load_events(path: Path):
    events = []
    for line in path.read_text().splitlines():
        line = line.strip()
        if not line:
            continue
        events.append(json.loads(line))
    return events

def event_hash(event):
    hash_input = {
        "schema_version": event["schema_version"],
        "event_id": event["event_id"],
        "run_id": event["run_id"],
        "sequence": event["sequence"],
        "event_type": event["event_type"],
        "recorded_at": event["recorded_at"],
        "subject_ref": event.get("subject_ref"),
        "actor": event["actor"],
        "causality": event["causality"],
        "classification": event["classification"],
        "lifecycle": event["lifecycle"],
        "governing_refs": event["governing_refs"],
        "payload": event["payload"],
        "effect": event["effect"],
        "redaction": event["redaction"],
        "previous_event_hash": event["integrity"].get("previous_event_hash"),
    }
    return "sha256:" + hashlib.sha256(
        json.dumps(hash_input, separators=(",", ":")).encode()
    ).hexdigest()

def validate_positive(case_dir: Path):
    manifest = load_yaml(case_dir / "control" / "events.manifest.yml")
    events = load_events(case_dir / "control" / "events.ndjson")
    runtime_state = load_yaml(case_dir / "control" / "runtime-state.yml")
    errors = []
    if not events:
        errors.append("journal has no events")
        return errors

    if manifest["event_count"] != len(events):
        errors.append("event_count mismatch")
    if manifest["first_event_ref"]["event_id"] != events[0]["event_id"]:
        errors.append("first_event_ref mismatch")
    if manifest["last_event_ref"]["event_id"] != events[-1]["event_id"]:
        errors.append("last_event_ref mismatch")

    previous_hash = None
    expected_sequence = 1
    saw_authority_resolution = False
    for event in events:
        if event["sequence"] != expected_sequence:
            errors.append(f"sequence mismatch at {event['event_id']}")
        if event["integrity"].get("previous_event_hash") != previous_hash:
            errors.append(f"previous_event_hash mismatch at {event['event_id']}")
        expected = event_hash(event)
        if event["integrity"]["event_hash"] != expected:
            errors.append(f"event_hash mismatch at {event['event_id']}")
        if event["event_type"] in ("authority-granted", "authority-denied"):
            saw_authority_resolution = True
        if event["event_type"].startswith("capability-") and not saw_authority_resolution:
            errors.append("capability invocation missing authority coverage")
        if (
            event["classification"].get("replay_disposition")
            == "requires-fresh-authorization"
            and event["event_type"] in ("replay-materialized", "recovery-completed")
            and not event["governing_refs"].get("grant_bundle_ref")
        ):
            errors.append("replay event missing fresh grant")
        previous_hash = event["integrity"]["event_hash"]
        expected_sequence += 1

    state_name = runtime_state.get("state") or runtime_state.get("status")
    if runtime_state.get("source_ledger_ref") != manifest["ledger_ref"]:
        errors.append("runtime-state source_ledger_ref mismatch")
    if runtime_state.get("source_ledger_manifest_ref") != manifest["manifest_ref"]:
        errors.append("runtime-state source_ledger_manifest_ref mismatch")
    if runtime_state.get("last_applied_event_id") != events[-1]["event_id"]:
        errors.append("runtime-state last_applied_event_id mismatch")
    if runtime_state.get("last_applied_sequence") != events[-1]["sequence"]:
        errors.append("runtime-state last_applied_sequence mismatch")
    if runtime_state.get("last_applied_event_hash") != events[-1]["integrity"]["event_hash"]:
        errors.append("runtime-state last_applied_event_hash mismatch")
    if state_name != events[-1]["lifecycle"]["state_after"]:
        errors.append("runtime-state final state mismatch")

    evidence_events = case_dir / "evidence" / "run-journal" / "events.snapshot.ndjson"
    evidence_manifest = case_dir / "evidence" / "run-journal" / "events.manifest.snapshot.yml"
    if evidence_events.read_text() != (case_dir / "control" / "events.ndjson").read_text():
        errors.append("journal snapshot content mismatch")
    if evidence_manifest.read_text() != (case_dir / "control" / "events.manifest.yml").read_text():
        errors.append("manifest snapshot content mismatch")

    operator_view = case_dir / "generated" / "operator-view.yml"
    if operator_view.is_file():
        view = load_yaml(operator_view)
        if view.get("non_authority_classification") != "generated-run-journal-summary":
            errors.append("operator read model missing non-authority classification")
        if not view.get("source_refs"):
            errors.append("operator read model missing source refs")
        if "runtime" in view.get("forbidden_consumers", []):
            errors.append("operator read model forbidden consumer declaration regressed")
    return errors

def validate_negative(case_dir: Path):
    expectation = load_yaml(case_dir / "expectation.yml")
    failures = validate_positive(case_dir)
    expected_fragment = expectation["expected_failure_contains"]
    if not failures:
        return [f"negative case unexpectedly passed: expected {expected_fragment}"]
    if not any(expected_fragment in item for item in failures):
        return [
            f"negative case did not fail for expected reason '{expected_fragment}': {failures}"
        ]
    return []

def normalize_tier(value: str) -> str:
    if value in ("repo-local-consequential", "WT-2"):
        return "repo-consequential"
    return value

def validate_live_run_root(run_dir: Path):
    errors = []
    manifest_path = run_dir / "run-manifest.yml"
    state_path = run_dir / "runtime-state.yml"
    events_path = run_dir / "events.ndjson"
    ledger_path = run_dir / "events.manifest.yml"
    if not manifest_path.is_file() or not state_path.is_file():
        return errors
    manifest = load_yaml(manifest_path)
    tier = normalize_tier(
        manifest.get("support_tier")
        or manifest.get("support_target", {}).get("workload_tier")
        or ""
    )
    if tier != "repo-consequential":
        return errors
    if not events_path.is_file():
        errors.append("missing live run journal events.ndjson")
        return errors
    if not ledger_path.is_file():
        errors.append("missing live run journal events.manifest.yml")
        return errors
    ledger = load_yaml(ledger_path)
    state = load_yaml(state_path)
    if manifest.get("schema_version") != "run-manifest-v2":
        errors.append("run-manifest schema is not run-manifest-v2")
    if state.get("schema_version") != "runtime-state-v2":
        errors.append("runtime-state schema is not runtime-state-v2")
    if ledger.get("schema_version") != "run-event-ledger-v2":
        errors.append("journal manifest schema is not run-event-ledger-v2")
    events = load_events(events_path)
    if not events:
        errors.append("journal has no events")
        return errors
    if state.get("source_ledger_ref") != ledger.get("ledger_ref"):
        errors.append("runtime-state source_ledger_ref mismatch")
    if state.get("source_ledger_manifest_ref") != ledger.get("manifest_ref"):
        errors.append("runtime-state source_ledger_manifest_ref mismatch")
    if normalize_tier(manifest.get("support_target", {}).get("workload_tier", "")) != "repo-consequential":
        errors.append("run-manifest workload tier not normalized to repo-consequential")
    return errors

def validate_live_consequential_support_refs():
    errors = []
    dossier = load_yaml(
        repo_root
        / ".octon/instance/governance/support-dossiers/live/repo-shell-repo-consequential-en/dossier.yml"
    )
    proof = load_yaml(
        repo_root
        / ".octon/state/evidence/validation/support-targets/repo-shell-repo-consequential-en.yml"
    )
    dossier_refs = dossier.get("representative_retained_runs", [])
    proof_refs = proof.get("scenario_evidence", {}).get("representative_run_refs", [])
    if dossier_refs != proof_refs:
        errors.append("live consequential dossier/proof representative run refs drift")
    for ref in dossier_refs:
        run_dir = repo_root / Path(ref).parent
        run_errors = validate_live_run_root(run_dir)
        if run_errors:
            errors.extend(
                [f"{run_dir.name}: {item}" for item in run_errors]
            )
    return errors

failures = []
fixture_root = root / "fixture-runs"
for case_dir in sorted(p for p in fixture_root.iterdir() if p.is_dir()):
    case_failures = validate_positive(case_dir)
    if case_failures:
        failures.append((case_dir.name, case_failures))
    else:
        print(f"[OK] fixture run validated: {case_dir.name}")

negative_root = root / "negative-tests"
for case_dir in sorted(p for p in negative_root.iterdir() if p.is_dir()):
    case_failures = validate_negative(case_dir)
    if case_failures:
        failures.append((case_dir.name, case_failures))
    else:
        print(f"[OK] negative control failed closed: {case_dir.name}")

live_runs_root = repo_root / ".octon/state/control/execution/runs"
for run_dir in sorted(p for p in live_runs_root.iterdir() if p.is_dir()):
    case_failures = validate_live_run_root(run_dir)
    if case_failures:
        failures.append((run_dir.name, case_failures))
    elif case_failures == []:
        manifest = load_yaml(run_dir / "run-manifest.yml") if (run_dir / "run-manifest.yml").is_file() else {}
        tier = normalize_tier(
            manifest.get("support_tier")
            or manifest.get("support_target", {}).get("workload_tier")
            or ""
        )
        if tier == "repo-consequential":
            print(f"[OK] live consequential run root validated: {run_dir.name}")

support_failures = validate_live_consequential_support_refs()
if support_failures:
    failures.append(("live-consequential-support-refs", support_failures))
else:
    print("[OK] live consequential support refs use normalized journal-backed run roots")

if failures:
    for name, items in failures:
        for item in items:
            print(f"[ERROR] {name}: {item}")
    sys.exit(1)
PY
status=$?
if [[ $status -ne 0 ]]; then
  errors=$((errors + 1))
fi

echo "Validation summary: errors=$errors"
[[ "$errors" -eq 0 ]]
