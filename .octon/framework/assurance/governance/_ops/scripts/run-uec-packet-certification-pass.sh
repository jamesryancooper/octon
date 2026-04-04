#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../.." && pwd)"
OCTON_DIR="${OCTON_DIR_OVERRIDE:-$DEFAULT_OCTON_DIR}"
ROOT_DIR="${OCTON_ROOT_DIR:-$(cd -- "$OCTON_DIR/.." && pwd)}"

OUTPUT_DIR=""
INCLUDE_CLOSURE_VALIDATOR="false"

run_step() {
  local step_id="$1"
  local cmd="$2"
  local log_file="$OUTPUT_DIR/${step_id}.log"
  echo "== $step_id ==" | tee "$log_file"
  if (
    cd "$ROOT_DIR"
    bash -lc "$cmd"
  ) >>"$log_file" 2>&1; then
    echo "PASS" >"$OUTPUT_DIR/${step_id}.status"
  else
    echo "FAIL" >"$OUTPUT_DIR/${step_id}.status"
    cat "$log_file" >&2
    return 1
  fi
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --output-dir) OUTPUT_DIR="$2"; shift 2 ;;
      --include-closure-validator) INCLUDE_CLOSURE_VALIDATOR="true"; shift ;;
      *) echo "unknown argument: $1" >&2; exit 1 ;;
    esac
  done

  [[ -n "$OUTPUT_DIR" ]] || { echo "--output-dir is required" >&2; exit 1; }
  if [[ "$OUTPUT_DIR" != /* ]]; then
    OUTPUT_DIR="$ROOT_DIR/$OUTPUT_DIR"
  fi
  mkdir -p "$OUTPUT_DIR"

  local -a steps=(
    "01-normalize|bash .octon/framework/assurance/governance/_ops/scripts/normalize-uec-packet-certification-runs.sh"
    "02-support-claims|bash .octon/framework/assurance/runtime/_ops/scripts/validate-support-target-live-claims.sh"
    "03-adapters|bash .octon/framework/assurance/runtime/_ops/scripts/validate-phase5-adapter-support-target-hardening.sh"
    "04-runtime|bash .octon/framework/assurance/governance/_ops/scripts/validate-uec-packet-runtime-normalization.sh"
    "05-richness|bash .octon/framework/assurance/runtime/_ops/scripts/validate-unified-execution-richness.sh"
    "06-disclosure|bash .octon/framework/assurance/runtime/_ops/scripts/validate-assurance-disclosure-expansion.sh"
    "07-disclosure-roots|bash .octon/framework/assurance/runtime/_ops/scripts/validate-disclosure-live-roots.sh"
    "08-retirement|bash .octon/framework/assurance/runtime/_ops/scripts/validate-global-retirement-closure.sh"
  )

  if [[ "$INCLUDE_CLOSURE_VALIDATOR" == "true" ]]; then
    steps+=("09-closure|bash .octon/framework/assurance/governance/_ops/scripts/assert-unified-execution-closure.sh")
  fi

  local item step_id cmd
  for item in "${steps[@]}"; do
    step_id="${item%%|*}"
    cmd="${item#*|}"
    run_step "$step_id" "$cmd"
  done

  local pass_id
  pass_id="$(basename "$OUTPUT_DIR")"
  jq -n \
    --arg pass_id "$pass_id" \
    --arg generated_at "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
    --arg include_closure "$INCLUDE_CLOSURE_VALIDATOR" \
    '{
      schema_version: "uec-packet-certification-pass-summary-v1",
      pass_id: $pass_id,
      generated_at: $generated_at,
      include_closure_validator: ($include_closure == "true"),
      status: "pass"
    }' | yq -P -p=json '.' >"$OUTPUT_DIR/summary.yml"
}

main "$@"
