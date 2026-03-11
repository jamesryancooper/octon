#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/orchestration-runtime-common.sh"
orchestration_runtime_init "${BASH_SOURCE[0]}"
require_tools jq

approval_id=""
action_class=""
surface=""
workflow_group=""
coordination_key=""
decision_time="$(now_utc)"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --approval-id) approval_id="$2"; shift 2 ;;
    --action-class) action_class="$2"; shift 2 ;;
    --surface) surface="$2"; shift 2 ;;
    --workflow-group) workflow_group="$2"; shift 2 ;;
    --coordination-key) coordination_key="$2"; shift 2 ;;
    --decision-time) decision_time="$2"; shift 2 ;;
    *) echo "unknown argument: $1" >&2; exit 1 ;;
  esac
done

[[ -n "$approval_id" && -n "$action_class" && -n "$surface" ]] || { echo "approval-id, action-class, and surface are required" >&2; exit 1; }

approval_file="$DECISIONS_DIR/approvals/$approval_id.json"
registry_file="$HARMONY_DIR/orchestration/governance/approver-authority-registry.json"
[[ -f "$approval_file" ]] || { echo "approval artifact missing: $approval_id" >&2; exit 1; }
[[ -f "$registry_file" ]] || { echo "approver registry missing" >&2; exit 1; }

approval_json="$(cat "$approval_file")"
approved_by="$(jq -r '.approved_by // ""' <<<"$approval_json")"
artifact_type="$(jq -r '.artifact_type // ""' <<<"$approval_json")"
approval_action_class="$(jq -r '.action_class // ""' <<<"$approval_json")"
approval_surface="$(jq -r '.scope.surface // ""' <<<"$approval_json")"
approval_action="$(jq -r '.scope.action // ""' <<<"$approval_json")"
approval_workflow_group="$(jq -r '.scope.workflow_ref.workflow_group // ""' <<<"$approval_json")"
approval_coordination_key="$(jq -r '.scope.coordination_key // ""' <<<"$approval_json")"
approval_expires_at="$(jq -r '.expires_at // ""' <<<"$approval_json")"
review_required="$(jq -r '.review_required' <<<"$approval_json")"
override_reason="$(jq -r '.override_reason // ""' <<<"$approval_json")"

[[ "$approval_action_class" == "$action_class" ]] || { echo "approval action_class mismatch" >&2; exit 1; }
[[ "$approval_surface" == "$surface" ]] || { echo "approval surface mismatch" >&2; exit 1; }
[[ "$approval_expires_at" > "$decision_time" ]] || { echo "approval artifact expired" >&2; exit 1; }

if [[ -n "$workflow_group" && -n "$approval_workflow_group" && "$approval_workflow_group" != "$workflow_group" ]]; then
  echo "approval workflow group mismatch" >&2
  exit 1
fi
if [[ -n "$coordination_key" && -n "$approval_coordination_key" && "$approval_coordination_key" != "$coordination_key" ]]; then
  echo "approval coordination key mismatch" >&2
  exit 1
fi

[[ "$artifact_type" != "override" || "$review_required" == "true" ]] || { echo "override artifacts require review_required=true" >&2; exit 1; }
[[ "$artifact_type" != "override" || -n "$override_reason" ]] || { echo "override artifacts require override_reason" >&2; exit 1; }

approver_json="$(jq -c --arg approver_id "$approved_by" '.approvers[] | select(.approver_id == $approver_id)' "$registry_file" | head -n1)"
[[ -n "$approver_json" ]] || { echo "approver not found in registry" >&2; exit 1; }
[[ "$(jq -r '.revoked' <<<"$approver_json")" == "false" ]] || { echo "approver is revoked" >&2; exit 1; }
[[ "$(jq -r '.expires_at' <<<"$approver_json")" > "$decision_time" ]] || { echo "approver authority expired" >&2; exit 1; }

matching_scopes="$(jq -c --arg action_class "$action_class" --arg surface "$surface" '.approved_scopes[] | select(.action_class == $action_class) | select(.surfaces | index($surface) != null)' <<<"$approver_json")"
[[ -n "$matching_scopes" ]] || { echo "no matching approver scopes" >&2; exit 1; }

if [[ -n "$workflow_group" ]]; then
  echo "$matching_scopes" | jq -e --arg workflow_group "$workflow_group" 'select((.workflow_groups // []) | length == 0 or index($workflow_group) != null)' >/dev/null || { echo "workflow group not allowed by approver scope" >&2; exit 1; }
fi
if [[ -n "$coordination_key" ]]; then
  scope_match="false"
  while IFS= read -r pattern; do
    [[ "$coordination_key" == $pattern ]] && scope_match="true"
  done < <(echo "$matching_scopes" | jq -r '.coordination_key_globs[]?')
  if echo "$matching_scopes" | jq -e 'select((.coordination_key_globs // []) | length == 0)' >/dev/null 2>&1; then
    scope_match="true"
  fi
  [[ "$scope_match" == "true" ]] || { echo "coordination key not allowed by approver scope" >&2; exit 1; }
fi

jq -n \
  --arg approval_id "$approval_id" \
  --arg approved_by "$approved_by" \
  --arg action_class "$action_class" \
  --arg surface "$surface" \
  '{approval_id:$approval_id,approved_by:$approved_by,action_class:$action_class,surface:$surface,status:"valid"}'
