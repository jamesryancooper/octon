#!/usr/bin/env bash
# query.sh - Phase 1 runtime for hybrid retrieval and evidence assembly.

set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Enforce deny-by-default policy at runtime for this shell service.
source "$SCRIPT_DIR/../../../_ops/scripts/enforce-deny-by-default.sh"
octon_enforce_service_policy "query" "$0" "$@"


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SIGNALS_DIR="$SCRIPT_DIR/signals"
SERVICE_VERSION="0.1.0"
SERVICE_NAME="octon.service.query"
SERVICES_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
RUN_RECORD_DIR="$SERVICES_DIR/_ops/state/runs/query"

if ! command -v jq >/dev/null 2>&1; then
  echo '{"run":{"run_id":"run-invalid","service_version":"0.1.0","snapshot_id":"unknown"},"status":"error","candidates":[],"citations":[],"evidence":[],"diagnostics":{"strategy":{"use":[],"fuse":"rrf","top_k":1},"timings":{"total_ms":0},"deterministic_stages":[],"warnings":["jq is required."]},"error":{"code":"InputValidationError","message":"jq is required for query runtime."}}'
  exit 5
fi

now_ms() {
  if command -v perl >/dev/null 2>&1; then
    perl -MTime::HiRes=time -e 'printf("%.0f\n", time()*1000)'
  else
    echo $(( $(date +%s) * 1000 ))
  fi
}

error_exit_code() {
  case "$1" in
    InputValidationError|UnsupportedCommandError|UnsupportedSignalError)
      echo 5
      ;;
    SnapshotNotFoundError|MissingSignalArtifactError|SemanticScoringUnavailableError)
      echo 6
      ;;
    CitationAssemblyError|NativeInvariantViolation|ProviderTermLeakError)
      echo 4
      ;;
    *)
      echo 4
      ;;
  esac
}

run_json='{"run_id":"run-invalid","service_version":"0.1.0","snapshot_id":"unknown"}'
strategy_use_json='[]'
strategy_fuse='rrf'
strategy_top_k='1'
route_mode='flat'
memory_enabled='false'
memory_max_clues='3'
memory_clues_json='[]'
route_applied='false'
payload='{}'
command_name='unknown'

sanitize_inputs_json() {
  local raw="${1:-{}}"
  if ! jq -e . >/dev/null 2>&1 <<<"$raw"; then
    echo '{}'
    return
  fi

  jq -c '
    def redact:
      if type == "object" then
        with_entries(
          if (.key | ascii_downcase | test("(api_key|secret|password|token|auth|credential|private_key|access_key)")) then
            .value = "<REDACTED>"
          else
            .value |= redact
          end
        )
      elif type == "array" then
        map(redact)
      else
        .
      end;
    redact
  ' <<<"$raw" 2>/dev/null || echo '{}'
}

write_run_record() {
  local lifecycle_status="${1:-error}" # success|partial|error (service output semantics)
  local summary="${2:-query execution}"
  local duration_ms="${3:-0}"
  local output_json="${4:-{}}"
  local error_code="${5:-}"

  local run_id
  run_id="$(jq -r '.run_id // "run-invalid"' <<<"$run_json" 2>/dev/null || echo "run-invalid")"

  local sanitized_inputs
  sanitized_inputs="$(sanitize_inputs_json "$payload")"
  local inputs_hash
  inputs_hash="sha256:$(printf '%s' "$sanitized_inputs" | shasum | awk '{print $1}')"

  local record_status="success"
  if [[ "$lifecycle_status" == "error" ]]; then
    record_status="failure"
  fi

  local stage="implement"
  local risk="medium"
  local created_at
  created_at="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  local span_name="service.query.${command_name}"

  local record_json
  record_json="$(jq -n \
    --arg runId "$run_id" \
    --arg serviceName "$SERVICE_NAME" \
    --arg version "$SERVICE_VERSION" \
    --arg status "$record_status" \
    --arg summary "$summary" \
    --arg stage "$stage" \
    --arg risk "$risk" \
    --arg createdAt "$created_at" \
    --arg inputsHash "$inputs_hash" \
    --arg traceId "$run_id" \
    --arg span "$span_name" \
    --arg errorCode "$error_code" \
    --arg durationMs "$duration_ms" \
    --arg inputs "$sanitized_inputs" \
    --arg outputs "$output_json" '
    {
      runId: $runId,
      service: { name: $serviceName, version: $version },
      inputs: (($inputs | fromjson?) // {}),
      status: $status,
      summary: $summary,
      durationMs: (($durationMs | tonumber?) // 0),
      stage: $stage,
      risk: $risk,
      telemetry: { trace_id: $traceId, spans: [$span] },
      determinism: { inputsHash: $inputsHash },
      outputs: (($outputs | fromjson?) // {}),
      createdAt: $createdAt
    } + (if $errorCode != "" then {error: {code: $errorCode}} else {} end)
  ')"

  mkdir -p "$RUN_RECORD_DIR" 2>/dev/null || true
  printf '%s\n' "$record_json" > "$RUN_RECORD_DIR/$run_id.json" 2>/dev/null || true
}

emit_error() {
  local code="$1"
  local message="$2"
  local warnings_json="${3:-[]}"
  local timings_json="${4:-{\"total_ms\":0}}"
  local output_json

  output_json="$(jq -n \
    --argjson run "$run_json" \
    --arg code "$code" \
    --arg message "$message" \
    --argjson use "$strategy_use_json" \
    --arg fuse "$strategy_fuse" \
    --arg route "$route_mode" \
    --argjson routeApplied 'false' \
    --argjson topk "$strategy_top_k" \
    --argjson warnings "$warnings_json" \
    --argjson timings "$timings_json" '
    {
      run: $run,
      status: "error",
      candidates: [],
      citations: [],
      evidence: [],
      diagnostics: {
        strategy: {
          use: $use,
          fuse: $fuse,
          route: $route,
          top_k: $topk
        },
        timings: $timings,
        deterministic_stages: [],
        route_applied: $routeApplied
      },
      error: {
        code: $code,
        message: $message
      }
    }
    + (if ($warnings | length) > 0 then {diagnostics: (.diagnostics + {warnings: $warnings})} else {} end)
  ')"

  write_run_record "error" "$message" 0 "$output_json" "$code"
  printf '%s\n' "$output_json"
  exit "$(error_exit_code "$code")"
}

payload="$(cat)"
if [[ -z "$(echo "$payload" | tr -d '[:space:]')" ]]; then
  emit_error "InputValidationError" "Expected JSON input on stdin."
fi

if ! jq -e . >/dev/null 2>&1 <<<"$payload"; then
  emit_error "InputValidationError" "Invalid JSON payload."
fi

if jq -e '[.. | objects | keys[]] | any(. == "adapters" or . == "rerankers" or . == "retriever" or . == "provider" or . == "model")' >/dev/null <<<"$payload"; then
  emit_error "NativeInvariantViolation" "Adapter/provider keys are not allowed in query core payload."
fi

command_name="$(jq -r '.command // empty' <<<"$payload")"
query_text="$(jq -r '.query // empty' <<<"$payload")"
snapshot_id="$(jq -r '.index.snapshot // empty' <<<"$payload")"
strategy_use_json="$(jq -c '.strategy.use // []' <<<"$payload")"
strategy_fuse="$(jq -r '.strategy.fuse // empty' <<<"$payload")"
route_mode="$(jq -r '.strategy.route // "flat"' <<<"$payload")"
strategy_top_k="$(jq -r '.strategy.top_k // empty' <<<"$payload")"
required_signals_json="$(jq -c '.strategy.required_signals // []' <<<"$payload")"
weights_json="$(jq -c '.strategy.weights // {}' <<<"$payload")"
max_excerpts="$(jq -r '.evidence.max_excerpts // 8' <<<"$payload")"
max_chars="$(jq -r '.evidence.max_chars_per_excerpt // 320' <<<"$payload")"
memory_enabled="$(jq -r '.memory.enabled // false | if . then "true" else "false" end' <<<"$payload")"
memory_max_clues="$(jq -r '.memory.max_clues // 3' <<<"$payload")"

if [[ -z "$command_name" || -z "$query_text" || -z "$snapshot_id" || -z "$strategy_fuse" || -z "$strategy_top_k" ]]; then
  emit_error "InputValidationError" "Missing required fields: command, query, index.snapshot, strategy.fuse, strategy.top_k."
fi

if ! [[ "$strategy_top_k" =~ ^[0-9]+$ ]] || (( strategy_top_k < 1 )); then
  emit_error "InputValidationError" "strategy.top_k must be a positive integer."
fi

if ! [[ "$max_excerpts" =~ ^[0-9]+$ ]] || (( max_excerpts < 1 )); then
  emit_error "InputValidationError" "evidence.max_excerpts must be a positive integer."
fi

if ! [[ "$max_chars" =~ ^[0-9]+$ ]] || (( max_chars < 32 )); then
  emit_error "InputValidationError" "evidence.max_chars_per_excerpt must be an integer >= 32."
fi

case "$command_name" in
  ask|retrieve|explain) ;;
  *)
    emit_error "UnsupportedCommandError" "Unsupported command '$command_name'."
    ;;
esac

if [[ "$strategy_fuse" != "rrf" && "$strategy_fuse" != "weighted" ]]; then
  emit_error "InputValidationError" "strategy.fuse must be 'rrf' or 'weighted'."
fi

case "$route_mode" in
  flat|hierarchical|graph_global) ;;
  *)
    emit_error "InputValidationError" "strategy.route must be 'flat', 'hierarchical', or 'graph_global'."
    ;;
esac

if [[ "$(jq 'length' <<<"$strategy_use_json")" == "0" ]]; then
  emit_error "InputValidationError" "strategy.use must include at least one signal."
fi

while IFS= read -r sig; do
  case "$sig" in
    keyword|semantic|graph) ;;
    *)
      emit_error "UnsupportedSignalError" "Unsupported signal '$sig'."
      ;;
  esac
done < <(jq -r '.[]' <<<"$strategy_use_json")

if [[ "$route_mode" != "flat" ]] && ! jq -e '.strategy.use | index("graph") != null' >/dev/null <<<"$payload"; then
  emit_error "InputValidationError" "advanced routes require graph signal to be enabled in strategy.use."
fi

if ! [[ "$memory_max_clues" =~ ^[0-9]+$ ]] || (( memory_max_clues < 1 )) || (( memory_max_clues > 8 )); then
  emit_error "InputValidationError" "memory.max_clues must be an integer between 1 and 8."
fi

if ! jq -n -e \
  --argjson use "$strategy_use_json" \
  --argjson req "$required_signals_json" \
  '($req | map(select(. as $s | (($use | index($s)) == null))) | length) == 0' \
  >/dev/null; then
  emit_error "InputValidationError" "strategy.required_signals must be a subset of strategy.use."
fi

repo_root="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel 2>/dev/null || pwd)"
if [[ -d "$snapshot_id" ]]; then
  snapshot_path="$snapshot_id"
elif [[ -d "$repo_root/$snapshot_id" ]]; then
  snapshot_path="$repo_root/$snapshot_id"
else
  snapshot_path="$snapshot_id"
fi

run_id="run-$(printf '%s|%s|%s' "$command_name" "$query_text" "$snapshot_id" | shasum | awk '{print substr($1,1,12)}')"
run_json="$(jq -n --arg run_id "$run_id" --arg version "$SERVICE_VERSION" --arg snapshot "$snapshot_id" '{run_id:$run_id,service_version:$version,snapshot_id:$snapshot}')"

if [[ ! -d "$snapshot_path" ]]; then
  emit_error "SnapshotNotFoundError" "Snapshot '$snapshot_id' could not be resolved."
fi

signal_enabled() {
  local signal="$1"
  jq -e --arg s "$signal" '.strategy.use | index($s) != null' >/dev/null <<<"$payload"
}

signal_required() {
  local signal="$1"
  jq -e --arg s "$signal" '(.strategy.required_signals // []) | index($s) != null' >/dev/null <<<"$payload"
}

warnings_json='[]'
degraded_signals_json='[]'
deterministic_stages_json='[]'
partial_override='false'

add_warning() {
  local warning="$1"
  warnings_json="$(jq --arg w "$warning" '. + [$w]' <<<"$warnings_json")"
}

add_degraded() {
  local signal="$1"
  degraded_signals_json="$(jq --arg s "$signal" 'if index($s) then . else . + [$s] end' <<<"$degraded_signals_json")"
}

add_deterministic_stage() {
  local stage="$1"
  deterministic_stages_json="$(jq --arg s "$stage" 'if index($s) then . else . + [$s] end' <<<"$deterministic_stages_json")"
}

merge_signal_warnings() {
  local signal_output="$1"
  while IFS= read -r w; do
    [[ -z "$w" ]] && continue
    add_warning "$w"
  done < <(jq -r '.warnings[]? // empty' <<<"$signal_output")
}

merge_candidates_maxscore() {
  local left_json="${1:-[]}"
  local right_json="${2:-[]}"

  jq -n \
    --argjson left "$left_json" \
    --argjson right "$right_json" '
    ([($left + $right)[]]
      | map(select(type == "object" and ((.chunk_id // "") | length > 0)))
      | group_by(.chunk_id)
      | map(
          reduce .[] as $c (
            {chunk_id: (.[0].chunk_id // ""), doc_id: "", locator: "", score: 0};
            .doc_id = (if (.doc_id | length) > 0 then .doc_id else ($c.doc_id // "") end)
            | .locator = (if (.locator | length) > 0 then .locator else ($c.locator // "") end)
            | .score = ([.score, (($c.score // 0) | tonumber)] | max)
          )
        )
      | map(.doc_id = (if (.doc_id | length) > 0 then .doc_id else (.chunk_id | split("#")[0]) end))
      | map(.locator = (if (.locator | length) > 0 then .locator else (.doc_id + "#" + .chunk_id) end))
      | sort_by(-.score, .chunk_id))
  '
}

keyword_candidates='[]'
graph_candidates='[]'
semantic_candidates='[]'
route_candidates='[]'

keyword_ms=0
graph_ms=0
semantic_ms=0
fusion_ms=0
citation_ms=0
route_ms=0
memory_ms=0

retrieval_query="$query_text"

total_start_ms="$(now_ms)"
if [[ "$route_mode" == "flat" ]]; then
  route_applied='true'
fi

if [[ "$memory_enabled" == "true" ]]; then
  t0="$(now_ms)"
  memory_output="$($SCRIPT_DIR/routes/memory-clues.sh --query "$query_text" --max-clues "$memory_max_clues")"
  t1="$(now_ms)"
  memory_ms=$((t1 - t0))

  if [[ "$(jq -r '.ok // false' <<<"$memory_output")" != "true" ]]; then
    err_message="$(jq -r '.error.message // "memory clue extraction failed."' <<<"$memory_output")"
    add_warning "$err_message"
    partial_override='true'
  else
    memory_clues_json="$(jq -c '.clues // []' <<<"$memory_output")"
    next_query="$(jq -r '.augmented_query // empty' <<<"$memory_output")"
    if [[ -n "$next_query" ]]; then
      retrieval_query="$next_query"
    fi
    merge_signal_warnings "$memory_output"
  fi
fi

if signal_enabled "keyword"; then
  t0="$(now_ms)"
  keyword_output="$($SIGNALS_DIR/keyword.sh --query "$retrieval_query" --snapshot "$snapshot_path" --top-k "$((strategy_top_k * 4))")"
  t1="$(now_ms)"
  keyword_ms=$((t1 - t0))

  if [[ "$(jq -r '.ok // false' <<<"$keyword_output")" != "true" ]]; then
    err_code="$(jq -r '.error.code // "MissingSignalArtifactError"' <<<"$keyword_output")"
    err_message="$(jq -r '.error.message // "Keyword signal failed."' <<<"$keyword_output")"
    if signal_required "keyword"; then
      emit_error "$err_code" "$err_message"
    fi
    add_degraded "keyword"
    add_warning "$err_message"
  else
    keyword_candidates="$(jq -c '.candidates // []' <<<"$keyword_output")"
    add_deterministic_stage "keyword"
    merge_signal_warnings "$keyword_output"
  fi
fi

if signal_enabled "graph"; then
  graph_seed_json="$(jq -c '[.[].chunk_id] | unique' <<<"$keyword_candidates")"
  t0="$(now_ms)"
  graph_output="$($SIGNALS_DIR/graph.sh --snapshot "$snapshot_path" --seed-json "$graph_seed_json" --top-k "$((strategy_top_k * 4))")"
  t1="$(now_ms)"
  graph_ms=$((t1 - t0))

  if [[ "$(jq -r '.ok // false' <<<"$graph_output")" != "true" ]]; then
    err_code="$(jq -r '.error.code // "MissingSignalArtifactError"' <<<"$graph_output")"
    err_message="$(jq -r '.error.message // "Graph signal failed."' <<<"$graph_output")"
    if [[ "$route_mode" != "flat" ]]; then
      emit_error "$err_code" "$err_message"
    fi
    if signal_required "graph"; then
      emit_error "$err_code" "$err_message"
    fi
    add_degraded "graph"
    add_warning "$err_message"
  else
    graph_candidates="$(jq -c '.candidates // []' <<<"$graph_output")"
    add_deterministic_stage "graph"
    merge_signal_warnings "$graph_output"
  fi

  if [[ "$route_mode" != "flat" ]]; then
    route_script=""
    case "$route_mode" in
      hierarchical)
        route_script="$SCRIPT_DIR/routes/hierarchical.sh"
        ;;
      graph_global)
        route_script="$SCRIPT_DIR/routes/graph-global.sh"
        ;;
    esac

    if [[ -n "$route_script" ]]; then
      t0="$(now_ms)"
      route_output="$($route_script --query "$retrieval_query" --snapshot "$snapshot_path" --top-k "$((strategy_top_k * 4))")"
      t1="$(now_ms)"
      route_ms=$((t1 - t0))

      if [[ "$(jq -r '.ok // false' <<<"$route_output")" != "true" ]]; then
        err_code="$(jq -r '.error.code // "MissingSignalArtifactError"' <<<"$route_output")"
        err_message="$(jq -r '.error.message // "Route expansion failed."' <<<"$route_output")"
        emit_error "$err_code" "$err_message"
      else
        route_candidates="$(jq -c '.candidates // []' <<<"$route_output")"
        graph_candidates="$(merge_candidates_maxscore "$graph_candidates" "$route_candidates")"
        route_applied='true'
        merge_signal_warnings "$route_output"
      fi
    fi
  fi
fi

if signal_enabled "semantic"; then
  semantic_seed_json="$(jq -n --argjson k "$keyword_candidates" --argjson g "$graph_candidates" '[($k + $g)[]] | unique_by(.chunk_id)')"
  t0="$(now_ms)"
  semantic_output="$($SIGNALS_DIR/semantic.sh --query "$retrieval_query" --snapshot "$snapshot_path" --input-candidates-json "$semantic_seed_json" --top-k "$((strategy_top_k * 4))")"
  t1="$(now_ms)"
  semantic_ms=$((t1 - t0))

  if [[ "$(jq -r '.ok // false' <<<"$semantic_output")" != "true" ]]; then
    err_code="$(jq -r '.error.code // "SemanticScoringUnavailableError"' <<<"$semantic_output")"
    err_message="$(jq -r '.error.message // "Semantic signal failed."' <<<"$semantic_output")"
    if signal_required "semantic"; then
      emit_error "$err_code" "$err_message"
    fi
    add_degraded "semantic"
    add_warning "$err_message"
  else
    semantic_candidates="$(jq -c '.candidates // []' <<<"$semantic_output")"
    merge_signal_warnings "$semantic_output"
  fi
fi

if [[ "$strategy_fuse" == "weighted" && "$(jq 'length' <<<"$weights_json")" == "0" ]]; then
  add_warning "weights not provided for weighted fusion; using equal defaults."
  partial_override='true'
fi

signals_payload="$(jq -n \
  --argjson keyword "$keyword_candidates" \
  --argjson semantic "$semantic_candidates" \
  --argjson graph "$graph_candidates" \
  '{keyword:$keyword, semantic:$semantic, graph:$graph}')"

t0="$(now_ms)"
fusion_output="$($SCRIPT_DIR/fusion.sh --fuse "$strategy_fuse" --top-k "$strategy_top_k" --signals-json "$signals_payload" --weights-json "$weights_json")"
t1="$(now_ms)"
fusion_ms=$((t1 - t0))

if [[ "$(jq -r '.ok // false' <<<"$fusion_output")" != "true" ]]; then
  err_code="$(jq -r '.error.code // "InputValidationError"' <<<"$fusion_output")"
  err_message="$(jq -r '.error.message // "Fusion failed."' <<<"$fusion_output")"
  emit_error "$err_code" "$err_message"
fi

fused_candidates_json="$(jq -c '.candidates // []' <<<"$fusion_output")"
add_deterministic_stage "fusion"

t0="$(now_ms)"
cite_output="$($SCRIPT_DIR/cite.sh --snapshot "$snapshot_path" --candidates-json "$fused_candidates_json" --max-excerpts "$max_excerpts" --max-chars "$max_chars")"
t1="$(now_ms)"
citation_ms=$((t1 - t0))

if [[ "$(jq -r '.ok // false' <<<"$cite_output")" != "true" ]]; then
  err_code="$(jq -r '.error.code // "CitationAssemblyError"' <<<"$cite_output")"
  err_message="$(jq -r '.error.message // "Citation assembly failed."' <<<"$cite_output")"
  emit_error "$err_code" "$err_message"
fi

citations_json="$(jq -c '.citations // []' <<<"$cite_output")"
evidence_json="$(jq -c '.evidence // []' <<<"$cite_output")"
add_deterministic_stage "citation"

total_end_ms="$(now_ms)"
total_ms=$((total_end_ms - total_start_ms))
if (( total_ms < 0 )); then total_ms=0; fi

status="success"
if [[ "$(jq 'length' <<<"$degraded_signals_json")" != "0" || "$partial_override" == "true" ]]; then
  status="partial"
fi

diagnostics_json="$(jq -n \
  --argjson use "$strategy_use_json" \
  --arg fuse "$strategy_fuse" \
  --arg route "$route_mode" \
  --argjson routeApplied "$route_applied" \
  --argjson topk "$strategy_top_k" \
  --argjson total "$total_ms" \
  --argjson keywordMs "$keyword_ms" \
  --argjson semanticMs "$semantic_ms" \
  --argjson graphMs "$graph_ms" \
  --argjson routeMs "$route_ms" \
  --argjson memoryMs "$memory_ms" \
  --argjson fusionMs "$fusion_ms" \
  --argjson citationMs "$citation_ms" \
  --argjson deterministic "$deterministic_stages_json" \
  --argjson degraded "$degraded_signals_json" \
  --argjson warnings "$warnings_json" \
  --argjson memoryClues "$memory_clues_json" '
  {
    strategy: {
      use: $use,
      fuse: $fuse,
      route: $route,
      top_k: $topk
    },
    timings: {
      total_ms: $total,
      signal_ms: {
        keyword: $keywordMs,
        semantic: $semanticMs,
        graph: $graphMs,
        route: $routeMs,
        memory: $memoryMs,
        fusion: $fusionMs,
        citation: $citationMs
      }
    },
    deterministic_stages: $deterministic,
    route_applied: $routeApplied
  }
  + (if ($degraded | length) > 0 then {degraded_signals: $degraded} else {} end)
  + (if ($warnings | length) > 0 then {warnings: $warnings} else {} end)
  + (if ($memoryClues | length) > 0 then {memory_clues: $memoryClues} else {} end)
')"

if [[ "$command_name" == "ask" ]]; then
  answer_text="$(jq -r 'if length == 0 then "" else map(.excerpt) | .[0:2] | join(" ") end' <<<"$evidence_json")"
  if [[ -z "$answer_text" ]]; then
    answer_text="No relevant evidence found for query."
  fi

  final_output="$(jq -n \
    --argjson run "$run_json" \
    --arg status "$status" \
    --arg answer "$answer_text" \
    --argjson candidates "$fused_candidates_json" \
    --argjson citations "$citations_json" \
    --argjson evidence "$evidence_json" \
    --argjson diagnostics "$diagnostics_json" '
    {
      run: $run,
      status: $status,
      answer: $answer,
      candidates: $candidates,
      citations: $citations,
      evidence: $evidence,
      diagnostics: $diagnostics
    }
  ')"
else
  final_output="$(jq -n \
    --argjson run "$run_json" \
    --arg status "$status" \
    --argjson candidates "$fused_candidates_json" \
    --argjson citations "$citations_json" \
    --argjson evidence "$evidence_json" \
    --argjson diagnostics "$diagnostics_json" '
    {
      run: $run,
      status: $status,
      candidates: $candidates,
      citations: $citations,
      evidence: $evidence,
      diagnostics: $diagnostics
    }
  ')"
fi

write_run_record "$status" "$command_name completed with status $status" "$total_ms" "$final_output"
printf '%s\n' "$final_output"
