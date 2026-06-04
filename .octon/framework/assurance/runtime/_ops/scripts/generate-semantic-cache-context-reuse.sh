#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_ROOT="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
ROOT_DIR="${OCTON_ROOT_DIR:-$DEFAULT_ROOT}"

ARTIFACT_DIR=""
RUN_ID="run-local"
LIFECYCLE_ID="proposal-packet"
ROUTE_ID="run-packet-implementation"
ROUTE_PURPOSE="semantic-cache-context-reuse"
TRUST_CLASS="repo-local"
POLICY_REF=".octon/instance/governance/policies/context-packing.yml"
REQUEST_BINDING_SHA256=""
WRITE=0
SOURCE_REFS=()
EVIDENCE_REFS=()
REPLAY_REFS=()
STAGE_IDS=()

usage() {
  cat <<'EOF'
usage:
  generate-semantic-cache-context-reuse.sh --artifact-dir <dir> --source-ref <ref>... --evidence-ref <ref> --replay-ref <ref> --write [options]

Options:
  --root <repo-root>
  --run-id <id>
  --lifecycle-id <id>
  --route-id <id>
  --route-purpose <purpose>
  --trust-class <class>
  --policy-ref <ref>
  --request-binding-sha256 <sha256:...>
  --stage-id <id>              Repeatable. Defaults to review and implementation.

Emits proposal-semantic-cache.yml, context-pack-layer-cache.yml, and
cache-invalidation-events.yml compact artifacts, then validates them. Output is
retained evidence/read-model material only and never authorizes execution.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)
      ROOT_DIR="$2"
      shift 2
      ;;
    --artifact-dir)
      ARTIFACT_DIR="$2"
      shift 2
      ;;
    --run-id)
      RUN_ID="$2"
      shift 2
      ;;
    --lifecycle-id)
      LIFECYCLE_ID="$2"
      shift 2
      ;;
    --route-id)
      ROUTE_ID="$2"
      shift 2
      ;;
    --route-purpose)
      ROUTE_PURPOSE="$2"
      shift 2
      ;;
    --trust-class)
      TRUST_CLASS="$2"
      shift 2
      ;;
    --policy-ref)
      POLICY_REF="$2"
      shift 2
      ;;
    --request-binding-sha256)
      REQUEST_BINDING_SHA256="$2"
      shift 2
      ;;
    --source-ref)
      SOURCE_REFS+=("$2")
      shift 2
      ;;
    --evidence-ref)
      EVIDENCE_REFS+=("$2")
      shift 2
      ;;
    --replay-ref)
      REPLAY_REFS+=("$2")
      shift 2
      ;;
    --stage-id)
      STAGE_IDS+=("$2")
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

if [[ -z "$ARTIFACT_DIR" || "${#SOURCE_REFS[@]}" -eq 0 || "${#EVIDENCE_REFS[@]}" -eq 0 || "${#REPLAY_REFS[@]}" -eq 0 || "$WRITE" -ne 1 ]]; then
  usage >&2
  exit 2
fi

if [[ "${#STAGE_IDS[@]}" -lt 2 ]]; then
  STAGE_IDS=("review" "implementation")
fi

SOURCE_REFS_JSON="$(printf '%s\n' "${SOURCE_REFS[@]}" | python3 -c 'import json,sys; print(json.dumps([line.rstrip("\n") for line in sys.stdin if line.rstrip("\n")]))')"
EVIDENCE_REFS_JSON="$(printf '%s\n' "${EVIDENCE_REFS[@]}" | python3 -c 'import json,sys; print(json.dumps([line.rstrip("\n") for line in sys.stdin if line.rstrip("\n")]))')"
REPLAY_REFS_JSON="$(printf '%s\n' "${REPLAY_REFS[@]}" | python3 -c 'import json,sys; print(json.dumps([line.rstrip("\n") for line in sys.stdin if line.rstrip("\n")]))')"
STAGE_IDS_JSON="$(printf '%s\n' "${STAGE_IDS[@]}" | python3 -c 'import json,sys; print(json.dumps([line.rstrip("\n") for line in sys.stdin if line.rstrip("\n")]))')"

python3 - "$ROOT_DIR" "$ARTIFACT_DIR" "$RUN_ID" "$LIFECYCLE_ID" "$ROUTE_ID" "$ROUTE_PURPOSE" "$TRUST_CLASS" "$POLICY_REF" "$REQUEST_BINDING_SHA256" "$SOURCE_REFS_JSON" "$EVIDENCE_REFS_JSON" "$REPLAY_REFS_JSON" "$STAGE_IDS_JSON" <<'PY'
import hashlib
import json
import pathlib
import sys

root = pathlib.Path(sys.argv[1]).resolve()
artifact_arg = pathlib.Path(sys.argv[2])
artifact_dir = artifact_arg if artifact_arg.is_absolute() else root / artifact_arg
run_id, lifecycle_id, route_id, route_purpose, trust_class = sys.argv[3:8]
policy_ref = sys.argv[8]
request_binding_sha256 = sys.argv[9]
source_refs = json.loads(sys.argv[10])
evidence_refs = json.loads(sys.argv[11])
replay_refs = json.loads(sys.argv[12])
stage_ids = json.loads(sys.argv[13])

def resolve(ref):
    if ref.startswith("evidence://"):
        ref = ".octon/state/evidence/" + ref.removeprefix("evidence://")
    return root / pathlib.Path(*pathlib.PurePosixPath(ref).parts)

def sha(ref):
    path = resolve(ref)
    if not path.is_file():
        raise SystemExit(f"[ERROR] source ref missing: {ref}")
    return "sha256:" + hashlib.sha256(path.read_bytes()).hexdigest()

def stable_sha(value):
    payload = json.dumps(value, sort_keys=True, separators=(",", ":")).encode()
    return "sha256:" + hashlib.sha256(payload).hexdigest()

def estimate_tokens(ref):
    return (resolve(ref).stat().st_size + 3) // 4

def classify(ref):
    if ref.startswith(".octon/framework/") or ref.startswith(".octon/instance/"):
        return "authority", "authoritative", "summary"
    if ref.startswith(".octon/state/control/"):
        return "control", "control", "handle-only"
    if ref.startswith(".octon/state/evidence/"):
        return "evidence", "evidence", "handle-only"
    if ref.startswith(".octon/generated/"):
        return "generated", "derived", "handle-only"
    if ref.startswith(".octon/inputs/"):
        return "non_authoritative_input", "non_authoritative", "digest-only"
    return "derived", "derived", "digest-only"

artifact_dir.mkdir(parents=True, exist_ok=True)
policy_sha = sha(policy_ref)
source_digests = [{"source_ref": ref, "sha256": sha(ref)} for ref in source_refs]
source_digest_by_ref = {item["source_ref"]: item["sha256"] for item in source_digests}
source_records = []
for ref in source_refs:
    source_class, authority_label, inclusion_mode = classify(ref)
    source_records.append({
        "source_ref": ref,
        "sha256": source_digest_by_ref[ref],
        "source_class": source_class,
        "authority_label": authority_label,
        "inclusion_mode": inclusion_mode,
        "model_visible": False,
        "estimated_tokens": estimate_tokens(ref),
    })

if not request_binding_sha256:
    request_binding_sha256 = stable_sha({
        "run_id": run_id,
        "lifecycle_id": lifecycle_id,
        "route_id": route_id,
        "route_purpose": route_purpose,
        "trust_class": trust_class,
        "policy_sha256": policy_sha,
        "source_digests": source_digests,
    })

common = {
    "authority_status": "non-authoritative retained evidence read model",
    "producer": {"id": "generate-semantic-cache-context-reuse.sh", "version": "semantic-cache-context-reuse-v1"},
    "consumer": {
        "preferred": "compact-default",
        "allowed_consumers": ["validators", "operators", "context-pack-builder"],
        "forbidden_consumers": ["runtime-authority", "policy-authority", "support-proof", "closure-authority"],
    },
    "source_refs": source_refs,
    "source_digests": source_digests,
    "source_records": source_records,
    "policy_ref": policy_ref,
    "policy_sha256": policy_sha,
    "route_binding": {
        "lifecycle_id": lifecycle_id,
        "route_id": route_id,
        "route_purpose": route_purpose,
        "trust_class": trust_class,
        "request_binding_sha256": request_binding_sha256,
    },
    "freshness": {"state": "fresh", "generated_at": "deterministic-local", "valid_until": None},
    "validation": {
        "status": "pass",
        "validator_ref": ".octon/framework/assurance/runtime/_ops/scripts/validate-semantic-cache-context-reuse.sh",
        "model_visible_sha256": stable_sha({"source_digests": source_digests, "policy_sha256": policy_sha, "route_purpose": route_purpose}),
        "model_visible_token_estimate": min(2000, sum(min(2000, estimate_tokens(ref)) for ref in source_refs)),
    },
    "evidence_refs": evidence_refs,
    "failure_behavior": {
        "fail_closed_on": [
            "missing-source",
            "source-digest-mismatch",
            "policy-digest-mismatch",
            "request-binding-mismatch",
            "expired-freshness",
            "missing-retained-evidence",
            "trust-downgrade",
            "explicit-governance-invalidation",
            "authority-boundary-violation",
            "missing-model-visible-hash",
            "missing-replay-ref",
        ]
    },
    "authority_boundary": {
        "artifact_class": "retained-evidence-read-model",
        "replaces_source_evidence": False,
        "authorizes_execution": False,
        "raw_evidence_retained": True,
        "proposal_input_authority": "non-authoritative",
        "generated_output_authority": "derived-only",
    },
}

semantic_entries = []
for ref in source_refs:
    semantic_entries.append({
        "summary_id": "summary-" + hashlib.sha256(ref.encode()).hexdigest()[:12],
        "source_ref": ref,
        "source_sha256": source_digest_by_ref[ref],
        "policy_sha256": policy_sha,
        "route_purpose": route_purpose,
        "trust_class": trust_class,
        "model_visible_sha256": stable_sha({"summary_ref": ref, "sha256": source_digest_by_ref[ref]}),
        "token_estimate": min(2000, max(1, estimate_tokens(ref))),
        "raw_evidence_ref": evidence_refs[0],
    })

artifacts = {
    "proposal-semantic-cache.yml": {
        **common,
        "schema_version": "proposal-semantic-cache-v1",
        "artifact_kind": "proposal-semantic-cache",
        "semantic_entries": semantic_entries,
    },
    "context-pack-layer-cache.yml": {
        **common,
        "schema_version": "context-pack-layer-cache-v1",
        "artifact_kind": "context-pack-layer-cache",
        "layers": [{
            "layer_id": "layer-" + hashlib.sha256(("|".join(source_refs)).encode()).hexdigest()[:12],
            "source_refs": source_refs,
            "source_digests": source_digests,
            "reuse_binding": {"stage_ids": stage_ids},
            "replay_refs": replay_refs,
            "model_visible_sha256": stable_sha({"layer_sources": source_digests, "stages": stage_ids}),
            "token_estimate": min(2000, sum(min(2000, estimate_tokens(ref)) for ref in source_refs)),
        }],
    },
    "cache-invalidation-events.yml": {
        **common,
        "schema_version": "cache-invalidation-events-v1",
        "artifact_kind": "cache-invalidation-events",
        "supported_triggers": [
            "source-digest-drift",
            "policy-digest-drift",
            "request-binding-mismatch",
            "expired-freshness",
            "missing-retained-evidence",
            "trust-downgrade",
            "explicit-governance-invalidation",
        ],
        "events": [],
    },
}

for name, data in artifacts.items():
    (artifact_dir / name).write_text(json.dumps(data, indent=2, sort_keys=True) + "\n")
    print(f"[OK] wrote {artifact_dir / name}")
PY

bash "$SCRIPT_DIR/validate-semantic-cache-context-reuse.sh" --root "$ROOT_DIR" --artifact-dir "$ARTIFACT_DIR"
