#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OPS_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
RUNTIME_DIR="$(cd -- "$OPS_DIR/.." && pwd)"
ORCHESTRATION_DIR="$(cd -- "$RUNTIME_DIR/.." && pwd)"
OCTON_DIR="$(cd -- "$ORCHESTRATION_DIR/.." && pwd)"
REPO_ROOT="$(cd -- "$OCTON_DIR/.." && pwd)"

EMIT_SCRIPT=".octon/orchestration/runtime/_ops/scripts/emit-watcher-event.sh"
ROUTE_SCRIPT=".octon/orchestration/runtime/_ops/scripts/route-watcher-event.sh"
QUEUE_SCRIPT=".octon/orchestration/runtime/_ops/scripts/manage-queue.sh"

pass_count=0
fail_count=0
cleanup_paths=()

cleanup() {
  local path
  for path in "${cleanup_paths[@]}"; do
    [[ -n "$path" ]] && rm -rf "$path"
  done
}
trap cleanup EXIT

pass() {
  echo "PASS: $1"
  pass_count=$((pass_count + 1))
}

fail() {
  echo "FAIL: $1" >&2
  fail_count=$((fail_count + 1))
}

assert_success() {
  local name="$1"
  shift
  if "$@"; then
    pass "$name"
  else
    fail "$name"
  fi
}

create_fixture() {
  local fixture_root
  fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/watcher-queue.XXXXXX")"
  cleanup_paths+=("$fixture_root")

  mkdir -p "$fixture_root/.octon/orchestration/runtime"
  mkdir -p "$fixture_root/.octon/continuity/decisions"
  mkdir -p "$fixture_root/.octon/continuity/runs"

  cp -R "$REPO_ROOT/.octon/orchestration/runtime" "$fixture_root/.octon/orchestration/"
  cp "$REPO_ROOT/.octon/continuity/decisions/README.md" "$fixture_root/.octon/continuity/decisions/README.md"
  cp "$REPO_ROOT/.octon/continuity/decisions/retention.json" "$fixture_root/.octon/continuity/decisions/retention.json"
  cp "$REPO_ROOT/.octon/continuity/runs/README.md" "$fixture_root/.octon/continuity/runs/README.md"

  printf '%s\n' "$fixture_root"
}

case_fan_out_and_order() {
  local fixture_root envs event_file output
  fixture_root="$(create_fixture)"
  envs=("OCTON_DIR_OVERRIDE=$fixture_root/.octon" "OCTON_ROOT_DIR=$fixture_root")

  cp -R "$fixture_root/.octon/orchestration/runtime/automations/runtime-contract-drift-remediation" "$fixture_root/.octon/orchestration/runtime/automations/alpha-freshness-audit"
  cp -R "$fixture_root/.octon/orchestration/runtime/automations/runtime-contract-drift-remediation" "$fixture_root/.octon/orchestration/runtime/automations/zeta-freshness-audit"
  perl -0pi -e 's/runtime-contract-drift-remediation/alpha-freshness-audit/g' "$fixture_root/.octon/orchestration/runtime/automations/alpha-freshness-audit/automation.yml"
  perl -0pi -e 's/runtime-contract-drift-remediation/zeta-freshness-audit/g' "$fixture_root/.octon/orchestration/runtime/automations/zeta-freshness-audit/automation.yml"

  event_file="$fixture_root/event-fanout.json"
  env "${envs[@]}" bash "$REPO_ROOT/$EMIT_SCRIPT" \
    --watcher-id runtime-contract-drift-watcher \
    --rule-id workflow-contract-drift \
    --source-ref .octon/orchestration/runtime/workflows \
    --event-id evt-fanout-001 \
    --output-file "$event_file" >/dev/null
  jq 'del(.target_automation_id)' "$event_file" > "$event_file.tmp"
  mv "$event_file.tmp" "$event_file"

  output="$(env "${envs[@]}" bash "$REPO_ROOT/$ROUTE_SCRIPT" --event-file "$event_file")"
  jq -e '.[0].automation_id == "alpha-freshness-audit" and .[1].automation_id == "runtime-contract-drift-remediation" and .[2].automation_id == "zeta-freshness-audit"' <<<"$output" >/dev/null
}

case_target_hint_miss_blocks() {
  local fixture_root envs event_file output
  fixture_root="$(create_fixture)"
  envs=("OCTON_DIR_OVERRIDE=$fixture_root/.octon" "OCTON_ROOT_DIR=$fixture_root")
  event_file="$fixture_root/event-target-miss.json"
  env "${envs[@]}" bash "$REPO_ROOT/$EMIT_SCRIPT" \
    --watcher-id runtime-contract-drift-watcher \
    --rule-id workflow-contract-drift \
    --source-ref .octon/orchestration/runtime/workflows \
    --event-id evt-target-miss-001 \
    --target-automation-id nonexistent-automation \
    --output-file "$event_file" >/dev/null
  output="$(env "${envs[@]}" bash "$REPO_ROOT/$ROUTE_SCRIPT" --event-file "$event_file")"
  jq -e 'length == 0' <<<"$output" >/dev/null
}

case_dedupe_suppresses_second_route() {
  local fixture_root envs event_file first second
  fixture_root="$(create_fixture)"
  envs=("OCTON_DIR_OVERRIDE=$fixture_root/.octon" "OCTON_ROOT_DIR=$fixture_root")
  event_file="$fixture_root/event-dedupe.json"
  env "${envs[@]}" bash "$REPO_ROOT/$EMIT_SCRIPT" \
    --watcher-id runtime-contract-drift-watcher \
    --rule-id workflow-contract-drift \
    --source-ref .octon/orchestration/runtime/workflows \
    --event-id evt-dedupe-001 \
    --output-file "$event_file" >/dev/null
  first="$(env "${envs[@]}" bash "$REPO_ROOT/$ROUTE_SCRIPT" --event-file "$event_file")"
  second="$(env "${envs[@]}" bash "$REPO_ROOT/$ROUTE_SCRIPT" --event-file "$event_file")"
  jq -e 'length == 1' <<<"$first" >/dev/null
  jq -e 'length == 0' <<<"$second" >/dev/null
}

case_match_mode_any_and_glob() {
  local fixture_root envs event_file output
  fixture_root="$(create_fixture)"
  envs=("OCTON_DIR_OVERRIDE=$fixture_root/.octon" "OCTON_ROOT_DIR=$fixture_root")
  cat > "$fixture_root/.octon/orchestration/runtime/automations/runtime-contract-drift-remediation/trigger.yml" <<'EOF'
kind: "event"
event:
  watcher_ids:
    - "runtime-contract-drift-watcher"
  event_types:
    - "different-event"
  source_ref_globs:
    - ".octon/orchestration/runtime/**"
  match_mode: "any"
EOF
  event_file="$fixture_root/event-any.json"
  env "${envs[@]}" bash "$REPO_ROOT/$EMIT_SCRIPT" \
    --watcher-id runtime-contract-drift-watcher \
    --rule-id workflow-contract-drift \
    --source-ref .octon/orchestration/runtime/workflows \
    --event-id evt-any-001 \
    --output-file "$event_file" >/dev/null
  output="$(env "${envs[@]}" bash "$REPO_ROOT/$ROUTE_SCRIPT" --event-file "$event_file")"
  jq -e 'length == 1 and .[0].automation_id == "runtime-contract-drift-remediation"' <<<"$output" >/dev/null
}

case_stale_ack_and_dead_letter() {
  local fixture_root envs claim_output good_token
  fixture_root="$(create_fixture)"
  envs=("OCTON_DIR_OVERRIDE=$fixture_root/.octon" "OCTON_ROOT_DIR=$fixture_root")
  env "${envs[@]}" bash "$REPO_ROOT/$QUEUE_SCRIPT" enqueue --queue-item-id q-retry-001 --target-automation-id auto-test --summary "retry item" --max-attempts 1 >/dev/null
  claim_output="$(env "${envs[@]}" bash "$REPO_ROOT/$QUEUE_SCRIPT" claim --claimed-by auto-test --lease-seconds 300)"
  good_token="$(jq -r '.claim_token' <<<"$claim_output")"
  if env "${envs[@]}" bash "$REPO_ROOT/$QUEUE_SCRIPT" ack --queue-item-id q-retry-001 --claim-token wrong-token >/dev/null 2>&1; then
    return 1
  fi
  find "$fixture_root/.octon/orchestration/runtime/queue/receipts" -type f -name 'q-retry-001-ack-*.json' | grep -q .

  jq '.claim_deadline = "2000-01-01T00:00:00Z"' "$fixture_root/.octon/orchestration/runtime/queue/claimed/q-retry-001.json" > "$fixture_root/.octon/orchestration/runtime/queue/claimed/q-retry-001.json.tmp"
  mv "$fixture_root/.octon/orchestration/runtime/queue/claimed/q-retry-001.json.tmp" "$fixture_root/.octon/orchestration/runtime/queue/claimed/q-retry-001.json"
  env "${envs[@]}" bash "$REPO_ROOT/$QUEUE_SCRIPT" expire >/dev/null
  [[ -f "$fixture_root/.octon/orchestration/runtime/queue/dead-letter/q-retry-001.json" ]]
  [[ -n "$good_token" ]]
}

assert_success "watcher routing fans out in lexical automation order" case_fan_out_and_order
assert_success "target hint miss blocks queue creation" case_target_hint_miss_blocks
assert_success "dedupe suppresses second routed event" case_dedupe_suppresses_second_route
assert_success "match_mode any allows source-ref glob match" case_match_mode_any_and_glob
assert_success "stale ack is rejected and expiry can dead-letter" case_stale_ack_and_dead_letter

if (( fail_count > 0 )); then
  echo "FAILURES: $fail_count" >&2
  exit 1
fi

echo "PASS: $pass_count"
