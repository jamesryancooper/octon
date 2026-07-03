#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
source "$SCRIPT_DIR/validator-recovery-diagnostics.sh"

RECEIPT=""
PACKAGE=""
MODE=""
REQUIRE_PASS=0
errors=0

usage() {
  cat <<'EOF'
usage:
  validate-architectural-review-receipts.sh --receipt <path> [--package <proposal-path>] [--mode <mode>] [--require-pass]
EOF
}

pass() { printf '[OK] %s\n' "$1"; }
fail() { printf '[ERROR] %s\n' "$1" >&2; errors=$((errors + 1)); }

repo_rel() {
  local path="$1"
  case "$path" in
    "$ROOT_DIR"/*)
      printf '%s\n' "${path#$ROOT_DIR/}"
      ;;
    *)
      printf '%s\n' "$path"
      ;;
  esac
}

architectural_review_rerun_gate() {
  local gate="validate-architectural-review-receipts.sh --receipt $(repo_rel "$RECEIPT")"
  if [[ -n "$PACKAGE" ]]; then
    gate="$gate --package $PACKAGE"
  fi
  if [[ -n "$MODE" ]]; then
    gate="$gate --mode $MODE"
  fi
  if [[ "$REQUIRE_PASS" -eq 1 ]]; then
    gate="$gate --require-pass"
  fi
  printf '%s\n' "$gate"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --receipt)
      shift; RECEIPT="${1:-}"
      ;;
    --package)
      shift; PACKAGE="${1:-}"
      ;;
    --mode)
      shift; MODE="${1:-}"
      ;;
    --require-pass)
      REQUIRE_PASS=1
      ;;
    *)
      usage >&2; exit 2
      ;;
  esac
  shift
done

[[ -n "$RECEIPT" ]] || { usage >&2; exit 2; }

if [[ "$RECEIPT" != /* ]]; then
  RECEIPT="$ROOT_DIR/$RECEIPT"
fi

if [[ ! -f "$RECEIPT" ]]; then
  fail "architectural review receipt exists"
  printf 'Validation summary: errors=%s\n' "$errors"
  exit 1
fi
pass "architectural review receipt exists"

if yq -e '.' "$RECEIPT" >/dev/null 2>&1; then
  pass "architectural review receipt parses as YAML"
else
  fail "architectural review receipt parses as YAML"
fi

field() {
  yq -r "$1 // \"\"" "$RECEIPT" 2>/dev/null || true
}

schema_version="$(field '.schema_version')"
receipt_id="$(field '.receipt_id')"
proposal_path="$(field '.proposal_path')"
packet_digest="$(field '.packet_digest')"
review_mode="$(field '.review_mode')"
verdict="$(field '.verdict')"
unresolved_count="$(field '.unresolved_count')"
non_authority_classification="$(field '.non_authority_classification')"

[[ "$schema_version" == "architectural-review-support-receipt-v1" ]] && pass "schema_version is architectural-review-support-receipt-v1" || fail "schema_version is architectural-review-support-receipt-v1"
[[ -n "$receipt_id" ]] && pass "receipt_id present" || fail "receipt_id present"
[[ -n "$proposal_path" ]] && pass "proposal_path present" || fail "proposal_path present"
[[ "$packet_digest" =~ ^sha256:[0-9a-f]{64}$ ]] && pass "packet_digest explicit" || fail "packet_digest explicit"
[[ "$review_mode" =~ ^(pre-integration-architecture-review|post-integration-architecture-review|current-state-mechanism-architecture-review|architecture-readiness-audit)$ ]] && pass "review_mode canonical" || fail "review_mode canonical"
[[ -z "$MODE" || "$review_mode" == "$MODE" ]] && pass "review_mode matches requested mode" || fail "review_mode matches requested mode"
[[ "$verdict" =~ ^(pass|fail|blocked|not_applicable|deferred)$ ]] && pass "verdict explicit" || fail "verdict explicit"
[[ "$unresolved_count" =~ ^[0-9]+$ ]] && pass "unresolved_count numeric" || fail "unresolved_count numeric"
[[ "$non_authority_classification" == "retained-evidence-only" ]] && pass "non-authority classification retained-evidence-only" || fail "non-authority classification retained-evidence-only"

evidence_count="$(yq -r '(.evidence_refs // []) | length' "$RECEIPT")"
validator_count="$(yq -r '(.validator_refs // []) | length' "$RECEIPT")"
blocker_count="$(yq -r '(.blockers // []) | length' "$RECEIPT")"
coverage_count="$(yq -r '(.mode_specific_coverage // {}) | length' "$RECEIPT")"

[[ "$evidence_count" -gt 0 ]] && pass "evidence_refs non-empty" || fail "evidence_refs non-empty"
[[ "$validator_count" -gt 0 ]] && pass "validator_refs non-empty" || fail "validator_refs non-empty"
yq -e '.blockers | type == "!!seq"' "$RECEIPT" >/dev/null 2>&1 && pass "blockers is a list" || fail "blockers is a list"
[[ "$coverage_count" -gt 0 ]] && pass "mode_specific_coverage non-empty" || fail "mode_specific_coverage non-empty"

if rg -qi '(^|[^[:alnum:]_])(TODO|TBD|FIXME)([^[:alnum:]_]|$)|not reviewed|not verified|not run|pending placeholder|stale packet digest' "$RECEIPT"; then
  fail "receipt contains no placeholder or stale-evidence text"
else
  pass "receipt contains no placeholder or stale-evidence text"
fi

if [[ "$REQUIRE_PASS" -eq 1 ]]; then
  [[ "$verdict" == "pass" ]] && pass "required pass receipt has pass verdict" || fail "required pass receipt has pass verdict"
  [[ "$unresolved_count" == "0" ]] && pass "required pass receipt has zero unresolved items" || fail "required pass receipt has zero unresolved items"
  [[ "$blocker_count" == "0" ]] && pass "required pass receipt has no blockers" || fail "required pass receipt has no blockers"
fi

if [[ -n "$PACKAGE" ]]; then
  if [[ "$PACKAGE" != /* ]]; then
    PACKAGE_ABS="$ROOT_DIR/$PACKAGE"
  else
    PACKAGE_ABS="$PACKAGE"
  fi
  if [[ -d "$PACKAGE_ABS" ]]; then
    current_digest="$(bash "$SCRIPT_DIR/validate-proposal-review-gate.sh" --package "$PACKAGE_ABS" --print-digest)"
    [[ "$packet_digest" == "$current_digest" ]] && pass "packet_digest is fresh for package" || {
      if [[ "$(yq -r '.status // ""' "$PACKAGE_ABS/proposal.yml" 2>/dev/null)" == "archived" \
        && -n "$(yq -r '.archive.original_path // ""' "$PACKAGE_ABS/proposal.yml" 2>/dev/null)" \
        && "$packet_digest" =~ ^sha256:[0-9a-f]{64}$ ]]; then
        pass "packet_digest preserved from pre-archive packet"
      else
        emit_stale_evidence_recovery_diagnostic \
          "$(repo_rel "$RECEIPT")#packet_digest" \
          "$packet_digest" \
          "$current_digest" \
          "$(repo_rel "$RECEIPT")" \
          "architectural review receipt packet_digest does not match current packet digest" \
          "$(architectural_review_rerun_gate)" \
          "rerun the $review_mode route at the next authorized stable digest boundary so the receipt records the current packet digest" \
          "packet-content-drift-after-architecture-review" \
          "$review_mode" \
          "packet_digest"
        fail "packet_digest is fresh for package"
        printf 'recorded: %s\ncurrent:  %s\n' "$packet_digest" "$current_digest" >&2
      fi
    }
  else
    fail "package path exists for digest freshness"
  fi
fi

printf 'Validation summary: errors=%s\n' "$errors"
[[ "$errors" -eq 0 ]]
