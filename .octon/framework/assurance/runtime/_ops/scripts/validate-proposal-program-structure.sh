#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
FRAMEWORK_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
OCTON_DIR="$(cd -- "$FRAMEWORK_DIR/.." && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"
source "$SCRIPT_DIR/validator-recovery-diagnostics.sh"

PROGRAM_PATH=""
errors=0
warnings=0

declare -A CHILD_SEEN=()

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

warn() {
  echo "[WARN] $1"
  warnings=$((warnings + 1))
}

pass() {
  echo "[OK] $1"
}

program_structure_rerun_gate() {
  printf 'validate-proposal-program-structure.sh --package %s\n' "$PROGRAM_PATH"
}

program_structure_repo_rel() {
  local path="$1"
  case "$path" in
    "$ROOT_DIR"/*)
      printf '%s\n' "${path#$ROOT_DIR/}"
      ;;
    *)
      printf '%s\n' "$path"
      ;;
  esac
}

usage() {
  cat <<'EOF'
usage:
  validate-proposal-program-structure.sh --package <program-packet-path>
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --package)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      PROGRAM_PATH="$1"
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
  shift
done

[[ -n "$PROGRAM_PATH" ]] || { usage >&2; exit 2; }

if [[ "$PROGRAM_PATH" = /* ]]; then
  PROGRAM_DIR="$PROGRAM_PATH"
  if [[ "$PROGRAM_PATH" == "$ROOT_DIR/"* ]]; then
    PROGRAM_REL="${PROGRAM_PATH#$ROOT_DIR/}"
  else
    PROGRAM_REL="$(basename "$PROGRAM_PATH")"
  fi
else
  PROGRAM_DIR="$ROOT_DIR/$PROGRAM_PATH"
  PROGRAM_REL="$PROGRAM_PATH"
fi

MANIFEST="$PROGRAM_DIR/proposal.yml"
REGISTRY="$PROGRAM_DIR/resources/child-packet-index.yml"
HUMAN_INDEX="$PROGRAM_DIR/resources/child-packet-index.md"
SEQUENCE="$PROGRAM_DIR/architecture/packet-sequence.md"
CHILD_CONTRACT="$PROGRAM_DIR/architecture/child-packet-contract.md"
CLOSEOUT_PLAN="$PROGRAM_DIR/architecture/program-closeout-plan.md"

safe_rel_path() {
  local value="$1"
  [[ -n "$value" \
    && "$value" != /* \
    && "$value" != "." \
    && "$value" != ./* \
    && "$value" != */./* \
    && "$value" != */. \
    && "$value" != *"../"* \
    && "$value" != ../* \
    && "$value" != *"/.." \
    && "$value" != ".." ]]
}

valid_child_id() {
  [[ "$1" =~ ^[a-z][a-z0-9-]*$ ]]
}

require_file() {
  local file="$1" label="$2"
  if [[ -f "$file" ]]; then
    pass "$label exists"
  else
    emit_recovery_diagnostic \
      --recovery-class "missing_required_file" \
      --failing-path "$(program_structure_repo_rel "$file")" \
      --minimal-repair-hint "create the required program packet artifact and rerun the structure gate" \
      --rerun-gate "$(program_structure_rerun_gate)"
    fail "$label exists"
  fi
}

require_yaml() {
  local file="$1" label="$2"
  if [[ -f "$file" ]] && yq -e '.' "$file" >/dev/null 2>&1; then
    pass "$label parses"
  else
    emit_recovery_diagnostic \
      --recovery-class "invalid_yaml" \
      --failing-path "$(program_structure_repo_rel "$file")" \
      --minimal-repair-hint "repair YAML syntax for the program packet artifact" \
      --rerun-gate "$(program_structure_rerun_gate)"
    fail "$label parses"
  fi
}

require_mentions_child_ids() {
  local file="$1" label="$2" id
  [[ -f "$file" ]] || return 0
  while IFS= read -r id; do
    [[ -n "$id" ]] || continue
    if grep -Fq -- "$id" "$file"; then
      pass "$label mentions child id: $id"
    else
      fail "$label mentions child id: $id"
    fi
  done < <(registry_child_ids)
}

registry_child_ids() {
  yq -r '.children[]?.child_id // ""' "$REGISTRY" 2>/dev/null | awk 'NF' | sort -u
}

related_child_ids() {
  {
    yq -r '.related_proposals[]? | select(tag == "!!str")' "$MANIFEST" 2>/dev/null || true
    yq -r '.related_proposals[]? | select(tag == "!!map") | (.proposal_id // .child_id // .id // "")' "$MANIFEST" 2>/dev/null || true
  } | awk 'NF' | sort -u
}

normalize_program_execution_mode() {
  local mode="$1"
  case "$mode" in
    sequential|parallel-independent|gated-parallel|approval-gated|program-atomic)
      printf '%s\n' "$mode"
      ;;
    sequenced-gated)
      printf '%s\n' "gated-parallel"
      ;;
    *)
      return 1
      ;;
  esac
}

validate_program_execution_modes() {
  local registry_mode parent_mode normalized_registry normalized_parent
  registry_mode="$(yq -r '.execution_mode // ""' "$REGISTRY" 2>/dev/null || true)"
  if normalized_registry="$(normalize_program_execution_mode "$registry_mode")"; then
    if [[ "$registry_mode" == "sequenced-gated" ]]; then
      pass "program registry execution_mode legacy alias normalizes to gated-parallel"
    else
      pass "program registry execution_mode is supported: $registry_mode"
    fi
  else
    emit_recovery_diagnostic \
      --recovery-class "child_registry_error" \
      --failing-path "$(program_structure_repo_rel "$REGISTRY")#execution_mode" \
      --observed-value "$registry_mode" \
      --minimal-repair-hint "set resources/child-packet-index.yml#execution_mode to one of sequential, parallel-independent, gated-parallel, approval-gated, program-atomic, or the legacy sequenced-gated alias for gated-parallel" \
      --rerun-gate "$(program_structure_rerun_gate)"
    fail "program registry execution_mode is supported: $registry_mode"
    return 0
  fi

  parent_mode="$(yq -r '.program_execution_mode // ""' "$MANIFEST" 2>/dev/null || true)"
  [[ -n "$parent_mode" && "$parent_mode" != "null" ]] || return 0
  if normalized_parent="$(normalize_program_execution_mode "$parent_mode")"; then
    pass "parent program_execution_mode is supported: $parent_mode"
  else
    emit_recovery_diagnostic \
      --recovery-class "child_registry_error" \
      --failing-path "$(program_structure_repo_rel "$MANIFEST")#program_execution_mode" \
      --observed-value "$parent_mode" \
      --minimal-repair-hint "set proposal.yml#program_execution_mode to a supported canonical mode or the legacy sequenced-gated alias" \
      --rerun-gate "$(program_structure_rerun_gate)"
    fail "parent program_execution_mode is supported: $parent_mode"
    return 0
  fi

  if [[ "$normalized_parent" == "$normalized_registry" ]]; then
    pass "parent program_execution_mode agrees with registry execution_mode after normalization"
  else
    emit_recovery_diagnostic \
      --recovery-class "child_registry_error" \
      --failing-path "$(program_structure_repo_rel "$REGISTRY")#execution_mode" \
      --observed-value "parent=$parent_mode registry=$registry_mode" \
      --minimal-repair-hint "make proposal.yml#program_execution_mode and resources/child-packet-index.yml#execution_mode agree after alias normalization" \
      --rerun-gate "$(program_structure_rerun_gate)"
    fail "parent program_execution_mode agrees with registry execution_mode after normalization"
  fi
}

compare_registry_to_related_proposals() {
  local missing extra
  missing="$(comm -23 <(registry_child_ids) <(related_child_ids) || true)"
  extra="$(comm -13 <(registry_child_ids) <(related_child_ids) || true)"

  if [[ -z "$missing" ]]; then
    pass "related_proposals covers registry children"
  else
    emit_recovery_diagnostic \
      --recovery-class "child_registry_error" \
      --failing-path "$(program_structure_repo_rel "$MANIFEST")#related_proposals" \
      --observed-value "$missing" \
      --minimal-repair-hint "add every child-packet-index.yml child_id to proposal.yml related_proposals" \
      --rerun-gate "$(program_structure_rerun_gate)"
    fail "related_proposals covers registry children: ${missing//$'\n'/, }"
  fi

  if [[ -z "$extra" ]]; then
    pass "related_proposals contains no extra child ids"
  else
    emit_recovery_diagnostic \
      --recovery-class "child_registry_error" \
      --failing-path "$(program_structure_repo_rel "$MANIFEST")#related_proposals" \
      --observed-value "$extra" \
      --minimal-repair-hint "remove related_proposals entries that are not present in child-packet-index.yml" \
      --rerun-gate "$(program_structure_rerun_gate)"
    fail "related_proposals contains no extra child ids: ${extra//$'\n'/, }"
  fi
}

validate_no_nested_children() {
  local child_path="$1" child_id="$2"
  if [[ "$child_path" == "$PROGRAM_REL" || "$child_path" == "$PROGRAM_REL"/* ]]; then
    emit_hard_blocker_recovery_diagnostic \
      "$(program_structure_repo_rel "$REGISTRY")#children[$child_id].path" \
      "child packet path is nested under the parent program packet" \
      "$(program_structure_rerun_gate)" \
      "$child_path"
    fail "child $child_id path is not nested under parent program"
  else
    pass "child $child_id path is not nested under parent program"
  fi
}

validate_no_forbidden_parent_authority_surfaces() {
  local output
  if [[ ! -d "$PROGRAM_DIR" ]]; then
    return 0
  fi
  output="$(
    grep -RInE '^[[:space:]]*(child_validation_verdicts|child_archive_metadata|child_receipts|child_promotion_targets|child_terminal_outcomes|child_archive_authorized|satisfies_child_receipts):' "$PROGRAM_DIR" 2>/dev/null || true
  )"
  if [[ -z "$output" ]]; then
    pass "parent package contains no child-owned authority surfaces"
  else
    emit_hard_blocker_recovery_diagnostic \
      "$(program_structure_repo_rel "$PROGRAM_DIR")" \
      "parent package contains child-owned authority surfaces" \
      "$(program_structure_rerun_gate)" \
      "$output"
    fail "parent package contains child-owned authority surfaces"
    printf '%s\n' "$output"
  fi
}

validate_write_scope_collision_ledger() {
  local registry_json
  [[ -f "$REGISTRY" ]] || return 0
  registry_json="$(mktemp)"
  if ! yq -o=json '.' "$REGISTRY" >"$registry_json" 2>/dev/null; then
    rm -f "$registry_json"
    return 0
  fi

  if python3 - "$registry_json" <<'PY'
import collections
import hashlib
import json
import re
import sys

registry_path = sys.argv[1]
with open(registry_path, "r", encoding="utf-8") as handle:
    registry = json.load(handle)

errors = []


def error(message):
    errors.append(message)


def relation(left, right):
    if left == right:
        return "exact"
    if (left.endswith("/") and right.startswith(left)) or (
        right.endswith("/") and left.startswith(right)
    ):
        return "directory-prefix"
    return None


children = registry.get("children")
if not isinstance(children, list):
    error("children must be an array before collision derivation")
    children = []

child_by_id = {}
projection = []
scope_entries = 0
unique_paths = set()
for index, child in enumerate(children):
    if not isinstance(child, dict):
        error(f"child[{index}] must be an object")
        continue
    child_id = child.get("child_id")
    dependencies = child.get("dependencies", [])
    write_scopes = child.get("write_scopes", [])
    if not isinstance(child_id, str):
        error(f"child[{index}] child_id must be a string")
        continue
    if not isinstance(dependencies, list) or not all(isinstance(v, str) for v in dependencies):
        error(f"child {child_id} dependencies must be a string array")
        dependencies = []
    if not isinstance(write_scopes, list) or not all(isinstance(v, str) for v in write_scopes):
        error(f"child {child_id} write_scopes must be a string array")
        write_scopes = []
    if len(dependencies) != len(set(dependencies)):
        error(f"child {child_id} has duplicate dependencies")
    if len(write_scopes) != len(set(write_scopes)):
        error(f"child {child_id} has duplicate write_scopes")
    child_by_id[child_id] = {
        "dependencies": list(dependencies),
        "write_scopes": list(write_scopes),
    }
    projection.append(
        {
            "child_id": child_id,
            "dependencies": sorted(dependencies),
            "write_scopes": sorted(write_scopes),
        }
    )
    scope_entries += len(write_scopes)
    unique_paths.update(write_scopes)

projection.sort(key=lambda row: row["child_id"])
projection_bytes = (
    json.dumps(projection, ensure_ascii=False, separators=(",", ":")) + "\n"
).encode("utf-8")
projection_digest = "sha256:" + hashlib.sha256(projection_bytes).hexdigest()

derived = {}
ordered_children = sorted(child_by_id)
for left_index, left_id in enumerate(ordered_children):
    for right_id in ordered_children[left_index + 1 :]:
        for left_scope in sorted(child_by_id[left_id]["write_scopes"]):
            for right_scope in sorted(child_by_id[right_id]["write_scopes"]):
                kind = relation(left_scope, right_scope)
                if kind is None:
                    continue
                key = (left_id, left_scope, right_id, right_scope)
                derived[key] = kind


def reachable(predecessor, successor):
    """Return true when successor transitively depends on predecessor."""
    pending = list(child_by_id.get(successor, {}).get("dependencies", []))
    seen = set()
    while pending:
        current = pending.pop()
        if current == predecessor:
            return True
        if current in seen:
            continue
        seen.add(current)
        pending.extend(child_by_id.get(current, {}).get("dependencies", []))
    return False


ledger = registry.get("write_scope_collision_ledger")
if ledger is None:
    if derived:
        error(
            f"write_scope_collision_ledger is required for {len(derived)} derived collisions"
        )
else:
    if not isinstance(ledger, dict):
        error("write_scope_collision_ledger must be an object")
        ledger = {}
    allowed_ledger = {
        "schema_version",
        "enforcement_state",
        "mutation_guard",
        "registry_projection_format",
        "registry_write_scopes_digest",
        "derived_counts",
        "records",
    }
    unknown = sorted(set(ledger) - allowed_ledger)
    if unknown:
        error(f"ledger has unknown fields: {', '.join(unknown)}")
    if ledger.get("schema_version") != "octon-program-write-scope-collision-ledger-v1":
        error("ledger schema_version must be octon-program-write-scope-collision-ledger-v1")
    if ledger.get("registry_write_scopes_digest") != projection_digest:
        error(
            "ledger registry_write_scopes_digest is stale: "
            f"expected {projection_digest}, observed {ledger.get('registry_write_scopes_digest')}"
        )

    exact_count = sum(kind == "exact" for kind in derived.values())
    prefix_count = sum(kind == "directory-prefix" for kind in derived.values())
    expected_counts = {
        "child_count": len(child_by_id),
        "scope_entries": scope_entries,
        "unique_paths": len(unique_paths),
        "exact_records": exact_count,
        "directory_prefix_records": prefix_count,
        "total_records": len(derived),
    }
    counts = ledger.get("derived_counts")
    if counts != expected_counts:
        error(
            "ledger derived_counts mismatch: "
            f"expected {expected_counts}, observed {counts}"
        )

    records = ledger.get("records")
    if not isinstance(records, list):
        error("ledger records must be an array")
        records = []
    observed = collections.Counter()
    collision_ids = set()
    serialization_edges = []
    allowed_record = {
        "collision_id",
        "participants",
        "collision_kind",
        "integration_owner_child_id",
        "serialization",
    }
    allowed_participant = {"child_id", "write_scope", "contribution"}
    allowed_serialization = {"mechanism", "lock_id", "ordered_child_ids"}

    for index, record in enumerate(records):
        label = f"ledger record[{index}]"
        if not isinstance(record, dict):
            error(f"{label} must be an object")
            continue
        unknown = sorted(set(record) - allowed_record)
        if unknown:
            error(f"{label} has unknown fields: {', '.join(unknown)}")
        collision_id = record.get("collision_id")
        if not isinstance(collision_id, str) or re.fullmatch(r"WSC-[0-9]{3,}", collision_id) is None:
            error(f"{label} collision_id must match WSC-[0-9]{{3,}}")
        elif collision_id in collision_ids:
            error(f"duplicate collision_id: {collision_id}")
        else:
            collision_ids.add(collision_id)

        participants = record.get("participants")
        if not isinstance(participants, list) or len(participants) != 2:
            error(f"{label} must have exactly two participants")
            continue
        parsed = []
        for participant_index, participant in enumerate(participants):
            participant_label = f"{label} participant[{participant_index}]"
            if not isinstance(participant, dict):
                error(f"{participant_label} must be an object")
                continue
            unknown = sorted(set(participant) - allowed_participant)
            if unknown:
                error(f"{participant_label} has unknown fields: {', '.join(unknown)}")
            child_id = participant.get("child_id")
            scope = participant.get("write_scope")
            contribution = participant.get("contribution")
            if child_id not in child_by_id:
                error(f"{participant_label} names unknown child {child_id}")
            elif scope not in child_by_id[child_id]["write_scopes"]:
                error(f"{participant_label} names undeclared write_scope {scope}")
            if not isinstance(contribution, str) or not contribution.strip():
                error(f"{participant_label} contribution must be nonempty")
            elif len(contribution) > 4096:
                error(f"{participant_label} contribution exceeds 4096 characters")
            if isinstance(child_id, str) and isinstance(scope, str):
                parsed.append((child_id, scope))

        if len(parsed) != 2:
            continue
        if parsed[0][0] == parsed[1][0]:
            error(f"{label} participants must name distinct children")
        canonical = sorted(parsed)
        if parsed != canonical:
            error(f"{label} participants are not canonically sorted")
        key = (canonical[0][0], canonical[0][1], canonical[1][0], canonical[1][1])
        observed[key] += 1
        actual_kind = relation(canonical[0][1], canonical[1][1])
        declared_kind = record.get("collision_kind")
        if actual_kind is None:
            error(f"{label} is an extra non-collision")
        elif declared_kind != actual_kind:
            error(
                f"{label} collision_kind mismatch: expected {actual_kind}, observed {declared_kind}"
            )

        participant_ids = [item[0] for item in canonical]
        owner = record.get("integration_owner_child_id")
        if owner not in participant_ids:
            error(f"{label} integration owner must name exactly one participant")

        serialization = record.get("serialization")
        if not isinstance(serialization, dict):
            error(f"{label} serialization must be an object")
            continue
        unknown = sorted(set(serialization) - allowed_serialization)
        if unknown:
            error(f"{label} serialization has unknown fields: {', '.join(unknown)}")
        mechanism = serialization.get("mechanism")
        lock_id = serialization.get("lock_id")
        order = serialization.get("ordered_child_ids")
        if mechanism not in {"dependency-order", "exclusive-integration-lock"}:
            error(f"{label} serialization mechanism is unsupported: {mechanism}")
            continue
        if (
            not isinstance(order, list)
            or len(order) != 2
            or len(set(order)) != 2
            or set(order) != set(participant_ids)
        ):
            error(f"{label} ordered_child_ids must list both participants exactly once")
            continue
        before, after = order
        if mechanism == "dependency-order":
            if lock_id is not None:
                error(f"{label} dependency-order must not declare lock_id")
            if not reachable(before, after):
                error(
                    f"{label} dependency-order does not agree with transitive reachability"
                )
        else:
            if not isinstance(lock_id, str) or not lock_id.strip():
                error(f"{label} exclusive-integration-lock requires lock_id")
            if reachable(before, after) or reachable(after, before):
                error(f"{label} exclusive-integration-lock participants are not DAG peers")
        serialization_edges.append((before, after, label))

    for key, count in observed.items():
        if count > 1:
            error(f"duplicate or reversed collision record for {key}: count={count}")
    missing = sorted(set(derived) - set(observed))
    extra = sorted(set(observed) - set(derived))
    if missing:
        error(f"ledger is missing {len(missing)} derived collision record(s); first={missing[0]}")
    if extra:
        error(f"ledger has {len(extra)} extra collision record(s); first={extra[0]}")

    graph = {child_id: set() for child_id in child_by_id}
    for child_id, child in child_by_id.items():
        for dependency in child["dependencies"]:
            if dependency in graph:
                graph[dependency].add(child_id)
    for before, after, _ in serialization_edges:
        if before in graph and after in graph:
            graph[before].add(after)

    visiting = set()
    visited = set()

    def visit(node):
        if node in visited:
            return False
        if node in visiting:
            return True
        visiting.add(node)
        for successor in sorted(graph[node]):
            if visit(successor):
                return True
        visiting.remove(node)
        visited.add(node)
        return False

    if any(visit(node) for node in sorted(graph)):
        error("dependency plus collision serialization graph is cyclic")

if errors:
    for message in errors:
        print(f"[ERROR] collision ledger: {message}")
    raise SystemExit(1)

print(
    "[OK] collision ledger projection digest and exact/component-aware "
    f"bijection pass: collisions={len(derived)} digest={projection_digest}"
)
PY
  then
    pass "program write-scope collision ledger is complete, fresh, and acyclic"
  else
    emit_recovery_diagnostic \
      --recovery-class "child_registry_error" \
      --failing-path "$(program_structure_repo_rel "$REGISTRY")#write_scope_collision_ledger" \
      --minimal-repair-hint "regenerate the complete collision ledger from the canonical child/dependency/write-scope projection and repair ownership or serialization errors" \
      --rerun-gate "$(program_structure_rerun_gate)"
    fail "program write-scope collision ledger is complete, fresh, and acyclic"
  fi
  rm -f "$registry_json"
}

if [[ ! -d "$PROGRAM_DIR" ]]; then
  emit_hard_blocker_recovery_diagnostic \
    "$(program_structure_repo_rel "$PROGRAM_DIR")" \
    "program packet directory is missing" \
    "$(program_structure_rerun_gate)"
  fail "program packet exists"
  echo "Validation summary: errors=$errors warnings=$warnings"
  exit 1
fi

require_file "$MANIFEST" "parent proposal.yml"
require_file "$REGISTRY" "program child registry"
require_file "$HUMAN_INDEX" "human child index"
require_file "$SEQUENCE" "packet sequence"
require_file "$CHILD_CONTRACT" "child packet contract"
require_file "$CLOSEOUT_PLAN" "program closeout plan"
require_yaml "$MANIFEST" "parent proposal.yml"
require_yaml "$REGISTRY" "program child registry"
validate_program_execution_modes

if [[ -d "$PROGRAM_DIR/children" ]]; then
  emit_hard_blocker_recovery_diagnostic \
    "$(program_structure_repo_rel "$PROGRAM_DIR/children")" \
    "program packets must not own nested child directories" \
    "$(program_structure_rerun_gate)"
  fail "program has no nested children directory"
else
  pass "program has no nested children directory"
fi

child_count="$(yq -r '(.children // []) | length' "$REGISTRY" 2>/dev/null || echo 0)"
if [[ "$child_count" =~ ^[1-9][0-9]*$ ]]; then
  pass "program child registry declares children"
else
  emit_recovery_diagnostic \
    --recovery-class "child_registry_error" \
    --failing-path "$(program_structure_repo_rel "$REGISTRY")#children" \
    --observed-value "$child_count" \
    --minimal-repair-hint "declare at least one child in resources/child-packet-index.yml" \
    --rerun-gate "$(program_structure_rerun_gate)"
  fail "program child registry declares children"
fi

for ((index=0; index<child_count; index++)); do
  child_id="$(yq -r ".children[$index].child_id // \"\"" "$REGISTRY" 2>/dev/null || true)"
  child_path="$(yq -r ".children[$index].path // \"\"" "$REGISTRY" 2>/dev/null || true)"
  dependencies="$(yq -r ".children[$index].dependencies[]? // \"\"" "$REGISTRY" 2>/dev/null | awk 'NF' || true)"

  valid_child_id "$child_id" && pass "child id valid: $child_id" || {
    emit_recovery_diagnostic \
      --recovery-class "child_registry_error" \
      --failing-path "$(program_structure_repo_rel "$REGISTRY")#children[$index].child_id" \
      --observed-value "$child_id" \
      --minimal-repair-hint "use a child_id matching ^[a-z][a-z0-9-]*$" \
      --rerun-gate "$(program_structure_rerun_gate)"
    fail "child id valid: $child_id"
  }
  if [[ -n "${CHILD_SEEN[$child_id]:-}" ]]; then
    emit_recovery_diagnostic \
      --recovery-class "child_registry_error" \
      --failing-path "$(program_structure_repo_rel "$REGISTRY")#children[$index].child_id" \
      --observed-value "$child_id" \
      --minimal-repair-hint "make every child_id unique in resources/child-packet-index.yml" \
      --rerun-gate "$(program_structure_rerun_gate)"
    fail "child id unique: $child_id"
  else
    CHILD_SEEN["$child_id"]=1
    pass "child id unique: $child_id"
  fi

  safe_rel_path "$child_path" && pass "child $child_id path is repo-relative" || {
    emit_recovery_diagnostic \
      --recovery-class "child_registry_error" \
      --failing-path "$(program_structure_repo_rel "$REGISTRY")#children[$index].path" \
      --observed-value "$child_path" \
      --minimal-repair-hint "set child path to a safe repo-relative proposal packet path" \
      --rerun-gate "$(program_structure_rerun_gate)"
    fail "child $child_id path is repo-relative"
  }
  validate_no_nested_children "$child_path" "$child_id"

  while IFS= read -r dependency; do
    [[ -n "$dependency" ]] || continue
    if [[ -n "${CHILD_SEEN[$dependency]:-}" ]] || yq -e ".children[]? | select(.child_id == \"$dependency\")" "$REGISTRY" >/dev/null 2>&1; then
      pass "child $child_id dependency references registry child: $dependency"
    else
      fail "child $child_id dependency references registry child: $dependency"
      emit_recovery_diagnostic \
        --recovery-class "child_registry_error" \
        --failing-path "$(program_structure_repo_rel "$REGISTRY")#children[$index].dependencies" \
        --observed-value "$dependency" \
        --minimal-repair-hint "make dependencies reference existing child_id values" \
        --rerun-gate "$(program_structure_rerun_gate)"
    fi
  done <<<"$dependencies"
done

compare_registry_to_related_proposals
require_mentions_child_ids "$HUMAN_INDEX" "human child index"
require_mentions_child_ids "$SEQUENCE" "packet sequence"
validate_write_scope_collision_ledger
validate_no_forbidden_parent_authority_surfaces

echo "Validation summary: errors=$errors warnings=$warnings"
[[ "$errors" -eq 0 ]]
