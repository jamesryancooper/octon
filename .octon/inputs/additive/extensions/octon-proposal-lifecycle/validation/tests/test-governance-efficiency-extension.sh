#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../../.." && pwd)"
CONTEXT="$ROOT_DIR/.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/governance-efficiency-evaluation.contract.yml"
COMMAND="$ROOT_DIR/.octon/inputs/additive/extensions/octon-proposal-lifecycle/commands/governance-efficiency-evaluate.md"
SKILL="$ROOT_DIR/.octon/inputs/additive/extensions/octon-proposal-lifecycle/skills/governance-efficiency-evaluation/SKILL.md"

[[ -f "$CONTEXT" ]] || { echo "[ERROR] context contract missing"; exit 1; }
[[ -f "$COMMAND" ]] || { echo "[ERROR] command surface missing"; exit 1; }
[[ -f "$SKILL" ]] || { echo "[ERROR] skill surface missing"; exit 1; }

for claim in review-authorization validation-gate closeout cleanup archive terminal-proof policy-mutation lifecycle-transition child-receipt-substitution; do
  yq -e ".forbidden_authority_claims[]? | select(. == \"$claim\")" "$CONTEXT" >/dev/null \
    || { echo "[ERROR] missing forbidden authority claim: $claim"; exit 1; }
done

rg -q "does not create a lifecycle gate" "$COMMAND" || { echo "[ERROR] command must stay optional"; exit 1; }
rg -q "cannot authorize review, validation, closeout, cleanup, archive" "$SKILL" || { echo "[ERROR] skill authority boundary missing"; exit 1; }

echo "test-governance-efficiency-extension: pass"
