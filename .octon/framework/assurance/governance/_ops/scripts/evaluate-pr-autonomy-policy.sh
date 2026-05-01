#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../.." && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
PROJECT_APPROVAL_SCRIPT="$OCTON_DIR/framework/engine/_ops/scripts/project-github-control-approval.sh"

PR_JSON=""
CHANGED_FILES_JSON=""
STANDARDS_JSON=""
PR_TEMPLATE=""
OUTPUT_JSON=""
REQUEST_ID=""
RUN_ID=""
TARGET_ID=""
ISSUED_BY=""
SUPPORT_TIER="repo-consequential"

usage() {
  cat <<'USAGE'
Usage:
  evaluate-pr-autonomy-policy.sh \
    --pr-json <path> \
    --changed-files-json <path> \
    --standards-json <path> \
    --pr-template <path> \
    [--output-json <path>] \
    [--request-id <id> --run-id <id> --target-id <id> --issued-by <ref>] \
    [--support-tier <tier>]
USAGE
}

json_array() {
  if [[ $# -eq 0 ]]; then
    printf '[]\n'
    return
  fi

  printf '%s\0' "$@" | jq -Rs 'split("\u0000")[:-1]'
}

parse_semver_core() {
  local raw="$1"
  if [[ "$raw" =~ ^v?([0-9]+)(\.([0-9]+))?(\.([0-9]+))? ]]; then
    printf '%s %s %s\n' "${BASH_REMATCH[1]}" "${BASH_REMATCH[3]:-0}" "${BASH_REMATCH[5]:-0}"
    return 0
  fi

  return 1
}

classify_dependabot_update_type() {
  local title="$1"
  if [[ ! "$title" =~ from[[:space:]]+([^[:space:]]+)[[:space:]]+to[[:space:]]+([^[:space:]]+) ]]; then
    printf 'unknown\n'
    return
  fi

  local from_raw="${BASH_REMATCH[1]}"
  local to_raw="${BASH_REMATCH[2]}"
  local from_major from_minor from_patch to_major to_minor to_patch
  read -r from_major from_minor from_patch < <(parse_semver_core "$from_raw" || printf 'x x x\n')
  read -r to_major to_minor to_patch < <(parse_semver_core "$to_raw" || printf 'x x x\n')

  if [[ "$from_major" == "x" || "$to_major" == "x" ]]; then
    printf 'unknown\n'
  elif [[ "$to_major" != "$from_major" ]]; then
    printf 'major\n'
  elif [[ "$to_minor" != "$from_minor" ]]; then
    printf 'minor\n'
  elif [[ "$to_patch" != "$from_patch" ]]; then
    printf 'patch\n'
  else
    printf 'unknown\n'
  fi
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --pr-json) PR_JSON="$2"; shift 2 ;;
      --changed-files-json) CHANGED_FILES_JSON="$2"; shift 2 ;;
      --standards-json) STANDARDS_JSON="$2"; shift 2 ;;
      --pr-template) PR_TEMPLATE="$2"; shift 2 ;;
      --output-json) OUTPUT_JSON="$2"; shift 2 ;;
      --request-id) REQUEST_ID="$2"; shift 2 ;;
      --run-id) RUN_ID="$2"; shift 2 ;;
      --target-id) TARGET_ID="$2"; shift 2 ;;
      --issued-by) ISSUED_BY="$2"; shift 2 ;;
      --support-tier) SUPPORT_TIER="$2"; shift 2 ;;
      -h|--help) usage; exit 0 ;;
      *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
    esac
  done

  [[ -f "$PR_JSON" ]] || { echo "missing --pr-json" >&2; exit 1; }
  [[ -f "$CHANGED_FILES_JSON" ]] || { echo "missing --changed-files-json" >&2; exit 1; }
  [[ -f "$STANDARDS_JSON" ]] || { echo "missing --standards-json" >&2; exit 1; }
  [[ -f "$PR_TEMPLATE" ]] || { echo "missing --pr-template" >&2; exit 1; }

  local title body head_ref base_ref author pr_number
  title="$(jq -r '.title // ""' "$PR_JSON")"
  body="$(jq -r '.body // ""' "$PR_JSON")"
  head_ref="$(jq -r '.head.ref // ""' "$PR_JSON")"
  base_ref="$(jq -r '.base.ref // ""' "$PR_JSON")"
  author="$(jq -r '.user.login // ""' "$PR_JSON")"
  pr_number="$(jq -r '.number // ""' "$PR_JSON")"

  local is_dependabot=false
  local is_release_please=false
  local is_dependabot_github_actions=false
  local is_bot_path=false
  if [[ "$author" == "dependabot[bot]" ]]; then
    is_dependabot=true
  fi
  if [[ "$head_ref" == release-please--* ]]; then
    is_release_please=true
  fi
  if [[ "$is_dependabot" == true && "$head_ref" == dependabot/github_actions/* ]]; then
    is_dependabot_github_actions=true
  fi
  if [[ "$is_dependabot" == true || "$is_release_please" == true ]]; then
    is_bot_path=true
  fi

  local dependabot_update_type="n/a"
  local is_dependabot_safe_update=false
  local dependabot_human_review_required=false
  if [[ "$is_dependabot" == true ]]; then
    dependabot_update_type="$(classify_dependabot_update_type "$title")"
    if [[ "$is_dependabot_github_actions" == true && ( "$dependabot_update_type" == "minor" || "$dependabot_update_type" == "patch" ) ]]; then
      is_dependabot_safe_update=true
    fi
    if [[ "$dependabot_update_type" == "major" || "$dependabot_update_type" == "unknown" ]]; then
      dependabot_human_review_required=true
    fi
  fi

  local allowed_commit_types scope_pattern header_format title_regex
  allowed_commit_types="$(jq -r '.commit.allowed_types | map(gsub("([][(){}.*+?^$|\\\\-])"; "\\\\\\1")) | join("|")' "$STANDARDS_JSON")"
  scope_pattern="$(jq -r '.commit.scope_pattern // "[a-z0-9][a-z0-9-]*"' "$STANDARDS_JSON")"
  header_format="$(jq -r '.commit.header_format // "<type>(<scope>): <summary>"' "$STANDARDS_JSON")"
  title_regex="^(${allowed_commit_types})\\((${scope_pattern})\\)(!)?: (.+)$"

  local -a errors=()
  local -a notices=()
  local -a reason_codes=()

  if [[ "$is_bot_path" != true ]]; then
    if [[ ! "$title" =~ $title_regex ]]; then
      errors+=("PR title '${title}' must match Conventional Commits format ${header_format}.")
    else
      local summary="${BASH_REMATCH[4]}"
      if [[ "$(jq -r '.commit.summary_must_be_lowercase // false' "$STANDARDS_JSON")" == "true" && "$summary" != "${summary,,}" ]]; then
        errors+=("PR title summary must be lowercase.")
      fi
      if [[ "$(jq -r '.commit.summary_must_not_end_with_period // false' "$STANDARDS_JSON")" == "true" && "$summary" == *"." ]]; then
        errors+=("PR title summary must not end with a period.")
      fi
      local header_max_length
      header_max_length="$(jq -r '.commit.header_max_length // 0' "$STANDARDS_JSON")"
      if [[ "$header_max_length" != "0" && "${#title}" -gt "$header_max_length" ]]; then
        errors+=("PR title exceeds ${header_max_length} characters.")
      fi
    fi
  fi

  if [[ "$head_ref" == exp/* ]]; then
    errors+=("Branches under 'exp/' are non-mergeable in autonomy policy. Rename branch before merge.")
  fi

  if [[ "$is_bot_path" != true ]]; then
    mapfile -t required_headings < <(
      awk '
        /^##[[:space:]]+/ {
          line=$0
          sub(/[[:space:]]+$/, "", line)
          print line
          if (line == "## Checklist") {
            exit
          }
        }
      ' "$PR_TEMPLATE"
    )

    local checklist_present=false
    local heading
    for heading in "${required_headings[@]}"; do
      if [[ "$heading" == "## Checklist" ]]; then
        checklist_present=true
      fi
    done
    if [[ "$checklist_present" != true ]]; then
      errors+=("Canonical template is missing '## Checklist'.")
    else
      for heading in "${required_headings[@]}"; do
        if ! printf '%s\n' "$body" | grep -Fqx -- "$heading"; then
          errors+=("PR body missing required section: ${heading}")
        fi
      done
    fi

    if ! printf '%s\n' "$body" | grep -Eiq '(close[sd]?|fixe?[sd]?|resolve[sd]?)\s+#\d+' \
      && ! printf '%s\n' "$body" | grep -Eiq 'No-Issue:\s*\S+'; then
      errors+=("PR body must include issue linkage (Closes/Fixes/Resolves #...) or No-Issue: <reason>.")
    fi
  fi

  local is_high_impact=false
  local is_medium_impact=false
  if jq -e '
    any(.[]?;
      startswith(".github/")
      or . == "AGENTS.md"
      or startswith(".octon/framework/execution-roles/governance/")
      or startswith(".octon/framework/cognition/governance/")
      or startswith(".octon/framework/capabilities/governance/")
      or startswith(".octon/framework/engine/governance/")
      or startswith(".octon/framework/engine/runtime/spec/")
      or startswith(".octon/framework/assurance/governance/")
    )' "$CHANGED_FILES_JSON" >/dev/null; then
    is_high_impact=true
  elif jq -e '
    any(.[]?;
      startswith(".octon/framework/execution-roles/runtime/")
      or startswith(".octon/framework/capabilities/runtime/")
      or startswith(".octon/framework/orchestration/runtime/")
      or startswith(".octon/framework/assurance/runtime/")
      or startswith(".octon/framework/engine/runtime/")
    )' "$CHANGED_FILES_JSON" >/dev/null; then
    is_medium_impact=true
  fi

  local requires_human_review=false
  local reason_code="PR_AUTONOMY_ELIGIBLE"
  if [[ "$is_high_impact" == true && "$is_dependabot_safe_update" != true ]]; then
    requires_human_review=true
    reason_code="PR_AUTONOMY_HIGH_IMPACT_REVIEW_REQUIRED"
    notices+=("High-impact change detected. PR remains manual-lane only; autonomous merge is intentionally disabled.")
  fi
  if [[ "$dependabot_human_review_required" == true ]]; then
    requires_human_review=true
    reason_code="PR_AUTONOMY_DEPENDABOT_REVIEW_REQUIRED"
    notices+=("Dependabot major/unknown update detected. PR remains manual-lane only; autonomous merge is intentionally disabled.")
  fi
  if [[ "$is_dependabot_github_actions" == true ]]; then
    notices+=("Dependabot github-actions update classified as '${dependabot_update_type}'.")
  fi
  if [[ "$is_medium_impact" == true && "$requires_human_review" != true ]]; then
    notices+=("Medium-impact runtime change detected. PR remains eligible only if canonical checks stay green.")
  fi

  local manual_lane_requested=false
  local explicit_auto_merge_requested=false
  if printf '%s\n' "$body" | grep -Eiq '\[[xX]\][[:space:]]*autonomy:no-automerge'; then
    manual_lane_requested=true
  fi
  if printf '%s\n' "$body" | grep -Eiq '\[[xX]\][[:space:]]*autonomy:auto-merge'; then
    explicit_auto_merge_requested=true
  fi

  if [[ "$manual_lane_requested" == true && "$explicit_auto_merge_requested" == true ]]; then
    errors+=("PR body selects both autonomy:auto-merge and autonomy:no-automerge.")
  elif [[ "$manual_lane_requested" == true ]]; then
    requires_human_review=true
    reason_code="PR_AUTONOMY_MANUAL_LANE_REQUESTED"
    notices+=("PR body requests autonomy:no-automerge. PR remains manual-lane only; autonomous merge is intentionally disabled.")
  fi

  local status="granted"
  if [[ "${#errors[@]}" -gt 0 ]]; then
    status="denied"
    reason_code="PR_AUTONOMY_POLICY_FAILED"
    reason_codes+=("PR_AUTONOMY_POLICY_FAILED")
  elif [[ "$requires_human_review" == true ]]; then
    status="staged"
    reason_codes+=("$reason_code")
  else
    reason_codes+=("PR_AUTONOMY_ELIGIBLE")
  fi

  local materialize_json='{}'
  if [[ -n "$REQUEST_ID" || -n "$RUN_ID" || -n "$TARGET_ID" || -n "$ISSUED_BY" ]]; then
    [[ -n "$REQUEST_ID" && -n "$RUN_ID" && -n "$TARGET_ID" && -n "$ISSUED_BY" ]] || {
      echo "request/run/target/issued-by must be provided together" >&2
      exit 1
    }

    local project_status="$status"
    chmod +x "$PROJECT_APPROVAL_SCRIPT"
    materialize_json="$(
      bash "$PROJECT_APPROVAL_SCRIPT" \
        --request-id "$REQUEST_ID" \
        --run-id "$RUN_ID" \
        --target-id "$TARGET_ID" \
        --action-type "github-pr-autonomy-policy" \
        --issued-by "$ISSUED_BY" \
        --status "$project_status" \
        --support-tier "$SUPPORT_TIER" \
        --workflow-mode "role-mediated" \
        --required-evidence "pr-autonomy-policy" \
        --required-evidence "required-checks" \
        --reason-code "$reason_code" \
        --projection-check "github://pull/${pr_number}#check:Validate autonomy policy" \
        --projection-kind "github-head-ref" \
        --projection-ref "github://pull/${pr_number}#head:${head_ref}" \
        --projection-kind "github-base-ref" \
        --projection-ref "github://pull/${pr_number}#base:${base_ref}"
    )"
  fi

  local errors_json notices_json reasons_json result_json
  errors_json="$(json_array "${errors[@]}")"
  notices_json="$(json_array "${notices[@]}")"
  reasons_json="$(json_array "${reason_codes[@]}")"
  result_json="$(
    jq -n \
      --arg status "$status" \
      --arg reason_code "$reason_code" \
      --arg head_ref "$head_ref" \
      --arg base_ref "$base_ref" \
      --argjson errors "$errors_json" \
      --argjson notices "$notices_json" \
      --argjson reason_codes "$reasons_json" \
      --argjson is_high_impact "$( [[ "$is_high_impact" == true ]] && printf 'true' || printf 'false' )" \
      --argjson is_medium_impact "$( [[ "$is_medium_impact" == true ]] && printf 'true' || printf 'false' )" \
      --argjson requires_human_review "$( [[ "$requires_human_review" == true ]] && printf 'true' || printf 'false' )" \
      --argjson manual_lane_requested "$( [[ "$manual_lane_requested" == true ]] && printf 'true' || printf 'false' )" \
      --argjson explicit_auto_merge_requested "$( [[ "$explicit_auto_merge_requested" == true ]] && printf 'true' || printf 'false' )" \
      --argjson materialized "$materialize_json" \
      '{
        status: $status,
        reason_code: $reason_code,
        reason_codes: $reason_codes,
        head_ref: $head_ref,
        base_ref: $base_ref,
        errors: $errors,
        notices: $notices,
        is_high_impact: $is_high_impact,
        is_medium_impact: $is_medium_impact,
        requires_human_review: $requires_human_review,
        manual_lane_requested: $manual_lane_requested,
        explicit_auto_merge_requested: $explicit_auto_merge_requested
      } + $materialized'
  )"

  if [[ -n "$OUTPUT_JSON" ]]; then
    mkdir -p "$(dirname "$OUTPUT_JSON")"
    printf '%s\n' "$result_json" > "$OUTPUT_JSON"
  else
    printf '%s\n' "$result_json"
  fi
}

main "$@"
