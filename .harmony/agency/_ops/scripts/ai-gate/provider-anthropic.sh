#!/usr/bin/env bash
set -euo pipefail

POLICY_PATH=""
SCHEMA_PATH=""
DIFF_PATH=""
OUTPUT_PATH=""

usage() {
  cat <<'USAGE'
Usage:
  provider-anthropic.sh --policy <path> --schema <path> --diff <path> --output <path>

Generates normalized AI gate findings for the Anthropic provider lane.
USAGE
}

error() {
  echo "[ERROR] $1" >&2
  exit 1
}

require_cmd() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || error "Missing required command: $cmd"
}

search_diff() {
  local pattern="$1"
  local output_file="$2"

  if command -v rg >/dev/null 2>&1; then
    rg -n "${pattern}" "${DIFF_PATH}" >"${output_file}" 2>/dev/null || true
  else
    grep -nE "${pattern}" "${DIFF_PATH}" >"${output_file}" 2>/dev/null || true
  fi

  [[ -s "${output_file}" ]]
}

add_finding() {
  local id="$1"
  local severity="$2"
  local decision="$3"
  local title="$4"
  local body="$5"
  local file="$6"
  local line="$7"

  FINDINGS_JSON="$(jq -c \
    --arg id "$id" \
    --arg severity "$severity" \
    --arg decision "$decision" \
    --arg title "$title" \
    --arg body "$body" \
    --arg file "$file" \
    --argjson line "$line" \
    '. + [{id:$id,severity:$severity,decision:$decision,title:$title,body:$body,file:$file,line:$line}]' \
    <<<"${FINDINGS_JSON}")"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --policy)
      shift
      [[ $# -gt 0 ]] || error "--policy requires a value"
      POLICY_PATH="$1"
      ;;
    --schema)
      shift
      [[ $# -gt 0 ]] || error "--schema requires a value"
      SCHEMA_PATH="$1"
      ;;
    --diff)
      shift
      [[ $# -gt 0 ]] || error "--diff requires a value"
      DIFF_PATH="$1"
      ;;
    --output)
      shift
      [[ $# -gt 0 ]] || error "--output requires a value"
      OUTPUT_PATH="$1"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      error "Unknown argument: $1"
      ;;
  esac
  shift
done

require_cmd jq
[[ -f "${POLICY_PATH}" ]] || error "Policy file not found: ${POLICY_PATH}"
[[ -f "${SCHEMA_PATH}" ]] || error "Schema file not found: ${SCHEMA_PATH}"
[[ -f "${DIFF_PATH}" ]] || error "Diff file not found: ${DIFF_PATH}"
[[ -n "${OUTPUT_PATH}" ]] || error "--output is required"

policy_version="$(jq -r '.version // "unknown"' "${POLICY_PATH}")"
secret_configured=false
status="unavailable"
summary="ANTHROPIC_API_KEY is not configured. Provider execution skipped."

if [[ -n "${ANTHROPIC_API_KEY:-}" ]]; then
  secret_configured=true
  status="ok"
  summary="Anthropic adapter completed deterministic diff heuristics."
fi

FINDINGS_JSON='[]'

if [[ "${status}" == "ok" ]]; then
  if search_diff '^\+.*(exec|spawn|system)[[:space:]]*\(' /tmp/ai-gate-anthropic-exec.$$; then
    while IFS=':' read -r line _; do
      add_finding \
        "anthropic-command-exec-${line}" \
        "high" \
        "block" \
        "Potential shell/process execution path added" \
        "Added lines include exec/spawn/system call patterns. Verify command sanitization and least privilege controls." \
        "diff" \
        "${line}"
    done < /tmp/ai-gate-anthropic-exec.$$
  fi

  if search_diff '^\+.*(OPENAI_API_KEY|ANTHROPIC_API_KEY|SECRET|TOKEN)' /tmp/ai-gate-anthropic-secrets.$$; then
    while IFS=':' read -r line _; do
      add_finding \
        "anthropic-secret-signal-${line}" \
        "medium" \
        "warn" \
        "Potential credential handling change" \
        "Added lines reference secret/token material. Confirm no secret value is committed or echoed." \
        "diff" \
        "${line}"
    done < /tmp/ai-gate-anthropic-secrets.$$
  fi
fi

rm -f /tmp/ai-gate-anthropic-exec.$$ /tmp/ai-gate-anthropic-secrets.$$ >/dev/null 2>&1 || true

jq -n \
  --arg provider "anthropic" \
  --arg status "${status}" \
  --arg generated_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --arg summary "${summary}" \
  --arg policy_version "${policy_version}" \
  --argjson secret_configured "${secret_configured}" \
  --argjson findings "${FINDINGS_JSON}" \
  '{
    provider: $provider,
    status: $status,
    generated_at: $generated_at,
    summary: $summary,
    meta: {
      adapter: "provider-anthropic.sh",
      policy_version: $policy_version,
      secret_configured: $secret_configured,
      analysis_mode: "deterministic-heuristics"
    },
    findings: $findings
  }' > "${OUTPUT_PATH}"

jq -e '
  .provider and .status and .generated_at and .summary and (.findings | type == "array")
' "${OUTPUT_PATH}" >/dev/null || error "Output did not satisfy minimum normalized structure."

echo "[OK] Anthropic findings written to ${OUTPUT_PATH}"
