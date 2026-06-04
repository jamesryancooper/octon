#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_ROOT="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
ROOT_DIR="${OCTON_ROOT_DIR:-$DEFAULT_ROOT}"
MODE=""
OUTPUT_DIR=".octon/generated/proposals/repo-authority"

usage() {
  cat <<'EOF'
usage:
  generate-repo-authority-write-scope-index.sh --write [--root <repo-root>] [--output-dir <path>]
  generate-repo-authority-write-scope-index.sh --check [--root <repo-root>] [--output-dir <path>]

Generates digest-bound advisory repo authority and write-scope artifacts:
  repo-authority-graph.yml
  promotion-target-index.yml
  write-scope-index.yml
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)
      ROOT_DIR="$2"
      shift 2
      ;;
    --output-dir)
      OUTPUT_DIR="$2"
      shift 2
      ;;
    --write)
      MODE="write"
      shift
      ;;
    --check)
      MODE="check"
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

if [[ -z "$MODE" ]]; then
  usage >&2
  exit 2
fi

python3 - "$ROOT_DIR" "$OUTPUT_DIR" "$MODE" <<'PY'
import difflib
import hashlib
import json
import pathlib
import subprocess
import sys

root = pathlib.Path(sys.argv[1]).resolve()
output_arg = pathlib.Path(sys.argv[2])
mode = sys.argv[3]
output_dir = output_arg if output_arg.is_absolute() else root / output_arg
output_dir = output_dir.resolve()

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
        fail(f"YAML parse failed for {rel(path)}: {result.stderr.strip()}")
        return {}
    try:
        return json.loads(result.stdout or "{}")
    except json.JSONDecodeError as exc:
        fail(f"YAML JSON decode failed for {rel(path)}: {exc}")
        return {}

authority_boundary = {
    "authorizes_execution": False,
    "engine_authorization_preserved": True,
    "generated_output_authority": "derived-only",
    "proposal_input_authority": "non-authoritative",
    "raw_evidence_retained": True,
    "replaces_source_evidence": False,
}

freshness = {
    "mode": "source-digest-bound",
    "source_digest_bound": True,
}

reader_preferences = {
    "default_reader": "compact-graph-first",
    "raw_body_escalation_required": True,
    "raw_body_allowed_when": [
        "source-digest-mismatch",
        "stale-compact-artifact",
        "authority-ambiguity",
        "validator-dispute",
        "context-pack-audit",
    ],
}

failure_behavior = [
    "fail-closed-on-missing-source",
    "fail-closed-on-source-digest-mismatch",
    "fail-closed-on-stale-compact-artifact",
    "fail-closed-on-authority-boundary-violation",
    "escalate-before-reading-raw-proposal-body",
]

producer = {
    "name": "generate-repo-authority-write-scope-index.sh",
    "version": "repo-authority-write-scope-index-v1",
}

artifact_paths = {
    "repo-authority-graph": output_dir / "repo-authority-graph.yml",
    "promotion-target-index": output_dir / "promotion-target-index.yml",
    "write-scope-index": output_dir / "write-scope-index.yml",
}

required_authority_refs = [
    ".octon/framework/cognition/_meta/architecture/contract-registry.yml",
    ".octon/framework/engine/runtime/spec/context-pack-builder-v1.md",
    ".octon/framework/engine/runtime/spec/repo-authority-write-scope-index-v1.md",
    ".octon/framework/engine/runtime/spec/repo-authority-graph-v1.schema.json",
    ".octon/framework/engine/runtime/spec/promotion-target-index-v1.schema.json",
    ".octon/framework/engine/runtime/spec/write-scope-index-v1.schema.json",
    ".octon/framework/constitution/precedence/normative.yml",
    ".octon/framework/constitution/precedence/epistemic.yml",
    ".octon/framework/constitution/obligations/fail-closed.yml",
    ".octon/framework/constitution/obligations/evidence.yml",
]

child_registry_ref = "/".join([
    ".octon",
    "inputs",
    "exploratory",
    "proposals",
    "architecture",
    "token-efficient-proposal-program-controller",
    "resources",
    "child-packet-index.yml",
])

for ref in required_authority_refs:
    if not resolve(ref).is_file():
        fail(f"required source missing: {ref}")

if errors:
    print(f"Repo authority index generation summary: errors={len(errors)}")
    sys.exit(1)

registry = load_yaml(resolve(".octon/framework/cognition/_meta/architecture/contract-registry.yml"))
child_registry = load_yaml(resolve(child_registry_ref)) if resolve(child_registry_ref).is_file() else {}

def source_record(role, ref, source_class, required=True):
    path = resolve(ref)
    return {
        "artifact_ref": ref,
        "artifact_role": role,
        "required": required,
        "sha256": sha256(path),
        "source_class": source_class,
    }

source_refs = []
for ref in required_authority_refs:
    source_refs.append(source_record("durable-authority", ref, "authored-authority", True))
if resolve(child_registry_ref).is_file():
    source_refs.append(source_record("proposal-program-child-registry", child_registry_ref, "non-authoritative-proposal-input", False))

proposal_manifest_paths = []
proposal_root = root / ".octon/inputs/exploratory/proposals"
if proposal_root.is_dir():
    for path in sorted(proposal_root.glob("*/*/proposal.yml")):
        if "/.archive/" in str(path):
            continue
        proposal_manifest_paths.append(path)
        source_refs.append(source_record("active-proposal-manifest", rel(path), "non-authoritative-proposal-input", False))

source_refs = sorted(source_refs, key=lambda item: (item["artifact_role"], item["artifact_ref"]))
source_digest_basis = "\n".join(f"{item['artifact_ref']} {item['sha256']}" for item in source_refs)
bundle_digest = "sha256:" + hashlib.sha256(source_digest_basis.encode()).hexdigest()
generated_at = "deterministic-from-source-digests:" + bundle_digest

def classify_path(path):
    if path.startswith("/"):
        return {
            "target_family": "external-absolute",
            "authority_posture": "outside-repo-boundary",
            "authored_authority": False,
            "boundary_status": "external-risk",
            "risk_flags": ["absolute-path-target"],
        }
    if path.startswith(".octon/framework/"):
        return {
            "target_family": "framework",
            "authority_posture": "portable-authored-authority",
            "authored_authority": True,
            "boundary_status": "authored-authority-target",
            "risk_flags": [],
        }
    if path.startswith(".octon/instance/"):
        return {
            "target_family": "instance",
            "authority_posture": "repo-specific-authored-authority",
            "authored_authority": True,
            "boundary_status": "authored-authority-target",
            "risk_flags": [],
        }
    if path.startswith(".octon/state/control/"):
        return {
            "target_family": "state-control",
            "authority_posture": "mutable-operational-truth",
            "authored_authority": False,
            "boundary_status": "mutable-control-target",
            "risk_flags": ["control-target-requires-run-authority"],
        }
    if path.startswith(".octon/state/evidence/"):
        return {
            "target_family": "state-evidence",
            "authority_posture": "retained-evidence",
            "authored_authority": False,
            "boundary_status": "retained-evidence-target",
            "risk_flags": ["evidence-target-not-authority"],
        }
    if path.startswith(".octon/state/continuity/"):
        return {
            "target_family": "state-continuity",
            "authority_posture": "resumption-context",
            "authored_authority": False,
            "boundary_status": "continuity-state-target",
            "risk_flags": ["continuity-target-not-authority"],
        }
    if path.startswith(".octon/state/"):
        return {
            "target_family": "state",
            "authority_posture": "operational-state",
            "authored_authority": False,
            "boundary_status": "state-target",
            "risk_flags": ["state-target-requires-control-or-evidence-classification"],
        }
    if path.startswith(".octon/generated/effective/"):
        return {
            "target_family": "generated-effective",
            "authority_posture": "derived-runtime-handle",
            "authored_authority": False,
            "boundary_status": "derived-generated-target",
            "risk_flags": ["generated-target-derived-only", "requires-publication-freshness"],
        }
    if path.startswith(".octon/generated/"):
        return {
            "target_family": "generated",
            "authority_posture": "derived-projection",
            "authored_authority": False,
            "boundary_status": "derived-generated-target",
            "risk_flags": ["generated-target-derived-only"],
        }
    if path.startswith(".octon/inputs/exploratory/"):
        return {
            "target_family": "inputs-exploratory",
            "authority_posture": "lineage-only-input",
            "authored_authority": False,
            "boundary_status": "non-authoritative-input-target",
            "risk_flags": ["input-target-non-authority", "proposal-path-dependency-risk"],
        }
    if path.startswith(".octon/inputs/additive/"):
        return {
            "target_family": "inputs-additive",
            "authority_posture": "untrusted-additive-input",
            "authored_authority": False,
            "boundary_status": "non-authoritative-input-target",
            "risk_flags": ["input-target-non-authority", "publication-required-before-runtime-use"],
        }
    if path.startswith(".octon/inputs/"):
        return {
            "target_family": "inputs",
            "authority_posture": "non-authoritative-input",
            "authored_authority": False,
            "boundary_status": "non-authoritative-input-target",
            "risk_flags": ["input-target-non-authority"],
        }
    if path.startswith(".github/"):
        return {
            "target_family": "github-projection",
            "authority_posture": "host-projection",
            "authored_authority": False,
            "boundary_status": "repo-local-projection-target",
            "risk_flags": ["host-projection-not-authority"],
        }
    return {
        "target_family": "repo-local",
        "authority_posture": "repo-local-surface",
        "authored_authority": False,
        "boundary_status": "repo-local-target",
        "risk_flags": [],
    }

def classified_path(path):
    result = classify_path(path)
    return {
        "path": path,
        "target_family": result["target_family"],
        "authority_posture": result["authority_posture"],
        "authored_authority": result["authored_authority"],
        "boundary_status": result["boundary_status"],
        "risk_flags": result["risk_flags"],
    }

def contains_scope(scope, target):
    if scope == target:
        return True
    normalized_scope = scope if scope.endswith("/") else scope + "/"
    return target.startswith(normalized_scope)

def coverage_status(write_scopes, promotion_targets):
    if not promotion_targets:
        return "no-promotion-targets-declared"
    missing = [target for target in promotion_targets if not any(contains_scope(scope, target) for scope in write_scopes)]
    if not missing:
        return "promotion-targets-contained-by-write-scopes"
    return "promotion-targets-outside-write-scopes"

def increment(summary, family):
    summary[family] = summary.get(family, 0) + 1

proposal_entries = []
target_family_summary = {}
for manifest_path in proposal_manifest_paths:
    proposal = load_yaml(manifest_path)
    proposal_id = proposal.get("proposal_id") or manifest_path.parent.name
    proposal_kind = proposal.get("proposal_kind") or manifest_path.parent.parent.name
    status = proposal.get("status") or "unknown"
    promotion_scope = proposal.get("promotion_scope") or "unknown"
    targets = []
    for target in proposal.get("promotion_targets") or []:
        entry = classified_path(str(target))
        increment(target_family_summary, entry["target_family"])
        targets.append(entry)
    proposal_entries.append({
        "proposal_id": proposal_id,
        "proposal_kind": proposal_kind,
        "promotion_scope": promotion_scope,
        "proposal_ref": rel(manifest_path),
        "proposal_sha256": sha256(manifest_path),
        "status": status,
        "target_count": len(targets),
        "targets": targets,
    })

proposal_entries = sorted(proposal_entries, key=lambda item: (item["proposal_kind"], item["proposal_id"]))

children = []
write_scope_family_summary = {}
program_ref = child_registry_ref if resolve(child_registry_ref).is_file() else "absent"
for child in child_registry.get("children") or []:
    child_id = child.get("child_id") or "unknown-child"
    child_path = str(child.get("path") or "")
    child_manifest = resolve(child_path) / "proposal.yml" if child_path else None
    child_promotion_targets = []
    if child_manifest and child_manifest.is_file():
        child_proposal = load_yaml(child_manifest)
        child_promotion_targets = [str(item) for item in child_proposal.get("promotion_targets") or []]
    write_scopes = [str(item) for item in child.get("write_scopes") or []]
    write_entries = []
    for scope in write_scopes:
        entry = classified_path(scope)
        increment(write_scope_family_summary, entry["target_family"])
        write_entries.append(entry)
    promotion_entries = [classified_path(target) for target in child_promotion_targets]
    children.append({
        "child_id": child_id,
        "coverage_status": coverage_status(write_scopes, child_promotion_targets),
        "dependencies": [str(item) for item in child.get("dependencies") or []],
        "group_id": str(child.get("group_id") or "unknown"),
        "model_route_default": str(child.get("model_route_default") or ""),
        "path": child_path,
        "phase_id": str(child.get("phase_id") or "unknown"),
        "promotion_target_count": len(promotion_entries),
        "promotion_targets": promotion_entries,
        "token_ceiling": str(child.get("token_ceiling") or ""),
        "write_scope_count": len(write_entries),
        "write_scopes": write_entries,
    })

children = sorted(children, key=lambda item: item["child_id"])

class_roots = []
for key, value in sorted((registry.get("class_roots") or {}).items()):
    if key == "resolution_order" or not isinstance(value, dict):
        continue
    class_roots.append({
        "authored_authority": bool(value.get("authored_authority", False)),
        "authority_class": str(value.get("authority_class") or "unknown"),
        "class_id": key,
        "root": str(value.get("root") or ""),
    })

surface_classes = []
for key, value in sorted((registry.get("steady_state_surface_classes") or {}).items()):
    if not isinstance(value, dict):
        continue
    surface_classes.append({
        "authority_posture": str(value.get("authority_posture") or "unknown"),
        "canonical_roots": [str(item) for item in value.get("canonical_roots") or []],
        "surface_class": key,
    })

path_rules = [
    {
        "authored_authority": classify_path(prefix)["authored_authority"],
        "authority_posture": classify_path(prefix)["authority_posture"],
        "path_prefix": prefix,
        "target_family": classify_path(prefix)["target_family"],
    }
    for prefix in [
        ".octon/framework/",
        ".octon/instance/",
        ".octon/state/control/",
        ".octon/state/evidence/",
        ".octon/state/continuity/",
        ".octon/generated/effective/",
        ".octon/generated/",
        ".octon/inputs/exploratory/",
        ".octon/inputs/additive/",
        ".github/",
    ]
]

common = {
    "authority_boundary": authority_boundary,
    "authority_status": "generated-derived-read-model-not-authority",
    "failure_behavior": failure_behavior,
    "freshness": freshness,
    "generated_at": generated_at,
    "producer": producer,
    "reader_preferences": reader_preferences,
    "source_refs": source_refs,
}

repo_authority_graph = {
    **common,
    "artifact_kind": "repo-authority-graph",
    "artifact_ref": rel(artifact_paths["repo-authority-graph"]),
    "class_roots": class_roots,
    "path_rules": path_rules,
    "schema_ref": ".octon/framework/engine/runtime/spec/repo-authority-graph-v1.schema.json",
    "schema_version": "octon-repo-authority-graph-v1",
    "surface_classes": surface_classes,
}

promotion_target_index = {
    **common,
    "artifact_kind": "promotion-target-index",
    "artifact_ref": rel(artifact_paths["promotion-target-index"]),
    "proposal_count": len(proposal_entries),
    "proposals": proposal_entries,
    "schema_ref": ".octon/framework/engine/runtime/spec/promotion-target-index-v1.schema.json",
    "schema_version": "octon-promotion-target-index-v1",
    "target_family_summary": dict(sorted(target_family_summary.items())),
}

write_scope_index = {
    **common,
    "artifact_kind": "write-scope-index",
    "artifact_ref": rel(artifact_paths["write-scope-index"]),
    "child_count": len(children),
    "children": children,
    "program_ref": program_ref,
    "schema_ref": ".octon/framework/engine/runtime/spec/write-scope-index-v1.schema.json",
    "schema_version": "octon-write-scope-index-v1",
    "target_family_summary": dict(sorted(write_scope_family_summary.items())),
}

outputs = {
    artifact_paths["repo-authority-graph"]: stable_json(repo_authority_graph),
    artifact_paths["promotion-target-index"]: stable_json(promotion_target_index),
    artifact_paths["write-scope-index"]: stable_json(write_scope_index),
}

if mode == "write":
    output_dir.mkdir(parents=True, exist_ok=True)
    for path, body in outputs.items():
        path.write_text(body)
        ok(f"wrote {rel(path)}")
elif mode == "check":
    for path, body in outputs.items():
        if not path.is_file():
            fail(f"generated artifact missing: {rel(path)}")
            continue
        current = path.read_text()
        if current == body:
            ok(f"generated artifact fresh: {rel(path)}")
        else:
            fail(f"generated artifact stale: {rel(path)}")
            diff = difflib.unified_diff(
                current.splitlines(),
                body.splitlines(),
                fromfile=f"current/{rel(path)}",
                tofile=f"expected/{rel(path)}",
                lineterm="",
            )
            for line in list(diff)[:120]:
                print(line)
else:
    fail(f"unsupported mode: {mode}")

print(f"Repo authority index generation summary: errors={len(errors)}")
sys.exit(1 if errors else 0)
PY
