#!/usr/bin/env bash
set -euo pipefail

POLICY_PATH=""
SCHEMA_PATH=""
FINDINGS_DIR=""
ENFORCE_VALUE=""
OUTPUT_PATH=""
WAIVED_BY_AUTHORITY=""

usage() {
  cat <<'USAGE'
Usage:
  aggregate-decision.sh \
    --policy <path> \
    --schema <path> \
    --findings-dir <dir> \
    --enforce <true|false> \
    --output <path>
    [--waived-by-authority <true|false>]

Aggregates provider findings and emits a provider-agnostic AI gate decision.
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

normalize_bool() {
  local value
  value="$(echo "$1" | tr '[:upper:]' '[:lower:]')"
  case "${value}" in
    true|1|yes|on) echo "true" ;;
    *) echo "false" ;;
  esac
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
    --findings-dir)
      shift
      [[ $# -gt 0 ]] || error "--findings-dir requires a value"
      FINDINGS_DIR="$1"
      ;;
    --enforce)
      shift
      [[ $# -gt 0 ]] || error "--enforce requires a value"
      ENFORCE_VALUE="$1"
      ;;
    --output)
      shift
      [[ $# -gt 0 ]] || error "--output requires a value"
      OUTPUT_PATH="$1"
      ;;
    --waived-by-authority)
      shift
      [[ $# -gt 0 ]] || error "--waived-by-authority requires a value"
      WAIVED_BY_AUTHORITY="$1"
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
require_cmd find

[[ -f "${POLICY_PATH}" ]] || error "Policy file not found: ${POLICY_PATH}"
[[ -f "${SCHEMA_PATH}" ]] || error "Schema file not found: ${SCHEMA_PATH}"
[[ -d "${FINDINGS_DIR}" ]] || error "Findings directory not found: ${FINDINGS_DIR}"
[[ -n "${OUTPUT_PATH}" ]] || error "--output is required"

policy_json="$(jq -c . "${POLICY_PATH}")"
policy_version="$(jq -r '.version // "unknown"' <<<"${policy_json}")"
policy_default_enforce="$(jq -r '.enforcement.default // false' <<<"${policy_json}")"
policy_require_provider_ok="$(jq -r '.enforcement.require_all_providers_available_when_enforced // true' <<<"${policy_json}")"
policy_blocking_decisions="$(jq -c '.blocking.decisions // ["block"]' <<<"${policy_json}")"
policy_blocking_severities="$(jq -c '.blocking.severities // ["high", "critical"]' <<<"${policy_json}")"
waiver_mode="$(jq -r '.waiver.mode // "disabled"' <<<"${policy_json}")"

if [[ -n "${ENFORCE_VALUE}" ]]; then
  enforce="$(normalize_bool "${ENFORCE_VALUE}")"
else
  enforce="$(normalize_bool "${policy_default_enforce}")"
fi

if [[ "${waiver_mode}" == "disabled" ]]; then
  waived=false
elif [[ -n "${WAIVED_BY_AUTHORITY}" ]]; then
  waived="$(normalize_bool "${WAIVED_BY_AUTHORITY}")"
else
  waived=false
fi

provider_results='[]'
providers_total=0
providers_unavailable=0
total_findings=0
total_blockers=0

mapfile -t findings_files < <(find "${FINDINGS_DIR}" -type f -name 'findings-*.json' | sort)
if [[ "${#findings_files[@]}" -eq 0 ]]; then
  error "No findings JSON files discovered under ${FINDINGS_DIR}"
fi

for file in "${findings_files[@]}"; do
  if ! jq -e '.provider and .status and (.findings | type == "array")' "${file}" >/dev/null 2>&1; then
    error "Invalid findings payload structure: ${file}"
  fi

  provider="$(jq -r '.provider' "${file}")"
  status="$(jq -r '.status' "${file}")"
  findings_count="$(jq -r '.findings | length' "${file}")"

  blockers_count="$(jq -r \
    --argjson blocking_decisions "${policy_blocking_decisions}" \
    --argjson blocking_severities "${policy_blocking_severities}" \
    '[
      .findings[]? as $finding
      | select(
          (($blocking_decisions | index($finding.decision)) != null)
          or (($blocking_severities | index($finding.severity)) != null)
        )
    ] | length' "${file}")"

  providers_total=$((providers_total + 1))
  total_findings=$((total_findings + findings_count))
  total_blockers=$((total_blockers + blockers_count))

  if [[ "${status}" != "ok" ]]; then
    providers_unavailable=$((providers_unavailable + 1))
  fi

  provider_results="$(jq -c \
    --arg provider "${provider}" \
    --arg status "${status}" \
    --arg file "${file}" \
    --argjson findings_count "${findings_count}" \
    --argjson blockers_count "${blockers_count}" \
    '. + [{provider:$provider,status:$status,file:$file,findings: $findings_count, blockers:$blockers_count}]' \
    <<<"${provider_results}")"
done

decision="pass"
reason="no blockers detected"
gate_pass=true

if [[ "${waived}" == "true" ]]; then
  decision="waived-pass"
  reason="waiver authority acknowledged the AI gate blockers"
elif [[ "${enforce}" == "true" && "${policy_require_provider_ok}" == "true" && "${providers_unavailable}" -gt 0 ]]; then
  decision="fail-provider-unavailable"
  reason="enforced mode requires all providers to execute successfully"
  gate_pass=false
elif [[ "${total_blockers}" -gt 0 && "${enforce}" == "true" ]]; then
  decision="fail-blockers"
  reason="blocking AI findings detected in enforced mode"
  gate_pass=false
elif [[ "${total_blockers}" -gt 0 ]]; then
  decision="shadow-blockers"
  reason="blocking findings detected in shadow mode; merge not blocked"
else
  decision="pass"
  reason="no blockers detected"
fi

jq -n \
  --arg generated_at "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --arg policy_version "${policy_version}" \
  --arg decision "${decision}" \
  --arg reason "${reason}" \
  --argjson enforce "${enforce}" \
  --argjson waived "${waived}" \
  --argjson gate_pass "${gate_pass}" \
  --argjson providers_total "${providers_total}" \
  --argjson providers_unavailable "${providers_unavailable}" \
  --argjson total_findings "${total_findings}" \
  --argjson total_blockers "${total_blockers}" \
  --argjson provider_results "${provider_results}" \
  '{
    generated_at: $generated_at,
    policy_version: $policy_version,
    decision: $decision,
    reason: $reason,
    enforce: $enforce,
    waived: $waived,
    gate_pass: $gate_pass,
    providers_total: $providers_total,
    providers_unavailable: $providers_unavailable,
    findings_total: $total_findings,
    blockers_total: $total_blockers,
    providers: $provider_results
  }' > "${OUTPUT_PATH}"

echo "[OK] AI gate decision written to ${OUTPUT_PATH}"

if [[ "${gate_pass}" != "true" ]]; then
  echo "[ERROR] AI gate decision is failing (${decision}): ${reason}" >&2
  exit 1
fi
