#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/closure-packet-common.sh"
policy="$OCTON_DIR/instance/governance/policies/evaluator-independence.yml"
yq -e '.same-generator-and-acceptance-model_allowed == false' "$policy" >/dev/null
while IFS= read -r run_id; do
  yq -e '.proof_plane_refs.evaluator' "$(run_card_path "$run_id")" >/dev/null
done < <(representative_run_ids)

