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
    '{
      result: {
        dryRun: true,
        accepted: true
      },
      runId: $runId,
      artifacts: [],
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
  '{
    result: $result,
    runId: $runId,
    artifacts: $artifacts,
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
