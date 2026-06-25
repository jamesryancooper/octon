#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"

SOURCE_ROOT=""
BASE_REF="origin/main"
FORMAT="yaml"
FOREIGN_SCAN="full"
INCLUDE_PATHS=()
EXCLUDE_PATHS=()

usage() {
  cat <<'USAGE'
usage:
  classify-implementation-surface-closeout.sh --source-root <dirty-root> \
    --base-ref <ref> --include <path> [--include <path> ...] \
    [--exclude <path> ...] [--format yaml]
    [--foreign-scan full|none]

Read-only classifier for a stale implementation-surface closeout candidate.
It compares candidate paths from a dirty source worktree against a current base
ref and partitions only the requested include boundary. Detection never
authorizes deletion.
USAGE
}

fail() {
  echo "[ERROR] $1" >&2
  exit 2
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --source-root)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      SOURCE_ROOT="$1"
      ;;
    --base-ref)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      BASE_REF="$1"
      ;;
    --include)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      INCLUDE_PATHS+=("$1")
      ;;
    --exclude)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      EXCLUDE_PATHS+=("$1")
      ;;
    --format)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      FORMAT="$1"
      ;;
    --foreign-scan)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      FOREIGN_SCAN="$1"
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

[[ -n "$SOURCE_ROOT" ]] || { usage >&2; exit 2; }
[[ ${#INCLUDE_PATHS[@]} -gt 0 ]] || fail "at least one --include path is required"
[[ "$FORMAT" == "yaml" ]] || fail "only --format yaml is supported"
case "$FOREIGN_SCAN" in
  full|none) ;;
  *) fail "unsupported --foreign-scan value: $FOREIGN_SCAN" ;;
esac

SOURCE_ROOT="$(git -C "$SOURCE_ROOT" rev-parse --show-toplevel 2>/dev/null)" || fail "SOURCE_ROOT is not a git repository"
git -C "$SOURCE_ROOT" rev-parse --verify "$BASE_REF^{commit}" >/dev/null 2>&1 || fail "base ref is not a commit: $BASE_REF"
MERGE_BASE="$(git -C "$SOURCE_ROOT" merge-base HEAD "$BASE_REF" 2>/dev/null || true)"
[[ -n "$MERGE_BASE" ]] || fail "could not resolve merge-base between source HEAD and $BASE_REF"

normalize_path() {
  local path="$1"
  case "$path" in
    "$SOURCE_ROOT"/*) path="${path#"$SOURCE_ROOT"/}" ;;
  esac
  path="${path#./}"
  while [[ "$path" == */ && "$path" != "/" ]]; do
    path="${path%/}"
  done
  printf '%s\n' "$path"
}

path_has_prefix() {
  local path="$1"
  local prefix="${2%/}"
  [[ "$path" == "$prefix" || "$path" == "$prefix/"* ]]
}

INCLUDE_PREFIXES="$(mktemp "${TMPDIR:-/tmp}/implementation-surface-include-prefixes.XXXXXX")"
EXCLUDE_PREFIXES="$(mktemp "${TMPDIR:-/tmp}/implementation-surface-exclude-prefixes.XXXXXX")"
for include in "${INCLUDE_PATHS[@]}"; do
  normalize_path "$include" >>"$INCLUDE_PREFIXES"
done
for exclude in "${EXCLUDE_PATHS[@]}"; do
  normalize_path "$exclude" >>"$EXCLUDE_PREFIXES"
done

is_included() {
  local path="$1"
  local prefix
  for prefix in "${INCLUDE_PATHS[@]}"; do
    prefix="$(normalize_path "$prefix")"
    if path_has_prefix "$path" "$prefix"; then
      return 0
    fi
  done
  return 1
}

is_excluded() {
  local path="$1"
  local prefix
  for prefix in "${EXCLUDE_PATHS[@]}"; do
    prefix="$(normalize_path "$prefix")"
    if path_has_prefix "$path" "$prefix"; then
      return 0
    fi
  done
  return 1
}

yaml_dq() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  printf '"%s"' "$value"
}

ref_has_path() {
  local ref="$1"
  local path="$2"
  git -C "$SOURCE_ROOT" cat-file -e "$ref:$path" 2>/dev/null
}

source_has_path() {
  local path="$1"
  [[ -e "$SOURCE_ROOT/$path" && ! -d "$SOURCE_ROOT/$path" ]]
}

source_matches_ref() {
  local ref="$1"
  local path="$2"
  source_has_path "$path" || return 1
  ref_has_path "$ref" "$path" || return 1
  git -C "$SOURCE_ROOT" show "$ref:$path" | cmp -s - "$SOURCE_ROOT/$path"
}

is_untracked_path() {
  local path="$1"
  git -C "$SOURCE_ROOT" ls-files --others --exclude-standard -- "$path" | grep -Fxq -- "$path"
}

merge_to_base_is_clean() {
  local path="$1"
  local tmpdir ancestor current candidate
  ref_has_path "$MERGE_BASE" "$path" || return 1
  ref_has_path "$BASE_REF" "$path" || return 1
  source_has_path "$path" || return 1
  tmpdir="$(mktemp -d "${TMPDIR:-/tmp}/implementation-surface-merge.XXXXXX")"
  ancestor="$tmpdir/ancestor"
  current="$tmpdir/current"
  candidate="$tmpdir/candidate"
  git -C "$SOURCE_ROOT" show "$MERGE_BASE:$path" >"$ancestor"
  git -C "$SOURCE_ROOT" show "$BASE_REF:$path" >"$current"
  cp "$SOURCE_ROOT/$path" "$candidate"
  if git merge-file -p "$current" "$ancestor" "$candidate" >/dev/null 2>&1; then
    rm -r -- "$tmpdir"
    return 0
  fi
  rm -r -- "$tmpdir"
  return 1
}

collect_paths() {
  local mode="$1"
  {
    git -C "$SOURCE_ROOT" diff --name-only "$BASE_REF" 2>/dev/null || true
    git -C "$SOURCE_ROOT" diff --name-only --cached 2>/dev/null || true
    git -C "$SOURCE_ROOT" diff --name-only 2>/dev/null || true
    git -C "$SOURCE_ROOT" ls-files --others --exclude-standard 2>/dev/null || true
  } | awk 'NF { print }' | sort -u | case "$mode" in
    candidate)
      awk '
        NR == FNR {
          prefixes[++prefix_count] = $0
          next
        }
        {
          for (i = 1; i <= prefix_count; i++) {
            prefix = prefixes[i]
            if ($0 == prefix || index($0, prefix "/") == 1) {
              print
              next
            }
          }
        }
      ' "$INCLUDE_PREFIXES" -
      ;;
    all)
      cat
      ;;
  esac
}

TARGET_ROWS="$(mktemp "${TMPDIR:-/tmp}/implementation-surface-target.XXXXXX")"
ALREADY_ROWS="$(mktemp "${TMPDIR:-/tmp}/implementation-surface-already.XXXXXX")"
STALE_ROWS="$(mktemp "${TMPDIR:-/tmp}/implementation-surface-stale.XXXXXX")"
DELETION_ROWS="$(mktemp "${TMPDIR:-/tmp}/implementation-surface-deletion.XXXXXX")"
UNTRACKED_OVERLAP_ROWS="$(mktemp "${TMPDIR:-/tmp}/implementation-surface-untracked-overlap.XXXXXX")"
FOREIGN_SAMPLE_ROWS="$(mktemp "${TMPDIR:-/tmp}/implementation-surface-foreign.XXXXXX")"
trap 'rm -f "$INCLUDE_PREFIXES" "$EXCLUDE_PREFIXES" "$TARGET_ROWS" "$ALREADY_ROWS" "$STALE_ROWS" "$DELETION_ROWS" "$UNTRACKED_OVERLAP_ROWS" "$FOREIGN_SAMPLE_ROWS"' EXIT

target_count=0
already_count=0
stale_count=0
deletion_count=0
untracked_overlap_count=0
candidate_path_count=0
foreign_count=0
foreign_sample_count=0

record_row() {
  local file="$1"
  local path="$2"
  local reason="$3"
  printf '%s\t%s\n' "$path" "$reason" >>"$file"
}

while IFS= read -r path; do
  [[ -n "$path" ]] || continue
  path="$(normalize_path "$path")"
  candidate_path_count=$((candidate_path_count + 1))

  if is_excluded "$path"; then
    foreign_count=$((foreign_count + 1))
    if [[ $foreign_sample_count -lt 50 ]]; then
      record_row "$FOREIGN_SAMPLE_ROWS" "$path" "inside explicit exclude boundary"
      foreign_sample_count=$((foreign_sample_count + 1))
    fi
    continue
  fi

  source_exists=false
  base_exists=false
  head_exists=false
  untracked=false
  source_has_path "$path" && source_exists=true
  ref_has_path "$BASE_REF" "$path" && base_exists=true
  ref_has_path HEAD "$path" && head_exists=true
  is_untracked_path "$path" && untracked=true

  if [[ "$source_exists" == false && "$base_exists" == true ]]; then
    deletion_count=$((deletion_count + 1))
    record_row "$DELETION_ROWS" "$path" "path exists on current base ref but is absent from dirty source; deletion requires explicit proof"
  elif [[ "$source_exists" == true && "$base_exists" == true ]] && source_matches_ref "$BASE_REF" "$path"; then
    already_count=$((already_count + 1))
    record_row "$ALREADY_ROWS" "$path" "dirty source content matches current base ref"
  elif [[ "$source_exists" == true && "$base_exists" == true && "$untracked" == true ]]; then
    untracked_overlap_count=$((untracked_overlap_count + 1))
    record_row "$UNTRACKED_OVERLAP_ROWS" "$path" "path is untracked in dirty source but tracked on current base ref with different content"
  elif [[ "$source_exists" == true && "$base_exists" == true && "$head_exists" == true ]]; then
    if merge_to_base_is_clean "$path"; then
      target_count=$((target_count + 1))
      record_row "$TARGET_ROWS" "$path" "tracked source change merges cleanly from source merge-base onto current base ref"
    else
      stale_count=$((stale_count + 1))
      record_row "$STALE_ROWS" "$path" "tracked source change conflicts with current base ref or cannot be cleanly replayed"
    fi
  elif [[ "$source_exists" == true && "$base_exists" == false && "$untracked" == true ]]; then
    target_count=$((target_count + 1))
    record_row "$TARGET_ROWS" "$path" "new untracked implementation file inside include boundary and absent from current base ref"
  elif [[ "$source_exists" == true && "$base_exists" == false && "$head_exists" == true ]]; then
    stale_count=$((stale_count + 1))
    record_row "$STALE_ROWS" "$path" "source path comes from stale branch history but is absent from current base ref"
  else
    stale_count=$((stale_count + 1))
    record_row "$STALE_ROWS" "$path" "path state cannot prove ownership or freshness"
  fi
done < <(collect_paths candidate "${INCLUDE_PATHS[@]}")

if [[ "$FOREIGN_SCAN" == "full" ]]; then
  while IFS= read -r path; do
    [[ -n "$path" ]] || continue
    path="$(normalize_path "$path")"
    if ! is_included "$path" || is_excluded "$path"; then
      foreign_count=$((foreign_count + 1))
      if [[ $foreign_sample_count -lt 50 ]]; then
        if is_excluded "$path"; then
          record_row "$FOREIGN_SAMPLE_ROWS" "$path" "inside explicit exclude boundary"
        else
          record_row "$FOREIGN_SAMPLE_ROWS" "$path" "outside candidate include boundary"
        fi
        foreign_sample_count=$((foreign_sample_count + 1))
      fi
    fi
  done < <(collect_paths all)
fi

blocked_count=$((stale_count + deletion_count + untracked_overlap_count))
candidate_authorized=false
candidate_noop=false
candidate_verdict="blocked"
if [[ $blocked_count -eq 0 && $target_count -gt 0 ]]; then
  candidate_authorized=true
  candidate_verdict="pass"
elif [[ $blocked_count -eq 0 && $target_count -eq 0 ]]; then
  candidate_noop=true
  candidate_verdict="noop"
fi

emit_path_rows() {
  local file="$1"
  local indent="$2"
  local path reason
  if [[ ! -s "$file" ]]; then
    printf '%s[]\n' "$indent"
    return
  fi
  printf '%s\n' "$indent"
  while IFS=$'\t' read -r path reason; do
    printf '%s- path: ' "$indent"
    yaml_dq "$path"
    printf '\n%s  reason: ' "$indent"
    yaml_dq "$reason"
    printf '\n'
  done <"$file"
}

echo 'schema_version: "implementation-surface-closeout-classification-v1"'
echo "read_only: true"
echo "detection_is_deletion_authority: false"
echo "source_root: $(yaml_dq "$SOURCE_ROOT")"
echo "source_head: $(yaml_dq "$(git -C "$SOURCE_ROOT" rev-parse HEAD)")"
echo "base_ref: $(yaml_dq "$BASE_REF")"
echo "base_ref_commit: $(yaml_dq "$(git -C "$SOURCE_ROOT" rev-parse "$BASE_REF")")"
echo "merge_base: $(yaml_dq "$MERGE_BASE")"
echo "foreign_scan: $(yaml_dq "$FOREIGN_SCAN")"
echo "candidate_verdict: $(yaml_dq "$candidate_verdict")"
echo "candidate_authorized: $candidate_authorized"
echo "candidate_noop: $candidate_noop"
echo "include_paths:"
for include in "${INCLUDE_PATHS[@]}"; do
  printf '  - '
  yaml_dq "$(normalize_path "$include")"
  printf '\n'
done
echo "exclude_paths:"
for exclude in "${EXCLUDE_PATHS[@]}"; do
  printf '  - '
  yaml_dq "$(normalize_path "$exclude")"
  printf '\n'
done
echo "partitions:"
echo "  target_owned_implementation_changes:"
echo "    count: $target_count"
printf '    paths: '
emit_path_rows "$TARGET_ROWS" "    "
echo "  already_integrated_changes:"
echo "    count: $already_count"
printf '    paths: '
emit_path_rows "$ALREADY_ROWS" "    "
echo "  stale_or_superseded_changes:"
echo "    count: $stale_count"
printf '    paths: '
emit_path_rows "$STALE_ROWS" "    "
echo "  deletion_candidates_requiring_explicit_proof:"
echo "    count: $deletion_count"
printf '    paths: '
emit_path_rows "$DELETION_ROWS" "    "
echo "  untracked_files_tracked_on_current_base:"
echo "    count: $untracked_overlap_count"
printf '    paths: '
emit_path_rows "$UNTRACKED_OVERLAP_ROWS" "    "
echo "  foreign_or_unrelated_residue:"
echo "    count: $foreign_count"
echo "    sample_limit: 50"
if [[ "$FOREIGN_SCAN" == "none" ]]; then
  echo "    note: \"foreign scan skipped for refined exact-boundary proof; use a paired broad classifier output for full foreign-residue partitioning\""
fi
printf '    sample_paths: '
emit_path_rows "$FOREIGN_SAMPLE_ROWS" "    "
echo "summary:"
echo "  candidate_path_count: $candidate_path_count"
echo "  blocked_path_count: $blocked_count"
echo "  target_owned_path_count: $target_count"
echo "  already_integrated_path_count: $already_count"
echo "  stale_or_superseded_path_count: $stale_count"
echo "  deletion_candidate_path_count: $deletion_count"
echo "  untracked_tracked_on_current_base_path_count: $untracked_overlap_count"
echo "  foreign_or_unrelated_residue_path_count: $foreign_count"
