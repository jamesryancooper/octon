#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
COVERAGE="$ROOT_DIR/.octon/framework/engine/runtime/spec/authorization-boundary-coverage.yml"

grep -Fq 'stale route-bundle denial' "$COVERAGE"
grep -Fq 'missing publication receipt denial' "$COVERAGE"
grep -Fq 'unadmitted pack denial' "$COVERAGE"
grep -Fq 'quarantined extension denial' "$COVERAGE"
grep -Fq 'runtime-effective direct-read denial' "$COVERAGE"
