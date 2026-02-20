#!/usr/bin/env bash
# validate-ra-acp-migration.sh - Regression guard for RA + ACP clean-break migration.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CAPABILITIES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
REPO_ROOT="$(cd "$CAPABILITIES_DIR/../.." && pwd)"

POLICY_FILE="$CAPABILITIES_DIR/_ops/policy/deny-by-default.v2.yml"
TAXONOMY_FILE="$CAPABILITIES_DIR/_ops/policy/acp-operation-classes.md"
ENFORCER_FILE="$CAPABILITIES_DIR/services/_ops/scripts/enforce-deny-by-default.sh"
AGENT_FILE="$CAPABILITIES_DIR/services/execution/agent/impl/agent.sh"
RECEIPT_WRITER="$CAPABILITIES_DIR/_ops/scripts/policy-receipt-write.sh"
BREAKER_ACTIONS_SCRIPT="$CAPABILITIES_DIR/_ops/scripts/policy-circuit-breaker-actions.sh"

FAIL_COUNT=0

fail() {
  local msg="$1"
  echo "RA+ACP migration check failed: $msg" >&2
  FAIL_COUNT=$((FAIL_COUNT + 1))
}

check_required_files() {
  local file
  for file in "$POLICY_FILE" "$TAXONOMY_FILE" "$ENFORCER_FILE" "$AGENT_FILE" "$RECEIPT_WRITER" "$BREAKER_ACTIONS_SCRIPT"; do
    [[ -f "$file" ]] || fail "missing required file: $file"
  done
}

check_hitl_doc_removed() {
  local old_doc="$REPO_ROOT/.harmony/cognition/principles/hitl-checkpoints.md"
  if [[ -f "$old_doc" ]]; then
    fail "legacy hitl-checkpoints.md still exists"
  fi
}

check_policy_sections() {
  local section
  for section in acp reversibility budgets quorum attestations circuit_breakers receipts; do
    if ! rg -n "^${section}:" "$POLICY_FILE" >/dev/null; then
      fail "policy missing top-level section '${section}'"
    fi
  done
}

collect_policy_classes() {
  awk '
    /^[[:space:]]+class:[[:space:]]*[a-zA-Z0-9._-]+/ {
      value=$2
      gsub(/["'\'' ,]/, "", value)
      print value
    }
  ' "$POLICY_FILE" | sort -u
}

collect_taxonomy_classes() {
  sed -n 's/^- `\([a-zA-Z0-9._-]*\)` — .*/\1/p' "$TAXONOMY_FILE" | sort -u
}

check_taxonomy_alignment() {
  local policy_classes taxonomy_classes policy_only taxonomy_only
  policy_classes="$(collect_policy_classes)"
  taxonomy_classes="$(collect_taxonomy_classes)"

  policy_only="$(comm -23 <(printf '%s\n' "$policy_classes") <(printf '%s\n' "$taxonomy_classes"))"
  taxonomy_only="$(comm -13 <(printf '%s\n' "$policy_classes") <(printf '%s\n' "$taxonomy_classes"))"

  if [[ -n "$policy_only" ]]; then
    fail "policy classes missing from taxonomy: $(tr '\n' ',' <<<"$policy_only" | sed 's/,$//')"
  fi
  if [[ -n "$taxonomy_only" ]]; then
    fail "taxonomy classes missing from policy: $(tr '\n' ',' <<<"$taxonomy_only" | sed 's/,$//')"
  fi
}

extract_wrapper_defaults() {
  {
    sed -n 's/.*HARMONY_OPERATION_CLASS:-\([^}]*\)}.*/\1/p' "$ENFORCER_FILE"
    sed -n 's/.*HARMONY_OPERATION_CLASS:-\([^}]*\)}.*/\1/p' "$AGENT_FILE"
  } | sed '/^[[:space:]]*$/d' | sort -u
}

check_wrapper_defaults_mapped() {
  local classes defaults default_class
  classes="$(collect_policy_classes)"
  defaults="$(extract_wrapper_defaults)"
  while IFS= read -r default_class; do
    [[ -n "$default_class" ]] || continue
    if ! grep -qx "$default_class" <<<"$classes"; then
      fail "wrapper default operation class '$default_class' is not mapped in policy"
    fi
  done <<<"$defaults"
}

check_receipt_writer_append_only() {
  if rg -n '>[[:space:]]*"\$receipt_path"|>[[:space:]]*"\$digest_path"' "$RECEIPT_WRITER" >/dev/null; then
    fail "receipt writer overwrites compatibility paths instead of preserving immutable history"
  fi
}

check_active_surface_legacy_terms() {
  local hits raw_hits pattern negation_pattern sample
  # Guard only against affirmative legacy semantics that require human approval at runtime.
  # Affirmative phrases indicating mandatory human involvement.
  pattern='require[sd]?(ing)?[^[:cntrl:]\n]{0,80}human approval|require[sd]?(ing)?[^[:cntrl:]\n]{0,80}human approvals|must[^[:cntrl:]\n]{0,80}be[^[:cntrl:]\n]{0,40}approved[^[:cntrl:]\n]{0,40}by[^[:cntrl:]\n]{0,20}human|await[^[:cntrl:]\n]{0,80}human approval|human[^[:cntrl:]\n]{0,40}must[^[:cntrl:]\n]{0,20}approve|block[^[:cntrl:]\n]{0,80}until[^[:cntrl:]\n]{0,40}approved[^[:cntrl:]\n]{0,40}by[^[:cntrl:]\n]{0,20}human|HITL[^[:cntrl:]\n]{0,40}checkpoint[^[:cntrl:]\n]{0,40}(required|mandatory|must)|(required|mandatory|must)[^[:cntrl:]\n]{0,40}HITL[^[:cntrl:]\n]{0,40}checkpoint|approve at defined checkpoints|human review and approval gate'
  # Explicit negations that intentionally describe no human approval dependency.
  negation_pattern='does not require[^[:cntrl:]\n]{0,80}human approval|does not require[^[:cntrl:]\n]{0,80}human approvals|do not require[^[:cntrl:]\n]{0,80}human approval|do not require[^[:cntrl:]\n]{0,80}human approvals|not[^[:cntrl:]\n]{0,40}human approval|not[^[:cntrl:]\n]{0,40}human approvals|no[^[:cntrl:]\n]{0,40}human[^[:cntrl:]\n]{0,20}approval|no[^[:cntrl:]\n]{0,40}human[^[:cntrl:]\n]{0,20}approvals|without[^[:cntrl:]\n]{0,40}human approval|without[^[:cntrl:]\n]{0,40}human approvals|not[^[:cntrl:]\n]{0,40}human checkpoint|not[^[:cntrl:]\n]{0,40}HITL[^[:cntrl:]\n]{0,40}checkpoint'

  raw_hits="$(
    rg -n -i --hidden \
      --glob '!**/.harmony/output/**' \
      --glob '!**/.harmony/ideation/**' \
      --glob '!**/.harmony/continuity/runs/**' \
      --glob '!**/.harmony/capabilities/_ops/state/**' \
      --glob '!**/.harmony/capabilities/_ops/tests/**' \
      --glob '!**/validate-ra-acp-migration.sh' \
      "$pattern" \
      "$REPO_ROOT/.harmony" 2>/dev/null || true
  )"

  hits="$(printf '%s\n' "$raw_hits" | rg -i -v "$negation_pattern" || true)"

  if [[ -n "$hits" ]]; then
    sample="$(printf '%s\n' "$hits" | head -n 10 | tr '\n' '; ')"
    fail "stale legacy HITL language remains on active .harmony surfaces: $sample"
  fi
}

check_tracked_temp_artifacts() {
  local tracked

  if ! command -v git >/dev/null 2>&1; then
    fail "git is required to validate tracked temp artifacts"
    return
  fi

  tracked="$(git -C "$REPO_ROOT" ls-files \
    '.harmony/output/reports/.tmp' \
    '.harmony/capabilities/_ops/state/.tmp' \
    2>/dev/null || true)"

  if [[ -n "$tracked" ]]; then
    fail "tracked temp artifacts detected (expected untracked-only): $(printf '%s\n' "$tracked" | head -n 10 | tr '\n' ',')"
  fi
}

check_shared_breaker_action_wiring() {
  if ! rg -n 'policy-circuit-breaker-actions\.sh' "$AGENT_FILE" >/dev/null; then
    fail "agent runtime does not reference shared circuit breaker actions helper"
  fi
  if ! rg -n 'policy-circuit-breaker-actions\.sh' "$ENFORCER_FILE" >/dev/null; then
    fail "service runtime enforcer does not reference shared circuit breaker actions helper"
  fi
}

check_quorum_independence_defaults() {
  if ! rg -n 'HARMONY_ALLOW_INPROCESS_ATTESTATIONS:-false' "$AGENT_FILE" >/dev/null; then
    fail "agent attestation flow missing explicit synthetic-attestation compatibility guard"
  fi
  if ! rg -n 'verifier\.attestation\.json|recovery\.attestation\.json' "$AGENT_FILE" >/dev/null; then
    fail "agent attestation flow is not sourcing external verifier/recovery artifacts"
  fi
}

main() {
  check_required_files
  check_hitl_doc_removed
  check_policy_sections
  check_taxonomy_alignment
  check_wrapper_defaults_mapped
  check_receipt_writer_append_only
  check_active_surface_legacy_terms
  check_tracked_temp_artifacts
  check_shared_breaker_action_wiring
  check_quorum_independence_defaults

  if (( FAIL_COUNT > 0 )); then
    echo "RA+ACP migration regression checks failed ($FAIL_COUNT)." >&2
    exit 1
  fi

  echo "RA+ACP migration regression checks passed."
}

main "$@"
