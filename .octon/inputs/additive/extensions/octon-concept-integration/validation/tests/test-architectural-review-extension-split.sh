#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../../.." && pwd)"

bash "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-extension-split.sh"
