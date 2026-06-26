#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-program-delivery.sh"
