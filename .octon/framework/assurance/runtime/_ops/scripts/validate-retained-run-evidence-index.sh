#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_ROOT="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
ROOT_DIR="${OCTON_ROOT_DIR:-$DEFAULT_ROOT}"
INDEX_PATH=""

usage() {
  cat <<'EOF'
Usage:
  validate-retained-run-evidence-index.sh --index <index.yml|json> [--root <repo-root>]

Validates a retained-run evidence index as discovery-only retained evidence.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)
      ROOT_DIR="$2"
      shift 2
      ;;
    --index)
      INDEX_PATH="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[ERROR] unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "$INDEX_PATH" ]]; then
  echo "[ERROR] missing --index" >&2
  usage >&2
  exit 2
fi

python3 - "$ROOT_DIR" "$INDEX_PATH" <<'PY'
import hashlib
import json
import pathlib
import re
import subprocess
import sys

root = pathlib.Path(sys.argv[1]).resolve()
raw_index = pathlib.Path(sys.argv[2])
index_path = raw_index if raw_index.is_absolute() else root / raw_index

errors = []

SHA_RE = re.compile(r"^sha256:[0-9a-f]{64}$")

def fail(message):
    errors.append(message)
    print(f"[ERROR] {message}")

def ok(message):
    print(f"[OK] {message}")

def load_data(path):
    result = subprocess.run(
        ["yq", "-o=json", ".", str(path)],
        text=True,
        capture_output=True,
        check=False,
    )
    if result.returncode != 0:
        fail(f"failed to parse index: {path}: {result.stderr.strip()}")
        return {}
    try:
        return json.loads(result.stdout or "{}")
    except json.JSONDecodeError as exc:
        fail(f"failed to decode index JSON: {path}: {exc}")
        return {}

def resolve_ref(ref):
    path = pathlib.Path(ref)
    return path if path.is_absolute() else root / path

def sha256(path):
    return "sha256:" + hashlib.sha256(path.read_bytes()).hexdigest()

def require_bool(value, expected, label):
    if value is expected:
        ok(label)
    else:
        fail(f"{label} must be {expected!r}")

def require_equal(value, expected, label):
    if value == expected:
        ok(label)
    else:
        fail(f"{label} must be {expected!r}")

if index_path.is_file():
    ok("retained-run evidence index exists")
else:
    fail(f"retained-run evidence index missing: {index_path}")

index = load_data(index_path) if index_path.is_file() else {}

require_equal(index.get("schema_version"), "retained-run-evidence-index-v1", "schema version")

subject = index.get("subject") or {}
for key in ("run_id", "lifecycle_kind", "terminal_status"):
    if subject.get(key):
        ok(f"subject {key} present")
    else:
        fail(f"subject {key} missing")

posture = index.get("evidence_posture") or {}
require_equal(posture.get("purpose"), "discovery-and-replay-aid", "evidence posture purpose")
if posture.get("freshness_state") in {"digest-bound", "freshness-checked"}:
    ok("evidence posture freshness state valid")
else:
    fail("evidence posture freshness_state must be digest-bound or freshness-checked")
direct_declared = posture.get("direct_control_refs_present")
if isinstance(direct_declared, bool):
    ok("direct_control_refs_present is explicit")
else:
    fail("direct_control_refs_present must be boolean")
    direct_declared = False

freshness = index.get("freshness") or {}
require_equal(freshness.get("source_digest_required"), True, "freshness requires source digests")
require_equal(freshness.get("stale_behavior"), "fail-closed", "freshness stale behavior")

boundary = index.get("authority_boundary") or {}
expected_boundary = {
    "replaces_source_evidence": False,
    "authorizes_execution": False,
    "satisfies_lifecycle_transition_authority": False,
    "satisfies_child_receipts": False,
    "proposal_input_authority": "non-authoritative",
    "generated_output_authority": "derived-only",
    "raw_evidence_retained": True,
}
for key, expected in expected_boundary.items():
    if isinstance(expected, bool):
        require_bool(boundary.get(key), expected, f"authority boundary {key}")
    else:
        require_equal(boundary.get(key), expected, f"authority boundary {key}")

control_refs = index.get("control_refs") or []
substitute_refs = index.get("substitute_workflow_refs") or []
if direct_declared:
    if control_refs:
        ok("direct control refs are present")
    else:
        fail("direct_control_refs_present is true but control_refs is empty")
else:
    if substitute_refs:
        ok("substitute retained workflow refs are present")
    else:
        fail("direct control refs absent and substitute_workflow_refs is empty")

terminal = index.get("terminal_evidence_refs") or {}
for key in ("validation", "rollback"):
    refs = terminal.get(key) or []
    if refs:
        ok(f"terminal evidence refs include {key}")
    else:
        fail(f"terminal evidence refs missing required {key}")

indexed_refs = list(index.get("indexed_refs") or [])
indexed_by_ref = {}
for record in indexed_refs:
    ref = record.get("ref")
    if ref:
        indexed_by_ref.setdefault(ref, record)

def iter_nested_refs():
    for source_name, records in (
        ("control_refs", control_refs),
        ("substitute_workflow_refs", substitute_refs),
    ):
        for record in records:
            yield source_name, record
    for role, records in terminal.items():
        if isinstance(records, list):
            for record in records:
                yield f"terminal_evidence_refs.{role}", record

for source_name, record in iter_nested_refs():
    ref = record.get("ref")
    if not ref:
        fail(f"{source_name} entry missing ref")
        continue
    if ref in indexed_by_ref:
        ok(f"{source_name} ref appears in indexed_refs: {ref}")
    else:
        fail(f"{source_name} ref missing from indexed_refs: {ref}")

for record in indexed_refs:
    ref = record.get("ref")
    role = record.get("role") or "<missing-role>"
    ref_class = record.get("ref_class")
    authority_use = record.get("authority_use")
    digest = record.get("sha256")
    if not ref:
        fail(f"indexed ref {role} missing ref")
        continue
    if not SHA_RE.match(str(digest or "")):
        fail(f"indexed ref digest shape invalid: {ref}")
        continue
    path = resolve_ref(ref)
    if not path.is_file():
        fail(f"indexed ref missing: {ref}")
        continue
    actual_sha = sha256(path)
    if digest == actual_sha:
        ok(f"indexed ref digest matches: {ref}")
    else:
        fail(f"indexed ref digest mismatch: {ref}")

    if ref_class == "control":
        if authority_use == "control-truth":
            ok(f"control ref authority use is explicit: {ref}")
        else:
            fail(f"control ref authority_use must be control-truth: {ref}")
    elif ref_class in {"retained-evidence", "retained-workflow-evidence"}:
        if authority_use == "evidence-only":
            ok(f"retained evidence ref is evidence-only: {ref}")
        else:
            fail(f"retained evidence ref authority_use must be evidence-only: {ref}")
    elif ref_class == "generated":
        if authority_use == "derived-only":
            ok(f"generated ref is derived-only: {ref}")
        else:
            fail(f"generated ref must be derived-only and cannot claim authority: {ref}")
    elif ref_class == "proposal-local":
        if authority_use == "non-authoritative":
            ok(f"proposal-local ref is non-authoritative: {ref}")
        else:
            fail(f"proposal-local ref must be non-authoritative: {ref}")
    else:
        fail(f"indexed ref class invalid: {ref}")

    ref_text = str(ref)
    if ref_text.startswith(".octon/generated/") and authority_use != "derived-only":
        fail(f"generated path claims non-derived authority: {ref}")
    if ref_text.startswith(".octon/inputs/") and authority_use != "non-authoritative":
        fail(f"proposal/input path claims authority: {ref}")

failure_behavior = index.get("failure_behavior") or []
required_failures = {
    "fail-closed-on-source-missing",
    "fail-closed-on-source-digest-mismatch",
    "fail-closed-on-authority-boundary-conflict",
}
for required in required_failures:
    if required in failure_behavior:
        ok(f"failure behavior includes {required}")
    else:
        fail(f"failure behavior missing {required}")

print(f"Validation summary: errors={len(errors)}")
if errors:
    sys.exit(1)
PY
