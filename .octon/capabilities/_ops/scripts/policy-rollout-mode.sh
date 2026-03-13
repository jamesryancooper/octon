#!/usr/bin/env bash
# policy-rollout-mode.sh - Manage deny-by-default rollout mode and friction SLO checks.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CAPABILITIES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
POLICY_FILE="${OCTON_DDB_POLICY_FILE:-$CAPABILITIES_DIR/governance/policy/deny-by-default.v2.yml}"
STATE_FILE="$CAPABILITIES_DIR/_ops/state/rollout-mode.state"

usage() {
  cat <<'USAGE'
Usage:
  policy-rollout-mode.sh get
  policy-rollout-mode.sh set --mode <shadow|soft-enforce|hard-enforce>
  policy-rollout-mode.sh clear
  policy-rollout-mode.sh slo-report [--fail-on-breach]
USAGE
}

policy_field() {
  local path="$1"
  awk -v path="$path" '
    BEGIN {split(path, parts, ".")}
    {
      if (NR == 1) {
        depth=0
      }
    }
    /^[^[:space:]]/ {
      if ($1 ~ /:$/) {
        key=$1
        sub(/:$/, "", key)
        stack[1]=key
        depth=1
      }
    }
    /^[[:space:]]+/ {
      line=$0
      indent=match(line, /[^ ]/) - 1
      key=$1
      sub(/:$/, "", key)
      cur_depth=int(indent/2)+1
      stack[cur_depth]=key
      depth=cur_depth
      for (i=cur_depth+1;i<20;i++) delete stack[i]

      match_ok=1
      for (i=1;i<=length(parts);i++) {
        if (stack[i] != parts[i]) {
          match_ok=0
          break
        }
      }
      if (match_ok && key == parts[length(parts)]) {
        value=$0
        sub(/^[[:space:]]*[^:]+:[[:space:]]*/, "", value)
        gsub(/["'\'' ]/, "", value)
        print value
        exit
      }
    }
  ' "$POLICY_FILE"
}

policy_mode() {
  awk '/^mode:/ {gsub(/[" ]/, "", $2); print $2; exit}' "$POLICY_FILE"
}

effective_mode() {
  if [[ -f "$STATE_FILE" ]]; then
    local mode
    mode="$(head -n 1 "$STATE_FILE" | tr -d '[:space:]')"
    if [[ "$mode" == "shadow" || "$mode" == "soft-enforce" || "$mode" == "hard-enforce" ]]; then
      echo "$mode"
      return 0
    fi
  fi
  policy_mode
}

cmd_get() {
  effective_mode
}

cmd_set() {
  local mode=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --mode) mode="$2"; shift 2 ;;
      *) echo "Unknown option for set: $1" >&2; exit 1 ;;
    esac
  done

  [[ "$mode" == "shadow" || "$mode" == "soft-enforce" || "$mode" == "hard-enforce" ]] || {
    echo "Invalid mode: $mode" >&2
    exit 1
  }

  mkdir -p "$(dirname "$STATE_FILE")"
  printf '%s\n' "$mode" > "$STATE_FILE"
  echo "$mode"
}

cmd_clear() {
  rm -f "$STATE_FILE"
  effective_mode
}

cmd_slo_report() {
  local fail_on_breach=false
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --fail-on-breach) fail_on_breach=true; shift ;;
      *) echo "Unknown option for slo-report: $1" >&2; exit 1 ;;
    esac
  done

  if ! command -v jq >/dev/null 2>&1; then
    echo "jq is required for slo-report" >&2
    exit 1
  fi

  local log_path false_deny_max median_max auto_success_min
  log_path="$(awk '/^[[:space:]]*decision_log_path:/ {line=$0; sub(/^[[:space:]]*decision_log_path:[[:space:]]*/, "", line); gsub(/["'\'' ]/, "", line); print line; exit}' "$POLICY_FILE")"
  false_deny_max="$(awk '/^[[:space:]]*false_deny_rate_max:/ {print $2; exit}' "$POLICY_FILE")"
  median_max="$(awk '/^[[:space:]]*median_deny_to_unblock_seconds_max:/ {print $2; exit}' "$POLICY_FILE")"
  auto_success_min="$(awk '/^[[:space:]]*auto_remediation_success_rate_min:/ {print $2; exit}' "$POLICY_FILE")"

  [[ -n "$log_path" ]] || { echo "Missing observability.decision_log_path in policy" >&2; exit 1; }

  if [[ ! -f "$log_path" ]]; then
    echo "No decision log found at $log_path"
    [[ "$fail_on_breach" == true ]] && exit 1
    exit 0
  fi

  local metrics
  metrics="$(jq -s '
    def median(arr):
      if (arr|length) == 0 then 0
      else (arr|sort|.[((length/2)|floor)])
      end;
    {
      total: length,
      denies: (map(select(.allow == false)) | length),
      false_denies: (map(select(.false_deny == true)) | length),
      deny_to_unblock_samples: (map(select(.deny_to_unblock_seconds != null) | .deny_to_unblock_seconds)),
      auto_attempts: (map(select(.auto_remediation != null)) | length),
      auto_successes: (map(select(.auto_remediation.success == true)) | length)
    } |
    . + {
      false_deny_rate: (if .total == 0 then 0 else (.false_denies / .total) end),
      median_deny_to_unblock_seconds: median(.deny_to_unblock_samples),
      auto_remediation_success_rate: (if .auto_attempts == 0 then 1 else (.auto_successes / .auto_attempts) end)
    }
  ' "$log_path")"

  echo "$metrics" | jq -c .

  local false_deny_rate median_seconds auto_success_rate
  false_deny_rate="$(jq -r '.false_deny_rate' <<<"$metrics")"
  median_seconds="$(jq -r '.median_deny_to_unblock_seconds' <<<"$metrics")"
  auto_success_rate="$(jq -r '.auto_remediation_success_rate' <<<"$metrics")"

  local breach=false
  awk -v actual="$false_deny_rate" -v max="$false_deny_max" 'BEGIN {exit !(actual > max)}' && breach=true || true
  awk -v actual="$median_seconds" -v max="$median_max" 'BEGIN {exit !(actual > max)}' && breach=true || true
  awk -v actual="$auto_success_rate" -v min="$auto_success_min" 'BEGIN {exit !(actual < min)}' && breach=true || true

  if [[ "$breach" == true ]]; then
    echo "SLO breach detected" >&2
    [[ "$fail_on_breach" == true ]] && exit 1
  fi
}

main() {
  [[ -f "$POLICY_FILE" ]] || { echo "Missing policy file: $POLICY_FILE" >&2; exit 1; }

  local cmd="${1:-}"
  shift || true

  case "$cmd" in
    get|status) cmd_get "$@" ;;
    set) cmd_set "$@" ;;
    clear) cmd_clear "$@" ;;
    slo-report) cmd_slo_report "$@" ;;
    ""|-h|--help|help) usage ;;
    *) echo "Unknown command: $cmd" >&2; usage >&2; exit 1 ;;
  esac
}

main "$@"
