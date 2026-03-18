#!/usr/bin/env bash
# flow-client.sh - HTTP client wrapper for Flow service.

set -o pipefail

emit_error() {
  local code="$1"
  local message="$2"
  jq -n --arg message "$message" --argjson code "$code" \
    '{success:false,error:{code:"UpstreamProviderError",exitCode:$code,message:$message,suggestedAction:"Check flow runner endpoint and payload."}}' >&2
  exit "$code"
}

if ! command -v jq >/dev/null 2>&1; then
  emit_error 6 "jq is required"
fi

if ! command -v curl >/dev/null 2>&1; then
  emit_error 6 "curl is required"
fi

FLOW_START_TS="${FLOW_START_TS:-$(date +%s)}"

generate_uuid() {
  if command -v uuidgen >/dev/null 2>&1; then
    uuidgen | tr '[:upper:]' '[:lower:]'
    return
  fi

  if command -v openssl >/dev/null 2>&1; then
    openssl rand -hex 16 | sed -E 's/(.{8})(.{4})(.{4})(.{4})(.{12})/\1-\2-\3-\4-\5/'
    return
  fi

  local hex
  hex="$(date +%s%N)$(od -An -N8 -tx1 /dev/urandom | tr -d ' \n')"
  hex="$(echo "$hex" | sed 's/[^a-fA-F0-9]//g' | cut -c1-32)"
  echo "$hex" | sed -E 's/(.{8})(.{4})(.{4})(.{4})(.{12})/\1-\2-\3-\4-\5/' | tr '[:upper:]' '[:lower:]'
}

flow_elapsed_ms() {
  local now elapsed
  now="$(date +%s)"
  elapsed=$(( (now - FLOW_START_TS) * 1000 ))
  if (( elapsed < 0 )); then
    elapsed=0
  fi
  printf '%s\n' "$elapsed"
}

flow_default_context_acquisition_json() {
  local file_reads search_queries commands subagent_spawns duration_ms
  file_reads="${OCTON_CONTEXT_FILE_READS:-0}"
  search_queries="${OCTON_CONTEXT_SEARCH_QUERIES:-0}"
  commands="${OCTON_CONTEXT_COMMANDS:-1}"
  subagent_spawns="${OCTON_CONTEXT_SUBAGENT_SPAWNS:-0}"
  duration_ms="$(flow_elapsed_ms)"

  [[ "$file_reads" =~ ^[0-9]+$ ]] || file_reads=0
  [[ "$search_queries" =~ ^[0-9]+$ ]] || search_queries=0
  [[ "$commands" =~ ^[0-9]+$ ]] || commands=0
  [[ "$subagent_spawns" =~ ^[0-9]+$ ]] || subagent_spawns=0
  [[ "$duration_ms" =~ ^[0-9]+$ ]] || duration_ms=0

  jq -cn \
    --argjson file_reads "$file_reads" \
    --argjson search_queries "$search_queries" \
    --argjson commands "$commands" \
    --argjson subagent_spawns "$subagent_spawns" \
    --argjson duration_ms "$duration_ms" \
    '{
      file_reads: $file_reads,
      search_queries: $search_queries,
      commands: $commands,
      subagent_spawns: $subagent_spawns,
      duration_ms: $duration_ms
    }'
}

payload="$(cat)"
if [[ -z "$(echo "$payload" | tr -d '[:space:]')" ]]; then
  emit_error 5 "Expected JSON input on stdin"
fi

flow_name="$(jq -r '.config.flowName // empty' <<<"$payload")"
prompt_path="$(jq -r '.config.canonicalPromptPath // empty' <<<"$payload")"
manifest_path="$(jq -r '.config.workflowManifestPath // empty' <<<"$payload")"
workspace_root="$(jq -r '.config.workspaceRoot // env.PWD' <<<"$payload")"
entrypoint="$(jq -r '.config.workflowEntrypoint // empty' <<<"$payload")"
dry_run="$(jq -r '.dryRun // false | if . then "true" else "false" end' <<<"$payload")"

[[ -n "$flow_name" ]] || emit_error 5 "Missing config.flowName"
[[ -n "$prompt_path" ]] || emit_error 5 "Missing config.canonicalPromptPath"
[[ -n "$manifest_path" ]] || emit_error 5 "Missing config.workflowManifestPath"

run_id="$(generate_uuid)"
endpoint="${FLOW_SERVICE_URL:-http://127.0.0.1:8410/flows/run}"
timeout_seconds="${FLOW_SERVICE_TIMEOUT_SECONDS:-30}"
context_acquisition_json="$(flow_default_context_acquisition_json)"
context_overhead_ratio="${OCTON_CONTEXT_OVERHEAD_RATIO:-0}"
if ! jq -en --arg ratio "$context_overhead_ratio" '$ratio | tonumber | . >= 0' >/dev/null 2>&1; then
  context_overhead_ratio="0"
fi

request_json="$(jq -n \
  --arg runId "$run_id" \
  --arg flowName "$flow_name" \
  --arg canonicalPromptPath "$prompt_path" \
  --arg workflowManifestPath "$manifest_path" \
  --arg workflowEntrypoint "$entrypoint" \
  --arg workspaceRoot "$workspace_root" \
  --argjson params "$(jq -c '.params // {}' <<<"$payload")" \
  '{
    runId: $runId,
    flowName: $flowName,
    canonicalPromptPath: $canonicalPromptPath,
    workflowManifestPath: $workflowManifestPath,
    workspaceRoot: $workspaceRoot,
    params: $params
  } + (if $workflowEntrypoint != "" then {workflowEntrypoint: $workflowEntrypoint} else {} end)')"

if [[ "$dry_run" == "true" ]]; then
  jq -n \
    --arg runId "$run_id" \
    --arg flowName "$flow_name" \
    --arg workflowManifestPath "$manifest_path" \
    --arg canonicalPromptPath "$prompt_path" \
    --arg workspaceRoot "$workspace_root" \
    --arg runnerEndpoint "$endpoint" \
    --arg workflowEntrypoint "$entrypoint" \
    --argjson context_acquisition "$context_acquisition_json" \
    --arg context_overhead_ratio "$context_overhead_ratio" \
    '{
      result: {
        dryRun: true,
        accepted: true
      },
      runId: $runId,
      artifacts: [],
      context_acquisition: $context_acquisition,
      context_overhead_ratio: ($context_overhead_ratio | tonumber),
      metadata: {
        flowName: $flowName,
        workflowManifestPath: $workflowManifestPath,
        canonicalPromptPath: $canonicalPromptPath,
        workspaceRoot: $workspaceRoot,
        runnerEndpoint: $runnerEndpoint
      }
    } + (if $workflowEntrypoint != "" then {metadata: (.metadata + {workflowEntrypoint: $workflowEntrypoint})} else {} end)'
  exit 0
fi

if ! response_with_code="$(curl -sS --max-time "$timeout_seconds" \
  -H 'Content-Type: application/json' \
  -X POST \
  -d "$request_json" \
  -w $'\n%{http_code}' \
  "$endpoint")"; then
  emit_error 6 "Failed to reach flow runner endpoint: $endpoint"
fi

http_code="$(printf '%s' "$response_with_code" | tail -n 1)"
response_body="$(printf '%s' "$response_with_code" | sed '$d')"

if [[ "$http_code" -lt 200 || "$http_code" -ge 300 ]]; then
  emit_error 6 "Flow runner returned HTTP $http_code: $response_body"
fi

if jq -e . >/dev/null 2>&1 <<<"$response_body"; then
  result_json="$(jq -c '.result // .' <<<"$response_body")"
  artifacts_json="$(jq -c '.artifacts // []' <<<"$response_body")"
  runtime_run_id="$(jq -r '.runtimeRunId // .runId // empty' <<<"$response_body")"
else
  result_json="$(jq -cn --arg text "$response_body" '$text')"
  artifacts_json='[]'
  runtime_run_id=""
fi

jq -n \
  --argjson result "$result_json" \
  --arg runId "$run_id" \
  --argjson artifacts "$artifacts_json" \
  --arg flowName "$flow_name" \
  --arg workflowManifestPath "$manifest_path" \
  --arg canonicalPromptPath "$prompt_path" \
  --arg workspaceRoot "$workspace_root" \
  --arg runnerEndpoint "$endpoint" \
  --arg workflowEntrypoint "$entrypoint" \
  --arg runtimeRunId "$runtime_run_id" \
  --argjson context_acquisition "$context_acquisition_json" \
  --arg context_overhead_ratio "$context_overhead_ratio" \
  '{
    result: $result,
    runId: $runId,
    artifacts: $artifacts,
    context_acquisition: $context_acquisition,
    context_overhead_ratio: ($context_overhead_ratio | tonumber),
    metadata: {
      flowName: $flowName,
      workflowManifestPath: $workflowManifestPath,
      canonicalPromptPath: $canonicalPromptPath,
      workspaceRoot: $workspaceRoot,
      runnerEndpoint: $runnerEndpoint
    }
  } +
  (if $workflowEntrypoint != "" then {metadata: (.metadata + {workflowEntrypoint: $workflowEntrypoint})} else {} end) +
  (if $runtimeRunId != "" then {metadata: (.metadata + {runtimeRunId: $runtimeRunId})} else {} end)'
