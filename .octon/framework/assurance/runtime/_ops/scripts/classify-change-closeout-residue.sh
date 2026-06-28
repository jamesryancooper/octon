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

if ! git -C "$ROOT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "[ERROR] not a git repository: $ROOT_DIR" >&2
  exit 1
fi

ROOT_DIR="$(git -C "$ROOT_DIR" rev-parse --show-toplevel)"

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

path_has_prefix() {
  local path="$1"
  local prefix="${2%/}"
  [[ "$path" == "$prefix" || "$path" == "$prefix/"* ]]
}

is_lifecycle_closeout_publishable_path() {
  local path="$1"
  case "$path" in
    .octon/state/control/extensions/active.yml|\
    .octon/state/control/extensions/quarantine.yml|\
    .octon/inputs/additive/extensions/*|\
    .octon/inputs/exploratory/proposals/architecture/*|\
    .octon/inputs/exploratory/proposals/.archive/*|\
    .octon/generated/effective/*|\
    .octon/generated/proposals/*|\
    .octon/state/evidence/decisions/*|\
    .octon/state/evidence/validation/extensions/*|\
    .octon/state/evidence/validation/publication/*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

temporary_fixture_manifest_for_path() {
  local path="$1" suffix kind rest proposal_id manifest
  case "$path" in
    .octon/inputs/exploratory/proposals/.archive/*)
      return 1
      ;;
    .octon/inputs/exploratory/proposals/*/*)
      suffix="${path#.octon/inputs/exploratory/proposals/}"
      kind="${suffix%%/*}"
      rest="${suffix#*/}"
      proposal_id="${rest%%/*}"
      manifest="$ROOT_DIR/.octon/inputs/exploratory/proposals/$kind/$proposal_id/proposal.yml"
      ;;
    .octon/generated/proposals/artifacts/*/*)
      suffix="${path#.octon/generated/proposals/artifacts/}"
      kind="${suffix%%/*}"
      rest="${suffix#*/}"
      proposal_id="${rest%%/*}"
      manifest="$ROOT_DIR/.octon/inputs/exploratory/proposals/$kind/$proposal_id/proposal.yml"
      ;;
    *)
      return 1
      ;;
  esac
  [[ -f "$manifest" ]] || return 1
  command -v yq >/dev/null 2>&1 || return 1
  [[ "$(yq -r '.lifecycle.temporary // false' "$manifest" 2>/dev/null || true)" == "true" ]] || return 1
  [[ "$(yq -r '.status // ""' "$manifest" 2>/dev/null || true)" == "implemented" ]] || return 1
  return 0
}

is_proposal_lifecycle_local_retained_path() {
  local path="$1"
  case "$path" in
    .octon/state/continuity/runs/archive-proposal-[0-9]*/*|\
    .octon/state/continuity/runs/promote-proposal-[0-9]*/*|\
    .octon/state/control/execution/runs/archive-proposal-[0-9]*/*|\
    .octon/state/control/execution/runs/promote-proposal-[0-9]*/*|\
    .octon/state/evidence/control/execution/authority-decision-archive-proposal-[0-9]*.yml|\
    .octon/state/evidence/control/execution/authority-decision-promote-proposal-[0-9]*.yml|\
    .octon/state/evidence/control/execution/authority-grant-bundle-archive-proposal-[0-9]*.yml|\
    .octon/state/evidence/control/execution/authority-grant-bundle-promote-proposal-[0-9]*.yml|\
    .octon/state/evidence/external-index/runs/archive-proposal-[0-9]*.yml|\
    .octon/state/evidence/external-index/runs/promote-proposal-[0-9]*.yml|\
    .octon/state/evidence/runs/skills/closeout-worktree/*/lifecycle-interaction-return.json|\
    .octon/state/evidence/runs/skills/closeout-worktree/*/operator-scope.md)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

classify_routing_path() {
  local path="$1"
  if temporary_fixture_manifest_for_path "$path"; then
    printf '%s\n' "fixture_retention_candidate"
    return
  fi

  if is_lifecycle_closeout_publishable_path "$path"; then
    printf '%s\n' "publishable_change"
    return
  fi

  if is_proposal_lifecycle_local_retained_path "$path"; then
    printf '%s\n' "local_private_retained"
    return
  fi

  case "$path" in
    .octon/state/control/*|.octon/engine/*|.octon/generated/effective/*|.octon/inputs/*|*transcript*|*Transcript*)
      printf '%s\n' "unsafe"
      return
      ;;
  esac

  if path_has_prefix "$path" ".octon/state/evidence/runs/skills/closeout-change" ||
     path_has_prefix "$path" ".octon/state/evidence/runs/skills/repo-hygiene-cleanup" ||
     path_has_prefix "$path" ".octon/state/evidence/validation/analysis"; then
    printf '%s\n' "publishable_closeout_evidence"
    return
  fi

  if path_has_prefix "$path" ".octon/state/evidence/local"; then
    printf '%s\n' "local_private_retained"
    return
  fi

  if path_has_prefix "$path" ".octon/state"; then
    printf '%s\n' "unsafe"
    return
  fi

  printf '%s\n' "publishable_change"
}

publishable_change_count=0
publishable_closeout_evidence_count=0
local_private_retained_count=0
fixture_retention_candidate_count=0
foreign_manual_review_count=0
unsafe_count=0
ambiguous_count=0

changed_paths="$(
  {
    git -C "$ROOT_DIR" diff --name-only --cached
    git -C "$ROOT_DIR" ls-files --others --modified --exclude-standard
  } 2>/dev/null | sort -u
)"
ignored_paths="$(printf '%s\n' "$porcelain" | awk 'substr($0,1,2) == "!!" { path = substr($0,4); if (path != "") print path }')"

while IFS= read -r path; do
  [[ -n "$path" ]] || continue
  case "$(classify_routing_path "$path")" in
    publishable_change)
      publishable_change_count=$((publishable_change_count + 1))
      ;;
    publishable_closeout_evidence)
      publishable_closeout_evidence_count=$((publishable_closeout_evidence_count + 1))
      ;;
    local_private_retained)
      local_private_retained_count=$((local_private_retained_count + 1))
      ;;
    fixture_retention_candidate)
      fixture_retention_candidate_count=$((fixture_retention_candidate_count + 1))
      ;;
    unsafe)
      unsafe_count=$((unsafe_count + 1))
      ;;
    ambiguous)
      ambiguous_count=$((ambiguous_count + 1))
      ;;
    foreign_manual_review)
      foreign_manual_review_count=$((foreign_manual_review_count + 1))
      ;;
  esac
done <<<"$changed_paths"

while IFS= read -r path; do
  [[ -n "$path" ]] || continue
  case "$(classify_routing_path "$path")" in
    publishable_closeout_evidence)
      publishable_closeout_evidence_count=$((publishable_closeout_evidence_count + 1))
      ;;
    unsafe)
      unsafe_count=$((unsafe_count + 1))
      ;;
    ambiguous)
      ambiguous_count=$((ambiguous_count + 1))
      ;;
    foreign_manual_review)
      foreign_manual_review_count=$((foreign_manual_review_count + 1))
      ;;
    publishable_change|local_private_retained)
      local_private_retained_count=$((local_private_retained_count + 1))
      ;;
    fixture_retention_candidate)
      fixture_retention_candidate_count=$((fixture_retention_candidate_count + 1))
      ;;
  esac
done <<<"$ignored_paths"

echo "routing_classes:"
emit_count "publishable_change" "$publishable_change_count"
emit_count "publishable_closeout_evidence" "$publishable_closeout_evidence_count"
emit_count "local_private_retained" "$local_private_retained_count"
emit_count "fixture_retention_candidate" "$fixture_retention_candidate_count"
emit_count "foreign_manual_review" "$foreign_manual_review_count"
emit_count "unsafe" "$unsafe_count"
emit_count "ambiguous" "$ambiguous_count"
