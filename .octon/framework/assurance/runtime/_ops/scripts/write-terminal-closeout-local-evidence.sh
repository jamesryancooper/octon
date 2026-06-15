#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
PROOF_VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-terminal-current-state-proof.sh"
MANIFEST_VALIDATOR="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-terminal-closeout-local-evidence.sh"
CLASSIFIER="$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/classify-change-closeout-residue.sh"

CHANGE_ID=""
PROOF=""
RECEIPT=""
LANDED_REF=""
LANDING_AUTHORIZATION=""
CLEANUP_AUTHORIZATION=""
SOURCE_BRANCH=""
SELECTED_ROUTE=""
TARGET_LIFECYCLE_OUTCOME=""
LIFECYCLE_OUTCOME=""
ROLLBACK_HANDLE=""

usage() {
  cat <<'USAGE'
usage:
  write-terminal-closeout-local-evidence.sh \
    --change-id <id> \
    --selected-route <route> \
    --target-lifecycle-outcome <outcome> \
    --lifecycle-outcome <outcome> \
    --landed-ref <sha> \
    --source-branch <branch> \
    --landing-authorization <landing-authorization.json> \
    --cleanup-authorization <branch-cleanup-authorization.json> \
    --rollback-handle <handle>

  write-terminal-closeout-local-evidence.sh \
    --change-id <id> \
    --proof <terminal-current-state-proof.yml> \
    --receipt <change-receipt.json> \
    --landed-ref <sha> \
    [--landing-authorization <landing-authorization.json>] \
    [--cleanup-authorization <branch-cleanup-authorization.json>] \
    [--source-branch <branch>]

If --proof and --receipt are supplied, the helper snapshots those files. Without
--proof/--receipt, it synthesizes a local terminal proof and local final receipt
from current repo state after landing, sync, cleanup, and final hygiene.

Writes final terminal closeout snapshots under:
  .octon/state/evidence/local/terminal-closeout/<change-id>/

The sink is local/operator evidence only. It is ignored by git and is never
landing authority, cleanup authority, hosted check evidence, packet evidence,
archive evidence, generated-publication evidence, or policy authority.
USAGE
}

require_tool() {
  local tool="$1"
  command -v "$tool" >/dev/null 2>&1 || {
    echo "[ERROR] $tool is required" >&2
    exit 1
  }
}

resolve_path() {
  local path="$1"
  case "$path" in
    /*) printf '%s\n' "$path" ;;
    *) printf '%s/%s\n' "$ROOT_DIR" "$path" ;;
  esac
}

repo_relative_path() {
  local path="$1"
  python3 - "$ROOT_DIR" "$path" <<'PY'
import sys
from pathlib import Path

root = Path(sys.argv[1]).resolve()
path = Path(sys.argv[2]).resolve()
try:
    print(path.relative_to(root).as_posix())
except ValueError:
    sys.exit(1)
PY
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

copy_snapshot() {
  local source="$1"
  local destination="$2"
  local tmp
  tmp="$destination.tmp.$$"
  cp -- "$source" "$tmp"
  mv -- "$tmp" "$destination"
}

write_text_snapshot() {
  local destination="$1"
  local tmp
  tmp="$destination.tmp.$$"
  cat >"$tmp"
  mv -- "$tmp" "$destination"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --change-id)
      shift
      CHANGE_ID="${1:-}"
      ;;
    --proof)
      shift
      PROOF="${1:-}"
      ;;
    --receipt)
      shift
      RECEIPT="${1:-}"
      ;;
    --landed-ref)
      shift
      LANDED_REF="${1:-}"
      ;;
    --landing-authorization)
      shift
      LANDING_AUTHORIZATION="${1:-}"
      ;;
    --cleanup-authorization)
      shift
      CLEANUP_AUTHORIZATION="${1:-}"
      ;;
    --source-branch)
      shift
      SOURCE_BRANCH="${1:-}"
      ;;
    --selected-route)
      shift
      SELECTED_ROUTE="${1:-}"
      ;;
    --target-lifecycle-outcome)
      shift
      TARGET_LIFECYCLE_OUTCOME="${1:-}"
      ;;
    --lifecycle-outcome)
      shift
      LIFECYCLE_OUTCOME="${1:-}"
      ;;
    --rollback-handle)
      shift
      ROLLBACK_HANDLE="${1:-}"
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

SNAPSHOT_MODE=0
if [[ -n "$PROOF" || -n "$RECEIPT" ]]; then
  SNAPSHOT_MODE=1
fi

if [[ "$SNAPSHOT_MODE" -eq 1 ]]; then
  [[ -n "$CHANGE_ID" && -n "$PROOF" && -n "$RECEIPT" && -n "$LANDED_REF" ]] || {
    usage >&2
    exit 2
  }
else
  [[ -n "$CHANGE_ID" && -n "$LANDED_REF" && -n "$SELECTED_ROUTE" && -n "$TARGET_LIFECYCLE_OUTCOME" && -n "$LIFECYCLE_OUTCOME" && -n "$ROLLBACK_HANDLE" ]] || {
    usage >&2
    exit 2
  }
fi

[[ "$SNAPSHOT_MODE" -eq 1 || "$LIFECYCLE_OUTCOME" == "cleaned" ]] || {
  echo "[ERROR] synthesize mode currently supports lifecycle-outcome cleaned only" >&2
  exit 2
}

[[ "$SNAPSHOT_MODE" -eq 1 || "$TARGET_LIFECYCLE_OUTCOME" == "cleaned" ]] || {
  echo "[ERROR] synthesize mode currently supports target-lifecycle-outcome cleaned only" >&2
  exit 2
}

[[ "$SNAPSHOT_MODE" -eq 1 || "$SELECTED_ROUTE" =~ ^(branch-no-pr|branch-pr|direct-main)$ ]] || {
  echo "[ERROR] synthesize mode selected route must be direct-main, branch-no-pr, or branch-pr" >&2
  exit 2
}

[[ "$SNAPSHOT_MODE" -eq 1 || -n "$SOURCE_BRANCH" ]] || {
  echo "[ERROR] synthesize mode requires --source-branch" >&2
  exit 2
}

[[ "$SNAPSHOT_MODE" -eq 1 || -n "$LANDING_AUTHORIZATION" ]] || {
  echo "[ERROR] synthesize mode requires --landing-authorization" >&2
  exit 2
}

[[ "$SNAPSHOT_MODE" -eq 1 || -n "$CLEANUP_AUTHORIZATION" ]] || {
  echo "[ERROR] synthesize mode requires --cleanup-authorization" >&2
  exit 2
}

[[ -n "$CHANGE_ID" && -n "$LANDED_REF" ]] || {
  usage >&2
  exit 2
}

[[ "$CHANGE_ID" =~ ^[A-Za-z0-9._:-]+$ ]] || {
  echo "[ERROR] --change-id contains unsupported characters: $CHANGE_ID" >&2
  exit 2
}

[[ "$LANDED_REF" =~ ^[0-9a-f]{40}$ ]] || {
  echo "[ERROR] --landed-ref must be a 40-character lowercase SHA: $LANDED_REF" >&2
  exit 2
}

require_tool git
require_tool jq
require_tool yq
require_tool python3
require_tool shasum

SINK_REL=".octon/state/evidence/local/terminal-closeout/$CHANGE_ID"
SINK_DIR="$ROOT_DIR/$SINK_REL"
mkdir -p "$SINK_DIR"

if [[ -n "$LANDING_AUTHORIZATION" ]]; then
  LANDING_AUTHORIZATION="$(resolve_path "$LANDING_AUTHORIZATION")"
  [[ -f "$LANDING_AUTHORIZATION" ]] || { echo "[ERROR] landing authorization file missing: $LANDING_AUTHORIZATION" >&2; exit 1; }
fi

if [[ -n "$CLEANUP_AUTHORIZATION" ]]; then
  CLEANUP_AUTHORIZATION="$(resolve_path "$CLEANUP_AUTHORIZATION")"
  [[ -f "$CLEANUP_AUTHORIZATION" ]] || { echo "[ERROR] cleanup authorization file missing: $CLEANUP_AUTHORIZATION" >&2; exit 1; }
fi

HEAD_REF="$(git_ref_or_unavailable HEAD)"
MAIN_REF="$(git_ref_or_unavailable main)"
ORIGIN_MAIN_REF="$(git_ref_or_unavailable origin/main)"

if [[ "$SNAPSHOT_MODE" -eq 1 ]]; then
  PROOF="$(resolve_path "$PROOF")"
  RECEIPT="$(resolve_path "$RECEIPT")"
  [[ -f "$PROOF" ]] || { echo "[ERROR] proof file missing: $PROOF" >&2; exit 1; }
  [[ -f "$RECEIPT" ]] || { echo "[ERROR] receipt file missing: $RECEIPT" >&2; exit 1; }
else
  [[ "$HEAD_REF" == "$LANDED_REF" && "$MAIN_REF" == "$LANDED_REF" && "$ORIGIN_MAIN_REF" == "$LANDED_REF" ]] || {
    echo "[ERROR] synthesize mode requires HEAD, main, origin/main, and landed-ref to match" >&2
    exit 1
  }
  visible_status="$(git -C "$ROOT_DIR" status --short --untracked-files=all | grep -v '^##' || true)"
  [[ -z "$visible_status" ]] || {
    echo "[ERROR] synthesize mode requires a clean non-ignored worktree before writing local terminal evidence" >&2
    printf '%s\n' "$visible_status" >&2
    exit 1
  }
  if git -C "$ROOT_DIR" show-ref --verify --quiet "refs/heads/$SOURCE_BRANCH"; then
    echo "[ERROR] synthesize mode requires local source branch to be absent: $SOURCE_BRANCH" >&2
    exit 1
  fi
  remote_source_ref="$(git -C "$ROOT_DIR" ls-remote --heads origin "$SOURCE_BRANCH" 2>/dev/null || true)"
  [[ -z "$remote_source_ref" ]] || {
    echo "[ERROR] synthesize mode requires remote source branch to be absent: $SOURCE_BRANCH" >&2
    printf '%s\n' "$remote_source_ref" >&2
    exit 1
  }

  PROOF="$(mktemp "${TMPDIR:-/tmp}/terminal-current-state-proof.XXXXXX.yml")"
  RECEIPT="$(mktemp "${TMPDIR:-/tmp}/terminal-change-receipt.XXXXXX.json")"
  trap 'rm -f "$PROOF" "$RECEIPT"' EXIT
  observed_at="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  cat >"$PROOF" <<YAML
schema_version: lifecycle-terminal-current-state-proof-v1
proof_id: terminal-proof-$CHANGE_ID-$LANDED_REF
observed_at: "$observed_at"
change_id: $CHANGE_ID
lifecycle_outcome: cleaned
non_authority_classification: retained-evidence-only
final_refs:
  head_ref: $HEAD_REF
  main_ref: $MAIN_REF
  origin_main_ref: $ORIGIN_MAIN_REF
  landed_ref: $LANDED_REF
alignment:
  head_equals_local_main: true
  local_main_equals_origin_main: true
  origin_main_contains_landed_ref: true
  local_main_contains_landed_ref: true
worktree:
  status: clean
  status_ref: $SINK_REL/status.txt
  residue_counts:
    staged: 0
    unstaged: 0
    untracked: 0
cleanup_classifier_ref: $SINK_REL/residue-classification.yml
validator_refs:
  - validator: git-status
    command: git status --short --branch --untracked-files=all
    cwd: $ROOT_DIR
    runtime: git
    exit_code: 0
    evidence_ref: $SINK_REL/status.txt
  - validator: classify-change-closeout-residue
    command: bash .octon/framework/assurance/runtime/_ops/scripts/classify-change-closeout-residue.sh --root .
    cwd: $ROOT_DIR
    runtime: bash
    exit_code: 0
    evidence_ref: $SINK_REL/residue-classification.yml
evidence_refs:
  - $SINK_REL/refs.txt
  - $SINK_REL/status.txt
  - $SINK_REL/residue-classification.yml
  - $(repo_relative_path "$LANDING_AUTHORIZATION")
  - $(repo_relative_path "$CLEANUP_AUTHORIZATION")
YAML
  proof_digest_for_receipt="$(digest_file "$PROOF")"
  landing_authorization_ref="$(repo_relative_path "$LANDING_AUTHORIZATION")"
  cleanup_authorization_ref="$(repo_relative_path "$CLEANUP_AUTHORIZATION")"
  python3 - "$RECEIPT" <<PY
import json
import sys

receipt = {
    "schema_version": "change-receipt-v1",
    "change_id": "$CHANGE_ID",
    "selected_route": "$SELECTED_ROUTE",
    "target_lifecycle_outcome": "$TARGET_LIFECYCLE_OUTCOME",
    "lifecycle_outcome": "$LIFECYCLE_OUTCOME",
    "outcome_intent": "attempt-cleaned-closeout",
    "intent": "Local terminal closeout receipt retained in ignored terminal evidence sink.",
    "scope": {"summary": "Terminal Closeout Evidence Sink implementation Change local terminal closeout."},
    "source_branch_ref": "$SOURCE_BRANCH",
    "target_branch_ref": "origin/main@$LANDED_REF",
    "landing_authorization_ref": "$landing_authorization_ref",
    "cleanup_authorization_ref": "$cleanup_authorization_ref",
    "landed_ref": "$LANDED_REF",
    "main_alignment": {
        "local_main_ref": "$MAIN_REF",
        "origin_main_ref": "$ORIGIN_MAIN_REF",
        "landed_ref": "$LANDED_REF",
        "aligned": True,
        "origin_main_contains_landed_ref": True,
        "local_main_contains_landed_ref": True,
        "origin_fetch_evidence_ref": "$SINK_REL/refs.txt",
        "local_main_sync_evidence_ref": "$SINK_REL/refs.txt",
    },
    "integration_method": "fast-forward",
    "integration_status": "landed",
    "publication_status": "hosted-main-updated",
    "cleanup_status": "completed",
    "source_branch_cleanup": {
        "status": "completed",
        "local_branch": "$SOURCE_BRANCH",
        "remote_branch": "origin/$SOURCE_BRANCH",
        "evidence_refs": ["$SINK_REL/refs.txt"],
    },
    "terminal_current_state_proof_ref": "$SINK_REL/terminal-current-state-proof.yml",
    "terminal_current_state_proof_digest": "$proof_digest_for_receipt",
    "validation_evidence_refs": [
        "validate-evidence-disclosure-tiers.sh",
        "validate-change-closeout-state-machine.sh",
        "validate-hosted-no-pr-landing.sh",
        "validate-change-closeout-lifecycle-alignment.sh",
        "validate-repo-hygiene-governance.sh",
        "validate-closeout-worktree-wrapper.sh",
    ],
    "durable_history": {"kind": "commit", "ref": "$LANDED_REF", "branch": "$SOURCE_BRANCH"},
    "rollback_handle": {"kind": "manual-instructions", "instructions": "$ROLLBACK_HANDLE"},
    "closeout_outcome": "completed",
    "stateful_closeout": {
        "state_machine_version": "change-closeout-state-machine-v1",
        "initial_inventory_ref": "$SINK_REL/status.txt",
        "residue_classification_ref": "$SINK_REL/residue-classification.yml",
        "phase_exit_refs": ["$SINK_REL/refs.txt"],
        "cleanup_decision_refs": ["$cleanup_authorization_ref"],
        "safe_cleanup_evidence_class": "origin-main-containment",
        "hosted_landing_refs": ["$landing_authorization_ref"],
        "branch_cleanup_refs": ["$cleanup_authorization_ref"],
        "final_verification_ref": "terminal-local-evidence-digest:$proof_digest_for_receipt",
    },
    "created_at": "$observed_at",
}
with open(sys.argv[1], "w", encoding="utf-8") as handle:
    json.dump(receipt, handle, indent=2, sort_keys=True)
    handle.write("\\n")
PY
fi

"$PROOF_VALIDATOR" --proof "$PROOF" --require-cleaned >/dev/null

proof_change_id="$(yq -r '.change_id // ""' "$PROOF")"
proof_landed_ref="$(yq -r '.final_refs.landed_ref // ""' "$PROOF")"
proof_non_authority="$(yq -r '.non_authority_classification // ""' "$PROOF")"

[[ "$proof_change_id" == "$CHANGE_ID" ]] || {
  echo "[ERROR] proof change_id does not match --change-id" >&2
  exit 1
}
[[ "$proof_landed_ref" == "$LANDED_REF" ]] || {
  echo "[ERROR] proof landed_ref does not match --landed-ref" >&2
  exit 1
}
[[ "$proof_non_authority" == "retained-evidence-only" ]] || {
  echo "[ERROR] proof must declare non_authority_classification: retained-evidence-only" >&2
  exit 1
}

jq -e '.' "$RECEIPT" >/dev/null
receipt_change_id="$(jq -r '.change_id // ""' "$RECEIPT")"
receipt_landed_ref="$(jq -r '.landed_ref // ""' "$RECEIPT")"
[[ "$receipt_change_id" == "$CHANGE_ID" ]] || {
  echo "[ERROR] receipt change_id does not match --change-id" >&2
  exit 1
}
[[ "$receipt_landed_ref" == "$LANDED_REF" ]] || {
  echo "[ERROR] receipt landed_ref does not match --landed-ref" >&2
  exit 1
}

PROOF_COPY="$SINK_DIR/terminal-current-state-proof.yml"
RECEIPT_COPY="$SINK_DIR/change-receipt.json"
REFS_COPY="$SINK_DIR/refs.txt"
STATUS_COPY="$SINK_DIR/status.txt"
CLASSIFICATION_COPY="$SINK_DIR/residue-classification.yml"
MANIFEST="$SINK_DIR/manifest.json"

copy_snapshot "$PROOF" "$PROOF_COPY"
copy_snapshot "$RECEIPT" "$RECEIPT_COPY"

LANDING_COPY=""
if [[ -n "$LANDING_AUTHORIZATION" ]]; then
  LANDING_COPY="$SINK_DIR/landing-authorization.json"
  copy_snapshot "$LANDING_AUTHORIZATION" "$LANDING_COPY"
fi

CLEANUP_COPY=""
if [[ -n "$CLEANUP_AUTHORIZATION" ]]; then
  CLEANUP_COPY="$SINK_DIR/branch-cleanup-authorization.json"
  copy_snapshot "$CLEANUP_AUTHORIZATION" "$CLEANUP_COPY"
fi

{
  printf 'HEAD=%s\n' "$HEAD_REF"
  printf 'main=%s\n' "$MAIN_REF"
  printf 'origin/main=%s\n' "$ORIGIN_MAIN_REF"
  printf 'landed_ref=%s\n' "$LANDED_REF"
  printf 'source_branch=%s\n' "${SOURCE_BRANCH:-not-recorded}"
} | write_text_snapshot "$REFS_COPY"

git -C "$ROOT_DIR" status --short --branch --untracked-files=all | write_text_snapshot "$STATUS_COPY"
"$CLASSIFIER" --root "$ROOT_DIR" | write_text_snapshot "$CLASSIFICATION_COPY"

PROOF_DIGEST="$(digest_file "$PROOF_COPY")"
RECEIPT_DIGEST="$(digest_file "$RECEIPT_COPY")"
REFS_DIGEST="$(digest_file "$REFS_COPY")"
STATUS_DIGEST="$(digest_file "$STATUS_COPY")"
CLASSIFICATION_DIGEST="$(digest_file "$CLASSIFICATION_COPY")"

MANIFEST_TMP="$MANIFEST.tmp.$$"
CREATED_AT="$(date -u '+%Y-%m-%dT%H:%M:%SZ')" \
ROOT_DIR="$ROOT_DIR" \
CHANGE_ID="$CHANGE_ID" \
SINK_REL="$SINK_REL" \
PROOF_REL="$(repo_relative_path "$PROOF_COPY")" \
RECEIPT_REL="$(repo_relative_path "$RECEIPT_COPY")" \
LANDING_REL="$([[ -n "$LANDING_COPY" ]] && repo_relative_path "$LANDING_COPY" || true)" \
CLEANUP_REL="$([[ -n "$CLEANUP_COPY" ]] && repo_relative_path "$CLEANUP_COPY" || true)" \
REFS_REL="$(repo_relative_path "$REFS_COPY")" \
STATUS_REL="$(repo_relative_path "$STATUS_COPY")" \
CLASSIFICATION_REL="$(repo_relative_path "$CLASSIFICATION_COPY")" \
HEAD_REF="$HEAD_REF" \
MAIN_REF="$MAIN_REF" \
ORIGIN_MAIN_REF="$ORIGIN_MAIN_REF" \
LANDED_REF="$LANDED_REF" \
SOURCE_BRANCH="$SOURCE_BRANCH" \
PROOF_DIGEST="$PROOF_DIGEST" \
RECEIPT_DIGEST="$RECEIPT_DIGEST" \
REFS_DIGEST="$REFS_DIGEST" \
STATUS_DIGEST="$STATUS_DIGEST" \
CLASSIFICATION_DIGEST="$CLASSIFICATION_DIGEST" \
OUT="$MANIFEST_TMP" \
python3 - <<'PY'
import hashlib
import json
import os
from pathlib import Path

root = Path(os.environ["ROOT_DIR"])
change_id = os.environ["CHANGE_ID"]
created_at = os.environ["CREATED_AT"]
sink_rel = os.environ["SINK_REL"]
landed_ref = os.environ["LANDED_REF"]

def copied(logical_name, path, digest):
    return {
        "logical_name": logical_name,
        "path": path,
        "digest": digest,
    }

copied_files = [
    copied("terminal_current_state_proof", os.environ["PROOF_REL"], os.environ["PROOF_DIGEST"]),
    copied("change_receipt", os.environ["RECEIPT_REL"], os.environ["RECEIPT_DIGEST"]),
    copied("refs_snapshot", os.environ["REFS_REL"], os.environ["REFS_DIGEST"]),
    copied("status_snapshot", os.environ["STATUS_REL"], os.environ["STATUS_DIGEST"]),
    copied("residue_classification_snapshot", os.environ["CLASSIFICATION_REL"], os.environ["CLASSIFICATION_DIGEST"]),
]

source_refs = {
    "terminal_current_state_proof_ref": os.environ["PROOF_REL"],
    "change_receipt_ref": os.environ["RECEIPT_REL"],
}

landing_rel = os.environ.get("LANDING_REL", "")
if landing_rel:
    copied_files.append(copied("landing_authorization", landing_rel, "sha256:" + hashlib.sha256((root / landing_rel).read_bytes()).hexdigest()))
    source_refs["landing_authorization_ref"] = landing_rel

cleanup_rel = os.environ.get("CLEANUP_REL", "")
if cleanup_rel:
    copied_files.append(copied("cleanup_authorization", cleanup_rel, "sha256:" + hashlib.sha256((root / cleanup_rel).read_bytes()).hexdigest()))
    source_refs["cleanup_authorization_ref"] = cleanup_rel

source_branch = os.environ.get("SOURCE_BRANCH", "")
if source_branch:
    source_refs["source_branch"] = source_branch

manifest_id_source = "\n".join([
    change_id,
    created_at,
    sink_rel,
    os.environ["PROOF_DIGEST"],
    os.environ["RECEIPT_DIGEST"],
])

manifest = {
    "schema_version": "terminal-closeout-local-evidence-v1",
    "evidence_id": "terminal-closeout-local-" + hashlib.sha256(manifest_id_source.encode("utf-8")).hexdigest()[:16],
    "change_id": change_id,
    "created_at": created_at,
    "sink_root": ".octon/state/evidence/local/terminal-closeout",
    "sink_path": sink_rel,
    "disclosure_tier": "local-private",
    "non_authority_classification": "retained-evidence-only",
    "authority_boundaries": {
        "not_landing_authorization": True,
        "not_cleanup_authorization": True,
        "not_hosted_check_evidence": True,
        "not_packet_evidence": True,
        "not_archive_evidence": True,
        "not_generated_publication_evidence": True,
        "not_policy_authority": True,
        "not_mutation_authority": True,
    },
    "final_refs": {
        "head_ref": os.environ["HEAD_REF"],
        "main_ref": os.environ["MAIN_REF"],
        "origin_main_ref": os.environ["ORIGIN_MAIN_REF"],
        "landed_ref": landed_ref,
    },
    "alignment": {
        "head_equals_local_main": os.environ["HEAD_REF"] == os.environ["MAIN_REF"] == landed_ref,
        "local_main_equals_origin_main": os.environ["MAIN_REF"] == os.environ["ORIGIN_MAIN_REF"] == landed_ref,
        "origin_main_contains_landed_ref": os.environ["ORIGIN_MAIN_REF"] == landed_ref,
        "local_main_contains_landed_ref": os.environ["MAIN_REF"] == landed_ref,
    },
    "source_refs": source_refs,
    "copied_files": copied_files,
    "snapshots": {
        "refs_ref": os.environ["REFS_REL"],
        "refs_digest": os.environ["REFS_DIGEST"],
        "status_ref": os.environ["STATUS_REL"],
        "status_digest": os.environ["STATUS_DIGEST"],
        "residue_classification_ref": os.environ["CLASSIFICATION_REL"],
        "residue_classification_digest": os.environ["CLASSIFICATION_DIGEST"],
    },
    "terminal_current_state_proof_digest": os.environ["PROOF_DIGEST"],
    "change_receipt_digest": os.environ["RECEIPT_DIGEST"],
}

Path(os.environ["OUT"]).write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")
PY

mv -- "$MANIFEST_TMP" "$MANIFEST"

"$MANIFEST_VALIDATOR" --manifest "$MANIFEST" --change-id "$CHANGE_ID" --landed-ref "$LANDED_REF" >/dev/null

cat <<EOF
terminal_closeout_local_evidence:
  sink_path: $SINK_REL
  manifest_ref: $SINK_REL/manifest.json
  terminal_current_state_proof_ref: $SINK_REL/terminal-current-state-proof.yml
  terminal_current_state_proof_digest: $PROOF_DIGEST
  change_receipt_ref: $SINK_REL/change-receipt.json
  change_receipt_digest: $RECEIPT_DIGEST
  non_authority_classification: retained-evidence-only
EOF
