#!/usr/bin/env bash
# guard.sh - Shell guard service implementation.

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Enforce deny-by-default policy at runtime for this shell service.
source "$SCRIPT_DIR/../../../_ops/scripts/enforce-deny-by-default.sh"
harmony_enforce_service_policy "guard" "$0" "$@"


emit_error() {
  local message="$1"
  local code="$2"
  local suggested="$3"
  jq -n \
    --arg message "$message" \
    --argjson exitCode "$code" \
    --arg suggested "$suggested" \
    '{success:false,error:{code:"InputValidationError",exitCode:$exitCode,message:$message,suggestedAction:$suggested}}' \
    >&2
  exit "$code"
}

if ! command -v jq >/dev/null 2>&1; then
  echo '{"success":false,"error":{"code":"UpstreamProviderError","exitCode":6,"message":"jq is required","suggestedAction":"Install jq"}}' >&2
  exit 6
fi

payload="$(cat)"
if [[ -z "$(echo "$payload" | tr -d '[:space:]')" ]]; then
  emit_error "Expected JSON input on stdin" 5 "Provide a JSON body that matches input.schema.json."
fi

content="$(jq -er '.content // empty' <<<"$payload" 2>/dev/null)"
if [[ -z "$content" ]]; then
  emit_error "Missing required field: content" 5 "Include a non-empty string field named content."
fi

check_enabled() {
  local key="$1"
  jq -r --arg k "$key" '.options.checks[$k] // true | if . then "true" else "false" end' <<<"$payload" 2>/dev/null || echo "true"
}

first_match() {
  local regex="$1"
  printf '%s' "$content" | grep -Eio "$regex" | head -n 1 || true
}

checks='[]'

add_check_pass() {
  local name="$1"
  checks="$(jq --arg name "$name" '. + [{name:$name,passed:true}]' <<<"$checks")"
}

add_check_fail() {
  local name="$1"
  local severity="$2"
  local message="$3"
  local pattern="$4"
  local redacted="$5"
  checks="$(jq \
    --arg name "$name" \
    --arg severity "$severity" \
    --arg message "$message" \
    --arg pattern "$pattern" \
    --arg redacted "$redacted" \
    '. + [{name:$name,passed:false,severity:$severity,message:$message,details:{matched:true},matches:[{pattern:$pattern,location:"content",redacted:$redacted}]}]' \
    <<<"$checks")"
}

run_check() {
  local key="$1"
  local regex="$2"
  local severity="$3"
  local message="$4"

  if [[ "$(check_enabled "$key")" != "true" ]]; then
    add_check_pass "$key"
    return
  fi

  local match
  match="$(first_match "$regex")"
  if [[ -n "$match" ]]; then
    add_check_fail "$key" "$severity" "$message" "$regex" "[REDACTED]"
  else
    add_check_pass "$key"
  fi
}

run_check "promptInjection" "ignore[[:space:]]+(all[[:space:]]+)?(previous|prior|above)[[:space:]]+(instructions?|prompts?|rules?)|dan|developer[[:space:]]+mode|bypass[[:space:]]+(safety|filters?|restrictions?)|\\[[[:space:]]*(SYSTEM|INST|INSTRUCTION)[[:space:]]*\\]" "critical" "Potential prompt injection pattern detected"
run_check "hallucination" "TODO|FIXME|PLACEHOLDER|Promise\\.delay|navigator\\.clipboard\\.writeSync|localStorage\\.getAsync" "medium" "Potential hallucination marker detected"
run_check "secrets" "(AKIA|A3T|AGPA|AIDA|AROA|AIPA|ANPA|ANVA|ASIA)[A-Z0-9]{16}|(ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9_]{36,}|-----BEGIN[[:space:]]+(RSA[[:space:]]+)?PRIVATE[[:space:]]+KEY-----|api[_-]?key['\":=[:space:]]+[A-Za-z0-9/_+=-]{20,}" "critical" "Secret material pattern detected"
run_check "pii" "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}|([+]?[1][-[:space:].]?)?[(]?[0-9]{3}[)]?[-[:space:].]?[0-9]{3}[-[:space:].]?[0-9]{4}|[0-9]{3}[-[:space:]]?[0-9]{2}[-[:space:]]?[0-9]{4}" "high" "PII pattern detected"
run_check "codeSafety" "\\beval[[:space:]]*\\(|\\b(exec|execSync|spawn|spawnSync)[[:space:]]*\\(|\\.innerHTML[[:space:]]*=|document\\.write[[:space:]]*\\(|\\.\\./|\\.\\.\\\\" "high" "Unsafe code pattern detected"
run_check "contentPolicy" "kill[[:space:]]+yourself|self-harm|do[[:space:]]+anything[[:space:]]+now" "medium" "Potential policy-sensitive language detected"

# Optional custom regex patterns.
while IFS= read -r custom_entry; do
  name="$(jq -r '.name // "custom"' <<<"$custom_entry")"
  pattern="$(jq -r '.pattern // empty' <<<"$custom_entry")"
  severity="$(jq -r '.severity // "medium"' <<<"$custom_entry")"
  if [[ -z "$pattern" ]]; then
    continue
  fi
  match="$(first_match "$pattern")"
  if [[ -n "$match" ]]; then
    add_check_fail "custom:$name" "$severity" "Custom pattern '$name' matched" "$pattern" "[REDACTED]"
  else
    add_check_pass "custom:$name"
  fi
done < <(jq -c '.options.customPatterns[]? | {name:(.name // "custom"), pattern:(.pattern // empty), severity:(.severity // "medium")}' <<<"$payload")

total_checks="$(jq 'length' <<<"$checks")"
failed_checks="$(jq '[.[] | select(.passed == false)] | length' <<<"$checks")"
passed_checks=$((total_checks - failed_checks))

highest_severity="$(jq -r '
  def rank: if . == "critical" then 4 elif . == "high" then 3 elif . == "medium" then 2 elif . == "low" then 1 else 0 end;
  [ .[] | select(.passed == false) | (.severity // "none") ] as $all
  | if ($all | length) == 0 then "none" else ($all | max_by(rank)) end
' <<<"$checks")"

overall_passed=true
if [[ "$failed_checks" -gt 0 ]]; then
  overall_passed=false
fi

sanitized="$content"
sanitized="$(printf '%s' "$sanitized" | sed -E 's/[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}/[EMAIL]/g')"
sanitized="$(printf '%s' "$sanitized" | sed -E 's/(AKIA|A3T|AGPA|AIDA|AROA|AIPA|ANPA|ANVA|ASIA)[A-Z0-9]{16}/[AWS_KEY]/g')"
sanitized="$(printf '%s' "$sanitized" | sed -E 's/(ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9_]{20,}/[GITHUB_TOKEN]/g')"

include_sanitized=false
if [[ "$sanitized" != "$content" ]]; then
  include_sanitized=true
fi

jq -n \
  --argjson passed "$overall_passed" \
  --argjson checks "$checks" \
  --argjson total "$total_checks" \
  --argjson passedChecks "$passed_checks" \
  --argjson failedChecks "$failed_checks" \
  --arg highestSeverity "$highest_severity" \
  --arg sanitized "$sanitized" \
  --argjson includeSanitized "$include_sanitized" \
  '{
    passed: $passed,
    checks: $checks,
    summary: {
      totalChecks: $total,
      passedChecks: $passedChecks,
      failedChecks: $failedChecks,
      highestSeverity: $highestSeverity
    }
  } + (if $includeSanitized then {sanitized: $sanitized} else {} end)'
