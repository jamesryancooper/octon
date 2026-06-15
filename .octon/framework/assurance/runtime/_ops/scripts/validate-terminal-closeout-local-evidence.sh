#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
SCHEMA="$ROOT_DIR/.octon/framework/product/contracts/terminal-closeout-local-evidence-v1.schema.json"
TERMINAL_PROOF_VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-terminal-current-state-proof.sh"

MANIFEST=""
CHANGE_ID=""
LANDED_REF=""
errors=0

usage() {
  cat <<'USAGE'
usage:
  validate-terminal-closeout-local-evidence.sh --manifest <manifest.json> [--change-id <id>] [--landed-ref <sha>]
USAGE
}

pass() { printf '[OK] %s\n' "$1"; }
fail() { printf '[ERROR] %s\n' "$1" >&2; errors=$((errors + 1)); }

resolve_path() {
  local path="$1"
  case "$path" in
    /*) printf '%s\n' "$path" ;;
    *) printf '%s/%s\n' "$ROOT_DIR" "$path" ;;
  esac
}

rel_path() {
  local path="$1"
  case "$path" in
    "$ROOT_DIR"/*) printf '%s\n' "${path#$ROOT_DIR/}" ;;
    *) printf '%s\n' "$path" ;;
  esac
}

digest_file() {
  local file="$1"
  local digest
  digest="$(shasum -a 256 "$file" | awk '{print $1}')"
  printf 'sha256:%s\n' "$digest"
}

json_value() {
  local expr="$1"
  jq -r "$expr // \"\"" "$MANIFEST"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --manifest)
      shift
      MANIFEST="${1:-}"
      ;;
    --change-id)
      shift
      CHANGE_ID="${1:-}"
      ;;
    --landed-ref)
      shift
      LANDED_REF="${1:-}"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
  shift
done

[[ -n "$MANIFEST" ]] || { usage >&2; exit 2; }
MANIFEST="$(resolve_path "$MANIFEST")"

if [[ -f "$SCHEMA" ]]; then
  pass "terminal local evidence schema exists"
else
  fail "terminal local evidence schema exists"
fi

if jq -e '.' "$SCHEMA" >/dev/null 2>&1; then
  pass "terminal local evidence schema parses as JSON"
else
  fail "terminal local evidence schema parses as JSON"
fi

if [[ -f "$MANIFEST" ]]; then
  pass "terminal local evidence manifest exists"
else
  fail "terminal local evidence manifest exists"
  printf 'Validation summary: errors=%s\n' "$errors"
  exit 1
fi

if jq -e '.' "$MANIFEST" >/dev/null 2>&1; then
  pass "terminal local evidence manifest parses as JSON"
else
  fail "terminal local evidence manifest parses as JSON"
  printf 'Validation summary: errors=%s\n' "$errors"
  exit 1
fi

set +e
python3 - "$MANIFEST" "$ROOT_DIR" "$CHANGE_ID" "$LANDED_REF" <<'PY'
import hashlib
import json
import re
import sys
from pathlib import Path, PurePosixPath

manifest_path = Path(sys.argv[1]).resolve()
root = Path(sys.argv[2]).resolve()
expected_change_id = sys.argv[3]
expected_landed_ref = sys.argv[4]
errors = []

def fail(message):
    errors.append(message)

def require(condition, message):
    if not condition:
        fail(message)

def rel_to_root(path):
    try:
        return Path(path).resolve().relative_to(root).as_posix()
    except ValueError:
        return None

def digest(path):
    h = hashlib.sha256()
    with Path(path).open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            h.update(chunk)
    return "sha256:" + h.hexdigest()

def local_terminal_path(text, change_id):
    if not isinstance(text, str) or not text:
        return False
    try:
        parsed = PurePosixPath(text)
    except Exception:
        return False
    if parsed.is_absolute() or ".." in parsed.parts:
        return False
    prefix = PurePosixPath(".octon/state/evidence/local/terminal-closeout") / change_id
    return parsed == prefix or str(parsed).startswith(str(prefix) + "/")

data = json.loads(manifest_path.read_text(encoding="utf-8"))
require(data.get("schema_version") == "terminal-closeout-local-evidence-v1", "schema_version must be terminal-closeout-local-evidence-v1")
change_id = data.get("change_id")
require(isinstance(change_id, str) and re.match(r"^[A-Za-z0-9._:-]+$", change_id or ""), "change_id must be present and safe")
if expected_change_id:
    require(change_id == expected_change_id, "manifest change_id must match expected change id")
require(data.get("sink_root") == ".octon/state/evidence/local/terminal-closeout", "sink_root must be terminal-closeout local root")
require(data.get("disclosure_tier") == "local-private", "disclosure_tier must be local-private")
require(data.get("non_authority_classification") == "retained-evidence-only", "non_authority_classification must be retained-evidence-only")
sink_path = data.get("sink_path")
require(local_terminal_path(sink_path, change_id), "sink_path must be under .octon/state/evidence/local/terminal-closeout/<change-id>")
require(rel_to_root(manifest_path) == f"{sink_path}/manifest.json", "manifest path must match sink_path/manifest.json")

boundaries = data.get("authority_boundaries") or {}
for key in [
    "not_landing_authorization",
    "not_cleanup_authorization",
    "not_hosted_check_evidence",
    "not_packet_evidence",
    "not_archive_evidence",
    "not_generated_publication_evidence",
    "not_policy_authority",
    "not_mutation_authority",
]:
    require(boundaries.get(key) is True, f"authority_boundaries.{key} must be true")

final_refs = data.get("final_refs") or {}
for key in ["head_ref", "main_ref", "origin_main_ref", "landed_ref"]:
    require(isinstance(final_refs.get(key), str) and final_refs[key], f"final_refs.{key} must be present")
landed_ref = final_refs.get("landed_ref")
if expected_landed_ref:
    require(landed_ref == expected_landed_ref, "manifest landed_ref must match expected landed ref")

alignment = data.get("alignment") or {}
for key in [
    "head_equals_local_main",
    "local_main_equals_origin_main",
    "origin_main_contains_landed_ref",
    "local_main_contains_landed_ref",
]:
    require(alignment.get(key) is True, f"alignment.{key} must be true")

source_refs = data.get("source_refs") or {}
proof_ref = source_refs.get("terminal_current_state_proof_ref")
receipt_ref = source_refs.get("change_receipt_ref")
require(local_terminal_path(proof_ref, change_id), "terminal_current_state_proof_ref must be under the terminal local sink")
require(local_terminal_path(receipt_ref, change_id), "change_receipt_ref must be under the terminal local sink")

for field in ["landing_authorization_ref", "cleanup_authorization_ref"]:
    if field in source_refs:
        require(local_terminal_path(source_refs[field], change_id), f"source_refs.{field} must be a copied local sink snapshot")

copied_files = data.get("copied_files")
require(isinstance(copied_files, list) and copied_files, "copied_files must be non-empty")
copied_by_name = {}
for index, item in enumerate(copied_files if isinstance(copied_files, list) else []):
    if not isinstance(item, dict):
        fail(f"copied_files[{index}] must be an object")
        continue
    name = item.get("logical_name")
    path = item.get("path")
    item_digest = item.get("digest")
    require(isinstance(name, str) and name, f"copied_files[{index}].logical_name must be present")
    require(local_terminal_path(path, change_id), f"copied_files[{index}].path must be under the terminal local sink")
    full_path = root / path if isinstance(path, str) else None
    require(full_path is not None and full_path.is_file(), f"copied_files[{index}].path must exist")
    if full_path is not None and full_path.is_file():
        actual = digest(full_path)
        require(item_digest == actual, f"copied_files[{index}].digest must match file digest")
    copied_by_name[name] = item

for required_name in ["terminal_current_state_proof", "change_receipt"]:
    require(required_name in copied_by_name, f"copied_files must include {required_name}")

if "terminal_current_state_proof" in copied_by_name:
    require(data.get("terminal_current_state_proof_digest") == copied_by_name["terminal_current_state_proof"].get("digest"), "terminal_current_state_proof_digest must match copied proof digest")
if "change_receipt" in copied_by_name:
    require(data.get("change_receipt_digest") == copied_by_name["change_receipt"].get("digest"), "change_receipt_digest must match copied receipt digest")

snapshots = data.get("snapshots") or {}
for ref_field, digest_field in [
    ("refs_ref", "refs_digest"),
    ("status_ref", "status_digest"),
    ("residue_classification_ref", "residue_classification_digest"),
]:
    ref = snapshots.get(ref_field)
    require(local_terminal_path(ref, change_id), f"snapshots.{ref_field} must be under the terminal local sink")
    full_path = root / ref if isinstance(ref, str) else None
    require(full_path is not None and full_path.is_file(), f"snapshots.{ref_field} must exist")
    if full_path is not None and full_path.is_file():
        require(snapshots.get(digest_field) == digest(full_path), f"snapshots.{digest_field} must match file digest")

if errors:
    for message in errors:
        print(f"[ERROR] {message}")
    print(f"Python validation summary: errors={len(errors)}")
    sys.exit(1)

print("[OK] terminal local evidence manifest fields and digests are valid")
print("Python validation summary: errors=0")
PY
python_status=$?
set -e
if [[ "$python_status" -ne 0 ]]; then
  errors=$((errors + 1))
fi

proof_ref="$(json_value '.source_refs.terminal_current_state_proof_ref')"
proof_path="$(resolve_path "$proof_ref")"
if [[ -f "$proof_path" ]]; then
  if "$TERMINAL_PROOF_VALIDATOR" --proof "$proof_path" --require-cleaned >/dev/null; then
    pass "terminal local proof validates as cleaned current-state proof"
  else
    fail "terminal local proof validates as cleaned current-state proof"
  fi
else
  fail "terminal local proof file exists"
fi

if [[ -n "$CHANGE_ID" ]]; then
  proof_change_id="$(yq -r '.change_id // ""' "$proof_path" 2>/dev/null || true)"
  [[ "$proof_change_id" == "$CHANGE_ID" ]] && pass "terminal local proof change_id matches" || fail "terminal local proof change_id must match"
fi

if [[ -n "$LANDED_REF" ]]; then
  proof_landed_ref="$(yq -r '.final_refs.landed_ref // ""' "$proof_path" 2>/dev/null || true)"
  [[ "$proof_landed_ref" == "$LANDED_REF" ]] && pass "terminal local proof landed_ref matches" || fail "terminal local proof landed_ref must match"
fi

printf 'Validation summary: errors=%s\n' "$errors"
[[ "$errors" -eq 0 ]]
