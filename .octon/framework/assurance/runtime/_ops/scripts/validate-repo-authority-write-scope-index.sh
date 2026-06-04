#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_ROOT="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
ROOT_DIR="${OCTON_ROOT_DIR:-$DEFAULT_ROOT}"
BUNDLE_DIR=".octon/generated/proposals/repo-authority"
TARGET_CHILD_ID="token-efficiency-repo-authority-write-scope-index"

usage() {
  cat <<'EOF'
usage:
  validate-repo-authority-write-scope-index.sh [--root <repo-root>] [--bundle <path>] [--target-child <child-id>]

Validates repo-authority-graph.yml, promotion-target-index.yml, and
write-scope-index.yml compact artifacts against source refs and authority
boundary rules.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)
      ROOT_DIR="$2"
      shift 2
      ;;
    --bundle)
      BUNDLE_DIR="$2"
      shift 2
      ;;
    --target-child)
      TARGET_CHILD_ID="$2"
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

python3 - "$ROOT_DIR" "$BUNDLE_DIR" "$TARGET_CHILD_ID" <<'PY'
import hashlib
import json
import pathlib
import subprocess
import sys

root = pathlib.Path(sys.argv[1]).resolve()
bundle_arg = pathlib.Path(sys.argv[2])
target_child_id = sys.argv[3]
bundle_dir = bundle_arg if bundle_arg.is_absolute() else root / bundle_arg
bundle_dir = bundle_dir.resolve()

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

repo_graph_path = bundle_dir / "repo-authority-graph.yml"
promotion_index_path = bundle_dir / "promotion-target-index.yml"
write_scope_path = bundle_dir / "write-scope-index.yml"

for path, label in [
    (repo_graph_path, "repo authority graph"),
    (promotion_index_path, "promotion target index"),
    (write_scope_path, "write-scope index"),
]:
    require_file(path, label)

repo_graph = load_yaml(repo_graph_path) if repo_graph_path.is_file() else {}
promotion_index = load_yaml(promotion_index_path) if promotion_index_path.is_file() else {}
write_scope_index = load_yaml(write_scope_path) if write_scope_path.is_file() else {}

expected_schemas = {
    "repo authority graph": (repo_graph, "octon-repo-authority-graph-v1"),
    "promotion target index": (promotion_index, "octon-promotion-target-index-v1"),
    "write-scope index": (write_scope_index, "octon-write-scope-index-v1"),
}
for label, (value, expected) in expected_schemas.items():
    if value.get("schema_version") == expected:
        ok(f"{label} schema is {expected}")
    else:
        fail(f"{label} schema must be {expected}")
    if value.get("authority_status") == "generated-derived-read-model-not-authority":
        ok(f"{label} authority status is non-authority")
    else:
        fail(f"{label} authority status must be generated-derived-read-model-not-authority")

def check_boundary(value, label):
    boundary = value.get("authority_boundary") or {}
    expected = {
        "replaces_source_evidence": False,
        "authorizes_execution": False,
        "proposal_input_authority": "non-authoritative",
        "generated_output_authority": "derived-only",
        "raw_evidence_retained": True,
        "engine_authorization_preserved": True,
    }
    for key, expected_value in expected.items():
        if boundary.get(key) == expected_value:
            ok(f"{label} authority boundary {key}")
        else:
            fail(f"{label} authority boundary {key} must be {expected_value!r}")

for value, label in [
    (repo_graph, "repo authority graph"),
    (promotion_index, "promotion target index"),
    (write_scope_index, "write-scope index"),
]:
    if value:
        check_boundary(value, label)
        prefs = value.get("reader_preferences") or {}
        if prefs.get("raw_body_escalation_required") is True:
            ok(f"{label} raw body escalation required")
        else:
            fail(f"{label} raw body escalation must be required")

seen_sources = {}
for value, label in [
    (repo_graph, "repo authority graph"),
    (promotion_index, "promotion target index"),
    (write_scope_index, "write-scope index"),
]:
    for item in value.get("source_refs") or []:
        ref = item.get("artifact_ref")
        recorded = item.get("sha256")
        if not ref:
            fail(f"{label} source ref missing artifact_ref")
            continue
        path = resolve(ref)
        if not require_file(path, f"{label} source {ref}"):
            continue
        actual = sha256(path)
        if recorded == actual:
            ok(f"{label} source digest matches: {ref}")
        else:
            fail(f"{label} source digest mismatch: {ref}")
        seen_sources[ref] = actual

def check_entry_boundary(entry, label):
    path = str(entry.get("path") or "")
    family = entry.get("target_family")
    posture = entry.get("authority_posture")
    authored = entry.get("authored_authority")
    risk_flags = set(entry.get("risk_flags") or [])
    if path.startswith(".octon/framework/") or path.startswith(".octon/instance/"):
        if authored is True and "authored-authority" in str(entry.get("boundary_status")):
            ok(f"{label} authored authority classification: {path}")
        else:
            fail(f"{label} authored authority misclassified: {path}")
    if path.startswith(".octon/generated/"):
        if authored is False and str(posture).startswith("derived") and "generated-target-derived-only" in risk_flags:
            ok(f"{label} generated target remains derived-only: {path}")
        else:
            fail(f"{label} generated target misclassified as authority: {path}")
    if path.startswith(".octon/inputs/"):
        if authored is False and "input-target-non-authority" in risk_flags:
            ok(f"{label} input target remains non-authority: {path}")
        else:
            fail(f"{label} input target misclassified as authority: {path}")
    if path.startswith(".octon/state/"):
        if authored is False and family and str(family).startswith("state"):
            ok(f"{label} state target remains non-authored: {path}")
        else:
            fail(f"{label} state target misclassified: {path}")

target_proposal = None
for proposal in promotion_index.get("proposals") or []:
    for target in proposal.get("targets") or []:
        check_entry_boundary(target, f"promotion target {proposal.get('proposal_id')}")
    if proposal.get("proposal_id") == target_child_id:
        target_proposal = proposal

if target_proposal:
    ok(f"promotion target index includes target child proposal: {target_child_id}")
    expected_targets = {
        ".octon/framework/cognition/_meta/architecture/",
        ".octon/framework/engine/runtime/spec/",
        ".octon/framework/assurance/runtime/_ops/scripts/",
        ".octon/framework/assurance/runtime/_ops/tests/",
    }
    present_targets = {target.get("path") for target in target_proposal.get("targets") or []}
    for expected in expected_targets:
        if expected in present_targets:
            ok(f"target child promotion target indexed: {expected}")
        else:
            fail(f"target child promotion target missing from index: {expected}")
else:
    fail(f"promotion target index includes target child proposal: {target_child_id}")

target_child = None
for child in write_scope_index.get("children") or []:
    for scope in child.get("write_scopes") or []:
        check_entry_boundary(scope, f"write scope {child.get('child_id')}")
    for target in child.get("promotion_targets") or []:
        check_entry_boundary(target, f"child promotion target {child.get('child_id')}")
    if child.get("child_id") == target_child_id:
        target_child = child

if target_child:
    ok(f"write-scope index includes target child: {target_child_id}")
    expected_scopes = {
        ".octon/framework/cognition/_meta/architecture/",
        ".octon/framework/engine/runtime/spec/",
        ".octon/framework/assurance/runtime/_ops/scripts/",
        ".octon/framework/assurance/runtime/_ops/tests/",
    }
    present_scopes = {scope.get("path") for scope in target_child.get("write_scopes") or []}
    for expected in expected_scopes:
        if expected in present_scopes:
            ok(f"target child write scope indexed: {expected}")
        else:
            fail(f"target child write scope missing from index: {expected}")
    if target_child.get("coverage_status") == "promotion-targets-contained-by-write-scopes":
        ok("target child promotion targets are contained by write scopes")
    else:
        fail("target child promotion targets must be contained by write scopes")
else:
    fail(f"write-scope index includes target child: {target_child_id}")

for path, value in [
    (repo_graph_path, repo_graph),
    (promotion_index_path, promotion_index),
    (write_scope_path, write_scope_index),
]:
    if value.get("artifact_ref") == rel(path):
        ok(f"artifact_ref matches generated path: {rel(path)}")
    else:
        fail(f"artifact_ref mismatch for {rel(path)}")

print(f"Repo authority index validation summary: errors={len(errors)}")
sys.exit(1 if errors else 0)
PY
