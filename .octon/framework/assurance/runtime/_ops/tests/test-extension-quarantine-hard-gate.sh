#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"
FIXTURE="$(mktemp -d)"
trap 'rm -rf "$FIXTURE"' EXIT

mkdir -p \
  "$FIXTURE/.octon/instance/governance" \
  "$FIXTURE/.octon/generated/effective/runtime" \
  "$FIXTURE/.octon/generated/effective/governance" \
  "$FIXTURE/.octon/generated/effective/capabilities" \
  "$FIXTURE/.octon/generated/effective/extensions" \
  "$FIXTURE/.octon/state/evidence/validation/publication/runtime" \
  "$FIXTURE/.octon/state/evidence/validation/publication/capabilities" \
  "$FIXTURE/.octon/state/evidence/validation/publication/extensions" \
  "$FIXTURE/.octon/state/control/extensions"

cp "$ROOT_DIR/.octon/octon.yml" "$FIXTURE/.octon/octon.yml"
cp "$ROOT_DIR/.octon/instance/governance/runtime-resolution.yml" "$FIXTURE/.octon/instance/governance/runtime-resolution.yml"
cp "$ROOT_DIR/.octon/instance/governance/support-targets.yml" "$FIXTURE/.octon/instance/governance/support-targets.yml"
cp "$ROOT_DIR/.octon/generated/effective/governance/support-target-matrix.yml" "$FIXTURE/.octon/generated/effective/governance/support-target-matrix.yml"
cp "$ROOT_DIR/.octon/generated/effective/capabilities/pack-routes.effective.yml" "$FIXTURE/.octon/generated/effective/capabilities/pack-routes.effective.yml"
cp "$ROOT_DIR/.octon/generated/effective/capabilities/pack-routes.lock.yml" "$FIXTURE/.octon/generated/effective/capabilities/pack-routes.lock.yml"
cp "$ROOT_DIR/.octon/generated/effective/extensions/catalog.effective.yml" "$FIXTURE/.octon/generated/effective/extensions/catalog.effective.yml"
cp "$ROOT_DIR/.octon/generated/effective/extensions/generation.lock.yml" "$FIXTURE/.octon/generated/effective/extensions/generation.lock.yml"
cp "$ROOT_DIR/.octon/state/control/extensions/active.yml" "$FIXTURE/.octon/state/control/extensions/active.yml"
cp "$ROOT_DIR/.octon/generated/effective/runtime/route-bundle.yml" "$FIXTURE/.octon/generated/effective/runtime/route-bundle.yml"
cp "$ROOT_DIR/.octon/generated/effective/runtime/route-bundle.lock.yml" "$FIXTURE/.octon/generated/effective/runtime/route-bundle.lock.yml"

cp "$ROOT_DIR/$(yq -r '.publication_receipt_path' "$ROOT_DIR/.octon/generated/effective/runtime/route-bundle.lock.yml")" "$FIXTURE/$(yq -r '.publication_receipt_path' "$ROOT_DIR/.octon/generated/effective/runtime/route-bundle.lock.yml")"
cp "$ROOT_DIR/$(yq -r '.publication_receipt_path' "$ROOT_DIR/.octon/generated/effective/capabilities/pack-routes.lock.yml")" "$FIXTURE/$(yq -r '.publication_receipt_path' "$ROOT_DIR/.octon/generated/effective/capabilities/pack-routes.lock.yml")"
cp "$ROOT_DIR/$(yq -r '.publication_receipt_path' "$ROOT_DIR/.octon/generated/effective/extensions/generation.lock.yml")" "$FIXTURE/$(yq -r '.publication_receipt_path' "$ROOT_DIR/.octon/generated/effective/extensions/generation.lock.yml")"

cat >"$FIXTURE/.octon/state/control/extensions/quarantine.yml" <<'EOF'
schema_version: "octon-extension-quarantine-state-v3"
updated_at: "2026-04-21T23:47:33Z"
records:
  - pack_id: "octon-concept-integration"
    source_id: "bundled-first-party"
    reason: "fixture"
EOF
yq -i '.extensions.quarantine_count = 1' "$FIXTURE/.octon/generated/effective/runtime/route-bundle.yml"

if OCTON_DIR_OVERRIDE="$FIXTURE/.octon" OCTON_ROOT_DIR="$FIXTURE" bash "$ROOT_DIR/.octon/framework/assurance/runtime/_ops/scripts/validate-runtime-effective-route-bundle.sh" >/dev/null 2>&1; then
  echo "expected runtime route bundle validator to fail with quarantined extension" >&2
  exit 1
fi
