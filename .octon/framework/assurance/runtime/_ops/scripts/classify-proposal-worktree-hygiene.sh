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
FOREIGN_ROWS="$(mktemp "${TMPDIR:-/tmp}/octon-hygiene-foreign-rows.XXXXXX")"
trap 'rm -f "$OWNED_PREFIXES" "$SCOPE_PREFIXES" "$OWNED_ROWS" "$SCOPE_ROWS" "$FOREIGN_ROWS"' EXIT

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
    same_scope_repo_hygiene_cleanup_receipt "$path" ||
    nonblocking_local_metadata "$path"; then
    printf '%s\t%s\n' "$status" "$path" >>"$OWNED_ROWS"
  elif matches_prefix_file "$path" "$SCOPE_PREFIXES" ||
    in_scope_host_projection_mirror "$path"; then
    printf '%s\t%s\n' "$status" "$path" >>"$SCOPE_ROWS"
  else
    printf '%s\t%s\n' "$status" "$path" >>"$FOREIGN_ROWS"
  fi
done < <(git -C "$ROOT_DIR" status --porcelain=v1 --untracked-files=all)

OWNED_COUNT="$(row_count "$OWNED_ROWS")"
SCOPE_COUNT="$(row_count "$SCOPE_ROWS")"
FOREIGN_COUNT="$(row_count "$FOREIGN_ROWS")"
FOREIGN_FINGERPRINT="$(rows_sha256 "$FOREIGN_ROWS")"
if [[ "$FOREIGN_COUNT" -gt 0 ]]; then
  VERDICT="blocked"
  BLOCKER_CLASS="worktree-hygiene-blocked"
  NEXT_ROUTE="route through closeout-change or operator scope resolution before proposal archive authorization"
else
  VERDICT="pass"
  BLOCKER_CLASS=""
  NEXT_ROUTE="continue proposal closeout validation and archive authorization checks"
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
printf 'worktree_hygiene_verdict: "%s"\n' "$VERDICT"
printf 'worktree_hygiene_blocker_class: "%s"\n' "$BLOCKER_CLASS"
printf 'worktree_hygiene_owned_path_count: %s\n' "$OWNED_COUNT"
printf 'worktree_hygiene_in_scope_path_count: %s\n' "$SCOPE_COUNT"
printf 'worktree_hygiene_foreign_path_count: %s\n' "$FOREIGN_COUNT"
printf 'worktree_hygiene_foreign_fingerprint: "%s"\n' "$FOREIGN_FINGERPRINT"
printf 'worktree_hygiene_evidence: "git status --porcelain=v1 --untracked-files=all classified without mutation"\n'
printf 'next_route_condition: '
yaml_quote "$NEXT_ROUTE"
printf '\n'
printf 'owned_by_this_lifecycle_run:\n'
emit_rows "$OWNED_ROWS"
cat <<'EOF'
declared_in_scope_change:
EOF
emit_rows "$SCOPE_ROWS"
cat <<'EOF'
foreign_or_ambiguous:
EOF
emit_rows "$FOREIGN_ROWS"
