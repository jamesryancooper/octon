#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/orchestration-runtime-common.sh"
orchestration_runtime_init "${BASH_SOURCE[0]}"
require_tools jq

ensure_dir "$QUEUE_DIR/pending"
ensure_dir "$QUEUE_DIR/claimed"
ensure_dir "$QUEUE_DIR/retry"
ensure_dir "$QUEUE_DIR/dead-letter"
ensure_dir "$QUEUE_DIR/receipts"

usage() {
  cat <<'EOF'
Usage:
  manage-queue.sh enqueue --queue-item-id <id> --target-automation-id <id> --summary <text> [options]
  manage-queue.sh claim --claimed-by <id> --lease-seconds <n>
  manage-queue.sh ack --queue-item-id <id> --claim-token <token>
  manage-queue.sh expire [--retry-delay-seconds <n>]
  manage-queue.sh dead-letter --queue-item-id <id> --reason <text>
EOF
}

queue_item_path_by_id() {
  local queue_item_id="$1"
  find "$QUEUE_DIR/pending" "$QUEUE_DIR/claimed" "$QUEUE_DIR/retry" "$QUEUE_DIR/dead-letter" -type f -name "${queue_item_id}.json" | head -n1
}

enqueue_item() {
  local queue_item_id="$1"
  local target_automation_id="$2"
  local summary="$3"
  local priority="$4"
  local available_at="$5"
  local max_attempts="$6"
  local event_id="$7"
  local watcher_id="$8"
  local payload_ref="$9"
  local enqueued_at
  enqueued_at="$(now_utc)"
  [[ ! -e "$QUEUE_DIR/pending/$queue_item_id.json" ]] || { echo "queue item already exists: $queue_item_id" >&2; exit 1; }
  jq -n \
    --arg queue_item_id "$queue_item_id" \
    --arg target_automation_id "$target_automation_id" \
    --arg summary "$summary" \
    --argjson priority "$priority" \
    --arg available_at "$available_at" \
    --argjson max_attempts "$max_attempts" \
    --arg enqueued_at "$enqueued_at" \
    --arg event_id "$event_id" \
    --arg watcher_id "$watcher_id" \
    --arg payload_ref "$payload_ref" '
    {
      queue_item_id: $queue_item_id,
      target_automation_id: $target_automation_id,
      status: "pending",
      priority: $priority,
      available_at: $available_at,
      attempt_count: 0,
      max_attempts: $max_attempts,
      summary: $summary,
      enqueued_at: $enqueued_at
    }
    + (if $event_id != "" then {event_id:$event_id} else {} end)
    + (if $watcher_id != "" then {watcher_id:$watcher_id} else {} end)
    + (if $payload_ref != "" then {payload_ref:$payload_ref} else {} end)
  ' > "$QUEUE_DIR/pending/$queue_item_id.json"
  echo "$QUEUE_DIR/pending/$queue_item_id.json"
}

claim_item_impl() {
  local claimed_by="$1"
  local lease_seconds="$2"
  local now="$3"
  local best_line=""
  local lane file priority_key available_at enqueued_at queue_item_id

  while IFS= read -r file; do
    [[ -f "$file" ]] || continue
    available_at="$(jq -r '.available_at // ""' "$file")"
    [[ -n "$available_at" && ( "$available_at" < "$now" || "$available_at" == "$now" ) ]] || continue
    queue_item_id="$(jq -r '.queue_item_id' "$file")"
    priority_key="$(jq -r 'if (.priority|type) == "number" then 1000000000 - .priority else 1000000000 end' "$file")"
    enqueued_at="$(jq -r '.enqueued_at // ""' "$file")"
    lane="$(basename "$(dirname "$file")")"
    printf '%s|%s|%s|%s|%s|%s\n' "$priority_key" "$available_at" "$enqueued_at" "$queue_item_id" "$lane" "$file"
  done < <(find "$QUEUE_DIR/pending" "$QUEUE_DIR/retry" -type f -name '*.json' | sort) | sort | while IFS= read -r line; do
    best_line="$line"
    echo "$best_line"
    break
  done | {
    IFS= read -r best_line || true
    if [[ -z "$best_line" ]]; then
      echo "no eligible queue item" >&2
      return 1
    fi
    IFS='|' read -r _priority_key _available_at _enqueued_at queue_item_id lane file <<<"$best_line"
    claim_token="claim-${claimed_by}-$(date -u +%Y%m%dT%H%M%SZ)"
    claim_deadline="$(next_expiry "$lease_seconds")"
    jq \
      --arg claimed_by "$claimed_by" \
      --arg now "$now" \
      --arg claim_deadline "$claim_deadline" \
      --arg claim_token "$claim_token" '
      .status = "claimed"
      | .claimed_by = $claimed_by
      | .claimed_at = $now
      | .claim_deadline = $claim_deadline
      | .claim_token = $claim_token
    ' "$file" > "$file.tmp"
    mv "$file.tmp" "$QUEUE_DIR/claimed/$queue_item_id.json"
    rm -f "$file"
    jq -n --arg queue_item_id "$queue_item_id" --arg claim_token "$claim_token" --arg claim_deadline "$claim_deadline" '{queue_item_id:$queue_item_id,claim_token:$claim_token,claim_deadline:$claim_deadline}'
  }
}

ack_item() {
  local queue_item_id="$1"
  local claim_token="$2"
  local file="$QUEUE_DIR/claimed/$queue_item_id.json"
  local handled_at receipt_path

  [[ -f "$file" ]] || { echo "claimed queue item not found: $queue_item_id" >&2; exit 1; }
  handled_at="$(now_utc)"
  receipt_path="$QUEUE_DIR/receipts/${queue_item_id}-ack-${handled_at//[:]/}.json"
  if [[ "$(jq -r '.claim_token // ""' "$file")" != "$claim_token" ]]; then
    jq -n --arg queue_item_id "$queue_item_id" --arg handled_at "$handled_at" \
      '{queue_item_id:$queue_item_id,action:"ack",status:"rejected",handled_at:$handled_at,reason:"claim-token-mismatch"}' \
      > "$receipt_path"
    echo "claim token mismatch for $queue_item_id" >&2
    exit 1
  fi

  jq -n \
    --arg queue_item_id "$queue_item_id" \
    --arg handled_at "$handled_at" \
    '{queue_item_id:$queue_item_id,action:"ack",status:"accepted",handled_at:$handled_at}' \
    > "$receipt_path"
  rm -f "$file"
  echo "$receipt_path"
}

expire_items() {
  local retry_delay_seconds="${1:-0}"
  local now next_available_at
  now="$(now_utc)"
  next_available_at="$(next_expiry "$retry_delay_seconds")"
  while IFS= read -r file; do
    [[ -f "$file" ]] || continue
    local deadline queue_item_id attempt_count max_attempts target_dir
    deadline="$(jq -r '.claim_deadline // ""' "$file")"
    [[ -n "$deadline" && "$deadline" < "$now" ]] || continue
    queue_item_id="$(jq -r '.queue_item_id' "$file")"
    attempt_count="$(jq -r '.attempt_count // 0' "$file")"
    max_attempts="$(jq -r '.max_attempts // 1' "$file")"
    if (( attempt_count + 1 >= max_attempts )); then
      target_dir="$QUEUE_DIR/dead-letter"
      new_status="dead_letter"
    else
      target_dir="$QUEUE_DIR/retry"
      new_status="retry"
    fi
    jq \
      --arg now "$now" \
      --arg next_available_at "$next_available_at" \
      --arg new_status "$new_status" '
      .status = $new_status
      | .attempt_count = (.attempt_count + 1)
      | .available_at = $next_available_at
      | .last_error = "claim expired"
      | del(.claimed_by, .claimed_at, .claim_deadline, .claim_token)
    ' "$file" > "$file.tmp"
    mv "$file.tmp" "$target_dir/$queue_item_id.json"
    rm -f "$file"
  done < <(find "$QUEUE_DIR/claimed" -type f -name '*.json' | sort)
}

dead_letter_item() {
  local queue_item_id="$1"
  local reason="$2"
  local file
  file="$(queue_item_path_by_id "$queue_item_id")"
  [[ -n "$file" ]] || { echo "queue item not found: $queue_item_id" >&2; exit 1; }
  jq \
    --arg reason "$reason" '
    .status = "dead_letter"
    | .last_error = $reason
    | del(.claimed_by, .claimed_at, .claim_deadline, .claim_token)
  ' "$file" > "$file.tmp"
  mv "$file.tmp" "$QUEUE_DIR/dead-letter/$queue_item_id.json"
  rm -f "$file"
  echo "$QUEUE_DIR/dead-letter/$queue_item_id.json"
}

cmd="${1:-}"
shift || true

case "$cmd" in
  enqueue)
    queue_item_id=""
    target_automation_id=""
    summary=""
    priority="0"
    available_at="$(now_utc)"
    max_attempts="3"
    event_id=""
    watcher_id=""
    payload_ref=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --queue-item-id) queue_item_id="$2"; shift 2 ;;
        --target-automation-id) target_automation_id="$2"; shift 2 ;;
        --summary) summary="$2"; shift 2 ;;
        --priority) priority="$2"; shift 2 ;;
        --available-at) available_at="$2"; shift 2 ;;
        --max-attempts) max_attempts="$2"; shift 2 ;;
        --event-id) event_id="$2"; shift 2 ;;
        --watcher-id) watcher_id="$2"; shift 2 ;;
        --payload-ref) payload_ref="$2"; shift 2 ;;
        *) echo "unknown argument: $1" >&2; exit 1 ;;
      esac
    done
    [[ -n "$queue_item_id" && -n "$target_automation_id" && -n "$summary" ]] || { usage; exit 1; }
    enqueue_item "$queue_item_id" "$target_automation_id" "$summary" "$priority" "$available_at" "$max_attempts" "$event_id" "$watcher_id" "$payload_ref"
    ;;
  claim)
    claimed_by=""
    lease_seconds=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --claimed-by) claimed_by="$2"; shift 2 ;;
        --lease-seconds) lease_seconds="$2"; shift 2 ;;
        *) echo "unknown argument: $1" >&2; exit 1 ;;
      esac
    done
    [[ -n "$claimed_by" && -n "$lease_seconds" ]] || { usage; exit 1; }
    with_path_lock "queue-claim" claim_item_impl "$claimed_by" "$lease_seconds" "$(now_utc)"
    ;;
  ack)
    queue_item_id=""
    claim_token=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --queue-item-id) queue_item_id="$2"; shift 2 ;;
        --claim-token) claim_token="$2"; shift 2 ;;
        *) echo "unknown argument: $1" >&2; exit 1 ;;
      esac
    done
    [[ -n "$queue_item_id" && -n "$claim_token" ]] || { usage; exit 1; }
    ack_item "$queue_item_id" "$claim_token"
    ;;
  expire)
    retry_delay_seconds="0"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --retry-delay-seconds) retry_delay_seconds="$2"; shift 2 ;;
        *) echo "unknown argument: $1" >&2; exit 1 ;;
      esac
    done
    with_path_lock "queue-expire" expire_items "$retry_delay_seconds"
    ;;
  dead-letter)
    queue_item_id=""
    reason=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --queue-item-id) queue_item_id="$2"; shift 2 ;;
        --reason) reason="$2"; shift 2 ;;
        *) echo "unknown argument: $1" >&2; exit 1 ;;
      esac
    done
    [[ -n "$queue_item_id" && -n "$reason" ]] || { usage; exit 1; }
    dead_letter_item "$queue_item_id" "$reason"
    ;;
  *)
    usage
    exit 1
    ;;
esac
