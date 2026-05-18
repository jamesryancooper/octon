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

add_program_child_scope() {
  local registry="$TARGET_DIR/resources/child-packet-index.yml"
  [[ -f "$registry" ]] || return 0
  command -v yq >/dev/null 2>&1 || return 0
  while IFS= read -r child_path; do
    [[ -n "$child_path" && "$child_path" != "null" ]] || continue
    add_prefix "$SCOPE_PREFIXES" "$child_path"
    add_in_scope_from_manifest "$ROOT_DIR/$(normalize_path "$child_path")/proposal.yml"
  done < <(yq -r '.children[]?.path // ""' "$registry" 2>/dev/null || true)
  while IFS= read -r write_scope; do
    [[ -n "$write_scope" && "$write_scope" != "null" ]] || continue
    add_prefix "$SCOPE_PREFIXES" "$write_scope"
  done < <(yq -r '.children[]?.write_scopes[]? // ""' "$registry" 2>/dev/null || true)
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
  if matches_prefix_file "$path" "$OWNED_PREFIXES"; then
    printf '%s\t%s\n' "$status" "$path" >>"$OWNED_ROWS"
  elif matches_prefix_file "$path" "$SCOPE_PREFIXES"; then
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
