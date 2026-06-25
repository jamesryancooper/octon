#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
SCHEMA_PATH="$ROOT_DIR/.octon/framework/product/contracts/branch-no-pr-delivery-authorization-envelope-v1.schema.json"
PREFLIGHT_SCRIPT="$ROOT_DIR/.octon/framework/execution-roles/_ops/scripts/git/git-branch-mutation-preflight.sh"
WORKFLOW_PATH="$ROOT_DIR/.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/workflow.yml"
SKILL_PATH="$ROOT_DIR/.octon/framework/capabilities/runtime/skills/operations/proposal-program-delivery/SKILL.md"
ENVELOPE_PATH=""
errors=0

usage() {
  cat <<'USAGE'
usage:
  validate-branch-no-pr-delivery-authorization-envelope.sh [--envelope <path>]
USAGE
}

pass() { echo "[OK] $1"; }
fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

need_tool() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "[ERROR] $1 is required" >&2
    exit 1
  }
}

scalar() {
  yq -r "$1" "$ENVELOPE_PATH" 2>/dev/null || true
}

require_file() {
  local path="$1" label="$2"
  [[ -f "$path" ]] && pass "$label exists" || fail "$label missing: $path"
}

require_token() {
  local path="$1" token="$2" label="$3"
  if [[ -f "$path" ]] && grep -Fq "$token" "$path"; then
    pass "$label"
  else
    fail "$label missing token: $token"
  fi
}

require_value() {
  local path="$1" expected="$2" label="$3" value
  value="$(scalar "$path")"
  [[ "$value" == "$expected" ]] && pass "$label is $expected" || fail "$label must be $expected"
}

require_bool() {
  require_value "$1" "$2" "$3"
}

require_array_contains() {
  local path="$1" expected="$2" label="$3"
  yq -e "$path[]? | select(. == \"$expected\")" "$ENVELOPE_PATH" >/dev/null 2>&1 \
    && pass "$label contains $expected" \
    || fail "$label must contain $expected"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --envelope)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      ENVELOPE_PATH="$1"
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

need_tool jq
need_tool yq

echo "== Branch No PR Delivery Authorization Envelope Validation =="

require_file "$SCHEMA_PATH" "authorization envelope schema"
require_file "$PREFLIGHT_SCRIPT" "git mutation preflight"
require_file "$WORKFLOW_PATH" "proposal program delivery workflow"
require_file "$SKILL_PATH" "proposal program delivery skill"

if [[ -f "$SCHEMA_PATH" ]] && jq -e '.' "$SCHEMA_PATH" >/dev/null 2>&1; then
  pass "authorization envelope schema JSON parses"
else
  fail "authorization envelope schema must parse as JSON"
fi

for token in \
  '"branch-no-pr-delivery-authorization-envelope-v1"' \
  '"staged_proof_locks"' \
  '"git_mutation_preflight"' \
  '"git-index-write-denied"' \
  '"git-ref-write-denied"' \
  '"preflight_authorizes_side_effects"'; do
  require_token "$SCHEMA_PATH" "$token" "schema token present: $token"
done

for helper in \
  git-branch-commit.sh \
  git-branch-push.sh \
  git-branch-land-hosted-no-pr.sh \
  git-branch-cleanup.sh; do
  require_token "$ROOT_DIR/.octon/framework/execution-roles/_ops/scripts/git/$helper" "git-branch-mutation-preflight.sh" "$helper invokes git mutation preflight"
done

require_token "$WORKFLOW_PATH" "git mutation preflight" "workflow records git mutation preflight"
require_token "$SKILL_PATH" "git mutation preflight" "skill records git mutation preflight"

if [[ -n "$ENVELOPE_PATH" ]]; then
  require_file "$ENVELOPE_PATH" "authorization envelope fixture"
  if yq -e '.' "$ENVELOPE_PATH" >/dev/null 2>&1; then
    pass "authorization envelope parses"
  else
    fail "authorization envelope must parse"
  fi

  require_value '.schema_version' 'branch-no-pr-delivery-authorization-envelope-v1' "schema_version"
  require_value '.selected_route' 'branch-no-pr' "selected route"
  case "$(scalar '.target_lifecycle_outcome')" in
    landed|synced|cleaned) pass "target lifecycle outcome allowed" ;;
    *) fail "target lifecycle outcome must be landed, synced, or cleaned" ;;
  esac
  require_bool '.forbidden_effects.pr_creation' 'true' "PR creation forbidden"
  require_bool '.forbidden_effects.pr_update' 'true' "PR update forbidden"
  require_bool '.forbidden_effects.pr_merge' 'true' "PR merge forbidden"
  require_bool '.forbidden_effects.force_push' 'true' "force push forbidden"
  require_bool '.forbidden_effects.unapproved_cleanup' 'true' "unapproved cleanup forbidden"
  require_bool '.git_mutation_preflight.required' 'true' "git mutation preflight required"
  require_value '.git_mutation_preflight.script_ref' '.octon/framework/execution-roles/_ops/scripts/git/git-branch-mutation-preflight.sh' "git mutation preflight script ref"
  require_bool '.git_mutation_preflight.non_authorizing' 'true' "git mutation preflight non-authorizing"
  require_array_contains '.git_mutation_preflight.blocked_classes' 'git-index-write-denied' "preflight blocked classes"
  require_array_contains '.git_mutation_preflight.blocked_classes' 'git-ref-write-denied' "preflight blocked classes"
  require_bool '.authority_boundaries.parent_summary_replaces_child_evidence' 'false' "parent summary replacement"
  require_bool '.authority_boundaries.archive_authorizes_delivery' 'false' "archive authorizes delivery"
  require_bool '.authority_boundaries.preflight_authorizes_side_effects' 'false' "preflight authorizes side effects"
  require_value '.authority_boundaries.generated_outputs_authority' 'derived-only' "generated outputs authority"
  for lock in commit_before_push push_before_landing landing_before_sync sync_before_cleanup cleanup_before_cleaned; do
    require_bool ".staged_proof_locks.$lock.required" 'true' "proof lock $lock"
    value="$(scalar ".staged_proof_locks.$lock.evidence_ref_field")"
    [[ -n "$value" && "$value" != "null" ]] && pass "proof lock $lock evidence field declared" || fail "proof lock $lock evidence field missing"
  done
fi

echo "Validation summary: errors=$errors"
[[ "$errors" -eq 0 ]]
