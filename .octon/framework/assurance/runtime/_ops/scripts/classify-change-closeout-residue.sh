#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"

usage() {
  cat <<'USAGE'
usage:
  classify-change-closeout-residue.sh [--root <repo-root>]

Read-only classifier for Change closeout residue. It inventories residue classes
needed by the Change Closeout State Machine and never authorizes deletion.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      ROOT_DIR="$1"
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

if [[ ! -d "$ROOT_DIR/.git" ]]; then
  echo "[ERROR] not a git repository: $ROOT_DIR" >&2
  exit 1
fi

echo "schema_version: change-closeout-residue-classification-v1"
echo "read_only: true"
echo "detection_is_deletion_authority: false"
echo "root: $ROOT_DIR"
echo "classes:"

emit_count() {
  local class="$1"
  local count="$2"
  echo "  - class: $class"
  echo "    count: $count"
}

porcelain="$(git -C "$ROOT_DIR" status --porcelain=v1 --ignored)"
emit_count "staged" "$(printf '%s\n' "$porcelain" | awk 'length($0) >= 2 && substr($0,1,1) != " " && substr($0,1,2) != "??" && substr($0,1,2) != "!!" { c++ } END { print c+0 }')"
emit_count "unstaged-tracked" "$(printf '%s\n' "$porcelain" | awk 'length($0) >= 2 && substr($0,2,1) != " " && substr($0,1,2) != "??" && substr($0,1,2) != "!!" { c++ } END { print c+0 }')"
emit_count "untracked" "$(printf '%s\n' "$porcelain" | awk 'substr($0,1,2) == "??" { c++ } END { print c+0 }')"
emit_count "ignored" "$(printf '%s\n' "$porcelain" | awk 'substr($0,1,2) == "!!" { c++ } END { print c+0 }')"
emit_count "local-branch" "$(git -C "$ROOT_DIR" for-each-ref --format='%(refname:short)' refs/heads | wc -l | tr -d ' ')"
emit_count "remote-branch" "$(git -C "$ROOT_DIR" for-each-ref --format='%(refname:short)' refs/remotes | wc -l | tr -d ' ')"
emit_count "generated-effective-output" "$(git -C "$ROOT_DIR" ls-files --others --modified --exclude-standard -- .octon/generated/effective 2>/dev/null | wc -l | tr -d ' ')"
emit_count "host-projection" "$(git -C "$ROOT_DIR" ls-files --others --modified --exclude-standard -- .codex/skills .claude 2>/dev/null | wc -l | tr -d ' ')"
emit_count "retained-evidence" "$(git -C "$ROOT_DIR" ls-files --others --modified --exclude-standard -- .octon/state/evidence 2>/dev/null | wc -l | tr -d ' ')"
emit_count "state-control" "$(git -C "$ROOT_DIR" ls-files --others --modified --exclude-standard -- .octon/state/control 2>/dev/null | wc -l | tr -d ' ')"
emit_count "release-version" "$(git -C "$ROOT_DIR" ls-files --others --modified --exclude-standard -- VERSION CHANGELOG.md .octon/framework/**/VERSION 2>/dev/null | wc -l | tr -d ' ')"
emit_count "input-surface" "$(git -C "$ROOT_DIR" ls-files --others --modified --exclude-standard -- .octon/inputs 2>/dev/null | wc -l | tr -d ' ')"
