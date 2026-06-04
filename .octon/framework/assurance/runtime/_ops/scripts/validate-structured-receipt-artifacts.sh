#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
OCTON_DIR="${OCTON_DIR:-$DEFAULT_OCTON_DIR}"
DEFAULT_ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"
ROOT_DIR="${ROOT_DIR:-$DEFAULT_ROOT_DIR}"

ARTIFACT_PATH=""
RUN_SELF_TEST=0
errors=0

usage() {
  cat <<'USAGE'
usage:
  validate-structured-receipt-artifacts.sh [--artifact <path>] [--self-test]

Without --artifact, validates durable static bindings for compact closeout and
publication artifacts. With --artifact, validates one compact artifact and
verifies reachable source digests. --self-test runs positive and negative
fixture controls, including expanded report reconstruction.
USAGE
}

pass() { echo "[OK] $1"; }
fail() {
  echo "[ERROR] $1" >&2
  errors=$((errors + 1))
}

require_file() {
  local file="$1"
  [[ -f "$file" ]] && pass "found ${file#$ROOT_DIR/}" || fail "missing ${file#$ROOT_DIR/}"
}

require_literal() {
  local file="$1"
  local needle="$2"
  local ok_msg="$3"
  local fail_msg="$4"
  grep -Fq -- "$needle" "$file" && pass "$ok_msg" || fail "$fail_msg"
}

hash_file() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  else
    shasum -a 256 "$1" | awk '{print $1}'
  fi
}

validate_static() {
  local evidence_store="$OCTON_DIR/framework/engine/runtime/spec/evidence-store-v1.md"
  local closeout_change="$OCTON_DIR/framework/capabilities/runtime/skills/remediation/closeout-change/SKILL.md"
  local closeout_change_io="$OCTON_DIR/framework/capabilities/runtime/skills/remediation/closeout-change/references/io-contract.md"
  local closeout_change_validation="$OCTON_DIR/framework/capabilities/runtime/skills/remediation/closeout-change/references/validation.md"
  local closeout_worktree="$OCTON_DIR/framework/capabilities/runtime/skills/remediation/closeout-worktree/SKILL.md"
  local closeout_worktree_io="$OCTON_DIR/framework/capabilities/runtime/skills/remediation/closeout-worktree/references/io-contract.md"
  local closeout_worktree_validation="$OCTON_DIR/framework/capabilities/runtime/skills/remediation/closeout-worktree/references/validation.md"
  local generator="$SCRIPT_DIR/generate-expanded-report-from-structured-receipt.sh"

  for file in \
    "$evidence_store" \
    "$closeout_change" \
    "$closeout_change_io" \
    "$closeout_change_validation" \
    "$closeout_worktree" \
    "$closeout_worktree_io" \
    "$closeout_worktree_validation" \
    "$generator"
  do
    require_file "$file"
  done

  require_literal "$evidence_store" "Structured Closeout And Publication Views" \
    "evidence store documents structured closeout/publication views" \
    "evidence store must document structured closeout/publication views"
  require_literal "$evidence_store" "closeout-projection.yml" \
    "evidence store names closeout projection artifact" \
    "evidence store must name closeout-projection.yml"
  require_literal "$evidence_store" "publication-summary.yml" \
    "evidence store names publication summary artifact" \
    "evidence store must name publication-summary.yml"
  require_literal "$evidence_store" "structured-receipt.yml" \
    "evidence store names structured receipt artifact" \
    "evidence store must name structured-receipt.yml"
  require_literal "$evidence_store" "expanded-report-request.yml" \
    "evidence store names expanded report request artifact" \
    "evidence store must name expanded-report-request.yml"
  require_literal "$evidence_store" "model_visible_token_estimate <= 4000" \
    "evidence store documents closeout projection token ceiling" \
    "evidence store must document closeout projection token ceiling"
  require_literal "$evidence_store" "fail-closed for missing" \
    "evidence store documents fail-closed compact view behavior" \
    "evidence store must document fail-closed compact view behavior"

  for file in "$closeout_change" "$closeout_change_io" "$closeout_change_validation" "$closeout_worktree" "$closeout_worktree_io" "$closeout_worktree_validation"; do
    require_literal "$file" "closeout-projection.yml" \
      "${file#$ROOT_DIR/} binds closeout projection" \
      "${file#$ROOT_DIR/} must bind closeout-projection.yml"
    require_literal "$file" "expanded-report-request.yml" \
      "${file#$ROOT_DIR/} binds expanded report request" \
      "${file#$ROOT_DIR/} must bind expanded-report-request.yml"
    require_literal "$file" "validate-structured-receipt-artifacts.sh" \
      "${file#$ROOT_DIR/} cites structured artifact validator" \
      "${file#$ROOT_DIR/} must cite structured artifact validator"
  done
}

validate_artifact() {
  local artifact="$1"

  if [[ ! -f "$artifact" ]]; then
    echo "[ERROR] artifact missing: $artifact" >&2
    return 1
  fi

  local artifact_json
  if ! artifact_json="$(yq -o=json '.' "$artifact" 2>/dev/null)"; then
    echo "[ERROR] artifact does not parse as YAML: $artifact" >&2
    return 1
  fi

  set +e
  ARTIFACT_JSON="$artifact_json" ARTIFACT_PATH="$artifact" ROOT_DIR="$ROOT_DIR" python3 - <<'PY'
import hashlib
import json
import os
import sys
from pathlib import Path, PurePosixPath

artifact = json.loads(os.environ["ARTIFACT_JSON"])
artifact_path = Path(os.environ["ARTIFACT_PATH"])
root = Path(os.environ["ROOT_DIR"]).resolve()
errors = []


def fail(message):
    errors.append(message)


def is_nonempty_string(value):
    return isinstance(value, str) and bool(value.strip())


def as_list(value):
    if isinstance(value, list):
        return value
    if value is None:
        return []
    return [value]


def resolve_ref(ref, field):
    if not is_nonempty_string(ref):
        fail(f"{field} contains a non-string or empty ref")
        return None
    if ref.startswith("evidence://"):
        suffix = ref.removeprefix("evidence://")
        if not suffix:
            fail(f"{field} evidence ref has no suffix")
            return None
        value = f".octon/state/evidence/{suffix}"
    else:
        value = ref

    path = PurePosixPath(value)
    if path.is_absolute() or ".." in path.parts:
        fail(f"{field} must be repo-relative without parent traversal: {ref}")
        return None
    return root / Path(*path.parts)


def ref_is_forbidden(ref, field):
    if ref.startswith("evidence://"):
        return False
    path = PurePosixPath(ref)
    if len(path.parts) >= 3 and path.parts[:3] == (".octon", "inputs", "exploratory"):
        fail(f"{field} must not use proposal or exploratory inputs as evidence/source authority: {ref}")
    if len(path.parts) >= 2 and path.parts[:2] == (".octon", "inputs"):
        fail(f"{field} must not use raw inputs as evidence/source authority: {ref}")
    if field == "evidence_refs" and len(path.parts) >= 2 and path.parts[:2] == (".octon", "generated"):
        fail(f"{field} must not use generated outputs as retained evidence: {ref}")


required = [
    "schema_version",
    "artifact_kind",
    "authority_status",
    "producer",
    "consumer",
    "reader_preference",
    "model_visible_token_estimate",
    "source_refs",
    "source_digests",
    "evidence_refs",
    "validation",
    "freshness",
    "failure_behavior",
    "authority_boundary",
]
for key in required:
    if key not in artifact:
        fail(f"missing required field: {key}")

allowed = {
    "closeout-projection-v1": "closeout-projection",
    "publication-summary-v1": "publication-summary",
    "structured-receipt-v1": "structured-receipt",
    "expanded-report-request-v1": "expanded-report-request",
}
schema = artifact.get("schema_version")
kind = artifact.get("artifact_kind")
if schema not in allowed:
    fail(f"unsupported schema_version: {schema}")
elif kind != allowed[schema]:
    fail(f"artifact_kind {kind!r} does not match schema_version {schema!r}")

authority_status = str(artifact.get("authority_status", "")).lower()
if not ("non-author" in authority_status or "evidence aid" in authority_status or "retained-evidence-aid" in authority_status):
    fail("authority_status must explicitly classify the artifact as non-authoritative or a retained evidence aid")
for phrase in ("source of truth", "source-of-truth", "runtime authority", "policy authority", "support proof", "closure proof"):
    if phrase in authority_status:
        fail(f"authority_status contains forbidden authority phrase: {phrase}")

source_refs = as_list(artifact.get("source_refs"))
evidence_refs = as_list(artifact.get("evidence_refs"))
if not source_refs:
    fail("source_refs must be non-empty")
if not evidence_refs:
    fail("evidence_refs must be non-empty")

for ref in source_refs:
    if is_nonempty_string(ref):
        ref_is_forbidden(ref, "source_refs")
for ref in evidence_refs:
    if is_nonempty_string(ref):
        ref_is_forbidden(ref, "evidence_refs")

digest_records = artifact.get("source_digests")
digest_by_ref = {}
if isinstance(digest_records, dict):
    digest_by_ref = {str(k): str(v) for k, v in digest_records.items()}
elif isinstance(digest_records, list):
    for index, item in enumerate(digest_records):
        if not isinstance(item, dict):
            fail(f"source_digests[{index}] must be an object")
            continue
        ref = item.get("source_ref")
        digest = item.get("sha256")
        if not is_nonempty_string(ref) or not is_nonempty_string(digest):
            fail(f"source_digests[{index}] requires source_ref and sha256")
            continue
        digest_by_ref[ref] = digest
else:
    fail("source_digests must be a mapping or list")

for ref in source_refs:
    if not is_nonempty_string(ref):
        continue
    declared = digest_by_ref.get(ref)
    if not declared:
        fail(f"missing source digest for {ref}")
        continue
    declared_hex = declared.removeprefix("sha256:")
    if len(declared_hex) != 64 or any(ch not in "0123456789abcdefABCDEF" for ch in declared_hex):
        fail(f"source digest for {ref} must be a sha256 hex digest")
        continue
    path = resolve_ref(ref, "source_refs")
    if path is None:
        continue
    if path.exists():
        actual = hashlib.sha256(path.read_bytes()).hexdigest()
        if actual.lower() != declared_hex.lower():
            fail(f"source digest mismatch for {ref}: declared {declared_hex}, actual {actual}")
    else:
        fail(f"source ref does not resolve for digest validation: {ref}")

for ref in evidence_refs:
    if is_nonempty_string(ref):
        path = resolve_ref(ref, "evidence_refs")
        if path is not None and not path.exists():
            fail(f"evidence ref does not resolve: {ref}")

producer = artifact.get("producer")
consumer = artifact.get("consumer")
if not isinstance(producer, dict) or not is_nonempty_string(producer.get("id")):
    fail("producer.id must be present")
if not isinstance(consumer, dict) or not is_nonempty_string(consumer.get("default_reader")):
    fail("consumer.default_reader must be present")

reader_preference = artifact.get("reader_preference")
if not isinstance(reader_preference, dict):
    fail("reader_preference must be an object")
else:
    if reader_preference.get("default") not in ("compact", "structured", "summary"):
        fail("reader_preference.default must prefer compact, structured, or summary context")
    if bool(reader_preference.get("raw_default", False)):
        fail("reader_preference.raw_default must not be true")

token_estimate = artifact.get("model_visible_token_estimate")
if not isinstance(token_estimate, int) or token_estimate < 0:
    fail("model_visible_token_estimate must be a non-negative integer")
elif kind == "closeout-projection" and token_estimate > 4000:
    fail("closeout-projection model_visible_token_estimate must be <= 4000")

validation = artifact.get("validation")
if not isinstance(validation, dict):
    fail("validation must be an object")
else:
    if validation.get("status") not in ("valid", "pass"):
        fail("validation.status must be valid or pass")
    if not is_nonempty_string(validation.get("validator")):
        fail("validation.validator must be present")

freshness = artifact.get("freshness")
if not isinstance(freshness, dict):
    fail("freshness must be an object")
else:
    if freshness.get("state") not in ("fresh", "current", "valid"):
        fail("freshness.state must be fresh, current, or valid")

failure_behavior = artifact.get("failure_behavior")
if not isinstance(failure_behavior, dict):
    fail("failure_behavior must be an object")
else:
    for key in ("on_missing_source", "on_digest_mismatch", "on_stale_freshness", "on_authority_conflict"):
        if failure_behavior.get(key) != "fail_closed":
            fail(f"failure_behavior.{key} must be fail_closed")

boundary = artifact.get("authority_boundary")
if not isinstance(boundary, dict):
    fail("authority_boundary must be an object")
else:
    for key in ("proposal_inputs_authoritative", "generated_outputs_authoritative", "raw_evidence_replaced", "engine_authorization_bypassed"):
        if boundary.get(key) is not False:
            fail(f"authority_boundary.{key} must be false")

if kind == "expanded-report-request":
    expanded = artifact.get("expanded_report")
    if not isinstance(expanded, dict):
        fail("expanded-report-request requires expanded_report object")
    else:
        sources = as_list(expanded.get("reconstruction_sources"))
        if not sources:
            fail("expanded_report.reconstruction_sources must be non-empty")
        missing = [ref for ref in sources if ref not in source_refs]
        if missing:
            fail(f"expanded_report.reconstruction_sources must be covered by source_refs: {missing}")
        if expanded.get("output_mode") not in ("on_demand", "stdout", "file"):
            fail("expanded_report.output_mode must be on_demand, stdout, or file")

if errors:
    for message in errors:
        print(f"[ERROR] {message}", file=sys.stderr)
    sys.exit(1)

print(f"[OK] structured artifact validates: {artifact_path}")
PY
  local status=$?
  set -e
  return "$status"
}

self_test() {
  local tmp source source_digest artifact bad generator_output
  tmp="$(mktemp -d "${TMPDIR:-/tmp}/structured-receipts.XXXXXX")"
  mkdir -p "$tmp/.octon/state/evidence/runs/skills/closeout-change/fixture"
  source="$tmp/.octon/state/evidence/runs/skills/closeout-change/fixture/change-receipt.json"
  printf '%s\n' '{"schema_version":"change-receipt-v1","change_id":"fixture","closeout_outcome":"completed"}' >"$source"
  source_digest="$(hash_file "$source")"
  artifact="$tmp/closeout-projection.yml"

  cat >"$artifact" <<YAML
schema_version: closeout-projection-v1
artifact_kind: closeout-projection
artifact_id: fixture-closeout-projection
authority_status: retained-evidence-aid non-authoritative
producer:
  id: closeout-change
  produced_at: 2026-06-03T00:00:00Z
consumer:
  default_reader: closeout-change
  model_route: compact-default
reader_preference:
  default: compact
  raw_default: false
model_visible_token_estimate: 900
source_refs:
  - .octon/state/evidence/runs/skills/closeout-change/fixture/change-receipt.json
source_digests:
  - source_ref: .octon/state/evidence/runs/skills/closeout-change/fixture/change-receipt.json
    sha256: $source_digest
evidence_refs:
  - .octon/state/evidence/runs/skills/closeout-change/fixture/change-receipt.json
validation:
  status: valid
  validator: validate-structured-receipt-artifacts.sh
  validation_refs:
    - self-test
freshness:
  state: fresh
failure_behavior:
  on_missing_source: fail_closed
  on_digest_mismatch: fail_closed
  on_stale_freshness: fail_closed
  on_authority_conflict: fail_closed
authority_boundary:
  proposal_inputs_authoritative: false
  generated_outputs_authoritative: false
  raw_evidence_replaced: false
  engine_authorization_bypassed: false
gate_state:
  authorization: retained
  rollback: retained
blockers: []
unresolved_questions: []
changed_files:
  - docs/closeout.md
rollback_refs:
  - rollback://fixture
exclusions:
  - compact artifact is not authority
YAML

  if ROOT_DIR="$tmp" validate_artifact "$artifact" >/dev/null; then
    pass "self-test valid closeout projection passes"
  else
    fail "self-test valid closeout projection should pass"
  fi

  bad="$tmp/bad-digest.yml"
  cp "$artifact" "$bad"
  sed -i.bak 's/sha256: .*/sha256: 0000000000000000000000000000000000000000000000000000000000000000/' "$bad"
  if ROOT_DIR="$tmp" validate_artifact "$bad" >/dev/null 2>&1; then
    fail "self-test digest mismatch should fail"
  else
    pass "self-test digest mismatch fails"
  fi

  bad="$tmp/bad-token-ceiling.yml"
  cp "$artifact" "$bad"
  sed -i.bak 's/model_visible_token_estimate: 900/model_visible_token_estimate: 4001/' "$bad"
  if ROOT_DIR="$tmp" validate_artifact "$bad" >/dev/null 2>&1; then
    fail "self-test closeout projection token ceiling should fail"
  else
    pass "self-test closeout projection token ceiling fails"
  fi

  bad="$tmp/bad-authority.yml"
  cp "$artifact" "$bad"
  sed -i.bak 's/proposal_inputs_authoritative: false/proposal_inputs_authoritative: true/' "$bad"
  if ROOT_DIR="$tmp" validate_artifact "$bad" >/dev/null 2>&1; then
    fail "self-test authority boundary violation should fail"
  else
    pass "self-test authority boundary violation fails"
  fi

  local request="$tmp/expanded-report-request.yml"
  cp "$artifact" "$request"
  sed -i.bak 's/schema_version: closeout-projection-v1/schema_version: expanded-report-request-v1/' "$request"
  sed -i.bak 's/artifact_kind: closeout-projection/artifact_kind: expanded-report-request/' "$request"
  cat >>"$request" <<'YAML'
expanded_report:
  output_mode: on_demand
  reconstruction_sources:
    - .octon/state/evidence/runs/skills/closeout-change/fixture/change-receipt.json
YAML
  if ROOT_DIR="$tmp" validate_artifact "$request" >/dev/null; then
    pass "self-test expanded report request passes"
  else
    fail "self-test expanded report request should pass"
  fi

  generator_output="$tmp/expanded-report.md"
  if ROOT_DIR="$tmp" "$SCRIPT_DIR/generate-expanded-report-from-structured-receipt.sh" --request "$request" --output "$generator_output" >/dev/null && grep -Fq "Expanded Report" "$generator_output"; then
    pass "self-test expanded report reconstruction passes"
  else
    fail "self-test expanded report reconstruction should pass"
  fi

  rm -rf "$tmp"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --artifact)
      ARTIFACT_PATH="${2:-}"
      shift 2
      ;;
    --self-test)
      RUN_SELF_TEST=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -n "$ARTIFACT_PATH" ]]; then
  validate_artifact "$ARTIFACT_PATH"
else
  validate_static
fi

if [[ "$RUN_SELF_TEST" -eq 1 ]]; then
  self_test
fi

if [[ "$errors" -gt 0 ]]; then
  echo "Validation summary: errors=$errors"
  exit 1
fi

echo "Validation summary: errors=0"
