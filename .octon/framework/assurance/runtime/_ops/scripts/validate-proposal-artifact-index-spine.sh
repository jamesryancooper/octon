#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_ROOT="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
ROOT_DIR="${OCTON_ROOT_DIR:-$DEFAULT_ROOT}"
PROPOSAL_PATH=""

usage() {
  cat <<'EOF'
usage:
  validate-proposal-artifact-index-spine.sh --proposal <proposal-path> [--root <repo-root>]

Validates proposal-artifact-index.yml, proposal-program-spine.yml, and
child-handoff-capsule.yml compact artifacts against proposal packet sources.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)
      ROOT_DIR="$2"
      shift 2
      ;;
    --proposal|--package)
      PROPOSAL_PATH="$2"
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

if [[ -z "$PROPOSAL_PATH" ]]; then
  usage >&2
  exit 2
fi

python3 - "$ROOT_DIR" "$PROPOSAL_PATH" <<'PY'
import hashlib
import json
import pathlib
import subprocess
import sys

root = pathlib.Path(sys.argv[1]).resolve()
proposal_arg = pathlib.Path(sys.argv[2])
proposal_dir = proposal_arg if proposal_arg.is_absolute() else root / proposal_arg
proposal_dir = proposal_dir.resolve()

errors = []

def fail(message):
    errors.append(message)
    print(f"[ERROR] {message}")

def ok(message):
    print(f"[OK] {message}")

def rel(path):
    path = pathlib.Path(path).resolve()
    return str(path.relative_to(root))

def resolve(ref):
    path = pathlib.Path(ref)
    return path if path.is_absolute() else root / path

def sha256(path):
    return "sha256:" + hashlib.sha256(path.read_bytes()).hexdigest()

def estimate_tokens(size):
    return (int(size) + 3) // 4

def stable_json(value):
    return json.dumps(value, indent=2, sort_keys=True) + "\n"

def load_yaml(path):
    result = subprocess.run(
        ["yq", "-o=json", ".", str(path)],
        text=True,
        capture_output=True,
        check=False,
    )
    if result.returncode != 0:
        fail(f"YAML parse failed for {path}: {result.stderr.strip()}")
        return {}
    try:
        return json.loads(result.stdout or "{}")
    except json.JSONDecodeError as exc:
        fail(f"YAML JSON decode failed for {path}: {exc}")
        return {}

def require_file(path, label):
    if pathlib.Path(path).is_file():
        ok(f"{label} exists")
        return True
    fail(f"{label} missing: {path}")
    return False

manifest_path = proposal_dir / "proposal.yml"
if not require_file(manifest_path, "proposal manifest"):
    print("Proposal artifact spine validation summary: errors=1")
    sys.exit(1)

proposal = load_yaml(manifest_path)
proposal_id = proposal.get("proposal_id") or proposal_dir.name
proposal_kind = proposal.get("proposal_kind") or "unknown"
parent_program = proposal.get("parent_program") or ""
output_dir = root / ".octon/generated/proposals/artifacts" / proposal_kind / proposal_id
index_path = output_dir / "proposal-artifact-index.yml"
spine_path = output_dir / "proposal-program-spine.yml"
handoff_path = output_dir / "child-handoff-capsule.yml"

for path, label in [
    (index_path, "proposal artifact index"),
    (spine_path, "proposal program spine"),
]:
    require_file(path, label)
if parent_program:
    require_file(handoff_path, "child handoff capsule")

index = load_yaml(index_path) if index_path.is_file() else {}
spine = load_yaml(spine_path) if spine_path.is_file() else {}
handoff = load_yaml(handoff_path) if handoff_path.is_file() else {}

def check_schema(value, expected, label):
    if value.get("schema_version") == expected:
        ok(f"{label} schema is {expected}")
    else:
        fail(f"{label} schema must be {expected}")

check_schema(index, "octon-proposal-artifact-index-v1", "proposal artifact index")
check_schema(spine, "octon-proposal-program-spine-v1", "proposal program spine")
if parent_program:
    check_schema(handoff, "octon-child-handoff-capsule-v1", "child handoff capsule")

def check_boundary(value, label):
    boundary = value.get("authority_boundary") or {}
    expected = {
        "replaces_source_evidence": False,
        "authorizes_execution": False,
        "proposal_input_authority": "non-authoritative",
        "generated_output_authority": "derived-only",
        "raw_evidence_retained": True,
        "generated_registry_replaces_manifest": False,
    }
    for key, expected_value in expected.items():
        if boundary.get(key) == expected_value:
            ok(f"{label} authority boundary {key}")
        else:
            fail(f"{label} authority boundary {key} must be {expected_value!r}")

for value, label in [
    (index, "proposal artifact index"),
    (spine, "proposal program spine"),
    (handoff, "child handoff capsule"),
]:
    if value:
        check_boundary(value, label)

reader_preferences = index.get("reader_preferences") or {}
if reader_preferences.get("raw_body_escalation_required") is True:
    ok("reader preferences require escalation before raw packet body reads")
else:
    fail("reader preferences must require escalation before raw packet body reads")

if index.get("proposal_path") == rel(proposal_dir):
    ok("proposal artifact index points at proposal path")
else:
    fail("proposal artifact index proposal_path mismatch")
if spine.get("proposal_path") == rel(proposal_dir):
    ok("proposal program spine points at proposal path")
else:
    fail("proposal program spine proposal_path mismatch")

valid_stage_roles = {"spine", "current-stage-slice", "evidence-annex", "optional-reference"}
valid_inclusion_modes = {"compact-default", "current-stage", "annex-ref", "handle-only"}
seen_packet_paths = set()
for artifact in index.get("artifacts") or []:
    artifact_ref = artifact.get("path")
    if not artifact_ref:
        fail("artifact entry missing path")
        continue
    path = resolve(artifact_ref)
    if not require_file(path, f"indexed artifact {artifact_ref}"):
        continue
    seen_packet_paths.add(artifact.get("packet_relative_path"))
    actual_sha = sha256(path)
    if artifact.get("sha256") == actual_sha:
        ok(f"indexed artifact digest matches: {artifact_ref}")
    else:
        fail(f"indexed artifact digest mismatch: {artifact_ref}")
    actual_size = path.stat().st_size
    if int(artifact.get("byte_size") or -1) == actual_size:
        ok(f"indexed artifact byte size matches: {artifact_ref}")
    else:
        fail(f"indexed artifact byte size mismatch: {artifact_ref}")
    if int(artifact.get("estimated_tokens") or -1) == estimate_tokens(actual_size):
        ok(f"indexed artifact token estimate matches: {artifact_ref}")
    else:
        fail(f"indexed artifact token estimate mismatch: {artifact_ref}")
    if artifact.get("stage_role") in valid_stage_roles:
        ok(f"indexed artifact stage role valid: {artifact_ref}")
    else:
        fail(f"indexed artifact stage role invalid: {artifact_ref}")
    if artifact.get("inclusion_mode") in valid_inclusion_modes:
        ok(f"indexed artifact inclusion mode valid: {artifact_ref}")
    else:
        fail(f"indexed artifact inclusion mode invalid: {artifact_ref}")
    if artifact.get("read_raw_only_if"):
        ok(f"indexed artifact raw-read conditions present: {artifact_ref}")
    else:
        fail(f"indexed artifact raw-read conditions missing: {artifact_ref}")

for required in {"proposal.yml", f"{proposal_kind}-proposal.yml"}:
    if required in seen_packet_paths:
        ok(f"required packet artifact indexed: {required}")
    else:
        fail(f"required packet artifact missing from index: {required}")

for source_ref, recorded_sha in (index.get("source_digests") or {}).items():
    if source_ref == ".octon/generated/proposals/registry.yml":
        fail("generated proposal registry must not be an authority source digest")
        continue
    path = resolve(source_ref)
    if not require_file(path, f"source digest ref {source_ref}"):
        continue
    if recorded_sha == sha256(path):
        ok(f"source digest matches: {source_ref}")
    else:
        fail(f"source digest mismatch: {source_ref}")

for source_ref in spine.get("source_refs") or []:
    if source_ref == ".octon/generated/proposals/registry.yml":
        fail("generated proposal registry must not replace proposal manifest in spine")
for source_ref, recorded_sha in (spine.get("source_digests") or {}).items():
    path = resolve(source_ref)
    if not require_file(path, f"spine source ref {source_ref}"):
        continue
    if recorded_sha == sha256(path):
        ok(f"spine source digest matches: {source_ref}")
    else:
        fail(f"spine source digest mismatch: {source_ref}")

compact_output_roles = {item.get("artifact_role") for item in index.get("compact_outputs") or []}
for role in {"proposal-artifact-index", "proposal-program-spine"}:
    if role in compact_output_roles:
        ok(f"compact output role present: {role}")
    else:
        fail(f"compact output role missing: {role}")
if parent_program and "child-handoff-capsule" not in compact_output_roles:
    fail("child handoff capsule compact output missing for child proposal")
elif parent_program:
    ok("child handoff capsule compact output present")

if parent_program:
    child_registry = spine.get("child_registry") or {}
    registry_ref = child_registry.get("registry_ref")
    if registry_ref:
        registry_path = resolve(registry_ref)
        if require_file(registry_path, "parent child registry"):
            if child_registry.get("sha256") == sha256(registry_path):
                ok("parent child registry digest matches")
            else:
                fail("parent child registry digest mismatch")
            if child_registry.get("child_id_present") is True:
                ok("parent child registry includes child id")
            else:
                fail("parent child registry must include child id")
    else:
        fail("child proposal spine must reference parent child registry")

    compact_refs = handoff.get("compact_context_refs") or []
    ref_to_path = {
        rel(index_path): index_path,
        rel(spine_path): spine_path,
    }
    for item in compact_refs:
        artifact_ref = item.get("artifact_ref")
        if artifact_ref not in ref_to_path:
            fail(f"handoff compact context ref is unexpected: {artifact_ref}")
            continue
        if item.get("sha256") == sha256(ref_to_path[artifact_ref]):
            ok(f"handoff compact context digest matches: {artifact_ref}")
        else:
            fail(f"handoff compact context digest mismatch: {artifact_ref}")
    if handoff.get("context_hash", "").startswith("sha256:"):
        ok("handoff context hash present")
    else:
        fail("handoff context hash missing")
    if handoff.get("write_scope_map"):
        ok("handoff write scope map present")
    else:
        fail("handoff write scope map missing")

print(f"Proposal artifact spine validation summary: errors={len(errors)}")
sys.exit(1 if errors else 0)
PY
