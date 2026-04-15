#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/extensions-common.sh"

extensions_common_init "${BASH_SOURCE[0]}"

PACK_ID=""
SOURCE_ID="bundled-first-party"
DISPATCHER_ID=""
CATALOG_PATH="$CATALOG_FILE"
INPUTS_JSON=""
INPUTS_FILE=""

usage() {
  cat <<'EOF'
usage:
  resolve-extension-route.sh --pack-id <id> --dispatcher-id <id> [--source-id <id>] [--inputs-json <json> | --inputs-file <path>] [--catalog <path>]
EOF
}

emit_result() {
  local status="$1" safe_to_run="$2" selected_route_id="$3" selected_binding_json="$4"
  local reason_codes_json="$5" precedence_trace_json="$6" normalized_inputs_json="$7" alternatives_json="$8"

  jq -cn \
    --arg schema_version "octon-extension-route-resolution-v1" \
    --arg pack_id "$PACK_ID" \
    --arg source_id "$SOURCE_ID" \
    --arg dispatcher_id "$DISPATCHER_ID" \
    --arg status "$status" \
    --argjson safe_to_run "$safe_to_run" \
    --arg selected_route_id "$selected_route_id" \
    --argjson selected_execution_binding "$selected_binding_json" \
    --argjson reason_codes "$reason_codes_json" \
    --argjson precedence_trace "$precedence_trace_json" \
    --argjson normalized_input_facts "$normalized_inputs_json" \
    --argjson alternatives_considered "$alternatives_json" '
    {
      schema_version: $schema_version,
      pack_id: $pack_id,
      source_id: $source_id,
      dispatcher_id: $dispatcher_id,
      status: $status,
      safe_to_run: $safe_to_run,
      selected_route_id: (if $selected_route_id == "" then null else $selected_route_id end),
      selected_execution_binding: $selected_execution_binding,
      reason_codes: $reason_codes,
      precedence_trace: $precedence_trace,
      normalized_input_facts: $normalized_input_facts,
      alternatives_considered: $alternatives_considered
    }'
}

matcher_matches() {
  local normalized_inputs_json="$1" matcher_json="$2"
  jq -e -n \
    --argjson inputs "$normalized_inputs_json" \
    --argjson matcher "$matcher_json" '
    def present($value):
      if $value == null then false
      elif ($value | type) == "string" then ($value | length) > 0
      elif ($value | type) == "boolean" then $value
      elif ($value | type) == "array" then ($value | length) > 0
      elif ($value | type) == "object" then ($value | length) > 0
      else true
      end;
    def cond_ok($condition):
      ($inputs[$condition.input_name] // null) as $value
      | if $condition.predicate == "present" then present($value)
        elif $condition.predicate == "absent" then (present($value) | not)
        elif $condition.predicate == "equals" then $value == $condition.value
        elif $condition.predicate == "one_of" then ($condition.values | index($value)) != null
        elif $condition.predicate == "not_one_of" then ($condition.values | index($value)) == null
        else false
        end;
    $matcher.all_of | all(cond_ok(.))
  ' >/dev/null
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --pack-id)
      shift
      PACK_ID="${1:-}"
      ;;
    --source-id)
      shift
      SOURCE_ID="${1:-}"
      ;;
    --dispatcher-id)
      shift
      DISPATCHER_ID="${1:-}"
      ;;
    --catalog)
      shift
      CATALOG_PATH="${1:-}"
      ;;
    --inputs-json)
      shift
      INPUTS_JSON="${1:-}"
      ;;
    --inputs-file)
      shift
      INPUTS_FILE="${1:-}"
      ;;
    *)
      usage >&2
      exit 2
      ;;
  esac
  shift
done

[[ -n "$PACK_ID" && -n "$DISPATCHER_ID" ]] || {
  usage >&2
  exit 2
}

if [[ -n "$INPUTS_JSON" && -n "$INPUTS_FILE" ]]; then
  usage >&2
  exit 2
fi

[[ "$CATALOG_PATH" = /* ]] || CATALOG_PATH="$ROOT_DIR/$CATALOG_PATH"

empty_json='{}'
empty_array='[]'
null_json='null'

if [[ ! -f "$CATALOG_PATH" ]]; then
  emit_result "blocked" false "" "$null_json" '["missing-catalog"]' "$empty_array" "$empty_json" "$empty_array"
  exit 1
fi

catalog_publication_status="$(yq -r '.publication_status // ""' "$CATALOG_PATH" 2>/dev/null || true)"
case "$catalog_publication_status" in
  published|published_with_quarantine)
    ;;
  *)
    emit_result "blocked" false "" "$null_json" '["extension-not-published"]' "$empty_array" "$empty_json" "$empty_array"
    exit 1
    ;;
esac

if [[ -n "$INPUTS_FILE" ]]; then
  [[ -f "$INPUTS_FILE" ]] || {
    emit_result "blocked" false "" "$null_json" '["missing-inputs-file"]' "$empty_array" "$empty_json" "$empty_array"
    exit 1
  }
  INPUTS_JSON="$(cat "$INPUTS_FILE")"
fi

if [[ -z "$INPUTS_JSON" ]]; then
  INPUTS_JSON='{}'
fi

if ! jq -e 'type == "object"' >/dev/null 2>&1 <<<"$INPUTS_JSON"; then
  emit_result "blocked" false "" "$null_json" '["invalid-inputs-json"]' "$empty_array" "$empty_json" "$empty_array"
  exit 1
fi

mapfile -t pack_matches < <(
  yq -o=json ".packs[]? | select(.pack_id == \"$PACK_ID\" and .source_id == \"$SOURCE_ID\")" "$CATALOG_PATH" 2>/dev/null | jq -c '.' || true
)

if [[ "${#pack_matches[@]}" -gt 1 ]]; then
  emit_result "blocked" false "" "$null_json" '["duplicate-pack-entry"]' "$empty_array" "$empty_json" "$empty_array"
  exit 1
fi

pack_json="${pack_matches[0]:-}"
if [[ -z "$pack_json" || "$pack_json" == "null" ]]; then
  emit_result "blocked" false "" "$null_json" '["missing-pack-entry"]' "$empty_array" "$empty_json" "$empty_array"
  exit 1
fi

publication_status="$(jq -r '.publication_status // ""' <<<"$pack_json")"
compatibility_status="$(jq -r '.compatibility_status // ""' <<<"$pack_json")"

case "$publication_status" in
  published|published_with_quarantine)
    ;;
  *)
    emit_result "blocked" false "" "$null_json" '["extension-not-published"]' "$empty_array" "$empty_json" "$empty_array"
    exit 1
    ;;
esac

if [[ "$compatibility_status" == "incompatible" ]]; then
  emit_result "blocked" false "" "$null_json" '["extension-incompatible"]' "$empty_array" "$empty_json" "$empty_array"
  exit 1
fi

mapfile -t dispatcher_matches < <(
  jq -c --arg dispatcher_id "$DISPATCHER_ID" '.route_dispatchers[]? | select(.dispatcher_id == $dispatcher_id)' <<<"$pack_json" || true
)

if [[ "${#dispatcher_matches[@]}" -gt 1 ]]; then
  emit_result "blocked" false "" "$null_json" '["duplicate-dispatcher-entry"]' "$empty_array" "$empty_json" "$empty_array"
  exit 1
fi

dispatcher_json="${dispatcher_matches[0]:-}"
if [[ -z "$dispatcher_json" || "$dispatcher_json" == "null" ]]; then
  emit_result "blocked" false "" "$null_json" '["missing-dispatcher-entry"]' "$empty_array" "$empty_json" "$empty_array"
  exit 1
fi

normalized_inputs_json="$(
  jq -cn \
    --argjson accepted "$(jq -c '.accepted_inputs // []' <<<"$dispatcher_json")" \
    --argjson raw "$INPUTS_JSON" '
      reduce $accepted[] as $key ({};
        .[$key] =
          (if ($raw | has($key)) then
             ($raw[$key] // null) as $value
             | if $value == null then null
               elif ($value | type) == "string" then
                 ($value | gsub("^\\s+|\\s+$"; "")) as $trimmed
                 | if $trimmed == "" then null else $trimmed end
               else
                 $value
               end
           else
             null
           end)
      )'
)"

selected_status=""
selected_route_id=""
selected_binding_json="$null_json"
selected_reason_codes_json="$empty_array"
precedence_trace_json="$empty_array"
alternatives_json="$empty_array"
declare -a matched_matcher_jsons=()

while IFS= read -r matcher_id; do
  [[ -n "$matcher_id" ]] || continue
  route_json="$(jq -c --arg matcher_id "$matcher_id" '.routes[]? | select(any(.matchers[]?; .matcher_id == $matcher_id))' <<<"$dispatcher_json" | head -n 1)"
  matcher_json="$(jq -c --arg matcher_id "$matcher_id" '.routes[]?.matchers[]? | select(.matcher_id == $matcher_id)' <<<"$dispatcher_json" | head -n 1)"
  if [[ -z "$route_json" || -z "$matcher_json" ]]; then
    emit_result "blocked" false "" "$null_json" '["invalid-dispatcher-metadata"]' "$empty_array" "$normalized_inputs_json" "$empty_array"
    exit 1
  fi

  route_id="$(jq -r '.route_id' <<<"$route_json")"
  matched=false
  if matcher_matches "$normalized_inputs_json" "$matcher_json"; then
    matched=true
    matched_matcher_jsons+=("$(jq -cn --arg matcher_id "$matcher_id" --arg route_id "$route_id" --argjson reason_codes "$(jq -c '.reason_codes' <<<"$matcher_json")" '{matcher_id: $matcher_id, route_id: $route_id, reason_codes: $reason_codes}')")
    if [[ -z "$selected_status" ]]; then
      selected_status="$(jq -r '.status' <<<"$route_json")"
      selected_route_id="$route_id"
      selected_reason_codes_json="$(jq -c '.reason_codes' <<<"$matcher_json")"
      if [[ "$selected_status" == "resolved" ]]; then
        binding_id="$(jq -r '.execution_binding_id // ""' <<<"$route_json")"
        selected_binding_json="$(jq -c --arg binding_id "$binding_id" '.execution_bindings[]? | select(.binding_id == $binding_id)' <<<"$dispatcher_json" | head -n 1)"
        if [[ -z "$selected_binding_json" || "$selected_binding_json" == "null" ]]; then
          emit_result "blocked" false "$selected_route_id" "$null_json" '["missing-execution-binding"]' "$empty_array" "$normalized_inputs_json" "$empty_array"
          exit 1
        fi
      fi
    fi
  fi

  precedence_trace_json="$(
    jq -cn \
      --argjson current "$precedence_trace_json" \
      --arg matcher_id "$matcher_id" \
      --arg route_id "$route_id" \
      --argjson matched "$matched" \
      '$current + [{matcher_id: $matcher_id, route_id: $route_id, matched: $matched}]'
  )"
done < <(jq -r '.precedence[]? // ""' <<<"$dispatcher_json")

if [[ -z "$selected_status" ]]; then
  emit_result "blocked" false "" "$null_json" '["no-matching-route"]' "$precedence_trace_json" "$normalized_inputs_json" "$empty_array"
  exit 1
fi

alternatives_json="$(
  jq -cn \
    --argjson matched "$(
      if [[ "${#matched_matcher_jsons[@]}" -eq 0 ]]; then
        printf '%s' "$empty_array"
      else
        printf '%s\n' "${matched_matcher_jsons[@]}" | jq -s '.'
      fi
    )" \
    --arg selected_route_id "$selected_route_id" '
      $matched | map(select(.route_id != $selected_route_id))
    '
)"

if [[ "$selected_status" == "resolved" ]]; then
  emit_result "$selected_status" true "$selected_route_id" "${selected_binding_json:-$null_json}" "$selected_reason_codes_json" "$precedence_trace_json" "$normalized_inputs_json" "$alternatives_json"
  exit 0
fi

emit_result "$selected_status" false "$selected_route_id" "$null_json" "$selected_reason_codes_json" "$precedence_trace_json" "$normalized_inputs_json" "$alternatives_json"
exit 1
