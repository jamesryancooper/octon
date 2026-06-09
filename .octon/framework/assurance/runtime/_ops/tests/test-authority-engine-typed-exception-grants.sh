#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OCTON_DIR="$(cd -- "$SCRIPT_DIR/../../../../.." && pwd)"

APPROVAL_GRANT_SCHEMA="$OCTON_DIR/framework/constitution/contracts/authority/approval-grant-v1.schema.json"
APPROVAL_REQUEST_SCHEMA="$OCTON_DIR/framework/constitution/contracts/authority/approval-request-v1.schema.json"
GRANT_BUNDLE_SCHEMA="$OCTON_DIR/framework/constitution/contracts/authority/grant-bundle-v2.schema.json"
DELEGATED_SCHEMA="$OCTON_DIR/framework/constitution/contracts/authority/delegated-governance-contract-v1.schema.json"

jq -e '."$defs".typed_exception_boundary.enum[] | select(. == "scope-expansion")' "$APPROVAL_GRANT_SCHEMA" >/dev/null
jq -e '.properties.grant_consumption_mode.enum[] | select(. == "delegated-execution")' "$APPROVAL_GRANT_SCHEMA" >/dev/null
jq -e '."$defs".typed_exception_boundary.enum[] | select(. == "policy-override")' "$APPROVAL_REQUEST_SCHEMA" >/dev/null
jq -e '.properties.approval_authority_source.not.enum[] | select(. == "generated-output")' "$APPROVAL_REQUEST_SCHEMA" >/dev/null
jq -e '.properties.approval_authority_source.not.enum[] | select(. == "read-model")' "$APPROVAL_REQUEST_SCHEMA" >/dev/null
jq -e '.properties.grant_consumption.properties.mints_fresh_authority.const == false' "$GRANT_BUNDLE_SCHEMA" >/dev/null
jq -e '.properties.grant_consumption.properties.mode.enum[] | select(. == "delegated-execution")' "$GRANT_BUNDLE_SCHEMA" >/dev/null
jq -e '.properties.approval_posture_derivation.properties.generic_importance_can_derive_approval.const == false' "$DELEGATED_SCHEMA" >/dev/null
jq -e '.properties.non_authority_surfaces.properties.generated_outputs_can_grant_authority.const == false' "$DELEGATED_SCHEMA" >/dev/null
jq -e '.properties.non_authority_surfaces.properties.read_models_can_grant_authority.const == false' "$DELEGATED_SCHEMA" >/dev/null

echo "[OK] authority-engine typed exception grant contracts expose required negative controls"
