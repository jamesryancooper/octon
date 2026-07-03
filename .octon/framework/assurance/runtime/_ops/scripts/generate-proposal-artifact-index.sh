#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_ROOT="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
ROOT_DIR="${OCTON_ROOT_DIR:-$DEFAULT_ROOT}"
PROPOSAL_PATH=""
MODE=""

usage() {
  cat <<'EOF'
usage:
  generate-proposal-artifact-index.sh --proposal <proposal-path> --write [--root <repo-root>]
  generate-proposal-artifact-index.sh --proposal <proposal-path> --check [--root <repo-root>]

Generates digest-bound proposal compact artifacts under:
  .octon/generated/proposals/artifacts/<proposal-kind>/<proposal-id>/
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

if [[ -z "$PROPOSAL_PATH" || -z "$MODE" ]]; then
  usage >&2
  exit 2
fi

python3 - "$ROOT_DIR" "$PROPOSAL_PATH" "$MODE" <<'PY'
import difflib
import hashlib
import json
import pathlib
import re
import shutil
import subprocess
import sys
import tempfile

root = pathlib.Path(sys.argv[1]).resolve()
proposal_arg = pathlib.Path(sys.argv[2])
mode = sys.argv[3]
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

def sha256(path):
    return "sha256:" + hashlib.sha256(path.read_bytes()).hexdigest()

def estimate_tokens(size):
    return (int(size) + 3) // 4

def stable_json(value):
    return json.dumps(value, indent=2, sort_keys=True) + "\n"

def write_if_changed(destination, source):
    if destination.is_file() and destination.read_bytes() == source.read_bytes():
        return "fresh"
    shutil.copyfile(source, destination)
    return "written"

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

def receipt_fields(path):
    fields = {}
    if not path.is_file():
        return fields
    for line in path.read_text(errors="replace").splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("#") or ":" not in stripped:
            continue
        key, value = stripped.split(":", 1)
        key = key.strip()
        if key.replace("_", "").replace("-", "").isalnum():
            fields[key] = value.strip().strip("'\"")
    return fields

def first_existing(paths):
    for path in paths:
        if path.is_file():
            return path
    return None

proposal_id_pattern = re.compile(r"^[a-z][a-z0-9]*(-[a-z0-9]+)*$")
proposal_kind_dirs = ["architecture", "design", "migration", "policy"]

def resolve_dependency_proposal(dependency_id, ref_type, source_field):
    if not isinstance(dependency_id, str) or not proposal_id_pattern.match(dependency_id):
        fail(f"dependency ref is not a canonical proposal id in {source_field}: {dependency_id!r}")
        return None

    matches = []
    proposal_root = root / ".octon/inputs/exploratory/proposals"
    for archive_prefix in ["", ".archive"]:
        for kind in proposal_kind_dirs:
            if archive_prefix:
                candidate_dir = proposal_root / archive_prefix / kind / dependency_id
            else:
                candidate_dir = proposal_root / kind / dependency_id
            manifest = candidate_dir / "proposal.yml"
            if not manifest.is_file():
                continue
            candidate = load_yaml(manifest)
            if candidate.get("proposal_id") != dependency_id:
                fail(f"dependency manifest id mismatch for {dependency_id}: {rel(manifest)}")
                continue
            matches.append((kind, candidate_dir, manifest))

    if not matches:
        fail(f"dependency proposal exists for {source_field}: {dependency_id}")
        return None
    if len(matches) > 1:
        fail(f"dependency proposal id is ambiguous for {source_field}: {dependency_id}")
        return None

    kind, dependency_dir, manifest = matches[0]
    return {
        "ref_type": ref_type,
        "proposal_id": dependency_id,
        "proposal_kind": kind,
        "proposal_path": rel(dependency_dir),
        "manifest_ref": rel(manifest),
        "manifest_sha256": sha256(manifest),
        "source_field": source_field,
        "required": True,
    }

proposal_manifest = proposal_dir / "proposal.yml"
if not proposal_manifest.is_file():
    fail(f"proposal manifest missing: {proposal_manifest}")
    print(f"Proposal artifact generation summary: errors={len(errors)}")
    sys.exit(1)

proposal = load_yaml(proposal_manifest)
proposal_id = proposal.get("proposal_id") or proposal_dir.name
proposal_kind = proposal.get("proposal_kind") or "unknown"
status = proposal.get("status") or "unknown"
promotion_targets = proposal.get("promotion_targets") or []
parent_program = proposal.get("parent_program") or ""
related_proposals = proposal.get("related_proposals") or []
source_lineage = proposal.get("source_lineage") or []
evidence_requirements = proposal.get("evidence_requirements") or []
validation_gates = proposal.get("validation_gates") or []
dependency_refs = []
if parent_program:
    resolved_parent = resolve_dependency_proposal(parent_program, "parent_program", "proposal.yml#parent_program")
    if resolved_parent:
        dependency_refs.append(resolved_parent)
if not isinstance(related_proposals, list):
    fail("related_proposals must be a list when present")
    related_proposals = []
for related_id in related_proposals:
    resolved_related = resolve_dependency_proposal(related_id, "related_proposal", "proposal.yml#related_proposals")
    if resolved_related:
        dependency_refs.append(resolved_related)

subtype_manifest = first_existing([
    proposal_dir / f"{proposal_kind}-proposal.yml",
    proposal_dir / "architecture-proposal.yml",
    proposal_dir / "design-proposal.yml",
    proposal_dir / "migration-proposal.yml",
    proposal_dir / "policy-proposal.yml",
])

output_dir = root / ".octon/generated/proposals/artifacts" / proposal_kind / proposal_id
artifact_index_path = output_dir / "proposal-artifact-index.yml"
program_spine_path = output_dir / "proposal-program-spine.yml"
handoff_capsule_path = output_dir / "child-handoff-capsule.yml"

authority_boundary = {
    "replaces_source_evidence": False,
    "authorizes_execution": False,
    "proposal_input_authority": "non-authoritative",
    "generated_output_authority": "derived-only",
    "raw_evidence_retained": True,
    "generated_registry_replaces_manifest": False,
}

failure_behavior = [
    "fail-closed-on-source-missing",
    "fail-closed-on-source-digest-mismatch",
    "fail-closed-on-stale-compact-artifact",
    "fail-closed-on-authority-boundary-violation",
    "escalate-before-reading-raw-packet-body",
]

def classify_packet_file(path):
    rel_packet = path.relative_to(proposal_dir).as_posix()
    if rel_packet == "proposal.yml":
        return ("proposal-manifest", "spine", "compact-default", ["all-routes"])
    if rel_packet.endswith("-proposal.yml"):
        return ("subtype-manifest", "spine", "compact-default", ["all-routes"])
    if rel_packet == "README.md":
        return ("overview", "optional-reference", "handle-only", ["orientation"])
    if rel_packet == "navigation/source-of-truth-map.md":
        return ("source-of-truth-map", "spine", "compact-default", ["all-routes"])
    if rel_packet == "navigation/artifact-catalog.md":
        return ("artifact-catalog", "spine", "compact-default", ["all-routes"])
    if rel_packet.startswith("architecture/"):
        role = pathlib.Path(rel_packet).stem.replace("_", "-")
        if role in {"target-architecture", "implementation-plan", "acceptance-criteria"}:
            return (role, "current-stage-slice", "current-stage", ["run-packet-implementation", "verify"])
        if role == "rollback-posture":
            return (role, "evidence-annex", "annex-ref", ["run-packet-implementation", "closeout"])
        return (role, "optional-reference", "handle-only", ["architecture-review"])
    if rel_packet.startswith("support/"):
        role = pathlib.Path(rel_packet).stem.replace("_", "-")
        if role in {"proposal-review", "implementation-grade-completeness-review"}:
            return (role, "evidence-annex", "annex-ref", ["run-packet-implementation", "promote-proposal"])
        if role in {"executable-implementation-prompt", "implementation-conformance-review", "post-implementation-drift-churn-review", "validation", "implementation-run"}:
            return (role, "current-stage-slice", "current-stage", ["run-packet-implementation", "verify", "closeout"])
        return (role, "evidence-annex", "annex-ref", ["support-review"])
    if rel_packet.startswith("resources/"):
        return ("resource", "optional-reference", "handle-only", ["lineage-audit"])
    return ("packet-file", "optional-reference", "handle-only", ["operator-audit"])

def raw_read_conditions(stage_role):
    if stage_role == "spine":
        return ["manifest-digest-mismatch", "status-or-target-dispute", "validator-dispute"]
    if stage_role == "current-stage-slice":
        return ["current-route-needs-full-context", "slice-digest-mismatch", "validator-dispute"]
    if stage_role == "evidence-annex":
        return ["receipt-freshness-dispute", "evidence-audit-request", "validator-dispute"]
    return ["operator-audit-request", "context-gap", "validator-dispute"]

packet_files = sorted(path for path in proposal_dir.rglob("*") if path.is_file())
artifact_rows = []
source_digests = {}
for path in packet_files:
    file_rel = rel(path)
    role, stage_role, inclusion_mode, stage_relevance = classify_packet_file(path)
    digest = sha256(path)
    source_digests[file_rel] = digest
    artifact_rows.append({
        "path": file_rel,
        "packet_relative_path": path.relative_to(proposal_dir).as_posix(),
        "role": role,
        "sha256": digest,
        "byte_size": path.stat().st_size,
        "estimated_tokens": estimate_tokens(path.stat().st_size),
        "stage_role": stage_role,
        "inclusion_mode": inclusion_mode,
        "stage_relevance": stage_relevance,
        "read_raw_only_if": raw_read_conditions(stage_role),
        "freshness_state": "digest-bound",
    })

required_source_paths = [proposal_manifest]
if subtype_manifest:
    required_source_paths.append(subtype_manifest)
for relative in [
    "navigation/source-of-truth-map.md",
    "navigation/artifact-catalog.md",
    "architecture/implementation-plan.md",
    "architecture/acceptance-criteria.md",
    "support/proposal-review.md",
    "support/implementation-grade-completeness-review.md",
    "support/executable-implementation-prompt.md",
]:
    candidate = proposal_dir / relative
    if candidate.is_file():
        required_source_paths.append(candidate)

source_refs = sorted({rel(path) for path in required_source_paths})
required_source_digests = {source_ref: sha256(root / source_ref) for source_ref in source_refs}

compact_outputs = [
    {
        "artifact_role": "proposal-artifact-index",
        "artifact_ref": rel(artifact_index_path),
        "schema_version": "octon-proposal-artifact-index-v1",
        "authority_status": "derived-read-model-only",
        "validation": ".octon/framework/assurance/runtime/_ops/scripts/validate-proposal-artifact-index-spine.sh",
    },
    {
        "artifact_role": "proposal-program-spine",
        "artifact_ref": rel(program_spine_path),
        "schema_version": "octon-proposal-program-spine-v1",
        "authority_status": "derived-read-model-only",
        "validation": ".octon/framework/assurance/runtime/_ops/scripts/validate-proposal-artifact-index-spine.sh",
    },
]
if parent_program:
    compact_outputs.append({
        "artifact_role": "child-handoff-capsule",
        "artifact_ref": rel(handoff_capsule_path),
        "schema_version": "octon-child-handoff-capsule-v1",
        "authority_status": "derived-read-model-only",
        "validation": ".octon/framework/assurance/runtime/_ops/scripts/validate-proposal-artifact-index-spine.sh",
    })

artifact_index = {
    "schema_version": "octon-proposal-artifact-index-v1",
    "proposal_id": proposal_id,
    "proposal_kind": proposal_kind,
    "proposal_path": rel(proposal_dir),
    "producer": ".octon/framework/assurance/runtime/_ops/scripts/generate-proposal-artifact-index.sh",
    "output_ref": rel(artifact_index_path),
    "freshness": {
        "mode": "digest-bound",
        "generated_at": "deterministic-from-source-digests",
    },
    "authority_boundary": authority_boundary,
    "reader_preferences": {
        "planner": "read proposal-artifact-index.yml and proposal-program-spine.yml before packet bodies",
        "executor": "read current-stage slices first; use raw packet refs only for disputes",
        "recovery": "read child-handoff-capsule.yml before parent summaries or stale packet history",
        "closeout": "verify compact digests before dereferencing raw packet evidence",
        "raw_body_policy": "handle-only-by-default",
        "raw_body_escalation_required": True,
    },
    "source_refs": source_refs,
    "source_digests": required_source_digests,
    "targeted_dependency_refs": dependency_refs,
    "artifact_count": len(artifact_rows),
    "artifacts": artifact_rows,
    "compact_outputs": compact_outputs,
    "validation": {
        "validator": ".octon/framework/assurance/runtime/_ops/scripts/validate-proposal-artifact-index-spine.sh",
        "negative_controls": [
            "generated-registry-cannot-replace-manifest",
            "source-digest-mismatch-fails-closed",
            "missing-child-handoff-fails-when-parent-program-present",
        ],
    },
    "failure_behavior": failure_behavior,
}

proposal_review = receipt_fields(proposal_dir / "support/proposal-review.md")
readiness_review = receipt_fields(proposal_dir / "support/implementation-grade-completeness-review.md")
receipt_paths = sorted((proposal_dir / "support").glob("*.md")) if (proposal_dir / "support").is_dir() else []
receipt_digests = [
    {
        "receipt_ref": rel(path),
        "sha256": sha256(path),
        "byte_size": path.stat().st_size,
        "estimated_tokens": estimate_tokens(path.stat().st_size),
    }
    for path in receipt_paths
]

parent_child_registry = None
child_registry_digest = ""
child_id_present = False
if parent_program:
    parent_path = root / ".octon/inputs/exploratory/proposals/architecture" / parent_program
    if not parent_path.is_dir():
        archive_parent_path = root / ".octon/inputs/exploratory/proposals/.archive/architecture" / parent_program
        archive_manifest = archive_parent_path / "proposal.yml"
        if archive_manifest.is_file():
            archived_parent = load_yaml(archive_manifest)
            expected_original = f".octon/inputs/exploratory/proposals/architecture/{parent_program}"
            if archived_parent.get("archive", {}).get("original_path") == expected_original:
                parent_path = archive_parent_path
    candidate = parent_path / "resources/child-packet-index.yml"
    if candidate.is_file():
        parent_child_registry = candidate
        child_registry_digest = sha256(candidate)
        child_id_present = proposal_id in candidate.read_text(errors="replace")

spine_source_refs = list(source_refs)
if parent_child_registry:
    spine_source_refs.append(rel(parent_child_registry))
spine_source_refs = sorted(set(spine_source_refs))
spine_source_digests = {source_ref: sha256(root / source_ref) for source_ref in spine_source_refs}

program_spine = {
    "schema_version": "octon-proposal-program-spine-v1",
    "proposal_id": proposal_id,
    "proposal_kind": proposal_kind,
    "proposal_path": rel(proposal_dir),
    "status": status,
    "producer": ".octon/framework/assurance/runtime/_ops/scripts/generate-proposal-artifact-index.sh",
    "output_ref": rel(program_spine_path),
    "freshness": {
        "mode": "digest-bound",
        "generated_at": "deterministic-from-source-digests",
    },
    "authority_boundary": authority_boundary,
    "source_refs": spine_source_refs,
    "source_digests": spine_source_digests,
    "parent_program": parent_program or None,
    "related_proposals": related_proposals,
    "dependency_refs": dependency_refs,
    "source_lineage": source_lineage,
    "lifecycle": {
        "status": status,
        "temporary": (proposal.get("lifecycle") or {}).get("temporary"),
        "exit_expectation": (proposal.get("lifecycle") or {}).get("exit_expectation"),
    },
    "promotion_targets": promotion_targets,
    "gate_states": {
        "proposal_review": {
            "receipt_ref": rel(proposal_dir / "support/proposal-review.md") if (proposal_dir / "support/proposal-review.md").is_file() else None,
            "verdict": proposal_review.get("verdict"),
            "implementation_prompt_authorized": proposal_review.get("implementation_prompt_authorized"),
            "open_blocking_findings_count": proposal_review.get("open_blocking_findings_count"),
            "reviewed_packet_digest": proposal_review.get("reviewed_packet_digest"),
        },
        "implementation_readiness": {
            "receipt_ref": rel(proposal_dir / "support/implementation-grade-completeness-review.md") if (proposal_dir / "support/implementation-grade-completeness-review.md").is_file() else None,
            "verdict": readiness_review.get("verdict"),
            "unresolved_questions_count": readiness_review.get("unresolved_questions_count"),
            "clarification_required": readiness_review.get("clarification_required"),
        },
        "validators": [
            "validate-proposal-standard.sh",
            "validate-proposal-review-gate.sh --require-implementation-authorization",
            "validate-proposal-implementation-readiness.sh",
            "validate-architecture-proposal.sh",
            "validate-proposal-artifact-index-spine.sh",
        ],
    },
    "receipt_digests": receipt_digests,
    "blockers": {
        "open_blocking_findings_count": proposal_review.get("open_blocking_findings_count", "unknown"),
        "known_blockers": readiness_review.get("blockers", "see-readiness-receipt"),
    },
    "child_registry": {
        "registry_ref": rel(parent_child_registry) if parent_child_registry else None,
        "sha256": child_registry_digest or None,
        "child_id_present": child_id_present,
    },
    "reader_preferences": artifact_index["reader_preferences"],
    "failure_behavior": failure_behavior,
}

tmp_dir = pathlib.Path(tempfile.mkdtemp(prefix="proposal-artifact-index."))
try:
    tmp_dir.mkdir(exist_ok=True)
    tmp_index = tmp_dir / "proposal-artifact-index.yml"
    tmp_spine = tmp_dir / "proposal-program-spine.yml"
    tmp_index.write_text(stable_json(artifact_index))
    tmp_spine.write_text(stable_json(program_spine))

    compact_context_refs = [
        {
            "artifact_ref": rel(artifact_index_path),
            "sha256": sha256(tmp_index),
            "schema_version": "octon-proposal-artifact-index-v1",
        },
        {
            "artifact_ref": rel(program_spine_path),
            "sha256": sha256(tmp_spine),
            "schema_version": "octon-proposal-program-spine-v1",
        },
    ]

    handoff_capsule = {
        "schema_version": "octon-child-handoff-capsule-v1",
        "child_id": proposal_id,
        "proposal_path": rel(proposal_dir),
        "parent_program": parent_program or None,
        "producer": ".octon/framework/assurance/runtime/_ops/scripts/generate-proposal-artifact-index.sh",
        "output_ref": rel(handoff_capsule_path),
        "freshness": {
            "mode": "digest-bound",
            "generated_at": "deterministic-from-source-digests",
        },
        "authority_boundary": authority_boundary,
        "source_refs": spine_source_refs,
        "source_digests": spine_source_digests,
        "compact_context_refs": compact_context_refs,
        "context_hash": "sha256:" + hashlib.sha256(stable_json({
            "source_digests": spine_source_digests,
            "compact_context_refs": compact_context_refs,
            "promotion_targets": promotion_targets,
            "validation_gates": validation_gates,
        }).encode()).hexdigest(),
        "scope_statement": proposal.get("scope_statement") or proposal.get("summary"),
        "dependency_vector": {
            "parent_program": parent_program or None,
            "related_proposals": related_proposals,
            "dependency_refs": dependency_refs,
            "source_lineage": source_lineage,
        },
        "write_scope_map": [
            {
                "target": target,
                "authority_class": "declared-promotion-target",
                "write_policy": "child-route-only-with-review-gate",
            }
            for target in promotion_targets
        ],
        "validator_matrix": [
            {"validator": gate, "required": True}
            for gate in validation_gates
        ] + [
            {"validator": "validate-proposal-artifact-index-spine.sh", "required": True},
            {"validator": "generated-registry-cannot-replace-manifest-negative-control", "required": True},
        ],
        "evidence_refs": evidence_requirements,
        "read_raw_only_if": [
            "compact-context-hash-mismatch",
            "child-registry-digest-mismatch",
            "write-scope-dispute",
            "validator-dispute",
        ],
        "failure_behavior": failure_behavior,
    }

    tmp_handoff = tmp_dir / "child-handoff-capsule.yml"
    tmp_handoff.write_text(stable_json(handoff_capsule))
    expected = [
        (artifact_index_path, tmp_index),
        (program_spine_path, tmp_spine),
    ]
    if parent_program:
        expected.append((handoff_capsule_path, tmp_handoff))

    refresh_outputs = []
    if mode == "write":
        output_dir.mkdir(parents=True, exist_ok=True)
        for destination, source in expected:
            expected_digest = sha256(source)
            status = write_if_changed(destination, source)
            if status == "fresh":
                ok(f"generated artifact already matches: {rel(destination)}")
            else:
                ok(f"generated artifact written: {rel(destination)}")
            refresh_outputs.append({
                "ref": rel(destination),
                "expected_output_digest": expected_digest,
                "current_output_digest": sha256(destination) if destination.is_file() else "missing",
                "refresh_status": status,
            })
    else:
        for destination, source in expected:
            expected_digest = sha256(source)
            if not destination.is_file():
                fail(f"generated artifact exists: {rel(destination)}")
                refresh_outputs.append({
                    "ref": rel(destination),
                    "expected_output_digest": expected_digest,
                    "current_output_digest": "missing",
                    "refresh_status": "missing-output",
                })
                continue
            current = destination.read_text(errors="replace").splitlines(keepends=True)
            proposed = source.read_text(errors="replace").splitlines(keepends=True)
            if current == proposed:
                ok(f"generated artifact matches: {rel(destination)}")
                status = "fresh"
            else:
                fail(f"generated artifact stale: {rel(destination)}")
                status = "stale-output"
                for line in difflib.unified_diff(current, proposed, fromfile=rel(destination), tofile=f"generated/{destination.name}"):
                    sys.stdout.write(line)
            refresh_outputs.append({
                "ref": rel(destination),
                "expected_output_digest": expected_digest,
                "current_output_digest": sha256(destination) if destination.is_file() else "missing",
                "refresh_status": status,
            })

    next_owning_route = "none"
    if any(item["refresh_status"] in {"missing-output", "stale-output"} for item in refresh_outputs):
        next_owning_route = (
            "generate-proposal-artifact-index.sh --proposal "
            + rel(proposal_dir)
            + " --write"
        )

    print("refresh_receipt:")
    print('  schema_version: "generated-metadata-refresh-receipt-v1"')
    print('  owning_generator: ".octon/framework/assurance/runtime/_ops/scripts/generate-proposal-artifact-index.sh"')
    print('  owning_route: "proposal-artifact-index-generator"')
    print(f"  proposal_ref: {json.dumps(rel(proposal_dir))}")
    print(f"  mode: {json.dumps(mode)}")
    print('  generated_output_authority: "derived-only"')
    print('  non_authority_classification: "generated-output-non-authority"')
    print(f"  next_owning_route: {json.dumps(next_owning_route)}")
    print("  source_refs:")
    for source_ref in sorted(spine_source_digests):
        print(f"    - ref: {json.dumps(source_ref)}")
        print(f"      sha256: {json.dumps(spine_source_digests[source_ref])}")
    print("  output_refs:")
    for item in refresh_outputs:
        print(f"    - ref: {json.dumps(item['ref'])}")
        print(f"      expected_output_digest: {json.dumps(item['expected_output_digest'])}")
        print(f"      current_output_digest: {json.dumps(item['current_output_digest'])}")
        print(f"      refresh_status: {json.dumps(item['refresh_status'])}")
finally:
    shutil.rmtree(tmp_dir, ignore_errors=True)

print(f"Proposal artifact generation summary: errors={len(errors)}")
sys.exit(1 if errors else 0)
PY
