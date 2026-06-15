#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"

ROOT_ARG=""
OCTON_ARG=""
ACTIVE_RUN_ID="${OCTON_ACTIVE_RUN_ID:-}"
CONFIRM=0
FAIL_ON_MANUAL=0
SUMMARY_ONLY=0
AUTHORIZE_OUT=""
AUTHORIZATION_RECEIPT=""
REQUESTED_CLEANUP_PATH_ARGS=()

POLICY_REF=".octon/instance/governance/policies/repo-hygiene.yml"
HELPER_REF=".octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh"
SCHEMA_REF=".octon/framework/product/contracts/repo-hygiene-cleanup-authorization-v1.schema.json"
RUN_HEALTH_GENERATOR_REF=".octon/framework/assurance/runtime/_ops/scripts/generate-run-health-read-model.sh"

usage() {
  cat <<'USAGE'
cleanup-local-run-artifacts.sh [--confirm] [--fail-on-manual] [--summary-only] [--cleanup-path <repo-relative-path>] [--authorize <out.json>] [--authorization <receipt.json>] [--active-run-id <run-id>] [--root <repo-root>] [--octon-dir <octon-root>]

Classify untracked local Octon run/control/evidence artifacts and optionally
remove only cleanup-safe local residue. Dry-run is the default.

The helper protects tracked files and untracked files referenced by tracked
files. Deletion requires either explicit --confirm or a validating
repo-hygiene-cleanup-authorization-v1 receipt passed with --authorization.
When --cleanup-path is supplied one or more times, cleanup is limited to those
repo-relative paths after they have been proven to be current cleanup
candidates by the full classification pass.
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
    --authorize)
      AUTHORIZE_OUT="${2:-}"
      [[ -n "$AUTHORIZE_OUT" ]] || {
        echo "[ERROR] --authorize requires a value" >&2
        exit 2
      }
      shift 2
      ;;
    --authorization)
      AUTHORIZATION_RECEIPT="${2:-}"
      [[ -n "$AUTHORIZATION_RECEIPT" ]] || {
        echo "[ERROR] --authorization requires a value" >&2
        exit 2
      }
      shift 2
      ;;
    --cleanup-path)
      requested_cleanup_path="${2:-}"
      [[ -n "$requested_cleanup_path" ]] || {
        echo "[ERROR] --cleanup-path requires a value" >&2
        exit 2
      }
      REQUESTED_CLEANUP_PATH_ARGS+=("$requested_cleanup_path")
      shift 2
      ;;
    --active-run-id)
      ACTIVE_RUN_ID="${2:-}"
      [[ -n "$ACTIVE_RUN_ID" ]] || {
        echo "[ERROR] --active-run-id requires a value" >&2
        exit 2
      }
      shift 2
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

if [[ -n "$AUTHORIZE_OUT" && -n "$AUTHORIZATION_RECEIPT" ]]; then
  echo "[ERROR] --authorize and --authorization are mutually exclusive" >&2
  exit 2
fi

if [[ "$CONFIRM" -eq 1 && -n "$AUTHORIZATION_RECEIPT" ]]; then
  echo "[ERROR] --confirm and --authorization are mutually exclusive cleanup routes" >&2
  exit 2
fi

if [[ "$SUMMARY_ONLY" -eq 1 && ( -n "$AUTHORIZE_OUT" || -n "$AUTHORIZATION_RECEIPT" ) ]]; then
  echo "[ERROR] --summary-only cannot emit or consume authorization receipts" >&2
  exit 2
fi

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

if [[ -n "$AUTHORIZATION_RECEIPT" && ! -f "$AUTHORIZATION_RECEIPT" ]]; then
  echo "[ERROR] authorization receipt is missing or unreadable: $AUTHORIZATION_RECEIPT" >&2
  exit 1
fi

if [[ -n "$ACTIVE_RUN_ID" && ! "$ACTIVE_RUN_ID" =~ ^[A-Za-z0-9._:-]+$ ]]; then
  echo "[ERROR] --active-run-id contains unsupported characters: $ACTIVE_RUN_ID" >&2
  exit 2
fi

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/octon-local-run-artifacts.XXXXXX")"
trap 'rm -rf "$TMP_DIR"' EXIT
UNTRACKED_PATHS="$TMP_DIR/untracked-paths.txt"
REFERENCED_PATHS="$TMP_DIR/referenced-paths.txt"
EXCLUDED_PATHS="$TMP_DIR/excluded-paths.txt"
STATUS_ROWS="$TMP_DIR/status-rows.txt"
CLASSIFICATION_ROWS="$TMP_DIR/classification-rows.tsv"
CLEANUP_PATHS="$TMP_DIR/cleanup-paths.txt"
PROTECTED_PATHS="$TMP_DIR/protected-paths.txt"
MANUAL_PATHS="$TMP_DIR/manual-paths.txt"
AUTHORIZED_PATHS="$TMP_DIR/authorized-paths.txt"
REQUESTED_CLEANUP_PATHS="$TMP_DIR/requested-cleanup-paths.txt"
SELECTED_CLEANUP_PATHS="$TMP_DIR/selected-cleanup-paths.txt"

: >"$EXCLUDED_PATHS"
: >"$CLASSIFICATION_ROWS"
: >"$CLEANUP_PATHS"
: >"$PROTECTED_PATHS"
: >"$MANUAL_PATHS"
: >"$AUTHORIZED_PATHS"
: >"$REQUESTED_CLEANUP_PATHS"
: >"$SELECTED_CLEANUP_PATHS"

repo_relative_if_under_root() {
  local candidate="$1"
  python3 - "$ROOT_DIR" "$candidate" <<'PY'
import sys
from pathlib import Path

root = Path(sys.argv[1]).resolve()
candidate = Path(sys.argv[2])
if not candidate.is_absolute():
    candidate = Path.cwd() / candidate
try:
    print(candidate.resolve().relative_to(root).as_posix())
except ValueError:
    pass
PY
}

add_excluded_path() {
  local raw="$1"
  local rel
  rel="$(repo_relative_if_under_root "$raw")"
  [[ -z "$rel" ]] || printf '%s\n' "$rel" >>"$EXCLUDED_PATHS"
}

[[ -z "$AUTHORIZE_OUT" ]] || add_excluded_path "$AUTHORIZE_OUT"
[[ -z "$AUTHORIZATION_RECEIPT" ]] || add_excluded_path "$AUTHORIZATION_RECEIPT"
sort -u "$EXCLUDED_PATHS" -o "$EXCLUDED_PATHS"

is_excluded_path() {
  local rel="$1"
  [[ -s "$EXCLUDED_PATHS" ]] && grep -Fxq -- "$rel" "$EXCLUDED_PATHS"
}

filter_excluded_paths() {
  while IFS= read -r rel; do
    [[ -n "$rel" ]] || continue
    is_excluded_path "$rel" && continue
    printf '%s\n' "$rel"
  done
}

filter_status_rows() {
  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    local rel="$line"
    case "$line" in
      '?? '*|'!! '*)
        rel="${line:3}"
        ;;
      *)
        rel="${line:3}"
        ;;
    esac
    is_excluded_path "$rel" && continue
    printf '%s\n' "$line"
  done
}

digest_file() {
  local file="$1"
  local digest
  digest="$(shasum -a 256 "$file" | awk '{print $1}')"
  printf 'sha256:%s\n' "$digest"
}

git_ref_or_unavailable() {
  local ref="$1"
  git -C "$ROOT_DIR" rev-parse --verify "$ref" 2>/dev/null || printf 'unavailable\n'
}

HEAD_REF="$(git_ref_or_unavailable HEAD)"
MAIN_REF="$(git_ref_or_unavailable main)"
ORIGIN_MAIN_REF="$(git_ref_or_unavailable origin/main)"

{
  git -C "$ROOT_DIR" ls-files --others --exclude-standard -- \
    .octon/state \
    .octon/generated/.tmp \
    .octon/generated/cognition/projections/materialized/runs \
    ':(glob)**/.DS_Store'
  git -C "$ROOT_DIR" ls-files --others --ignored --exclude-standard -- \
    ':(glob)**/.DS_Store'
} | sort -u \
  | filter_excluded_paths >"$UNTRACKED_PATHS"

if [[ -s "$UNTRACKED_PATHS" ]]; then
  git -C "$ROOT_DIR" grep -h -F -o -f "$UNTRACKED_PATHS" -- >"$REFERENCED_PATHS" 2>/dev/null || true
  sort -u "$REFERENCED_PATHS" -o "$REFERENCED_PATHS"
else
  : >"$REFERENCED_PATHS"
fi

{
  git -C "$ROOT_DIR" status --porcelain=v1 -uall -- \
    .octon/state \
    .octon/generated/.tmp \
    .octon/generated/cognition/projections/materialized/runs \
    ':(glob)**/.DS_Store'
  git -C "$ROOT_DIR" status --porcelain=v1 --ignored -- \
    ':(glob)**/.DS_Store'
} | sort -u \
  | filter_status_rows >"$STATUS_ROWS"

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
    .octon/generated/cognition/projections/materialized/runs/*)
      echo "generated_run_health_projection"
      ;;
    *)
      echo "referenced_untracked"
      ;;
  esac
}

matches_active_run_artifact() {
  local rel="$1"
  [[ -n "$ACTIVE_RUN_ID" ]] || return 1
  case "$rel" in
    .octon/state/control/execution/runs/"$ACTIVE_RUN_ID"/*|\
    .octon/state/control/execution/runs/"$ACTIVE_RUN_ID"-*/*|\
    .octon/state/continuity/runs/"$ACTIVE_RUN_ID"/*|\
    .octon/state/continuity/runs/"$ACTIVE_RUN_ID"-*/*|\
    .octon/state/evidence/runs/"$ACTIVE_RUN_ID"/*|\
    .octon/state/evidence/runs/"$ACTIVE_RUN_ID"-*/*|\
    .octon/state/evidence/runs/workflows/"$ACTIVE_RUN_ID"/*|\
    .octon/state/evidence/runs/workflows/"$ACTIVE_RUN_ID"-*/*|\
    .octon/state/evidence/runs/skills/repo-hygiene-cleanup/"$ACTIVE_RUN_ID"/*|\
    .octon/state/evidence/runs/skills/repo-hygiene-cleanup/"$ACTIVE_RUN_ID"-*/*|\
    .octon/state/evidence/runs/skills/closeout-change/"$ACTIVE_RUN_ID"/*|\
    .octon/state/evidence/runs/skills/closeout-change/"$ACTIVE_RUN_ID"-*/*|\
    .octon/state/evidence/runs/skills/closeout-worktree/"$ACTIVE_RUN_ID"/*|\
    .octon/state/evidence/runs/skills/closeout-worktree/"$ACTIVE_RUN_ID"-*/*|\
    .octon/state/evidence/runs/skills/closeout-packet/"$ACTIVE_RUN_ID"/*|\
    .octon/state/evidence/runs/skills/closeout-packet/"$ACTIVE_RUN_ID"-*/*|\
    .octon/state/control/execution/approvals/requests/"$ACTIVE_RUN_ID"*.yml|\
    .octon/state/evidence/control/execution/authority-decision-"$ACTIVE_RUN_ID"*.yml|\
    .octon/state/evidence/control/execution/authority-grant-bundle-"$ACTIVE_RUN_ID"*.yml|\
    .octon/state/evidence/external-index/runs/"$ACTIVE_RUN_ID"*.yml)
      return 0
      ;;
  esac
  return 1
}

is_closed_workflow_run_id() {
  local run_id="$1"
  [[ -n "$run_id" ]] || return 1

  local control_dir="$ROOT_DIR/.octon/state/control/execution/runs/$run_id"
  local runtime_state="$control_dir/runtime-state.yml"
  local complete_checkpoint="$control_dir/checkpoints/execution-complete.yml"
  local evidence_dir="$ROOT_DIR/.octon/state/evidence/runs/$run_id"

  [[ -f "$runtime_state" ]] || return 1
  [[ -f "$complete_checkpoint" ]] || return 1
  [[ -d "$evidence_dir" ]] || return 1
  grep -Eq '^[[:space:]]*state:[[:space:]]*closed([[:space:]]|$)' "$runtime_state" || return 1
  grep -Eq '^[[:space:]]*status:[[:space:]]*materialized([[:space:]]|$)' "$complete_checkpoint" || return 1
}

closed_workflow_run_residue_run_id() {
  local rel="$1"
  local run_id=""

  case "$rel" in
    .octon/state/control/execution/runs/*/*)
      run_id="${rel#.octon/state/control/execution/runs/}"
      run_id="${run_id%%/*}"
      ;;
    .octon/state/continuity/runs/*/*)
      run_id="${rel#.octon/state/continuity/runs/}"
      run_id="${run_id%%/*}"
      ;;
    .octon/state/control/execution/approvals/requests/*.yml)
      run_id="${rel#.octon/state/control/execution/approvals/requests/}"
      run_id="${run_id%.yml}"
      ;;
    .octon/state/evidence/control/execution/authority-decision-*.yml)
      run_id="${rel#.octon/state/evidence/control/execution/authority-decision-}"
      run_id="${run_id%.yml}"
      ;;
    .octon/state/evidence/control/execution/authority-grant-bundle-*.yml)
      run_id="${rel#.octon/state/evidence/control/execution/authority-grant-bundle-}"
      run_id="${run_id%.yml}"
      ;;
    .octon/state/evidence/external-index/runs/*.yml)
      run_id="${rel#.octon/state/evidence/external-index/runs/}"
      run_id="${run_id%.yml}"
      ;;
    *)
      return 1
      ;;
  esac

  if is_closed_workflow_run_id "$run_id"; then
    printf '%s\n' "$run_id"
    return 0
  fi

  return 1
}

run_id_for_control_residue_path() {
  local rel="$1"
  local run_id=""

  case "$rel" in
    .octon/state/control/execution/runs/*/*)
      run_id="${rel#.octon/state/control/execution/runs/}"
      run_id="${run_id%%/*}"
      ;;
    .octon/state/continuity/runs/*/*)
      run_id="${rel#.octon/state/continuity/runs/}"
      run_id="${run_id%%/*}"
      ;;
    .octon/state/control/execution/approvals/requests/*.yml)
      run_id="${rel#.octon/state/control/execution/approvals/requests/}"
      run_id="${run_id%.yml}"
      ;;
    .octon/state/evidence/control/execution/authority-decision-*.yml)
      run_id="${rel#.octon/state/evidence/control/execution/authority-decision-}"
      run_id="${run_id%.yml}"
      ;;
    .octon/state/evidence/control/execution/authority-grant-bundle-*.yml)
      run_id="${rel#.octon/state/evidence/control/execution/authority-grant-bundle-}"
      run_id="${run_id%.yml}"
      ;;
    .octon/state/evidence/external-index/runs/*.yml)
      run_id="${rel#.octon/state/evidence/external-index/runs/}"
      run_id="${run_id%.yml}"
      ;;
    *)
      return 1
      ;;
  esac

  [[ -n "$run_id" ]] || return 1
  printf '%s\n' "$run_id"
}

proposal_inputs_root_rel() {
  printf '.octon/%s/%s/%s\n' "inputs" "exploratory" "proposals"
}

proposal_path_from_archive_contract() {
  local run_id="$1"
  local run_contract="$ROOT_DIR/.octon/state/control/execution/runs/$run_id/run-contract.yml"
  [[ -f "$run_contract" ]] || return 1

  local proposals_root
  proposals_root="$(proposal_inputs_root_rel)"

  python3 - "$ROOT_DIR" "$run_contract" "$proposals_root" <<'PY'
import sys
from pathlib import Path

root = Path(sys.argv[1]).resolve()
contract = Path(sys.argv[2])
prefix = sys.argv[3].rstrip("/") + "/"

for raw_line in contract.read_text(encoding="utf-8").splitlines():
    stripped = raw_line.strip()
    if not stripped.startswith("- "):
        continue
    value = stripped[2:].strip().strip('"').strip("'")
    if not value:
        continue
    candidate = value
    if candidate.startswith(str(root) + "/"):
        try:
            candidate = Path(candidate).resolve().relative_to(root).as_posix()
        except ValueError:
            continue
    elif candidate.startswith("./"):
        candidate = candidate[2:]
    if not candidate.startswith(prefix):
        continue
    if candidate.startswith(prefix + ".archive/") or "/.archive/" in candidate:
        continue
    print(candidate.rstrip("/"))
    sys.exit(0)

sys.exit(1)
PY
}

archived_path_for_proposal_path() {
  local proposal_path="$1"
  local proposals_root
  proposals_root="$(proposal_inputs_root_rel)"

  local remainder="${proposal_path#"$proposals_root"/}"
  local proposal_kind="${remainder%%/*}"
  local proposal_tail="${remainder#*/}"
  local proposal_id="${proposal_tail%%/*}"

  [[ -n "$proposal_kind" && -n "$proposal_id" && "$proposal_kind" != "$remainder" ]] || return 1
  printf '%s/.archive/%s/%s\n' "$proposals_root" "$proposal_kind" "$proposal_id"
}

successful_archive_workflow_summary_exists() {
  local proposal_path="$1"
  local archived_path="$2"
  local summaries_root="$ROOT_DIR/.octon/state/evidence/runs/workflows"
  local summary

  [[ -d "$summaries_root" ]] || return 1
  while IFS= read -r summary; do
    grep -Fqx -- "- workflow_id: \`archive-proposal\`" "$summary" || continue
    grep -Fqx -- "- final_verdict: \`archived\`" "$summary" || continue
    grep -Fqx -- "- proposal_path: \`$proposal_path\`" "$summary" || continue
    grep -Fqx -- "- archived_path: \`$archived_path\`" "$summary" || continue
    return 0
  done < <(find "$summaries_root" -mindepth 2 -maxdepth 2 -type f -name summary.md 2>/dev/null | sort)

  return 1
}

is_stale_archive_proposal_starter_run_id() {
  local run_id="$1"
  [[ "$run_id" == archive-proposal-* ]] || return 1

  local control_dir="$ROOT_DIR/.octon/state/control/execution/runs/$run_id"
  local runtime_state="$control_dir/runtime-state.yml"
  local start_checkpoint="$control_dir/checkpoints/execution-start.yml"
  local complete_checkpoint="$control_dir/checkpoints/execution-complete.yml"
  local run_contract="$control_dir/run-contract.yml"

  [[ -f "$runtime_state" ]] || return 1
  [[ -f "$start_checkpoint" ]] || return 1
  [[ ! -e "$complete_checkpoint" ]] || return 1
  [[ -f "$run_contract" ]] || return 1
  grep -Eq '^[[:space:]]*state:[[:space:]]*running([[:space:]]|$)' "$runtime_state" || return 1
  grep -Fq "checkpoints/execution-start.yml" "$runtime_state" || return 1
  grep -Fq "archive-proposal" "$run_contract" || return 1

  local proposal_path archived_path
  proposal_path="$(proposal_path_from_archive_contract "$run_id")" || return 1
  archived_path="$(archived_path_for_proposal_path "$proposal_path")" || return 1
  [[ -d "$ROOT_DIR/$archived_path" ]] || return 1
  successful_archive_workflow_summary_exists "$proposal_path" "$archived_path"
}

stale_archive_proposal_starter_residue_run_id() {
  local rel="$1"
  local run_id

  run_id="$(run_id_for_control_residue_path "$rel")" || return 1
  if is_stale_archive_proposal_starter_run_id "$run_id"; then
    printf '%s\n' "$run_id"
    return 0
  fi

  return 1
}

classify_path() {
  local rel="$1"

  if matches_active_run_artifact "$rel"; then
    set_classification "active_run_state" "protected" "belongs to the active lifecycle run id supplied to the cleanup helper"
    return
  fi

  if is_referenced_by_tracked_file "$rel"; then
    set_classification "$(referenced_kind_for_path "$rel")" "protected_referenced" "referenced by a tracked control, evidence, generated, or governance file"
    return
  fi

  local closed_run_id
  if closed_run_id="$(closed_workflow_run_residue_run_id "$rel")"; then
    set_classification "local_run_residue" "cleanup_candidate" "unreferenced closed workflow-engine run residue: $closed_run_id"
    return
  fi

  local stale_archive_run_id
  if stale_archive_run_id="$(stale_archive_proposal_starter_residue_run_id "$rel")"; then
    set_classification "local_run_residue" "cleanup_candidate" "unreferenced stale archive-proposal starter residue superseded by durable archive evidence: $stale_archive_run_id"
    return
  fi

  case "$rel" in
    .DS_Store|*/.DS_Store)
      set_classification "local_filesystem_metadata" "cleanup_candidate" "unreferenced local filesystem metadata"
      ;;
    .octon/generated/cognition/projections/materialized/runs/*)
      set_classification "generated_run_health_projection" "manual_review" "generated run-health pruning is generator-owned; run $RUN_HEALTH_GENERATOR_REF --all-runs"
      ;;
    .octon/state/evidence/local/terminal-closeout/*)
      set_classification "local_private_evidence" "manual_review" "terminal closeout local evidence sink is protected from generic cleanup; use an explicit local-private evidence cleanup route"
      ;;
    .octon/inputs/*)
      set_classification "input_surface" "manual_review" "raw inputs are non-authoritative and outside local cleanup authority"
      ;;
    .octon/generated/effective/*)
      set_classification "generated_authority" "manual_review" "generated effective authority outputs are never generic cleanup candidates"
      ;;
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
    .octon/state/control/execution/runs/lifecycle-proposal-*/*|\
    .octon/state/continuity/runs/lifecycle-proposal-*/*|\
    .octon/state/control/execution/approvals/requests/lifecycle-proposal-*.yml|\
    .octon/state/evidence/control/execution/authority-decision-lifecycle-proposal-*.yml|\
    .octon/state/evidence/control/execution/authority-grant-bundle-lifecycle-proposal-*.yml|\
    .octon/state/evidence/external-index/runs/lifecycle-proposal-*.yml)
      set_classification "local_run_residue" "cleanup_candidate" "unreferenced local proposal lifecycle runner residue"
      ;;
    .octon/state/evidence/runs/skills/closeout-worktree/*|\
    .octon/state/evidence/runs/skills/closeout-packet/*|\
    .octon/state/evidence/runs/skills/octon-proposal-lifecycle-closeout-packet/*)
      set_classification "local_run_residue" "cleanup_candidate" "unreferenced local closeout skill run residue"
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

while IFS= read -r rel; do
  [[ -n "$rel" ]] || continue
  CLASS_KIND=""
  CLASS_DISPOSITION=""
  CLASS_REASON=""
  classify_path "$rel"
  printf '%s\t%s\t%s\t%s\n' "$CLASS_DISPOSITION" "$CLASS_KIND" "$rel" "$CLASS_REASON" >>"$CLASSIFICATION_ROWS"
  case "$CLASS_DISPOSITION" in
    cleanup_candidate)
      printf '%s\n' "$rel" >>"$CLEANUP_PATHS"
      [[ "$SUMMARY_ONLY" -eq 1 ]] || printf 'cleanup_candidate\t%s\t%s\t%s\n' "$CLASS_KIND" "$rel" "$CLASS_REASON"
      ;;
    protected_referenced|protected)
      printf '%s\n' "$rel" >>"$PROTECTED_PATHS"
      [[ "$SUMMARY_ONLY" -eq 1 ]] || printf 'protected\t%s\t%s\t%s\n' "$CLASS_KIND" "$rel" "$CLASS_REASON"
      ;;
    manual_review)
      printf '%s\n' "$rel" >>"$MANUAL_PATHS"
      [[ "$SUMMARY_ONLY" -eq 1 ]] || printf 'manual_review\t%s\t%s\t%s\n' "$CLASS_KIND" "$rel" "$CLASS_REASON"
      ;;
    *)
      printf '%s\n' "$rel" >>"$MANUAL_PATHS"
      [[ "$SUMMARY_ONLY" -eq 1 ]] || printf 'manual_review\t%s\t%s\tunrecognized disposition %s\n' "$CLASS_KIND" "$rel" "$CLASS_DISPOSITION"
      ;;
  esac
done <"$UNTRACKED_PATHS"

sort -u "$CLASSIFICATION_ROWS" -o "$CLASSIFICATION_ROWS"
sort -u "$CLEANUP_PATHS" -o "$CLEANUP_PATHS"
sort -u "$PROTECTED_PATHS" -o "$PROTECTED_PATHS"
sort -u "$MANUAL_PATHS" -o "$MANUAL_PATHS"

select_cleanup_paths() {
  if [[ "${#REQUESTED_CLEANUP_PATH_ARGS[@]}" -eq 0 ]]; then
    cp "$CLEANUP_PATHS" "$SELECTED_CLEANUP_PATHS"
    return
  fi

  local raw rel
  for raw in "${REQUESTED_CLEANUP_PATH_ARGS[@]}"; do
    rel="${raw#./}"
    if [[ -z "$rel" || "$rel" == /* || "$rel" == "." || "$rel" == *$'\n'* ]]; then
      echo "[ERROR] --cleanup-path must be a non-empty repo-relative path: $raw" >&2
      exit 2
    fi
    case "/$rel/" in
      *"/../"*|*"/./"*|*"//"*)
        echo "[ERROR] --cleanup-path must not contain unsafe path segments: $raw" >&2
        exit 2
        ;;
    esac
    printf '%s\n' "$rel" >>"$REQUESTED_CLEANUP_PATHS"
  done
  sort -u "$REQUESTED_CLEANUP_PATHS" -o "$REQUESTED_CLEANUP_PATHS"

  while IFS= read -r rel; do
    [[ -n "$rel" ]] || continue
    if ! grep -Fxq -- "$rel" "$CLEANUP_PATHS"; then
      echo "[ERROR] requested cleanup path is not a current cleanup candidate: $rel" >&2
      exit 1
    fi
    printf '%s\n' "$rel" >>"$SELECTED_CLEANUP_PATHS"
  done <"$REQUESTED_CLEANUP_PATHS"
  sort -u "$SELECTED_CLEANUP_PATHS" -o "$SELECTED_CLEANUP_PATHS"
}

select_cleanup_paths

GIT_STATUS_DIGEST="$(digest_file "$STATUS_ROWS")"
CLASSIFICATION_DIGEST="$(digest_file "$CLASSIFICATION_ROWS")"
CLEANUP_PATH_SET_DIGEST="$(digest_file "$SELECTED_CLEANUP_PATHS")"
PROTECTED_PATHS_DIGEST="$(digest_file "$PROTECTED_PATHS")"
MANUAL_REVIEW_PATHS_DIGEST="$(digest_file "$MANUAL_PATHS")"

count_lines() {
  local file="$1"
  if [[ -s "$file" ]]; then
    wc -l <"$file" | tr -d ' '
  else
    echo 0
  fi
}

eligible_cleanup_count="$(count_lines "$CLEANUP_PATHS")"
cleanup_count="$(count_lines "$SELECTED_CLEANUP_PATHS")"
protected_count="$(count_lines "$PROTECTED_PATHS")"
manual_count="$(count_lines "$MANUAL_PATHS")"

write_authorization_receipt() {
  local out="$1"
  mkdir -p "$(dirname -- "$out")"
  CREATED_AT="$(date -u '+%Y-%m-%dT%H:%M:%SZ')" \
  ROOT_DIR="$ROOT_DIR" \
  POLICY_REF="$POLICY_REF" \
  HELPER_REF="$HELPER_REF" \
  SCHEMA_REF="$SCHEMA_REF" \
  HEAD_REF="$HEAD_REF" \
  MAIN_REF="$MAIN_REF" \
  ORIGIN_MAIN_REF="$ORIGIN_MAIN_REF" \
  GIT_STATUS_DIGEST="$GIT_STATUS_DIGEST" \
  CLASSIFICATION_DIGEST="$CLASSIFICATION_DIGEST" \
  CLEANUP_PATH_SET_DIGEST="$CLEANUP_PATH_SET_DIGEST" \
  PROTECTED_PATHS_DIGEST="$PROTECTED_PATHS_DIGEST" \
  MANUAL_REVIEW_PATHS_DIGEST="$MANUAL_REVIEW_PATHS_DIGEST" \
  CLASSIFICATION_ROWS="$CLASSIFICATION_ROWS" \
  CLEANUP_PATHS="$SELECTED_CLEANUP_PATHS" \
  OUT="$out" \
  python3 - <<'PY'
import hashlib
import json
import os
from pathlib import Path

def read_lines(path):
    path = Path(path)
    if not path.exists():
        return []
    return [line.rstrip("\n") for line in path.read_text(encoding="utf-8").splitlines() if line.rstrip("\n")]

rows = {}
for row in read_lines(os.environ["CLASSIFICATION_ROWS"]):
    parts = row.split("\t", 3)
    if len(parts) == 4:
        disposition, kind, path, reason = parts
        rows[path] = {"disposition": disposition, "class": kind, "reason": reason}

authorized_paths = []
for rel in read_lines(os.environ["CLEANUP_PATHS"]):
    kind = rows.get(rel, {}).get("class", "cleanup_candidate")
    authorized_paths.append(
        {
            "path": rel,
            "class": kind,
            "pattern_id": kind,
            "proofs": {
                "untracked": True,
                "unreferenced_by_tracked_files": True,
                "non_authoritative": True,
                "allowed_cleanup_pattern": True,
                "not_input_surface": True,
                "not_durable_evidence": True,
                "not_active_control_state": True,
                "not_generated_authority": True,
                "not_generated_run_health_projection": True,
                "not_ignored_or_user_owned_residue": True,
            },
        }
    )

authorization_id_source = "\n".join(
    [
        os.environ["CREATED_AT"],
        os.environ["HEAD_REF"],
        os.environ["GIT_STATUS_DIGEST"],
        os.environ["CLEANUP_PATH_SET_DIGEST"],
    ]
)
authorization_id = "repo-hygiene-cleanup-" + hashlib.sha256(authorization_id_source.encode("utf-8")).hexdigest()[:16]
receipt = {
    "schema_version": "repo-hygiene-cleanup-authorization-v1",
    "authorization_id": authorization_id,
    "authorization_result": "approved" if authorized_paths else "denied",
    "created_at": os.environ["CREATED_AT"],
    "valid_until_status_changes": True,
    "policy_ref": os.environ["POLICY_REF"],
    "helper_ref": os.environ["HELPER_REF"],
    "schema_ref": os.environ["SCHEMA_REF"],
    "repo_root_ref": ".",
    "head_ref": os.environ["HEAD_REF"],
    "main_ref": os.environ["MAIN_REF"],
    "origin_main_ref": os.environ["ORIGIN_MAIN_REF"],
    "git_status_digest": os.environ["GIT_STATUS_DIGEST"],
    "classification_ref": "inline:cleanup-local-run-artifacts.sh",
    "classification_digest": os.environ["CLASSIFICATION_DIGEST"],
    "cleanup_path_set_digest": os.environ["CLEANUP_PATH_SET_DIGEST"],
    "authorized_paths": authorized_paths,
    "protected_paths_digest": os.environ["PROTECTED_PATHS_DIGEST"],
    "manual_review_paths_digest": os.environ["MANUAL_REVIEW_PATHS_DIGEST"],
    "discard_or_rollback_posture": "delete only the exact untracked authorized path set; retain protected and manual-review residue",
    "runtime_safety_boundary": "Octon governance receipt does not bypass filesystem, sandbox, host, provider, or platform permission boundaries.",
}
Path(os.environ["OUT"]).write_text(json.dumps(receipt, indent=2, sort_keys=True) + "\n", encoding="utf-8")
PY
  echo "[OK] wrote cleanup authorization receipt: $out"
}

validate_authorization_receipt() {
  local receipt="$1"
  RECEIPT="$receipt" \
  POLICY_REF="$POLICY_REF" \
  HELPER_REF="$HELPER_REF" \
  SCHEMA_REF="$SCHEMA_REF" \
  HEAD_REF="$HEAD_REF" \
  MAIN_REF="$MAIN_REF" \
  ORIGIN_MAIN_REF="$ORIGIN_MAIN_REF" \
  GIT_STATUS_DIGEST="$GIT_STATUS_DIGEST" \
  CLASSIFICATION_DIGEST="$CLASSIFICATION_DIGEST" \
  CLEANUP_PATH_SET_DIGEST="$CLEANUP_PATH_SET_DIGEST" \
  PROTECTED_PATHS_DIGEST="$PROTECTED_PATHS_DIGEST" \
  MANUAL_REVIEW_PATHS_DIGEST="$MANUAL_REVIEW_PATHS_DIGEST" \
  ALL_CLEANUP_PATHS="$CLEANUP_PATHS" \
  SELECTED_CLEANUP_PATHS="$SELECTED_CLEANUP_PATHS" \
  AUTHORIZED_PATHS="$AUTHORIZED_PATHS" \
  python3 - <<'PY'
import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path, PurePosixPath

def fail(message):
    print(f"[ERROR] {message}", file=sys.stderr)
    sys.exit(1)

def read_lines(path):
    path = Path(path)
    if not path.exists():
        return []
    return [line.rstrip("\n") for line in path.read_text(encoding="utf-8").splitlines() if line.rstrip("\n")]

receipt_path = Path(os.environ["RECEIPT"])
try:
    receipt = json.loads(receipt_path.read_text(encoding="utf-8"))
except Exception as exc:
    fail(f"authorization receipt is malformed or unreadable: {exc}")

if not isinstance(receipt, dict):
    fail("authorization receipt root must be an object")

required = [
    "schema_version",
    "authorization_id",
    "authorization_result",
    "created_at",
    "policy_ref",
    "helper_ref",
    "schema_ref",
    "repo_root_ref",
    "head_ref",
    "main_ref",
    "origin_main_ref",
    "git_status_digest",
    "classification_ref",
    "classification_digest",
    "cleanup_path_set_digest",
    "authorized_paths",
    "protected_paths_digest",
    "manual_review_paths_digest",
    "discard_or_rollback_posture",
    "runtime_safety_boundary",
]
for key in required:
    if key not in receipt:
        fail(f"authorization receipt missing required field: {key}")

allowed_top_level = set(required) | {"expires_at", "valid_until_status_changes"}
unexpected_top_level = sorted(set(receipt) - allowed_top_level)
if unexpected_top_level:
    fail(f"authorization receipt contains schema-invalid fields: {', '.join(unexpected_top_level)}")

if receipt.get("schema_version") != "repo-hygiene-cleanup-authorization-v1":
    fail("authorization receipt schema_version is invalid")
if receipt.get("authorization_result") != "approved":
    fail("authorization receipt is denied or not approved")
if "valid_until_status_changes" in receipt and receipt.get("valid_until_status_changes") is not True:
    fail("authorization receipt valid_until_status_changes must be true when present")
if receipt.get("valid_until_status_changes") is not True and not receipt.get("expires_at"):
    fail("authorization receipt must declare valid_until_status_changes or expires_at")
if receipt.get("repo_root_ref") != ".":
    fail("authorization receipt repo_root_ref must be .")
try:
    datetime.fromisoformat(str(receipt["created_at"]).replace("Z", "+00:00"))
except Exception as exc:
    fail(f"authorization receipt created_at is invalid: {exc}")
if receipt.get("expires_at"):
    try:
        expires_at = datetime.fromisoformat(str(receipt["expires_at"]).replace("Z", "+00:00"))
    except Exception as exc:
        fail(f"authorization receipt expires_at is invalid: {exc}")
    if expires_at.tzinfo is None:
        expires_at = expires_at.replace(tzinfo=timezone.utc)
    if expires_at <= datetime.now(timezone.utc):
        fail("authorization receipt is expired")

expected = {
    "policy_ref": os.environ["POLICY_REF"],
    "helper_ref": os.environ["HELPER_REF"],
    "schema_ref": os.environ["SCHEMA_REF"],
    "head_ref": os.environ["HEAD_REF"],
    "main_ref": os.environ["MAIN_REF"],
    "origin_main_ref": os.environ["ORIGIN_MAIN_REF"],
    "git_status_digest": os.environ["GIT_STATUS_DIGEST"],
    "classification_digest": os.environ["CLASSIFICATION_DIGEST"],
    "cleanup_path_set_digest": os.environ["CLEANUP_PATH_SET_DIGEST"],
    "protected_paths_digest": os.environ["PROTECTED_PATHS_DIGEST"],
    "manual_review_paths_digest": os.environ["MANUAL_REVIEW_PATHS_DIGEST"],
}
for key, value in expected.items():
    if receipt.get(key) != value:
        fail(f"authorization receipt is stale or mismatched: {key}")

authorized = receipt.get("authorized_paths")
if not isinstance(authorized, list) or not authorized:
    fail("authorization receipt must approve a non-empty path set")

current_paths = read_lines(os.environ["ALL_CLEANUP_PATHS"])
selected_paths = read_lines(os.environ["SELECTED_CLEANUP_PATHS"])
receipt_paths = []
required_proofs = [
    "untracked",
    "unreferenced_by_tracked_files",
    "non_authoritative",
    "allowed_cleanup_pattern",
    "not_input_surface",
    "not_durable_evidence",
    "not_active_control_state",
    "not_generated_authority",
    "not_generated_run_health_projection",
    "not_ignored_or_user_owned_residue",
]

for index, item in enumerate(authorized):
    if not isinstance(item, dict):
        fail(f"authorized_paths[{index}] must be an object")
    unexpected_item_fields = sorted(set(item) - {"path", "class", "pattern_id", "proofs"})
    if unexpected_item_fields:
        fail(f"authorized_paths[{index}] contains schema-invalid fields: {', '.join(unexpected_item_fields)}")
    path = item.get("path")
    if not isinstance(path, str) or not path:
        fail(f"authorized_paths[{index}].path must be non-empty")
    parsed = PurePosixPath(path)
    if parsed.is_absolute() or ".." in parsed.parts:
        fail(f"authorized path must be repo-relative and safe: {path}")
    item_class = item.get("class")
    is_local_filesystem_metadata = item_class == "local_filesystem_metadata" and path.endswith("/.DS_Store")
    if path.startswith(".octon/state/evidence/local/terminal-closeout/"):
        fail(f"terminal closeout local evidence sink cannot be authorized by generic cleanup: {path}")
    if path.startswith(".octon/inputs/") and not is_local_filesystem_metadata:
        fail(f"input-surface path cannot be authorized: {path}")
    if path.startswith(".octon/generated/effective/"):
        fail(f"generated authority path cannot be authorized: {path}")
    if path.startswith(".octon/generated/cognition/projections/materialized/runs/"):
        fail(f"generated run-health path must route to generator-owned pruning: {path}")
    if not isinstance(item_class, str) or not item_class:
        fail(f"authorized_paths[{index}].class must be non-empty")
    if not isinstance(item.get("pattern_id"), str) or not item["pattern_id"]:
        fail(f"authorized_paths[{index}].pattern_id must be non-empty")
    proofs = item.get("proofs")
    if not isinstance(proofs, dict):
        fail(f"authorized_paths[{index}].proofs must be an object")
    unexpected_proofs = sorted(set(proofs) - set(required_proofs))
    if unexpected_proofs:
        fail(f"authorized_paths[{index}].proofs contains schema-invalid fields: {', '.join(unexpected_proofs)}")
    for proof in required_proofs:
        if proofs.get(proof) is not True:
            fail(f"authorized_paths[{index}].proofs.{proof} must be true")
    receipt_paths.append(path)

receipt_paths = sorted(receipt_paths)
if receipt_paths != selected_paths:
    fail("authorization receipt path set does not match selected cleanup candidates exactly")
current_path_set = set(current_paths)
for path in receipt_paths:
    if path not in current_path_set:
        fail(f"authorized path is not a current cleanup candidate: {path}")

path_set_payload = "".join(f"{path}\n" for path in receipt_paths).encode("utf-8")
path_set_digest = "sha256:" + __import__("hashlib").sha256(path_set_payload).hexdigest()
if receipt.get("cleanup_path_set_digest") != path_set_digest:
    fail("authorization receipt cleanup_path_set_digest does not match selected authorized paths")

Path(os.environ["AUTHORIZED_PATHS"]).write_text("\n".join(receipt_paths) + ("\n" if receipt_paths else ""), encoding="utf-8")
PY
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

mode="dry-run"
if [[ "$CONFIRM" -eq 1 ]]; then
  mode="confirm"
elif [[ -n "$AUTHORIZE_OUT" ]]; then
  mode="authorize"
elif [[ -n "$AUTHORIZATION_RECEIPT" ]]; then
  mode="authorization"
fi

echo "summary:"
echo "  mode: $mode"
echo "  cleanup_candidates: $cleanup_count"
echo "  eligible_cleanup_candidates: $eligible_cleanup_count"
echo "  protected_referenced: $protected_count"
echo "  manual_review: $manual_count"
echo "  git_status_digest: $GIT_STATUS_DIGEST"
echo "  classification_digest: $CLASSIFICATION_DIGEST"
echo "  cleanup_path_set_digest: $CLEANUP_PATH_SET_DIGEST"
echo "  protected_paths_digest: $PROTECTED_PATHS_DIGEST"
echo "  manual_review_paths_digest: $MANUAL_REVIEW_PATHS_DIGEST"

if [[ -n "$AUTHORIZE_OUT" ]]; then
  write_authorization_receipt "$AUTHORIZE_OUT"
  if [[ "$cleanup_count" -eq 0 ]]; then
    echo "[WARN] denied authorization because no cleanup candidates are present"
  fi
  exit 0
fi

if [[ -n "$AUTHORIZATION_RECEIPT" ]]; then
  validate_authorization_receipt "$AUTHORIZATION_RECEIPT"
  while IFS= read -r rel; do
    [[ -n "$rel" ]] || continue
    if [[ ! -f "$ROOT_DIR/$rel" && ! -L "$ROOT_DIR/$rel" ]]; then
      echo "[ERROR] authorized cleanup candidate no longer exists as a file: $rel" >&2
      exit 1
    fi
    if git -C "$ROOT_DIR" ls-files --error-unmatch -- "$rel" >/dev/null 2>&1; then
      echo "[ERROR] authorized cleanup candidate is now tracked: $rel" >&2
      exit 1
    fi
  done <"$AUTHORIZED_PATHS"
  while IFS= read -r rel; do
    [[ -n "$rel" ]] || continue
    rm -f -- "$ROOT_DIR/$rel"
    prune_empty_parents "$rel"
    echo "removed: $rel"
  done <"$AUTHORIZED_PATHS"
  echo "[OK] removed $(count_lines "$AUTHORIZED_PATHS") cleanup candidate file(s) via validating authorization receipt; protected and manual-review files were retained"
elif [[ "$CONFIRM" -eq 1 ]]; then
  while IFS= read -r rel; do
    [[ -n "$rel" ]] || continue
    if [[ -f "$ROOT_DIR/$rel" || -L "$ROOT_DIR/$rel" ]]; then
      rm -f -- "$ROOT_DIR/$rel"
      prune_empty_parents "$rel"
      echo "removed: $rel"
    else
      echo "[WARN] cleanup candidate no longer exists as a file: $rel"
    fi
  done <"$SELECTED_CLEANUP_PATHS"
  echo "[OK] removed $cleanup_count cleanup candidate file(s); protected and manual-review files were retained"
else
  echo "[OK] dry-run complete; rerun with --confirm or --authorization <receipt.json> to remove cleanup candidates only"
fi

if [[ "$FAIL_ON_MANUAL" -eq 1 && "$manual_count" -gt 0 ]]; then
  echo "[ERROR] manual-review artifacts remain" >&2
  exit 1
fi
