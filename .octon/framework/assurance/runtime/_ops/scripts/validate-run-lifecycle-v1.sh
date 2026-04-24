#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
DEFAULT_FIXTURES_ROOT="$OCTON_DIR/framework/assurance/runtime/_ops/fixtures/run-lifecycle-v1"
DEFAULT_EVIDENCE_ROOT="$OCTON_DIR/state/evidence/validation/assurance/run-lifecycle-v1"
VALIDATOR_REF=".octon/framework/assurance/runtime/_ops/scripts/validate-run-lifecycle-v1.sh"
JOURNAL_APPEND_BOUNDARY_GUARD_REF=".octon/framework/assurance/runtime/_ops/scripts/validate-run-journal-append-boundary.sh"
JOURNAL_APPEND_BOUNDARY_GUARD_PATH="$ROOT_DIR/$JOURNAL_APPEND_BOUNDARY_GUARD_REF"
JOURNAL_APPEND_BOUNDARY_GUARD_STATUS="skipped"

if [[ "${OCTON_SKIP_RUN_JOURNAL_APPEND_BOUNDARY:-0}" != "1" ]]; then
    bash "$JOURNAL_APPEND_BOUNDARY_GUARD_PATH"
    JOURNAL_APPEND_BOUNDARY_GUARD_STATUS="pass"
fi

python3 - "$ROOT_DIR" "$DEFAULT_FIXTURES_ROOT" "$DEFAULT_EVIDENCE_ROOT" "$VALIDATOR_REF" "$JOURNAL_APPEND_BOUNDARY_GUARD_REF" "$JOURNAL_APPEND_BOUNDARY_GUARD_STATUS" "$@" <<'PY'
import argparse
import hashlib
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

import yaml

ROOT_DIR = Path(sys.argv[1])
DEFAULT_FIXTURES_ROOT = Path(sys.argv[2])
DEFAULT_EVIDENCE_ROOT = Path(sys.argv[3])
VALIDATOR_REF = sys.argv[4]
JOURNAL_APPEND_BOUNDARY_GUARD_REF = sys.argv[5]
JOURNAL_APPEND_BOUNDARY_GUARD_STATUS = sys.argv[6]
ARGV = sys.argv[7:]

EXPECTED_TRANSITIONS = {
    "draft": {"bound", "denied"},
    "bound": {"authorized", "staged", "denied"},
    "authorized": {"running", "staged", "revoked", "denied"},
    "running": {"paused", "failed", "revoked", "succeeded", "staged"},
    "paused": {"running", "revoked", "failed"},
    "staged": {"authorized", "revoked", "closed"},
    "revoked": {"rolled_back", "closed"},
    "failed": {"rolled_back", "closed"},
    "rolled_back": {"closed"},
    "succeeded": {"closed"},
    "denied": {"closed"},
    "closed": set(),
}

STATE_ALIASES = {
    "stage_only": "staged",
    "stage-only": "staged",
}

CLOSEOUT_REQUIRED = {
    "evidence_store_completeness",
    "journal_snapshot",
    "rollback_posture",
    "run_card",
    "review_dispositions",
    "risk_disposition",
}

TRANSITION_REQUIREMENTS = {
    ("draft", "bound"): {"run_contract", "run_manifest", "runtime_state", "rollback_posture", "bound_checkpoint"},
    ("draft", "denied"): {"denial_receipt"},
    ("bound", "authorized"): {"decision_artifact", "grant_bundle", "context_pack"},
    ("bound", "staged"): {"stage_only_decision"},
    ("bound", "denied"): {"denial_receipt"},
    ("authorized", "running"): {"stage_attempt", "effect_token"},
    ("authorized", "staged"): {"stage_only_decision"},
    ("authorized", "revoked"): {"revocation_ref"},
    ("authorized", "denied"): {"denial_receipt"},
    ("running", "paused"): {"checkpoint", "pause_receipt"},
    ("paused", "running"): {"grant_bundle", "context_pack", "resume_receipt"},
    ("running", "failed"): {"failure_receipt", "rollback_posture"},
    ("running", "revoked"): {"revocation_ref", "rollback_posture"},
    ("running", "succeeded"): {"retained_evidence"},
    ("running", "staged"): {"stage_only_decision", "retained_evidence"},
    ("staged", "authorized"): {"decision_artifact", "grant_bundle", "context_pack"},
    ("staged", "revoked"): {"revocation_ref"},
    ("staged", "closed"): CLOSEOUT_REQUIRED,
    ("revoked", "rolled_back"): {"rollback_evidence", "rollback_posture"},
    ("revoked", "closed"): CLOSEOUT_REQUIRED,
    ("failed", "rolled_back"): {"rollback_evidence", "rollback_posture"},
    ("failed", "closed"): CLOSEOUT_REQUIRED,
    ("rolled_back", "closed"): CLOSEOUT_REQUIRED,
    ("succeeded", "closed"): CLOSEOUT_REQUIRED,
    ("denied", "closed"): CLOSEOUT_REQUIRED,
}

CONTROL_REFS = {
    "run_contract",
    "run_manifest",
    "runtime_state",
    "rollback_posture",
    "bound_checkpoint",
    "decision_artifact",
    "grant_bundle",
    "stage_attempt",
    "effect_token",
    "review_dispositions",
    "risk_disposition",
    "checkpoint",
    "stage_only_decision",
}

RUN_EVIDENCE_REFS = {
    "context_pack",
    "retained_evidence",
    "pause_receipt",
    "resume_receipt",
    "failure_receipt",
    "rollback_evidence",
    "denial_receipt",
    "revocation_ref",
    "evidence_store_completeness",
    "journal_snapshot",
}

DISCLOSURE_REFS = {"run_card"}
GENERATED_REFS = {"operator_view"}


def normalize_repo_ref(ref_value):
    if not isinstance(ref_value, str):
        return ref_value
    return ref_value.replace("{ROOT_DIR}", str(ROOT_DIR))


def repo_relative_for_boundary(ref_value):
    ref_value = normalize_repo_ref(ref_value)
    root_prefix = str(ROOT_DIR) + "/"
    if ref_value.startswith(root_prefix):
        return ref_value[len(root_prefix):]
    return ref_value


def stage_only_signal(value):
    return str(value).strip().lower().replace("-", "_").replace(" ", "_") in {
        "stage_only",
        "stageonly",
        "escalate",
        "escalation",
        "stage_only_escalation",
    }


def parse_args():
    parser = argparse.ArgumentParser(description="Validate run-lifecycle-v1 assurance fixtures.")
    parser.add_argument("--fixtures-root", default=str(DEFAULT_FIXTURES_ROOT))
    parser.add_argument("--fixture-set", default=None)
    parser.add_argument("--transition-matrix", default=None)
    parser.add_argument("--evidence-root", default=str(DEFAULT_EVIDENCE_ROOT))
    parser.add_argument("--case", action="append", default=[])
    parser.add_argument("--no-report", action="store_true")
    return parser.parse_args(ARGV)


def load_yaml(path):
    with Path(path).open("r", encoding="utf-8") as handle:
        return yaml.safe_load(handle)


def normalize_state(state):
    return STATE_ALIASES.get(state, state)


def validate_known_state(raw_state, normalized_state, failures, context):
    if normalized_state not in EXPECTED_TRANSITIONS:
        failures.append(f"{context} unknown lifecycle state: {raw_state}")


def canonical_hash(event):
    payload = {key: value for key, value in event.items() if key != "event_hash"}
    encoded = json.dumps(payload, sort_keys=True, separators=(",", ":"), ensure_ascii=True).encode("utf-8")
    return "sha256:" + hashlib.sha256(encoded).hexdigest()


def derived_refs(run_id):
    control_root = f".octon/state/control/execution/runs/{run_id}"
    evidence_root = f".octon/state/evidence/runs/{run_id}"
    disclosure_root = f".octon/state/evidence/disclosure/runs/{run_id}"
    return {
        "run_contract": f"{control_root}/run-contract.yml",
        "run_manifest": f"{control_root}/run-manifest.yml",
        "runtime_state": f"{control_root}/runtime-state.yml",
        "rollback_posture": f"{control_root}/rollback-posture.yml",
        "bound_checkpoint": f"{control_root}/checkpoints/bound.yml",
        "decision_artifact": f"{control_root}/authority/decision.yml",
        "grant_bundle": f"{control_root}/authority/grant-bundle.yml",
        "stage_attempt": f"{control_root}/stage-attempts/initial.yml",
        "effect_token": f"{control_root}/effect-tokens/effect-token-fixture.yml",
        "review_dispositions": f"{control_root}/authority/review-dispositions.yml",
        "risk_disposition": f"{control_root}/authority/review-dispositions.yml",
        "checkpoint": f"{control_root}/checkpoints/pause.yml",
        "context_pack": f"{evidence_root}/context/context-pack-receipt.yml",
        "retained_evidence": f"{evidence_root}/retained-run-evidence.yml",
        "pause_receipt": f"{evidence_root}/receipts/pause.yml",
        "resume_receipt": f"{evidence_root}/receipts/resume.yml",
        "failure_receipt": f"{evidence_root}/receipts/failure.yml",
        "rollback_evidence": f"{evidence_root}/rollback/rollback-complete.yml",
        "stage_only_decision": f"{control_root}/authority/stage-only-decision.yml",
        "denial_receipt": f"{evidence_root}/receipts/denial.yml",
        "revocation_ref": f"{evidence_root}/receipts/revocation.yml",
        "evidence_store_completeness": f"{evidence_root}/closeout/evidence-store-completeness.yml",
        "journal_snapshot": f"{evidence_root}/run-journal/events.snapshot.ndjson",
        "run_card": f"{disclosure_root}/run-card.yml",
        "operator_view": f".octon/generated/cognition/projections/materialized/runs/{run_id}.yml",
    }


def expected_prefix(ref_key, run_id):
    if ref_key in CONTROL_REFS:
        return f".octon/state/control/execution/runs/{run_id}/"
    if ref_key in RUN_EVIDENCE_REFS:
        return f".octon/state/evidence/runs/{run_id}/"
    if ref_key in DISCLOSURE_REFS:
        return f".octon/state/evidence/disclosure/runs/{run_id}/"
    if ref_key in GENERATED_REFS:
        return ".octon/generated/"
    return None


def materialize_events(case, run_id):
    events = []
    previous_hash = None
    for index, transition in enumerate(case.get("transitions", []), start=1):
        state_before = transition["from"]
        state_after = transition["to"]
        event = {
            "sequence": index,
            "event_id": f"{run_id}-evt-{index:03d}-{transition['operation_id']}",
            "operation_id": transition["operation_id"],
            "state_before": state_before,
            "state_after": state_after,
            "required_refs": list(transition.get("required_refs", [])),
            "previous_event_hash": previous_hash,
        }
        for key in ("material_effect", "effect_token_ref", "authority_source_ref"):
            if key in transition:
                event[key] = transition[key]
        event["event_hash"] = canonical_hash(event)
        previous_hash = event["event_hash"]
        events.append(event)
    return events


def validate_transition_matrix(matrix):
    failures = []
    declared = matrix.get("allowed_transitions", {})
    for state, allowed in EXPECTED_TRANSITIONS.items():
        actual = {normalize_state(item) for item in declared.get(state, [])}
        if actual != allowed:
            failures.append(f"transition matrix mismatch for {state}: expected {sorted(allowed)}, got {sorted(actual)}")
    extra_states = set(declared) - set(EXPECTED_TRANSITIONS)
    if extra_states:
        failures.append(f"transition matrix declares unknown states: {sorted(extra_states)}")
    for item in matrix.get("invalid_transition_controls", []):
        before = normalize_state(item.get("from"))
        after = normalize_state(item.get("to"))
        if after in EXPECTED_TRANSITIONS.get(before, set()):
            failures.append(f"invalid transition control is actually allowed: {before} -> {after}")
    return failures


def validate_ref_boundary(ref_key, ref_value, run_id, failures, context):
    expected = expected_prefix(ref_key, run_id)
    if expected is None:
        failures.append(f"{context} unknown required ref: {ref_key}")
        return
    ref_value = repo_relative_for_boundary(ref_value)
    if not ref_value.startswith(expected):
        failures.append(f"{context} boundary violation for {ref_key}: expected prefix {expected}")


def validate_case(case):
    failures = []
    case_id = case["case_id"]
    run_id = case.get("run_id", f"fixture-{case_id}")
    refs = derived_refs(run_id)
    refs.update({key: normalize_repo_ref(value) for key, value in case.get("refs", {}).items()})
    missing = set(case.get("missing_artifacts", []))
    invalid = set(case.get("invalid_artifacts", []))
    ref_postures = case.get("ref_postures", {})
    artifacts_present = set(refs) - missing
    events = materialize_events(case, run_id)

    if not events:
        failures.append("journal has no events")
        return failures, {}

    current_state = "draft"
    previous_hash = None
    for expected_sequence, event in enumerate(events, start=1):
        event_id = event["event_id"]
        raw_before = event["state_before"]
        raw_after = event["state_after"]
        before = normalize_state(raw_before)
        after = normalize_state(raw_after)
        context = f"{case_id}:{event_id}"
        validate_known_state(raw_before, before, failures, context)
        validate_known_state(raw_after, after, failures, context)

        if event["sequence"] != expected_sequence:
            failures.append(f"{context} sequence mismatch")
        if event["previous_event_hash"] != previous_hash:
            failures.append(f"{context} previous hash mismatch")
        expected_hash = canonical_hash(event)
        if event["event_hash"] != expected_hash:
            failures.append(f"{context} event hash mismatch")
        if before != current_state:
            failures.append(f"{context} journal rebuild state mismatch: expected {current_state}, got {before}")
        if after not in EXPECTED_TRANSITIONS.get(before, set()):
            failures.append(f"invalid transition {before} -> {after}")

        declared_refs = set(event.get("required_refs", []))
        required_refs = TRANSITION_REQUIREMENTS.get((before, after), set())
        for ref_key in sorted(required_refs):
            if ref_key not in declared_refs:
                failures.append(f"{before}->{after} missing precondition ref: {ref_key}")
        for ref_key in sorted(declared_refs | required_refs):
            if ref_key not in refs:
                failures.append(f"{context} missing required ref: {ref_key}")
                continue
            if ref_key not in artifacts_present:
                failures.append(f"{context} required artifact not present: {ref_key}")
            if ref_key in invalid:
                failures.append(f"{context} required artifact invalid: {ref_key}")
            validate_ref_boundary(ref_key, refs[ref_key], run_id, failures, context)
            if ref_key == "stage_only_decision" and not stage_only_signal(ref_postures.get(ref_key, "stage_only")):
                failures.append(f"{context} stage_only_decision is not stage-only or escalation")

        if event.get("material_effect"):
            if before != "running":
                failures.append("material effect outside running")
            token_key = event.get("effect_token_ref")
            token = case.get("effect_tokens", {}).get(token_key, {})
            if not token_key or token_key not in declared_refs:
                failures.append(f"{context} material effect missing effect token ref")
            if token.get("status", "valid") != "valid":
                failures.append(f"{context} effect token is not valid")
            if normalize_state(token.get("state_scope", "")) != "running":
                failures.append(f"{context} effect token is not scoped to running")
            if token.get("single_use") and token.get("consumed_by_event_id") not in (event_id, None):
                failures.append(f"{context} effect token consumption target mismatch")

        authority_source_ref = event.get("authority_source_ref")
        if authority_source_ref:
            authority_path = repo_relative_for_boundary(refs.get(authority_source_ref, authority_source_ref))
            if authority_path.startswith(".octon/generated/") or authority_path.startswith(".octon/inputs/"):
                failures.append("generated or input source used as lifecycle authority")

        current_state = after
        previous_hash = event["event_hash"]

    journal = {
        "ledger_ref": f".octon/state/control/execution/runs/{run_id}/events.ndjson",
        "manifest_ref": f".octon/state/control/execution/runs/{run_id}/events.manifest.yml",
        "event_count": len(events),
        "first_event_id": events[0]["event_id"],
        "last_event_id": events[-1]["event_id"],
        "last_event_hash": events[-1]["event_hash"],
        "final_state": events[-1]["state_after"],
    }

    runtime_state = case.get("runtime_state", {})
    expected_runtime_state = {
        "state": journal["final_state"],
        "source_ledger_ref": journal["ledger_ref"],
        "source_ledger_manifest_ref": journal["manifest_ref"],
        "last_applied_event_id": journal["last_event_id"],
        "last_applied_sequence": journal["event_count"],
        "last_applied_event_hash": journal["last_event_hash"],
    }
    materialized_runtime_state = dict(expected_runtime_state)
    materialized_runtime_state.update(runtime_state)
    if normalize_state(materialized_runtime_state.get("state")) != normalize_state(expected_runtime_state["state"]):
        failures.append("runtime-state final state mismatch")
    for key in (
        "source_ledger_ref",
        "source_ledger_manifest_ref",
        "last_applied_event_id",
        "last_applied_sequence",
        "last_applied_event_hash",
    ):
        if materialized_runtime_state.get(key) != expected_runtime_state[key]:
            failures.append(f"runtime-state {key} mismatch")
    if materialized_runtime_state.get("drift_status", "in-sync") != "in-sync":
        failures.append("runtime-state drift_status is not in-sync")

    if journal["final_state"] == "closed":
        closeout_refs = set(case.get("closeout", {}).get("required_refs", CLOSEOUT_REQUIRED))
        for ref_key in sorted(CLOSEOUT_REQUIRED):
            if ref_key not in closeout_refs:
                failures.append(f"closeout missing required ref: {ref_key}")
            if ref_key not in artifacts_present:
                failures.append(f"closeout required artifact not present: {ref_key}")
            if ref_key in invalid:
                failures.append(f"closeout required artifact invalid: {ref_key}")
        risk = case.get("closeout", {}).get("risk_disposition", {})
        unresolved_risk_count = int(risk.get("unresolved_risk_count", 0) or 0)
        risk_status = str(risk.get("status", "resolved"))
        if unresolved_risk_count > 0 and risk_status not in {"accepted", "resolved"}:
            failures.append("closeout unresolved blocking risk")

    operator_view = case.get("generated_operator_view")
    if operator_view:
        ref_key = operator_view.get("ref_key", "operator_view")
        ref_value = refs.get(ref_key, "")
        validate_ref_boundary(ref_key, ref_value, run_id, failures, f"{case_id}:operator-view")
        if operator_view.get("non_authority_classification") != "generated-run-lifecycle-summary":
            failures.append("operator read model missing lifecycle non-authority classification")
        forbidden = set(operator_view.get("forbidden_consumers", []))
        if not {"runtime", "policy", "authority"}.issubset(forbidden):
            failures.append("operator read model missing forbidden runtime/policy/authority consumers")
        if not operator_view.get("source_refs"):
            failures.append("operator read model missing source refs")

    coverage = set(case.get("coverage", []))
    summary = {
        "case_id": case_id,
        "expectation": case.get("expectation", "pass"),
        "coverage": sorted(coverage),
        "reconstructed_state": journal["final_state"],
        "latest_sequence": journal["event_count"],
        "latest_hash": journal["last_event_hash"],
        "failures": failures,
    }
    return failures, summary


def report_semantics(report):
    semantic = dict(report or {})
    semantic.pop("generated_at", None)
    return semantic


def render_report_markdown(report):
    lines = [
        "# Run Lifecycle v1 Validation Report",
        "",
        f"- status: `{report['status']}`",
        f"- validator: `{report['validator_ref']}`",
        f"- fixture_set: `{report['fixture_set_ref']}`",
        f"- generated_at: `{report['generated_at']}`",
        f"- journal_append_boundary_guard: `{report['journal_append_boundary_guard']['status']}`",
        "",
        "## Coverage",
    ]
    for item in report["coverage"]:
        lines.append(f"- {item}")
    lines.extend(["", "## Cases"])
    for case in report["cases"]:
        lines.append(f"- `{case['case_id']}`: {case['outcome']} ({case['reconstructed_state']})")
    return "\n".join(lines) + "\n"


def write_if_changed(path, content):
    if path.is_file() and path.read_text(encoding="utf-8") == content:
        return
    path.write_text(content, encoding="utf-8")


def write_reports(evidence_root, report):
    evidence_root.mkdir(parents=True, exist_ok=True)
    yml_path = evidence_root / "validation-report.yml"
    md_path = evidence_root / "validation-report.md"
    if yml_path.is_file():
        existing = load_yaml(yml_path)
        if report_semantics(existing) == report_semantics(report):
            report["generated_at"] = existing.get("generated_at", report["generated_at"])

    yml_content = yaml.safe_dump(report, sort_keys=False, width=120)
    md_content = render_report_markdown(report)
    write_if_changed(yml_path, yml_content)
    write_if_changed(md_path, md_content)


def main():
    args = parse_args()
    fixtures_root = Path(args.fixtures_root)
    fixture_set_path = Path(args.fixture_set) if args.fixture_set else fixtures_root / "lifecycle-fixtures.yml"
    transition_matrix_path = Path(args.transition_matrix) if args.transition_matrix else fixtures_root / "transition-matrix.yml"
    evidence_root = Path(args.evidence_root)

    fixture_set = load_yaml(fixture_set_path)
    matrix = load_yaml(transition_matrix_path)

    selected_cases = set(args.case)
    matrix_failures = validate_transition_matrix(matrix)
    report_cases = []
    coverage = set()
    unexpected_failures = list(matrix_failures)
    if JOURNAL_APPEND_BOUNDARY_GUARD_STATUS == "pass":
        coverage.add("journal-append-boundary")

    for case in fixture_set.get("cases", []):
        if selected_cases and case["case_id"] not in selected_cases:
            continue
        failures, summary = validate_case(case)
        expectation = case.get("expectation", "pass")
        coverage.update(summary["coverage"])
        expected_fragment = case.get("expected_failure_contains", "")

        if expectation == "pass":
            if failures:
                outcome = "fail"
                unexpected_failures.extend(f"{case['case_id']}: {failure}" for failure in failures)
            else:
                outcome = "pass"
        else:
            if not failures:
                outcome = "unexpected-pass"
                unexpected_failures.append(f"{case['case_id']}: negative case unexpectedly passed")
            elif expected_fragment and not any(expected_fragment in failure for failure in failures):
                outcome = "wrong-failure"
                unexpected_failures.append(
                    f"{case['case_id']}: expected failure containing '{expected_fragment}', got {failures}"
                )
            else:
                outcome = "expected-fail-closed"

        report_case = dict(summary)
        report_case["outcome"] = outcome
        report_cases.append(report_case)

    required_coverage = {
        "positive-transitions",
        "invalid-transitions-fail-closed",
        "journal-derived-runtime-state",
        "closeout-completeness",
        "boundary-composition",
        "unknown-state-fail-closed",
        "journal-append-boundary",
    }
    missing_coverage = sorted(required_coverage - coverage)
    if not selected_cases:
        for item in missing_coverage:
            unexpected_failures.append(f"missing required lifecycle coverage: {item}")

    lab_scenario_ref = fixture_set.get("lab_scenario_ref", "")
    if lab_scenario_ref:
        scenario_path = ROOT_DIR / lab_scenario_ref
        if not scenario_path.is_file():
            unexpected_failures.append(f"missing lab scenario ref: {lab_scenario_ref}")

    status = "fail" if unexpected_failures else "pass"
    report = {
        "schema_version": "run-lifecycle-v1-validation-report",
        "status": status,
        "validator_ref": VALIDATOR_REF,
        "fixture_set_ref": str(fixture_set_path.relative_to(ROOT_DIR) if fixture_set_path.is_absolute() and ROOT_DIR in fixture_set_path.parents else fixture_set_path),
        "transition_matrix_ref": str(transition_matrix_path.relative_to(ROOT_DIR) if transition_matrix_path.is_absolute() and ROOT_DIR in transition_matrix_path.parents else transition_matrix_path),
        "lab_scenario_ref": lab_scenario_ref,
        "generated_at": datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z"),
        "journal_append_boundary_guard": {
            "status": JOURNAL_APPEND_BOUNDARY_GUARD_STATUS,
            "validator_ref": JOURNAL_APPEND_BOUNDARY_GUARD_REF,
        },
        "coverage": sorted(coverage),
        "required_coverage": sorted(required_coverage),
        "matrix_failures": matrix_failures,
        "unexpected_failures": unexpected_failures,
        "cases": report_cases,
    }

    if not args.no_report:
        write_reports(evidence_root, report)

    for case in report_cases:
        if case["outcome"] == "pass":
            print(f"[OK] {case['case_id']} reconstructed {case['reconstructed_state']}")
        elif case["outcome"] == "expected-fail-closed":
            print(f"[OK] {case['case_id']} failed closed")
        else:
            print(f"[ERROR] {case['case_id']} {case['outcome']}")
    for failure in unexpected_failures:
        print(f"[ERROR] {failure}")
    print(f"Validation summary: status={status} cases={len(report_cases)}")
    return 0 if status == "pass" else 1


if __name__ == "__main__":
    raise SystemExit(main())
PY
