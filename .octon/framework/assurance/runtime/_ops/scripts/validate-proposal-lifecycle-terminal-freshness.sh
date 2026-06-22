#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"

TARGET=""
CHILDREN_FILE=""
RUN_REGISTRY_CHECK=0
TARGETED=0
GMI_RECEIPT_VALIDATOR="$SCRIPT_DIR/validate-governed-mechanism-integration-receipt.sh"
errors=0

usage() {
  cat <<'EOF'
usage:
  validate-proposal-lifecycle-terminal-freshness.sh --proposal <path> [--children-file <path>] [--targeted] [--run-registry-check] [--root <repo-root>]
  validate-proposal-lifecycle-terminal-freshness.sh --program <path> [--children-file <path>] [--targeted] [--run-registry-check] [--root <repo-root>]

Validates late proposal lifecycle freshness for the scoped packet set by
checking generated proposal registry freshness when requested, artifact index
freshness, artifact spine freshness, targeted dependency refs when requested,
and governed mechanism integration receipt freshness when the scoped proposal
declares that gate.
EOF
}

pass() { printf '[OK] %s\n' "$1"; }
fail() { printf '[ERROR] %s\n' "$1" >&2; errors=$((errors + 1)); }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --proposal|--package|--program)
      shift
      TARGET="${1:-}"
      ;;
    --children-file)
      shift
      CHILDREN_FILE="${1:-}"
      ;;
    --run-registry-check)
      RUN_REGISTRY_CHECK=1
      ;;
    --targeted)
      TARGETED=1
      ;;
    --root)
      shift
      ROOT_DIR="$(cd -- "${1:-}" && pwd)"
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

if [[ -z "$TARGET" ]]; then
  usage >&2
  exit 2
fi

resolve_path() {
  local path="$1"
  if [[ "$path" = /* ]]; then
    printf '%s\n' "$path"
  else
    printf '%s/%s\n' "$ROOT_DIR" "$path"
  fi
}

rel_path() {
  local path="$1"
  if [[ "$path" == "$ROOT_DIR" ]]; then
    printf '.\n'
  else
    printf '%s\n' "${path#$ROOT_DIR/}"
  fi
}

run_check() {
  local label="$1"
  shift
  if "$@"; then
    pass "$label"
  else
    fail "$label"
  fi
}

proposal_in_scope() {
  local candidate="$1"
  local existing
  for existing in "${PROPOSALS[@]}"; do
    [[ "$existing" == "$candidate" ]] && return 0
  done
  return 1
}

append_targeted_dependency_paths() {
  local proposal="$1"
  local deps_file="$2"
  local deps_tmp
  deps_tmp="$(mktemp "${TMPDIR:-/tmp}/octon-targeted-proposal-deps.XXXXXX")"
  if python3 - "$ROOT_DIR" "$proposal" "$deps_tmp" <<'PY'
import hashlib
import json
import pathlib
import re
import subprocess
import sys

root = pathlib.Path(sys.argv[1]).resolve()
proposal_dir = pathlib.Path(sys.argv[2]).resolve()
deps_output = pathlib.Path(sys.argv[3])
errors = []
proposal_id_pattern = re.compile(r"^[a-z][a-z0-9]*(-[a-z0-9]+)*$")
proposal_kind_dirs = ["architecture", "design", "migration", "policy"]

def fail(message):
    errors.append(message)
    print(f"[ERROR] {message}", file=sys.stderr)

def rel(path):
    return str(pathlib.Path(path).resolve().relative_to(root))

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
        fail(f"YAML parse failed for {rel(path)}: {result.stderr.strip()}")
        return {}
    try:
        return json.loads(result.stdout or "{}")
    except json.JSONDecodeError as exc:
        fail(f"YAML JSON decode failed for {rel(path)}: {exc}")
        return {}

def resolve_dependency(dependency_id, ref_type, source_field):
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

manifest = proposal_dir / "proposal.yml"
if not manifest.is_file():
    fail(f"proposal manifest missing for targeted dependency check: {proposal_dir}")
    deps_output.write_text("")
    sys.exit(1)

proposal = load_yaml(manifest)
proposal_id = proposal.get("proposal_id") or proposal_dir.name
proposal_kind = proposal.get("proposal_kind") or "unknown"
parent_program = proposal.get("parent_program") or ""
related_proposals = proposal.get("related_proposals") or []
if related_proposals is None:
    related_proposals = []
if not isinstance(related_proposals, list):
    fail("related_proposals must be a list when present")
    related_proposals = []

expected = []
if parent_program:
    resolved = resolve_dependency(parent_program, "parent_program", "proposal.yml#parent_program")
    if resolved:
        expected.append(resolved)
for related_id in related_proposals:
    resolved = resolve_dependency(related_id, "related_proposal", "proposal.yml#related_proposals")
    if resolved:
        expected.append(resolved)

artifact_dir = root / ".octon/generated/proposals/artifacts" / proposal_kind / proposal_id
index_path = artifact_dir / "proposal-artifact-index.yml"
spine_path = artifact_dir / "proposal-program-spine.yml"
index = load_yaml(index_path) if index_path.is_file() else {}
spine = load_yaml(spine_path) if spine_path.is_file() else {}
if not index:
    fail(f"proposal artifact index readable for targeted dependency check: {rel(index_path)}")
if not spine:
    fail(f"proposal program spine readable for targeted dependency check: {rel(spine_path)}")

expected_by_key = {(item["ref_type"], item["proposal_id"]): item for item in expected}

def check_generated_refs(refs, label):
    if refs is None:
        refs = []
    if not isinstance(refs, list):
        fail(f"{label} dependency refs must be a list")
        return
    generated_by_key = {}
    for item in refs:
        if not isinstance(item, dict):
            fail(f"{label} dependency ref is not an object")
            continue
        key = (item.get("ref_type"), item.get("proposal_id"))
        generated_by_key[key] = item
    for key, expected_item in expected_by_key.items():
        generated = generated_by_key.get(key)
        if not generated:
            fail(f"{label} missing dependency ref: {key[0]} {key[1]}")
            continue
        for field in ["proposal_kind", "proposal_path", "manifest_ref", "manifest_sha256", "source_field", "required"]:
            if generated.get(field) != expected_item.get(field):
                fail(f"{label} stale dependency metadata for {key[0]} {key[1]} field {field}")
    for key in generated_by_key:
        if key not in expected_by_key:
            fail(f"{label} contains undeclared dependency ref: {key[0]} {key[1]}")

check_generated_refs(index.get("targeted_dependency_refs"), "proposal artifact index")
check_generated_refs(spine.get("dependency_refs"), "proposal program spine")

deps_output.write_text("".join(f"{item['proposal_path']}\n" for item in expected))
sys.exit(1 if errors else 0)
PY
  then
    pass "targeted dependency metadata validates: $(rel_path "$proposal")"
    cat "$deps_tmp" >>"$deps_file"
  else
    fail "targeted dependency metadata validates: $(rel_path "$proposal")"
  fi
  rm -f "$deps_tmp"
}

TARGET_ABS="$(resolve_path "$TARGET")"
if [[ -d "$TARGET_ABS" && -f "$TARGET_ABS/proposal.yml" ]]; then
  pass "target proposal exists: $(rel_path "$TARGET_ABS")"
else
  fail "target proposal exists: $TARGET"
fi

declare -a PROPOSALS=("$TARGET_ABS")
if [[ -n "$CHILDREN_FILE" ]]; then
  if [[ "$RUN_REGISTRY_CHECK" -ne 1 && "$TARGETED" -ne 1 ]]; then
    fail "scoped child validation requires --run-registry-check"
  elif [[ "$TARGETED" -eq 1 && "$RUN_REGISTRY_CHECK" -ne 1 ]]; then
    pass "targeted child validation uses scoped child file without full registry traversal"
  fi
  CHILDREN_ABS="$(resolve_path "$CHILDREN_FILE")"
  if [[ -f "$CHILDREN_ABS" ]]; then
    pass "children file exists: $(rel_path "$CHILDREN_ABS")"
    while IFS= read -r child || [[ -n "$child" ]]; do
      child="${child%%#*}"
      child="${child#"${child%%[![:space:]]*}"}"
      child="${child%"${child##*[![:space:]]}"}"
      [[ -z "$child" ]] && continue
      PROPOSALS+=("$(resolve_path "$child")")
    done <"$CHILDREN_ABS"
  else
    fail "children file exists: $CHILDREN_FILE"
  fi
fi
TARGETED_DEPENDENCY_ROOT_COUNT="${#PROPOSALS[@]}"

if [[ "$RUN_REGISTRY_CHECK" -eq 1 ]]; then
  if [[ "$ROOT_DIR" != "$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)" ]]; then
    fail "registry freshness check requires the real repository root"
  else
  run_check "proposal registry projection is fresh" \
    bash "$SCRIPT_DIR/generate-proposal-registry.sh" --check
  fi
fi

for ((i = 0; i < ${#PROPOSALS[@]}; i++)); do
  proposal="${PROPOSALS[$i]}"
  if [[ ! -d "$proposal" || ! -f "$proposal/proposal.yml" ]]; then
    fail "scoped proposal has manifest: $(rel_path "$proposal")"
    continue
  fi
  pass "scoped proposal has manifest: $(rel_path "$proposal")"
  run_check "proposal artifact index is fresh: $(rel_path "$proposal")" \
    bash "$SCRIPT_DIR/generate-proposal-artifact-index.sh" --root "$ROOT_DIR" --proposal "$proposal" --check
  run_check "proposal artifact spine validates: $(rel_path "$proposal")" \
    bash "$SCRIPT_DIR/validate-proposal-artifact-index-spine.sh" --root "$ROOT_DIR" --proposal "$proposal"

  receipt="$proposal/support/governed-mechanism-integration-evaluation.yml"
  requires_gmi=0
  if yq -r '.validation_gates[]?' "$proposal/proposal.yml" 2>/dev/null | grep -Fqi "governed mechanism integration"; then
    requires_gmi=1
  fi
  status="$(yq -r '.status // ""' "$proposal/proposal.yml" 2>/dev/null || true)"
  archive_disposition="$(yq -r '.archive.disposition // ""' "$proposal/proposal.yml" 2>/dev/null || true)"
  if [[ -f "$receipt" ]]; then
    run_check "governed mechanism integration receipt validates: $(rel_path "$proposal")" \
      bash "$GMI_RECEIPT_VALIDATOR" --receipt "$receipt" --package "$(rel_path "$proposal")"
  elif [[ "$requires_gmi" -eq 1 && ( "$status" == "implemented" || ( "$status" == "archived" && "$archive_disposition" == "implemented" ) ) ]]; then
    fail "governed mechanism integration receipt exists for implemented terminal freshness: $(rel_path "$proposal")"
  else
    pass "governed mechanism integration receipt not required for current lifecycle state: $(rel_path "$proposal")"
  fi

  if [[ "$TARGETED" -eq 1 && "$i" -lt "$TARGETED_DEPENDENCY_ROOT_COUNT" ]]; then
    deps_file="$(mktemp "${TMPDIR:-/tmp}/octon-targeted-proposal-deps.list.XXXXXX")"
    append_targeted_dependency_paths "$proposal" "$deps_file"
    while IFS= read -r dependency || [[ -n "$dependency" ]]; do
      [[ -z "$dependency" ]] && continue
      dependency_abs="$(resolve_path "$dependency")"
      if proposal_in_scope "$dependency_abs"; then
        pass "targeted dependency already scoped: $(rel_path "$dependency_abs")"
      else
        PROPOSALS+=("$dependency_abs")
        pass "targeted dependency queued: $(rel_path "$dependency_abs")"
      fi
    done <"$deps_file"
    rm -f "$deps_file"
  fi
done

printf 'Terminal freshness validation summary: checked=%s errors=%s\n' "${#PROPOSALS[@]}" "$errors"
[[ "$errors" -eq 0 ]]
