#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_ROOT="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
ROOT_DIR="${OCTON_ROOT_DIR:-$DEFAULT_ROOT}"
RECEIPT_PATH=""
RUN_ID=""
GENERATED_AT=""
INDEX_PATH=""
WRITE=0

usage() {
  cat <<'EOF'
Usage:
  generate-proposal-program-delivery-evidence-index.sh --receipt <proposal-program-delivery-receipt.yml> --run-id <run-id> --write [--generated-at <iso8601>] [--index <path>] [--root <repo-root>]

Materializes a compact proposal-program-delivery-evidence-index-v1 artifact
from a validated proposal-program-delivery-receipt-v1 receipt. The generated
index records refs, digests, disclosure tiers, route/outcome metadata,
validator results, and non-authority boundaries. It does not authorize
delivery, landing, cleanup, archive, execution, or child receipt replacement.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)
      ROOT_DIR="${2:-}"
      shift 2
      ;;
    --receipt)
      RECEIPT_PATH="${2:-}"
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
    --index)
      INDEX_PATH="${2:-}"
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

if [[ -z "$RECEIPT_PATH" || -z "$RUN_ID" ]]; then
  echo "[ERROR] --receipt and --run-id are required" >&2
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

python3 - "$ROOT_DIR" "$RECEIPT_PATH" "$RUN_ID" "$GENERATED_AT" "$INDEX_PATH" "$SCRIPT_DIR/validate-proposal-program-delivery-receipt.sh" "$SCRIPT_DIR/validate-proposal-program-delivery-evidence-index.sh" <<'PY'
import hashlib
import json
import pathlib
import re
import subprocess
import sys

root = pathlib.Path(sys.argv[1]).resolve()
receipt_arg = pathlib.Path(sys.argv[2])
run_id = sys.argv[3]
generated_at = sys.argv[4]
index_arg = sys.argv[5]
receipt_validator = pathlib.Path(sys.argv[6]).resolve()
index_validator = pathlib.Path(sys.argv[7]).resolve()

if not re.match(r"^[A-Za-z0-9._+-]+$", run_id):
    print(f"[ERROR] unsafe run id: {run_id}", file=sys.stderr)
    sys.exit(2)

receipt_path = receipt_arg if receipt_arg.is_absolute() else root / receipt_arg
receipt_path = receipt_path.resolve()
if index_arg:
    index_path = pathlib.Path(index_arg)
    index_path = index_path if index_path.is_absolute() else root / index_path
else:
    index_path = root / ".octon/state/evidence/runs/workflows" / run_id / "proposal-program-delivery-evidence-index.yml"
index_path = index_path.resolve()


def run(command):
    return subprocess.run(command, cwd=root, text=True, capture_output=True, check=False)


def rel(path):
    path = pathlib.Path(path).resolve()
    try:
        return str(path.relative_to(root))
    except ValueError:
        return str(path)


def resolve_ref(ref):
    path = pathlib.Path(str(ref))
    return path if path.is_absolute() else root / path


def sha(path):
    return "sha256:" + hashlib.sha256(path.read_bytes()).hexdigest()


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


if not receipt_path.is_file():
    print(f"[ERROR] receipt missing: {rel(receipt_path)}", file=sys.stderr)
    sys.exit(1)

receipt_check = subprocess.run(
    ["bash", str(receipt_validator), "--receipt", str(receipt_path)],
    cwd=root,
    text=True,
    capture_output=True,
    check=False,
)
if receipt_check.returncode != 0:
    print(receipt_check.stdout, end="")
    print(receipt_check.stderr, end="", file=sys.stderr)
    sys.exit(receipt_check.returncode)

receipt = load_yaml(receipt_path)
if receipt.get("schema_version") != "proposal-program-delivery-receipt-v1":
    print("[ERROR] source receipt schema_version must be proposal-program-delivery-receipt-v1", file=sys.stderr)
    sys.exit(1)


def scalar(path, default=""):
    node = receipt
    for part in path.split("."):
        if isinstance(node, dict) and part in node:
            node = node[part]
        else:
            return default
    if node is None:
        return default
    return node


def usable_ref(value):
    if value is None:
        return False
    text = str(value).strip()
    return bool(text) and text not in {"not-applicable", "not-run", "not-required", "none", "null"}


def disclosure_tier(ref):
    text = str(ref)
    if text.startswith(".octon/state/evidence/local/"):
        return "local-private-index-only"
    if text.startswith(".octon/state/evidence/"):
        return "retained-evidence"
    if text.startswith(".octon/inputs/"):
        return "proposal-local"
    if text.startswith(".octon/generated/"):
        return "derived-generated"
    if text.startswith(".octon/framework/"):
        return "framework-source"
    return "repo-local"


def authority_use(source_field, ref):
    tier = disclosure_tier(ref)
    if source_field == ".source_receipt":
        return "source-delivery-receipt"
    if source_field.startswith(".child_receipts."):
        return "target-owned-child-receipt-ref"
    if source_field == ".generated_publication.publisher_refs":
        return "publisher-source-ref"
    if source_field.startswith(".validator_results"):
        return "validator-evidence-ref"
    if source_field == ".parent_program_lifecycle.receipt_ref":
        return "workflow-evidence-ref"
    if tier == "local-private-index-only":
        return "local-private-ref"
    if tier == "framework-source":
        return "framework-source-ref"
    if tier == "derived-generated":
        return "derived-only-ref"
    if tier == "proposal-local":
        return "proposal-local-ref"
    return "retained-evidence-ref"


def role_for(source_field, fallback):
    role_map = {
        ".source_receipt": "program-delivery-receipt",
        ".profile.profile_ref": "delivery-profile",
        ".parent_program_lifecycle.receipt_ref": "parent-program-lifecycle-receipt",
        ".child_receipts.implementation_run": "child-implementation-run",
        ".child_receipts.implementation_conformance": "child-implementation-conformance",
        ".child_receipts.post_implementation_drift_churn": "child-post-implementation-drift-churn",
        ".child_receipts.packet_closeout": "child-packet-closeout",
        ".child_receipts.archive": "child-archive",
        ".child_receipts.change_closeout": "child-change-closeout",
        ".implementation_conformance.receipt_ref": "program-implementation-conformance",
        ".post_implementation_drift_churn.receipt_ref": "program-post-implementation-drift-churn",
        ".generated_publication.publisher_refs": "publication-publisher",
        ".governed_mechanism_integration.receipt_refs": "governed-mechanism-integration",
        ".lifecycle_residue_cleanup.cleanup_authorization_refs": "lifecycle-residue-cleanup-authorization",
        ".change_closeout.receipt_ref": "change-closeout-receipt",
        ".branch_authorization.landing_authorization_ref": "landing-authorization",
        ".branch_authorization.cleanup_authorization_ref": "branch-cleanup-authorization",
        ".terminal_current_state_proof.evidence_ref": "terminal-current-state-proof",
        ".worktree_hygiene.evidence_ref": "worktree-hygiene-proof",
        ".blockers.evidence_ref": "delivery-blocker-evidence",
    }
    return role_map.get(source_field, fallback)


records = []


def add_ref(ref, source_field, fallback_role, required=True):
    if not usable_ref(ref):
        return
    ref_text = str(ref)
    path = resolve_ref(ref_text)
    if not path.is_file():
        print(f"[ERROR] indexed evidence ref missing: {ref_text}", file=sys.stderr)
        sys.exit(1)
    records.append(
        {
            "ref": rel(path),
            "role": role_for(source_field, fallback_role),
            "source_field": source_field,
            "sha256": sha(path),
            "disclosure_tier": disclosure_tier(rel(path)),
            "authority_use": authority_use(source_field, rel(path)),
            "required": bool(required),
        }
    )


add_ref(rel(receipt_path), ".source_receipt", "program-delivery-receipt")
add_ref(scalar("profile.profile_ref"), ".profile.profile_ref", "delivery-profile")
add_ref(
    scalar("parent_program_lifecycle.receipt_ref"),
    ".parent_program_lifecycle.receipt_ref",
    "parent-program-lifecycle-receipt",
)

child_receipts = receipt.get("child_receipts") or {}
for family, values in child_receipts.items():
    if isinstance(values, list):
        for value in values:
            add_ref(value, f".child_receipts.{family}", f"child-{family.replace('_', '-')}")

add_ref(
    scalar("implementation_conformance.receipt_ref"),
    ".implementation_conformance.receipt_ref",
    "program-implementation-conformance",
)
add_ref(
    scalar("post_implementation_drift_churn.receipt_ref"),
    ".post_implementation_drift_churn.receipt_ref",
    "program-post-implementation-drift-churn",
)

for value in (receipt.get("generated_publication") or {}).get("publisher_refs") or []:
    add_ref(value, ".generated_publication.publisher_refs", "publication-publisher")
for value in (receipt.get("governed_mechanism_integration") or {}).get("receipt_refs") or []:
    add_ref(value, ".governed_mechanism_integration.receipt_refs", "governed-mechanism-integration")
for value in (receipt.get("lifecycle_residue_cleanup") or {}).get("cleanup_authorization_refs") or []:
    add_ref(value, ".lifecycle_residue_cleanup.cleanup_authorization_refs", "cleanup-authorization")

add_ref(scalar("change_closeout.receipt_ref"), ".change_closeout.receipt_ref", "change-closeout-receipt")
add_ref(
    scalar("branch_authorization.landing_authorization_ref"),
    ".branch_authorization.landing_authorization_ref",
    "landing-authorization",
)
add_ref(
    scalar("branch_authorization.cleanup_authorization_ref"),
    ".branch_authorization.cleanup_authorization_ref",
    "branch-cleanup-authorization",
)
add_ref(
    scalar("terminal_current_state_proof.evidence_ref"),
    ".terminal_current_state_proof.evidence_ref",
    "terminal-current-state-proof",
)
add_ref(scalar("worktree_hygiene.evidence_ref"), ".worktree_hygiene.evidence_ref", "worktree-hygiene-proof")
for blocker in receipt.get("blockers") or []:
    if isinstance(blocker, dict):
        add_ref(blocker.get("evidence_ref"), ".blockers.evidence_ref", "delivery-blocker-evidence", required=False)

target_outcome = str(receipt.get("target_outcome") or "")
actual_outcome = str(receipt.get("actual_outcome") or "")
final_sync_claimed = actual_outcome in {"synced", "cleaned"}

index = {
    "schema_version": "proposal-program-delivery-evidence-index-v1",
    "index_id": f"{run_id}-proposal-program-delivery-evidence-index",
    "generated_at": generated_at,
    "producer": "generate-proposal-program-delivery-evidence-index.sh",
    "source_receipt": {
        "ref": rel(receipt_path),
        "sha256": sha(receipt_path),
        "schema_version": "proposal-program-delivery-receipt-v1",
    },
    "target_program": {
        "path": str(scalar("target_program.path")),
        "status": str(scalar("target_program.status")),
    },
    "target_outcome": target_outcome,
    "actual_outcome": actual_outcome,
    "route": {
        "change_closeout_route": str(scalar("change_closeout.route")),
        "change_closeout_verdict": str(scalar("change_closeout.verdict")),
        "landing_performed": bool(scalar("branch_authorization.landing_performed", False)),
        "branch_cleanup_performed": bool(scalar("branch_authorization.branch_cleanup_performed", False)),
        "branch_deleted": bool(scalar("branch_authorization.branch_deleted", False)),
        "final_sync_claimed": final_sync_claimed,
    },
    "outcome_authority": {
        "index_replaces_delivery_receipt": False,
        "archive_evidence_claims_delivery": False,
        "child_delivery_required_for_sibling_progression": False,
        "child_delivery_claimed_by_archive_only": False,
    },
    "evidence_policy": {
        "purpose": "compact-retained-delivery-evidence-index",
        "disclosure": "refs-digests-and-classification-only",
        "raw_evidence_retained": True,
        "authorizes_execution": False,
        "authorizes_archive": False,
        "authorizes_delivery": False,
        "authorizes_landing": False,
        "authorizes_cleanup": False,
        "satisfies_child_receipts": False,
        "generated_outputs_are_authority": False,
    },
    "validator_results": [
        {
            "validator": "validate-proposal-program-delivery-receipt.sh",
            "target_ref": rel(receipt_path),
            "verdict": "pass",
            "evidence_ref": rel(receipt_path),
        },
        {
            "validator": "generate-proposal-program-delivery-evidence-index.sh",
            "target_ref": rel(index_path),
            "verdict": "pass",
            "evidence_ref": rel(index_path),
        },
    ],
    "non_authority_classification": receipt.get("non_authority_classification") or {},
    "target_owned_evidence_policy": receipt.get("target_owned_evidence_policy") or {},
    "indexed_evidence_refs": records,
    "failure_behavior": [
        "fail-closed-on-source-receipt-validation-failure",
        "fail-closed-on-indexed-ref-missing",
        "fail-closed-on-indexed-ref-digest-mismatch",
        "fail-closed-on-authority-boundary-conflict",
    ],
}

index_path.parent.mkdir(parents=True, exist_ok=True)
index_path.write_text(json.dumps(index, indent=2, sort_keys=False) + "\n")

index_check = subprocess.run(
    ["bash", str(index_validator), "--root", str(root), "--index", str(index_path)],
    cwd=root,
    text=True,
    capture_output=True,
    check=False,
)
if index_check.returncode != 0:
    print(index_check.stdout, end="")
    print(index_check.stderr, end="", file=sys.stderr)
    sys.exit(index_check.returncode)

print(rel(index_path))
PY
