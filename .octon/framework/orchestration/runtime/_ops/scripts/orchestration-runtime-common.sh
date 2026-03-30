#!/usr/bin/env bash

orchestration_runtime_init() {
  local caller_script="$1"
  ORCH_COMMON_SCRIPT_DIR="$(cd -- "$(dirname -- "$caller_script")" && pwd)"
  ORCH_RUNTIME_DIR="$(cd -- "$ORCH_COMMON_SCRIPT_DIR/../.." && pwd)"
  ORCHESTRATION_DIR="$(cd -- "$ORCH_RUNTIME_DIR/.." && pwd)"
  FRAMEWORK_DIR="$(cd -- "$ORCHESTRATION_DIR/.." && pwd)"
  TOOL_OCTON_DIR="$(cd -- "$FRAMEWORK_DIR/.." && pwd)"
  if [[ -n "${OCTON_DIR_OVERRIDE:-}" ]]; then
    OCTON_DIR="$OCTON_DIR_OVERRIDE"
    ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"
  else
    OCTON_DIR="$TOOL_OCTON_DIR"
    ROOT_DIR="$(cd -- "$OCTON_DIR/.." && pwd)"
  fi

  RUNTIME_DIR="$OCTON_DIR/framework/orchestration/runtime"
  DECISIONS_DIR="$OCTON_DIR/state/evidence/decisions/repo"
  RUN_EVIDENCE_ROOT="$OCTON_DIR/state/evidence/runs"
  RUN_CONTINUITY_ROOT="$OCTON_DIR/state/continuity/runs"
  CONTROL_EVIDENCE_ROOT="$OCTON_DIR/state/evidence/control/execution"
  EXTERNAL_EVIDENCE_INDEX_ROOT="$OCTON_DIR/state/evidence/external-index"
  RUN_CONTROL_ROOT="$OCTON_DIR/state/control/execution/runs"
  RUNTIME_RUNS_DIR="$RUNTIME_DIR/runs"
  QUEUE_DIR="$RUNTIME_DIR/queue"
  WORKFLOWS_DIR="$RUNTIME_DIR/workflows"
  MISSIONS_DIR="$OCTON_DIR/instance/orchestration/missions"
  COORDINATION_DIR="$RUNTIME_DIR/_coordination"
  LOCKS_DIR="$COORDINATION_DIR/locks"
  OCTON_KERNEL_RUNNER="${OCTON_KERNEL_RUNNER_OVERRIDE:-$OCTON_DIR/framework/engine/runtime/run}"
}

require_tools() {
  local tool
  for tool in "$@"; do
    if ! command -v "$tool" >/dev/null 2>&1; then
      echo "[ERROR] required tool '$tool' is missing" >&2
      exit 1
    fi
  done
}

ensure_dir() {
  mkdir -p "$1"
}

now_utc() {
  date -u '+%Y-%m-%dT%H:%M:%SZ'
}

orchestration_runtime_run_kernel() {
  local cwd="${OCTON_ROOT_DIR:-$ROOT_DIR}"
  (
    cd "$cwd"
    "$OCTON_KERNEL_RUNNER" "$@"
  )
}

next_expiry() {
  local seconds="$1"
  date -u -v+"${seconds}"S '+%Y-%m-%dT%H:%M:%SZ' 2>/dev/null || python3 - <<PY
from datetime import datetime, timedelta, timezone
print((datetime.now(timezone.utc)+timedelta(seconds=int("${seconds}"))).strftime("%Y-%m-%dT%H:%M:%SZ"))
PY
}

coordination_key_file() {
  local coordination_key="$1"
  local encoded
  encoded="$(printf '%s' "$coordination_key" | shasum -a 256 | awk '{print $1}')"
  printf '%s/%s.json' "$LOCKS_DIR" "$encoded"
}

with_path_lock() {
  local lock_name="$1"
  shift
  local lock_dir="$ROOT_DIR/.tmp-${lock_name}.lock"
  local waited=0

  while ! mkdir "$lock_dir" 2>/dev/null; do
    sleep 0.05
    waited=$((waited + 1))
    if [[ "$waited" -gt 200 ]]; then
      echo "[ERROR] timed out acquiring lock: $lock_name" >&2
      exit 1
    fi
  done

  trap 'rmdir "$lock_dir" 2>/dev/null || true' RETURN
  "$@"
  rmdir "$lock_dir" 2>/dev/null || true
  trap - RETURN
}
