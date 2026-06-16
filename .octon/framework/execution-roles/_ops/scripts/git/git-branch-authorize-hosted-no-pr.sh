#!/usr/bin/env bash
set -euo pipefail

TARGET_BRANCH="main"
REMOTE="origin"
RECEIPT_PATH=""
RULESET_JSON=""
OUTPUT_PATH=""
ROLLBACK_HANDLE=""
TARGET_LIFECYCLE_OUTCOME="cleaned"
DRY_RUN=0
ALLOW_EMPTY_CHECK_SET=0
EMPTY_CHECK_SET_RATIONALE=""
declare -a REQUIRED_CHECKS=()

usage() {
  cat <<'USAGE'
Usage:
  git-branch-authorize-hosted-no-pr.sh --output <path> --rollback-handle <text> [--target-lifecycle-outcome landed|cleaned] [--target <branch>] [--remote <name>] [--receipt <path>] [--ruleset-json <path>] [--require-check <name>]... [--allow-empty-check-set --empty-check-set-rationale <text>] [--dry-run]

Governed hosted no-PR landing authorization helper.
Route guard: call only after Change routing selects branch-no-pr.

Behavior:
  - runs hosted no-PR landing preflight before emitting authorization
  - records the exact source ref and target pre-ref that may be landed
  - records provider/ruleset, exact-SHA check, rollback, and no-PR evidence
  - emits branch-landing-authorization-v1 JSON
  - does not mutate origin/main and does not create, update, or merge a PR
USAGE
}

sandbox_guidance() {
  echo "[INFO] Governed rerun path: rerun this same helper in an environment authorized for the required git fetch, remote-check, push, or ref-write operation. Do not bypass platform, sandbox, provider, or host controls." >&2
}

error() {
  echo "[ERROR] $1" >&2
  case "$1" in
    *fetch*|*remote*|*push*|*ref*|*branch*|*sandbox*|*host*|*platform*|*provider*|*permission*|*denied*)
      sandbox_guidance
      ;;
  esac
  exit 1
}

run_cmd() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '[DRY] '
    printf '%q ' "$@"
    printf '\n'
    return 0
  fi
  if ! "$@"; then
    echo "[ERROR] command failed: $*" >&2
    sandbox_guidance
    exit 1
  fi
}

repo_root() {
  git rev-parse --show-toplevel 2>/dev/null || true
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      shift
      [[ $# -gt 0 ]] || error "--target requires a value"
      TARGET_BRANCH="$1"
      ;;
    --remote)
      shift
      [[ $# -gt 0 ]] || error "--remote requires a value"
      REMOTE="$1"
      ;;
    --receipt)
      shift
      [[ $# -gt 0 ]] || error "--receipt requires a value"
      RECEIPT_PATH="$1"
      ;;
    --ruleset-json)
      shift
      [[ $# -gt 0 ]] || error "--ruleset-json requires a value"
      RULESET_JSON="$1"
      ;;
    --require-check)
      shift
      [[ $# -gt 0 ]] || error "--require-check requires a value"
      REQUIRED_CHECKS+=("$1")
      ;;
    --allow-empty-check-set)
      ALLOW_EMPTY_CHECK_SET=1
      ;;
    --empty-check-set-rationale)
      shift
      [[ $# -gt 0 ]] || error "--empty-check-set-rationale requires a value"
      EMPTY_CHECK_SET_RATIONALE="$1"
      ;;
    --target-lifecycle-outcome)
      shift
      [[ $# -gt 0 ]] || error "--target-lifecycle-outcome requires a value"
      TARGET_LIFECYCLE_OUTCOME="$1"
      ;;
    --rollback-handle)
      shift
      [[ $# -gt 0 ]] || error "--rollback-handle requires a value"
      ROLLBACK_HANDLE="$1"
      ;;
    --output)
      shift
      [[ $# -gt 0 ]] || error "--output requires a value"
      OUTPUT_PATH="$1"
      ;;
    --dry-run)
      DRY_RUN=1
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      error "Unknown argument: $1"
      ;;
  esac
  shift
done

case "$TARGET_LIFECYCLE_OUTCOME" in
  landed|cleaned) ;;
  *) error "--target-lifecycle-outcome must be landed or cleaned" ;;
esac

[[ -n "$OUTPUT_PATH" ]] || error "--output is required."
[[ -n "$ROLLBACK_HANDLE" ]] || error "--rollback-handle is required."
if [[ "${#REQUIRED_CHECKS[@]}" -eq 0 && "$ALLOW_EMPTY_CHECK_SET" -ne 1 ]]; then
  error "At least one --require-check is required unless --allow-empty-check-set is explicit."
fi
if [[ "$ALLOW_EMPTY_CHECK_SET" -eq 1 && -z "$EMPTY_CHECK_SET_RATIONALE" ]]; then
  error "--empty-check-set-rationale is required when --allow-empty-check-set is explicit."
fi

REPO_ROOT="$(repo_root)"
[[ -n "$REPO_ROOT" ]] || error "Run this command from inside a git repository."

SOURCE_BRANCH="$(git -C "$REPO_ROOT" rev-parse --abbrev-ref HEAD)"
[[ "$SOURCE_BRANCH" != "HEAD" ]] || error "Detached HEAD is not supported."
[[ "$SOURCE_BRANCH" != "$TARGET_BRANCH" ]] || error "Source branch already equals target branch."
[[ "$SOURCE_BRANCH" != "main" ]] || error "Refusing hosted no-PR landing authorization from main."

PREFLIGHT_ARGS=("--target" "$TARGET_BRANCH" "--remote" "$REMOTE")
[[ -n "$RECEIPT_PATH" ]] && PREFLIGHT_ARGS+=("--receipt" "$RECEIPT_PATH")
[[ -n "$RULESET_JSON" ]] && PREFLIGHT_ARGS+=("--ruleset-json" "$RULESET_JSON")
for context in "${REQUIRED_CHECKS[@]}"; do
  PREFLIGHT_ARGS+=("--require-check" "$context")
done
[[ "$ALLOW_EMPTY_CHECK_SET" -eq 1 ]] && PREFLIGHT_ARGS+=("--allow-empty-check-set")
[[ "$DRY_RUN" -eq 1 ]] && PREFLIGHT_ARGS+=("--dry-run")

if ! "$REPO_ROOT/.octon/framework/execution-roles/_ops/scripts/git/git-branch-hosted-preflight.sh" "${PREFLIGHT_ARGS[@]}"; then
  echo "[ERROR] hosted no-PR preflight failed" >&2
  sandbox_guidance
  exit 1
fi

SOURCE_REF="$(git -C "$REPO_ROOT" rev-parse "$SOURCE_BRANCH")"
if [[ "$DRY_RUN" -eq 0 ]]; then
  REMOTE_SOURCE_REF="$(git -C "$REPO_ROOT" rev-parse "$REMOTE/$SOURCE_BRANCH")"
else
  REMOTE_SOURCE_REF="$SOURCE_REF"
fi

if git -C "$REPO_ROOT" rev-parse --verify "$REMOTE/$TARGET_BRANCH^{commit}" >/dev/null 2>&1; then
  TARGET_PRE_REF="$(git -C "$REPO_ROOT" rev-parse "$REMOTE/$TARGET_BRANCH")"
else
  TARGET_PRE_REF="$(git -C "$REPO_ROOT" rev-parse "$TARGET_BRANCH")"
fi

CHECK_REFS=()
if [[ "${#REQUIRED_CHECKS[@]}" -gt 0 ]]; then
  for context in "${REQUIRED_CHECKS[@]}"; do
    CHECK_REFS+=("${context}@${SOURCE_REF}")
  done
else
  CHECK_REFS+=("empty-check-set-explicitly-allowed@${SOURCE_REF}")
fi

CHECK_REFS_JSON="$(printf '%s\n' "${CHECK_REFS[@]}" | jq -R . | jq -s .)"
ALLOW_EMPTY_JSON="false"
[[ "$ALLOW_EMPTY_CHECK_SET" -eq 1 ]] && ALLOW_EMPTY_JSON="true"

RULESET_REF="live-provider-rules:${REMOTE}/${TARGET_BRANCH}"
[[ -n "$RULESET_JSON" ]] && RULESET_REF="ruleset-json:${RULESET_JSON}"

CREATED_AT="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
AUTHORIZATION_ID="hosted-no-pr-${SOURCE_BRANCH//\//-}-${SOURCE_REF:0:12}"

mkdir -p -- "$(dirname -- "$OUTPUT_PATH")"
jq -n \
  --arg schema_version "branch-landing-authorization-v1" \
  --arg authorization_id "$AUTHORIZATION_ID" \
  --arg authorization_result "approved" \
  --arg selected_route "branch-no-pr" \
  --arg target_lifecycle_outcome "$TARGET_LIFECYCLE_OUTCOME" \
  --arg remote "$REMOTE" \
  --arg target_branch "$TARGET_BRANCH" \
  --arg source_branch "$SOURCE_BRANCH" \
  --arg source_ref "$SOURCE_REF" \
  --arg remote_source_ref "$REMOTE_SOURCE_REF" \
  --arg target_pre_ref "$TARGET_PRE_REF" \
  --arg provider_ruleset_ref "$RULESET_REF" \
  --arg preflight_status "passed" \
  --arg rollback_handle "$ROLLBACK_HANDLE" \
  --arg empty_check_set_rationale "$EMPTY_CHECK_SET_RATIONALE" \
  --arg created_at "$CREATED_AT" \
  --argjson required_check_refs "$CHECK_REFS_JSON" \
  --argjson allow_empty_check_set "$ALLOW_EMPTY_JSON" \
  '{
    schema_version: $schema_version,
    authorization_id: $authorization_id,
    authorization_result: $authorization_result,
    selected_route: $selected_route,
    target_lifecycle_outcome: $target_lifecycle_outcome,
    remote: $remote,
    target_branch: $target_branch,
    source_branch: $source_branch,
    source_ref: $source_ref,
    remote_source_ref: $remote_source_ref,
    target_pre_ref: $target_pre_ref,
    provider_ruleset_ref: $provider_ruleset_ref,
    no_pr_required: true,
    preflight_status: $preflight_status,
    required_check_refs: $required_check_refs,
    allow_empty_check_set: $allow_empty_check_set,
    rollback_handle: $rollback_handle,
    host_controls_not_bypassed: true,
    runtime_safety_boundary: "Octon authorization is required before hosted mutation, but it does not bypass platform, sandbox, or host safety controls.",
    created_at: $created_at
  } + (if $allow_empty_check_set then {empty_check_set_rationale: $empty_check_set_rationale} else {} end)' >"$OUTPUT_PATH"

echo "[OK] Hosted no-PR landing authorization emitted."
echo "[OK] Authorization receipt: $OUTPUT_PATH"
echo "[OK] Source branch: $SOURCE_BRANCH"
echo "[OK] Source ref: $SOURCE_REF"
echo "[OK] Target branch: $TARGET_BRANCH"
echo "[OK] Target pre-ref: $TARGET_PRE_REF"
