#!/usr/bin/env bash
set -euo pipefail
run_id="${1:-}"
[[ -n "$run_id" ]] || { echo "usage: generate-run-card.sh <run-id>" >&2; exit 2; }
[[ -f ".octon/state/evidence/disclosure/runs/$run_id/run-card.yml" ]]

