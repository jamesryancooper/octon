#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSURANCE_DIR="$(cd -- "$SCRIPT_DIR/../../.." && pwd)"
FRAMEWORK_DIR="$(cd -- "$ASSURANCE_DIR/.." && pwd)"
OCTON_DIR="$(cd -- "$FRAMEWORK_DIR/.." && pwd)"
DEFAULT_ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"
ROOT_DIR="${OCTON_ROOT_DIR:-$DEFAULT_ROOT_DIR}"

TARGET_PATH=""
LIFECYCLE=""
RUN_ID=""
FORMAT="yaml"

usage() {
  cat <<'EOF'
usage:
  classify-proposal-worktree-hygiene.sh --target <proposal-path> --lifecycle proposal-packet|proposal-program [--run-id <run-id>] [--format yaml]
EOF
}

fail() {
  echo "[ERROR] $1" >&2
  exit 2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      TARGET_PATH="$1"
      ;;
    --lifecycle)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      LIFECYCLE="$1"
      ;;
    --run-id)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      RUN_ID="$1"
      ;;
    --format)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      FORMAT="$1"
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

[[ -n "$TARGET_PATH" ]] || { usage >&2; exit 2; }
case "$LIFECYCLE" in
  proposal-packet|proposal-program) ;;
  *) usage >&2; exit 2 ;;
esac
[[ "$FORMAT" == "yaml" ]] || fail "only --format yaml is supported"

GIT_ROOT="$(git -C "$ROOT_DIR" rev-parse --show-toplevel 2>/dev/null)" || fail "ROOT_DIR is not inside a git repository: $ROOT_DIR"
ROOT_DIR="$GIT_ROOT"

normalize_path() {
  local path="$1"
  case "$path" in
    "$ROOT_DIR"/*) path="${path#"$ROOT_DIR"/}" ;;
  esac
  path="${path#./}"
  while [[ "$path" == */ && "$path" != "/" ]]; do
    path="${path%/}"
  done
  printf '%s\n' "$path"
}

TARGET_REL="$(normalize_path "$TARGET_PATH")"
TARGET_DIR="$ROOT_DIR/$TARGET_REL"
MANIFEST="$TARGET_DIR/proposal.yml"
[[ -d "$TARGET_DIR" ]] || fail "target proposal directory does not exist: $TARGET_REL"
[[ -f "$MANIFEST" ]] || fail "target proposal manifest does not exist: $TARGET_REL/proposal.yml"

OWNED_PREFIXES="$(mktemp "${TMPDIR:-/tmp}/octon-hygiene-owned.XXXXXX")"
SCOPE_PREFIXES="$(mktemp "${TMPDIR:-/tmp}/octon-hygiene-scope.XXXXXX")"
OWNED_ROWS="$(mktemp "${TMPDIR:-/tmp}/octon-hygiene-owned-rows.XXXXXX")"
SCOPE_ROWS="$(mktemp "${TMPDIR:-/tmp}/octon-hygiene-scope-rows.XXXXXX")"
RETAINED_FIXTURE_ROWS="$(mktemp "${TMPDIR:-/tmp}/octon-hygiene-retained-fixture-rows.XXXXXX")"
RETAINED_FIXTURE_RECEIPTS="$(mktemp "${TMPDIR:-/tmp}/octon-hygiene-retained-fixture-receipts.XXXXXX")"
RETAINED_FIXTURE_SOURCE_ROWS="$(mktemp "${TMPDIR:-/tmp}/octon-hygiene-retained-fixture-source-rows.XXXXXX")"
FOREIGN_ROWS="$(mktemp "${TMPDIR:-/tmp}/octon-hygiene-foreign-rows.XXXXXX")"
PUBLISHABLE_CHANGE_ROWS="$(mktemp "${TMPDIR:-/tmp}/octon-hygiene-publishable-change-rows.XXXXXX")"
PUBLISHABLE_CLOSEOUT_ROWS="$(mktemp "${TMPDIR:-/tmp}/octon-hygiene-publishable-closeout-rows.XXXXXX")"
CLEANUP_SAFE_ROWS="$(mktemp "${TMPDIR:-/tmp}/octon-hygiene-cleanup-safe-rows.XXXXXX")"
PROTECTED_RETAINED_ROWS="$(mktemp "${TMPDIR:-/tmp}/octon-hygiene-protected-retained-rows.XXXXXX")"
PROTECTED_CONTROL_ROWS="$(mktemp "${TMPDIR:-/tmp}/octon-hygiene-protected-control-rows.XXXXXX")"
MANUAL_REVIEW_ROWS="$(mktemp "${TMPDIR:-/tmp}/octon-hygiene-manual-review-rows.XXXXXX")"
PUBLISH_RUN_SCOPE_CACHE="$(mktemp "${TMPDIR:-/tmp}/octon-hygiene-publish-run-cache.XXXXXX")"
trap 'rm -f "$OWNED_PREFIXES" "$SCOPE_PREFIXES" "$OWNED_ROWS" "$SCOPE_ROWS" "$RETAINED_FIXTURE_ROWS" "$RETAINED_FIXTURE_RECEIPTS" "$RETAINED_FIXTURE_SOURCE_ROWS" "$FOREIGN_ROWS" "$PUBLISHABLE_CHANGE_ROWS" "$PUBLISHABLE_CLOSEOUT_ROWS" "$CLEANUP_SAFE_ROWS" "$PROTECTED_RETAINED_ROWS" "$PROTECTED_CONTROL_ROWS" "$MANUAL_REVIEW_ROWS" "$PUBLISH_RUN_SCOPE_CACHE"' EXIT

add_prefix() {
  local file="$1"
  local raw="$2"
  local normalized
  normalized="$(normalize_path "$raw")"
  [[ -n "$normalized" ]] || return 0
  printf '%s\n' "$normalized" >>"$file"
}

add_in_scope_from_manifest() {
  local manifest="$1"
  [[ -f "$manifest" ]] || return 0
  if command -v yq >/dev/null 2>&1; then
    while IFS= read -r target; do
      [[ -n "$target" && "$target" != "null" ]] || continue
      add_prefix "$SCOPE_PREFIXES" "$target"
    done < <(yq -r '.promotion_targets[]? // ""' "$manifest" 2>/dev/null || true)
  fi
}

proposal_manifest_for_rel() {
  local rel active suffix archive original_path
  rel="$(normalize_path "$1")"
  active="$ROOT_DIR/$rel/proposal.yml"
  if [[ -f "$active" ]]; then
    printf '%s\n' "$active"
    return 0
  fi
  case "$rel" in
    .octon/inputs/exploratory/proposals/*/*)
      suffix="${rel#.octon/inputs/exploratory/proposals/}"
      archive="$ROOT_DIR/.octon/inputs/exploratory/proposals/.archive/$suffix/proposal.yml"
      if [[ -f "$archive" ]] && command -v yq >/dev/null 2>&1; then
        original_path="$(yq -r '.archive.original_path // ""' "$archive" 2>/dev/null || true)"
        if [[ "$(normalize_path "$original_path")" == "$rel" ]]; then
          printf '%s\n' "$archive"
          return 0
        fi
      fi
      ;;
  esac
  return 1
}

add_program_child_scope_from_dir() {
  local program_dir="$1"
  local registry="$program_dir/resources/child-packet-index.yml"
  local child_manifest
  [[ -f "$registry" ]] || return 0
  command -v yq >/dev/null 2>&1 || return 0
  while IFS= read -r child_path; do
    [[ -n "$child_path" && "$child_path" != "null" ]] || continue
    add_prefix "$SCOPE_PREFIXES" "$child_path"
    if child_manifest="$(proposal_manifest_for_rel "$child_path")"; then
      add_in_scope_from_manifest "$child_manifest"
    fi
  done < <(yq -r '.children[]?.path // ""' "$registry" 2>/dev/null || true)
  while IFS= read -r write_scope; do
    [[ -n "$write_scope" && "$write_scope" != "null" ]] || continue
    add_prefix "$SCOPE_PREFIXES" "$write_scope"
  done < <(yq -r '.children[]?.write_scopes[]? // ""' "$registry" 2>/dev/null || true)
}

add_program_child_scope() {
  add_program_child_scope_from_dir "$TARGET_DIR"
}

PROGRAM_RUN_CONTEXT_APPLIED=0

program_checkpoint_applies_to_target() {
  local program_target="$1"
  local registry="$2"
  local child_path normalized_child_path child_manifest child_manifest_dir

  if [[ "$TARGET_REL" == "$program_target" ]]; then
    return 0
  fi

  [[ -f "$registry" ]] || return 1
  command -v yq >/dev/null 2>&1 || return 1
  while IFS= read -r child_path; do
    [[ -n "$child_path" && "$child_path" != "null" ]] || continue
    normalized_child_path="$(normalize_path "$child_path")"
    if [[ "$TARGET_REL" == "$normalized_child_path" ]]; then
      return 0
    fi
    if child_manifest="$(proposal_manifest_for_rel "$normalized_child_path")"; then
      child_manifest_dir="$(normalize_path "$(dirname "$child_manifest")")"
      if [[ "$TARGET_REL" == "$child_manifest_dir" ]]; then
        return 0
      fi
    fi
  done < <(yq -r '.children[]?.path // ""' "$registry" 2>/dev/null || true)

  return 1
}

add_program_scope_from_run_checkpoint() {
  [[ -n "$RUN_ID" ]] || return 0
  command -v yq >/dev/null 2>&1 || return 0
  local run_dir checkpoint program_target program_dir registry
  run_dir="$ROOT_DIR/.octon/state/control/execution/runs/$RUN_ID"
  for checkpoint in "$run_dir/program-lifecycle-checkpoint.yml" "$run_dir/lifecycle-checkpoint.yml"; do
    [[ -f "$checkpoint" ]] && break
  done
  [[ -f "$checkpoint" ]] || return 0
  program_target="$(yq -r '.target // ""' "$checkpoint" 2>/dev/null || true)"
  [[ -n "$program_target" && "$program_target" != "null" ]] || return 0
  program_target="$(normalize_path "$program_target")"
  program_dir="$ROOT_DIR/$program_target"
  registry="$program_dir/resources/child-packet-index.yml"
  [[ -f "$registry" ]] || return 0
  program_checkpoint_applies_to_target "$program_target" "$registry" || return 0
  PROGRAM_RUN_CONTEXT_APPLIED=1
  add_prefix "$SCOPE_PREFIXES" "$program_target"
  add_in_scope_from_manifest "$program_dir/proposal.yml"
  add_program_child_scope_from_dir "$program_dir"
}

add_program_generated_scope() {
  add_prefix "$SCOPE_PREFIXES" ".octon/generated/effective"
  add_prefix "$SCOPE_PREFIXES" ".octon/generated/proposals"
  add_prefix "$SCOPE_PREFIXES" ".octon/state/control/extensions"
  add_prefix "$SCOPE_PREFIXES" ".octon/state/evidence/decisions/repo/capabilities"
  add_prefix "$SCOPE_PREFIXES" ".octon/state/evidence/runs/skills/closeout-change"
  add_prefix "$SCOPE_PREFIXES" ".octon/state/evidence/validation"
}

matches_prefix_file() {
  local path="$1"
  local file="$2"
  local prefix
  while IFS= read -r prefix; do
    [[ -n "$prefix" ]] || continue
    if [[ "$path" == "$prefix" || "$path" == "$prefix"/* ]]; then
      return 0
    fi
  done <"$file"
  return 1
}

cache_bool_get() {
  local file="$1"
  local key="$2"
  local cached_key value
  while IFS=$'\t' read -r cached_key value; do
    [[ "$cached_key" == "$key" ]] || continue
    [[ "$value" == "true" ]]
    return $?
  done <"$file"
  return 2
}

cache_bool_put() {
  local file="$1"
  local key="$2"
  local value="$3"
  printf '%s\t%s\n' "$key" "$value" >>"$file"
}

ARCHIVE_MOVE_CANDIDATE_AUTHORIZED="false"
ARCHIVE_MOVE_ORIGINAL_REL=""

detect_archive_move_candidate() {
  local status original_path normalized_original
  [[ -f "$MANIFEST" ]] || return 0
  command -v yq >/dev/null 2>&1 || return 0
  case "$TARGET_REL" in
    .octon/inputs/exploratory/proposals/.archive/*/*) ;;
    *) return 0 ;;
  esac
  status="$(yq -r '.status // ""' "$MANIFEST" 2>/dev/null || true)"
  original_path="$(yq -r '.archive.original_path // ""' "$MANIFEST" 2>/dev/null || true)"
  [[ "$status" == "archived" ]] || return 0
  [[ -n "$original_path" && "$original_path" != "null" ]] || return 0
  normalized_original="$(normalize_path "$original_path")"
  [[ -n "$normalized_original" ]] || return 0
  [[ -d "$TARGET_DIR" ]] || return 0
  [[ ! -e "$ROOT_DIR/$normalized_original" ]] || return 0

  ARCHIVE_MOVE_CANDIDATE_AUTHORIZED="true"
  ARCHIVE_MOVE_ORIGINAL_REL="$normalized_original"
}

archive_move_candidate_path() {
  local status="$1"
  local path="$2"
  [[ "$ARCHIVE_MOVE_CANDIDATE_AUTHORIZED" == "true" ]] || return 1
  if [[ "$path" == "$TARGET_REL" || "$path" == "$TARGET_REL/"* ]]; then
    return 0
  fi
  if [[ -n "$ARCHIVE_MOVE_ORIGINAL_REL" && "$status" == *D* ]] &&
    [[ "$path" == "$ARCHIVE_MOVE_ORIGINAL_REL" || "$path" == "$ARCHIVE_MOVE_ORIGINAL_REL/"* ]]; then
    return 0
  fi
  return 1
}

matches_current_run_artifact() {
  local path="$1"
  [[ -n "$RUN_ID" ]] || return 1
  case "$path" in
    ".octon/state/control/execution/runs/$RUN_ID"|\
    ".octon/state/control/execution/runs/$RUN_ID"/*|\
    ".octon/state/control/execution/runs/$RUN_ID-"*|\
    ".octon/state/continuity/runs/$RUN_ID"|\
    ".octon/state/continuity/runs/$RUN_ID"/*|\
    ".octon/state/continuity/runs/$RUN_ID-"*|\
    ".octon/state/evidence/runs/workflows/$RUN_ID"|\
    ".octon/state/evidence/runs/workflows/$RUN_ID"/*|\
    ".octon/state/evidence/runs/workflows/$RUN_ID-"*|\
    ".octon/state/evidence/control/execution/"*"$RUN_ID"*|\
    ".octon/state/evidence/external-index/runs/$RUN_ID"*|\
    ".octon/state/evidence/runs/skills/closeout-packet/$RUN_ID"*|\
    ".octon/state/evidence/runs/skills/octon-proposal-lifecycle-closeout-packet/$RUN_ID"*|\
    ".octon/state/evidence/runs/skills/repo-hygiene-cleanup/$RUN_ID"* )
      return 0
      ;;
  esac
  return 1
}

matches_target_closeout_skill_artifact() {
  local path="$1"
  [[ -n "$PROPOSAL_ID" && "$PROPOSAL_ID" != "null" ]] || return 1
  case "$path" in
    ".octon/state/evidence/runs/skills/octon-proposal-lifecycle-closeout-packet/$PROPOSAL_ID"|\
    ".octon/state/evidence/runs/skills/octon-proposal-lifecycle-closeout-packet/$PROPOSAL_ID"/* )
      return 0
      ;;
  esac
  return 1
}

same_scope_lifecycle_run_artifact() {
  local path="$1"
  local run_dir run_id checkpoint target
  case "$path" in
    ".octon/state/control/execution/runs/"*)
      run_id="${path#".octon/state/control/execution/runs/"}"
      run_id="${run_id%%/*}"
      ;;
    ".octon/state/continuity/runs/"*)
      run_id="${path#".octon/state/continuity/runs/"}"
      run_id="${run_id%%/*}"
      ;;
    ".octon/state/evidence/runs/workflows/"*)
      run_id="${path#".octon/state/evidence/runs/workflows/"}"
      run_id="${run_id%%/*}"
      ;;
    ".octon/state/evidence/external-index/runs/"*)
      run_id="${path#".octon/state/evidence/external-index/runs/"}"
      run_id="${run_id%%/*}"
      run_id="${run_id%.yml}"
      ;;
    ".octon/state/evidence/control/execution/"*)
      run_id="${path#".octon/state/evidence/control/execution/"}"
      run_id="${run_id%%/*}"
      run_id="${run_id%.yml}"
      case "$run_id" in
        authority-decision-*) run_id="${run_id#"authority-decision-"}" ;;
        authority-grant-bundle-*) run_id="${run_id#"authority-grant-bundle-"}" ;;
        *) return 1 ;;
      esac
      ;;
    ".octon/state/evidence/runs/skills/closeout-packet/"*)
      run_id="${path#".octon/state/evidence/runs/skills/closeout-packet/"}"
      run_id="${run_id%%/*}"
      ;;
    ".octon/state/evidence/runs/skills/octon-proposal-lifecycle-closeout-packet/"*)
      run_id="${path#".octon/state/evidence/runs/skills/octon-proposal-lifecycle-closeout-packet/"}"
      run_id="${run_id%%/*}"
      ;;
    ".octon/state/evidence/runs/skills/repo-hygiene-cleanup/"*)
      run_id="${path#".octon/state/evidence/runs/skills/repo-hygiene-cleanup/"}"
      run_id="${run_id%%/*}"
      ;;
    *)
      return 1
      ;;
  esac
  [[ -n "$run_id" ]] || return 1
  if [[ "$run_id" =~ ^(lifecycle-proposal-(program|packet)-[0-9]+-[A-Za-z0-9]+) ]]; then
    run_id="${BASH_REMATCH[1]}"
  else
    return 1
  fi
  run_dir="$ROOT_DIR/.octon/state/control/execution/runs/$run_id"
  checkpoint=""
  if [[ -f "$run_dir/program-lifecycle-checkpoint.yml" ]]; then
    checkpoint="$run_dir/program-lifecycle-checkpoint.yml"
  elif [[ -f "$run_dir/lifecycle-checkpoint.yml" ]]; then
    checkpoint="$run_dir/lifecycle-checkpoint.yml"
  elif [[ -f "$ROOT_DIR/.octon/state/evidence/runs/workflows/$run_id/program-lifecycle-checkpoint.yml" ]]; then
    checkpoint="$ROOT_DIR/.octon/state/evidence/runs/workflows/$run_id/program-lifecycle-checkpoint.yml"
  elif [[ -f "$ROOT_DIR/.octon/state/evidence/runs/workflows/$run_id/lifecycle-checkpoint.yml" ]]; then
    checkpoint="$ROOT_DIR/.octon/state/evidence/runs/workflows/$run_id/lifecycle-checkpoint.yml"
  fi
  [[ -n "$checkpoint" ]] || return 1
  target=""
  if command -v yq >/dev/null 2>&1; then
    target="$(yq -r '.target // ""' "$checkpoint" 2>/dev/null || true)"
  fi
  [[ -n "$target" && "$target" != "null" ]] || return 1
  target="$(normalize_path "$target")"
  if [[ "$target" == "$TARGET_REL" ]] || matches_prefix_file "$target" "$SCOPE_PREFIXES"; then
    return 0
  fi
  return 1
}

publish_run_id_for_artifact_path() {
  local path="$1"
  case "$path" in
    ".octon/state/control/execution/runs/"*)
      path="${path#".octon/state/control/execution/runs/"}"
      printf '%s\n' "${path%%/*}"
      return 0
      ;;
    ".octon/state/continuity/runs/"*)
      path="${path#".octon/state/continuity/runs/"}"
      printf '%s\n' "${path%%/*}"
      return 0
      ;;
    ".octon/state/evidence/external-index/runs/"*)
      path="${path#".octon/state/evidence/external-index/runs/"}"
      path="${path%%/*}"
      printf '%s\n' "${path%.yml}"
      return 0
      ;;
    ".octon/state/evidence/control/execution/"*)
      path="${path#".octon/state/evidence/control/execution/"}"
      path="${path%%/*}"
      path="${path%.yml}"
      case "$path" in
        authority-decision-*) printf '%s\n' "${path#"authority-decision-"}"; return 0 ;;
        authority-grant-bundle-*) printf '%s\n' "${path#"authority-grant-bundle-"}"; return 0 ;;
      esac
      ;;
  esac
  return 1
}

publication_command_for_manifest() {
  local manifest="$1"
  local action_type target_id target_slug
  [[ -f "$manifest" ]] || return 1
  command -v yq >/dev/null 2>&1 || return 1
  action_type="$(yq -r '.action_type // ""' "$manifest" 2>/dev/null || true)"
  target_id="$(yq -r '.target_id // ""' "$manifest" 2>/dev/null || true)"
  [[ "$action_type" == "publish_generated_effective" ]] || return 1
  case "$target_id" in
    publication:*) ;;
    *) return 1 ;;
  esac
  target_slug="${target_id#publication:}"
  [[ -n "$target_slug" && "$target_slug" != "null" ]] || return 1
  printf 'publish-%s\n' "$target_slug"
}

completed_current_recovery_command() {
  local command_id="$1"
  local recovery_root result status exit_code actual_command
  [[ -n "$RUN_ID" ]] || return 1
  [[ -n "$command_id" ]] || return 1
  command -v yq >/dev/null 2>&1 || return 1
  recovery_root="$ROOT_DIR/.octon/state/evidence/runs/workflows/$RUN_ID/program-recovery-actions"
  [[ -d "$recovery_root" ]] || return 1
  while IFS= read -r result; do
    [[ -f "$result" ]] || continue
    actual_command="$(yq -r '.command_id // ""' "$result" 2>/dev/null || true)"
    status="$(yq -r '.status // ""' "$result" 2>/dev/null || true)"
    exit_code="$(yq -r '.exit_code // ""' "$result" 2>/dev/null || true)"
    if [[ "$actual_command" == "$command_id" && "$status" == "completed" && "$exit_code" == "0" ]]; then
      return 0
    fi
  done < <(find "$recovery_root" -type f -name '*command.result.yml' 2>/dev/null | LC_ALL=C sort)
  return 1
}

same_scope_program_recovery_publish_artifact() {
  local path="$1"
  local run_id manifest command_id cache_key
  [[ "$LIFECYCLE" == "proposal-program" ]] || return 1
  run_id="$(publish_run_id_for_artifact_path "$path" 2>/dev/null || true)"
  [[ -n "$run_id" ]] || return 1
  cache_key="publish-run:$run_id"
  if cache_bool_get "$PUBLISH_RUN_SCOPE_CACHE" "$cache_key"; then
    return 0
  else
    case "$?" in
      1) return 1 ;;
    esac
  fi
  manifest="$ROOT_DIR/.octon/state/control/execution/runs/$run_id/run-manifest.yml"
  command_id="$(publication_command_for_manifest "$manifest" 2>/dev/null || true)"
  if [[ -n "$command_id" ]] && completed_current_recovery_command "$command_id"; then
    cache_bool_put "$PUBLISH_RUN_SCOPE_CACHE" "$cache_key" "true"
    return 0
  fi
  cache_bool_put "$PUBLISH_RUN_SCOPE_CACHE" "$cache_key" "false"
  return 1
}

same_scope_repo_hygiene_cleanup_receipt() {
  local path="$1"
  local receipt target receipt_run_id run_dir checkpoint
  case "$path" in
    ".octon/state/evidence/runs/skills/repo-hygiene-cleanup/"*/receipt.yml)
      receipt="$ROOT_DIR/$path"
      ;;
    ".octon/state/evidence/runs/skills/repo-hygiene-cleanup/"*/cleanup-authorization.json)
      receipt="$ROOT_DIR/${path%/cleanup-authorization.json}/receipt.yml"
      ;;
    *)
      return 1
      ;;
  esac
  [[ -f "$receipt" ]] || return 1
  command -v yq >/dev/null 2>&1 || return 1
  target="$(yq -r '.target // ""' "$receipt" 2>/dev/null || true)"
  if [[ -n "$target" && "$target" != "null" ]]; then
    target="$(normalize_path "$target")"
    if [[ "$target" == "$TARGET_REL" ]] || matches_prefix_file "$target" "$SCOPE_PREFIXES"; then
      return 0
    fi
  fi
  receipt_run_id="$(yq -r '.parent_run_id // .run_id // ""' "$receipt" 2>/dev/null || true)"
  [[ -n "$receipt_run_id" && "$receipt_run_id" != "null" ]] || return 1
  if [[ "$receipt_run_id" =~ ^(lifecycle-proposal-(program|packet)-[0-9]+-[A-Za-z0-9]+) ]]; then
    receipt_run_id="${BASH_REMATCH[1]}"
  else
    return 1
  fi
  run_dir="$ROOT_DIR/.octon/state/control/execution/runs/$receipt_run_id"
  checkpoint=""
  if [[ -f "$run_dir/program-lifecycle-checkpoint.yml" ]]; then
    checkpoint="$run_dir/program-lifecycle-checkpoint.yml"
  elif [[ -f "$run_dir/lifecycle-checkpoint.yml" ]]; then
    checkpoint="$run_dir/lifecycle-checkpoint.yml"
  elif [[ -f "$ROOT_DIR/.octon/state/evidence/runs/workflows/$receipt_run_id/program-lifecycle-checkpoint.yml" ]]; then
    checkpoint="$ROOT_DIR/.octon/state/evidence/runs/workflows/$receipt_run_id/program-lifecycle-checkpoint.yml"
  elif [[ -f "$ROOT_DIR/.octon/state/evidence/runs/workflows/$receipt_run_id/lifecycle-checkpoint.yml" ]]; then
    checkpoint="$ROOT_DIR/.octon/state/evidence/runs/workflows/$receipt_run_id/lifecycle-checkpoint.yml"
  fi
  [[ -n "$checkpoint" ]] || return 1
  target="$(yq -r '.target // ""' "$checkpoint" 2>/dev/null || true)"
  [[ -n "$target" && "$target" != "null" ]] || return 1
  target="$(normalize_path "$target")"
  if [[ "$target" == "$TARGET_REL" ]] || matches_prefix_file "$target" "$SCOPE_PREFIXES"; then
    return 0
  fi
  return 1
}

repo_relative_file_exists() {
  local rel="$1"
  [[ -n "$rel" ]] || return 1
  case "$rel" in
    /*|*"/../"*|../*|*"/.."|.) return 1 ;;
  esac
  [[ -f "$ROOT_DIR/$rel" ]]
}

file_sha256() {
  local file="$1"
  shasum -a 256 "$file" | awk '{print "sha256:" $1}'
}

closeout_worktree_report_ref_location() {
  local report_ref="$1"
  case "$report_ref" in
    .octon/state/evidence/validation/analysis/*closeout-worktree*.yml|\
    .octon/state/evidence/validation/analysis/*closeout-worktree*.yaml|\
    .octon/state/evidence/validation/analysis/*closeout-worktree*.json|\
    .octon/state/evidence/runs/workflows/*/lifecycle-interactions/*closeout-worktree-report*.yml|\
    .octon/state/evidence/runs/workflows/*/lifecycle-interactions/*closeout-worktree-report*.yaml|\
    .octon/state/evidence/runs/workflows/*/lifecycle-interactions/*closeout-worktree-report*.json)
      return 0
      ;;
  esac
  return 1
}

closeout_worktree_return_ref_location() {
  local return_ref="$1"
  case "$return_ref" in
    .octon/state/evidence/runs/skills/closeout-worktree/*/lifecycle-interaction-return.json|\
    .octon/state/evidence/runs/workflows/*/lifecycle-interactions/*closeout-worktree-return*.json)
      return 0
      ;;
  esac
  return 1
}

same_scope_closeout_worktree_report_ref() {
  local report_ref="$1"
  local report_path program_run_id classifier_ref request_ref
  [[ -n "$RUN_ID" ]] || return 1
  command -v yq >/dev/null 2>&1 || return 1
  closeout_worktree_report_ref_location "$report_ref" || return 1
  repo_relative_file_exists "$report_ref" || return 1
  report_path="$ROOT_DIR/$report_ref"
  [[ "$(yq -r '.schema_version // ""' "$report_path" 2>/dev/null || true)" == "closeout-worktree-report-v1" ]] || return 1

  while IFS=$'\t' read -r program_run_id classifier_ref request_ref; do
    [[ -n "$program_run_id$classifier_ref$request_ref" ]] || continue
    if [[ "$program_run_id" == "$RUN_ID" ]] ||
      [[ "$classifier_ref" == ".octon/state/evidence/runs/workflows/$RUN_ID/"* ]] ||
      [[ "$request_ref" == ".octon/state/evidence/runs/workflows/$RUN_ID/"* ]]; then
      return 0
    fi
  done < <(
    yq -r '.candidates[]?.proposal_program_handoff_authorization // {} | [.program_run_id // "", .classifier_output_ref // "", .interaction_request_ref // ""] | @tsv' "$report_path" 2>/dev/null || true
  )
  return 1
}

same_scope_closeout_worktree_return_ref() {
  local return_ref="$1"
  local required_report_ref="${2:-}"
  local return_path return_schema consumer completed report_ref expected_digest report_path actual_digest
  [[ -n "$RUN_ID" ]] || return 1
  command -v jq >/dev/null 2>&1 || return 1
  closeout_worktree_return_ref_location "$return_ref" || return 1
  repo_relative_file_exists "$return_ref" || return 1
  return_path="$ROOT_DIR/$return_ref"
  return_schema="$(jq -r '.schema_version // ""' "$return_path" 2>/dev/null || true)"
  [[ "$return_schema" == "lifecycle-interaction-return-v1" ]] || return 1
  consumer="$(jq -r '.consumer.lifecycle_id // ""' "$return_path" 2>/dev/null || true)"
  [[ "$consumer" == "closeout-worktree" ]] || return 1
  completed="$(jq -r 'if (.outcome.completed == true) then "true" else "" end' "$return_path" 2>/dev/null || true)"
  [[ "$completed" == "true" ]] || return 1

  while IFS=$'\t' read -r report_ref expected_digest; do
    [[ -n "$report_ref" ]] || continue
    [[ -z "$required_report_ref" || "$report_ref" == "$required_report_ref" ]] || continue
    closeout_worktree_report_ref_location "$report_ref" || continue
    repo_relative_file_exists "$report_ref" || continue
    report_path="$ROOT_DIR/$report_ref"
    [[ -n "$expected_digest" && "$expected_digest" != "null" ]] || continue
    actual_digest="$(file_sha256 "$report_path")"
    [[ "$actual_digest" == "$expected_digest" ]] || continue
    same_scope_closeout_worktree_report_ref "$report_ref" && return 0
  done < <(
    jq -r '.return_evidence_refs[]? | [.ref // "", .digest // ""] | @tsv' "$return_path" 2>/dev/null || true
  )
  return 1
}

same_scope_closeout_worktree_report_artifact() {
  local report_ref="$1"
  local search_root candidate_return
  closeout_worktree_report_ref_location "$report_ref" || return 1
  same_scope_closeout_worktree_report_ref "$report_ref" || return 1
  for search_root in \
    "$ROOT_DIR/.octon/state/evidence/runs/skills/closeout-worktree" \
    "$ROOT_DIR/.octon/state/evidence/runs/workflows"; do
    [[ -d "$search_root" ]] || continue
    while IFS= read -r candidate_return; do
      candidate_return="${candidate_return#"$ROOT_DIR/"}"
      same_scope_closeout_worktree_return_ref "$candidate_return" "$report_ref" && return 0
    done < <(find "$search_root" -type f \( -name 'lifecycle-interaction-return.json' -o -path '*/lifecycle-interactions/*closeout-worktree-return*.json' \) 2>/dev/null | sort)
  done
  return 1
}

same_scope_closeout_worktree_handoff_artifact() {
  local path="$1"
  if closeout_worktree_return_ref_location "$path"; then
    same_scope_closeout_worktree_return_ref "$path"
    return $?
  fi
  if closeout_worktree_report_ref_location "$path"; then
    same_scope_closeout_worktree_report_artifact "$path"
    return $?
  fi
  return 1
}

matches_current_run_acp_decision_log() {
  local path="$1"
  local diff added_lines line decision_run_id removed_count
  [[ "$path" == ".octon/state/evidence/decisions/repo/capabilities/acp-decisions.jsonl" ]] || return 1
  [[ -n "$RUN_ID" ]] || return 1
  git -C "$ROOT_DIR" ls-files --error-unmatch -- "$path" >/dev/null 2>&1 || return 1

  diff="$(git -C "$ROOT_DIR" diff --unified=0 -- "$path" 2>/dev/null || true)"
  [[ -n "$diff" ]] || return 1
  removed_count="$(printf '%s\n' "$diff" | awk 'substr($0,1,1) == "-" && substr($0,1,3) != "---" { c++ } END { print c+0 }')"
  [[ "$removed_count" == "0" ]] || return 1
  added_lines="$(printf '%s\n' "$diff" | awk 'substr($0,1,1) == "+" && substr($0,1,3) != "+++" { print substr($0,2) }')"
  [[ -n "$added_lines" ]] || return 1
  command -v jq >/dev/null 2>&1 || return 1

  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    decision_run_id="$(printf '%s\n' "$line" | jq -r '.run_id // ""' 2>/dev/null || true)"
    [[ "$decision_run_id" == "$RUN_ID" || "$decision_run_id" == "$RUN_ID-"* ]] || return 1
  done <<<"$added_lines"

  return 0
}

artifact_field_for_effective_id() {
  local effective_id="$1"
  local query="$2"
  local artifact_map="$ROOT_DIR/.octon/generated/effective/capabilities/artifact-map.yml"
  [[ -f "$artifact_map" ]] || return 1
  yq -r ".artifacts[]? | select(.effective_id == \"$effective_id\") | $query // \"\"" "$artifact_map" 2>/dev/null | head -n 1
}

extension_projection_source_path() {
  local pack_id="$1"
  local source_id="$2"
  local kind="$3"
  local capability_id="$4"
  local catalog="$ROOT_DIR/.octon/generated/effective/extensions/catalog.effective.yml"
  [[ -f "$catalog" ]] || return 1
  yq -r ".packs[]? | select(.pack_id == \"$pack_id\" and .source_id == \"$source_id\") | .routing_exports.${kind}s[]? | select(.capability_id == \"$capability_id\") | .projection_source_path // \"\"" "$catalog" 2>/dev/null | head -n 1
}

routed_projection_source_path() {
  local effective_id="$1"
  local kind="$2"
  local capability_id="$3"
  local source_kind source_path pack_id source_id

  source_kind="$(artifact_field_for_effective_id "$effective_id" '.source_kind' || true)"
  source_path="$(artifact_field_for_effective_id "$effective_id" '.source_path' || true)"
  if [[ "$source_kind" == "extension-export" ]]; then
    pack_id="$(artifact_field_for_effective_id "$effective_id" '.extension_pack_id' || true)"
    source_id="$(artifact_field_for_effective_id "$effective_id" '.extension_source_id' || true)"
    source_path="$(extension_projection_source_path "$pack_id" "$source_id" "$kind" "$capability_id" || true)"
    [[ "$source_path" == ".octon/generated/effective/extensions/published/"* ]] || return 1
  elif [[ "$kind" == "skill" && -n "$source_path" && "$source_path" != "null" ]]; then
    source_path="$(dirname "$source_path")"
  fi

  [[ -n "$source_path" && "$source_path" != "null" ]] || return 1
  normalize_path "$source_path"
}

in_scope_host_projection_mirror() {
  local path="$1"
  local host kind capability_id rel source_rel source_file routing_file
  case "$path" in
    .claude/skills/*/*|.codex/skills/*/*|.cursor/skills/*/*)
      host="${path#./}"
      host="${host#.*}"
      host="${host%%/*}"
      rel="${path#".${host}/skills/"}"
      capability_id="${rel%%/*}"
      rel="${rel#"$capability_id/"}"
      kind="skill"
      ;;
    .claude/commands/*.md|.codex/commands/*.md|.cursor/commands/*.md)
      host="${path#./}"
      host="${host#.*}"
      host="${host%%/*}"
      capability_id="${path#".${host}/commands/"}"
      capability_id="${capability_id%.md}"
      rel=""
      kind="command"
      ;;
    *)
      return 1
      ;;
  esac

  [[ -n "$host" && -n "$kind" && -n "$capability_id" ]] || return 1
  command -v yq >/dev/null 2>&1 || return 1
  routing_file="$ROOT_DIR/.octon/generated/effective/capabilities/routing.effective.yml"
  [[ -f "$routing_file" ]] || return 1

  local effective_ids=()
  local effective_id
  while IFS= read -r effective_id; do
    [[ -n "$effective_id" ]] || continue
    effective_ids+=("$effective_id")
  done < <(
    yq -r ".routing_candidates[]? | select(.status == \"active\") | select(.capability_kind == \"$kind\") | select(.capability_id == \"$capability_id\") | select((.host_adapters // []) | contains([\"$host\"])) | .effective_id // \"\"" "$routing_file" 2>/dev/null |
      awk 'NF'
  )
  [[ "${#effective_ids[@]}" -eq 1 ]] || return 1

  source_rel="$(routed_projection_source_path "${effective_ids[0]}" "$kind" "$capability_id")" || return 1
  matches_prefix_file "$source_rel" "$SCOPE_PREFIXES" || return 1
  if [[ "$kind" == "skill" ]]; then
    source_file="$source_rel/$rel"
  else
    source_file="$source_rel"
  fi
  [[ -f "$ROOT_DIR/$path" && -f "$ROOT_DIR/$source_file" ]] || return 1
  cmp -s "$ROOT_DIR/$path" "$ROOT_DIR/$source_file"
}

nonblocking_local_metadata() {
  local path="$1"
  local base="${path##*/}"
  case "$base" in
    .DS_Store|Thumbs.db|Desktop.ini|Icon?|._*)
      return 0
      ;;
  esac
  return 1
}

load_retained_fixture_receipts() {
  local validator receipt rel json
  validator="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-fixture-retention-closeout-receipt.sh"
  [[ -x "$validator" || -f "$validator" ]] || return 0
  command -v jq >/dev/null 2>&1 || return 0
  [[ -d "$ROOT_DIR/.octon/state/evidence/runs/workflows" ]] || return 0
  while IFS= read -r receipt; do
    [[ -f "$receipt" ]] || continue
    rel="$(normalize_path "$receipt")"
    if json="$(bash "$validator" --receipt "$rel" --emit-consumption-json 2>/dev/null)"; then
      printf '%s\n' "$json" | jq -r '.retained_status_entries[]? | [.status, .path] | @tsv' >>"$RETAINED_FIXTURE_SOURCE_ROWS"
      printf '%s\n' "$json" | jq -r '.receipt_ref // empty' >>"$RETAINED_FIXTURE_RECEIPTS"
    fi
  done < <(find "$ROOT_DIR/.octon/state/evidence/runs/workflows" -path '*fixture-retention-closeout*/retention-receipt.yml' -type f 2>/dev/null | sort)
  sort -u -o "$RETAINED_FIXTURE_SOURCE_ROWS" "$RETAINED_FIXTURE_SOURCE_ROWS" 2>/dev/null || true
  sort -u -o "$RETAINED_FIXTURE_RECEIPTS" "$RETAINED_FIXTURE_RECEIPTS" 2>/dev/null || true
}

matches_retained_fixture_receipt() {
  local status="$1"
  local path="$2"
  grep -Fxq "$status	$path" "$RETAINED_FIXTURE_SOURCE_ROWS"
}

yaml_quote() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  printf '"%s"' "$value"
}

emit_rows() {
  local file="$1"
  if [[ ! -s "$file" ]]; then
    printf '  []\n'
    return 0
  fi
  local status path
  while IFS=$'\t' read -r status path; do
    printf '  - status: '
    yaml_quote "$status"
    printf '\n    path: '
    yaml_quote "$path"
    printf '\n'
  done <"$file"
}

add_partition_row() {
  local file="$1"
  local source_bucket="$2"
  local status="$3"
  local path="$4"
  local reason="$5"
  printf '%s\t%s\t%s\t%s\n' "$source_bucket" "$status" "$path" "$reason" >>"$file"
}

emit_partition_rows() {
  local file="$1"
  if [[ ! -s "$file" ]]; then
    printf '    []\n'
    return 0
  fi
  local source_bucket status path reason
  while IFS=$'\t' read -r source_bucket status path reason; do
    printf '    - source_bucket: '
    yaml_quote "$source_bucket"
    printf '\n      status: '
    yaml_quote "$status"
    printf '\n      path: '
    yaml_quote "$path"
    printf '\n      reason: '
    yaml_quote "$reason"
    printf '\n'
  done <"$file"
}

target_support_evidence_path() {
  local path="$1"
  [[ "$path" == "$TARGET_REL/support" || "$path" == "$TARGET_REL/support/"* ]]
}

target_proposal_input_path() {
  local path="$1"
  [[ "$path" == "$TARGET_REL" || "$path" == "$TARGET_REL/"* ]]
}

target_packet_manifest_path() {
  local path="$1"
  [[ "$path" == "$TARGET_REL/proposal.yml" ]]
}

protected_retained_path() {
  local path="$1"
  case "$path" in
    .octon/state/evidence/*|.octon/state/evidence/local/terminal-closeout/*|.octon/state/evidence/validation/publication/build-to-delete/*)
      return 0
      ;;
  esac
  return 1
}

protected_control_path() {
  local path="$1"
  case "$path" in
    .octon/state/control/*|.octon/state/continuity/*)
      return 0
      ;;
  esac
  return 1
}

generated_or_input_protected_path() {
  local path="$1"
  case "$path" in
    .octon/generated/effective/*|.octon/generated/cognition/projections/materialized/runs/*|.octon/inputs/*)
      return 0
      ;;
  esac
  return 1
}

classify_partition_row() {
  local source_bucket="$1"
  local status="$2"
  local path="$3"

  case "$source_bucket" in
    owned_by_this_lifecycle_run)
      if nonblocking_local_metadata "$path"; then
        add_partition_row "$CLEANUP_SAFE_ROWS" "$source_bucket" "$status" "$path" "cleanup-safe local metadata only; detection is not deletion authority"
      elif protected_control_path "$path"; then
        add_partition_row "$PROTECTED_CONTROL_ROWS" "$source_bucket" "$status" "$path" "same-scope lifecycle control or continuity state; protected from cleanup"
      elif protected_retained_path "$path"; then
        add_partition_row "$PROTECTED_RETAINED_ROWS" "$source_bucket" "$status" "$path" "same-scope lifecycle evidence; retained evidence is not child authority and is protected from cleanup"
      else
        add_partition_row "$MANUAL_REVIEW_ROWS" "$source_bucket" "$status" "$path" "same-scope nonstandard lifecycle residue requires manual routing"
      fi
      ;;
    declared_in_scope_change)
      if archive_move_candidate_path "$status" "$path"; then
        add_partition_row "$PUBLISHABLE_CLOSEOUT_ROWS" "$source_bucket" "$status" "$path" "archive-move packet boundary authorized by archived manifest status, archive.original_path, absent active original path, and exact target/original path scope"
      elif target_support_evidence_path "$path"; then
        add_partition_row "$PUBLISHABLE_CLOSEOUT_ROWS" "$source_bucket" "$status" "$path" "child-owned support evidence for this target packet; proposal-local evidence is not runtime or policy authority"
      elif target_packet_manifest_path "$path"; then
        add_partition_row "$PUBLISHABLE_CLOSEOUT_ROWS" "$source_bucket" "$status" "$path" "child-owned target packet manifest state; proposal-local evidence is not runtime or policy authority"
      elif target_proposal_input_path "$path"; then
        add_partition_row "$MANUAL_REVIEW_ROWS" "$source_bucket" "$status" "$path" "target proposal input surface is in child scope but is not cleanup, support, runtime, policy, or closeout authority"
      elif generated_or_input_protected_path "$path"; then
        add_partition_row "$MANUAL_REVIEW_ROWS" "$source_bucket" "$status" "$path" "generated or input surface requires explicit publication or lifecycle routing; classifier output is not authority"
      else
        add_partition_row "$PUBLISHABLE_CHANGE_ROWS" "$source_bucket" "$status" "$path" "declared promotion target or same-scope durable change"
      fi
      ;;
    retained_by_fixture_retention)
      add_partition_row "$PROTECTED_RETAINED_ROWS" "$source_bucket" "$status" "$path" "fixture-retention receipt covers this residue; retained evidence is protected and non-authorizing"
      ;;
    foreign_or_ambiguous)
      add_partition_row "$MANUAL_REVIEW_ROWS" "$source_bucket" "$status" "$path" "foreign, ambiguous, unsafe, or user-owned residue blocks worktree hygiene"
      ;;
    *)
      add_partition_row "$MANUAL_REVIEW_ROWS" "$source_bucket" "$status" "$path" "unrecognized source bucket requires manual routing"
      ;;
  esac
}

build_partition_rows_from() {
  local source_bucket="$1"
  local file="$2"
  local status path
  while IFS=$'\t' read -r status path; do
    [[ -n "$status" && -n "$path" ]] || continue
    classify_partition_row "$source_bucket" "$status" "$path"
  done <"$file"
}

row_count() {
  local file="$1"
  if [[ ! -s "$file" ]]; then
    printf '0\n'
  else
    wc -l <"$file" | tr -d ' '
  fi
}

rows_sha256() {
  local file="$1"
  if [[ -s "$file" ]]; then
    LC_ALL=C sort "$file" | shasum -a 256 | awk '{print "sha256:" $1}'
  else
    printf '' | shasum -a 256 | awk '{print "sha256:" $1}'
  fi
}

add_prefix "$SCOPE_PREFIXES" "$TARGET_REL"
add_in_scope_from_manifest "$MANIFEST"
detect_archive_move_candidate
if [[ "$ARCHIVE_MOVE_CANDIDATE_AUTHORIZED" == "true" ]]; then
  add_prefix "$SCOPE_PREFIXES" "$ARCHIVE_MOVE_ORIGINAL_REL"
fi

PROPOSAL_ID=""
if command -v yq >/dev/null 2>&1; then
  PROPOSAL_ID="$(yq -r '.proposal_id // ""' "$MANIFEST" 2>/dev/null || true)"
fi
if [[ -n "$PROPOSAL_ID" && "$PROPOSAL_ID" != "null" ]]; then
  add_prefix "$SCOPE_PREFIXES" ".octon/state/evidence/validation/proposals/$PROPOSAL_ID"
fi

if [[ "$LIFECYCLE" == "proposal-program" ]]; then
  add_program_child_scope
  add_program_generated_scope
fi
add_program_scope_from_run_checkpoint
if [[ "$PROGRAM_RUN_CONTEXT_APPLIED" -eq 1 ]]; then
  add_program_generated_scope
fi

if [[ -n "$RUN_ID" ]]; then
  add_prefix "$OWNED_PREFIXES" ".octon/state/control/execution/runs/$RUN_ID"
  add_prefix "$OWNED_PREFIXES" ".octon/state/evidence/runs/workflows/$RUN_ID"
fi

load_retained_fixture_receipts

while IFS= read -r line; do
  [[ -n "$line" ]] || continue
  status="${line:0:2}"
  raw_path="${line:3}"
  case "$raw_path" in
    *" -> "*) raw_path="${raw_path##* -> }" ;;
  esac
  path="$(normalize_path "$raw_path")"
  if matches_prefix_file "$path" "$OWNED_PREFIXES" ||
    matches_current_run_artifact "$path" ||
    matches_target_closeout_skill_artifact "$path" ||
    same_scope_lifecycle_run_artifact "$path" ||
    same_scope_program_recovery_publish_artifact "$path" ||
    same_scope_repo_hygiene_cleanup_receipt "$path" ||
    same_scope_closeout_worktree_handoff_artifact "$path" ||
    matches_current_run_acp_decision_log "$path" ||
    nonblocking_local_metadata "$path"; then
    printf '%s\t%s\n' "$status" "$path" >>"$OWNED_ROWS"
  elif matches_retained_fixture_receipt "$status" "$path"; then
    printf '%s\t%s\n' "$status" "$path" >>"$RETAINED_FIXTURE_ROWS"
  elif matches_prefix_file "$path" "$SCOPE_PREFIXES" ||
    in_scope_host_projection_mirror "$path"; then
    printf '%s\t%s\n' "$status" "$path" >>"$SCOPE_ROWS"
  else
    printf '%s\t%s\n' "$status" "$path" >>"$FOREIGN_ROWS"
  fi
done < <(git -C "$ROOT_DIR" status --porcelain=v1 --untracked-files=all)

build_partition_rows_from "owned_by_this_lifecycle_run" "$OWNED_ROWS"
build_partition_rows_from "declared_in_scope_change" "$SCOPE_ROWS"
build_partition_rows_from "retained_by_fixture_retention" "$RETAINED_FIXTURE_ROWS"
build_partition_rows_from "foreign_or_ambiguous" "$FOREIGN_ROWS"
sort -u -o "$PUBLISHABLE_CHANGE_ROWS" "$PUBLISHABLE_CHANGE_ROWS" 2>/dev/null || true
sort -u -o "$PUBLISHABLE_CLOSEOUT_ROWS" "$PUBLISHABLE_CLOSEOUT_ROWS" 2>/dev/null || true
sort -u -o "$CLEANUP_SAFE_ROWS" "$CLEANUP_SAFE_ROWS" 2>/dev/null || true
sort -u -o "$PROTECTED_RETAINED_ROWS" "$PROTECTED_RETAINED_ROWS" 2>/dev/null || true
sort -u -o "$PROTECTED_CONTROL_ROWS" "$PROTECTED_CONTROL_ROWS" 2>/dev/null || true
sort -u -o "$MANUAL_REVIEW_ROWS" "$MANUAL_REVIEW_ROWS" 2>/dev/null || true

OWNED_COUNT="$(row_count "$OWNED_ROWS")"
SCOPE_COUNT="$(row_count "$SCOPE_ROWS")"
RETAINED_FIXTURE_COUNT="$(row_count "$RETAINED_FIXTURE_ROWS")"
FOREIGN_COUNT="$(row_count "$FOREIGN_ROWS")"
PUBLISHABLE_CHANGE_COUNT="$(row_count "$PUBLISHABLE_CHANGE_ROWS")"
PUBLISHABLE_CLOSEOUT_COUNT="$(row_count "$PUBLISHABLE_CLOSEOUT_ROWS")"
CLEANUP_SAFE_COUNT="$(row_count "$CLEANUP_SAFE_ROWS")"
PROTECTED_RETAINED_COUNT="$(row_count "$PROTECTED_RETAINED_ROWS")"
PROTECTED_CONTROL_COUNT="$(row_count "$PROTECTED_CONTROL_ROWS")"
MANUAL_REVIEW_COUNT="$(row_count "$MANUAL_REVIEW_ROWS")"
FOREIGN_FINGERPRINT="$(rows_sha256 "$FOREIGN_ROWS")"
if [[ "$FOREIGN_COUNT" -gt 0 ]]; then
  VERDICT="blocked"
  BLOCKER_CLASS="worktree-hygiene-blocked"
  NEXT_ROUTE="route through closeout-change or operator scope resolution before proposal archive authorization"
  HANDOFF_ROUTE="closeout-worktree"
  HANDOFF_REQUIRED="true"
else
  VERDICT="pass"
  BLOCKER_CLASS=""
  NEXT_ROUTE="continue proposal closeout validation and archive authorization checks"
  HANDOFF_ROUTE=""
  HANDOFF_REQUIRED="false"
fi

printf 'schema_version: "octon-proposal-worktree-hygiene-v1"\n'
printf 'target: '
yaml_quote "$TARGET_REL"
printf '\n'
printf 'lifecycle: '
yaml_quote "$LIFECYCLE"
printf '\n'
printf 'run_id: '
yaml_quote "$RUN_ID"
printf '\n'
printf 'archive_move_candidate_authorized: "%s"\n' "$ARCHIVE_MOVE_CANDIDATE_AUTHORIZED"
printf 'archive_move_original_path: '
yaml_quote "$ARCHIVE_MOVE_ORIGINAL_REL"
printf '\n'
printf 'worktree_hygiene_verdict: "%s"\n' "$VERDICT"
printf 'worktree_hygiene_blocker_class: "%s"\n' "$BLOCKER_CLASS"
printf 'worktree_hygiene_owned_path_count: %s\n' "$OWNED_COUNT"
printf 'worktree_hygiene_in_scope_path_count: %s\n' "$SCOPE_COUNT"
printf 'worktree_hygiene_retained_fixture_path_count: %s\n' "$RETAINED_FIXTURE_COUNT"
printf 'worktree_hygiene_foreign_path_count: %s\n' "$FOREIGN_COUNT"
printf 'worktree_hygiene_publishable_change_path_count: %s\n' "$PUBLISHABLE_CHANGE_COUNT"
printf 'worktree_hygiene_publishable_closeout_evidence_path_count: %s\n' "$PUBLISHABLE_CLOSEOUT_COUNT"
printf 'worktree_hygiene_cleanup_safe_path_count: %s\n' "$CLEANUP_SAFE_COUNT"
printf 'worktree_hygiene_protected_retained_evidence_path_count: %s\n' "$PROTECTED_RETAINED_COUNT"
printf 'worktree_hygiene_protected_active_control_path_count: %s\n' "$PROTECTED_CONTROL_COUNT"
printf 'worktree_hygiene_manual_review_path_count: %s\n' "$MANUAL_REVIEW_COUNT"
printf 'worktree_hygiene_foreign_fingerprint: "%s"\n' "$FOREIGN_FINGERPRINT"
printf 'worktree_hygiene_evidence: "git status --porcelain=v1 --untracked-files=all classified without mutation"\n'
printf 'worktree_hygiene_partition_authority: "classification-only; does not authorize deletion, cleanup, publication, promotion, archive, closeout, or cleaned claims"\n'
printf 'worktree_hygiene_handoff_required: "%s"\n' "$HANDOFF_REQUIRED"
printf 'worktree_hygiene_handoff_route: '
yaml_quote "$HANDOFF_ROUTE"
printf '\n'
printf 'worktree_hygiene_required_return_evidence: "closeout-worktree-report-v1"\n'
printf 'parent_summary_not_child_closeout_receipt: "true"\n'
printf 'child_closeout_authority_preserved: "true"\n'
printf 'next_route_condition: '
yaml_quote "$NEXT_ROUTE"
printf '\n'
cat <<'EOF'
worktree_hygiene_partitions:
  publishable_changes:
EOF
emit_partition_rows "$PUBLISHABLE_CHANGE_ROWS"
cat <<'EOF'
  publishable_closeout_evidence:
EOF
emit_partition_rows "$PUBLISHABLE_CLOSEOUT_ROWS"
cat <<'EOF'
  cleanup_safe_local_residue:
EOF
emit_partition_rows "$CLEANUP_SAFE_ROWS"
cat <<'EOF'
  protected_retained_evidence:
EOF
emit_partition_rows "$PROTECTED_RETAINED_ROWS"
cat <<'EOF'
  protected_active_control_state:
EOF
emit_partition_rows "$PROTECTED_CONTROL_ROWS"
cat <<'EOF'
  manual_review_foreign_ambiguous_unsafe_or_user_owned:
EOF
emit_partition_rows "$MANUAL_REVIEW_ROWS"
printf 'owned_by_this_lifecycle_run:\n'
emit_rows "$OWNED_ROWS"
cat <<'EOF'
declared_in_scope_change:
EOF
emit_rows "$SCOPE_ROWS"
cat <<'EOF'
retained_by_fixture_retention:
EOF
emit_rows "$RETAINED_FIXTURE_ROWS"
cat <<'EOF'
fixture_retention_receipts:
EOF
if [[ ! -s "$RETAINED_FIXTURE_RECEIPTS" ]]; then
  printf '  []\n'
else
  while IFS= read -r receipt_ref; do
    printf '  - '
    yaml_quote "$receipt_ref"
    printf '\n'
  done <"$RETAINED_FIXTURE_RECEIPTS"
fi
cat <<'EOF'
foreign_or_ambiguous:
EOF
emit_rows "$FOREIGN_ROWS"
