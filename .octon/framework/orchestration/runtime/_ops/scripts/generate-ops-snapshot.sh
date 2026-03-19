#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/orchestration-runtime-common.sh"
orchestration_runtime_init "${BASH_SOURCE[0]}"

report_path="$OCTON_DIR/state/evidence/validation/analysis/$(date -u +%F)-orchestration-ops-snapshot.md"
orchestration_runtime_run_kernel orchestration summary --surface all --format markdown --output-report "$report_path" >/dev/null
printf '%s\n' "$report_path"
