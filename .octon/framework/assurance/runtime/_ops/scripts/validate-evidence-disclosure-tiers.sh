#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../../" && pwd)"
ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"

RECEIPT_PATH=""
CHANGE_RECEIPT_PATH=""
warnings=0
errors=0

usage() {
  cat <<'USAGE'
usage:
  validate-evidence-disclosure-tiers.sh [--root <repo-root>] [--receipt <publishable-receipt.json>] [--change-receipt <change-receipt.json>]

Without --receipt or --change-receipt, validates the live tier contracts and
tracked local-evidence boundary. With --receipt, validates one
publishable-evidence-receipt-v1 file. With --change-receipt, validates that a
hosted/shared closeout receipt does not depend directly on local-only or
generated evidence references.
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

is_allowed_local_marker() {
  case "$1" in
    .octon/state/evidence/local/README.md|.octon/state/evidence/local/.gitkeep)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

validate_tracked_local_evidence() {
  local tracked_files=()
  local file

  if git -C "$ROOT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    while IFS= read -r file; do
      [[ -n "$file" ]] && tracked_files+=("$file")
    done < <(git -C "$ROOT_DIR" ls-files '.octon/state/evidence/local/**')
  fi

  if [[ "${#tracked_files[@]}" -eq 0 ]]; then
    pass "no tracked local evidence files found"
    return
  fi

  local forbidden=0
  for file in "${tracked_files[@]}"; do
    if is_allowed_local_marker "$file"; then
      pass "tracked local evidence marker is allowed: $file"
    else
      fail "tracked local-only evidence is forbidden: $file"
      forbidden=$((forbidden + 1))
    fi
  done

  [[ "$forbidden" -eq 0 ]] || return 0
}

validate_static_contracts() {
  local tier_contract="$ROOT_DIR/.octon/framework/constitution/contracts/retention/evidence-disclosure-tiers-v1.yml"
  local receipt_schema="$ROOT_DIR/.octon/framework/constitution/contracts/retention/publishable-evidence-receipt-v1.schema.json"
  local local_readme="$ROOT_DIR/.octon/state/evidence/local/README.md"

  require_file "$tier_contract"
  require_file "$receipt_schema"
  require_file "$local_readme"

  require_yq "$tier_contract" '.schema_version == "octon-evidence-disclosure-tiers-v1"' "tier contract schema version is current" "tier contract schema version must be octon-evidence-disclosure-tiers-v1"
  for tier in private_raw_evidence repo_publishable_evidence operator_release_disclosure generated_read_model; do
    require_yq "$tier_contract" ".tiers[]? | select(.tier_id == \"$tier\")" "tier contract defines $tier" "tier contract missing $tier"
  done
  require_yq "$tier_contract" '.tiers[]? | select(.tier_id == "repo_publishable_evidence") | .publishable_receipt_contract.schema_ref == ".octon/framework/constitution/contracts/retention/publishable-evidence-receipt-v1.schema.json"' "repo-publishable tier references receipt schema" "repo-publishable tier must reference publishable receipt schema"
  for field in claim_scope disclosure_tier source_summary validation_summary redactions limitations local_evidence_refs outcome rollback_or_discard authority_boundaries concision; do
    require_yq "$tier_contract" ".tiers[]? | select(.tier_id == \"repo_publishable_evidence\") | .publishable_receipt_contract.required_fields[]? | select(. == \"$field\")" "tier contract requires publishable receipt field $field" "tier contract missing required publishable receipt field $field"
    require_jq "$receipt_schema" ".required[] | select(. == \"$field\")" "receipt schema requires $field" "receipt schema missing required $field"
  done
  require_yq "$tier_contract" '.tiers[]? | select(.tier_id == "repo_publishable_evidence") | .publishable_receipt_contract.concision_policy.warning_threshold_bytes == 65536' "tier contract defines 64 KiB warning threshold" "tier contract must define 64 KiB warning threshold"
  require_yq "$tier_contract" '.tiers[]? | select(.tier_id == "repo_publishable_evidence") | .publishable_receipt_contract.concision_policy.failure_threshold_bytes == 262144' "tier contract defines 256 KiB failure threshold" "tier contract must define 256 KiB failure threshold"
  require_yq "$tier_contract" '.classification_requirements[]? | test("Hosted/shared closeout claims")' "tier contract gates hosted/shared closeout claims" "tier contract must gate hosted/shared closeout claims"
  require_yq "$tier_contract" '.tiers[]? | select(.tier_id == "generated_read_model") | .forbidden_consumers[]? | select(. == "closeout or archive gates")' "generated read models are forbidden closeout/archive consumers" "generated read models must be forbidden closeout/archive consumers"

  require_jq "$receipt_schema" '.properties.disclosure_tier.const == "repo-publishable"' "receipt schema fixes disclosure_tier" "receipt schema must fix disclosure_tier to repo-publishable"
  require_jq "$receipt_schema" '.properties.evidence_tier_ref.const == "repo_publishable_evidence"' "receipt schema fixes evidence_tier_ref" "receipt schema must fix evidence_tier_ref"
  require_jq "$receipt_schema" '.properties.local_evidence_refs.items.required[] | select(. == "digest")' "receipt schema requires local evidence digest" "receipt schema must require local evidence digest"
  require_jq "$receipt_schema" '.properties.local_evidence_refs.items.properties.digest_algorithm.const == "sha256"' "receipt schema requires sha256 digest algorithm" "receipt schema must require sha256 digest algorithm"
  require_jq "$receipt_schema" '.properties.concision.properties.warning_threshold_bytes.const == 65536' "receipt schema fixes warning threshold" "receipt schema must fix warning threshold"
  require_jq "$receipt_schema" '.properties.concision.properties.failure_threshold_bytes.const == 262144' "receipt schema fixes failure threshold" "receipt schema must fix failure threshold"
  require_jq "$receipt_schema" '.properties.concision.allOf[]? | select(.then.required[]? == "size_exception_ref")' "receipt schema requires exception ref when size exception is authorized" "receipt schema must require size_exception_ref for authorized size exceptions"

  validate_tracked_local_evidence
}

validate_publishable_receipt() {
  local file
  file="$(resolve_path "$RECEIPT_PATH")"
  require_file "$file"
  jq -e '.' "$file" >/dev/null 2>&1 && pass "publishable receipt parses as JSON" || { fail "publishable receipt must parse as JSON"; return; }

  local required_fields=(
    schema_version receipt_id receipt_mode created_at issuer_ref disclosure_tier evidence_tier_ref
    claim_scope source_summary validation_summary redactions limitations local_evidence_refs outcome
    rollback_or_discard authority_boundaries concision
  )
  local field
  for field in "${required_fields[@]}"; do
    require_jq "$file" "has(\"$field\")" "publishable receipt has $field" "publishable receipt missing $field"
  done

  require_jq "$file" '.schema_version == "publishable-evidence-receipt-v1"' "publishable receipt schema_version is current" "publishable receipt schema_version must be publishable-evidence-receipt-v1"
  require_jq "$file" '.disclosure_tier == "repo-publishable"' "publishable receipt declares repo-publishable disclosure tier" "publishable receipt must declare disclosure_tier repo-publishable"
  require_jq "$file" '.evidence_tier_ref == "repo_publishable_evidence"' "publishable receipt declares repo_publishable_evidence tier" "publishable receipt must declare evidence_tier_ref repo_publishable_evidence"
  require_jq "$file" '.source_summary.raw_evidence_published == false' "publishable receipt does not publish raw evidence" "publishable receipt must set source_summary.raw_evidence_published false"
  require_jq "$file" '.local_evidence_refs | type == "array" and length > 0' "publishable receipt declares local evidence refs" "publishable receipt must declare at least one local_evidence_refs entry"
  require_jq "$file" 'all(.local_evidence_refs[]; (.ref_kind | IN("repo-relative-path", "logical-id", "external-index")) and (.ref | type == "string" and length > 0) and .digest_algorithm == "sha256" and (.digest | test("^sha256:[0-9a-f]{64}$")) and .raw_evidence_not_published == true)' "local evidence refs include kind, ref, sha256 digest, and raw-not-published posture" "each local evidence ref must include kind, ref, sha256 digest, and raw_evidence_not_published true"
  require_jq "$file" '.authority_boundaries.raw_inputs_not_authority == true and .authority_boundaries.generated_outputs_not_authority == true and .authority_boundaries.proposal_paths_not_authority == true and .authority_boundaries.host_state_not_authority == true and .authority_boundaries.parent_program_evidence_not_substitute == true' "publishable receipt preserves authority boundaries" "publishable receipt must preserve authority boundary booleans"
  require_jq "$file" '.concision.declared_receipt_size_bytes | type == "number" and . >= 0' "publishable receipt declares receipt size" "publishable receipt must declare concision.declared_receipt_size_bytes"
  require_jq "$file" '.concision.warning_threshold_bytes == 65536 and .concision.failure_threshold_bytes == 262144' "publishable receipt declares canonical concision thresholds" "publishable receipt must declare canonical concision thresholds"
  require_jq "$file" '.concision.size_exception_authorized | type == "boolean"' "publishable receipt declares size exception posture" "publishable receipt must declare concision.size_exception_authorized"
  require_jq "$file" 'if .receipt_mode == "claim" then (.claim_scope.claim_type != "example" and .outcome.result != "example-only") else true end' "claim receipts do not use example-only outcome" "claim receipts must not use example-only outcome"
  require_jq "$file" 'if .receipt_mode == "example_fixture" then (.claim_scope.claim_type == "example" and .outcome.result == "example-only") else true end' "example fixtures use example-only outcome" "example fixtures must use example-only outcome"

  local actual_size exception_authorized
  actual_size="$(wc -c <"$file" | tr -d '[:space:]')"
  exception_authorized="$(jq -r '.concision.size_exception_authorized // false' "$file")"
  if [[ "$actual_size" -gt 262144 && "$exception_authorized" != "true" ]]; then
    fail "publishable receipt exceeds 256 KiB without size exception: $(rel_path "$file") (${actual_size} bytes)"
  elif [[ "$actual_size" -gt 262144 ]]; then
    require_jq "$file" '.concision.size_exception_ref | type == "string" and length > 0' "oversized receipt carries size exception ref" "oversized receipt must carry concision.size_exception_ref"
  elif [[ "$actual_size" -gt 65536 && "$exception_authorized" != "true" ]]; then
    warn "publishable receipt exceeds 64 KiB warning threshold: $(rel_path "$file") (${actual_size} bytes)"
  else
    pass "publishable receipt is within concision thresholds"
  fi
}

is_local_only_or_generated_ref() {
  local ref="$1"
  case "$ref" in
    .octon/state/evidence/local/*|state/evidence/local/*|evidence://local/*|*/.octon/state/evidence/local/*|*/state/evidence/local/*)
      return 0
      ;;
    .octon/generated/*|generated/*|*/.octon/generated/*|*/generated/*)
      return 0
      ;;
    .octon/inputs/*|inputs/*|*/.octon/inputs/*|*/inputs/*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

is_terminal_local_ref() {
  local ref="$1"
  [[ "$ref" == .octon/state/evidence/local/terminal-closeout/* ]]
}

digest_file() {
  local file="$1"
  local digest
  digest="$(shasum -a 256 "$file" | awk '{print $1}')"
  printf 'sha256:%s\n' "$digest"
}

validate_terminal_local_ref() {
  local file="$1"
  local ref digest change_id expected_prefix path actual_digest manifest

  ref="$(jq -r '.terminal_current_state_proof_ref // ""' "$file")"
  [[ -n "$ref" ]] || return 0
  if ! is_terminal_local_ref "$ref"; then
    return 0
  fi

  change_id="$(jq -r '.change_id // ""' "$file")"
  expected_prefix=".octon/state/evidence/local/terminal-closeout/$change_id/"
  if [[ -z "$change_id" || "$ref" != "$expected_prefix"* ]]; then
    fail "local terminal proof ref must be under .octon/state/evidence/local/terminal-closeout/<change-id>/"
    return
  fi

  digest="$(jq -r '.terminal_current_state_proof_digest // ""' "$file")"
  if [[ -z "$digest" ]]; then
    fail "local terminal proof ref requires terminal_current_state_proof_digest"
    return
  fi
  if [[ ! "$digest" =~ ^sha256:[0-9a-f]{64}$ ]]; then
    fail "terminal_current_state_proof_digest must be sha256:<64 hex>"
    return
  fi

  path="$(resolve_path "$ref")"
  if [[ -f "$path" ]]; then
    actual_digest="$(digest_file "$path")"
    [[ "$actual_digest" == "$digest" ]] && pass "local terminal proof digest matches" || fail "local terminal proof digest must match terminal_current_state_proof_digest"
  else
    fail "local terminal proof ref must resolve to a current file"
  fi

  manifest="$(dirname -- "$path")/manifest.json"
  if [[ -f "$manifest" ]]; then
    jq -e '.schema_version == "terminal-closeout-local-evidence-v1" and .non_authority_classification == "retained-evidence-only"' "$manifest" >/dev/null 2>&1 \
      && pass "local terminal manifest declares retained-evidence-only" \
      || fail "local terminal manifest must declare terminal-closeout-local-evidence-v1 retained-evidence-only"
  else
    fail "local terminal proof ref must have a sibling manifest.json"
  fi
}

validate_change_receipt() {
  local file
  file="$(resolve_path "$CHANGE_RECEIPT_PATH")"
  require_file "$file"
  jq -e '.' "$file" >/dev/null 2>&1 && pass "change receipt parses as JSON" || { fail "change receipt must parse as JSON"; return; }

  local route closeout outcome hosted_shared
  route="$(jq -r '.selected_route // ""' "$file")"
  closeout="$(jq -r '.closeout_outcome // ""' "$file")"
  outcome="$(jq -r '.lifecycle_outcome // ""' "$file")"
  hosted_shared=0

  if [[ "$route" == "branch-pr" ]]; then
    hosted_shared=1
  elif [[ "$route" == "branch-no-pr" ]] && jq -e '.hosted_landing | type == "object"' "$file" >/dev/null 2>&1; then
    hosted_shared=1
  fi

  if [[ "$hosted_shared" -ne 1 ]]; then
    pass "change receipt is not hosted/shared closeout; local-only closeout evidence gate not applicable"
    return
  fi

  local ref found_forbidden=0
  while IFS= read -r ref; do
    [[ -n "$ref" ]] || continue
    if is_local_only_or_generated_ref "$ref"; then
      fail "hosted/shared closeout depends on non-publishable evidence ref: $ref"
      found_forbidden=$((found_forbidden + 1))
    fi
  done < <(jq -r '
    [
      (.validation_evidence_refs[]?),
      (.landing_authorization_ref?),
      (.cleanup_authorization_ref?),
      (.hosted_landing.required_check_refs[]?),
      (.durable_history.ref?),
      (.durable_history.refs[]?),
      (.scope.diff_refs[]?),
      (.landing_evaluation.evidence_refs[]?),
      (.stateful_closeout.phase_exit_refs[]?),
      (.stateful_closeout.hosted_landing_refs[]?),
      (.stateful_closeout.cleanup_decision_refs[]?),
      (.stateful_closeout.branch_cleanup_refs[]?),
      (.stateful_closeout.final_verification_ref?),
      (.source_branch_integration.evidence_refs[]?),
      (.main_alignment.origin_fetch_evidence_ref?),
      (.main_alignment.local_main_sync_evidence_ref?)
    ] | map(select(type == "string")) | .[]
  ' "$file")

  if [[ "$found_forbidden" -eq 0 ]]; then
    pass "hosted/shared closeout receipt avoids local-only, generated, and input evidence refs"
  fi

  validate_terminal_local_ref "$file"

  case "$closeout:$outcome" in
    completed:*|*:cleaned|*:landed|*:ready|*:published|*:published-branch)
      pass "hosted/shared closeout evidence gate evaluated for $route/$outcome/$closeout"
      ;;
    *)
      pass "hosted/shared receipt is non-terminal but still free of forbidden evidence refs"
      ;;
  esac
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      ROOT_DIR="$(cd -- "$1" && pwd)"
      OCTON_DIR="$ROOT_DIR/.octon"
      ;;
    --receipt)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      RECEIPT_PATH="$1"
      ;;
    --change-receipt)
      shift
      [[ $# -gt 0 ]] || { usage >&2; exit 2; }
      CHANGE_RECEIPT_PATH="$1"
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

validate_static_contracts

if [[ -n "$RECEIPT_PATH" ]]; then
  validate_publishable_receipt
fi

if [[ -n "$CHANGE_RECEIPT_PATH" ]]; then
  validate_change_receipt
fi

echo "Validation summary: errors=$errors warnings=$warnings"
[[ "$errors" -eq 0 ]]
