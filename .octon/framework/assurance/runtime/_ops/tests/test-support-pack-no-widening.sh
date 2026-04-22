#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-support-pack-admission-alignment.sh" >/dev/null
grep -Fq 'claim_effect' "$ROOT_DIR/.octon/generated/effective/capabilities/pack-routes.effective.yml"
