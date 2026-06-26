#!/usr/bin/env bash
set -euo pipefail

REPO_PATH=""
CHECK_INDEX=0
CHECK_REF=0
EVIDENCE_PATH=""
REQUIRE_CLEAN_ROUTE_CLASSIFICATION=0
INCLUDE_PATH_CLASSIFICATION=""
BASE_REF="origin/main"

usage() {
  cat <<'USAGE'
Usage:
  git-branch-mutation-preflight.sh [--repo <path>] [--check-index] [--check-ref] [--evidence <path>] [--require-clean-route-classification] [--include-path-classification <path>] [--base-ref <ref>]

Rollback-safe git mutation capability preflight.

Behavior:
  - checks index lock creation before branch-local staging/commit;
  - checks temporary ref creation/deletion before push, landing, sync, or cleanup;
  - when requested, blocks dirty or stale source posture unless include-path
    classification selects a route-owned clean worktree;
  - emits typed blockers such as git-index-write-denied or git-ref-write-denied;
  - never authorizes delivery, landing, sync, cleanup, or branch deletion.
USAGE
}

error() {
  echo "[ERROR] $1" >&2
  exit 2
}

json_escape() {
  jq -Rsa . <<<"$1"
}

repo_root() {
  local path="$1"
  git -C "$path" rev-parse --show-toplevel 2>/dev/null || true
}

git_common_dir() {
  local root="$1" raw
  raw="$(git -C "$root" rev-parse --git-common-dir 2>/dev/null || true)"
  [[ -n "$raw" ]] || return 1
  case "$raw" in
    /*) printf '%s\n' "$raw" ;;
    *) printf '%s/%s\n' "$root" "$raw" ;;
  esac
}

git_path() {
  local root="$1" pathspec="$2" raw
  raw="$(git -C "$root" rev-parse --git-path "$pathspec" 2>/dev/null || true)"
  [[ -n "$raw" ]] || return 1
  case "$raw" in
    /*) printf '%s\n' "$raw" ;;
    *) printf '%s/%s\n' "$root" "$raw" ;;
  esac
}

emit_evidence() {
  local status="$1" blocker_class="$2" index_status="$3" index_blocker="$4" index_detail="$5" ref_status="$6" ref_blocker="$7" ref_detail="$8"
  [[ -n "$EVIDENCE_PATH" ]] || return 0

  local branch head emitted_at
  branch="$(git -C "$REPO_ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
  head="$(git -C "$REPO_ROOT" rev-parse --verify HEAD 2>/dev/null || true)"
  emitted_at="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  mkdir -p -- "$(dirname -- "$EVIDENCE_PATH")"
  jq -n \
    --arg schema_version "git-mutation-preflight-v1" \
    --arg emitted_at "$emitted_at" \
    --arg repo_root "$REPO_ROOT" \
    --arg git_common_dir "$GIT_COMMON_DIR" \
    --arg status "$status" \
    --arg blocker_class "$blocker_class" \
    --arg branch "$branch" \
    --arg head "$head" \
    --arg index_status "$index_status" \
    --arg index_blocker "$index_blocker" \
    --arg index_detail "$index_detail" \
    --arg ref_status "$ref_status" \
    --arg ref_blocker "$ref_blocker" \
    --arg ref_detail "$ref_detail" \
    --argjson source_dirty "$SOURCE_DIRTY_JSON" \
    --argjson source_stale "$SOURCE_STALE_JSON" \
    --arg source_base_ref "$BASE_REF" \
    --arg clean_route "$CLEAN_ROUTE_SELECTION" \
    --arg include_path_classification "$INCLUDE_PATH_CLASSIFICATION" \
    --argjson include_path_classification_present "$INCLUDE_PATH_CLASSIFICATION_PRESENT_JSON" \
    --argjson route_owned_clean_worktree_required "$ROUTE_OWNED_CLEAN_WORKTREE_REQUIRED_JSON" \
    '{
      schema_version: $schema_version,
      emitted_at: $emitted_at,
      repo_root: $repo_root,
      git_common_dir: $git_common_dir,
      status: $status,
      blocker_class: (if $blocker_class == "" then null else $blocker_class end),
      current_branch: $branch,
      head_ref: $head,
      rollback_safe: true,
      non_authorizing: true,
      authority_effects: {
        delivery: false,
        landing: false,
        sync: false,
        cleanup: false,
        branch_deletion: false
      },
      source_posture: {
        dirty: $source_dirty,
        stale_against_base: $source_stale,
        base_ref: $source_base_ref
      },
      clean_worktree_route: {
        selected_route: $clean_route,
        route_owned_clean_worktree_required: $route_owned_clean_worktree_required,
        include_path_classification_ref: $include_path_classification,
        include_path_classification_present: $include_path_classification_present
      },
      checks: {
        index: {
          requested: ($index_status != "not-requested"),
          status: $index_status,
          blocker_class: (if $index_blocker == "" then null else $index_blocker end),
          detail: $index_detail
        },
        ref: {
          requested: ($ref_status != "not-requested"),
          status: $ref_status,
          blocker_class: (if $ref_blocker == "" then null else $ref_blocker end),
          detail: $ref_detail
        }
      }
    }' >"$EVIDENCE_PATH"
}

bool_json() {
  [[ "$1" == "1" ]] && printf 'true' || printf 'false'
}

classification_path_exists() {
  local ref="$1"
  [[ -n "$ref" ]] || return 1
  case "$ref" in
    /*) [[ -f "$ref" ]] ;;
    *) [[ -f "$REPO_ROOT/$ref" ]] ;;
  esac
}

check_clean_route_classification() {
  local status_output
  status_output="$(git -C "$REPO_ROOT" status --porcelain=v1 2>/dev/null || true)"
  if [[ -n "$status_output" ]]; then
    SOURCE_DIRTY=1
  fi
  if git -C "$REPO_ROOT" rev-parse --verify "$BASE_REF" >/dev/null 2>&1; then
    if ! git -C "$REPO_ROOT" merge-base --is-ancestor "$BASE_REF" HEAD >/dev/null 2>&1; then
      SOURCE_STALE=1
    fi
  fi

  if [[ "$SOURCE_DIRTY" -eq 1 || "$SOURCE_STALE" -eq 1 ]]; then
    ROUTE_OWNED_CLEAN_WORKTREE_REQUIRED=1
    CLEAN_ROUTE_SELECTION="route-owned-clean-worktree"
  else
    CLEAN_ROUTE_SELECTION="current-clean-worktree"
  fi

  if classification_path_exists "$INCLUDE_PATH_CLASSIFICATION"; then
    INCLUDE_PATH_CLASSIFICATION_PRESENT=1
  fi

  if [[ "$REQUIRE_CLEAN_ROUTE_CLASSIFICATION" -eq 1 && "$ROUTE_OWNED_CLEAN_WORKTREE_REQUIRED" -eq 1 && "$INCLUDE_PATH_CLASSIFICATION_PRESENT" -ne 1 ]]; then
    CLEAN_ROUTE_STATUS="blocked"
    CLEAN_ROUTE_SELECTION="blocked"
    if [[ "$SOURCE_DIRTY" -eq 1 ]]; then
      CLEAN_ROUTE_BLOCKER="worktree-dirty-unclassified"
      CLEAN_ROUTE_DETAIL="dirty source posture requires route-owned clean worktree and include-path classification"
    else
      CLEAN_ROUTE_BLOCKER="source-branch-stale-unclassified"
      CLEAN_ROUTE_DETAIL="stale source posture requires route-owned clean worktree and include-path classification"
    fi
    return 1
  fi

  CLEAN_ROUTE_STATUS="passed"
  CLEAN_ROUTE_DETAIL="clean route classification requirements satisfied"
  return 0
}

need_tool() {
  command -v "$1" >/dev/null 2>&1 || error "$1 is required"
}

check_index_write() {
  local lock_path
  lock_path="$(git_path "$REPO_ROOT" "index.lock")" || {
    INDEX_STATUS="blocked"
    INDEX_BLOCKER="git-index-write-denied"
    INDEX_DETAIL="cannot resolve git index lock path"
    return 1
  }

  if [[ -e "$lock_path" ]]; then
    INDEX_STATUS="blocked"
    INDEX_BLOCKER="git-index-lock-present"
    INDEX_DETAIL="index lock already exists: $lock_path"
    return 1
  fi

  if ( set -C; : >"$lock_path" ) 2>/dev/null; then
    rm -f -- "$lock_path"
    INDEX_STATUS="passed"
    INDEX_DETAIL="created and removed index lock probe"
    return 0
  fi

  INDEX_STATUS="blocked"
  INDEX_BLOCKER="git-index-write-denied"
  INDEX_DETAIL="cannot create git index lock probe: $lock_path"
  return 1
}

check_ref_write() {
  local head tmp_ref tmp_err
  head="$(git -C "$REPO_ROOT" rev-parse --verify HEAD 2>/dev/null || true)"
  if [[ -z "$head" ]]; then
    REF_STATUS="blocked"
    REF_BLOCKER="git-ref-write-denied"
    REF_DETAIL="cannot resolve HEAD for ref write preflight"
    return 1
  fi

  tmp_ref="refs/octon/preflight/$(date -u +%Y%m%dT%H%M%SZ)-$$"
  tmp_err="$(mktemp "${TMPDIR:-/tmp}/git-ref-preflight.XXXXXX")"
  if git -C "$REPO_ROOT" update-ref "$tmp_ref" "$head" 2>"$tmp_err"; then
    if git -C "$REPO_ROOT" update-ref -d "$tmp_ref" 2>>"$tmp_err"; then
      REF_STATUS="passed"
      REF_DETAIL="created and deleted temporary ref $tmp_ref"
      rm -f -- "$tmp_err"
      return 0
    fi
    REF_STATUS="blocked"
    REF_BLOCKER="git-ref-rollback-failed"
    REF_DETAIL="$(tr '\n' ' ' <"$tmp_err")"
    rm -f -- "$tmp_err"
    return 1
  fi

  REF_STATUS="blocked"
  REF_BLOCKER="git-ref-write-denied"
  REF_DETAIL="$(tr '\n' ' ' <"$tmp_err")"
  rm -f -- "$tmp_err"
  return 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      shift
      [[ $# -gt 0 ]] || error "--repo requires a value"
      REPO_PATH="$1"
      ;;
    --check-index)
      CHECK_INDEX=1
      ;;
    --check-ref)
      CHECK_REF=1
      ;;
    --evidence)
      shift
      [[ $# -gt 0 ]] || error "--evidence requires a value"
      EVIDENCE_PATH="$1"
      ;;
    --require-clean-route-classification)
      REQUIRE_CLEAN_ROUTE_CLASSIFICATION=1
      ;;
    --include-path-classification)
      shift
      [[ $# -gt 0 ]] || error "--include-path-classification requires a value"
      INCLUDE_PATH_CLASSIFICATION="$1"
      ;;
    --base-ref)
      shift
      [[ $# -gt 0 ]] || error "--base-ref requires a value"
      BASE_REF="$1"
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

need_tool jq

[[ "$CHECK_INDEX" -eq 1 || "$CHECK_REF" -eq 1 ]] || {
  CHECK_INDEX=1
  CHECK_REF=1
}

[[ -n "$REPO_PATH" ]] || REPO_PATH="."
REPO_ROOT="$(repo_root "$REPO_PATH")"
[[ -n "$REPO_ROOT" ]] || error "Run this command from inside a git repository or pass --repo."
GIT_COMMON_DIR="$(git_common_dir "$REPO_ROOT")" || error "Unable to resolve git common dir."

INDEX_STATUS="not-requested"
INDEX_BLOCKER=""
INDEX_DETAIL=""
REF_STATUS="not-requested"
REF_BLOCKER=""
REF_DETAIL=""
CLEAN_ROUTE_STATUS="not-requested"
CLEAN_ROUTE_BLOCKER=""
CLEAN_ROUTE_DETAIL=""
CLEAN_ROUTE_SELECTION="not-required"
SOURCE_DIRTY=0
SOURCE_STALE=0
INCLUDE_PATH_CLASSIFICATION_PRESENT=0
ROUTE_OWNED_CLEAN_WORKTREE_REQUIRED=0
STATUS="passed"
BLOCKER_CLASS=""

if [[ "$REQUIRE_CLEAN_ROUTE_CLASSIFICATION" -eq 1 ]]; then
  if ! check_clean_route_classification; then
    STATUS="blocked"
    BLOCKER_CLASS="$CLEAN_ROUTE_BLOCKER"
  fi
fi

SOURCE_DIRTY_JSON="$(bool_json "$SOURCE_DIRTY")"
SOURCE_STALE_JSON="$(bool_json "$SOURCE_STALE")"
INCLUDE_PATH_CLASSIFICATION_PRESENT_JSON="$(bool_json "$INCLUDE_PATH_CLASSIFICATION_PRESENT")"
ROUTE_OWNED_CLEAN_WORKTREE_REQUIRED_JSON="$(bool_json "$ROUTE_OWNED_CLEAN_WORKTREE_REQUIRED")"

if [[ "$STATUS" == "passed" && "$CHECK_INDEX" -eq 1 ]]; then
  if ! check_index_write; then
    STATUS="blocked"
    BLOCKER_CLASS="$INDEX_BLOCKER"
  fi
fi

if [[ "$STATUS" == "passed" && "$CHECK_REF" -eq 1 ]]; then
  if ! check_ref_write; then
    STATUS="blocked"
    BLOCKER_CLASS="$REF_BLOCKER"
  fi
fi

emit_evidence "$STATUS" "$BLOCKER_CLASS" "$INDEX_STATUS" "$INDEX_BLOCKER" "$INDEX_DETAIL" "$REF_STATUS" "$REF_BLOCKER" "$REF_DETAIL"

if [[ "$STATUS" == "passed" ]]; then
  echo "[OK] Git mutation preflight passed."
  echo "[OK] Repo: $REPO_ROOT"
  [[ "$CHECK_INDEX" -eq 1 ]] && echo "[OK] git index write probe passed."
  [[ "$CHECK_REF" -eq 1 ]] && echo "[OK] git ref write probe passed."
  exit 0
fi

echo "[ERROR] Git mutation preflight blocked: $BLOCKER_CLASS" >&2
[[ -n "$CLEAN_ROUTE_BLOCKER" ]] && echo "[ERROR] clean-route blocker: $CLEAN_ROUTE_BLOCKER - $CLEAN_ROUTE_DETAIL" >&2
[[ -n "$INDEX_BLOCKER" ]] && echo "[ERROR] index blocker: $INDEX_BLOCKER - $INDEX_DETAIL" >&2
[[ -n "$REF_BLOCKER" ]] && echo "[ERROR] ref blocker: $REF_BLOCKER - $REF_DETAIL" >&2
[[ -n "$EVIDENCE_PATH" ]] && echo "[ERROR] evidence: $EVIDENCE_PATH" >&2
exit 1
