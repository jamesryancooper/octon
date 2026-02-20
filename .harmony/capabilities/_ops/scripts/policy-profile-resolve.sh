#!/usr/bin/env bash
# policy-profile-resolve.sh - Resolve policy profiles and optionally materialize grants.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CAPABILITIES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
PROFILE_DIR="$CAPABILITIES_DIR/governance/policy/profiles"
GRANT_BROKER="$CAPABILITIES_DIR/_ops/scripts/policy-grant-broker.sh"

usage() {
  cat <<'USAGE'
Usage:
  policy-profile-resolve.sh <profile-id>
  policy-profile-resolve.sh <profile-id> --emit-grant --subject <subject> --request-id <id> --agent-id <id> --plan-step-id <id> [--review-evidence] [--quorum-evidence]
  policy-profile-resolve.sh --lint
USAGE
}

require_jq() {
  if ! command -v jq >/dev/null 2>&1; then
    echo "jq is required for policy-profile-resolve.sh" >&2
    exit 1
  fi
}

profile_file() {
  local profile_id="$1"
  echo "$PROFILE_DIR/$profile_id.yml"
}

resolve_profile() {
  local profile_id="$1"
  local file
  file="$(profile_file "$profile_id")"

  [[ -f "$file" ]] || { echo "Unknown profile: $profile_id" >&2; exit 1; }
  jq -c . "$file"
}

lint_profiles() {
  local file failed=0
  for file in "$PROFILE_DIR"/*.yml; do
    [[ -e "$file" ]] || continue
    if ! jq -e . "$file" >/dev/null 2>&1; then
      echo "Invalid profile JSON/YAML: $file" >&2
      failed=1
      continue
    fi

    local profile_id
    profile_id="$(jq -r '.id // empty' "$file")"
    if [[ -z "$profile_id" ]]; then
      echo "Profile missing id: $file" >&2
      failed=1
    fi

    if jq -e '.write_scope_bundle[]? | contains("**")' "$file" >/dev/null 2>&1; then
      echo "Profile '$profile_id' contains broad write scope; narrow scope required" >&2
      failed=1
    fi

    if ! jq -e '.tool_bundle | length > 0' "$file" >/dev/null 2>&1; then
      echo "Profile '$profile_id' must define at least one tool token" >&2
      failed=1
    fi
  done

  if [[ $failed -ne 0 ]]; then
    exit 1
  fi

  echo "profile-lint:ok"
}

emit_grant_from_profile() {
  local profile_json="$1"
  local subject="$2"
  local request_id="$3"
  local agent_id="$4"
  local plan_step_id="$5"
  local review_evidence="$6"
  local quorum_evidence="$7"

  local tier
  tier="$(jq -r '.auto_grant_tier // "none"' <<<"$profile_json")"
  if [[ "$tier" == "none" ]]; then
    echo "Profile does not permit auto-grant tier." >&2
    exit 13
  fi

  local -a args
  args=(create --subject "$subject" --tier "$tier" --request-id "$request_id" --agent-id "$agent_id" --plan-step-id "$plan_step_id")

  local token
  while IFS= read -r token; do
    [[ -n "$token" ]] && args+=(--tool "$token")
  done < <(jq -r '.tool_bundle[]?' <<<"$profile_json")

  while IFS= read -r token; do
    [[ -n "$token" ]] && args+=(--write-scope "$token")
  done < <(jq -r '.write_scope_bundle[]?' <<<"$profile_json")

  [[ "$review_evidence" == "true" ]] && args+=(--review-evidence)
  [[ "$quorum_evidence" == "true" ]] && args+=(--quorum-evidence)

  "$GRANT_BROKER" "${args[@]}"
}

main() {
  require_jq

  if [[ "${1:-}" == "--lint" ]]; then
    lint_profiles
    exit 0
  fi

  local profile_id="${1:-}"
  [[ -n "$profile_id" ]] || { usage >&2; exit 1; }
  shift || true

  local emit_grant=false
  local subject="" request_id="" agent_id="" plan_step_id=""
  local review_evidence=false quorum_evidence=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --emit-grant) emit_grant=true; shift ;;
      --subject) subject="$2"; shift 2 ;;
      --request-id) request_id="$2"; shift 2 ;;
      --agent-id) agent_id="$2"; shift 2 ;;
      --plan-step-id) plan_step_id="$2"; shift 2 ;;
      --review-evidence) review_evidence=true; shift ;;
      --quorum-evidence) quorum_evidence=true; shift ;;
      *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
    esac
  done

  local profile_json
  profile_json="$(resolve_profile "$profile_id")"

  if [[ "$emit_grant" == "true" ]]; then
    [[ -n "$subject" ]] || { echo "--subject is required with --emit-grant" >&2; exit 1; }
    [[ -n "$request_id" ]] || { echo "--request-id is required with --emit-grant" >&2; exit 1; }
    [[ -n "$agent_id" ]] || { echo "--agent-id is required with --emit-grant" >&2; exit 1; }
    [[ -n "$plan_step_id" ]] || { echo "--plan-step-id is required with --emit-grant" >&2; exit 1; }

    emit_grant_from_profile "$profile_json" "$subject" "$request_id" "$agent_id" "$plan_step_id" "$review_evidence" "$quorum_evidence"
    exit 0
  fi

  echo "$profile_json"
}

main "$@"
