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
  require_literal "$WRAPPER_IO" "omitted means \`cleaned\`" \
    "I/O contract documents cleaned default target" \
    "I/O contract must document cleaned default target"
  require_literal "$WRAPPER_VALIDATION" "selected candidate has explicit include and exclude path boundaries" \
    "wrapper validation requires explicit boundaries" \
    "wrapper validation must require explicit boundaries"
  require_literal "$WRAPPER_VALIDATION" "orchestration iteration" \
    "wrapper validation requires orchestration evidence" \
    "wrapper validation must require orchestration evidence"
  require_literal "$WRAPPER_VALIDATION" "and the receipt records" \
    "wrapper validation requires completed closeout-change receipts for closed candidates" \
    "wrapper validation must require completed closeout-change receipts for closed candidates"
  require_literal "$WRAPPER_VALIDATION" "continued handoff receipt as \`closed\` fails" \
    "wrapper validation rejects continued handoff receipts as closed candidates" \
    "wrapper validation must reject continued handoff receipts as closed candidates"
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
  REPORT_JSON="$report_json" ROOT_DIR="$ROOT_DIR" CLOSEOUT_WORKTREE_EVIDENCE_ROOT="${CLOSEOUT_WORKTREE_EVIDENCE_ROOT:-$ROOT_DIR}" python3 - <<'PY'
import json
import os
import subprocess
import sys
from pathlib import Path
from pathlib import PurePosixPath

errors = []
ROOT_DIR = Path(os.environ["ROOT_DIR"]).resolve()
EVIDENCE_ROOT = Path(os.environ.get("CLOSEOUT_WORKTREE_EVIDENCE_ROOT", str(ROOT_DIR))).resolve()
CLOSEOUT_CHANGE_ROOT = (EVIDENCE_ROOT / ".octon/state/evidence/runs/skills/closeout-change").resolve()


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


def repo_path(value, field):
    validate_repo_path(value, field)
    if not is_nonempty_string(value):
        return None
    path = PurePosixPath(value)
    if path.is_absolute() or ".." in path.parts:
        return None
    return ROOT_DIR / Path(*path.parts)


def ref_to_repo_path(ref, field):
    if not is_nonempty_string(ref):
        fail(f"{field} must be a non-empty evidence ref")
        return None

    if ref.startswith("evidence://runs/skills/closeout-change/"):
        suffix = ref.removeprefix("evidence://runs/skills/closeout-change/")
        if not suffix:
            fail(f"{field} must include a closeout-change evidence path suffix")
            return None
        value = f".octon/state/evidence/runs/skills/closeout-change/{suffix}"
    elif ref.startswith(".octon/state/evidence/runs/skills/closeout-change/"):
        value = ref
    else:
        fail(f"{field} must cite retained closeout-change evidence under .octon/state/evidence/runs/skills/closeout-change/")
        return None

    validate_repo_path(value, field)
    path = PurePosixPath(value)
    if path.is_absolute() or ".." in path.parts:
        return None
    return EVIDENCE_ROOT / Path(*path.parts)


def require_closeout_change_evidence(ref, field):
    path = ref_to_repo_path(ref, field)
    if path is None:
        return None
    resolved = path.resolve()
    try:
        resolved.relative_to(CLOSEOUT_CHANGE_ROOT)
    except ValueError:
        fail(f"{field} must stay under .octon/state/evidence/runs/skills/closeout-change/: {ref}")
        return None
    if not resolved.is_file():
        fail(f"{field} must resolve to a retained closeout-change evidence file: {ref}")
        return None
    return resolved


def load_closeout_change_receipt(ref, field, require_receipt=False):
    resolved = require_closeout_change_evidence(ref, field)
    if resolved is None:
        return None
    if resolved.suffix != ".json":
        if require_receipt:
            fail(f"{field} must resolve to a closeout-change receipt JSON when reporting closed/full closeout: {ref}")
        return None
    try:
        loaded = json.loads(resolved.read_text())
    except Exception as exc:
        fail(f"{field} must be parseable closeout-change receipt JSON: {exc}")
        return None
    if not isinstance(loaded, dict):
        fail(f"{field} closeout-change receipt must be a JSON object")
        return None
    return loaded


def resolve_receipt_ref(ref, field):
    if not is_nonempty_string(ref):
        fail(f"{field} must be a non-empty evidence ref")
        return None
    if ref.startswith("evidence://"):
        value = f".octon/state/evidence/{ref.removeprefix('evidence://')}"
        validate_repo_path(value, field)
        path = PurePosixPath(value)
        if path.is_absolute() or ".." in path.parts:
            return None
        return EVIDENCE_ROOT / Path(*path.parts)
    if ref.startswith("/"):
        return Path(ref)
    validate_repo_path(ref, field)
    path = PurePosixPath(ref)
    if path.is_absolute() or ".." in path.parts:
        return None
    return EVIDENCE_ROOT / Path(*path.parts)


def validate_cleanup_authorization(receipt, field):
    auth_ref = receipt.get("cleanup_authorization_ref")
    if not is_nonempty_string(auth_ref):
        fail(f"{field} completed source branch cleanup requires cleanup_authorization_ref")
        return False
    auth_path = resolve_receipt_ref(auth_ref, f"{field}.cleanup_authorization_ref")
    if auth_path is None:
        return False
    if not auth_path.is_file():
        fail(f"{field}.cleanup_authorization_ref must resolve to an existing cleanup authorization receipt")
        return False
    try:
        auth = json.loads(auth_path.read_text())
    except Exception as exc:
        fail(f"{field}.cleanup_authorization_ref must parse as JSON: {exc}")
        return False
    if not isinstance(auth, dict):
        fail(f"{field}.cleanup_authorization_ref must be a JSON object")
        return False

    main_alignment = receipt.get("main_alignment") if isinstance(receipt.get("main_alignment"), dict) else {}
    expected = {
        "schema_version": "branch-cleanup-authorization-v1",
        "authorization_result": "approved",
        "selected_route": receipt.get("selected_route"),
        "target_lifecycle_outcome": "cleaned",
        "source_branch": receipt.get("source_branch_ref"),
        "landed_ref": receipt.get("landed_ref"),
        "origin_main_ref": main_alignment.get("origin_main_ref"),
        "local_main_ref": main_alignment.get("local_main_ref"),
        "local_main_synced_to_origin_main": True,
        "origin_main_contains_landed_ref": True,
        "local_main_contains_landed_ref": True,
        "source_branch_contained_in_origin_main": True,
        "source_branch_protected": False,
        "open_pr_count": 0,
        "cleanup_policy_allowed": True,
        "host_controls_not_bypassed": True,
    }
    for key, expected_value in expected.items():
        if auth.get(key) != expected_value:
            fail(f"{field}.cleanup_authorization_ref {key} must match completed branch cleanup evidence")
            return False
    return True


def receipt_has_completed_full_closeout(ref, field):
    receipt = load_closeout_change_receipt(ref, field, require_receipt=True)
    if not isinstance(receipt, dict):
        return False

    if receipt.get("closeout_outcome") != "completed":
        fail(f"{field} receipt closeout_outcome must be completed for a closed candidate")
        return False

    route = receipt.get("selected_route")
    lifecycle = receipt.get("lifecycle_outcome")
    integration = receipt.get("integration_status")
    landed_ref = receipt.get("landed_ref")
    main_alignment = receipt.get("main_alignment") if isinstance(receipt.get("main_alignment"), dict) else {}

    if route in {"branch-no-pr", "branch-pr"}:
        if lifecycle not in {"landed", "cleaned"}:
            fail(f"{field} branch receipt must have landed or cleaned lifecycle_outcome for closed candidate")
            return False
        if integration != "landed":
            fail(f"{field} branch receipt must have integration_status landed for closed candidate")
            return False

        source_integration = receipt.get("source_branch_integration")
        if not isinstance(source_integration, dict):
            fail(f"{field} branch receipt must include source_branch_integration for closed candidate")
            return False
        if source_integration.get("integrated") is not True:
            fail(f"{field} source_branch_integration.integrated must be true")
            return False
        if not isinstance(source_integration.get("evidence_refs"), list) or not source_integration.get("evidence_refs"):
            fail(f"{field} source_branch_integration.evidence_refs must be non-empty")
            return False
        if source_integration.get("source_branch_ref") != receipt.get("source_branch_ref"):
            fail(f"{field} source_branch_integration.source_branch_ref must equal source_branch_ref")
            return False
        if source_integration.get("landed_ref") != landed_ref:
            fail(f"{field} source_branch_integration.landed_ref must equal landed_ref")
            return False

        required_alignment = {
            "local_main_ref": landed_ref,
            "origin_main_ref": landed_ref,
            "landed_ref": landed_ref,
            "aligned": True,
            "origin_main_contains_landed_ref": True,
            "local_main_contains_landed_ref": True,
        }
        for key, expected in required_alignment.items():
            if main_alignment.get(key) != expected:
                fail(f"{field} main_alignment.{key} must prove local main, origin/main, and landed_ref alignment")
                return False
        for key in ("origin_fetch_evidence_ref", "local_main_sync_evidence_ref"):
            if not is_nonempty_string(main_alignment.get(key)):
                fail(f"{field} main_alignment.{key} must be present for branch full closeout")
                return False

        cleanup_status = receipt.get("cleanup_status")
        if cleanup_status not in {"completed", "deferred"}:
            fail(f"{field} branch full closeout cleanup_status must be completed or deferred")
            return False
        source_cleanup = receipt.get("source_branch_cleanup")
        if not isinstance(source_cleanup, dict):
            fail(f"{field} branch full closeout must include source_branch_cleanup")
            return False
        if source_cleanup.get("status") == "deferred":
            has_cleanup_evidence = (
                is_nonempty_string(source_cleanup.get("blocker_reason"))
                and (
                    isinstance(source_cleanup.get("evidence_refs"), list)
                    and bool(source_cleanup.get("evidence_refs"))
                    or isinstance(receipt.get("cleanup_evidence_refs"), list)
                    and bool(receipt.get("cleanup_evidence_refs"))
                    or isinstance(receipt.get("external_blocker_refs"), list)
                    and bool(receipt.get("external_blocker_refs"))
                )
            )
            if not has_cleanup_evidence:
                fail(f"{field} deferred source branch cleanup requires blocker evidence")
                return False
        if source_cleanup.get("status") == "completed" and not validate_cleanup_authorization(receipt, field):
            return False

    return True


def receipt_is_nonterminal_handoff(ref, field):
    receipt = load_closeout_change_receipt(ref, field, require_receipt=True)
    if not isinstance(receipt, dict):
        return False
    return receipt.get("closeout_outcome") in {"continued", "stage_only", "blocked", "escalated", "denied"}


def load_yaml_as_json(path, field):
    try:
        completed = subprocess.run(
            ["yq", "-o=json", ".", str(path)],
            check=True,
            text=True,
            capture_output=True,
        )
        loaded = json.loads(completed.stdout)
        if not isinstance(loaded, dict):
            fail(f"{field} must parse to a mapping")
            return {}
        return loaded
    except Exception as exc:
        fail(f"{field} must be a parseable YAML report: {exc}")
        return {}


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
retained_residue_dispositions = {"retained", "foreign"}
deferred_dispositions = {"deferred"}
blocker_dispositions = {"blocked", "escalated", "ambiguous"}
unresolved_dispositions = retained_residue_dispositions | deferred_dispositions | blocker_dispositions
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
        if is_nonempty_string(ref):
            require_closeout_change_evidence(ref, f"{prefix}.closeout_change_ref")

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
    if disposition in deferred_dispositions:
        ref = candidate.get("closeout_change_ref")
        if retained_by_candidate.get(candidate_id) or blockers_by_candidate.get(candidate_id):
            pass
        elif is_nonempty_string(ref):
            if not receipt_is_nonterminal_handoff(ref, f"{prefix}.closeout_change_ref"):
                fail(f"{prefix}.closeout_change_ref must record a non-terminal closeout-change outcome for deferred disposition")
        else:
            fail(f"{prefix} with disposition deferred must have retained_residue, blocker evidence, or a non-terminal closeout-change receipt")

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
            if is_nonempty_string(ref):
                receipt_has_completed_full_closeout(ref, f"{prefix}.closeout_change_ref")
        elif state in retained_residue_dispositions:
            if not retained_by_candidate.get(candidate_id):
                fail(f"{prefix} with state {state} must have retained_residue evidence")
        elif state == "deferred":
            ref = item.get("closeout_change_ref")
            if retained_by_candidate.get(candidate_id) or blockers_by_candidate.get(candidate_id):
                pass
            elif is_nonempty_string(ref):
                if not receipt_is_nonterminal_handoff(ref, f"{prefix}.closeout_change_ref"):
                    fail(f"{prefix}.closeout_change_ref must record a non-terminal closeout-change outcome for deferred state")
            else:
                fail(f"{prefix} with state deferred must have retained_residue, blocker evidence, or a non-terminal closeout-change receipt")
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
    if is_nonempty_string(ref):
        require_closeout_change_evidence(ref, f"{prefix}.closeout_change_ref")
        if iteration.get("closeout_change_outcome") == "closed":
            receipt_has_completed_full_closeout(ref, f"{prefix}.closeout_change_ref")

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

final_residue_classes = data.get("final_residue_classes")
ignored_count = 0
if not isinstance(final_residue_classes, dict):
    fail("final_residue_classes must be a mapping with an ignored count")
else:
    ignored_count = final_residue_classes.get("ignored")
    if not isinstance(ignored_count, int) or ignored_count < 0:
        fail("final_residue_classes.ignored must be a non-negative integer")

if isinstance(ignored_count, int) and ignored_count > 0:
    ignored_coverage = False
    for item in data.get("retained_residue", []):
        if not isinstance(item, dict):
            continue
        candidate_id = item.get("candidate_id")
        candidate = candidates_by_id.get(candidate_id)
        final_state = final_states.get(candidate_id)
        candidate_disposition = candidate.get("disposition") if isinstance(candidate, dict) else None
        if candidate_disposition not in {"foreign", "retained"} and final_state not in {"foreign", "retained"}:
            continue
        evidence_text = " ".join(
            str(value)
            for value in (
                candidate_id,
                candidate.get("ownership") if isinstance(candidate, dict) else "",
                item.get("path"),
                item.get("disposition"),
            )
            if value is not None
        ).lower()
        if "ignored" in evidence_text or "local" in evidence_text:
            ignored_coverage = True
            break
    if not ignored_coverage:
        fail("final_residue_classes.ignored > 0 requires foreign or retained candidate-keyed ignored/local residue evidence")

prior_reconciliation = data.get("prior_candidate_reconciliation")
if prior_reconciliation is not None:
    if not isinstance(prior_reconciliation, dict):
        fail("prior_candidate_reconciliation must be a mapping")
    else:
        prior_report_ref = prior_reconciliation.get("prior_report_ref")
        prior_report_path = repo_path(prior_report_ref, "prior_candidate_reconciliation.prior_report_ref")
        prior_candidate_ids = set()
        if prior_report_path is not None:
            if not prior_report_path.is_file():
                fail(f"prior_candidate_reconciliation.prior_report_ref must resolve to an existing report: {prior_report_ref}")
            else:
                prior_report = load_yaml_as_json(prior_report_path, "prior_candidate_reconciliation.prior_report_ref")
                prior_candidates = prior_report.get("candidates")
                if isinstance(prior_candidates, list):
                    for index, prior_candidate in enumerate(prior_candidates):
                        if isinstance(prior_candidate, dict) and is_nonempty_string(prior_candidate.get("candidate_id")):
                            prior_candidate_ids.add(prior_candidate["candidate_id"])
                        else:
                            fail(f"prior report candidates[{index}].candidate_id must be present")
                else:
                    fail("prior report candidates must be a list")

        reconciliation_items = prior_reconciliation.get("candidates")
        if not isinstance(reconciliation_items, list):
            fail("prior_candidate_reconciliation.candidates must be a list")
            reconciliation_items = []

        reconciled_ids = set()
        valid_reconciliation = {"folded", "retained", "blocked", "escalated", "deferred", "foreign"}
        for index, item in enumerate(reconciliation_items):
            prefix = f"prior_candidate_reconciliation.candidates[{index}]"
            if not isinstance(item, dict):
                fail(f"{prefix} must be a mapping")
                continue
            prior_candidate_id = item.get("prior_candidate_id")
            current_candidate_id = item.get("current_candidate_id")
            disposition = item.get("disposition")
            require(is_nonempty_string(prior_candidate_id), f"{prefix}.prior_candidate_id must be present")
            require(disposition in valid_reconciliation, f"{prefix}.disposition must be one of {sorted(valid_reconciliation)}")
            require(is_nonempty_string(current_candidate_id), f"{prefix}.current_candidate_id must be present")
            if is_nonempty_string(current_candidate_id):
                require(current_candidate_id in candidate_ids, f"{prefix}.current_candidate_id must match a current candidate")
            require(is_nonempty_string(item.get("rationale")), f"{prefix}.rationale must be present")
            if is_nonempty_string(prior_candidate_id):
                reconciled_ids.add(prior_candidate_id)
                if prior_candidate_ids and prior_candidate_id not in prior_candidate_ids:
                    fail(f"{prefix}.prior_candidate_id is not present in prior report: {prior_candidate_id}")

        for prior_candidate_id in sorted(prior_candidate_ids):
            if prior_candidate_id not in candidate_ids and prior_candidate_id not in reconciled_ids:
                fail(f"prior candidate {prior_candidate_id} must remain present or be explicitly reconciled")

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
