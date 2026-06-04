#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_ROOT="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
ROOT_DIR="${OCTON_ROOT_DIR:-$DEFAULT_ROOT}"
ARTIFACT_DIR=""
BASELINE_LEDGER=""
CANDIDATE_LEDGER=""
THRESHOLD_PERCENT=30
errors=0

usage() {
  cat <<'EOF'
usage:
  validate-semantic-cache-context-reuse.sh --artifact-dir <dir> [--root <repo-root>]
  validate-semantic-cache-context-reuse.sh --artifact-dir <dir> --baseline-ledger <path> --candidate-ledger <path> [--threshold-percent <n>] [--root <repo-root>]

Validates proposal-semantic-cache.yml, context-pack-layer-cache.yml, and
cache-invalidation-events.yml compact artifacts against reachable source refs,
policy digests, replay refs, token ceilings, and authority boundaries.
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
    --baseline-ledger)
      BASELINE_LEDGER="$2"
      shift 2
      ;;
    --candidate-ledger)
      CANDIDATE_LEDGER="$2"
      shift 2
      ;;
    --threshold-percent)
      THRESHOLD_PERCENT="$2"
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

if [[ -z "$ARTIFACT_DIR" ]]; then
  usage >&2
  exit 2
fi

if ! python3 - "$ROOT_DIR" "$ARTIFACT_DIR" "$SCRIPT_DIR" <<'PY'; then
import hashlib
import json
import pathlib
import re
import subprocess
import sys

root = pathlib.Path(sys.argv[1]).resolve()
artifact_arg = pathlib.Path(sys.argv[2])
artifact_dir = artifact_arg if artifact_arg.is_absolute() else root / artifact_arg
artifact_dir = artifact_dir.resolve()
script_dir = pathlib.Path(sys.argv[3]).resolve()

errors = []
sha_re = re.compile(r"^sha256:[0-9a-f]{64}$")
required_fail_closed = {
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
}
required_triggers = {
    "source-digest-drift",
    "policy-digest-drift",
    "request-binding-mismatch",
    "expired-freshness",
    "missing-retained-evidence",
    "trust-downgrade",
    "explicit-governance-invalidation",
}
expected = {
    "proposal-semantic-cache.yml": ("proposal-semantic-cache-v1", "proposal-semantic-cache"),
    "context-pack-layer-cache.yml": ("context-pack-layer-cache-v1", "context-pack-layer-cache"),
    "cache-invalidation-events.yml": ("cache-invalidation-events-v1", "cache-invalidation-events"),
}

def ok(message):
    print(f"[OK] {message}")

def fail(message):
    errors.append(message)
    print(f"[ERROR] {message}")

def resolve(ref):
    if not isinstance(ref, str) or not ref:
        return None
    if ref.startswith("evidence://"):
        ref = ".octon/state/evidence/" + ref.removeprefix("evidence://")
    path = pathlib.PurePosixPath(ref)
    if path.is_absolute() or ".." in path.parts:
        fail(f"ref must be repo-relative without parent traversal: {ref}")
        return None
    return root / pathlib.Path(*path.parts)

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
        fail(f"artifact parses as YAML: {path.name}")
        stderr = result.stderr.strip()
        if stderr:
            print(stderr)
        return {}
    try:
        return json.loads(result.stdout or "{}")
    except json.JSONDecodeError as exc:
        fail(f"artifact JSON conversion valid: {path.name}: {exc}")
        return {}

def require_sha(value, label):
    if isinstance(value, str) and sha_re.match(value):
        ok(f"{label} uses sha256")
        return True
    fail(f"{label} must use sha256:<64 hex>")
    return False

def digest_map(value):
    result = {}
    if isinstance(value, dict):
        for ref, digest in value.items():
            result[str(ref)] = str(digest)
        return result
    if isinstance(value, list):
        for index, item in enumerate(value):
            if not isinstance(item, dict):
                fail(f"source_digests[{index}] must be an object")
                continue
            ref = item.get("source_ref")
            digest = item.get("sha256")
            if not isinstance(ref, str) or not isinstance(digest, str):
                fail(f"source_digests[{index}] requires source_ref and sha256")
                continue
            result[ref] = digest
        return result
    fail("source_digests must be a map or list")
    return result

def check_ref_digest(ref, recorded, label, require_exists=True):
    require_sha(recorded, f"{label} digest for {ref}")
    path = resolve(ref)
    if path is None:
        return
    if path.is_file():
        actual = sha256(path)
        if recorded == actual:
            ok(f"{label} source digest matches: {ref}")
        else:
            fail(f"{label} source digest mismatch: {ref}")
    elif require_exists:
        fail(f"{label} source ref missing: {ref}")
    else:
        ok(f"{label} source ref is handle-only or unavailable by policy: {ref}")

def check_common(data, filename, schema, kind):
    if data.get("schema_version") == schema:
        ok(f"{filename} schema_version is {schema}")
    else:
        fail(f"{filename} schema_version must be {schema}")
    if data.get("artifact_kind") == kind:
        ok(f"{filename} artifact_kind is {kind}")
    else:
        fail(f"{filename} artifact_kind must be {kind}")

    authority_status = str(data.get("authority_status", "")).lower()
    if "non-author" in authority_status or "not-authority" in authority_status:
        ok(f"{filename} declares non-authority status")
    else:
        fail(f"{filename} must declare non-authority status")
    for forbidden in ("source of truth", "source-of-truth", "runtime authority", "policy authority", "closure authority"):
        if forbidden in authority_status:
            fail(f"{filename} authority_status contains forbidden phrase: {forbidden}")

    producer = data.get("producer") or {}
    if producer.get("version") == "semantic-cache-context-reuse-v1":
        ok(f"{filename} producer version valid")
    else:
        fail(f"{filename} producer version must be semantic-cache-context-reuse-v1")

    consumer = data.get("consumer") or {}
    forbidden_consumers = set(consumer.get("forbidden_consumers") or [])
    expected_forbidden = {"runtime-authority", "policy-authority", "support-proof", "closure-authority"}
    if expected_forbidden.issubset(forbidden_consumers):
        ok(f"{filename} forbids authority consumers")
    else:
        fail(f"{filename} must forbid runtime/policy/support/closure authority consumers")

    boundary = data.get("authority_boundary") or {}
    expected_boundary = {
        "replaces_source_evidence": False,
        "authorizes_execution": False,
        "raw_evidence_retained": True,
        "proposal_input_authority": "non-authoritative",
        "generated_output_authority": "derived-only",
    }
    for key, expected_value in expected_boundary.items():
        if boundary.get(key) == expected_value:
            ok(f"{filename} authority boundary {key}")
        else:
            fail(f"{filename} authority boundary {key} must be {expected_value!r}")

    freshness = data.get("freshness") or {}
    if freshness.get("state") == "fresh":
        ok(f"{filename} freshness state is fresh")
    else:
        fail(f"{filename} freshness state must be fresh")

    validation = data.get("validation") or {}
    if validation.get("status") == "pass":
        ok(f"{filename} validation status passes")
    else:
        fail(f"{filename} validation status must be pass")
    if validation.get("validator_ref") == ".octon/framework/assurance/runtime/_ops/scripts/validate-semantic-cache-context-reuse.sh":
        ok(f"{filename} validator ref is durable")
    else:
        fail(f"{filename} validator ref must point to validate-semantic-cache-context-reuse.sh")
    require_sha(validation.get("model_visible_sha256"), f"{filename} model-visible hash")
    estimate = validation.get("model_visible_token_estimate")
    if isinstance(estimate, int) and 0 <= estimate <= 2000:
        ok(f"{filename} cache-hit token overhead within ceiling")
    else:
        fail(f"{filename} cache-hit token overhead must be <= 2000")

    fail_closed = set((data.get("failure_behavior") or {}).get("fail_closed_on") or [])
    if required_fail_closed.issubset(fail_closed):
        ok(f"{filename} failure behavior covers required fail-closed cases")
    else:
        missing = ", ".join(sorted(required_fail_closed - fail_closed))
        fail(f"{filename} failure behavior missing cases: {missing}")

    source_refs = data.get("source_refs") or []
    if source_refs:
        ok(f"{filename} source_refs present")
    else:
        fail(f"{filename} source_refs must be non-empty")
    digests = digest_map(data.get("source_digests"))
    for ref in source_refs:
        if ref in digests:
            check_ref_digest(ref, digests[ref], filename)
        else:
            fail(f"{filename} missing source digest for {ref}")

    policy_ref = data.get("policy_ref")
    policy_sha = data.get("policy_sha256")
    if policy_ref and policy_sha:
        check_ref_digest(policy_ref, policy_sha, f"{filename} policy")
    else:
        fail(f"{filename} policy_ref and policy_sha256 are required")

    binding = data.get("route_binding") or {}
    for key in ("lifecycle_id", "route_id", "route_purpose", "trust_class"):
        if isinstance(binding.get(key), str) and binding.get(key):
            ok(f"{filename} route binding {key} present")
        else:
            fail(f"{filename} route binding {key} required")
    require_sha(binding.get("request_binding_sha256"), f"{filename} request binding")

    for record in data.get("source_records") or []:
        ref = record.get("source_ref")
        record_sha = record.get("sha256")
        if ref in digests:
            if record_sha == digests[ref]:
                ok(f"{filename} source record digest agrees: {ref}")
            else:
                fail(f"{filename} source record digest disagrees: {ref}")
        else:
            fail(f"{filename} source record missing digest map entry: {ref}")
        if ref and record_sha:
            check_ref_digest(ref, record_sha, f"{filename} source record")

        source_class = record.get("source_class")
        authority_label = record.get("authority_label")
        if source_class in {"generated", "generated_read_model", "derived", "non_authoritative_input"} and authority_label == "authoritative":
            fail(f"{filename} non-authority source cannot be authoritative: {ref}")
        elif source_class in {"generated", "generated_read_model", "derived", "non_authoritative_input"}:
            ok(f"{filename} non-authority source label preserved: {ref}")
        if isinstance(ref, str) and ref.startswith(".octon/inputs/exploratory/") and record.get("model_visible") is True:
            fail(f"{filename} proposal-local source must not be model-visible by default: {ref}")
    if not data.get("source_records"):
        fail(f"{filename} source_records must be non-empty")

    evidence_refs = data.get("evidence_refs") or []
    if evidence_refs:
        ok(f"{filename} evidence_refs present")
    else:
        fail(f"{filename} evidence_refs must be non-empty")

    return digests

artifacts = {}
for filename, (schema, kind) in expected.items():
    path = artifact_dir / filename
    if path.is_file():
        ok(f"{filename} exists")
        artifacts[filename] = load_yaml(path)
    else:
        fail(f"{filename} exists")
        artifacts[filename] = {}

common_route = None
common_policy = None
all_source_refs = set()
all_source_digests = {}
for filename, data in artifacts.items():
    schema, kind = expected[filename]
    digests = check_common(data, filename, schema, kind)
    all_source_refs.update(data.get("source_refs") or [])
    all_source_digests.update(digests)
    route_key = tuple((data.get("route_binding") or {}).get(key) for key in ("lifecycle_id", "route_id", "route_purpose", "trust_class"))
    policy_key = (data.get("policy_ref"), data.get("policy_sha256"))
    if common_route is None:
        common_route = route_key
    elif route_key == common_route:
        ok(f"{filename} route binding matches artifact family")
    else:
        fail(f"{filename} route binding differs from artifact family")
    if common_policy is None:
        common_policy = policy_key
    elif policy_key == common_policy:
        ok(f"{filename} policy binding matches artifact family")
    else:
        fail(f"{filename} policy binding differs from artifact family")

semantic = artifacts["proposal-semantic-cache.yml"]
entries = semantic.get("semantic_entries") or []
if entries:
    ok("semantic cache entries present")
else:
    fail("semantic cache entries must be non-empty")
for entry in entries:
    ref = entry.get("source_ref")
    if ref in all_source_digests and entry.get("source_sha256") == all_source_digests[ref]:
        ok(f"semantic entry source digest matches: {ref}")
    else:
        fail(f"semantic entry source digest mismatch: {ref}")
    if entry.get("policy_sha256") == semantic.get("policy_sha256"):
        ok(f"semantic entry policy digest matches: {entry.get('summary_id')}")
    else:
        fail(f"semantic entry policy digest mismatch: {entry.get('summary_id')}")
    require_sha(entry.get("model_visible_sha256"), f"semantic entry model-visible hash {entry.get('summary_id')}")
    token_estimate = entry.get("token_estimate")
    if isinstance(token_estimate, int) and 0 <= token_estimate <= 2000:
        ok(f"semantic entry token estimate within ceiling: {entry.get('summary_id')}")
    else:
        fail(f"semantic entry token estimate must be <= 2000: {entry.get('summary_id')}")
    if entry.get("route_purpose") and entry.get("trust_class") and entry.get("raw_evidence_ref"):
        ok(f"semantic entry route/trust/evidence binding present: {entry.get('summary_id')}")
    else:
        fail(f"semantic entry route/trust/evidence binding missing: {entry.get('summary_id')}")

layer_cache = artifacts["context-pack-layer-cache.yml"]
layers = layer_cache.get("layers") or []
if layers:
    ok("context layer cache layers present")
else:
    fail("context layer cache layers must be non-empty")
for layer in layers:
    layer_id = layer.get("layer_id")
    stage_ids = ((layer.get("reuse_binding") or {}).get("stage_ids") or [])
    if len(stage_ids) >= 2:
        ok(f"context layer is reused by multiple stages: {layer_id}")
    else:
        fail(f"context layer must be reusable by at least two stages: {layer_id}")
    layer_digests = digest_map(layer.get("source_digests"))
    for ref in layer.get("source_refs") or []:
        if ref not in layer_digests:
            fail(f"context layer missing source digest for {ref}: {layer_id}")
            continue
        if ref in all_source_digests and layer_digests[ref] == all_source_digests[ref]:
            ok(f"context layer source digest matches family source: {ref}")
        else:
            fail(f"context layer source digest mismatch: {ref}")
    replay_refs = layer.get("replay_refs") or []
    if replay_refs:
        ok(f"context layer replay refs present: {layer_id}")
    else:
        fail(f"context layer replay refs missing: {layer_id}")
    for ref in replay_refs:
        path = resolve(ref)
        if path and path.is_file():
            ok(f"context layer replay ref exists: {ref}")
        else:
            fail(f"context layer replay ref missing: {ref}")
    require_sha(layer.get("model_visible_sha256"), f"context layer model-visible hash {layer_id}")
    token_estimate = layer.get("token_estimate")
    if isinstance(token_estimate, int) and 0 <= token_estimate <= 2000:
        ok(f"context layer token estimate within ceiling: {layer_id}")
    else:
        fail(f"context layer token estimate must be <= 2000: {layer_id}")

events_artifact = artifacts["cache-invalidation-events.yml"]
triggers = set(events_artifact.get("supported_triggers") or [])
if required_triggers.issubset(triggers):
    ok("invalidation artifact supports all required triggers")
else:
    missing = ", ".join(sorted(required_triggers - triggers))
    fail(f"invalidation artifact missing triggers: {missing}")
for event in events_artifact.get("events") or []:
    trigger = event.get("trigger")
    if trigger in required_triggers:
        ok(f"invalidation event trigger valid: {event.get('event_id')}")
    else:
        fail(f"invalidation event trigger invalid: {event.get('event_id')}")
    if event.get("fail_closed") is True:
        ok(f"invalidation event fails closed: {event.get('event_id')}")
    else:
        fail(f"invalidation event must fail closed: {event.get('event_id')}")
    if event.get("state") == "active":
        fail(f"active invalidation event blocks cache use: {event.get('event_id')}")
    elif event.get("state") in {"recorded", "resolved"}:
        ok(f"invalidation event state is non-active: {event.get('event_id')}")
    else:
        fail(f"invalidation event state invalid: {event.get('event_id')}")
    if "previous_sha256" in event:
        require_sha(event.get("previous_sha256"), f"invalidation previous digest {event.get('event_id')}")
    if "current_sha256" in event:
        require_sha(event.get("current_sha256"), f"invalidation current digest {event.get('event_id')}")

static_refs = [
    ".octon/framework/engine/runtime/spec/context-pack-builder-v1.md",
    ".octon/framework/engine/runtime/spec/semantic-cache-context-reuse-v1.schema.json",
    ".octon/framework/engine/runtime/spec/token-budget-ledger-v1.md",
    ".octon/framework/assurance/runtime/_ops/scripts/generate-semantic-cache-context-reuse.sh",
    ".octon/framework/assurance/runtime/_ops/scripts/validate-semantic-cache-context-reuse.sh",
]
for ref in static_refs:
    path = root / ref
    if path.is_file():
        ok(f"durable semantic-cache contract exists: {ref}")
    else:
        fail(f"durable semantic-cache contract missing: {ref}")

print(f"Semantic cache context reuse validation summary: errors={len(errors)}")
sys.exit(1 if errors else 0)
PY
  errors=$((errors + 1))
fi

if [[ -n "$BASELINE_LEDGER" || -n "$CANDIDATE_LEDGER" ]]; then
  if [[ -z "$BASELINE_LEDGER" || -z "$CANDIDATE_LEDGER" ]]; then
    echo "[ERROR] --baseline-ledger and --candidate-ledger must be supplied together"
    errors=$((errors + 1))
  elif bash "$SCRIPT_DIR/validate-token-budget-ledger.sh" \
      --root "$ROOT_DIR" \
      --baseline "$BASELINE_LEDGER" \
      --candidate "$CANDIDATE_LEDGER" \
      --threshold-percent "$THRESHOLD_PERCENT"; then
    echo "[OK] token regression ledger check passes"
  else
    echo "[ERROR] token regression ledger check fails"
    errors=$((errors + 1))
  fi
fi

echo "Validation summary: errors=$errors"
[[ "$errors" -eq 0 ]]
