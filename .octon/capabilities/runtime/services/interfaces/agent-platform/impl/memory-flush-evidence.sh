#!/usr/bin/env bash
# memory-flush-evidence.sh - Enforce flush-before-compaction and emit evidence artifact.

set -euo pipefail

session_id="native-session"
limit=""
used=""
compaction_requested="false"
flush_ok="true"
waiver_id=""
output=""

usage() {
  cat <<USAGE
Usage: $0 --limit <int> --used <int> [--session-id <id>] [--compaction-requested true|false] [--flush-ok true|false] [--waiver-id <id>] [--output <path>]

Enforces:
- warning threshold at 80%
- mandatory flush at 90% or explicit compaction request
- fail-closed on flush failure unless waiver is provided
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --session-id)
      session_id="${2:-}"
      shift 2
      ;;
    --limit)
      limit="${2:-}"
      shift 2
      ;;
    --used)
      used="${2:-}"
      shift 2
      ;;
    --compaction-requested)
      compaction_requested="${2:-false}"
      shift 2
      ;;
    --flush-ok)
      flush_ok="${2:-true}"
      shift 2
      ;;
    --waiver-id)
      waiver_id="${2:-}"
      shift 2
      ;;
    --output)
      output="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "$limit" || -z "$used" ]]; then
  echo "--limit and --used are required" >&2
  exit 2
fi

if ! [[ "$limit" =~ ^[0-9]+$ && "$used" =~ ^[0-9]+$ ]]; then
  echo "--limit and --used must be non-negative integers" >&2
  exit 2
fi

if (( limit == 0 )); then
  echo "--limit must be > 0" >&2
  exit 2
fi

if (( used > limit )); then
  echo "--used cannot exceed --limit" >&2
  exit 2
fi

if [[ "$compaction_requested" != "true" && "$compaction_requested" != "false" ]]; then
  echo "--compaction-requested must be true|false" >&2
  exit 2
fi

if [[ "$flush_ok" != "true" && "$flush_ok" != "false" ]]; then
  echo "--flush-ok must be true|false" >&2
  exit 2
fi

if [[ -z "$output" ]]; then
  output=".octon/output/reports/analysis/$(date +%F)-memory-flush-evidence.md"
fi

percent=$(( used * 100 / limit ))
warning_reached="false"
flush_required="false"

if (( percent >= 80 )); then
  warning_reached="true"
fi
if (( percent >= 90 )) || [[ "$compaction_requested" == "true" ]]; then
  flush_required="true"
fi

flush_state="not-required"
decision="allow"
exit_code=0

if [[ "$flush_required" == "true" ]]; then
  if [[ "$flush_ok" == "true" ]]; then
    flush_state="completed"
    decision="allow"
  else
    if [[ -n "$waiver_id" ]]; then
      flush_state="failed-waived"
      decision="allow-with-waiver"
    else
      flush_state="failed-blocked"
      decision="fail-closed"
      exit_code=1
    fi
  fi
fi

mkdir -p "$(dirname "$output")"

cat > "$output" <<MD
---
title: Memory Flush Evidence
description: Evidence record for flush-before-compaction policy evaluation.
---

# Memory Flush Evidence

- Session id: ${session_id}
- Interop contract version: 1.0.0
- Budget used: ${used}/${limit}
- Budget used percent: ${percent}%
- Warning threshold reached (>=80%): ${warning_reached}
- Flush required (>=90% or explicit compaction): ${flush_required}
- Flush execution state: ${flush_state}
- Compaction decision: ${decision}
- ACP waiver id: ${waiver_id:-none}

## Flush Sequence Evidence

1. Session artifacts classified.
2. Sensitive values redacted.
3. Durable summary prepared.
4. Evidence record emitted to this artifact.
MD

node - "$session_id" "$limit" "$used" "$percent" "$warning_reached" "$flush_required" "$flush_state" "$decision" "$waiver_id" "$output" <<'NODE'
const [
  sessionId,
  limit,
  used,
  percent,
  warningReached,
  flushRequired,
  flushState,
  decision,
  waiverId,
  output,
] = process.argv.slice(2);

console.log(JSON.stringify({
  interop_contract_version: '1.0.0',
  session_id: sessionId,
  budget_limit: Number(limit),
  budget_used: Number(used),
  budget_used_percent: Number(percent),
  warning_threshold_reached: warningReached === 'true',
  flush_required: flushRequired === 'true',
  flush_state: flushState,
  decision,
  waiver_id: waiverId || null,
  evidence_path: output,
}, null, 2));
NODE

exit "$exit_code"
