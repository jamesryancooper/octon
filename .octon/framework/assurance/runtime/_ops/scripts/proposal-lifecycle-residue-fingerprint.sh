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

cleanup_paths_file="$(mktemp "${TMPDIR:-/tmp}/octon-residue-fingerprint-cleanup-paths.XXXXXX")"
trap 'rm -f "$cleanup_paths_file"' EXIT
git -C "$ROOT_DIR" ls-files --others --exclude-standard -- \
  .octon/state \
  .octon/generated/.tmp \
  .octon/generated/cognition/projections/materialized/runs >"$cleanup_paths_file"
cleanup_summary="$(
  python3 - "$active_run_id" "$cleanup_paths_file" <<'PY'
import fnmatch
import hashlib
import sys
from pathlib import Path

active_run_id = sys.argv[1]
paths = sorted(path.strip() for path in Path(sys.argv[2]).read_text().splitlines() if path.strip())

def active_run_artifact(path: str) -> bool:
    if not active_run_id:
        return False
    prefixes = (
        f".octon/state/control/execution/runs/{active_run_id}/",
        f".octon/state/control/execution/runs/{active_run_id}-",
        f".octon/state/continuity/runs/{active_run_id}/",
        f".octon/state/continuity/runs/{active_run_id}-",
        f".octon/state/evidence/runs/{active_run_id}/",
        f".octon/state/evidence/runs/{active_run_id}-",
        f".octon/state/evidence/runs/workflows/{active_run_id}/",
        f".octon/state/evidence/runs/workflows/{active_run_id}-",
        f".octon/state/evidence/runs/skills/repo-hygiene-cleanup/{active_run_id}/",
        f".octon/state/evidence/runs/skills/repo-hygiene-cleanup/{active_run_id}-",
        f".octon/state/evidence/runs/skills/closeout-change/{active_run_id}/",
        f".octon/state/evidence/runs/skills/closeout-change/{active_run_id}-",
        f".octon/state/evidence/runs/skills/closeout-worktree/{active_run_id}/",
        f".octon/state/evidence/runs/skills/closeout-worktree/{active_run_id}-",
        f".octon/state/evidence/runs/skills/closeout-packet/{active_run_id}/",
        f".octon/state/evidence/runs/skills/closeout-packet/{active_run_id}-",
    )
    exact_prefixes = (
        f".octon/state/control/execution/approvals/requests/{active_run_id}",
        f".octon/state/evidence/control/execution/authority-decision-{active_run_id}",
        f".octon/state/evidence/control/execution/authority-grant-bundle-{active_run_id}",
        f".octon/state/evidence/external-index/runs/{active_run_id}",
    )
    return path.startswith(prefixes) or any(path.startswith(prefix) for prefix in exact_prefixes)

def cleanup_candidate(path: str) -> bool:
    if active_run_artifact(path):
        return False
    if path == ".DS_Store" or path.endswith("/.DS_Store"):
        return True
    if path.startswith(".octon/generated/.tmp/"):
        return True
    patterns = (
        ".octon/state/control/execution/runs/publish-*/*",
        ".octon/state/continuity/runs/publish-*/*",
        ".octon/state/control/execution/approvals/requests/publish-*.yml",
        ".octon/state/evidence/control/execution/authority-decision-publish-*.yml",
        ".octon/state/evidence/control/execution/authority-grant-bundle-publish-*.yml",
        ".octon/state/evidence/external-index/runs/publish-*.yml",
        ".octon/state/control/execution/runs/service-build-*/*",
        ".octon/state/continuity/runs/service-build-*/*",
        ".octon/state/control/execution/approvals/requests/service-build-*.yml",
        ".octon/state/evidence/control/execution/authority-decision-service-build-*.yml",
        ".octon/state/evidence/control/execution/authority-grant-bundle-service-build-*.yml",
        ".octon/state/evidence/external-index/runs/service-build-*.yml",
        ".octon/state/evidence/runs/services/service-build-*/*",
        ".octon/state/control/engine/agent/checkpoints/runtime-agent-quorum-*.json",
        ".octon/state/evidence/runs/engine/agent/runtime-agent-quorum-*.json",
        ".octon/state/control/execution/runs/lifecycle-proposal-*/*",
        ".octon/state/continuity/runs/lifecycle-proposal-*/*",
        ".octon/state/control/execution/approvals/requests/lifecycle-proposal-*.yml",
        ".octon/state/evidence/control/execution/authority-decision-lifecycle-proposal-*.yml",
        ".octon/state/evidence/control/execution/authority-grant-bundle-lifecycle-proposal-*.yml",
        ".octon/state/evidence/external-index/runs/lifecycle-proposal-*.yml",
        ".octon/state/evidence/runs/skills/closeout-worktree/*",
        ".octon/state/evidence/runs/skills/closeout-packet/*",
        ".octon/state/evidence/runs/skills/octon-proposal-lifecycle-closeout-packet/*",
        ".octon/state/evidence/validation/publication/capabilities/*.yml",
        ".octon/state/evidence/validation/publication/runtime/*.yml",
        ".octon/state/evidence/validation/publication/extensions/*.yml",
        ".octon/state/evidence/validation/compatibility/extensions/*.yml",
        ".octon/state/evidence/validation/extensions/prompt-alignment/*.yml",
    )
    return any(fnmatch.fnmatchcase(path, pattern) for pattern in patterns)

candidates = sorted(path for path in paths if cleanup_candidate(path))
payload = "".join(f"{path}\n" for path in candidates).encode("utf-8")
print("summary:")
print(f"  cleanup_candidates: {len(candidates)}")
print(f"  cleanup_path_set_digest: sha256:{hashlib.sha256(payload).hexdigest()}")
PY
)"

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
