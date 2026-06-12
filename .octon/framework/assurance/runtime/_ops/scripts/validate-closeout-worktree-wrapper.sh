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
  require_literal "$WRAPPER" "repo_hygiene_cleanup_actions_performed: false" \
    "wrapper records that repo-hygiene cleanup actions are not performed by the wrapper" \
    "wrapper must record repo_hygiene_cleanup_actions_performed: false"
  require_literal "$WRAPPER" "repo_hygiene_next_route_condition" \
    "wrapper documents repo-hygiene next route condition" \
    "wrapper must document repo_hygiene_next_route_condition"
  require_literal "$WRAPPER" "repo_hygiene_cleanup_ref" \
    "wrapper documents delegated repo-hygiene cleanup evidence" \
    "wrapper must document repo_hygiene_cleanup_ref"
  require_literal "$WRAPPER" "worktree_terminal_state" \
    "wrapper documents worktree terminal state" \
    "wrapper must document worktree_terminal_state"
  require_literal "$WRAPPER" "terminal_current_state_proof_ref" \
    "wrapper documents delegated terminal current-state proof refs" \
    "wrapper must document terminal_current_state_proof_ref"
  require_literal "$WRAPPER" "correction_branch_aggregate_receipt_ref" \
    "wrapper documents delegated correction aggregate refs" \
    "wrapper must document correction_branch_aggregate_receipt_ref"
  require_literal "$WRAPPER" "residue_routing_class" \
    "wrapper documents residue routing classes" \
    "wrapper must document residue_routing_class"
  require_literal "$WRAPPER" "partition autonomously" \
    "wrapper documents autonomous unambiguous partitioning" \
    "wrapper must document autonomous unambiguous partitioning"
  require_literal "$WRAPPER" "stale detached Git worktrees" \
    "wrapper documents detached worktree cleanup safety routing" \
    "wrapper must document detached worktree cleanup safety routing"
  require_literal "$CLOSEOUT_CHANGE" '`cleaned` is route-bound' \
    "closeout-change limits cleaned to route-bound cleanup evidence" \
    "closeout-change must limit cleaned to route-bound cleanup evidence"
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
  require_literal "$WRAPPER_IO" "git_clean_terminal" \
    "I/O contract documents Git-clean terminal state" \
    "I/O contract must document git_clean_terminal"
  require_literal "$WRAPPER_IO" "residue_routing_class" \
    "I/O contract documents residue routing classes" \
    "I/O contract must document residue_routing_class"
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
  require_literal "$WRAPPER_VALIDATION" "repo_hygiene_cleanup_actions_performed: true" \
    "wrapper validation rejects direct repo-hygiene cleanup action claims" \
    "wrapper validation must reject direct repo-hygiene cleanup action claims"
  require_literal "$WRAPPER_VALIDATION" "worktree_terminal_state" \
    "wrapper validation documents terminal state checks" \
    "wrapper validation must document worktree_terminal_state checks"
  require_literal "$WRAPPER_VALIDATION" "residue_routing_class" \
    "wrapper validation documents residue routing-class checks" \
    "wrapper validation must document residue_routing_class checks"
  require_literal "$CODEX_WRAPPER" "residue_routing_class" \
    "Codex host projection documents residue routing classes" \
    "Codex host projection must document residue_routing_class"
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
REPO_HYGIENE_CLEANUP_ROOT = (EVIDENCE_ROOT / ".octon/state/evidence/runs/skills/repo-hygiene-cleanup").resolve()


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


def validate_branch_pr_predicate_evidence(receipt, field):
    predicate = receipt.get("branch_pr_predicate")
    evidence = receipt.get("branch_pr_predicate_evidence")
    if not is_nonempty_string(predicate):
        fail(f"{field} branch-pr receipt requires branch_pr_predicate")
        return False
    if not isinstance(evidence, dict):
        fail(f"{field} branch-pr receipt requires branch_pr_predicate_evidence")
        return False
    if evidence.get("predicate") != predicate:
        fail(f"{field} branch_pr_predicate_evidence.predicate must match branch_pr_predicate")
        return False
    for key in ("requirement_ref", "branch_no_pr_rejection_reason"):
        if not is_nonempty_string(evidence.get(key)):
            fail(f"{field} branch_pr_predicate_evidence.{key} must be non-empty")
            return False
    if not isinstance(evidence.get("evidence_refs"), list) or not evidence.get("evidence_refs"):
        fail(f"{field} branch_pr_predicate_evidence.evidence_refs must be non-empty")
        return False
    evidence_blob = "\n".join(
        str(value)
        for value in [
            evidence.get("requirement_ref"),
            evidence.get("branch_no_pr_rejection_reason"),
            evidence.get("operator_request_ref"),
            evidence.get("provider_ruleset_ref"),
            evidence.get("existing_pr_or_review_ref"),
            evidence.get("scope_classification_ref"),
            evidence.get("governing_review_requirement_ref"),
            *evidence.get("evidence_refs", []),
        ]
        if isinstance(value, str)
    ).lower()
    if any(term in evidence_blob for term in ("branch isolation", "high-impact alone", "protected surface alone", "provider caution")):
        fail(f"{field} branch_pr_predicate_evidence cannot rely on branch isolation, high-impact/protected-surface scope, or provider caution alone")
        return False
    requirement_ref = str(evidence.get("requirement_ref", "")).lower()
    if (
        ("block" in requirement_ref)
        and any(term in requirement_ref for term in ("gh013", "required checks", "direct push", "hosted no-pr", "branch-no-pr"))
    ):
        fail(f"{field} branch_pr_predicate_evidence.requirement_ref cannot be blocked landing evidence")
        return False
    if predicate == "explicit-operator-pr-request" and not is_nonempty_string(evidence.get("operator_request_ref")):
        fail(f"{field} explicit operator PR predicate requires operator_request_ref")
        return False
    if predicate == "existing-pr-context" and not is_nonempty_string(evidence.get("existing_pr_or_review_ref")):
        fail(f"{field} existing PR context predicate requires existing_pr_or_review_ref")
        return False
    if predicate == "provider-ruleset-requires-pr-for-requested-pr-backed-landing" and not is_nonempty_string(evidence.get("provider_ruleset_ref")):
        fail(f"{field} provider PR predicate requires provider_ruleset_ref")
        return False
    if predicate == "protected-or-high-impact-remote-review-required":
        if not is_nonempty_string(evidence.get("scope_classification_ref")):
            fail(f"{field} protected/high-impact PR predicate requires scope_classification_ref")
            return False
        if not is_nonempty_string(evidence.get("governing_review_requirement_ref")):
            fail(f"{field} protected/high-impact PR predicate requires governing_review_requirement_ref")
            return False
    return True


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


def resolve_repo_hygiene_cleanup_ref(ref, field):
    if not is_nonempty_string(ref):
        fail(f"{field} must be a non-empty evidence ref")
        return None
    if ref.startswith("evidence://runs/skills/repo-hygiene-cleanup/"):
        suffix = ref.removeprefix("evidence://runs/skills/repo-hygiene-cleanup/")
        if not suffix:
            fail(f"{field} must include a repo-hygiene-cleanup evidence path suffix")
            return None
        value = f".octon/state/evidence/runs/skills/repo-hygiene-cleanup/{suffix}"
    elif ref.startswith(".octon/state/evidence/runs/skills/repo-hygiene-cleanup/"):
        value = ref
    else:
        fail(f"{field} must cite delegated repo-hygiene-cleanup evidence under .octon/state/evidence/runs/skills/repo-hygiene-cleanup/")
        return None

    validate_repo_path(value, field)
    path = PurePosixPath(value)
    if path.is_absolute() or ".." in path.parts:
        return None
    resolved = (EVIDENCE_ROOT / Path(*path.parts)).resolve()
    try:
        resolved.relative_to(REPO_HYGIENE_CLEANUP_ROOT)
    except ValueError:
        fail(f"{field} must stay under .octon/state/evidence/runs/skills/repo-hygiene-cleanup/: {ref}")
        return None
    if not resolved.exists():
        fail(f"{field} must resolve to delegated repo-hygiene-cleanup evidence: {ref}")
        return None
    return resolved


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


def validate_main_alignment(receipt, field):
    landed_ref = receipt.get("landed_ref")
    main_alignment = receipt.get("main_alignment") if isinstance(receipt.get("main_alignment"), dict) else {}
    if not is_nonempty_string(landed_ref):
        fail(f"{field} full closeout requires landed_ref")
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
            fail(f"{field} main_alignment.{key} must be present for full closeout")
            return False
    return True


def validate_exact_sha_check_refs(required_check_refs, source_ref, field):
    if not isinstance(required_check_refs, list) or not required_check_refs:
        fail(f"{field}.required_check_refs must be a non-empty list of exact source-SHA check refs")
        return False
    if not is_nonempty_string(source_ref):
        fail(f"{field}.source_ref must be present before validating exact source-SHA check refs")
        return False
    for index, ref in enumerate(required_check_refs):
        if not is_nonempty_string(ref):
            fail(f"{field}.required_check_refs[{index}] must be a non-empty string")
            return False
        if source_ref not in ref:
            fail(f"{field}.required_check_refs[{index}] must bind to hosted_landing.source_ref")
            return False
    return True


def validate_branch_no_pr_landing_authorization(receipt, field):
    auth_ref = receipt.get("landing_authorization_ref")
    if not is_nonempty_string(auth_ref):
        fail(f"{field} branch-no-pr landed/cleaned receipt requires landing_authorization_ref")
        return False
    auth_path = resolve_receipt_ref(auth_ref, f"{field}.landing_authorization_ref")
    if auth_path is None:
        return False
    if not auth_path.is_file():
        fail(f"{field}.landing_authorization_ref must resolve to an existing branch landing authorization receipt")
        return False
    try:
        auth = json.loads(auth_path.read_text())
    except Exception as exc:
        fail(f"{field}.landing_authorization_ref must parse as JSON: {exc}")
        return False
    if not isinstance(auth, dict):
        fail(f"{field}.landing_authorization_ref must be a JSON object")
        return False

    hosted = receipt.get("hosted_landing")
    if not isinstance(hosted, dict):
        fail(f"{field} branch-no-pr landed/cleaned receipt requires hosted_landing evidence")
        return False

    expected = {
        "schema_version": "branch-landing-authorization-v1",
        "authorization_result": "approved",
        "selected_route": "branch-no-pr",
        "remote": hosted.get("remote"),
        "target_branch": hosted.get("target_branch"),
        "source_branch": receipt.get("source_branch_ref"),
        "source_ref": hosted.get("source_ref"),
        "remote_source_ref": hosted.get("source_ref"),
        "target_pre_ref": hosted.get("target_pre_ref"),
        "provider_ruleset_ref": hosted.get("provider_ruleset_ref"),
        "no_pr_required": True,
        "preflight_status": "passed",
        "host_controls_not_bypassed": True,
    }
    for key, expected_value in expected.items():
        if auth.get(key) != expected_value:
            fail(f"{field}.landing_authorization_ref {key} must match hosted branch-no-pr landing evidence")
            return False

    if auth.get("target_lifecycle_outcome") not in {"landed", "cleaned"}:
        fail(f"{field}.landing_authorization_ref target_lifecycle_outcome must be landed or cleaned")
        return False
    if not is_nonempty_string(auth.get("rollback_handle")):
        fail(f"{field}.landing_authorization_ref must include rollback_handle")
        return False
    if not is_nonempty_string(auth.get("runtime_safety_boundary")):
        fail(f"{field}.landing_authorization_ref must include runtime_safety_boundary")
        return False

    hosted_required_checks = hosted.get("required_check_refs")
    auth_required_checks = auth.get("required_check_refs")
    if sorted(auth_required_checks or []) != sorted(hosted_required_checks or []):
        fail(f"{field}.landing_authorization_ref required_check_refs must match hosted_landing.required_check_refs")
        return False
    if not validate_exact_sha_check_refs(hosted_required_checks, hosted.get("source_ref"), f"{field}.hosted_landing"):
        return False
    if hosted.get("validated_ref") != hosted.get("source_ref"):
        fail(f"{field}.hosted_landing.validated_ref must equal source_ref")
        return False
    if hosted.get("target_post_ref") != receipt.get("landed_ref"):
        fail(f"{field}.hosted_landing.target_post_ref must equal landed_ref")
        return False
    if hosted.get("source_ref") != receipt.get("landed_ref"):
        fail(f"{field}.hosted_landing.source_ref must equal landed_ref for exact fast-forward integration")
        return False
    if hosted.get("source_branch") != receipt.get("source_branch_ref"):
        fail(f"{field}.hosted_landing.source_branch must equal source_branch_ref")
        return False
    if hosted.get("fast_forward_only") is not True:
        fail(f"{field}.hosted_landing.fast_forward_only must be true")
        return False
    return True


closed_receipt_cleanup_deferred_candidate_ids = set()


def receipt_has_completed_full_closeout(ref, field, candidate_id=None):
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

        if not validate_main_alignment(receipt, field):
            return False
        if route == "branch-no-pr" and not validate_branch_no_pr_landing_authorization(receipt, field):
            return False
        if route == "branch-pr" and not validate_branch_pr_predicate_evidence(receipt, field):
            return False

        cleanup_status = receipt.get("cleanup_status")
        if cleanup_status not in {"completed", "deferred"}:
            fail(f"{field} branch full closeout cleanup_status must be completed or deferred")
            return False
        if lifecycle == "cleaned" and cleanup_status != "completed":
            fail(f"{field} cleaned branch receipt must have completed cleanup_status")
            return False
        source_cleanup = receipt.get("source_branch_cleanup")
        if not isinstance(source_cleanup, dict):
            fail(f"{field} branch full closeout must include source_branch_cleanup")
            return False
        if lifecycle == "cleaned" and source_cleanup.get("status") != "completed":
            fail(f"{field} cleaned branch receipt must have completed source_branch_cleanup")
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
            if is_nonempty_string(candidate_id):
                closed_receipt_cleanup_deferred_candidate_ids.add(candidate_id)
        if source_cleanup.get("status") == "completed" and not validate_cleanup_authorization(receipt, field):
            return False

    elif route == "direct-main":
        if lifecycle not in {"landed", "cleaned"}:
            fail(f"{field} direct-main receipt must have landed or cleaned lifecycle_outcome for closed candidate")
            return False
        if integration != "landed":
            fail(f"{field} direct-main receipt must have integration_status landed for closed candidate")
            return False
        durable_history = receipt.get("durable_history") if isinstance(receipt.get("durable_history"), dict) else {}
        if durable_history.get("kind") != "commit" or durable_history.get("ref") != landed_ref:
            fail(f"{field} direct-main full closeout requires durable_history commit ref equal to landed_ref")
            return False
        if not validate_main_alignment(receipt, field):
            return False

    else:
        fail(f"{field} receipt selected_route must be direct-main, branch-no-pr, or branch-pr for a closed candidate")
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


PUBLISHABLE_CLOSEOUT_EVIDENCE_PREFIXES = (
    ".octon/state/evidence/runs/skills/closeout-change/",
    ".octon/state/evidence/runs/skills/repo-hygiene-cleanup/",
    ".octon/state/evidence/validation/analysis/",
)
LOCAL_PRIVATE_RETAINED_PREFIXES = (
    ".octon/state/evidence/local/",
)
RAW_PRIVATE_OR_UNSAFE_PREFIXES = (
    ".octon/state/control/",
    ".octon/engine/",
    ".octon/generated/effective/",
    ".octon/inputs/",
)
LIFECYCLE_CLOSEOUT_PUBLISHABLE_PREFIXES = (
    ".octon/inputs/additive/extensions/",
    ".octon/inputs/exploratory/proposals/architecture/",
    ".octon/inputs/exploratory/proposals/.archive/",
    ".octon/generated/effective/",
    ".octon/generated/proposals/",
    ".octon/state/evidence/decisions/",
    ".octon/state/evidence/validation/extensions/",
    ".octon/state/evidence/validation/compatibility/extensions/",
    ".octon/state/evidence/validation/publication/",
)
LIFECYCLE_CLOSEOUT_PUBLISHABLE_EXACT_PATHS = {
    ".octon/state/control/extensions/active.yml",
    ".octon/state/control/extensions/quarantine.yml",
}


def path_text(value):
    if not is_nonempty_string(value):
        return ""
    return str(PurePosixPath(value))


def path_is_under(value, prefix):
    text = path_text(value)
    normalized_prefix = str(PurePosixPath(prefix.rstrip("/")))
    return text == normalized_prefix or text.startswith(f"{normalized_prefix}/")


def path_is_under_any(value, prefixes):
    return any(path_is_under(value, prefix) for prefix in prefixes)


def path_is_publishable_closeout_evidence(value):
    return path_is_under_any(value, PUBLISHABLE_CLOSEOUT_EVIDENCE_PREFIXES) and not path_is_raw_private_or_unsafe(value)


def path_is_lifecycle_closeout_publishable_surface(value):
    text = path_text(value)
    return text in LIFECYCLE_CLOSEOUT_PUBLISHABLE_EXACT_PATHS or path_is_under_any(text, LIFECYCLE_CLOSEOUT_PUBLISHABLE_PREFIXES)


def candidate_has_lifecycle_closeout_authority(candidate, prefix):
    authority = candidate.get("lifecycle_closeout_authority") if isinstance(candidate, dict) else None
    if not isinstance(authority, dict):
        return False
    required_string_fields = (
        "completed_program_run_id",
        "program_target",
        "completed_program_summary_ref",
    )
    for field in required_string_fields:
        if not is_nonempty_string(authority.get(field)):
            fail(f"{prefix}.lifecycle_closeout_authority.{field} must be present for lifecycle publishable surfaces")
            return False
    for field in ("child_authority_preserved", "parent_summary_not_child_receipt", "local_run_state_excluded"):
        if authority.get(field) is not True:
            fail(f"{prefix}.lifecycle_closeout_authority.{field} must be true for lifecycle publishable surfaces")
            return False
    proof_refs = authority.get("proof_refs")
    if not isinstance(proof_refs, list) or not proof_refs:
        fail(f"{prefix}.lifecycle_closeout_authority.proof_refs must be a non-empty list")
        return False
    for index, ref in enumerate(proof_refs):
        validate_repo_path(ref, f"{prefix}.lifecycle_closeout_authority.proof_refs[{index}]")
    return True


def path_is_local_private_retained(value):
    return path_is_under_any(value, LOCAL_PRIVATE_RETAINED_PREFIXES)


def path_is_raw_private_or_unsafe(value):
    text = path_text(value)
    lower = text.lower()
    if path_is_under_any(text, RAW_PRIVATE_OR_UNSAFE_PREFIXES):
        return True
    if "transcript" in lower:
        return True
    if path_is_under(text, ".octon/state/"):
        if path_is_under_any(text, PUBLISHABLE_CLOSEOUT_EVIDENCE_PREFIXES):
            return False
        if path_is_under_any(text, LOCAL_PRIVATE_RETAINED_PREFIXES):
            return False
        return True
    return False


def validate_candidate_routing_paths(candidate_id, routing_class, include_paths, prefix, candidate):
    if routing_class == "publishable_closeout_evidence":
        for include_path in include_paths:
            if not path_is_publishable_closeout_evidence(include_path):
                fail(f"{prefix}.residue_routing_class publishable_closeout_evidence may include only approved closeout evidence paths: {include_path}")
    elif routing_class == "publishable_change":
        has_lifecycle_authority = candidate_has_lifecycle_closeout_authority(candidate, prefix)
        for include_path in include_paths:
            if path_is_lifecycle_closeout_publishable_surface(include_path):
                if not has_lifecycle_authority:
                    fail(f"{prefix}.residue_routing_class publishable_change includes lifecycle closeout surface without lifecycle_closeout_authority: {include_path}")
                continue
            if path_is_raw_private_or_unsafe(include_path) or path_is_under(include_path, ".octon/state/"):
                fail(f"{prefix}.residue_routing_class publishable_change must not include raw/private state or generated authority paths: {include_path}")
    elif routing_class == "local_private_retained":
        for include_path in include_paths:
            if not path_is_local_private_retained(include_path):
                fail(f"{prefix}.residue_routing_class local_private_retained may include only local private retained evidence paths: {include_path}")
    elif routing_class == "foreign_manual_review":
        for include_path in include_paths:
            if path_is_raw_private_or_unsafe(include_path):
                fail(f"{prefix}.residue_routing_class foreign_manual_review must not mask raw/private Octon state or generated authority paths: {include_path}")


def retained_evidence_matches_routing(candidate_id, routing_class, item, prefix):
    item_path = item.get("path") if isinstance(item, dict) else None
    disposition = str(item.get("disposition", "") if isinstance(item, dict) else "").lower()
    evidence_text = " ".join(
        str(value)
        for value in (
            candidate_id,
            item_path,
            disposition,
        )
        if value is not None
    ).lower()

    if routing_class == "local_private_retained":
        if not path_is_local_private_retained(item_path):
            fail(f"{prefix} local_private_retained residue evidence must cite .octon/state/evidence/local/ paths")
            return False
    elif routing_class == "foreign_manual_review":
        if path_is_raw_private_or_unsafe(item_path):
            fail(f"{prefix} foreign_manual_review residue evidence must not cite raw/private Octon state or generated authority paths")
            return False
        if not any(marker in evidence_text for marker in ("foreign", "manual", "user-owned", "user owned", "ignored", "local")):
            fail(f"{prefix} foreign_manual_review residue evidence must identify foreign/manual ownership")
            return False
    return True


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
if "repo_hygiene_cleanup_actions_performed" in data:
    require(data.get("repo_hygiene_cleanup_actions_performed") is False, "repo_hygiene_cleanup_actions_performed must be false")

valid_worktree_terminal_states = {
    "git_clean_terminal",
    "disposition_complete_with_retained_residue",
    "nonterminal",
}
worktree_terminal_state = data.get("worktree_terminal_state")
require(
    worktree_terminal_state in valid_worktree_terminal_states,
    f"worktree_terminal_state must be one of {sorted(valid_worktree_terminal_states)}",
)

for field in ("run_id", "initial_inventory_ref", "residue_classification_ref", "final_inventory_ref", "selected_candidate_id", "next_route_condition"):
    require(is_nonempty_string(data.get(field)), f"{field} must be present")

terminal_next_route_values = {"none", "no-op", "noop", "n/a", "na", "closed", "complete", "completed", "done", "terminal"}
repo_hygiene_unresolved_count = 0
repo_hygiene_summary = data.get("repo_hygiene_summary")
repo_hygiene_cleanup_ref = data.get("repo_hygiene_cleanup_ref")
repo_hygiene_cleanup_outcome = data.get("repo_hygiene_cleanup_outcome")
if repo_hygiene_cleanup_ref is not None:
    resolve_repo_hygiene_cleanup_ref(repo_hygiene_cleanup_ref, "repo_hygiene_cleanup_ref")
    valid_cleanup_outcomes = {
        "classification-only",
        "delegated-cleaned",
        "delegated-blocked",
        "delegated-retained",
        "not-applicable",
    }
    require(
        repo_hygiene_cleanup_outcome in valid_cleanup_outcomes,
        f"repo_hygiene_cleanup_outcome must be one of {sorted(valid_cleanup_outcomes)} when repo_hygiene_cleanup_ref is present",
    )
    require(
        data.get("repo_hygiene_cleanup_actions_performed") is False,
        "delegated repo-hygiene cleanup requires repo_hygiene_cleanup_actions_performed: false",
    )
elif repo_hygiene_cleanup_outcome is not None:
    require(
        repo_hygiene_cleanup_outcome in {"classification-only", "not-applicable"},
        "repo_hygiene_cleanup_outcome without repo_hygiene_cleanup_ref must be classification-only or not-applicable",
    )
if repo_hygiene_summary is not None:
    if not isinstance(repo_hygiene_summary, dict):
        fail("repo_hygiene_summary must be a mapping")
    else:
        for field in ("cleanup_candidates", "protected_referenced", "manual_review"):
            value = repo_hygiene_summary.get(field)
            if not isinstance(value, int) or value < 0:
                fail(f"repo_hygiene_summary.{field} must be a non-negative integer")
            else:
                repo_hygiene_unresolved_count += value

if repo_hygiene_unresolved_count > 0:
    require(is_nonempty_string(data.get("repo_hygiene_classification_ref")), "repo_hygiene_classification_ref must be present when repo-hygiene residue remains")
    require(is_nonempty_string(data.get("repo_hygiene_next_route_condition")), "repo_hygiene_next_route_condition must be present when repo-hygiene residue remains")
    if worktree_terminal_state == "git_clean_terminal":
        fail("worktree_terminal_state git_clean_terminal is not allowed while repo-hygiene residue remains unresolved")
    next_route = data.get("repo_hygiene_next_route_condition")
    if is_nonempty_string(next_route) and next_route.strip().lower() in terminal_next_route_values:
        fail("repo_hygiene_next_route_condition must not be terminal when repo-hygiene residue remains")
    worktree_next_route = data.get("next_route_condition")
    if is_nonempty_string(worktree_next_route) and worktree_next_route.strip().lower() in terminal_next_route_values:
        fail("next_route_condition must not be terminal while repo-hygiene residue remains unresolved")

if data.get("repo_hygiene_classification_ref") is not None:
    validate_repo_path(data.get("repo_hygiene_classification_ref"), "repo_hygiene_classification_ref")
if data.get("repo_hygiene_cleanup_authorization_ref") is not None:
    validate_repo_path(data.get("repo_hygiene_cleanup_authorization_ref"), "repo_hygiene_cleanup_authorization_ref")

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
valid_routing_classes = {
    "publishable_change",
    "publishable_closeout_evidence",
    "local_private_retained",
    "foreign_manual_review",
    "unsafe",
    "ambiguous",
}
publishable_routing_classes = {"publishable_change", "publishable_closeout_evidence"}
retained_routing_classes = {"local_private_retained", "foreign_manual_review"}
blocking_routing_classes = {"unsafe", "ambiguous"}
unresolved_candidates = []
candidates_by_id = {}
candidate_boundaries = {}
candidate_routing_classes = {}
blocking_routing_candidate_ids = set()

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
    routing_class = candidate.get("residue_routing_class")
    require(routing_class in valid_routing_classes, f"{prefix}.residue_routing_class must be one of {sorted(valid_routing_classes)}")
    if is_nonempty_string(candidate_id) and routing_class in valid_routing_classes:
        candidate_routing_classes[candidate_id] = routing_class
    if routing_class in blocking_routing_classes and is_nonempty_string(candidate_id):
        blocking_routing_candidate_ids.add(candidate_id)
    if disposition in delegated_dispositions and routing_class not in publishable_routing_classes:
        fail(f"{prefix}.residue_routing_class must be publishable_change or publishable_closeout_evidence when disposition is delegated or closed")
    if disposition in retained_residue_dispositions and routing_class not in retained_routing_classes:
        fail(f"{prefix}.residue_routing_class must be local_private_retained or foreign_manual_review when disposition is retained or foreign")
    if routing_class in blocking_routing_classes and disposition not in blocker_dispositions:
        fail(f"{prefix}.residue_routing_class {routing_class} must use a blocked, escalated, or ambiguous disposition")
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

    if routing_class in valid_routing_classes:
        validate_candidate_routing_paths(candidate_id, routing_class, include_paths, prefix, candidate)

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
            if is_nonempty_string(candidate_id) and candidate_id not in candidate_ids:
                fail(f"blockers[{index}].candidate_id must match a candidate")
            require(
                is_nonempty_string(item.get("blocker")) or is_nonempty_string(item.get("reason")),
                f"blockers[{index}] must include blocker or reason text",
            )
            if is_nonempty_string(candidate_id) and candidate_id in candidate_ids:
                blockers_by_candidate.setdefault(candidate_id, []).append(item)
        else:
            fail(f"blockers[{index}] must be a mapping")
else:
    fail("blockers must be a list")

if unresolved_candidates:
    terminal_next_route_values = {"none", "no-op", "noop", "n/a", "na", "closed", "complete", "completed", "done", "terminal"}
    next_route = data.get("next_route_condition")
    if (
        is_nonempty_string(next_route)
        and next_route.strip().lower() in terminal_next_route_values
        and worktree_terminal_state == "nonterminal"
    ):
        fail("next_route_condition must not be terminal with unresolved candidates when worktree_terminal_state is nonterminal")

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
            routing_class = candidate_routing_classes.get(candidate_id)
            for item in evidence_items:
                retained_evidence_matches_routing(candidate_id, routing_class, item, f"{prefix}.retained_residue")
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
            if candidate_routing_classes.get(candidate_id) not in publishable_routing_classes:
                fail(f"{prefix}.state closed requires publishable_change or publishable_closeout_evidence residue_routing_class")
            ref = item.get("closeout_change_ref")
            require(is_nonempty_string(ref) and "closeout-change" in ref, f"{prefix}.closeout_change_ref must cite closeout-change")
            if is_nonempty_string(ref):
                receipt_has_completed_full_closeout(ref, f"{prefix}.closeout_change_ref", candidate_id)
        elif state in retained_residue_dispositions:
            if candidate_routing_classes.get(candidate_id) not in retained_routing_classes:
                fail(f"{prefix}.state {state} requires local_private_retained or foreign_manual_review residue_routing_class")
            if not retained_by_candidate.get(candidate_id):
                fail(f"{prefix} with state {state} must have retained_residue evidence")
            else:
                for retained_item in retained_by_candidate.get(candidate_id, []):
                    retained_evidence_matches_routing(candidate_id, candidate_routing_classes.get(candidate_id), retained_item, f"{prefix}.retained_residue")
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

if blocking_routing_candidate_ids:
    if worktree_terminal_state != "nonterminal":
        fail("unsafe or ambiguous residue_routing_class candidates require worktree_terminal_state: nonterminal")
    for candidate_id in sorted(blocking_routing_candidate_ids):
        if not blockers_by_candidate.get(candidate_id):
            fail(f"candidate {candidate_id} with unsafe or ambiguous residue_routing_class must have blocker evidence")
        if final_states.get(candidate_id) not in {"blocked", "escalated"}:
            fail(f"candidate {candidate_id} with unsafe or ambiguous residue_routing_class must finish blocked or escalated")

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
            receipt_has_completed_full_closeout(ref, f"{prefix}.closeout_change_ref", iteration_candidate_id)

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
final_residue_counts = {}
if not isinstance(final_residue_classes, dict):
    fail("final_residue_classes must be a mapping with an ignored count")
else:
    ignored_count = final_residue_classes.get("ignored")
    if not isinstance(ignored_count, int) or ignored_count < 0:
        fail("final_residue_classes.ignored must be a non-negative integer")

    def residue_count(canonical, aliases, required=False):
        found = False
        value = 0
        for key in (canonical, *aliases):
            if key in final_residue_classes:
                found = True
                value = final_residue_classes.get(key)
                break
        if not found:
            if required:
                fail(f"final_residue_classes.{canonical} must be present for git_clean_terminal")
            return 0
        if not isinstance(value, int) or value < 0:
            fail(f"final_residue_classes.{canonical} must be a non-negative integer")
            return 0
        return value

    residue_specs = {
        "staged": (),
        "unstaged_tracked": ("unstaged-tracked",),
        "untracked": (),
        "generated_effective_output": ("generated-effective-output",),
        "host_projection": ("host-projection",),
        "retained_evidence": ("retained-evidence",),
        "state_control": ("state-control",),
        "release_version": ("release-version",),
        "input_surface": ("input-surface",),
    }
    for canonical, aliases in residue_specs.items():
        final_residue_counts[canonical] = residue_count(
            canonical,
            aliases,
            required=worktree_terminal_state == "git_clean_terminal",
        )

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
            "operator must select first candidate",
            "operator must choose first candidate",
            "operator must pick first candidate",
            "operator selects first candidate",
            "operator chooses first candidate",
            "manual candidate selection",
            "manual selection of first candidate",
            "requires operator candidate selection",
        )
        if any(marker in blocker_text for marker in partition_only_markers):
            fail("selected candidate must not be blocked only because other candidates exist; delegate safely separable candidates or record a candidate-specific blocker")

non_closed_final_states = [
    candidate_id for candidate_id, state in final_states.items() if state != "closed"
]
genuinely_unresolved_candidate_ids = {
    candidate_id
    for candidate_id, state in final_states.items()
    if state in {"blocked", "escalated", "deferred"}
}
for candidate in unresolved_candidates:
    candidate_id = candidate.get("candidate_id")
    if candidate.get("disposition") in deferred_dispositions | blocker_dispositions and is_nonempty_string(candidate_id):
        genuinely_unresolved_candidate_ids.add(candidate_id)
for candidate_id, items in blockers_by_candidate.items():
    if items:
        genuinely_unresolved_candidate_ids.add(candidate_id)
genuinely_unresolved_candidate_ids |= blocking_routing_candidate_ids
genuinely_unresolved_candidate_ids |= closed_receipt_cleanup_deferred_candidate_ids
terminal_next_route_values = {"none", "no-op", "noop", "n/a", "na", "closed", "complete", "completed", "done", "terminal"}
next_route = data.get("next_route_condition")
terminal_next_route = is_nonempty_string(next_route) and next_route.strip().lower() in terminal_next_route_values

def has_ignored_local_retained_evidence(candidate_id):
    for item in retained_by_candidate.get(candidate_id, []):
        if not isinstance(item, dict):
            continue
        candidate = candidates_by_id.get(candidate_id)
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
            return True
    return False

if worktree_terminal_state == "nonterminal":
    if terminal_next_route:
        fail("next_route_condition must not be terminal when worktree_terminal_state is nonterminal")
    if repo_hygiene_unresolved_count == 0 and not genuinely_unresolved_candidate_ids:
        fail("worktree_terminal_state nonterminal requires an unresolved candidate, repo-hygiene residue, blocker, deferred state, escalation, unsafe residue, or ambiguity")
elif worktree_terminal_state == "disposition_complete_with_retained_residue":
    bad_states = {
        candidate_id: state
        for candidate_id, state in final_states.items()
        if state not in {"closed", "retained", "foreign"}
    }
    if bad_states:
        fail("disposition_complete_with_retained_residue allows only closed, retained, or foreign final candidate states")
    if repo_hygiene_unresolved_count > 0:
        fail("disposition_complete_with_retained_residue is not allowed while repo-hygiene residue remains unresolved")
    if closed_receipt_cleanup_deferred_candidate_ids:
        fail("disposition_complete_with_retained_residue is not allowed while closed branch receipts still defer source branch cleanup")
    retained_candidate_ids = [candidate_id for candidate_id, state in final_states.items() if state in {"retained", "foreign"}]
    if not retained_candidate_ids and non_closed_final_states:
        fail("disposition_complete_with_retained_residue requires retained or foreign final candidate evidence for non-closed residue")
    if not retained_candidate_ids:
        uncovered_retained_counts = {
            key: final_residue_counts.get(key, 0)
            for key in ("untracked", "ignored", "retained_evidence")
            if final_residue_counts.get(key, 0) > 0
        }
        if uncovered_retained_counts:
            fail(f"disposition_complete_with_retained_residue requires retained or foreign candidate evidence for retained residue counts: {uncovered_retained_counts}")
    for candidate_id in retained_candidate_ids:
        routing_class = candidate_routing_classes.get(candidate_id)
        if routing_class not in retained_routing_classes:
            fail(f"disposition_complete_with_retained_residue candidate {candidate_id} must be local_private_retained or foreign_manual_review")
        for retained_item in retained_by_candidate.get(candidate_id, []):
            retained_evidence_matches_routing(candidate_id, routing_class, retained_item, f"retained terminal candidate {candidate_id}")
    forbidden_retained_counts = {
        key: final_residue_counts.get(key, 0)
        for key in (
            "staged",
            "unstaged_tracked",
            "generated_effective_output",
            "host_projection",
            "state_control",
            "release_version",
            "input_surface",
        )
        if final_residue_counts.get(key, 0) > 0
    }
    if forbidden_retained_counts:
        fail(f"disposition_complete_with_retained_residue cannot be satisfied by ordinary source, generated, control, or input residue: {forbidden_retained_counts}")
elif worktree_terminal_state == "git_clean_terminal":
    dirty_counts = {
        key: value
        for key, value in final_residue_counts.items()
        if value > 0
    }
    if dirty_counts:
        fail(f"git_clean_terminal requires zero non-ignored residue counts, found {dirty_counts}")
    if repo_hygiene_unresolved_count > 0:
        fail("git_clean_terminal is not allowed while repo-hygiene residue remains unresolved")
    if closed_receipt_cleanup_deferred_candidate_ids:
        fail("git_clean_terminal is not allowed while closed branch receipts still defer source branch cleanup")
    for candidate_id in non_closed_final_states:
        state = final_states.get(candidate_id)
        if state != "foreign" or not has_ignored_local_retained_evidence(candidate_id):
            fail("git_clean_terminal allows non-closed candidates only for covered ignored/local foreign residue")
        if candidate_routing_classes.get(candidate_id) != "foreign_manual_review":
            fail("git_clean_terminal non-closed foreign residue must use foreign_manual_review residue_routing_class")

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
