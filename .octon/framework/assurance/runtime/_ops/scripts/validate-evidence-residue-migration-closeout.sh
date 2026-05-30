#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

EVIDENCE_ROOT=""
RUN_ID="lifecycle-proposal-program-1780090167014-7a1ddc40-evidence-residue-migration-closeout"
errors=0
warnings=0

usage() {
  cat <<'USAGE'
usage:
  validate-evidence-residue-migration-closeout.sh [--root <repo-root>] [--evidence-root <path>] [--run-id <run-id>]

Validates retained evidence for the evidence residue migration closeout child:
inventory summary, migration decision table, publishable replacement receipt,
parent closeout aggregate, local archive pointer, and run disclosure card.
USAGE
}

pass() { echo "[OK] $1"; }
warn() { echo "[WARN] $1"; warnings=$((warnings + 1)); }
fail() { echo "[ERROR] $1" >&2; errors=$((errors + 1)); }

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

rel_path() {
  local path="$1"
  case "$path" in
    "$ROOT_DIR"/*) printf '%s\n' "${path#$ROOT_DIR/}" ;;
    *) printf '%s\n' "$path" ;;
  esac
}

require_file() {
  local file="$1"
  [[ -f "$file" ]] && pass "found $(rel_path "$file")" || fail "missing $(rel_path "$file")"
}

require_yq() {
  local file="$1"
  local expr="$2"
  local ok_msg="$3"
  local fail_msg="$4"
  yq -e "$expr" "$file" >/dev/null 2>&1 && pass "$ok_msg" || fail "$fail_msg"
}

require_jq() {
  local file="$1"
  local expr="$2"
  local ok_msg="$3"
  local fail_msg="$4"
  jq -e "$expr" "$file" >/dev/null 2>&1 && pass "$ok_msg" || fail "$fail_msg"
}

latest_evidence_root() {
  local base="$ROOT_DIR/.octon/state/evidence/runs/skills/evidence-residue-migration-closeout"
  find "$base" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | LC_ALL=C sort | tail -n 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      ROOT_DIR="$(cd -- "$1" && pwd)"
      OCTON_DIR="$ROOT_DIR/.octon"
      ;;
    --evidence-root)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      EVIDENCE_ROOT="$(resolve_path "$1")"
      ;;
    --run-id)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      RUN_ID="$1"
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

require_tool jq
require_tool yq

if [[ -z "$EVIDENCE_ROOT" ]]; then
  EVIDENCE_ROOT="$(latest_evidence_root)"
fi

if [[ -z "$EVIDENCE_ROOT" || ! -d "$EVIDENCE_ROOT" ]]; then
  fail "evidence root exists"
  echo "Validation summary: errors=$errors warnings=$warnings"
  exit 1
fi

inventory="$EVIDENCE_ROOT/inventory-summary.yml"
decision_table="$EVIDENCE_ROOT/migration-decision-table.yml"
receipt="$EVIDENCE_ROOT/publishable-receipt.json"
aggregate="$EVIDENCE_ROOT/parent-closeout-aggregate.yml"
run_card="$ROOT_DIR/.octon/state/evidence/disclosure/runs/$RUN_ID/run-card.yml"

require_file "$inventory"
require_file "$decision_table"
require_file "$receipt"
require_file "$aggregate"
require_file "$run_card"

require_yq "$inventory" '.schema_version == "evidence-residue-inventory-summary-v1"' "inventory schema version is current" "inventory schema version must be evidence-residue-inventory-summary-v1"
require_yq "$inventory" '.inventory_scope.cleanup_closeout_scope_files_seen == 166' "inventory records cleanup/closeout scope count" "inventory must record 166 cleanup/closeout files"
require_yq "$inventory" '.classification_counts.repo_publishable_receipt == 36' "inventory records publishable receipt count" "inventory must record 36 publishable receipts"
require_yq "$inventory" '.classification_counts.raw_authorization_payload == 38' "inventory records raw authorization count" "inventory must record 38 raw authorization payloads"
require_yq "$inventory" '.classification_counts.raw_run_log == 22' "inventory records raw run log count" "inventory must record 22 raw run logs"
require_yq "$inventory" '.local_archive.raw_evidence_published == false' "inventory keeps raw local evidence unpublished" "inventory must keep raw local evidence unpublished"
require_yq "$inventory" '.local_archive.copied_raw_like_count >= 60' "inventory records local archive copy count" "inventory must record a nontrivial local archive copy count"
require_yq "$inventory" '.cleanup_helper_summary.mode == "dry-run" and .cleanup_helper_summary.cleanup_candidates == 0' "cleanup helper dry-run summary is retained" "cleanup helper dry-run summary must be retained with zero cleanup candidates"

archive_manifest_ref="$(yq -r '.local_archive.archive_manifest_ref // ""' "$inventory")"
archive_manifest_digest="$(yq -r '.local_archive.archive_manifest_digest // ""' "$inventory")"
if [[ -n "$archive_manifest_ref" ]]; then
  archive_manifest="$(resolve_path "$archive_manifest_ref")"
  require_file "$archive_manifest"
  if [[ -f "$archive_manifest" ]]; then
    actual_digest="sha256:$(shasum -a 256 "$archive_manifest" | awk '{print $1}')"
    [[ "$actual_digest" == "$archive_manifest_digest" ]] && pass "local archive manifest digest matches inventory" || fail "local archive manifest digest matches inventory"
  fi
else
  fail "inventory declares local archive manifest ref"
fi

require_yq "$decision_table" '.schema_version == "evidence-residue-migration-decision-table-v1"' "decision table schema version is current" "decision table schema version must be evidence-residue-migration-decision-table-v1"
for action in keep-publishable move-to-local replace-with-receipt retain-with-rationale discard-after-archive; do
  require_yq "$decision_table" ".decisions[]? | select(.action == \"$action\")" "decision table covers action $action" "decision table must cover action $action"
done
require_yq "$decision_table" '.decision_result.verdict == "pass" and .decision_result.deletion_performed == false' "decision table records pass without deletion" "decision table must record pass without deletion"
require_yq "$decision_table" '.authority_boundaries.local_archive_not_hosted_closeout_proof == true' "decision table blocks local archive as hosted closeout proof" "decision table must block local archive as hosted closeout proof"

if bash "$SCRIPT_DIR/validate-evidence-disclosure-tiers.sh" --root "$ROOT_DIR" --receipt "$(rel_path "$receipt")"; then
  pass "publishable receipt passes evidence disclosure tier validator"
else
  fail "publishable receipt passes evidence disclosure tier validator"
fi

require_jq "$receipt" '.receipt_mode == "claim" and .claim_scope.claim_type == "implementation-promotion"' "publishable receipt is a claim receipt" "publishable receipt must be an implementation-promotion claim"
require_jq "$receipt" '.source_summary.raw_evidence_published == false' "publishable receipt does not publish raw evidence" "publishable receipt must not publish raw evidence"
require_jq "$receipt" '.outcome.result == "pass"' "publishable receipt outcome passes" "publishable receipt outcome must pass"

require_yq "$aggregate" '.schema_version == "evidence-residue-parent-closeout-aggregate-v1"' "parent aggregate schema version is current" "parent aggregate schema version must be evidence-residue-parent-closeout-aggregate-v1"
require_yq "$aggregate" '.parent_closeout_disposition.verdict == "not-authorized-by-this-child"' "parent aggregate does not authorize closeout" "parent aggregate must not authorize parent closeout"
require_yq "$aggregate" '.parent_closeout_disposition.terminal_child_count_observed == 6 and .parent_closeout_disposition.required_child_count == 7' "parent aggregate records predecessor count boundary" "parent aggregate must record predecessor count boundary"
require_yq "$aggregate" '.boundary_rules.child_receipts_not_satisfied_by_parent_evidence == true' "parent aggregate preserves child receipt boundary" "parent aggregate must preserve child receipt boundary"

require_yq "$run_card" '.schema_version == "run-card-v2"' "run card schema version is current" "run card schema version must be run-card-v2"
require_yq "$run_card" ".run_id == \"$RUN_ID\"" "run card run id matches" "run card run id must match"
require_yq "$run_card" '.publishable_evidence_receipt_refs[]? | select(.raw_evidence_not_published == true and .disclosure_tier == "repo-publishable")' "run card cites publishable evidence receipt" "run card must cite publishable evidence receipt"
require_yq "$run_card" '.local_evidence_limitations[]? | test("not hosted/shared closeout proof")' "run card discloses local evidence limitation" "run card must disclose local evidence limitation"

durable_scan="$(rg -n "\\.octon/inputs/exploratory/proposals/(\\.archive/)?[a-z0-9-]+/evidence-residue-migration-closeout" "$EVIDENCE_ROOT" "$run_card" 2>/dev/null || true)"
if [[ -n "$durable_scan" ]]; then
  fail "durable evidence avoids proposal-path backreferences"
  printf '%s\n' "$durable_scan"
else
  pass "durable evidence avoids proposal-path backreferences"
fi

echo "Validation summary: errors=$errors warnings=$warnings"
[[ "$errors" -eq 0 ]]
