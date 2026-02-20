#!/usr/bin/env bash
# run-harmony-policy.sh - Resolve and execute the shared harmony-policy CLI.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CAPABILITIES_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
REPO_ROOT="$(cd "$CAPABILITIES_DIR/../.." && pwd)"
RUNTIME_CRATES_DIR="$REPO_ROOT/.harmony/runtime/crates"
DEFAULT_BIN="$RUNTIME_CRATES_DIR/../_ops/state/build/runtime-crates-target/debug/harmony-policy"
ROLLOUT_STATE_FILE="$CAPABILITIES_DIR/_ops/state/rollout-mode.state"
DEFAULT_POLICY="$CAPABILITIES_DIR/_ops/policy/deny-by-default.v2.yml"
RECEIPT_WRITER="$CAPABILITIES_DIR/_ops/scripts/policy-receipt-write.sh"

binary_is_stale() {
  local bin="$1"
  if [[ ! -x "$bin" ]]; then
    return 0
  fi

  local src_root="$RUNTIME_CRATES_DIR/policy_engine"
  if find \
    "$src_root/src" \
    "$src_root/tests" \
    "$src_root/Cargo.toml" \
    "$RUNTIME_CRATES_DIR/Cargo.toml" \
    -type f -newer "$bin" -print -quit 2>/dev/null | grep -q .; then
    return 0
  fi

  return 1
}

ensure_harmony_policy_bin() {
  local candidate="${HARMONY_POLICY_BIN:-$DEFAULT_BIN}"

  if [[ -x "$candidate" ]] && ! binary_is_stale "$candidate"; then
    echo "$candidate"
    return 0
  fi

  if [[ ! -d "$RUNTIME_CRATES_DIR" ]]; then
    echo "Missing runtime crates directory: $RUNTIME_CRATES_DIR" >&2
    return 1
  fi

  (
    cd "$RUNTIME_CRATES_DIR"
    cargo build -q -p policy_engine --bin harmony-policy
  )

  if [[ -x "$candidate" ]]; then
    echo "$candidate"
    return 0
  fi

  if [[ -x "$DEFAULT_BIN" ]]; then
    echo "$DEFAULT_BIN"
    return 0
  fi

  echo "Unable to locate built harmony-policy binary" >&2
  return 1
}

run_acp_enforce() {
  local bin="$1"
  shift || true

  local emit_receipt="false"
  local emit_digest="false"
  local run_id_override=""
  local policy_path="$DEFAULT_POLICY"
  local request_path=""
  local request_arg_index=-1
  local show_help="false"
  local -a passthrough=()
  local -a input_args=("$@")

  local idx=0
  while (( idx < ${#input_args[@]} )); do
    local token="${input_args[$idx]}"
    case "$token" in
      --emit-receipt)
        emit_receipt="true"
        ;;
      --digest)
        emit_digest="true"
        ;;
      -h|--help)
        show_help="true"
        passthrough+=("$token")
        ;;
      --run-id)
        idx=$((idx + 1))
        if (( idx >= ${#input_args[@]} )); then
          echo "--run-id requires a value" >&2
          return 2
        fi
        run_id_override="${input_args[$idx]}"
        ;;
      --policy)
        idx=$((idx + 1))
        if (( idx >= ${#input_args[@]} )); then
          echo "--policy requires a value" >&2
          return 2
        fi
        policy_path="${input_args[$idx]}"
        passthrough+=("$token" "$policy_path")
        ;;
      --request)
        idx=$((idx + 1))
        if (( idx >= ${#input_args[@]} )); then
          echo "--request requires a value" >&2
          return 2
        fi
        request_path="${input_args[$idx]}"
        passthrough+=("$token" "$request_path")
        request_arg_index=$((${#passthrough[@]} - 1))
        ;;
      *)
        passthrough+=("$token")
        ;;
    esac
    idx=$((idx + 1))
  done

  if [[ "$show_help" == "true" ]]; then
    cat <<'USAGE'
run-harmony-policy.sh wrapper options for `acp-enforce`:
  --emit-receipt   Emit ACP receipt/digest artifacts via policy-receipt-write.sh.
  --run-id <id>    Override request.run_id before evaluation (requires --request).
  --digest         Print rendered digest to stderr after receipt emission (requires --emit-receipt).
USAGE
    "$bin" acp-enforce --help
    return 0
  fi

  if [[ "$emit_receipt" != "true" ]]; then
    if [[ -n "$run_id_override" || "$emit_digest" == "true" ]]; then
      echo "--run-id/--digest require --emit-receipt" >&2
      return 2
    fi
  fi

  local tmp_request=""
  local effective_request_path="$request_path"
  if [[ -n "$run_id_override" ]]; then
    if [[ -z "$request_path" || "$request_arg_index" -lt 0 ]]; then
      echo "--run-id requires --request for acp-enforce" >&2
      return 2
    fi
    if ! command -v jq >/dev/null 2>&1; then
      echo "jq is required for --run-id request override" >&2
      return 2
    fi
    tmp_request="$(mktemp "${TMPDIR:-/tmp}/acp-enforce-request.XXXXXX.json")"
    if ! jq --arg run_id "$run_id_override" '.run_id = $run_id' "$request_path" > "$tmp_request"; then
      rm -f "$tmp_request"
      echo "failed to apply run_id override to request: $request_path" >&2
      return 2
    fi
    passthrough[$request_arg_index]="$tmp_request"
    effective_request_path="$tmp_request"
  fi

  local decision_output rc
  set +e
  decision_output="$("$bin" acp-enforce "${passthrough[@]}")"
  rc=$?
  set -e
  printf '%s\n' "$decision_output"

  local tmp_decision="" receipt_output="" receipt_rc=0 receipt_validate_rc=0 receipt_validate_output="" receipt_validate_path=""
  if [[ "$emit_receipt" == "true" ]]; then
    if [[ -z "$effective_request_path" ]]; then
      echo "--emit-receipt requires --request <path>" >&2
      rm -f "$tmp_request"
      [[ "$rc" -eq 0 ]] && return 13
      return "$rc"
    fi
    if [[ ! -x "$RECEIPT_WRITER" ]]; then
      echo "receipt writer unavailable: $RECEIPT_WRITER" >&2
      rm -f "$tmp_request"
      [[ "$rc" -eq 0 ]] && return 13
      return "$rc"
    fi
    if ! command -v jq >/dev/null 2>&1; then
      echo "jq is required for --emit-receipt mode" >&2
      rm -f "$tmp_request"
      [[ "$rc" -eq 0 ]] && return 13
      return "$rc"
    fi
    if ! jq -e . >/dev/null 2>&1 <<<"$decision_output"; then
      echo "acp-enforce did not return JSON; cannot emit receipt" >&2
      rm -f "$tmp_request"
      [[ "$rc" -eq 0 ]] && return 13
      return "$rc"
    fi

    tmp_decision="$(mktemp "${TMPDIR:-/tmp}/acp-enforce-decision.XXXXXX.json")"
    printf '%s\n' "$decision_output" > "$tmp_decision"

    set +e
    receipt_output="$("$RECEIPT_WRITER" --policy "$policy_path" --request "$effective_request_path" --decision "$tmp_decision" 2>&1)"
    receipt_rc=$?
    set -e
    if [[ "$receipt_rc" -ne 0 ]]; then
      echo "failed to emit ACP receipt: $receipt_output" >&2
      rm -f "$tmp_request" "$tmp_decision"
      [[ "$rc" -eq 0 ]] && return 13
      return "$rc"
    fi

    receipt_validate_path="$(jq -r '.latest_receipt // .receipt // empty' <<<"$receipt_output" 2>/dev/null || true)"
    if [[ -z "$receipt_validate_path" || ! -f "$receipt_validate_path" ]]; then
      echo "receipt writer did not return a valid receipt path for validation" >&2
      rm -f "$tmp_request" "$tmp_decision"
      [[ "$rc" -eq 0 ]] && return 13
      return "$rc"
    fi
    set +e
    receipt_validate_output="$("$bin" receipt-validate --policy "$policy_path" --receipt "$receipt_validate_path" 2>&1)"
    receipt_validate_rc=$?
    set -e
    if [[ "$receipt_validate_rc" -ne 0 ]]; then
      echo "failed ACP receipt validation: $receipt_validate_output" >&2
      rm -f "$tmp_request" "$tmp_decision"
      [[ "$rc" -eq 0 ]] && return 13
      return "$rc"
    fi

    if [[ "$emit_digest" == "true" ]]; then
      local digest_path
      digest_path="$(jq -r '.latest_digest // .digest // empty' <<<"$receipt_output" 2>/dev/null || true)"
      if [[ -n "$digest_path" && -f "$digest_path" ]]; then
        echo "[acp-enforce] digest: $digest_path" >&2
        cat "$digest_path" >&2
      else
        echo "[acp-enforce] digest unavailable from receipt writer output" >&2
      fi
    fi
  fi

  rm -f "$tmp_request" "$tmp_decision"
  return "$rc"
}

main() {
  if [[ "${1:-}" == "--print-bin" ]]; then
    ensure_harmony_policy_bin
    return 0
  fi

  local bin
  bin="$(ensure_harmony_policy_bin)"
  if [[ -f "$ROLLOUT_STATE_FILE" ]]; then
    local mode
    mode="$(head -n 1 "$ROLLOUT_STATE_FILE" | tr -d '[:space:]')"
    if [[ "$mode" == "shadow" || "$mode" == "soft-enforce" || "$mode" == "hard-enforce" ]]; then
      export HARMONY_POLICY_MODE_OVERRIDE="$mode"
    fi
  fi

  local command="${1:-}"
  if [[ "$command" == "acp-enforce" ]]; then
    shift
    run_acp_enforce "$bin" "$@"
    return $?
  fi

  "$bin" "$@"
}

main "$@"
