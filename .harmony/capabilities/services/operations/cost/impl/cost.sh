#!/usr/bin/env bash
# cost.sh - Shell implementation for cost estimate/record operations.

set -o pipefail

error_json() {
  local message="$1"
  local code="$2"
  jq -n --arg message "$message" --argjson code "$code" \
    '{success:false,error:{code:"InputValidationError",exitCode:$code,message:$message,suggestedAction:"Check input schema and retry."}}' >&2
  exit "$code"
}

if ! command -v jq >/dev/null 2>&1; then
  echo '{"success":false,"error":{"code":"UpstreamProviderError","exitCode":6,"message":"jq is required","suggestedAction":"Install jq"}}' >&2
  exit 6
fi

payload="$(cat)"
if [[ -z "$(echo "$payload" | tr -d '[:space:]')" ]]; then
  error_json "Expected JSON input on stdin" 5
fi

operation="$(jq -r '.operation // empty' <<<"$payload" 2>/dev/null)"
if [[ -z "$operation" ]]; then
  error_json "Missing required field: operation" 5
fi

pricing_for_model() {
  case "$1" in
    gpt-4o) echo "openai 2.5 10.0" ;;
    gpt-4o-mini|gpt-4o-mini-2024-07-18|gpt-3.5-turbo) echo "openai 0.15 0.6" ;;
    o1) echo "openai 15.0 60.0" ;;
    o1-mini) echo "openai 3.0 12.0" ;;
    o3-mini) echo "openai 1.1 4.4" ;;
    claude-sonnet|claude-3-5-sonnet-20241022) echo "anthropic 3.0 15.0" ;;
    claude-haiku|claude-3-5-haiku-20241022) echo "anthropic 0.8 4.0" ;;
    gemini-2.0-flash) echo "google 0.1 0.4" ;;
    mistral-large) echo "mistral 2.0 6.0" ;;
    mistral-small|codestral) echo "mistral 0.2 0.6" ;;
    ollama-*|local-*) echo "local 0 0" ;;
    *) echo "openai 0.15 0.6" ;;
  esac
}

calc_cost() {
  local input_tokens="$1"
  local output_tokens="$2"
  local input_price="$3"
  local output_price="$4"
  awk -v i="$input_tokens" -v o="$output_tokens" -v ip="$input_price" -v op="$output_price" 'BEGIN{printf "%.8f", ((i/1000000)*ip)+((o/1000000)*op)}'
}

iso_now() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

generate_uuid() {
  if command -v uuidgen >/dev/null 2>&1; then
    uuidgen | tr '[:upper:]' '[:lower:]'
    return
  fi

  if command -v openssl >/dev/null 2>&1; then
    openssl rand -hex 16 | sed -E 's/(.{8})(.{4})(.{4})(.{4})(.{12})/\1-\2-\3-\4-\5/'
    return
  fi

  # Fallback: timestamp + random bytes shaped as UUID.
  local hex
  hex="$(date +%s%N)$(od -An -N8 -tx1 /dev/urandom | tr -d ' \n')"
  hex="$(echo "$hex" | sed 's/[^a-fA-F0-9]//g' | cut -c1-32)"
  echo "$hex" | sed -E 's/(.{8})(.{4})(.{4})(.{4})(.{12})/\1-\2-\3-\4-\5/' | tr '[:upper:]' '[:lower:]'
}

if [[ "$operation" == "estimate" ]]; then
  workflow_type="$(jq -r '.workflowType // empty' <<<"$payload")"
  tier="$(jq -r '.tier // empty' <<<"$payload")"
  stage="$(jq -r '.stage // empty' <<<"$payload")"
  model="$(jq -r '.model // "gpt-4o-mini"' <<<"$payload")"
  input_tokens="$(jq -r '.inputTokens // 3000' <<<"$payload")"
  output_tokens="$(jq -r '.outputTokens // 2500' <<<"$payload")"

  [[ -n "$workflow_type" ]] || error_json "estimate requires workflowType" 5
  [[ -n "$tier" ]] || error_json "estimate requires tier" 5

  read -r provider input_price output_price <<<"$(pricing_for_model "$model")"
  estimated_cost="$(calc_cost "$input_tokens" "$output_tokens" "$input_price" "$output_price")"
  min_cost="$(awk -v c="$estimated_cost" 'BEGIN{printf "%.8f", c*0.7}')"
  max_cost="$(awk -v c="$estimated_cost" 'BEGIN{printf "%.8f", c*1.3}')"

  estimate_id="$(generate_uuid)"
  created_at="$(iso_now)"
  total_tokens=$((input_tokens + output_tokens))

  jq -n \
    --arg estimateId "$estimate_id" \
    --arg model "$model" \
    --arg provider "$provider" \
    --arg workflowType "$workflow_type" \
    --arg tier "$tier" \
    --arg stage "$stage" \
    --arg createdAt "$created_at" \
    --argjson inputTokens "$input_tokens" \
    --argjson outputTokens "$output_tokens" \
    --argjson totalTokens "$total_tokens" \
    --argjson estimatedCostUsd "$estimated_cost" \
    --argjson minCost "$min_cost" \
    --argjson maxCost "$max_cost" \
    '{
      estimateId: $estimateId,
      model: $model,
      provider: $provider,
      tokens: {
        inputTokens: $inputTokens,
        outputTokens: $outputTokens,
        totalTokens: $totalTokens,
        confidence: 0.6,
        basis: "heuristic"
      },
      estimatedCostUsd: $estimatedCostUsd,
      costRange: {
        min: $minCost,
        max: $maxCost
      },
      workflowType: $workflowType,
      tier: $tier,
      createdAt: $createdAt,
      exceedsBudget: false,
      budgetWarnings: []
    } + (if $stage != "" then {stage: $stage} else {} end)'

  exit 0
fi

if [[ "$operation" == "record" ]]; then
  model="$(jq -r '.model // "gpt-4o-mini"' <<<"$payload")"
  input_tokens="$(jq -r '.inputTokens // empty' <<<"$payload")"
  output_tokens="$(jq -r '.outputTokens // empty' <<<"$payload")"
  workflow_type="$(jq -r '.workflowType // empty' <<<"$payload")"
  tier="$(jq -r '.tier // empty' <<<"$payload")"
  task_id="$(jq -r '.taskId // empty' <<<"$payload")"
  estimate_id="$(jq -r '.estimateId // empty' <<<"$payload")"
  duration_ms="$(jq -r '.durationMs // empty' <<<"$payload")"
  success="$(jq -r '.success // empty' <<<"$payload")"
  error_text="$(jq -r '.error // empty' <<<"$payload")"

  [[ -n "$input_tokens" ]] || error_json "record requires inputTokens" 5
  [[ -n "$output_tokens" ]] || error_json "record requires outputTokens" 5
  [[ -n "$workflow_type" ]] || error_json "record requires workflowType" 5
  [[ -n "$tier" ]] || error_json "record requires tier" 5
  [[ -n "$duration_ms" ]] || error_json "record requires durationMs" 5
  [[ "$success" == "true" || "$success" == "false" ]] || error_json "record requires boolean success" 5

  read -r provider input_price output_price <<<"$(pricing_for_model "$model")"
  actual_cost="$(calc_cost "$input_tokens" "$output_tokens" "$input_price" "$output_price")"
  total_tokens=$((input_tokens + output_tokens))
  usage_id="$(generate_uuid)"
  timestamp="$(iso_now)"

  record_json="$(jq -n \
    --arg usageId "$usage_id" \
    --arg estimateId "$estimate_id" \
    --arg model "$model" \
    --arg provider "$provider" \
    --arg workflowType "$workflow_type" \
    --arg tier "$tier" \
    --arg taskId "$task_id" \
    --arg timestamp "$timestamp" \
    --arg error "$error_text" \
    --argjson input "$input_tokens" \
    --argjson output "$output_tokens" \
    --argjson total "$total_tokens" \
    --argjson actualCostUsd "$actual_cost" \
    --argjson durationMs "$duration_ms" \
    --argjson success "$success" \
    '{
      usageId: $usageId,
      model: $model,
      provider: $provider,
      tokens: {
        input: $input,
        output: $output,
        total: $total
      },
      actualCostUsd: $actualCostUsd,
      workflowType: $workflowType,
      tier: $tier,
      timestamp: $timestamp,
      durationMs: $durationMs,
      success: $success
    } +
    (if $estimateId != "" then {estimateId: $estimateId} else {} end) +
    (if $taskId != "" then {taskId: $taskId} else {} end) +
    (if $error != "" then {error: $error} else {} end)')"

  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  state_dir="$(cd "$script_dir/../../_state/runs" && pwd)"
  mkdir -p "$state_dir"
  echo "$record_json" >> "$state_dir/cost-usage.jsonl"

  echo "$record_json"
  exit 0
fi

error_json "Unsupported operation '$operation'" 5
