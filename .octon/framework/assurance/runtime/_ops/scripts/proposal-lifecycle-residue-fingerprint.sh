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

usage() {
  cat <<'EOF'
usage:
  proposal-lifecycle-residue-fingerprint.sh --target <proposal-path> --lifecycle proposal-packet|proposal-program
EOF
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

GIT_ROOT="$(git -C "$ROOT_DIR" rev-parse --show-toplevel 2>/dev/null)" || {
  echo "[ERROR] ROOT_DIR is not inside a git repository: $ROOT_DIR" >&2
  exit 2
}
ROOT_DIR="$GIT_ROOT"
OCTON_DIR="$ROOT_DIR/.octon"

extract_yaml_scalar() {
  local content="$1" key="$2"
  awk -v key="$key" '
    $1 == key ":" {
      sub(/^[^:]*:[[:space:]]*/, "")
      gsub(/^"/, "")
      gsub(/"$/, "")
      print
      exit
    }
  ' <<<"$content"
}

cleanup_summary=""
cleanup_helper="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh"
if [[ -f "$cleanup_helper" ]]; then
  active_run_id="${OCTON_ACTIVE_RUN_ID:-}"
  if [[ -z "$active_run_id" && "$LIFECYCLE" == "proposal-program" ]]; then
    runs_root="$OCTON_DIR/state/control/execution/runs"
    if [[ -d "$runs_root" ]]; then
      while IFS= read -r checkpoint; do
        grep -Fq "target: $TARGET_PATH" "$checkpoint" || continue
        active_run_id="$(basename "$(dirname "$checkpoint")")"
      done < <(
        find "$runs_root" \
          -path "*/lifecycle-proposal-program-*/program-lifecycle-checkpoint.yml" \
          -type f \
          -print 2>/dev/null | sort
      )
    fi
  fi
  cleanup_args=(
    --summary-only
    --root "$ROOT_DIR"
    --octon-dir "$OCTON_DIR"
  )
  if [[ -n "$active_run_id" ]]; then
    cleanup_args+=(--active-run-id "$active_run_id")
  fi
  cleanup_summary="$(
    OCTON_ROOT_DIR="$ROOT_DIR" bash "$cleanup_helper" \
      "${cleanup_args[@]}"
  )"
fi

worktree_summary=""
worktree_classifier="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/classify-proposal-worktree-hygiene.sh"
if [[ -f "$worktree_classifier" ]]; then
  worktree_summary="$(
    OCTON_ROOT_DIR="$ROOT_DIR" bash "$worktree_classifier" \
      --target "$TARGET_PATH" \
      --lifecycle "$LIFECYCLE" \
      --format yaml
  )"
fi

cleanup_candidates="$(extract_yaml_scalar "$cleanup_summary" cleanup_candidates)"
cleanup_path_set_digest="$(extract_yaml_scalar "$cleanup_summary" cleanup_path_set_digest)"

# Cleanup receipt freshness is for actionable cleanup residue only. Manual-review
# and foreign worktree hygiene are publication/closeout blockers, not cleanup
# candidates; including them here causes no-op cleanup receipts to become stale
# after ordinary lifecycle receipt churn.
{
  printf 'target=%s\n' "$TARGET_PATH"
  printf 'lifecycle=%s\n' "$LIFECYCLE"
  printf 'cleanup_candidates=%s\n' "${cleanup_candidates:-unknown}"
  printf 'cleanup_path_set_digest=%s\n' "${cleanup_path_set_digest:-unknown}"
} | LC_ALL=C shasum -a 256 | awk '{print "sha256:" $1}'
