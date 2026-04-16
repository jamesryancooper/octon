#!/usr/bin/env bash
set -euo pipefail

TEST_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PACK_ROOT="$(cd -- "$TEST_DIR/../.." && pwd)"
REPO_ROOT="$(cd -- "$TEST_DIR/../../../../../../.." && pwd)"
EXPECTED_TOP_LEVEL=$'README.md\ncommands\ncontext\npack.yml\nskills\ntemplates\nvalidation'

actual_top_level="$(
  find "$PACK_ROOT" -mindepth 1 -maxdepth 1 ! -name '.DS_Store' -exec basename {} \; | LC_ALL=C sort
)"

[[ "$actual_top_level" == "$EXPECTED_TOP_LEVEL" ]]
[[ ! -d "$PACK_ROOT/prompts" ]]

bash "$REPO_ROOT/.octon/framework/assurance/runtime/_ops/scripts/validate-extension-pack-contract.sh" >/dev/null
