#!/usr/bin/env bash
set -euo pipefail

TARGET_BRANCH="main"
REMOTE="origin"
RECEIPT_PATH=""
RULESET_JSON=""
AUTHORIZATION_PATH=""
CONFIRM=0
DRY_RUN=0
ALLOW_EMPTY_CHECK_SET=0
declare -a REQUIRED_CHECKS=()

usage() {
  cat <<'USAGE'
Usage:
  git-branch-land-hosted-no-pr.sh [--target <branch>] [--remote <name>] [--receipt <path>] [--ruleset-json <path>] [--authorization <path>] [--require-check <name>]... [--allow-empty-check-set] [--confirm] [--dry-run]

Fast-forward-only hosted no-PR branch landing helper.
Route guard: call only after Change routing selects branch-no-pr.

Behavior:
  - runs hosted no-PR landing preflight before mutation
  - requires a validating branch-landing-authorization-v1 receipt before mutation
  - pushes the current source ref to the hosted target branch without force
  - verifies post-push that remote target equals the landed ref
  - emits receipt-ready refs for hosted_landing evidence
  - does not create, update, or merge a PR
USAGE
}

error() {
  echo "[ERROR] $1" >&2
  exit 1
}

repo_root() {
  git rev-parse --show-toplevel 2>/dev/null || true
}

run_cmd() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '[DRY] '
    printf '%q ' "$@"
    printf '\n'
    return 0
  fi
  "$@"
}

json_value() {
  local path="$1"
  local expr="$2"
  jq -r "$expr // \"\"" "$path"
}

validate_authorization() {
  local authorization_path="$1"
  [[ -f "$authorization_path" ]] || error "Landing authorization receipt does not exist: $authorization_path"
  jq -e '.' "$authorization_path" >/dev/null 2>&1 || error "Landing authorization receipt must parse as JSON."

  local schema result route target_outcome auth_remote auth_target auth_source_branch auth_source_ref auth_remote_source_ref auth_target_pre_ref preflight no_pr rollback controls
  schema="$(json_value "$authorization_path" '.schema_version')"
  result="$(json_value "$authorization_path" '.authorization_result')"
  route="$(json_value "$authorization_path" '.selected_route')"
  target_outcome="$(json_value "$authorization_path" '.target_lifecycle_outcome')"
  auth_remote="$(json_value "$authorization_path" '.remote')"
  auth_target="$(json_value "$authorization_path" '.target_branch')"
  auth_source_branch="$(json_value "$authorization_path" '.source_branch')"
  auth_source_ref="$(json_value "$authorization_path" '.source_ref')"
  auth_remote_source_ref="$(json_value "$authorization_path" '.remote_source_ref')"
  auth_target_pre_ref="$(json_value "$authorization_path" '.target_pre_ref')"
  preflight="$(json_value "$authorization_path" '.preflight_status')"
  no_pr="$(json_value "$authorization_path" '.no_pr_required')"
  rollback="$(json_value "$authorization_path" '.rollback_handle')"
  controls="$(json_value "$authorization_path" '.host_controls_not_bypassed')"

  [[ "$schema" == "branch-landing-authorization-v1" ]] || error "Landing authorization schema_version must be branch-landing-authorization-v1."
  [[ "$result" == "approved" ]] || error "Landing authorization result must be approved."
  [[ "$route" == "branch-no-pr" ]] || error "Landing authorization route must be branch-no-pr."
  [[ "$target_outcome" == "landed" || "$target_outcome" == "cleaned" ]] || error "Landing authorization target lifecycle outcome must be landed or cleaned."
  [[ "$auth_remote" == "$REMOTE" ]] || error "Landing authorization remote is stale or mismatched."
  [[ "$auth_target" == "$TARGET_BRANCH" ]] || error "Landing authorization target branch is stale or mismatched."
  [[ "$auth_source_branch" == "$SOURCE_BRANCH" ]] || error "Landing authorization source branch is stale or mismatched."
  [[ "$auth_source_ref" == "$SOURCE_REF" ]] || error "Landing authorization source ref is stale or mismatched."
  [[ "$auth_remote_source_ref" == "$SOURCE_REF" ]] || error "Landing authorization remote source ref is stale or mismatched."
  [[ "$auth_target_pre_ref" == "$TARGET_PRE_REF" ]] || error "Landing authorization target pre-ref is stale; re-run preflight and authorization."
  [[ "$preflight" == "passed" ]] || error "Landing authorization must record passed preflight."
  [[ "$no_pr" == "true" ]] || error "Landing authorization must prove no PR is required."
  [[ "$controls" == "true" ]] || error "Landing authorization must preserve host/platform safety boundaries."
  [[ -n "$rollback" ]] || error "Landing authorization must record rollback or discard handle."

  if jq -e '.required_check_refs | type == "array" and length > 0' "$authorization_path" >/dev/null 2>&1; then
    :
  else
    error "Landing authorization must include exact-SHA check refs or explicit empty-check evidence."
  fi

  echo "[OK] Landing authorization receipt validates."
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
    --authorization)
      shift
      [[ $# -gt 0 ]] || error "--authorization requires a value"
      AUTHORIZATION_PATH="$1"
      ;;
    --require-check)
      shift
      [[ $# -gt 0 ]] || error "--require-check requires a value"
      REQUIRED_CHECKS+=("$1")
      ;;
    --allow-empty-check-set)
      ALLOW_EMPTY_CHECK_SET=1
      ;;
    --confirm)
      CONFIRM=1
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

REPO_ROOT="$(repo_root)"
[[ -n "$REPO_ROOT" ]] || error "Run this command from inside a git repository."

SOURCE_BRANCH="$(git -C "$REPO_ROOT" rev-parse --abbrev-ref HEAD)"
[[ "$SOURCE_BRANCH" != "HEAD" ]] || error "Detached HEAD is not supported."
[[ "$SOURCE_BRANCH" != "$TARGET_BRANCH" ]] || error "Source branch already equals target branch."
[[ "$SOURCE_BRANCH" != "main" ]] || error "Refusing hosted no-PR branch landing from main."

SOURCE_REF="$(git -C "$REPO_ROOT" rev-parse "$SOURCE_BRANCH")"
if git -C "$REPO_ROOT" rev-parse --verify "$REMOTE/$TARGET_BRANCH^{commit}" >/dev/null 2>&1; then
  TARGET_PRE_REF="$(git -C "$REPO_ROOT" rev-parse "$REMOTE/$TARGET_BRANCH")"
else
  TARGET_PRE_REF="$(git -C "$REPO_ROOT" rev-parse "$TARGET_BRANCH")"
fi

PREFLIGHT_ARGS=("--target" "$TARGET_BRANCH" "--remote" "$REMOTE")
[[ -n "$RECEIPT_PATH" ]] && PREFLIGHT_ARGS+=("--receipt" "$RECEIPT_PATH")
[[ -n "$RULESET_JSON" ]] && PREFLIGHT_ARGS+=("--ruleset-json" "$RULESET_JSON")
for context in "${REQUIRED_CHECKS[@]}"; do
  PREFLIGHT_ARGS+=("--require-check" "$context")
done
[[ "$ALLOW_EMPTY_CHECK_SET" -eq 1 ]] && PREFLIGHT_ARGS+=("--allow-empty-check-set")
[[ "$DRY_RUN" -eq 1 ]] && PREFLIGHT_ARGS+=("--dry-run")

"$REPO_ROOT/.octon/framework/execution-roles/_ops/scripts/git/git-branch-hosted-preflight.sh" "${PREFLIGHT_ARGS[@]}"

if [[ "$DRY_RUN" -eq 0 ]]; then
  [[ -n "$AUTHORIZATION_PATH" ]] || error "Mutating hosted no-PR branch landing requires --authorization <branch-landing-authorization-v1 receipt>."
  validate_authorization "$AUTHORIZATION_PATH"
elif [[ -n "$AUTHORIZATION_PATH" ]]; then
  validate_authorization "$AUTHORIZATION_PATH"
fi

if [[ "$DRY_RUN" -eq 0 && "$CONFIRM" -ne 1 ]]; then
  error "Mutating hosted no-PR branch landing requires --confirm."
fi

run_cmd git -C "$REPO_ROOT" push "$REMOTE" "$SOURCE_REF:refs/heads/$TARGET_BRANCH"

if [[ "$DRY_RUN" -eq 1 ]]; then
  TARGET_POST_REF="<dry-run>"
else
  git -C "$REPO_ROOT" fetch --quiet "$REMOTE" "$TARGET_BRANCH"
  TARGET_POST_REF="$(git -C "$REPO_ROOT" rev-parse "$REMOTE/$TARGET_BRANCH")"
  [[ "$TARGET_POST_REF" == "$SOURCE_REF" ]] || error "$REMOTE/$TARGET_BRANCH does not equal landed ref $SOURCE_REF after push."
fi

echo "[OK] Route guard: branch-no-pr."
echo "[OK] Hosted no-PR fast-forward landing complete."
echo "[OK] Source branch: $SOURCE_BRANCH"
echo "[OK] Source ref: $SOURCE_REF"
echo "[OK] Target branch: $TARGET_BRANCH"
echo "[OK] Target pre-ref: $TARGET_PRE_REF"
echo "[OK] Target post-ref: $TARGET_POST_REF"
echo "[OK] Landed ref: $SOURCE_REF"
echo "[OK] origin/main equals landed_ref after push when target is main."
echo "[OK] Integration method: fast-forward"
