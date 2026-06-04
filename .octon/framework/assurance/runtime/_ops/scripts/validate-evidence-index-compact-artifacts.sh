#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_ROOT="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
ROOT_DIR="${OCTON_ROOT_DIR:-$DEFAULT_ROOT}"
BUNDLE_PATH=""

usage() {
  cat <<'EOF'
Usage:
  validate-evidence-index-compact-artifacts.sh --bundle <evidence-bundle> [--root <repo-root>]

Validates evidence-index.yml, raw-log-summary.yml, and
failing-slice-manifest.yml against their retained raw evidence refs.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)
      ROOT_DIR="$2"
      shift 2
      ;;
    --bundle)
      BUNDLE_PATH="$2"
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

if [[ -z "$BUNDLE_PATH" ]]; then
  echo "[ERROR] missing --bundle" >&2
  usage >&2
  exit 2
fi

python3 - "$ROOT_DIR" "$BUNDLE_PATH" <<'PY'
import hashlib
import json
import pathlib
import subprocess
import sys

root = pathlib.Path(sys.argv[1]).resolve()
raw_bundle = pathlib.Path(sys.argv[2])
bundle = raw_bundle if raw_bundle.is_absolute() else root / raw_bundle

errors = []

def fail(message):
    errors.append(message)
    print(f"[ERROR] {message}")

def ok(message):
    print(f"[OK] {message}")

def load_yaml(path):
    result = subprocess.run(
        ["yq", "-o=json", ".", str(path)],
        text=True,
        capture_output=True,
        check=False,
    )
    if result.returncode != 0:
        fail(f"failed to parse YAML: {path}: {result.stderr.strip()}")
        return {}
    try:
        return json.loads(result.stdout or "{}")
    except json.JSONDecodeError as exc:
        fail(f"failed to decode YAML JSON: {path}: {exc}")
        return {}

def resolve_ref(ref):
    path = pathlib.Path(ref)
    return path if path.is_absolute() else root / path

def sha256(path):
    return "sha256:" + hashlib.sha256(path.read_bytes()).hexdigest()

def require_file(path, label):
    if path.is_file():
        ok(f"{label} exists")
        return True
    fail(f"{label} missing: {path}")
    return False

index_path = bundle / "evidence-index.yml"
raw_summary_path = bundle / "raw-log-summary.yml"
slice_manifest_path = bundle / "failing-slice-manifest.yml"

for path, label in [
    (index_path, "evidence index"),
    (raw_summary_path, "raw-log summary"),
    (slice_manifest_path, "failing-slice manifest"),
]:
    require_file(path, label)

index = load_yaml(index_path) if index_path.is_file() else {}
raw_summary = load_yaml(raw_summary_path) if raw_summary_path.is_file() else {}
slice_manifest = load_yaml(slice_manifest_path) if slice_manifest_path.is_file() else {}

def check_schema(value, expected, label):
    if value.get("schema_version") == expected:
        ok(f"{label} schema is {expected}")
    else:
        fail(f"{label} schema must be {expected}")

check_schema(index, "octon-evidence-index-v1", "evidence index")
check_schema(raw_summary, "octon-raw-log-summary-v1", "raw-log summary")
check_schema(slice_manifest, "octon-failing-slice-manifest-v1", "failing-slice manifest")

def check_boundary(value, label):
    boundary = value.get("authority_boundary") or {}
    expected = {
        "replaces_source_evidence": False,
        "authorizes_execution": False,
        "proposal_input_authority": "non-authoritative",
        "generated_output_authority": "derived-only",
        "raw_evidence_retained": True,
    }
    for key, expected_value in expected.items():
        if boundary.get(key) == expected_value:
            ok(f"{label} authority boundary {key}")
        else:
            fail(f"{label} authority boundary {key} must be {expected_value!r}")

check_boundary(index, "evidence index")
check_boundary(raw_summary, "raw-log summary")
check_boundary(slice_manifest, "failing-slice manifest")

reader_preferences = index.get("reader_preferences") or {}
if reader_preferences.get("raw_body_escalation_required") is True:
    ok("reader preferences require escalation before raw body reads")
else:
    fail("reader preferences must require escalation before raw body reads")

if int(raw_summary.get("token_ceiling") or 0) <= 2000:
    ok("raw-log summary token ceiling is 2k or lower")
else:
    fail("raw-log summary token ceiling must be 2k or lower")

source_refs = {}
for artifact in index.get("source_artifacts") or []:
    ref = artifact.get("artifact_ref")
    if not ref:
        fail("source artifact missing artifact_ref")
        continue
    path = resolve_ref(ref)
    if not require_file(path, f"source artifact {ref}"):
        continue
    actual_sha = sha256(path)
    if artifact.get("sha256") == actual_sha:
        ok(f"source artifact digest matches: {ref}")
    else:
        fail(f"source artifact digest mismatch: {ref}")
    actual_size = path.stat().st_size
    if int(artifact.get("byte_size") or -1) == actual_size:
        ok(f"source artifact byte size matches: {ref}")
    else:
        fail(f"source artifact byte size mismatch: {ref}")
    if artifact.get("default_reader") in {"compact-ref", "raw-ref-handle"}:
        ok(f"source artifact default reader is explicit: {ref}")
    else:
        fail(f"source artifact default reader invalid: {ref}")
    source_refs[ref] = actual_sha

compact_roles = set()
for artifact in index.get("compact_artifacts") or []:
    ref = artifact.get("artifact_ref")
    role = artifact.get("artifact_role")
    compact_roles.add(role)
    if not ref:
        fail(f"compact artifact {role} missing artifact_ref")
        continue
    path = resolve_ref(ref)
    if not require_file(path, f"compact artifact {role}"):
        continue
    if artifact.get("sha256") == sha256(path):
        ok(f"compact artifact digest matches: {role}")
    else:
        fail(f"compact artifact digest mismatch: {role}")

for required_role in {"raw-log-summary", "failing-slice-manifest"}:
    if required_role in compact_roles:
        ok(f"compact artifact role present: {required_role}")
    else:
        fail(f"compact artifact role missing: {required_role}")

summary_records = raw_summary.get("summaries") or []
if int(raw_summary.get("source_count") or -1) == len(summary_records):
    ok("raw-log summary source_count matches summaries")
else:
    fail("raw-log summary source_count does not match summaries")

for record in summary_records:
    ref = record.get("source_ref")
    if not ref:
        fail("raw-log summary record missing source_ref")
        continue
    path = resolve_ref(ref)
    if not require_file(path, f"raw-log summary source {ref}"):
        continue
    actual_sha = sha256(path)
    if record.get("source_sha256") == actual_sha:
        ok(f"raw-log summary source digest matches: {ref}")
    else:
        fail(f"raw-log summary source digest mismatch: {ref}")
    lines = path.read_text(errors="replace").splitlines()
    if int(record.get("line_count") or -1) == len(lines):
        ok(f"raw-log summary line count matches: {ref}")
    else:
        fail(f"raw-log summary line count mismatch: {ref}")

slices = slice_manifest.get("slices") or []
if (slice_manifest.get("no_failure_observed") is True) == (len(slices) == 0):
    ok("failing-slice no_failure_observed matches slice count")
else:
    fail("failing-slice no_failure_observed must match slice count")

for item in slices:
    ref = item.get("source_ref")
    if not ref:
        fail("failing slice missing source_ref")
        continue
    path = resolve_ref(ref)
    if not require_file(path, f"failing slice source {ref}"):
        continue
    actual_sha = sha256(path)
    if item.get("source_sha256") == actual_sha:
        ok(f"failing slice source digest matches: {item.get('slice_id')}")
    else:
        fail(f"failing slice source digest mismatch: {item.get('slice_id')}")
    lines = path.read_text(errors="replace").splitlines()
    start = int(item.get("start_line") or 0)
    end = int(item.get("end_line") or 0)
    if start < 1 or end < start or end > len(lines):
        fail(f"failing slice line range invalid: {item.get('slice_id')}")
        continue
    reconstructed = "\n".join(lines[start - 1:end])
    reconstructed_sha = "sha256:" + hashlib.sha256(reconstructed.encode()).hexdigest()
    if item.get("slice_sha256") == reconstructed_sha:
        ok(f"failing slice reconstructs: {item.get('slice_id')}")
    else:
        fail(f"failing slice reconstruction digest mismatch: {item.get('slice_id')}")
    expected_count = end - start + 1
    if int(item.get("line_count") or -1) == expected_count:
        ok(f"failing slice line count matches: {item.get('slice_id')}")
    else:
        fail(f"failing slice line count mismatch: {item.get('slice_id')}")

print(f"Validation summary: errors={len(errors)}")
if errors:
    sys.exit(1)
PY
