# Phase 0 Validation

- `yq -e '.' .octon/instance/cognition/context/shared/migrations/index.yml`: PASS
- `yq -e '.records[] | select(.id == "2026-03-28-unified-execution-constitution-phase0-baseline-freeze")' .octon/instance/cognition/context/shared/migrations/index.yml`: PASS
- `yq -e '.' .octon/instance/cognition/context/shared/evidence/index.yml`: PASS
- `yq -e '.records[] | select(.id == "2026-03-28-unified-execution-constitution-phase0-baseline-freeze")' .octon/instance/cognition/context/shared/evidence/index.yml`: PASS
- `yq -e '.' .octon/instance/cognition/decisions/index.yml`: PASS
- `yq -e '.records[] | select(.id == "076-unified-execution-constitution-phase0-baseline-freeze")' .octon/instance/cognition/decisions/index.yml`: PASS
- `yq -e '.' .octon/state/evidence/migration/2026-03-28-unified-execution-constitution-phase0-baseline-freeze/bundle.yml`: PASS
- `yq -e '.' .octon/state/evidence/migration/2026-03-28-unified-execution-constitution-phase0-baseline-freeze/frozen-inputs.yml`: PASS
- `yq -e '.schema_version == "phase0-constitutional-freeze-v1" and (.inputs | length == 15)' .octon/state/evidence/migration/2026-03-28-unified-execution-constitution-phase0-baseline-freeze/frozen-inputs.yml`: PASS
- `yq -e '.' .octon/state/evidence/lab/harness-cards/hc-phase0-unified-execution-constitution-baseline-v0-20260328.yml`: PASS
- `yq -e '.schema_version == "harness-card-v1" and .card_id == "hc-phase0-unified-execution-constitution-baseline-v0-20260328" and (.proof_bundle_refs | length == 3)' .octon/state/evidence/lab/harness-cards/hc-phase0-unified-execution-constitution-baseline-v0-20260328.yml`: PASS
- `git diff --check`: PASS
