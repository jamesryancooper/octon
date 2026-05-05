#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"

ROOT_ARG=""
OCTON_ARG=""
CONFIRM=0
FAIL_ON_MANUAL=0
SUMMARY_ONLY=0

usage() {
  cat <<'USAGE'
cleanup-local-run-artifacts.sh [--confirm] [--fail-on-manual] [--summary-only] [--root <repo-root>] [--octon-dir <octon-root>]

Classify untracked local Octon run/control/evidence artifacts and optionally
remove only cleanup-safe local residue. Dry-run is the default.

The helper protects tracked files and untracked files referenced by tracked
files. Deletion requires --confirm.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --confirm)
      CONFIRM=1
      shift
      ;;
    --fail-on-manual)
      FAIL_ON_MANUAL=1
      shift
      ;;
    --summary-only)
      SUMMARY_ONLY=1
      shift
      ;;
    --root)
      ROOT_ARG="${2:-}"
      [[ -n "$ROOT_ARG" ]] || {
        echo "[ERROR] --root requires a value" >&2
        exit 2
      }
      shift 2
      ;;
    --octon-dir)
      OCTON_ARG="${2:-}"
      [[ -n "$OCTON_ARG" ]] || {
        echo "[ERROR] --octon-dir requires a value" >&2
        exit 2
      }
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[ERROR] unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -n "$ROOT_ARG" ]]; then
  ROOT_DIR="$(cd -- "$ROOT_ARG" && pwd)"
else
  OCTON_DIR_FOR_ROOT="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
  ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR_FOR_ROOT/.." && pwd)}"
fi

if [[ -n "$OCTON_ARG" ]]; then
  OCTON_DIR="$(cd -- "$OCTON_ARG" && pwd)"
else
  OCTON_DIR="${OCTON_DIR_OVERRIDE:-$ROOT_DIR/.octon}"
fi

ROOT_DIR="$(git -C "$ROOT_DIR" rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "$ROOT_DIR" ]]; then
  echo "[ERROR] --root must point inside a git worktree" >&2
  exit 2
fi

if [[ ! -d "$ROOT_DIR/.octon" ]]; then
  echo "[ERROR] repo root does not contain .octon" >&2
  exit 2
fi

OCTON_DIR="$(cd -- "$OCTON_DIR" && pwd -P)"
EXPECTED_OCTON_DIR="$(cd -- "$ROOT_DIR/.octon" && pwd -P)"
if [[ "$OCTON_DIR" != "$EXPECTED_OCTON_DIR" ]]; then
  echo "[ERROR] Octon root must resolve to repo root .octon: $OCTON_DIR" >&2
  exit 2
fi

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/octon-local-run-artifacts.XXXXXX")"
trap 'rm -rf "$TMP_DIR"' EXIT
UNTRACKED_PATHS="$TMP_DIR/untracked-paths.txt"
REFERENCED_PATHS="$TMP_DIR/referenced-paths.txt"

git -C "$ROOT_DIR" ls-files --others --exclude-standard -- .octon/state .octon/generated/.tmp >"$UNTRACKED_PATHS"
if [[ -s "$UNTRACKED_PATHS" ]]; then
  git -C "$ROOT_DIR" grep -h -F -o -f "$UNTRACKED_PATHS" -- >"$REFERENCED_PATHS" 2>/dev/null || true
  sort -u "$REFERENCED_PATHS" -o "$REFERENCED_PATHS"
else
  : >"$REFERENCED_PATHS"
fi

is_referenced_by_tracked_file() {
  local rel="$1"
  grep -Fxq -- "$rel" "$REFERENCED_PATHS"
}

set_classification() {
  CLASS_KIND="$1"
  CLASS_DISPOSITION="$2"
  CLASS_REASON="$3"
}

referenced_kind_for_path() {
  local rel="$1"
  case "$rel" in
    .octon/state/evidence/*)
      echo "retained_evidence"
      ;;
    .octon/state/control/*|.octon/state/continuity/*)
      echo "active_control_state"
      ;;
    .octon/generated/.tmp/*)
      echo "generated_scratch_output"
      ;;
    *)
      echo "referenced_untracked"
      ;;
  esac
}

classify_path() {
  local rel="$1"

  if is_referenced_by_tracked_file "$rel"; then
    set_classification "$(referenced_kind_for_path "$rel")" "protected_referenced" "referenced by a tracked control, evidence, generated, or governance file"
    return
  fi

  case "$rel" in
    .octon/state/control/execution/runs/publish-*/*|\
    .octon/state/continuity/runs/publish-*/*|\
    .octon/state/control/execution/approvals/requests/publish-*.yml|\
    .octon/state/evidence/control/execution/authority-decision-publish-*.yml|\
    .octon/state/evidence/control/execution/authority-grant-bundle-publish-*.yml|\
    .octon/state/evidence/external-index/runs/publish-*.yml)
      set_classification "local_run_residue" "cleanup_candidate" "unreferenced local publication run residue"
      ;;
    .octon/state/control/execution/runs/service-build-*/*|\
    .octon/state/continuity/runs/service-build-*/*|\
    .octon/state/control/execution/approvals/requests/service-build-*.yml|\
    .octon/state/evidence/control/execution/authority-decision-service-build-*.yml|\
    .octon/state/evidence/control/execution/authority-grant-bundle-service-build-*.yml|\
    .octon/state/evidence/external-index/runs/service-build-*.yml|\
    .octon/state/evidence/runs/services/service-build-*/*)
      set_classification "local_run_residue" "cleanup_candidate" "unreferenced local service-build run residue"
      ;;
    .octon/state/control/engine/agent/checkpoints/runtime-agent-quorum-*.json|\
    .octon/state/evidence/runs/engine/agent/runtime-agent-quorum-*.json)
      set_classification "local_run_residue" "cleanup_candidate" "unreferenced local runtime agent quorum residue"
      ;;
    .octon/state/evidence/validation/publication/capabilities/*.yml|\
    .octon/state/evidence/validation/publication/runtime/*.yml|\
    .octon/state/evidence/validation/publication/extensions/*.yml|\
    .octon/state/evidence/validation/compatibility/extensions/*.yml|\
    .octon/state/evidence/validation/extensions/prompt-alignment/*.yml)
      set_classification "stale_unreferenced_publication_attempt" "cleanup_candidate" "unreferenced superseded publication receipt"
      ;;
    .octon/generated/.tmp/*)
      set_classification "generated_scratch_output" "cleanup_candidate" "rebuildable generated scratch output"
      ;;
    .octon/state/evidence/validation/publication/build-to-delete/*)
      set_classification "retained_evidence" "manual_review" "build-to-delete evidence is claim-adjacent and never local-only by path alone"
      ;;
    .octon/state/evidence/*)
      set_classification "retained_evidence" "manual_review" "unreferenced evidence root file needs explicit retention or cleanup rationale"
      ;;
    .octon/state/control/*|.octon/state/continuity/*)
      set_classification "active_control_state" "manual_review" "unreferenced control or continuity state needs operator classification"
      ;;
    .octon/state/*)
      set_classification "unknown_state_artifact" "manual_review" "unrecognized state artifact"
      ;;
    *)
      set_classification "outside_scope" "manual_review" "outside local Octon state cleanup scope"
      ;;
  esac
}

prune_empty_parents() {
  local rel="$1"
  local dir
  dir="$(dirname -- "$ROOT_DIR/$rel")"
  while [[ "$dir" == "$ROOT_DIR/.octon/state"* || "$dir" == "$ROOT_DIR/.octon/generated/.tmp"* ]]; do
    [[ "$dir" != "$ROOT_DIR/.octon/state" && "$dir" != "$ROOT_DIR/.octon/generated/.tmp" ]] || break
    rmdir "$dir" 2>/dev/null || break
    dir="$(dirname -- "$dir")"
  done
}

declare -a CLEANUP_CANDIDATES=()
declare -a PROTECTED_REFERENCED=()
declare -a MANUAL_REVIEW=()

while IFS= read -r rel; do
  [[ -n "$rel" ]] || continue
  CLASS_KIND=""
  CLASS_DISPOSITION=""
  CLASS_REASON=""
  classify_path "$rel"
  case "$CLASS_DISPOSITION" in
    cleanup_candidate)
      CLEANUP_CANDIDATES+=("$rel")
      [[ "$SUMMARY_ONLY" -eq 1 ]] || printf 'cleanup_candidate\t%s\t%s\t%s\n' "$CLASS_KIND" "$rel" "$CLASS_REASON"
      ;;
    protected_referenced|protected)
      PROTECTED_REFERENCED+=("$rel")
      [[ "$SUMMARY_ONLY" -eq 1 ]] || printf 'protected\t%s\t%s\t%s\n' "$CLASS_KIND" "$rel" "$CLASS_REASON"
      ;;
    manual_review)
      MANUAL_REVIEW+=("$rel")
      [[ "$SUMMARY_ONLY" -eq 1 ]] || printf 'manual_review\t%s\t%s\t%s\n' "$CLASS_KIND" "$rel" "$CLASS_REASON"
      ;;
    *)
      MANUAL_REVIEW+=("$rel")
      [[ "$SUMMARY_ONLY" -eq 1 ]] || printf 'manual_review\t%s\t%s\tunrecognized disposition %s\n' "$CLASS_KIND" "$rel" "$CLASS_DISPOSITION"
      ;;
  esac
done <"$UNTRACKED_PATHS"

echo "summary:"
echo "  mode: $([[ "$CONFIRM" -eq 1 ]] && echo confirm || echo dry-run)"
echo "  cleanup_candidates: ${#CLEANUP_CANDIDATES[@]}"
echo "  protected_referenced: ${#PROTECTED_REFERENCED[@]}"
echo "  manual_review: ${#MANUAL_REVIEW[@]}"

if [[ "$CONFIRM" -ne 1 ]]; then
  echo "[OK] dry-run complete; rerun with --confirm to remove cleanup candidates only"
else
  for rel in "${CLEANUP_CANDIDATES[@]}"; do
    if [[ -f "$ROOT_DIR/$rel" || -L "$ROOT_DIR/$rel" ]]; then
      rm -f -- "$ROOT_DIR/$rel"
      prune_empty_parents "$rel"
      echo "removed: $rel"
    else
      echo "[WARN] cleanup candidate no longer exists as a file: $rel"
    fi
  done
  echo "[OK] removed ${#CLEANUP_CANDIDATES[@]} cleanup candidate file(s); protected and manual-review files were retained"
fi

if [[ "$FAIL_ON_MANUAL" -eq 1 && "${#MANUAL_REVIEW[@]}" -gt 0 ]]; then
  echo "[ERROR] manual-review artifacts remain" >&2
  exit 1
fi
