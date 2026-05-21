#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

WRAPPER="$OCTON_DIR/framework/capabilities/runtime/skills/remediation/closeout-worktree/SKILL.md"
WRAPPER_IO="$OCTON_DIR/framework/capabilities/runtime/skills/remediation/closeout-worktree/references/io-contract.md"
WRAPPER_VALIDATION="$OCTON_DIR/framework/capabilities/runtime/skills/remediation/closeout-worktree/references/validation.md"
CLOSEOUT_CHANGE="$OCTON_DIR/framework/capabilities/runtime/skills/remediation/closeout-change/SKILL.md"
STATE_MACHINE="$OCTON_DIR/framework/product/contracts/change-closeout-state-machine.yml"
DEFAULT_WORK_UNIT="$OCTON_DIR/framework/product/contracts/default-work-unit.yml"
SKILL_MANIFEST="$OCTON_DIR/framework/capabilities/runtime/skills/manifest.yml"
SKILL_REGISTRY="$OCTON_DIR/framework/capabilities/runtime/skills/registry.yml"
CAPABILITY_ROUTING="$OCTON_DIR/generated/effective/capabilities/routing.effective.yml"
CODEX_WRAPPER="$ROOT_DIR/.codex/skills/closeout-worktree/SKILL.md"

REPORT_PATH=""
errors=0

usage() {
  cat <<'USAGE'
usage:
  validate-closeout-worktree-wrapper.sh [--report <path>]

Without --report, validates that Closeout Worktree is registered, projected, and
bound as the dirty-worktree wrapper. With --report, also validates a
closeout-worktree-report-v1 evidence record.
USAGE
}

pass() { echo "[OK] $1"; }
fail() { echo "[ERROR] $1"; errors=$((errors + 1)); }

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

require_yq() {
  local file="$1"
  local expr="$2"
  local ok_msg="$3"
  local fail_msg="$4"
  yq -e "$expr" "$file" >/dev/null 2>&1 && pass "$ok_msg" || fail "$fail_msg"
}

validate_static() {
  for file in \
    "$WRAPPER" \
    "$WRAPPER_IO" \
    "$WRAPPER_VALIDATION" \
    "$CLOSEOUT_CHANGE" \
    "$STATE_MACHINE" \
    "$DEFAULT_WORK_UNIT" \
    "$SKILL_MANIFEST" \
    "$SKILL_REGISTRY" \
    "$CAPABILITY_ROUTING" \
    "$CODEX_WRAPPER"
  do
    require_file "$file"
  done

  require_yq "$DEFAULT_WORK_UNIT" '.worktree_wrapper.id == "closeout-worktree"' \
    "default work unit declares closeout-worktree wrapper" \
    "default work unit must declare closeout-worktree wrapper"
  require_yq "$DEFAULT_WORK_UNIT" '.worktree_wrapper.default_work_unit_replacement == false' \
    "wrapper does not replace default work unit" \
    "wrapper must not replace default work unit"
  require_yq "$STATE_MACHINE" '.relationship_to_default_work_unit.dirty_worktree_wrapper.skill_ref == ".octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/SKILL.md"' \
    "state machine binds closeout-worktree wrapper skill" \
    "state machine must bind closeout-worktree wrapper skill"
  require_yq "$SKILL_MANIFEST" '.skills[]? | select(.id == "closeout-worktree" and .skill_class == "invocable" and .path == "remediation/closeout-worktree/")' \
    "skill manifest exposes invocable closeout-worktree" \
    "skill manifest must expose invocable closeout-worktree"
  require_yq "$SKILL_REGISTRY" '.skills."closeout-worktree".commands[]? | select(. == "/closeout-worktree")' \
    "skill registry exposes /closeout-worktree command" \
    "skill registry must expose /closeout-worktree command"
  require_yq "$SKILL_REGISTRY" '.skills."closeout-worktree".host_adapters[]? | select(. == "codex")' \
    "skill registry projects closeout-worktree to Codex" \
    "skill registry must project closeout-worktree to Codex"
  require_yq "$SKILL_REGISTRY" '.skills."closeout-worktree".parameters[]? | select(.name == "include_paths")' \
    "skill registry exposes include path boundaries" \
    "skill registry must expose include path boundaries"
  require_yq "$SKILL_REGISTRY" '.skills."closeout-worktree".parameters[]? | select(.name == "exclude_paths")' \
    "skill registry exposes exclude path boundaries" \
    "skill registry must expose exclude path boundaries"
  require_yq "$CAPABILITY_ROUTING" '.routing_candidates[]? | select(.effective_id == "framework.skill.closeout-worktree") | .host_adapters[]? | select(. == "codex")' \
    "effective routing projects closeout-worktree to Codex" \
    "effective routing must project closeout-worktree to Codex"

  require_literal "$WRAPPER" "Dirty-worktree wrapper for decomposing multiple local change sets" \
    "wrapper describes multi-change decomposition" \
    "wrapper must describe multi-change decomposition"
  require_literal "$WRAPPER" 'singular `closeout-change` runs' \
    "wrapper delegates to singular closeout-change runs" \
    "wrapper must delegate to singular closeout-change runs"
  require_literal "$WRAPPER" "Do not create a \`Closeout Changes\` model" \
    "wrapper forbids Closeout Changes model" \
    "wrapper must forbid Closeout Changes model"
  require_literal "$WRAPPER" "schema_version: closeout-worktree-report-v1" \
    "wrapper documents report schema version" \
    "wrapper must document report schema version"
  require_literal "$WRAPPER_IO" "closeout-worktree-report-v1" \
    "I/O contract documents wrapper report schema" \
    "I/O contract must document wrapper report schema"
  require_literal "$WRAPPER_IO" "final_candidate_dispositions" \
    "I/O contract documents final candidate dispositions" \
    "I/O contract must document final candidate dispositions"
  require_literal "$WRAPPER_IO" "Each iteration must include" \
    "I/O contract documents orchestration iterations" \
    "I/O contract must document orchestration iterations"
  require_literal "$WRAPPER_VALIDATION" "selected candidate has explicit include and exclude path boundaries" \
    "wrapper validation requires explicit boundaries" \
    "wrapper validation must require explicit boundaries"
  require_literal "$WRAPPER_VALIDATION" "orchestration iteration" \
    "wrapper validation requires orchestration evidence" \
    "wrapper validation must require orchestration evidence"
  require_literal "$CODEX_WRAPPER" "name: closeout-worktree" \
    "Codex host projection exposes closeout-worktree" \
    "Codex host projection must expose closeout-worktree"
}

validate_report() {
  [[ -f "$REPORT_PATH" ]] || { fail "report exists: $REPORT_PATH"; return; }

  local report_json
  if ! report_json="$(yq -o=json '.' "$REPORT_PATH" 2>/dev/null)"; then
    fail "report parses as YAML: $REPORT_PATH"
    return
  fi

  set +e
  REPORT_JSON="$report_json" python3 - <<'PY'
import json
import os
import sys
from pathlib import PurePosixPath

errors = []


def fail(message):
    errors.append(message)


def require(condition, message):
    if not condition:
        fail(message)


def is_nonempty_string(value):
    return isinstance(value, str) and bool(value.strip())


def validate_repo_path(value, field):
    if not is_nonempty_string(value):
        fail(f"{field} must be a non-empty string")
        return
    path = PurePosixPath(value)
    if path.is_absolute() or ".." in path.parts:
        fail(f"{field} must be repo-relative and must not contain parent traversal: {value}")


def path_covers_boundary(evidence_path, boundary_path):
    evidence = PurePosixPath(evidence_path)
    boundary = PurePosixPath(boundary_path)
    return evidence == boundary or evidence in boundary.parents or boundary in evidence.parents


def path_list(value, field, required=True):
    if not isinstance(value, list):
        fail(f"{field} must be a list")
        return []
    if required and not value:
        fail(f"{field} must not be empty")
    for index, item in enumerate(value):
        validate_repo_path(item, f"{field}[{index}]")
    return value


try:
    data = json.loads(os.environ["REPORT_JSON"])
except Exception as exc:
    print(f"[ERROR] report parses as JSON after yq conversion: {exc}")
    sys.exit(1)

if not isinstance(data, dict):
    print("[ERROR] report root must be a mapping")
    sys.exit(1)

require(data.get("schema_version") == "closeout-worktree-report-v1", "schema_version must be closeout-worktree-report-v1")
require(data.get("wrapper_id") == "closeout-worktree", "wrapper_id must be closeout-worktree")
require(data.get("default_work_unit") == "Change", "default_work_unit must remain Change")
require(data.get("read_only_classification") is True, "read_only_classification must be true")
require(data.get("detection_is_deletion_authority") is False, "detection_is_deletion_authority must be false")
require(data.get("direct_material_actions_performed") is False, "direct_material_actions_performed must be false")

for field in ("run_id", "initial_inventory_ref", "residue_classification_ref", "final_inventory_ref", "selected_candidate_id", "next_route_condition"):
    require(is_nonempty_string(data.get(field)), f"{field} must be present")

observed_count = data.get("observed_change_set_count")
require(isinstance(observed_count, int) and observed_count >= 1, "observed_change_set_count must be a positive integer")

candidates = data.get("candidates")
require(isinstance(candidates, list) and candidates, "candidates must be a non-empty list")
if not isinstance(candidates, list):
    candidates = []

if isinstance(observed_count, int) and observed_count > 1:
    require(len(candidates) > 1, "multiple observed change sets must be partitioned into multiple candidates")

candidate_ids = []
selected_id = data.get("selected_candidate_id")
selected = None
all_paths = {}
valid_dispositions = {"selected", "delegated", "closed", "retained", "deferred", "blocked", "escalated", "foreign", "ambiguous"}
delegated_dispositions = {"delegated", "closed"}
retained_residue_dispositions = {"retained", "deferred", "foreign"}
blocker_dispositions = {"blocked", "escalated", "ambiguous"}
unresolved_dispositions = retained_residue_dispositions | blocker_dispositions
unresolved_candidates = []
candidates_by_id = {}
candidate_boundaries = {}

for index, candidate in enumerate(candidates):
    prefix = f"candidates[{index}]"
    if not isinstance(candidate, dict):
        fail(f"{prefix} must be a mapping")
        continue

    candidate_id = candidate.get("candidate_id")
    require(is_nonempty_string(candidate_id), f"{prefix}.candidate_id must be present")
    if is_nonempty_string(candidate_id):
        if candidate_id in candidate_ids:
            fail(f"candidate_id must be unique: {candidate_id}")
        candidate_ids.append(candidate_id)
        candidates_by_id[candidate_id] = candidate
        if candidate_id == selected_id:
            selected = candidate

    disposition = candidate.get("disposition")
    require(disposition in valid_dispositions, f"{prefix}.disposition must be one of {sorted(valid_dispositions)}")
    if disposition in unresolved_dispositions:
        unresolved_candidates.append(candidate)
    require(is_nonempty_string(candidate.get("ownership")), f"{prefix}.ownership must be present")
    require(is_nonempty_string(candidate.get("route_hint")), f"{prefix}.route_hint must be present")
    require(is_nonempty_string(candidate.get("target_lifecycle_outcome")), f"{prefix}.target_lifecycle_outcome must be present")
    require(is_nonempty_string(candidate.get("rollback_or_discard_posture")), f"{prefix}.rollback_or_discard_posture must be present")

    boundaries = candidate.get("boundaries")
    if not isinstance(boundaries, dict):
        fail(f"{prefix}.boundaries must be present")
        include_paths = []
        exclude_paths = []
    else:
        include_paths = path_list(boundaries.get("include_paths"), f"{prefix}.boundaries.include_paths")
        exclude_paths = path_list(boundaries.get("exclude_paths", []), f"{prefix}.boundaries.exclude_paths", required=False)

    if is_nonempty_string(candidate_id):
        candidate_boundaries[candidate_id] = {
            "include_paths": include_paths,
            "exclude_paths": exclude_paths,
        }

    for path in include_paths:
        previous = all_paths.get(path)
        if previous is not None:
            fail(f"path {path} appears in both {previous} and {candidate_id}")
        all_paths[path] = candidate_id

    if disposition in delegated_dispositions:
        ref = candidate.get("closeout_change_ref")
        require(is_nonempty_string(ref) and "closeout-change" in ref, f"{prefix}.closeout_change_ref must reference closeout-change")

require(selected is not None, "selected_candidate_id must match a candidate")

retained_by_candidate = {}
if isinstance(data.get("retained_residue"), list):
    for index, item in enumerate(data["retained_residue"]):
        if isinstance(item, dict):
            candidate_id = item.get("candidate_id")
            require(is_nonempty_string(candidate_id), f"retained_residue[{index}].candidate_id must be present")
            validate_repo_path(item.get("path"), f"retained_residue[{index}].path")
            require(is_nonempty_string(item.get("disposition")), f"retained_residue[{index}].disposition must be present")
            if is_nonempty_string(candidate_id):
                retained_by_candidate.setdefault(candidate_id, []).append(item)
        else:
            fail(f"retained_residue[{index}] must be a mapping")
else:
    fail("retained_residue must be a list")

blockers_by_candidate = {}
if isinstance(data.get("blockers"), list):
    for index, item in enumerate(data["blockers"]):
        if isinstance(item, dict):
            candidate_id = item.get("candidate_id")
            require(is_nonempty_string(candidate_id), f"blockers[{index}].candidate_id must be present")
            require(
                is_nonempty_string(item.get("blocker")) or is_nonempty_string(item.get("reason")),
                f"blockers[{index}] must include blocker or reason text",
            )
            if is_nonempty_string(candidate_id):
                blockers_by_candidate.setdefault(candidate_id, []).append(item)
        else:
            fail(f"blockers[{index}] must be a mapping")
else:
    fail("blockers must be a list")

if unresolved_candidates:
    terminal_next_route_values = {"none", "no-op", "noop", "n/a", "na", "closed", "complete", "completed", "done", "terminal"}
    next_route = data.get("next_route_condition")
    if is_nonempty_string(next_route) and next_route.strip().lower() in terminal_next_route_values:
        fail("next_route_condition must not be terminal when unresolved candidates remain")

for candidate in unresolved_candidates:
    candidate_id = candidate.get("candidate_id")
    disposition = candidate.get("disposition")
    prefix = f"candidate {candidate_id}"
    include_paths = []
    boundaries = candidate.get("boundaries")
    if isinstance(boundaries, dict) and isinstance(boundaries.get("include_paths"), list):
        include_paths = boundaries.get("include_paths")

    if disposition in retained_residue_dispositions:
        evidence_items = retained_by_candidate.get(candidate_id, [])
        if not evidence_items:
            fail(f"{prefix} with disposition {disposition} must have retained_residue evidence")
        else:
            for include_path in include_paths:
                if not any(path_covers_boundary(item.get("path"), include_path) for item in evidence_items if is_nonempty_string(item.get("path"))):
                    fail(f"{prefix} retained_residue evidence must cover boundary path {include_path}")

    if disposition in blocker_dispositions:
        if not blockers_by_candidate.get(candidate_id):
            fail(f"{prefix} with disposition {disposition} must have blocker evidence")

final_states = {}
final_dispositions = data.get("final_candidate_dispositions")
if not isinstance(final_dispositions, dict):
    fail("final_candidate_dispositions must be a mapping keyed by candidate_id")
else:
    valid_final_states = {"closed", "retained", "blocked", "escalated", "deferred", "foreign"}
    final_ids = set(final_dispositions.keys())
    candidate_id_set = set(candidate_ids)
    for candidate_id in sorted(candidate_id_set - final_ids):
        fail(f"final_candidate_dispositions must include candidate {candidate_id}")
    for candidate_id in sorted(final_ids - candidate_id_set):
        fail(f"final_candidate_dispositions includes unknown candidate {candidate_id}")

    for candidate_id, item in final_dispositions.items():
        prefix = f"final_candidate_dispositions.{candidate_id}"
        if not isinstance(item, dict):
            fail(f"{prefix} must be a mapping")
            continue

        state = item.get("state")
        require(state in valid_final_states, f"{prefix}.state must be one of {sorted(valid_final_states)}")
        if state in valid_final_states:
            final_states[candidate_id] = state

        if state == "closed":
            ref = item.get("closeout_change_ref")
            require(is_nonempty_string(ref) and "closeout-change" in ref, f"{prefix}.closeout_change_ref must cite closeout-change")
        elif state in retained_residue_dispositions:
            if not retained_by_candidate.get(candidate_id):
                fail(f"{prefix} with state {state} must have retained_residue evidence")
        elif state in {"blocked", "escalated"}:
            if not blockers_by_candidate.get(candidate_id):
                fail(f"{prefix} with state {state} must have blocker evidence")

iterations = data.get("iterations")
if not isinstance(iterations, list):
    fail("iterations must be a list")
    iterations = []

iteration_ids = set()
iterations_by_candidate = {}
for index, iteration in enumerate(iterations):
    prefix = f"iterations[{index}]"
    if not isinstance(iteration, dict):
        fail(f"{prefix} must be a mapping")
        continue

    iteration_id = iteration.get("iteration_id")
    require(is_nonempty_string(iteration_id), f"{prefix}.iteration_id must be present")
    if is_nonempty_string(iteration_id):
        if iteration_id in iteration_ids:
            fail(f"iteration_id must be unique: {iteration_id}")
        iteration_ids.add(iteration_id)

    for field in (
        "pre_inventory_ref",
        "pre_classification_ref",
        "selected_candidate_id",
        "closeout_change_ref",
        "closeout_change_outcome",
        "post_inventory_ref",
        "post_classification_ref",
        "next_selection_reason",
    ):
        require(is_nonempty_string(iteration.get(field)), f"{prefix}.{field} must be present")

    iteration_candidate_id = iteration.get("selected_candidate_id")
    if is_nonempty_string(iteration_candidate_id):
        require(iteration_candidate_id in candidate_ids, f"{prefix}.selected_candidate_id must match a candidate")
        iterations_by_candidate.setdefault(iteration_candidate_id, []).append(iteration)

    ref = iteration.get("closeout_change_ref")
    require(is_nonempty_string(ref) and "closeout-change" in ref, f"{prefix}.closeout_change_ref must cite closeout-change")

    include_paths = path_list(iteration.get("include_paths"), f"{prefix}.include_paths")
    path_list(iteration.get("exclude_paths", []), f"{prefix}.exclude_paths", required=False)
    if is_nonempty_string(iteration_candidate_id) and iteration_candidate_id in candidate_boundaries:
        candidate_include_paths = set(candidate_boundaries[iteration_candidate_id]["include_paths"])
        for include_path in include_paths:
            if include_path not in candidate_include_paths:
                fail(f"{prefix}.include_paths includes path outside selected candidate boundaries: {include_path}")

requires_iteration = set()
for candidate in candidates:
    candidate_id = candidate.get("candidate_id")
    if candidate.get("disposition") in delegated_dispositions and is_nonempty_string(candidate_id):
        requires_iteration.add(candidate_id)
for candidate_id, state in final_states.items():
    if state == "closed":
        requires_iteration.add(candidate_id)

if requires_iteration and not iterations:
    fail("iterations must not be empty when any candidate is delegated or closed")

for candidate_id in sorted(requires_iteration):
    if not iterations_by_candidate.get(candidate_id):
        fail(f"candidate {candidate_id} delegated or closed must have orchestration iteration evidence")

if isinstance(final_dispositions, dict):
    for candidate_id, state in final_states.items():
        if state == "closed":
            final_ref = final_dispositions[candidate_id].get("closeout_change_ref")
            iteration_refs = {
                iteration.get("closeout_change_ref")
                for iteration in iterations_by_candidate.get(candidate_id, [])
                if is_nonempty_string(iteration.get("closeout_change_ref"))
            }
            if is_nonempty_string(final_ref) and final_ref not in iteration_refs:
                fail(f"final_candidate_dispositions.{candidate_id}.closeout_change_ref must match an iteration closeout_change_ref")

selected_final_state = final_states.get(selected_id)
selected_candidate_disposition = selected.get("disposition") if isinstance(selected, dict) else None
if selected_candidate_disposition in {"blocked", "escalated", "ambiguous"} or selected_final_state in {"blocked", "escalated"}:
    for item in blockers_by_candidate.get(selected_id, []):
        blocker_text = " ".join(
            str(item.get(field, ""))
            for field in ("blocker", "reason")
            if item.get(field) is not None
        ).strip().lower()
        partition_only_markers = (
            "multiple candidates exist",
            "multiple candidates alone",
            "more than one candidate exists",
            "other candidates exist",
            "because other candidates exist",
            "because multiple candidates exist",
            "operator confirmation of first singular closeout-change scope",
        )
        if any(marker in blocker_text for marker in partition_only_markers):
            fail("selected candidate must not be blocked only because other candidates exist; delegate safely separable candidates or record a candidate-specific blocker")

non_closed_final_states = [
    candidate_id for candidate_id, state in final_states.items() if state != "closed"
]
if non_closed_final_states:
    terminal_next_route_values = {"none", "no-op", "noop", "n/a", "na", "closed", "complete", "completed", "done", "terminal"}
    next_route = data.get("next_route_condition")
    if is_nonempty_string(next_route) and next_route.strip().lower() in terminal_next_route_values:
        fail("next_route_condition must not be terminal unless every candidate is closed")

if errors:
    for message in errors:
        print(f"[ERROR] {message}")
    sys.exit(1)

print("[OK] closeout-worktree report validates")
PY
  local status=$?
  set -e
  if [[ "$status" -eq 0 ]]; then
    pass "report evidence contract passed"
  else
    fail "report evidence contract failed"
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --report)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      REPORT_PATH="$1"
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

if [[ -n "$REPORT_PATH" && "$REPORT_PATH" != /* ]]; then
  REPORT_PATH="$ROOT_DIR/$REPORT_PATH"
fi

command -v yq >/dev/null 2>&1 || { echo "[ERROR] yq is required" >&2; exit 1; }

echo "== Closeout Worktree Wrapper Validation =="
validate_static
[[ -z "$REPORT_PATH" ]] || validate_report

echo
echo "Validation summary: errors=$errors"
[[ "$errors" -eq 0 ]]
