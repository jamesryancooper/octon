#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../../../../../.." && pwd)"

tests=(
  missing_token_record_fails_closed
  wrong_scope_effect_fails_closed
  single_use_effect_cannot_be_consumed_twice
  expired_effect_is_rejected
  forged_effect_digest_is_rejected
  wrong_effect_class_is_rejected
  wrong_run_binding_is_rejected
  wrong_route_binding_is_rejected
  wrong_support_tuple_is_rejected
  support_envelope_block_rejects_effect_consumption
  wrong_capability_pack_is_rejected
  active_revocation_rejects_effect_consumption
  missing_approval_binding_rejects_effect_consumption
  missing_exception_binding_rejects_effect_consumption
  missing_rollback_posture_rejects_effect_consumption
  budget_denial_rejects_effect_consumption
  egress_denial_rejects_effect_consumption
)

for test_name in "${tests[@]}"; do
  cargo test \
    --manifest-path "$ROOT_DIR/.octon/framework/engine/runtime/crates/Cargo.toml" \
    -p octon_authority_engine --lib "$test_name"
done
