#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_ROOT="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
ROOT_DIR="${OCTON_ROOT_DIR:-$DEFAULT_ROOT}"
PACKAGE_PATH=""
RUN_ID=""
GENERATED_AT=""
WRITE=0

usage() {
  cat <<'EOF'
Usage:
  generate-retained-run-evidence-index.sh --package <implemented-proposal-packet> --run-id <run-id> --write [--generated-at <iso8601>] [--root <repo-root>]

Materializes a discovery-only retained-run-evidence-index-v1 artifact for an
already implemented proposal packet. The generated index is evidence-only and
does not authorize lifecycle transitions or satisfy child receipts.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)
      ROOT_DIR="${2:-}"
      shift 2
      ;;
    --package)
      PACKAGE_PATH="${2:-}"
      shift 2
      ;;
    --run-id)
      RUN_ID="${2:-}"
      shift 2
      ;;
    --generated-at)
      GENERATED_AT="${2:-}"
      shift 2
      ;;
    --write)
      WRITE=1
      shift
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

if [[ -z "$PACKAGE_PATH" || -z "$RUN_ID" ]]; then
  echo "[ERROR] --package and --run-id are required" >&2
  usage >&2
  exit 2
fi

if [[ "$WRITE" -ne 1 ]]; then
  echo "[ERROR] --write is required; dry-run indexes are not retained evidence" >&2
  exit 2
fi

if [[ -z "$GENERATED_AT" ]]; then
  GENERATED_AT="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
fi

python3 - "$ROOT_DIR" "$PACKAGE_PATH" "$RUN_ID" "$GENERATED_AT" "$SCRIPT_DIR/validate-retained-run-evidence-index.sh" <<'PY'
import hashlib
import json
import pathlib
import re
import subprocess
import sys

root = pathlib.Path(sys.argv[1]).resolve()
package_arg = pathlib.Path(sys.argv[2])
run_id = sys.argv[3]
generated_at = sys.argv[4]
validator = pathlib.Path(sys.argv[5]).resolve()

if not re.match(r"^[A-Za-z0-9._+-]+$", run_id):
    print(f"[ERROR] unsafe run id: {run_id}", file=sys.stderr)
    sys.exit(2)

package_dir = package_arg if package_arg.is_absolute() else root / package_arg
package_dir = package_dir.resolve()
try:
    package_ref = str(package_dir.relative_to(root))
except ValueError:
    print(f"[ERROR] package must be inside root: {package_dir}", file=sys.stderr)
    sys.exit(2)


def run(command):
    return subprocess.run(command, cwd=root, text=True, capture_output=True, check=False)


def load_yaml(path):
    result = run(["yq", "-o=json", ".", str(path)])
    if result.returncode != 0:
        print(f"[ERROR] cannot parse YAML: {rel(path)}: {result.stderr.strip()}", file=sys.stderr)
        sys.exit(1)
    try:
        return json.loads(result.stdout or "{}")
    except json.JSONDecodeError as exc:
        print(f"[ERROR] cannot decode YAML: {rel(path)}: {exc}", file=sys.stderr)
        sys.exit(1)


def rel(path):
    path = pathlib.Path(path).resolve()
    try:
        return str(path.relative_to(root))
    except ValueError:
        return str(path)


def sha(path):
    return "sha256:" + hashlib.sha256(path.read_bytes()).hexdigest()


def receipt_field(path, field):
    pattern = re.compile(rf"^[\s-]*{re.escape(field)}\s*:\s*(.+?)\s*$", re.IGNORECASE)
    for line in path.read_text(errors="replace").splitlines():
        match = pattern.match(line)
        if match:
            return match.group(1).strip().strip("`").strip('"').strip("'")
    return ""


def require_file(path, label):
    if not path.is_file():
        print(f"[ERROR] {label} missing: {rel(path)}", file=sys.stderr)
        sys.exit(1)


def require_field(path, field, expected, label):
    actual = receipt_field(path, field)
    if actual != expected:
        print(
            f"[ERROR] {label} requires {field}: {expected}; found {actual or '<missing>'}: {rel(path)}",
            file=sys.stderr,
        )
        sys.exit(1)


manifest_path = package_dir / "proposal.yml"
support_dir = package_dir / "support"
require_file(manifest_path, "proposal manifest")
manifest = load_yaml(manifest_path)

proposal_id = str(manifest.get("proposal_id") or package_dir.name)
status = str(manifest.get("status") or "")
if status != "implemented":
    print(f"[ERROR] package status must be implemented; found {status or '<missing>'}: {package_ref}", file=sys.stderr)
    sys.exit(1)

source_paths = [
    (manifest_path, "proposal-manifest"),
    (support_dir / "proposal-review.md", "accepted-review"),
    (support_dir / "implementation-run.md", "implementation-run"),
    (support_dir / "implementation-conformance-review.md", "implementation-conformance"),
    (support_dir / "post-implementation-drift-churn-review.md", "post-implementation-drift"),
    (support_dir / "validation.md", "validation-evidence"),
]

optional_sources = [
    (support_dir / "pre-integration-architecture-review.yml", "strict-architecture-review"),
    (support_dir / "executable-implementation-prompt.md", "implementation-prompt"),
]
for path, role in optional_sources:
    if path.is_file():
        source_paths.append((path, role))

for path, role in source_paths:
    require_file(path, role)

require_field(support_dir / "proposal-review.md", "verdict", "accepted", "proposal review")
require_field(support_dir / "implementation-run.md", "verdict", "pass", "implementation run receipt")
require_field(
    support_dir / "implementation-conformance-review.md",
    "verdict",
    "pass",
    "implementation conformance receipt",
)
require_field(
    support_dir / "post-implementation-drift-churn-review.md",
    "verdict",
    "pass",
    "post-implementation drift/churn receipt",
)

run_root = root / ".octon/state/evidence/runs" / run_id
validation_dir = run_root / "validation"
rollback_dir = run_root / "rollback"
workflow_dir = root / ".octon/state/evidence/runs/workflows" / run_id
run_root.mkdir(parents=True, exist_ok=True)
validation_dir.mkdir(parents=True, exist_ok=True)
rollback_dir.mkdir(parents=True, exist_ok=True)
workflow_dir.mkdir(parents=True, exist_ok=True)

validation_path = validation_dir / "result.yml"
rollback_path = rollback_dir / "rollback.md"
source_manifest_path = run_root / "source-manifest.yml"
workflow_path = workflow_dir / "retained-run-evidence-index-materialization.yml"
index_path = run_root / "retained-run-evidence-index.yml"

source_records = [
    {
        "ref": rel(path),
        "role": role,
        "sha256": sha(path),
        "status": "source-retained",
    }
    for path, role in source_paths
]

source_manifest = {
    "schema_version": "retained-run-evidence-index-source-manifest-v1",
    "run_id": run_id,
    "package": package_ref,
    "proposal_id": proposal_id,
    "package_status": status,
    "generated_at": generated_at,
    "source_refs": source_records,
}
validation_result = {
    "schema_version": "retained-run-evidence-index-materialization-validation-v1",
    "run_id": run_id,
    "package": package_ref,
    "verdict": "pass",
    "checks": [
        "implemented-status-present",
        "accepted-review-present",
        "implementation-run-verdict-pass",
        "implementation-conformance-verdict-pass",
        "post-implementation-drift-verdict-pass",
        "validation-evidence-present",
    ],
}
workflow_receipt = {
    "schema_version": "retained-run-evidence-index-materialization-receipt-v1",
    "run_id": run_id,
    "package": package_ref,
    "producer": "generate-retained-run-evidence-index.sh",
    "generated_at": generated_at,
    "authority_use": "evidence-only",
    "control_refs_created": False,
    "notes": "Materialized discovery-only retained evidence index from existing proposal packet receipts.",
}


def dump(path, data):
    path.write_text(json.dumps(data, indent=2, sort_keys=False) + "\n")


dump(source_manifest_path, source_manifest)
dump(validation_path, validation_result)
dump(workflow_path, workflow_receipt)
rollback_path.write_text(
    "\n".join(
        [
            "# Rollback Posture",
            "",
            f"run_id: {run_id}",
            f"package: {package_ref}",
            "verdict: evidence-retained",
            "",
            "This retained-run evidence index is discovery-only evidence. Supersede it",
            "with a newer governed index if source receipts change. Do not delete retained",
            "evidence without an explicit governed cleanup route.",
            "",
        ]
    )
)


def record(path, role, ref_class, authority_use, required=True, notes=""):
    result = {
        "ref": rel(path),
        "role": role,
        "ref_class": ref_class,
        "sha256": sha(path),
        "authority_use": authority_use,
        "required": bool(required),
    }
    if notes:
        result["notes"] = notes
    return result


child_refs = [
    record(path, role, "proposal-local", "non-authoritative", True, "Source packet evidence; not lifecycle authority.")
    for path, role in source_paths
]
substitute_refs = [
    record(workflow_path, "materialization-workflow-receipt", "retained-workflow-evidence", "evidence-only")
]
validation_refs = [
    record(validation_path, "materialization-validation-result", "retained-evidence", "evidence-only")
]
rollback_refs = [
    record(rollback_path, "rollback-posture", "retained-evidence", "evidence-only")
]
extra_refs = [
    record(source_manifest_path, "source-manifest", "retained-evidence", "evidence-only")
]
indexed_refs = []
indexed_refs.extend(substitute_refs)
indexed_refs.extend(child_refs)
indexed_refs.extend(validation_refs)
indexed_refs.extend(rollback_refs)
indexed_refs.extend(extra_refs)

index = {
    "schema_version": "retained-run-evidence-index-v1",
    "subject": {
        "run_id": run_id,
        "lifecycle_kind": "proposal-packet",
        "terminal_status": "implemented",
    },
    "producer": "generate-retained-run-evidence-index.sh",
    "generated_at": generated_at,
    "evidence_posture": {
        "purpose": "discovery-and-replay-aid",
        "freshness_state": "digest-bound",
        "direct_control_refs_present": False,
    },
    "control_refs": [],
    "substitute_workflow_refs": substitute_refs,
    "terminal_evidence_refs": {
        "child": child_refs,
        "parent": [],
        "validation": validation_refs,
        "rollback": rollback_refs,
        "closeout": [],
        "cleanup": [],
    },
    "indexed_refs": indexed_refs,
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
dump(index_path, index)

index_ref = rel(index_path)
result = subprocess.run(
    ["bash", str(validator), "--root", str(root), "--index", index_ref],
    cwd=root,
    text=True,
    capture_output=True,
    check=False,
)
if result.returncode != 0:
    print(result.stdout, end="")
    print(result.stderr, end="", file=sys.stderr)
    sys.exit(result.returncode)

print(index_ref)
PY
