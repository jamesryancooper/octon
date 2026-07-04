#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"

RECEIPT_PATH=""
COMPACT_RECEIPT_PATH=""
NO_DISPATCH_LEDGER_PATH=""
errors=0

usage() {
  cat <<'USAGE'
usage:
  validate-run-program-clean-delivery.sh [--receipt <proposal-program-delivery-receipt.yml>] [--compact-receipt <compact-blocker-remediation-receipt.yml>] [--no-dispatch-ledger <no-dispatch-attempt-ledger.yml>]

Without --receipt, validates that the clean-delivery validator chain is present
and statically healthy. With --receipt, also requires a validated
proposal-program-delivery receipt whose actual outcome is cleaned. With
--compact-receipt, validates compact blocker-remediation budget evidence. With
--no-dispatch-ledger, validates bounded no-dispatch attempt ledger evidence.
USAGE
}

pass() { echo "[OK] $1"; }
fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --receipt)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      RECEIPT_PATH="$1"
      ;;
    --compact-receipt)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      COMPACT_RECEIPT_PATH="$1"
      ;;
    --no-dispatch-ledger)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      NO_DISPATCH_LEDGER_PATH="$1"
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

need_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "[ERROR] $1 is required" >&2
    exit 1
  fi
}

need_tool yq

run_static_validator() {
  local label="$1" script="$2"
  if bash "$script" >/tmp/octon-clean-delivery-"${label//[^A-Za-z0-9_.-]/_}".log 2>&1; then
    pass "$label static validation passes"
  else
    cat /tmp/octon-clean-delivery-"${label//[^A-Za-z0-9_.-]/_}".log
    fail "$label static validation passes"
  fi
}

require_script() {
  local rel="$1"
  if [[ -x "$ROOT_DIR/$rel" || -f "$ROOT_DIR/$rel" ]]; then
    pass "validator present: $rel"
  else
    fail "validator missing: $rel"
  fi
}

scalar() {
  yq -r "$1" "$RECEIPT_PATH" 2>/dev/null || true
}

scalar_from() {
  local file="$1" expr="$2"
  yq -r "$expr" "$file" 2>/dev/null || true
}

array_length_from() {
  local file="$1" expr="$2"
  yq -r "($expr // []) | length" "$file" 2>/dev/null || echo 0
}

abs_path() {
  python3 - "$1" <<'PY'
import pathlib
import sys

print(pathlib.Path(sys.argv[1]).resolve())
PY
}

receipt_root() {
  python3 - "$1" "$ROOT_DIR" <<'PY'
import pathlib
import sys

path = pathlib.Path(sys.argv[1]).resolve()
fallback = pathlib.Path(sys.argv[2]).resolve()
parts = path.parts
if ".octon" in parts:
    index = parts.index(".octon")
    print(pathlib.Path(*parts[:index]) if index else pathlib.Path("/"))
else:
    print(fallback)
PY
}

resolve_ref() {
  local root="$1" ref="$2"
  if [[ "$ref" == /* ]]; then
    printf '%s\n' "$ref"
  else
    printf '%s/%s\n' "$root" "$ref"
  fi
}

require_receipt_value() {
  local expr="$1" expected="$2" label="$3" value
  value="$(scalar "$expr")"
  [[ "$value" == "$expected" ]] && pass "$label is $expected" || fail "$label must be $expected"
}

require_compact_value() {
  local file="$1" expr="$2" expected="$3" label="$4" value
  value="$(scalar_from "$file" "$expr")"
  [[ "$value" == "$expected" ]] && pass "$label is $expected" || fail "$label must be $expected"
}

require_compact_true() {
  local file="$1" expr="$2" label="$3"
  require_compact_value "$file" "$expr" "true" "$label"
}

require_compact_false() {
  local file="$1" expr="$2" label="$3"
  require_compact_value "$file" "$expr" "false" "$label"
}

require_compact_positive_int() {
  local file="$1" expr="$2" label="$3" value
  value="$(scalar_from "$file" "$expr")"
  [[ "$value" =~ ^[0-9]+$ && "$value" -gt 0 ]] && pass "$label positive" || fail "$label must be a positive integer"
}

receipt_count() {
  yq -r "$1" "$RECEIPT_PATH" 2>/dev/null || echo 1
}

require_receipt_count_zero() {
  local expr="$1" label="$2" value
  value="$(receipt_count "$expr")"
  [[ "$value" == "0" ]] && pass "$label" || fail "$label"
}

validate_run_health_projection_refs() {
  local output status
  set +e
  output="$(python3 - "$RECEIPT_PATH" <<'PY'
import json
import re
import subprocess
import sys

receipt_path = sys.argv[1]
try:
    raw = subprocess.check_output(["yq", "-o=json", ".", receipt_path], text=True)
    data = json.loads(raw) if raw.strip() else {}
except Exception as exc:
    print(f"[ERROR] failed to parse receipt for run-health projection validation: {exc}")
    raise SystemExit(1)

generated_prefix = ".octon/generated/cognition/projections/materialized/runs/"
digest_re = re.compile(r"^sha256:[0-9a-f]{64}$")

def walk(value):
    if isinstance(value, dict):
        for item in value.values():
            yield from walk(item)
    elif isinstance(value, list):
        for item in value:
            yield from walk(item)
    elif isinstance(value, str):
        yield value

def is_generated_run_health_ref(value):
    return value.startswith(generated_prefix) or f"/{generated_prefix}" in value

refs = sorted({item for item in walk(data) if is_generated_run_health_ref(item)})
if not refs:
    print("[OK] delivery receipt has no generated run-health projection refs")
    raise SystemExit(0)

publication = data.get("generated_run_health_publication") or {}
promotion_entries = []
for entry in publication.get("promoted_paths") or []:
    if isinstance(entry, dict):
        promotion_entries.append(entry)
for receipt in publication.get("promotion_receipts") or []:
    if isinstance(receipt, dict):
        for entry in receipt.get("output_paths") or []:
            if isinstance(entry, dict):
                merged = dict(entry)
                merged.setdefault("owning_route", receipt.get("owning_route"))
                merged.setdefault("freshness", receipt.get("freshness"))
                merged.setdefault("allowed_consumers", receipt.get("allowed_consumers"))
                merged.setdefault("forbidden_consumers", receipt.get("forbidden_consumers"))
                merged.setdefault("non_authority_classification", receipt.get("non_authority_classification"))
                promotion_entries.append(merged)
for entry in ((data.get("generated_publication") or {}).get("run_health_promotions") or []):
    if isinstance(entry, dict):
        promotion_entries.append(entry)

promoted_by_path = {
    str(entry.get("path")): entry
    for entry in promotion_entries
    if isinstance(entry, dict) and entry.get("path")
}
errors = []
for ref in refs:
    entry = promoted_by_path.get(ref)
    if not entry:
        errors.append(f"unpromoted generated run-health projection ref: {ref}")
        continue
    digest = entry.get("digest") or entry.get("sha256")
    freshness = entry.get("freshness") if isinstance(entry.get("freshness"), dict) else {}
    allowed = set(entry.get("allowed_consumers") or [])
    forbidden = set(entry.get("forbidden_consumers") or [])
    if not digest_re.match(str(digest or "")):
        errors.append(f"promoted run-health ref lacks sha256 digest: {ref}")
    if (freshness.get("status") or entry.get("freshness_status")) != "fresh":
        errors.append(f"promoted run-health ref lacks fresh freshness status: {ref}")
    if not entry.get("owning_route"):
        errors.append(f"promoted run-health ref lacks owning_route: {ref}")
    if entry.get("non_authority_classification") != "generated_read_model_non_authoritative":
        errors.append(f"promoted run-health ref lacks non-authority classification: {ref}")
    if "validators" not in allowed:
        errors.append(f"promoted run-health ref lacks validators allowed consumer: {ref}")
    for required in ("runtime", "policy", "authority", "support-claim-evaluation", "closeout-gates", "archive-gates"):
        if required not in forbidden:
            errors.append(f"promoted run-health ref lacks forbidden consumer {required}: {ref}")

if errors:
    for error in errors:
        print(f"[ERROR] {error}")
    raise SystemExit(1)
print("[OK] generated run-health projection refs are covered by promotion metadata")
PY
)"
  status=$?
  set -e
  [[ -n "$output" ]] && printf '%s\n' "$output"
  if [[ "$status" -eq 0 ]]; then
    pass "generated run-health projection refs are absent or promotion-receipted"
  else
    fail "generated run-health projection refs require promotion receipt"
  fi
}

validate_compact_remediation_receipt() {
  local receipt="$1" entry_count signal count missing_ref_digest missing_summary_digest
  local bad_evidence_loss bad_unclassified bad_authority bad_full_output_status
  if [[ -f "$receipt" ]]; then
    pass "compact blocker-remediation receipt exists"
  else
    fail "compact blocker-remediation receipt missing: $receipt"
    return
  fi
  if yq -e '.' "$receipt" >/dev/null 2>&1; then
    pass "compact blocker-remediation receipt YAML parses"
  else
    fail "compact blocker-remediation receipt YAML does not parse"
    return
  fi

  require_compact_value "$receipt" '.schema_version' 'octon-program-compact-blocker-remediation-receipt-v1' "compact receipt schema_version"
  require_compact_value "$receipt" '.producer' 'lifecycle-program-controller' "compact receipt producer"
  require_compact_value "$receipt" '.mode' 'compact-blocker-remediation' "compact remediation mode"
  require_compact_false "$receipt" '.authority_boundary.replaces_source_evidence' "compact receipt replaces source evidence"
  require_compact_false "$receipt" '.authority_boundary.authorizes_execution' "compact receipt authorizes execution"
  require_compact_true "$receipt" '.authority_boundary.raw_evidence_retained' "compact receipt raw evidence retained"
  require_compact_value "$receipt" '.authority_boundary.generated_output_authority' 'derived-only' "compact receipt generated output authority"
  require_compact_positive_int "$receipt" '.budget_policy.repeated_blocker_fingerprint_threshold' "repeated blocker fingerprint threshold"
  require_compact_positive_int "$receipt" '.budget_policy.repeated_full_workflow_directory_threshold' "repeated full workflow directory threshold"
  require_compact_positive_int "$receipt" '.budget_policy.file_count_limit' "file count budget"
  require_compact_positive_int "$receipt" '.budget_policy.total_byte_limit' "total byte budget"
  require_compact_true "$receipt" '.budget_policy.compact_continuation_requires_retained_evidence_preservation' "compact continuation requires evidence preservation"
  require_compact_true "$receipt" '.budget_policy.compact_continuation_denied_when_required_receipts_missing' "compact continuation denies missing receipts"
  require_compact_true "$receipt" '.budget_policy.compact_continuation_denied_when_full_evidence_missing' "compact continuation denies missing full evidence"
  require_compact_false "$receipt" '.budget_policy.compact_summaries_are_authority' "compact summaries authority"
  require_compact_false "$receipt" '.compact_continuation.summary_outputs_are_authority' "compact continuation summary authority"

  entry_count="$(array_length_from "$receipt" '.entries')"
  [[ "$entry_count" -gt 0 ]] && pass "compact receipt entries non-empty" || fail "compact receipt entries must be non-empty"
  [[ "$(array_length_from "$receipt" '.retained_evidence_refs')" -gt 0 ]] \
    && pass "compact receipt retained evidence refs non-empty" \
    || fail "compact receipt retained evidence refs must be non-empty"
  [[ -n "$(scalar_from "$receipt" '.bounded_log_summary_ref.sha256')" && "$(scalar_from "$receipt" '.bounded_log_summary_ref.sha256')" != "null" ]] \
    && pass "compact receipt bounded log summary digest declared" \
    || fail "compact receipt bounded log summary digest missing"

  for signal in repeated-fingerprint repeated-full-workflow-directory file-count byte-count; do
    count="$(yq -r "[.entries[]? | select((.trigger_signals // [])[]? == \"$signal\")] | length" "$receipt" 2>/dev/null || echo 0)"
    [[ "$count" -gt 0 ]] && pass "compact receipt covers $signal trigger" || fail "compact receipt must cover $signal trigger"
  done

  missing_ref_digest="$(yq -r '[.entries[]?.retained_evidence_refs[]? | select((.artifact_ref // "") == "" or (.sha256 // "") == "")] | length' "$receipt" 2>/dev/null || echo 1)"
  [[ "$missing_ref_digest" == "0" ]] && pass "compact retained evidence refs include digests" || fail "compact retained evidence refs must include refs and digests"

  missing_summary_digest="$(yq -r '[.entries[]? | select((.bounded_log_summary_ref.sha256 // "") == "")] | length' "$receipt" 2>/dev/null || echo 1)"
  [[ "$missing_summary_digest" == "0" ]] && pass "compact entries include bounded log summary digests" || fail "compact entries must include bounded log summary digests"

  bad_evidence_loss="$(yq -r '[.entries[]? | select(.compact_continuation.evidence_loss_risk == true and .compact_continuation.continuation_allowed == true)] | length' "$receipt" 2>/dev/null || echo 1)"
  [[ "$bad_evidence_loss" == "0" ]] && pass "compact continuation blocks evidence-loss risk" || fail "compact continuation must block evidence-loss risk"

  bad_unclassified="$(yq -r '[.entries[]? | select(((.blocker_class // "") == "unclassified" or (.route_id // "") == "none") and .compact_continuation.continuation_allowed == true)] | length' "$receipt" 2>/dev/null || echo 1)"
  [[ "$bad_unclassified" == "0" ]] && pass "compact continuation blocks unclassified or unrouted blockers" || fail "compact continuation must block unclassified or unrouted blockers"

  bad_authority="$(yq -r '[.entries[]? | select(.compact_continuation.summary_outputs_are_authority == true or ((.authority_boundary_notice // "") | contains("evidence-only") | not))] | length' "$receipt" 2>/dev/null || echo 1)"
  [[ "$bad_authority" == "0" ]] && pass "compact entries remain evidence-only" || fail "compact entries must remain evidence-only and non-authoritative"

  bad_full_output_status="$(yq -r '[.entries[]? | select((.trigger_signals // [])[]? == "repeated-full-workflow-directory") | select((.full_output_path_status // "") != "fail-closed-after-threshold")] | length' "$receipt" 2>/dev/null || echo 1)"
  [[ "$bad_full_output_status" == "0" ]] && pass "repeated full-output threshold fails closed" || fail "repeated full-output threshold must fail closed"
}

validate_no_dispatch_attempt_ledger() {
  local ledger="$1" entry_count max_recent missing_required bad_refs bad_recent bad_authority bad_counts
  if [[ -f "$ledger" ]]; then
    pass "no-dispatch attempt ledger exists"
  else
    fail "no-dispatch attempt ledger missing: $ledger"
    return
  fi
  if yq -e '.' "$ledger" >/dev/null 2>&1; then
    pass "no-dispatch attempt ledger YAML parses"
  else
    fail "no-dispatch attempt ledger YAML does not parse"
    return
  fi

  require_compact_value "$ledger" '.schema_version' 'octon-program-no-dispatch-attempt-ledger-v1' "no-dispatch ledger schema_version"
  require_compact_value "$ledger" '.producer' 'lifecycle-program-controller' "no-dispatch ledger producer"
  require_compact_true "$ledger" '.evidence_only' "no-dispatch ledger evidence-only"
  require_compact_false "$ledger" '.authority_boundary.replaces_source_evidence' "no-dispatch ledger replaces source evidence"
  require_compact_false "$ledger" '.authority_boundary.authorizes_execution' "no-dispatch ledger authorizes execution"
  require_compact_true "$ledger" '.authority_boundary.raw_evidence_retained' "no-dispatch ledger raw evidence retained"
  require_compact_value "$ledger" '.authority_boundary.generated_output_authority' 'derived-only' "no-dispatch ledger generated output authority"
  require_compact_positive_int "$ledger" '.max_recent_attempts' "no-dispatch recent attempt bound"

  entry_count="$(array_length_from "$ledger" '.entries')"
  [[ "$entry_count" -gt 0 ]] && pass "no-dispatch ledger entries non-empty" || fail "no-dispatch ledger entries must be non-empty"
  [[ "$(scalar_from "$ledger" '.entry_count')" == "$entry_count" ]] \
    && pass "no-dispatch ledger entry_count matches entries" \
    || fail "no-dispatch ledger entry_count must match entries"
  [[ "$(array_length_from "$ledger" '.source_evidence_refs')" -gt 0 ]] \
    && pass "no-dispatch ledger source evidence refs non-empty" \
    || fail "no-dispatch ledger source evidence refs must be non-empty"

  missing_required="$(yq -r '[.entries[]? | select((.key_digest // "") == "" or (.target // "") == "" or (.route // "") == "" or (.route_owner // "") == "" or (.input_digest // "") == "" or (.blocker_class // "") == "" or (.blocker_fingerprint // "") == "" or (.attempt_count == null) or (.first_seen_at // "") == "" or (.latest_seen_at // "") == "" or (.latest_event_index == null))] | length' "$ledger" 2>/dev/null || echo 1)"
  [[ "$missing_required" == "0" ]] && pass "no-dispatch entries carry required key fields" || fail "no-dispatch entries must carry key, digest, blocker, count, and event fields"

  bad_counts="$(yq -r '[.entries[]? | select((.attempt_count // 0) < 1)] | length' "$ledger" 2>/dev/null || echo 1)"
  [[ "$bad_counts" == "0" ]] && pass "no-dispatch entry attempt counts positive" || fail "no-dispatch entry attempt counts must be positive"

  bad_refs="$(
    {
      yq -r '[.source_evidence_refs[]? | select((.artifact_ref // "") == "" or (.sha256 // "") == "")] | length' "$ledger" 2>/dev/null || echo 1
      yq -r '[.entries[]?.source_evidence_refs[]? | select((.artifact_ref // "") == "" or (.sha256 // "") == "")] | length' "$ledger" 2>/dev/null || echo 1
      yq -r '[.entries[]?.recent_attempts[]?.source_evidence_refs[]? | select((.artifact_ref // "") == "" or (.sha256 // "") == "")] | length' "$ledger" 2>/dev/null || echo 1
    } | awk '{sum += $1} END {print sum + 0}'
  )"
  [[ "$bad_refs" == "0" ]] && pass "no-dispatch source evidence refs include digests" || fail "no-dispatch source evidence refs must include refs and digests"

  max_recent="$(scalar_from "$ledger" '.max_recent_attempts')"
  bad_recent="$(yq -r "[.entries[]? | select(((.recent_attempts // []) | length) > $max_recent or ((.recent_attempts // []) | length) == 0)] | length" "$ledger" 2>/dev/null || echo 1)"
  [[ "$bad_recent" == "0" ]] && pass "no-dispatch recent attempts are bounded and non-empty" || fail "no-dispatch recent attempts must be bounded and non-empty"

  bad_authority="$(yq -r '[.entries[]? | select(((.authority_boundary_notice // "") | contains("evidence-only") | not))] | length' "$ledger" 2>/dev/null || echo 1)"
  [[ "$bad_authority" == "0" ]] && pass "no-dispatch entries remain evidence-only" || fail "no-dispatch entries must not authorize execution"
}

validate_stale_branch_retirement() {
  local required branch_count retirement_count
  required="$(scalar '.stale_branch_retirement.required')"
  branch_count="$(receipt_count '(.stale_branch_retirement.cleanup_reports.branches // []) | length')"
  retirement_count="$(receipt_count '(.stale_branch_retirement.retirement_receipts // []) | length')"

  if [[ "$required" != "true" && "$branch_count" == "0" && "$retirement_count" == "0" ]]; then
    pass "stale branch retirement receipt not required"
    return
  fi

  require_receipt_value '.stale_branch_retirement.required' 'true' "stale branch retirement requirement"
  require_receipt_value '.stale_branch_retirement.evidence_only' 'true' "stale branch retirement evidence-only"
  require_receipt_value '.stale_branch_retirement.detection_is_deletion_authority' 'false' "stale branch retirement detection authority"
  require_receipt_value '.stale_branch_retirement.remote_mutation_authorized_by_delivery' 'false' "stale branch retirement remote mutation authority"

  [[ "$branch_count" -gt 0 ]] \
    && pass "stale branch cleanup reports branches" \
    || fail "stale branch cleanup reports must name retained or retired local branches"
  [[ "$retirement_count" -gt 0 ]] \
    && pass "stale branch retirement receipts non-empty" \
    || fail "stale branch retirement receipts must be non-empty when required"

  require_receipt_count_zero '[.stale_branch_retirement.cleanup_reports.branches[]? | select((.role_label // "") != "source-dirty-anchor" and (.role_label // "") != "route-owned-delivery-branch" and (.role_label // "") != "correction" and (.role_label // "") != "cleanup" and (.role_label // "") != "retained-protected" and (.role_label // "") != "retired-stale")] | length' \
    "stale branch cleanup reports use known branch role labels"
  require_receipt_count_zero '[.stale_branch_retirement.cleanup_reports.branches[]? | select((.branch // "") == "" or (.role_label // "") == "" or (.ref // "") == "" or (.upstream_state // "") == "" or (.pr_state // "") == "" or (.protected_status == null) or (.worktree_attachment // "") == "" or (.unique_commit_status // "") == "" or (.disposition // "") == "" or (.reason // "") == "")] | length' \
    "stale branch cleanup reports carry required branch facts"
  require_receipt_count_zero '(.stale_branch_retirement.cleanup_reports.branches // []) as $branches | (.stale_branch_retirement.retirement_receipts // []) as $receipts | [$branches[]? | select(.role_label == "retired-stale") | .branch as $branch | select(([$receipts[]? | select(.candidate_branch == $branch and .role_label == "retired-stale")] | length) == 0)] | length' \
    "retired-stale cleanup labels have matching retirement receipts"

  require_receipt_count_zero '[.stale_branch_retirement.retirement_receipts[]? | select((.candidate_branch // "") == "" or (.role_label // "") == "" or (.stale_ref // "") == "" or (.surviving_branch // "") == "" or (.surviving_ref // "") == "" or (.merge_base // "") == "" or (.unique_commit_count == null) or (.no_unique_commits == null) or (.upstream_state // "") == "" or (.remote_ref_state // "") == "" or (.pr_state // "") == "" or (.protected_status == null) or (.active_worktree_dependency == null) or (.dirty_residue == null) or (.authorization == null) or (.post_delete_verification == null) or (.rollback == null))] | length' \
    "stale branch retirement receipts carry required proof fields"
  require_receipt_count_zero '[.stale_branch_retirement.retirement_receipts[]? | select(.role_label == "retired-stale") | select((.unique_commit_count // 1) != 0 or .no_unique_commits != true)] | length' \
    "retired-stale receipts prove no unique commits"
  require_receipt_count_zero '[.stale_branch_retirement.retirement_receipts[]? | select(.role_label == "retired-stale") | select((.upstream_state // "") != "none" or (.remote_ref_state // "") != "absent" or (.pr_state // "") != "none")] | length' \
    "retired-stale receipts prove no unresolved upstream, remote-ref, or PR ownership"
  require_receipt_count_zero '[.stale_branch_retirement.retirement_receipts[]? | select(.role_label == "retired-stale") | select(.protected_status != false or .active_worktree_dependency != false)] | length' \
    "retired-stale receipts prove no protected or active worktree dependency"
  require_receipt_count_zero '[.stale_branch_retirement.retirement_receipts[]? | select(.role_label == "retired-stale") | select(.dirty_residue.checked_out == true) | select((.dirty_residue.disposition // "") != "local-worktree-retired" or (.dirty_residue.authorization_ref // "") == "" or (.dirty_residue.authorization_ref // "") == "not-required" or .dirty_residue.safe_switch_completed != true or .authorization.switch_authorized != true)] | length' \
    "dirty checked-out stale branches require local-worktree retirement proof"
  require_receipt_count_zero '[.stale_branch_retirement.retirement_receipts[]? | select(.role_label == "retired-stale") | select((.dirty_residue.disposition // "") == "unpreservable" or ((.dirty_residue.checked_out == true) and ((.dirty_residue.authorization_ref // "") == "" or (.dirty_residue.authorization_ref // "") == "not-required")))] | length' \
    "unpreservable or unauthorised dirty residue blocks stale branch retirement"
  require_receipt_count_zero '[.stale_branch_retirement.retirement_receipts[]? | select(.role_label == "retired-stale") | select((.authorization.receipt_ref // "") == "" or (.authorization.receipt_ref // "") == "not-required" or .authorization.local_delete_authorized != true)] | length' \
    "retired-stale receipts include local delete authorization"
  require_receipt_count_zero '[.stale_branch_retirement.retirement_receipts[]? | select(.role_label == "retired-stale") | select(((.authorization.remote_mutation_status // "") != "not-authorized") and (((.authorization.remote_mutation_receipt_ref // "") == "" or (.authorization.remote_mutation_receipt_ref // "") == "not-required") or .authorization.remote_mutation_current != true))] | length' \
    "remote branch mutation is blocked without a separate current receipt"
  require_receipt_count_zero '[.stale_branch_retirement.retirement_receipts[]? | select(.role_label == "retired-stale") | select(.post_delete_verification.local_branch_absent != true or .post_delete_verification.surviving_ref_aligned != true or (.post_delete_verification.verification_ref // "") == "")] | length' \
    "retired-stale receipts include post-delete verification"
  require_receipt_count_zero '[.stale_branch_retirement.retirement_receipts[]? | select(.role_label == "retired-stale") | select(.rollback.stale_ref_retained != true or (.rollback.recreate_command // "") == "")] | length' \
    "retired-stale receipts include rollback recreation notes"
  require_receipt_count_zero '[.stale_branch_retirement.retirement_receipts[]? | select(.role_label == "retired-stale") | select(((.blockers // []) | length) != 0)] | length' \
    "retired-stale receipts have no open blocker payload"
}

required_validators=(
  ".octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-profile.sh"
  ".octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-receipt.sh"
  ".octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-evidence-index.sh"
  ".octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-state-machine.sh"
  ".octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh"
  ".octon/framework/assurance/runtime/_ops/scripts/validate-hosted-no-pr-landing.sh"
  ".octon/framework/assurance/runtime/_ops/scripts/validate-evidence-disclosure-tiers.sh"
)

for validator in "${required_validators[@]}"; do
  require_script "$validator"
done

run_static_validator "proposal-program-delivery-profile" "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-profile.sh"
run_static_validator "proposal-program-delivery-receipt" "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-receipt.sh"
run_static_validator "proposal-program-delivery-evidence-index" "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-evidence-index.sh"
run_static_validator "change-closeout-state-machine" "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-state-machine.sh"
run_static_validator "change-closeout-lifecycle-alignment" "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh"
run_static_validator "hosted-no-pr-landing" "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-hosted-no-pr-landing.sh"
run_static_validator "evidence-disclosure-tiers" "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-evidence-disclosure-tiers.sh"

if [[ -n "$COMPACT_RECEIPT_PATH" ]]; then
  validate_compact_remediation_receipt "$COMPACT_RECEIPT_PATH"
fi

if [[ -n "$NO_DISPATCH_LEDGER_PATH" ]]; then
  validate_no_dispatch_attempt_ledger "$NO_DISPATCH_LEDGER_PATH"
fi

if [[ -n "$RECEIPT_PATH" ]]; then
  if [[ -f "$RECEIPT_PATH" ]]; then
    pass "delivery receipt exists"
  else
    fail "delivery receipt missing: $RECEIPT_PATH"
    echo "Validation summary: errors=$errors"
    exit 1
  fi

  if bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-receipt.sh" --receipt "$RECEIPT_PATH"; then
    pass "delivery receipt validator passes"
  else
    fail "delivery receipt validator passes"
  fi

  require_receipt_value '.actual_outcome' 'cleaned' "actual outcome"
  require_receipt_value '.terminal_current_state_proof.verdict' 'pass' "terminal current-state proof verdict"
  require_receipt_value '.terminal_current_state_proof.fresh_after_last_mutation' 'true' "terminal proof freshness"
  require_receipt_value '.worktree_hygiene.verdict' 'pass' "worktree hygiene verdict"
  require_receipt_value '.worktree_hygiene.dirty_worktree' 'false' "worktree dirty flag"
  require_receipt_value '.final_sync.main_origin_landed_ref_equal' 'true' "main/origin/landed ref equality"
  require_receipt_value '.target_owned_evidence_policy.target_owned_receipts_required' 'true' "target-owned receipts required"
  require_receipt_value '.target_owned_evidence_policy.aggregate_receipt_replaces_target_owned_receipts' 'false' "aggregate receipt replacement"
  require_receipt_value '.delivery_evidence_index.schema_version' 'proposal-program-delivery-evidence-index-v1' "delivery evidence index schema_version"
  require_receipt_value '.delivery_evidence_index.validator_ref' '.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-evidence-index.sh' "delivery evidence index validator_ref"
  require_receipt_value '.delivery_evidence_index.validator_verdict' 'pass' "delivery evidence index validator verdict"
  require_receipt_value '.delivery_evidence_index.evidence_only' 'true' "delivery evidence index evidence-only"
  require_receipt_value '.delivery_evidence_index.source_receipt_digest_bound' 'true' "delivery evidence index source receipt digest bound"
  require_receipt_value '.delivery_evidence_index.circular_digest_required' 'false' "delivery evidence index circular digest required"

  open_blockers="$(yq -r '[.blockers[]? | select(.status == "open")] | length' "$RECEIPT_PATH" 2>/dev/null || echo 0)"
  [[ "$open_blockers" == "0" ]] && pass "cleaned receipt has no open blockers" || fail "cleaned receipt must not have open blockers"

  receipt_abs="$(abs_path "$RECEIPT_PATH")"
  evidence_root="$(receipt_root "$RECEIPT_PATH")"

  compact_required="$(scalar '.compact_blocker_remediation.required')"
  if [[ "$compact_required" == "true" ]]; then
    compact_ref="$(scalar '.compact_blocker_remediation.receipt_ref')"
    if [[ -n "$compact_ref" && "$compact_ref" != "null" && "$compact_ref" != "not-applicable" ]]; then
      pass "compact blocker-remediation receipt ref declared"
      validate_compact_remediation_receipt "$(resolve_ref "$evidence_root" "$compact_ref")"
    else
      fail "compact blocker-remediation receipt ref missing when required"
    fi
    require_receipt_value '.compact_blocker_remediation.evidence_only' 'true' "compact blocker-remediation evidence-only"
    require_receipt_value '.compact_blocker_remediation.compact_summaries_are_authority' 'false' "compact blocker-remediation summary authority"
    require_receipt_value '.compact_blocker_remediation.source_full_evidence_digest_bound' 'true' "compact blocker-remediation full evidence digest binding"
  fi

  validate_stale_branch_retirement
  validate_run_health_projection_refs

  if bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-evidence-disclosure-tiers.sh" --root "$evidence_root"; then
    pass "evidence disclosure validator passes for delivery evidence root"
  else
    fail "evidence disclosure validator passes for delivery evidence root"
  fi

  index_ref="$(scalar '.delivery_evidence_index.ref')"
  if [[ -n "$index_ref" && "$index_ref" != "null" ]]; then
    pass "delivery evidence index ref declared"
    index_path="$(resolve_ref "$evidence_root" "$index_ref")"
  else
    fail "delivery evidence index ref missing"
    index_path=""
  fi

  if [[ -n "$index_path" && -f "$index_path" ]]; then
    pass "delivery evidence index exists"
  else
    fail "delivery evidence index missing: ${index_path:-<unset>}"
  fi

  if [[ -n "$index_path" && -f "$index_path" ]]; then
    if bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-evidence-index.sh" --root "$evidence_root" --index "$index_path"; then
      pass "delivery evidence index validator passes"
    else
      fail "delivery evidence index validator passes"
    fi

    index_source_ref="$(yq -r '.source_receipt.ref // ""' "$index_path" 2>/dev/null || true)"
    index_source_path="$(resolve_ref "$evidence_root" "$index_source_ref")"
    if [[ -n "$index_source_ref" && "$(abs_path "$index_source_path")" == "$receipt_abs" ]]; then
      pass "delivery evidence index source receipt matches supplied receipt"
    else
      fail "delivery evidence index source receipt must match supplied receipt"
    fi

    index_outcome="$(yq -r '.actual_outcome // ""' "$index_path" 2>/dev/null || true)"
    [[ "$index_outcome" == "cleaned" ]] && pass "delivery evidence index actual outcome is cleaned" || fail "delivery evidence index actual outcome must be cleaned"

    index_target_owned_required="$(yq -r '.target_owned_evidence_policy.target_owned_receipts_required' "$index_path" 2>/dev/null || true)"
    [[ "$index_target_owned_required" == "true" ]] && pass "delivery evidence index requires target-owned receipts" || fail "delivery evidence index must require target-owned receipts"

    index_replacement="$(yq -r '.target_owned_evidence_policy.aggregate_receipt_replaces_target_owned_receipts' "$index_path" 2>/dev/null || true)"
    [[ "$index_replacement" == "false" ]] && pass "delivery evidence index preserves child-owned receipts" || fail "delivery evidence index must not replace child-owned receipts"

    for policy_path in \
      '.evidence_policy.authorizes_delivery' \
      '.evidence_policy.authorizes_archive' \
      '.evidence_policy.authorizes_landing' \
      '.evidence_policy.authorizes_cleanup' \
      '.evidence_policy.satisfies_child_receipts' \
      '.evidence_policy.generated_outputs_are_authority' \
      '.outcome_authority.index_replaces_delivery_receipt' \
      '.outcome_authority.archive_evidence_claims_delivery' \
      '.outcome_authority.child_delivery_claimed_by_archive_only'; do
      policy_value="$(yq -r "$policy_path" "$index_path" 2>/dev/null || true)"
      [[ "$policy_value" == "false" ]] && pass "delivery evidence index denies ${policy_path#.}" || fail "delivery evidence index must deny ${policy_path#.}"
    done
  fi
fi

echo "Validation summary: errors=$errors"
[[ "$errors" -eq 0 ]]
