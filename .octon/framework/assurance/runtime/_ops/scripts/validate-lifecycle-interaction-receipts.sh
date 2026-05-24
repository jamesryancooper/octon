#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
FRAMEWORK_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
OCTON_DIR="$(cd -- "$FRAMEWORK_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

REQUEST_PATH=""
RETURN_PATH=""
SELF_TEST=0

usage() {
  cat <<'EOF'
usage:
  validate-lifecycle-interaction-receipts.sh --request <json> [--root <repo-root>]
  validate-lifecycle-interaction-receipts.sh --return <json> [--root <repo-root>]
  validate-lifecycle-interaction-receipts.sh --self-test
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --request)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      REQUEST_PATH="$1"
      ;;
    --return)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      RETURN_PATH="$1"
      ;;
    --root)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      ROOT_DIR="$(cd -- "$1" && pwd)"
      ;;
    --self-test)
      SELF_TEST=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
  shift
done

if [[ "$SELF_TEST" -eq 1 ]]; then
  python3 - "$ROOT_DIR" <<'PY'
import copy
import hashlib
import json
import os
import pathlib
import subprocess
import sys
import tempfile

repo_root = pathlib.Path(sys.argv[1])
script = repo_root / ".octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-interaction-receipts.sh"

def sha(path):
    return "sha256:" + hashlib.sha256(path.read_bytes()).hexdigest()

def boundary_digest(include_paths, exclude_paths):
    payload = json.dumps(
        {"include_paths": include_paths, "exclude_paths": exclude_paths},
        sort_keys=True,
        separators=(",", ":"),
    ).encode()
    return "sha256:" + hashlib.sha256(payload).hexdigest()

def write(path, value):
    path.write_text(json.dumps(value, indent=2) + "\n")

def expect(label, args, ok):
    result = subprocess.run(["bash", str(script), *args], cwd=root, text=True, capture_output=True)
    if (result.returncode == 0) != ok:
        sys.stderr.write(result.stdout)
        sys.stderr.write(result.stderr)
        raise SystemExit(f"self-test failed: {label}")
    print(f"PASS: {label}")

with tempfile.TemporaryDirectory(prefix="octon-lifecycle-interaction-") as tmp:
    root = pathlib.Path(tmp)
    evidence = root / ".octon/state/evidence/example.txt"
    evidence.parent.mkdir(parents=True)
    evidence.write_text("evidence\n")
    include_paths = [".octon/framework/product/contracts"]
    exclude_paths = [".octon/generated"]
    request = {
        "schema_version": "lifecycle-interaction-request-v1",
        "interaction_id": "lifecycle-interaction-test",
        "created_at": "2026-05-24T00:00:00Z",
        "source": {
            "lifecycle_id": "proposal-packet",
            "run_id": "run-1",
            "atomic_unit_type": "proposal-packet",
            "target_ref": ".octon/inputs/exploratory/proposals/architecture/example",
            "phase_id": "closeout-and-hygiene",
        },
        "request": {
            "interaction_profile": "handoff",
            "interaction_kind": "follow_on_work_required",
            "requested_capability": "change-closeout",
            "requested_lifecycle_id": "change-closeout",
            "requested_route_surface": "closeout-change",
            "requested_atomic_unit_type": "change",
            "requested_target_outcome": "cleaned",
        },
        "scope": {
            "include_paths": include_paths,
            "exclude_paths": exclude_paths,
            "boundary_digest": boundary_digest(include_paths, exclude_paths),
        },
        "evidence_offered": [
            {
                "ref": ".octon/state/evidence/example.txt",
                "digest": sha(evidence),
                "acceptance_class": "validation-evidence",
            }
        ],
        "authority_boundary": {
            "forbidden_transfer": [
                "git-ref-mutation",
                "hosted-provider-authorization",
                "branch-cleanup-authorization",
                "archive-authorization",
                "promotion-authorization",
                "scope-expansion",
            ]
        },
        "stop_conditions": ["target-gate-missing"],
        "expected_return_evidence": ["change-receipt-v1"],
    }
    valid_request = root / "valid-request.json"
    write(valid_request, request)
    expect("valid interaction request passes", ["--root", str(root), "--request", str(valid_request)], True)

    dangling = copy.deepcopy(request)
    dangling["evidence_offered"][0]["ref"] = ".octon/state/evidence/missing.txt"
    dangling_path = root / "dangling-request.json"
    write(dangling_path, dangling)
    expect("dangling evidence refs fail", ["--root", str(root), "--request", str(dangling_path)], False)

    stale = copy.deepcopy(request)
    stale["evidence_offered"][0]["digest"] = "sha256:" + ("0" * 64)
    stale_path = root / "stale-request.json"
    write(stale_path, stale)
    expect("stale evidence refs fail", ["--root", str(root), "--request", str(stale_path)], False)

    widened = copy.deepcopy(request)
    widened["scope"]["include_paths"].append(".octon/framework/engine")
    widened_path = root / "scope-widened-request.json"
    write(widened_path, widened)
    expect("scope widening fails", ["--root", str(root), "--request", str(widened_path)], False)

    forbidden = copy.deepcopy(request)
    forbidden["authority_boundary"]["forbidden_transfer"].remove("promotion-authorization")
    forbidden_path = root / "forbidden-transfer-request.json"
    write(forbidden_path, forbidden)
    expect("forbidden authority transfer fails", ["--root", str(root), "--request", str(forbidden_path)], False)

    returned = {
        "schema_version": "lifecycle-interaction-return-v1",
        "interaction_id": "lifecycle-interaction-test",
        "consumer": {"lifecycle_id": "change-closeout", "run_id": "run-2"},
        "outcome": {"completed": True, "lifecycle_outcome": "cleaned", "blocker": None},
        "return_evidence_refs": [{"ref": ".octon/state/evidence/example.txt", "digest": sha(evidence)}],
        "remaining_residue": [],
    }
    valid_return = root / "valid-return.json"
    write(valid_return, returned)
    expect("valid interaction return passes", ["--root", str(root), "--return", str(valid_return)], True)

    missing_return = copy.deepcopy(returned)
    missing_return["return_evidence_refs"] = []
    missing_return_path = root / "missing-return-evidence.json"
    write(missing_return_path, missing_return)
    expect("return evidence is required for completed outcome", ["--root", str(root), "--return", str(missing_return_path)], False)
PY
  exit 0
fi

if [[ -n "$REQUEST_PATH" && -n "$RETURN_PATH" ]]; then
  echo "[ERROR] choose --request or --return, not both" >&2
  exit 2
fi
if [[ -z "$REQUEST_PATH" && -z "$RETURN_PATH" ]]; then
  usage >&2
  exit 2
fi

python3 - "$ROOT_DIR" "$REQUEST_PATH" "$RETURN_PATH" <<'PY'
import datetime as dt
import hashlib
import json
import pathlib
import re
import sys

root = pathlib.Path(sys.argv[1]).resolve()
request_path = sys.argv[2]
return_path = sys.argv[3]

IDENTIFIER = re.compile(r"^[a-z][a-z0-9-]*$")
SHA256 = re.compile(r"^sha256:[0-9a-f]{64}$")
FORBIDDEN = {
    "git-ref-mutation",
    "hosted-provider-authorization",
    "branch-cleanup-authorization",
    "archive-authorization",
    "promotion-authorization",
    "scope-expansion",
}
ACCEPTANCE_CLASSES = {
    "advisory-context",
    "validation-evidence",
    "review-evidence",
    "rollback-context",
    "non-authority-only",
}
REQUEST_KEYS = {
    "schema_version",
    "interaction_id",
    "created_at",
    "source",
    "request",
    "scope",
    "evidence_offered",
    "authority_boundary",
    "stop_conditions",
    "expected_return_evidence",
}
RETURN_KEYS = {
    "schema_version",
    "interaction_id",
    "consumer",
    "outcome",
    "return_evidence_refs",
    "remaining_residue",
}

errors = []

def fail(message):
    errors.append(message)

def load(path):
    try:
        with open(path, "r", encoding="utf-8") as handle:
            return json.load(handle)
    except Exception as exc:
        fail(f"receipt JSON unreadable: {path}: {exc}")
        return None

def safe_rel_path(value, label):
    if not isinstance(value, str) or not value:
        fail(f"{label} must be a non-empty string")
        return None
    path = pathlib.PurePosixPath(value)
    if value.startswith("/") or any(part in ("", ".", "..") for part in path.parts):
        fail(f"{label} must be repo-relative without traversal: {value}")
        return None
    return value

def existing_ref(value, label):
    rel = safe_rel_path(value, label)
    if rel is None:
        return None
    absolute = (root / rel).resolve()
    try:
        absolute.relative_to(root)
    except ValueError:
        fail(f"{label} escapes repo root: {value}")
        return None
    if not absolute.is_file():
        fail(f"{label} does not exist: {value}")
        return None
    return absolute

def digest(path):
    return "sha256:" + hashlib.sha256(path.read_bytes()).hexdigest()

def check_digest(path, expected, label):
    if not isinstance(expected, str) or not SHA256.match(expected):
        fail(f"{label} digest must be sha256:<64 hex>")
        return
    actual = digest(path)
    if actual != expected:
        fail(f"{label} digest stale: expected {expected}, current {actual}")

def boundary_digest(include_paths, exclude_paths):
    payload = json.dumps(
        {"include_paths": include_paths, "exclude_paths": exclude_paths},
        sort_keys=True,
        separators=(",", ":"),
    ).encode()
    return "sha256:" + hashlib.sha256(payload).hexdigest()

def require_keys(obj, required, allowed, label):
    if not isinstance(obj, dict):
        fail(f"{label} must be an object")
        return
    missing = sorted(required - set(obj))
    extra = sorted(set(obj) - allowed)
    if missing:
        fail(f"{label} missing required keys: {', '.join(missing)}")
    if extra:
        fail(f"{label} has unsupported keys: {', '.join(extra)}")

def check_iso8601(value, label):
    if not isinstance(value, str) or not value:
        fail(f"{label} must be a date-time string")
        return
    try:
        dt.datetime.fromisoformat(value.replace("Z", "+00:00"))
    except ValueError:
        fail(f"{label} is not a valid date-time: {value}")

def validate_request(path):
    data = load(path)
    if data is None:
        return
    require_keys(data, REQUEST_KEYS, REQUEST_KEYS, "request receipt")
    if data.get("schema_version") != "lifecycle-interaction-request-v1":
        fail("request schema_version must be lifecycle-interaction-request-v1")
    if not isinstance(data.get("interaction_id"), str) or not IDENTIFIER.match(data.get("interaction_id", "")):
        fail("interaction_id invalid")
    check_iso8601(data.get("created_at"), "created_at")

    source = data.get("source", {})
    require_keys(source, {"lifecycle_id", "run_id", "atomic_unit_type", "target_ref", "phase_id"}, {"lifecycle_id", "run_id", "atomic_unit_type", "target_ref", "phase_id"}, "source")
    for key in ("lifecycle_id", "atomic_unit_type", "phase_id"):
        if not isinstance(source.get(key), str) or not IDENTIFIER.match(source.get(key, "")):
            fail(f"source.{key} invalid")
    if not isinstance(source.get("run_id"), str) or not source.get("run_id"):
        fail("source.run_id invalid")
    safe_rel_path(source.get("target_ref"), "source.target_ref")

    request = data.get("request", {})
    request_keys = {"interaction_profile", "interaction_kind", "requested_capability", "requested_lifecycle_id", "requested_route_surface", "requested_atomic_unit_type", "requested_target_outcome"}
    require_keys(request, request_keys, request_keys, "request")
    if request.get("interaction_kind") != "follow_on_work_required":
        fail("request.interaction_kind must be follow_on_work_required")
    if request.get("requested_capability") not in {"change-closeout", "closeout-worktree", "repo-hygiene-cleanup"}:
        fail("request.requested_capability unsupported")
    for key in ("interaction_profile", "requested_lifecycle_id", "requested_route_surface", "requested_atomic_unit_type", "requested_target_outcome"):
        if not isinstance(request.get(key), str) or not IDENTIFIER.match(request.get(key, "")):
            fail(f"request.{key} invalid")

    scope = data.get("scope", {})
    require_keys(scope, {"include_paths", "exclude_paths", "boundary_digest"}, {"include_paths", "exclude_paths", "boundary_digest"}, "scope")
    include_paths = scope.get("include_paths")
    exclude_paths = scope.get("exclude_paths")
    if not isinstance(include_paths, list) or not isinstance(exclude_paths, list):
        fail("scope include_paths and exclude_paths must be arrays")
        include_paths, exclude_paths = [], []
    for item in include_paths:
        safe_rel_path(item, "scope.include_paths[]")
    for item in exclude_paths:
        safe_rel_path(item, "scope.exclude_paths[]")
    expected_boundary = boundary_digest(include_paths, exclude_paths)
    if scope.get("boundary_digest") != expected_boundary:
        fail(f"scope boundary_digest stale: expected {expected_boundary}, recorded {scope.get('boundary_digest')}")

    evidence = data.get("evidence_offered")
    if not isinstance(evidence, list):
        fail("evidence_offered must be an array")
        evidence = []
    for index, item in enumerate(evidence):
        require_keys(item, {"ref", "digest", "acceptance_class"}, {"ref", "digest", "acceptance_class"}, f"evidence_offered[{index}]")
        if item.get("acceptance_class") not in ACCEPTANCE_CLASSES:
            fail(f"evidence_offered[{index}].acceptance_class invalid")
        absolute = existing_ref(item.get("ref"), f"evidence_offered[{index}].ref")
        if absolute is not None:
            check_digest(absolute, item.get("digest"), f"evidence_offered[{index}]")

    authority_boundary = data.get("authority_boundary", {})
    require_keys(authority_boundary, {"forbidden_transfer"}, {"forbidden_transfer"}, "authority_boundary")
    transfers = authority_boundary.get("forbidden_transfer")
    if not isinstance(transfers, list):
        fail("authority_boundary.forbidden_transfer must be an array")
        transfers = []
    transfer_set = set(transfers)
    unknown = transfer_set - FORBIDDEN
    missing = FORBIDDEN - transfer_set
    if unknown:
        fail(f"authority_boundary.forbidden_transfer has unknown entries: {', '.join(sorted(unknown))}")
    if missing:
        fail(f"authority_boundary.forbidden_transfer missing required entries: {', '.join(sorted(missing))}")

    if not isinstance(data.get("stop_conditions"), list):
        fail("stop_conditions must be an array")
    if not isinstance(data.get("expected_return_evidence"), list):
        fail("expected_return_evidence must be an array")

def validate_return(path):
    data = load(path)
    if data is None:
        return
    require_keys(data, RETURN_KEYS, RETURN_KEYS, "return receipt")
    if data.get("schema_version") != "lifecycle-interaction-return-v1":
        fail("return schema_version must be lifecycle-interaction-return-v1")
    if not isinstance(data.get("interaction_id"), str) or not IDENTIFIER.match(data.get("interaction_id", "")):
        fail("return interaction_id invalid")
    consumer = data.get("consumer", {})
    require_keys(consumer, {"lifecycle_id", "run_id"}, {"lifecycle_id", "run_id"}, "consumer")
    if not isinstance(consumer.get("lifecycle_id"), str) or not IDENTIFIER.match(consumer.get("lifecycle_id", "")):
        fail("consumer.lifecycle_id invalid")
    if not isinstance(consumer.get("run_id"), str) or not consumer.get("run_id"):
        fail("consumer.run_id invalid")
    outcome = data.get("outcome", {})
    require_keys(outcome, {"completed", "lifecycle_outcome", "blocker"}, {"completed", "lifecycle_outcome", "blocker"}, "outcome")
    if not isinstance(outcome.get("completed"), bool):
        fail("outcome.completed must be boolean")
    if not isinstance(outcome.get("lifecycle_outcome"), str) or not IDENTIFIER.match(outcome.get("lifecycle_outcome", "")):
        fail("outcome.lifecycle_outcome invalid")
    refs = data.get("return_evidence_refs")
    if not isinstance(refs, list):
        fail("return_evidence_refs must be an array")
        refs = []
    if outcome.get("completed") is True and not refs:
        fail("completed return requires return_evidence_refs")
    for index, item in enumerate(refs):
        if not isinstance(item, dict):
            fail(f"return_evidence_refs[{index}] must be an object")
            continue
        require_keys(item, {"ref", "digest"}, {"ref", "digest"}, f"return_evidence_refs[{index}]")
        absolute = existing_ref(item.get("ref"), f"return_evidence_refs[{index}].ref")
        if absolute is not None:
            check_digest(absolute, item.get("digest"), f"return_evidence_refs[{index}]")
    residue = data.get("remaining_residue")
    if not isinstance(residue, list):
        fail("remaining_residue must be an array")
        residue = []
    for item in residue:
        safe_rel_path(item, "remaining_residue[]")

if request_path:
    validate_request(request_path)
if return_path:
    validate_return(return_path)

if errors:
    for error in errors:
        print(f"[ERROR] {error}")
    print(f"Validation summary: errors={len(errors)}")
    sys.exit(1)

print("[OK] lifecycle interaction receipt validates")
print("Validation summary: errors=0")
PY
