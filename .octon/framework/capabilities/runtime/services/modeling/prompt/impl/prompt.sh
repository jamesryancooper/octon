#!/usr/bin/env bash
# prompt.sh - Harness-native prompt compilation service.

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Enforce deny-by-default policy at runtime for this shell service.
source "$SCRIPT_DIR/../../../_ops/scripts/enforce-deny-by-default.sh"
octon_enforce_service_policy "prompt" "$0" "$@"


emit_error() {
  local code="$1"
  local message="$2"
  jq -n --arg message "$message" --argjson code "$code" \
    '{success:false,error:{code:"InputValidationError",exitCode:$code,message:$message,suggestedAction:"Fix request payload and retry."}}' >&2
  exit "$code"
}

if ! command -v jq >/dev/null 2>&1; then
  echo '{"success":false,"error":{"code":"UpstreamProviderError","exitCode":6,"message":"jq is required","suggestedAction":"Install jq"}}' >&2
  exit 6
fi

payload="$(cat)"
if [[ -z "$(echo "$payload" | tr -d '[:space:]')" ]]; then
  emit_error 5 "Expected JSON input on stdin"
fi

prompt_id="$(jq -r '.promptId // empty' <<<"$payload")"
if [[ -z "$prompt_id" ]]; then
  emit_error 5 "Missing required field: promptId"
fi

variant="$(jq -r '.options.variant // "default"' <<<"$payload")"
model="$(jq -r '.options.model // "gpt-4o-mini"' <<<"$payload")"
max_tokens="$(jq -r '.options.maxTokens // 0' <<<"$payload")"
include_hash="$(jq -r '.options.hash // true | if . then "true" else "false" end' <<<"$payload")"

variables_json="$(jq -c '.variables // {}' <<<"$payload")"
variables_pretty="$(jq -S '.variables // {}' <<<"$payload")"

content="Prompt ID: $prompt_id
Variant: $variant

Variables:
$variables_pretty"

# Approximate token estimate from word count.
estimated_tokens="$(printf '%s' "$content" | wc -w | awk '{print ($1 < 1 ? 1 : $1)}')"

if [[ "$max_tokens" =~ ^[0-9]+$ ]] && [[ "$max_tokens" -gt 0 ]] && [[ "$estimated_tokens" -gt "$max_tokens" ]]; then
  # Truncate by words to honor max token cap approximately.
  content="$(printf '%s' "$content" | awk -v m="$max_tokens" '{for(i=1;i<=NF && c<m;i++){printf "%s%s", $i, (c+1<m?" ":""); c++}}')"
  estimated_tokens="$max_tokens"
fi

hash_value=""
if [[ "$include_hash" == "true" ]]; then
  hash_value="sha256:$(printf '%s' "$content" | shasum | awk '{print $1}')"
fi

compiled_at="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

jq -n \
  --arg promptId "$prompt_id" \
  --arg variant "$variant" \
  --arg content "$content" \
  --arg model "$model" \
  --argjson estimated "$estimated_tokens" \
  --arg hash "$hash_value" \
  --arg compiledAt "$compiled_at" \
  --argjson variables "$variables_json" \
  '{
    promptId: $promptId,
    variant: $variant,
    content: $content,
    messages: [
      {role:"system",content:"You are the Octon AI agent runtime."},
      {role:"user",content:$content}
    ],
    tokens: {
      estimated: $estimated,
      model: $model
    },
    metadata: {
      version: "0.1.0",
      author: "octon",
      tags: ["harness-native", "deterministic"],
      model: $model,
      temperature: 0,
      compiledAt: $compiledAt,
      variables: $variables
    }
  } + (if $hash != "" then {hash: $hash} else {} end)'
