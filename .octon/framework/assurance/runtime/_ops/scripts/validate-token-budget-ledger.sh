#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_ROOT="$(cd -- "$SCRIPT_DIR/../../../../../.." && pwd)"
ROOT_DIR="${OCTON_ROOT_DIR:-$DEFAULT_ROOT}"
LEDGER_PATH=""
BASELINE_PATH=""
CANDIDATE_PATH=""
REGRESSION_THRESHOLD_PERCENT=30
errors=0

usage() {
  cat <<'EOF'
Usage:
  validate-token-budget-ledger.sh --ledger <path> [--root <repo-root>]
  validate-token-budget-ledger.sh --baseline <path> --candidate <path> [--threshold-percent <n>] [--root <repo-root>]

Validates token-budget-ledger-v1 artifacts and optional before/after regression.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)
      ROOT_DIR="$2"
      shift 2
      ;;
    --ledger)
      LEDGER_PATH="$2"
      shift 2
      ;;
    --baseline)
      BASELINE_PATH="$2"
      shift 2
      ;;
    --candidate)
      CANDIDATE_PATH="$2"
      shift 2
      ;;
    --threshold-percent)
      REGRESSION_THRESHOLD_PERCENT="$2"
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

pass() {
  echo "[OK] $1"
}

fail() {
  echo "[ERROR] $1"
  errors=$((errors + 1))
}

resolve_path() {
  local path="$1"
  if [[ "$path" = /* ]]; then
    printf '%s\n' "$path"
  else
    printf '%s/%s\n' "$ROOT_DIR" "$path"
  fi
}

require_json_value() {
  local file="$1" expr="$2" label="$3"
  if yq -e "$expr" "$file" >/dev/null 2>&1; then
    pass "$label"
  else
    fail "$label"
  fi
}

validate_ledger() {
  local raw="$1" ledger
  ledger="$(resolve_path "$raw")"
  if [[ ! -f "$ledger" ]]; then
    fail "token ledger exists: $raw"
    return
  fi
  pass "token ledger exists: $raw"

  require_json_value "$ledger" '.schema_version == "token-budget-ledger-v1"' "schema version is token-budget-ledger-v1"
  require_json_value "$ledger" '.schema_ref == ".octon/framework/engine/runtime/spec/token-budget-ledger-v1.schema.json"' "schema ref is durable"
  require_json_value "$ledger" '.ledger_role | test("not-authority$")' "ledger role is non-authority"
  require_json_value "$ledger" '.authority_boundary.replaces_source_evidence == false' "ledger does not replace source evidence"
  require_json_value "$ledger" '.authority_boundary.authorizes_execution == false' "ledger does not authorize execution"
  require_json_value "$ledger" '.authority_boundary.raw_evidence_retained == true' "raw evidence retained"
  require_json_value "$ledger" '.authority_boundary.proposal_input_authority == "non-authoritative"' "proposal input remains non-authoritative"
  require_json_value "$ledger" '.authority_boundary.generated_output_authority == "derived-only"' "generated output remains derived-only"
  require_json_value "$ledger" '.provider_usage.status == "available" or .provider_usage.status == "not_available" or .provider_usage.status == "missing"' "provider usage status explicit"
  require_json_value "$ledger" '.token_summary.estimated_total_tokens >= 0' "estimated total tokens present"
  require_json_value "$ledger" '.token_summary.repeated_source_percentage >= 0' "repeated-source percentage present"
  require_json_value "$ledger" '.token_summary.prompt_boilerplate_percentage >= 0' "prompt boilerplate percentage present"
  require_json_value "$ledger" '.token_summary.generated_state_reread_count >= 0' "generated-state reread count present"
  require_json_value "$ledger" '.token_summary.raw_log_reread_count >= 0' "raw-log reread count present"
  require_json_value "$ledger" '.token_summary.high_reasoning_call_count >= 0' "high-reasoning call count present"

  for level in parent child stage source model; do
    require_json_value "$ledger" ".levels[] | select(.level == \"$level\")" "level present: $level"
  done

  if yq -e '.source_records[]? | select(.source_ref | test("\\.octon/inputs/exploratory/proposals/")) | select(.model_visible == true)' "$ledger" >/dev/null 2>&1; then
    fail "proposal-local source is not model-visible by default"
  else
    pass "proposal-local source is not model-visible by default"
  fi

  if yq -e '.source_records[]? | select(.sha256 | test("^sha256:[0-9a-f]{64}$") | not)' "$ledger" >/dev/null 2>&1; then
    fail "all source records use sha256 digests"
  else
    pass "all source records use sha256 digests"
  fi
}

validate_regression() {
  local baseline candidate before after allowed
  baseline="$(resolve_path "$BASELINE_PATH")"
  candidate="$(resolve_path "$CANDIDATE_PATH")"
  [[ -f "$baseline" ]] || fail "baseline ledger exists"
  [[ -f "$candidate" ]] || fail "candidate ledger exists"
  [[ -f "$baseline" && -f "$candidate" ]] || return

  before="$(yq -r '.token_summary.model_visible_estimated_tokens // .token_summary.estimated_total_tokens' "$baseline")"
  after="$(yq -r '.token_summary.model_visible_estimated_tokens // .token_summary.estimated_total_tokens' "$candidate")"
  allowed=$(( before + ((before * REGRESSION_THRESHOLD_PERCENT + 99) / 100) ))
  if [[ "$after" -le "$allowed" ]]; then
    pass "candidate model-visible tokens stay within threshold"
  else
    fail "candidate model-visible tokens exceed threshold: before=$before after=$after allowed=$allowed"
  fi
}

if [[ -n "$LEDGER_PATH" ]]; then
  validate_ledger "$LEDGER_PATH"
fi

if [[ -n "$BASELINE_PATH" || -n "$CANDIDATE_PATH" ]]; then
  [[ -n "$BASELINE_PATH" ]] || fail "missing --baseline"
  [[ -n "$CANDIDATE_PATH" ]] || fail "missing --candidate"
  if [[ -n "$BASELINE_PATH" && -n "$CANDIDATE_PATH" ]]; then
    validate_ledger "$BASELINE_PATH"
    validate_ledger "$CANDIDATE_PATH"
    validate_regression
  fi
fi

if [[ -z "$LEDGER_PATH" && -z "$BASELINE_PATH" && -z "$CANDIDATE_PATH" ]]; then
  fail "missing --ledger or --baseline/--candidate"
fi

echo "Validation summary: errors=$errors"
[[ "$errors" -eq 0 ]]
