#!/usr/bin/env bash
# run-fixtures.sh - Execute Query fixture pack and validate stable expectations.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
FIXTURE_DIR="$SERVICE_DIR/fixtures"
SNAPSHOT_ROOT="/tmp/octon-query-indexes"
ONLY_FIXTURE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --snapshot-root)
      SNAPSHOT_ROOT="${2:-}"
      shift 2
      ;;
    --fixture)
      ONLY_FIXTURE="${2:-}"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 2
      ;;
  esac
done

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required" >&2
  exit 6
fi

bash "$SCRIPT_DIR/make-test-snapshot.sh" --output-root "$SNAPSHOT_ROOT" >/dev/null

mapfile -t fixtures < <(find "$FIXTURE_DIR" -maxdepth 1 -type f -name '*.fixture.json' | sort)
if [[ -n "$ONLY_FIXTURE" ]]; then
  mapfile -t fixtures < <(printf '%s\n' "${fixtures[@]}" | grep -E "$ONLY_FIXTURE" || true)
fi

if [[ ${#fixtures[@]} -eq 0 ]]; then
  echo "No fixtures found." >&2
  exit 1
fi

passes=0
fails=0

for fixture in "${fixtures[@]}"; do
  id="$(jq -r '.metadata.id // "unknown"' "$fixture")"
  cmd="$(jq -r '.input.command // ""' "$fixture")"
  expected_status="$(jq -r '.expected_output.status // ""' "$fixture")"
  expected_error="$(jq -r '.expected_output.error.code // ""' "$fixture")"

  if [[ -z "$expected_status" ]]; then
    echo "FAIL [$id] missing expected_output.status"
    fails=$((fails + 1))
    continue
  fi

  payload="$(jq -c '.input' "$fixture")"
  runtime_env_json="$(jq -c '.metadata.runtime_env // {}' "$fixture")"

  # Map fixture-relative snapshot IDs (e.g., indexes/test-snapshot) to the
  # generated snapshot root when needed.
  snapshot_hint="$(jq -r '.index.snapshot // ""' <<<"$payload")"
  if [[ -n "$snapshot_hint" && ! -d "$snapshot_hint" ]]; then
    snapshot_base="$(basename "$snapshot_hint")"
    if [[ -d "$SNAPSHOT_ROOT/$snapshot_base" ]]; then
      payload="$(jq -c --arg snap "$SNAPSHOT_ROOT/$snapshot_base" '.index.snapshot = $snap' <<<"$payload")"
    fi
  fi

  tmp_out="$(mktemp)"
  set +e
  if [[ "$runtime_env_json" != "{}" ]]; then
    (
      while IFS=$'\t' read -r k v; do
        export "$k=$v"
      done < <(jq -r 'to_entries[] | [.key, .value] | @tsv' <<<"$runtime_env_json")
      printf '%s' "$payload" | bash "$SCRIPT_DIR/query.sh"
    ) >"$tmp_out"
    exit_code=$?
  else
    printf '%s' "$payload" | bash "$SCRIPT_DIR/query.sh" >"$tmp_out"
    exit_code=$?
  fi
  set -e

  if ! jq -e . >/dev/null 2>&1 <"$tmp_out"; then
    echo "FAIL [$id] runtime output is not valid JSON"
    rm -f "$tmp_out"
    fails=$((fails + 1))
    continue
  fi

  if ! jq -e '.diagnostics.strategy.route | type == "string"' "$tmp_out" >/dev/null; then
    echo "FAIL [$id] diagnostics.strategy.route missing"
    rm -f "$tmp_out"
    fails=$((fails + 1))
    continue
  fi

  actual_status="$(jq -r '.status // ""' "$tmp_out")"
  if [[ "$actual_status" != "$expected_status" ]]; then
    echo "FAIL [$id] expected status '$expected_status' got '$actual_status'"
    rm -f "$tmp_out"
    fails=$((fails + 1))
    continue
  fi

  if [[ -n "$expected_error" ]]; then
    actual_error="$(jq -r '.error.code // ""' "$tmp_out")"
    if [[ "$actual_error" != "$expected_error" ]]; then
      echo "FAIL [$id] expected error '$expected_error' got '$actual_error'"
      rm -f "$tmp_out"
      fails=$((fails + 1))
      continue
    fi
  fi

  if [[ "$cmd" == "ask" && "$actual_status" != "error" ]]; then
    if ! jq -e '(.answer // "") | length > 0' "$tmp_out" >/dev/null; then
      echo "FAIL [$id] ask response missing non-empty answer"
      rm -f "$tmp_out"
      fails=$((fails + 1))
      continue
    fi
  fi

  expected_det="$(jq -c '.expected_output.diagnostics.deterministic_stages // []' "$fixture")"
  if [[ "$expected_det" != "[]" ]]; then
    actual_det="$(jq -c '.diagnostics.deterministic_stages // []' "$tmp_out")"
    if [[ "$actual_det" != "$expected_det" ]]; then
      echo "FAIL [$id] deterministic_stages mismatch expected=$expected_det actual=$actual_det"
      rm -f "$tmp_out"
      fails=$((fails + 1))
      continue
    fi
  fi

  expected_route="$(jq -r '.expected_output.diagnostics.strategy.route // ""' "$fixture")"
  if [[ -n "$expected_route" ]]; then
    actual_route="$(jq -r '.diagnostics.strategy.route // ""' "$tmp_out")"
    if [[ "$actual_route" != "$expected_route" ]]; then
      echo "FAIL [$id] expected route '$expected_route' got '$actual_route'"
      rm -f "$tmp_out"
      fails=$((fails + 1))
      continue
    fi
  fi

  expected_deg="$(jq -c '.expected_output.diagnostics.degraded_signals // []' "$fixture")"
  if [[ "$expected_deg" != "[]" ]]; then
    actual_deg="$(jq -c '.diagnostics.degraded_signals // []' "$tmp_out")"
    if [[ "$actual_deg" != "$expected_deg" ]]; then
      echo "FAIL [$id] degraded_signals mismatch expected=$expected_deg actual=$actual_deg"
      rm -f "$tmp_out"
      fails=$((fails + 1))
      continue
    fi
  fi

  expected_memory_clues="$(jq -c '.expected_output.diagnostics.memory_clues // []' "$fixture")"
  if [[ "$expected_memory_clues" != "[]" ]]; then
    actual_memory_clues="$(jq -c '.diagnostics.memory_clues // []' "$tmp_out")"
    if [[ "$actual_memory_clues" != "$expected_memory_clues" ]]; then
      echo "FAIL [$id] memory_clues mismatch expected=$expected_memory_clues actual=$actual_memory_clues"
      rm -f "$tmp_out"
      fails=$((fails + 1))
      continue
    fi
  fi

  expected_route_applied="$(jq -r 'if .expected_output.diagnostics.route_applied == null then "" else (.expected_output.diagnostics.route_applied | tostring) end' "$fixture")"
  if [[ -n "$expected_route_applied" ]]; then
    actual_route_applied="$(jq -r '.diagnostics.route_applied | tostring' "$tmp_out")"
    if [[ "$actual_route_applied" != "$expected_route_applied" ]]; then
      echo "FAIL [$id] route_applied mismatch expected=$expected_route_applied actual=$actual_route_applied"
      rm -f "$tmp_out"
      fails=$((fails + 1))
      continue
    fi
  fi

  min_candidates="$(jq -r '(.expected_output.candidates | length) // 0' "$fixture")"
  actual_candidates="$(jq -r '(.candidates | length) // 0' "$tmp_out")"
  if (( actual_candidates < min_candidates )); then
    echo "FAIL [$id] expected at least $min_candidates candidates got $actual_candidates"
    rm -f "$tmp_out"
    fails=$((fails + 1))
    continue
  fi

  min_citations="$(jq -r '(.expected_output.citations | length) // 0' "$fixture")"
  actual_citations="$(jq -r '(.citations | length) // 0' "$tmp_out")"
  if (( actual_citations < min_citations )); then
    echo "FAIL [$id] expected at least $min_citations citations got $actual_citations"
    rm -f "$tmp_out"
    fails=$((fails + 1))
    continue
  fi

  if ! jq -e 'has("run") and has("status") and has("candidates") and has("citations") and has("evidence") and has("diagnostics")' "$tmp_out" >/dev/null; then
    echo "FAIL [$id] output missing required top-level fields"
    rm -f "$tmp_out"
    fails=$((fails + 1))
    continue
  fi

  echo "PASS [$id] (exit=$exit_code, status=$actual_status)"
  rm -f "$tmp_out"
  passes=$((passes + 1))
done

echo "Fixture summary: pass=$passes fail=$fails"
if (( fails > 0 )); then
  exit 1
fi
