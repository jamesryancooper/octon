#!/usr/bin/env bash
# filesystem-graph.sh - compatibility wrapper over runtime wasm service.

set -o pipefail

CONTRACT_VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HARMONY_DIR="$(cd "$SCRIPT_DIR/../../../../.." && pwd)"
REPO_ROOT="$(cd "$HARMONY_DIR/.." && pwd)"
RUNTIME_RUN="$HARMONY_DIR/runtime/run"

if ! command -v jq >/dev/null 2>&1; then
  echo '{"ok":false,"filesystem_graph_contract_version":"1.0.0","command":"unknown","result":{},"errors":["ERR_FILESYSTEM_GRAPH_INPUT_INVALID: jq is required"]}'
  exit 5
fi

emit_success() {
  local command="$1"
  local result_json="$2"
  local snapshot_id="${3:-}"

  if [[ -n "$snapshot_id" ]]; then
    jq -cn \
      --arg v "$CONTRACT_VERSION" \
      --arg c "$command" \
      --arg s "$snapshot_id" \
      --argjson r "$result_json" \
      '{ok:true,filesystem_graph_contract_version:$v,command:$c,snapshot_id:$s,result:$r}'
  else
    jq -cn \
      --arg v "$CONTRACT_VERSION" \
      --arg c "$command" \
      --argjson r "$result_json" \
      '{ok:true,filesystem_graph_contract_version:$v,command:$c,result:$r}'
  fi
}

emit_error() {
  local command="$1"
  local code="$2"
  local message="$3"
  jq -cn \
    --arg v "$CONTRACT_VERSION" \
    --arg c "$command" \
    --arg e "$code: $message" \
    '{ok:false,filesystem_graph_contract_version:$v,command:$c,result:{},errors:[$e]}'
}

to_repo_relative() {
  local value="$1"
  if [[ -z "$value" || "$value" != /* ]]; then
    echo "$value"
    return 0
  fi

  local abs="$value"
  if [[ -d "$value" ]]; then
    abs="$(cd "$value" && pwd)"
  fi

  if [[ "$abs" == "$REPO_ROOT" ]]; then
    echo "."
    return 0
  fi

  case "$abs" in
    "$REPO_ROOT"/*)
      echo "${abs#"$REPO_ROOT/"}"
      return 0
      ;;
  esac

  return 1
}

if [[ ! -x "$RUNTIME_RUN" ]]; then
  emit_error "unknown" "ERR_FILESYSTEM_GRAPH_INTERNAL" "Runtime launcher not found: $RUNTIME_RUN"
  exit 4
fi

payload_raw="$(cat)"
if [[ -z "$(echo "$payload_raw" | tr -d '[:space:]')" ]]; then
  emit_error "unknown" "ERR_FILESYSTEM_GRAPH_INPUT_INVALID" "Expected JSON input on stdin."
  exit 5
fi

if ! jq -e . >/dev/null 2>&1 <<<"$payload_raw"; then
  emit_error "unknown" "ERR_FILESYSTEM_GRAPH_INPUT_INVALID" "Invalid JSON payload."
  exit 5
fi

command="$(jq -r '.command // empty' <<<"$payload_raw")"
if [[ -z "$command" ]]; then
  emit_error "unknown" "ERR_FILESYSTEM_GRAPH_INPUT_INVALID" "payload.command is required."
  exit 5
fi

tool_input="$(jq -c '.payload // {}' <<<"$payload_raw")"
snapshot_id="$(jq -r '.snapshot_id // empty' <<<"$payload_raw")"
state_dir="$(jq -r '.state_dir // empty' <<<"$payload_raw")"

if [[ -n "$state_dir" ]]; then
  if ! state_dir="$(to_repo_relative "$state_dir")"; then
    emit_error "$command" "ERR_FILESYSTEM_GRAPH_PATH_INVALID" "state_dir must be inside repository root."
    exit 4
  fi
fi

if [[ "$command" == "snapshot.build" ]]; then
  root_payload="$(jq -r '.root // empty' <<<"$tool_input")"
  if [[ -n "$root_payload" && "$root_payload" == /* ]]; then
    if ! root_payload="$(to_repo_relative "$root_payload")"; then
      emit_error "$command" "ERR_FILESYSTEM_GRAPH_PATH_INVALID" "payload.root must be inside repository root."
      exit 4
    fi
    tool_input="$(jq -c --arg root "$root_payload" '. + {root:$root}' <<<"$tool_input")"
  fi
fi

if [[ "$command" == "snapshot.diff" ]]; then
  for key in base head state_dir; do
    path_value="$(jq -r --arg key "$key" '.[$key] // empty' <<<"$tool_input")"
    if [[ -n "$path_value" && "$path_value" == /* ]]; then
      if ! rel_value="$(to_repo_relative "$path_value")"; then
        emit_error "$command" "ERR_FILESYSTEM_GRAPH_PATH_INVALID" "payload.$key absolute path must be inside repository root."
        exit 4
      fi
      tool_input="$(jq -c --arg key "$key" --arg value "$rel_value" '. + {($key): $value}' <<<"$tool_input")"
    fi
  done
fi

if [[ -n "$snapshot_id" ]]; then
  tool_input="$(jq -c --arg snapshot_id "$snapshot_id" '. + {snapshot_id:$snapshot_id}' <<<"$tool_input")"
fi
if [[ -n "$state_dir" ]]; then
  tool_input="$(jq -c --arg state_dir "$state_dir" '. + {state_dir:$state_dir}' <<<"$tool_input")"
fi

if ! raw_out="$($RUNTIME_RUN tool interfaces/filesystem-graph "$command" --json "$tool_input" 2>&1)"; then
  msg="$(echo "$raw_out" | tr '\n' ' ' | sed 's/[[:space:]]\+/ /g')"
  emit_error "$command" "ERR_FILESYSTEM_GRAPH_OPERATION_FAILED" "$msg"
  exit 4
fi

if ! result_json="$(jq -c . <<<"$raw_out" 2>/dev/null)"; then
  emit_error "$command" "ERR_FILESYSTEM_GRAPH_INTERNAL" "Runtime returned non-JSON output."
  exit 4
fi

if jq -e '.ok == false and (.error.code? != null)' >/dev/null 2>&1 <<<"$result_json"; then
  code="$(jq -r '.error.code // "ERR_FILESYSTEM_GRAPH_OPERATION_FAILED"' <<<"$result_json")"
  message="$(jq -r '.error.message // "Service operation failed."' <<<"$result_json")"
  emit_error "$command" "$code" "$message"
  exit 4
fi

snapshot_out="$(jq -r '.snapshot_id // empty' <<<"$result_json")"
if [[ -z "$snapshot_out" ]]; then
  snapshot_out="$snapshot_id"
fi

emit_success "$command" "$result_json" "$snapshot_out"
