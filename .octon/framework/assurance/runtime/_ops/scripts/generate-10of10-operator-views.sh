#!/usr/bin/env bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/closure-packet-common.sh"

require_yq

OUT_DIR="$OCTON_DIR/generated/cognition/projections/materialized"
RUNTIME_BUNDLE="$OCTON_DIR/generated/effective/runtime/route-bundle.yml"
PACK_ROUTES="$OCTON_DIR/generated/effective/capabilities/pack-routes.effective.yml"
EVIDENCE_ROOT="$OCTON_DIR/state/evidence/validation/architecture/10of10-target-transition/operator-views"
mkdir -p "$OUT_DIR" "$EVIDENCE_ROOT"

generated_at="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

cat >"$OUT_DIR/runtime-route-map.md" <<EOF
# Runtime Route Map

Generated at: \`$generated_at\`

Non-authority disclaimer: this map is derived from canonical authored authority, retained evidence, and freshness-gated generated/effective outputs. It does not mint authority.

Source refs:

- \`/.octon/framework/engine/runtime/spec/runtime-resolution-v1.md\`
- \`/.octon/instance/governance/runtime-resolution.yml\`
- \`/.octon/generated/effective/runtime/route-bundle.yml\`
- \`/.octon/generated/effective/runtime/route-bundle.lock.yml\`
- \`/.octon/state/evidence/validation/architecture/10of10-target-transition/publication/freshness.yml\`

Route bundle generation: \`$(yq -r '.generation_id // ""' "$RUNTIME_BUNDLE")\`

## Tuple Routes
EOF

while IFS=$'\t' read -r tuple_id claim_effect route; do
  [[ -n "$tuple_id" ]] || continue
  {
    echo "- \`$tuple_id\`: \`$claim_effect\`, route=\`$route\`"
  } >>"$OUT_DIR/runtime-route-map.md"
done < <(yq -r '.routes[]? | [.tuple_id, .claim_effect, .route] | @tsv' "$RUNTIME_BUNDLE")

cat >"$OUT_DIR/support-pack-route-map.md" <<EOF
# Support Pack Route Map

Generated at: \`$generated_at\`

Non-authority disclaimer: this derived read model traces support tuples, pack routes, and retained receipts. Canonical authority remains in \`framework/**\`, \`instance/**\`, \`state/**\`, and freshness-gated generated/effective outputs.

Source refs:

- \`/.octon/framework/engine/runtime/spec/runtime-resolution-v1.md\`
- \`/.octon/instance/governance/support-targets.yml\`
- \`/.octon/generated/effective/capabilities/pack-routes.effective.yml\`
- \`/.octon/generated/effective/capabilities/pack-routes.lock.yml\`
- \`/.octon/state/evidence/validation/architecture/10of10-target-transition/capabilities/pack-route-no-widening.yml\`

## Pack Routes
EOF

while IFS=$'\t' read -r pack_id status; do
  [[ -n "$pack_id" ]] || continue
  {
    echo "- \`$pack_id\`: status=\`$status\`"
    while IFS=$'\t' read -r tuple_id claim_effect route; do
      [[ -n "$tuple_id" ]] || continue
      echo "  - \`$tuple_id\`: \`$claim_effect\`, route=\`$route\`"
    done < <(yq -r ".packs[] | select(.pack_id == \"$pack_id\") | .tuple_routes[]? | [.tuple_id, .claim_effect, .route] | @tsv" "$PACK_ROUTES")
  } >>"$OUT_DIR/support-pack-route-map.md"
done < <(yq -r '.packs[]? | [.pack_id, .admission_status] | @tsv' "$PACK_ROUTES")

cat >"$EVIDENCE_ROOT/generation.yml" <<EOF
schema_version: "operator-read-model-publication-v1"
generated_at: "$generated_at"
view_contract_ref: ".octon/framework/engine/runtime/spec/operator-read-models-v1.md"
published_views:
  - view_kind: "runtime-route"
    projection_ref: ".octon/generated/cognition/projections/materialized/runtime-route-map.md"
    summary_ref: ".octon/generated/effective/runtime/route-bundle.yml"
  - view_kind: "support-pack-route"
    projection_ref: ".octon/generated/cognition/projections/materialized/support-pack-route-map.md"
    summary_ref: ".octon/generated/effective/capabilities/pack-routes.effective.yml"
  - view_kind: "architecture"
    projection_ref: ".octon/generated/cognition/projections/materialized/architecture-map.md"
    summary_ref: ".octon/state/evidence/validation/architecture/10of10-target-transition/manifest.yml"
EOF
