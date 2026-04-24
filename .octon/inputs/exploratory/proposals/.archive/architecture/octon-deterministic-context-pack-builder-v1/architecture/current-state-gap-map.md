# Current-State Gap Map

## Summary

This map records the pre-promotion gaps that drove the packet. The final
disposition is implemented: durable contracts, runtime code, policy, validator,
fixtures, conformance wiring, and packet checksums now close the listed gaps.

| Subcomponent | Current Octon evidence | Coverage status | Gap type(s) | Operational risk if left as-is | Final disposition |
|---|---|---|---|---|---|
| Constitutional context-pack contract | `context-pack-v1.schema.json` | partially_covered | shallow_contract; missing_runtime_binding | medium | adapt |
| Execution authorization binding | `execution-request-v3`, `execution-authorization-v1`, `execution-grant-v1`, `execution-receipt-v3` | partially_covered | missing_receipt_binding; missing_invalidity_semantics | high | adapt |
| Instruction-layer evidence | `instruction-layer-manifest-v2` | partially_covered | missing_context_binding | medium-high | adapt |
| Runtime event coverage | `runtime-event-v1` | partially_covered | missing_builder_events; missing_rebuild_and_invalidation coverage | medium | adapt |
| Repo-specific policy | no dedicated context packing policy found | missing | missing_policy_surface | high | add |
| Assurance enforcement | no dedicated context-pack builder validator found | missing | missing_validator; missing_ci_gate | high | add |
| State/control and retained evidence shape | roots exist, but no dedicated context-pack state/evidence binding contract found | partially_covered | missing_emission_contract | high | adapt |
| Support-target proof posture | `support-targets.yml` requires instruction-layer manifest and runtime-event-ledger for relevant adapters, but not explicit context-pack receipts | partially_covered | missing_required_evidence strengthening | medium | adapt |

## Implemented closure overlay

- `context-pack-v1` now carries model-visible ref/hash, source classification, trust, authority, inclusion, freshness, invalidation, rebuild, replay, and policy fields.
- `context-pack-builder-v1.md` and `context-pack-receipt-v1.schema.json` now define the deterministic runtime contract and retained receipt.
- `authorize_execution(...)` now validates supplied or built pack evidence before allowing consequential or boundary-sensitive Runs.
- `instruction-layer-manifest-v2`, execution request/grant/receipt schemas, and Rust bindings now preserve `model_visible_context_ref` and `model_visible_context_sha256`.
- `run-event-v2` now carries canonical `context-pack-*` lifecycle events; dot-named `runtime-event-v1` forms are alias-only.
- `context-packing.yml`, durable fixtures, validator, tests, and active conformance wiring now make the migration enforcement-led.

## Detailed gaps

### 1. Existing constitutional contract is real, but shallow

**What exists now**
- `/.octon/framework/constitution/contracts/runtime/context-pack-v1.schema.json` already defines a canonical deterministic context assembly contract for consequential runs.
- It already requires `context_pack_id`, `run_id`, `authority_sources`, `derived_sources`, `omissions`, `budget`, `freshness`, and `generated_at`.
- Each source entry already carries `path`, `sha256`, and `authority_label`.

**Why that is not yet enough**
- There is no builder contract that defines deterministic source ordering, tie-break rules, or canonical assembly order.
- Source entries do not yet carry enough information to distinguish:
  - actual super-root surface class
  - trust class
  - inclusion mode
  - source role
  - whether content was model-visible directly vs summarized or omitted
- The top-level schema does not yet capture model-visible payload hashes or explicit builder-policy references.

### 2. Authorization requires `context_pack_ref`, but there is no closure-grade runtime receipt

**What exists now**
- `execution-request-v3` requires `context_pack_ref`.
- `execution-authorization-v1` says context-pack provenance must participate in authority routing.
- `execution-grant-v1` and `execution-receipt-v3` already carry `context_pack_ref`.

**Why that is not yet enough**
- The runtime cannot yet prove what exact model-visible context payload corresponded to `context_pack_ref`.
- There is no dedicated context-pack receipt recording:
  - exact model-visible hash
  - builder version / policy
  - source-class and trust-class breakdown
  - omissions under budget pressure
  - invalidation or rebuild status
- This leaves authorization relying on a context reference that is structurally real but not yet closure-grade.

### 3. Instruction-layer evidence does not yet fully bind context assembly

**What exists now**
- `instruction-layer-manifest-v2` already records workspace charter refs, run contract ref, support target tuple, authority refs, precedence stack, adapter projections, and source digests.

**Why that is not yet enough**
- It does not yet guarantee a direct binding to:
  - context-pack receipt ref
  - model-visible context hash
  - context assembly policy ref
  - compaction / invalidation receipt refs
- As a result, instruction-layer evidence still leaves a material gap between “what governed the run” and “what the model actually saw.”

### 4. No repo-specific context policy exists yet

**What exists now**
- Governance policies already exist for network egress, execution budgets, mission autonomy, and governance exclusions.

**Why that is not yet enough**
- The repo does not yet expose a dedicated policy surface for:
  - context budgets by source class
  - trust-class restrictions
  - rules for non-authoritative inputs
  - freshness TTLs
  - compaction triggers
  - generated read-model exclusion
  - support-target-specific context rules

### 5. No validator blocks context drift

**What exists now**
- Proposal standards and architecture-conformance automation already exist.
- Assurance runtime scripts and tests are already first-class durable surfaces.

**Why that is not yet enough**
- There is no dedicated validator proving that:
  - the builder emits all required evidence
  - the emitted pack is deterministic
  - forbidden source classes do not become model-visible authority
  - stale or invalidated packs are rejected for consequential runs
  - the instruction-layer manifest, grant/receipt artifacts, and runtime journal agree on the same context evidence

## Explicit no-change areas

This packet does **not** change:
- top-level class roots
- mission authority design
- support universe membership
- capability-pack architecture except where context-pack assembly must reference approved capability schemas
- memory governance
- generated read-model authority posture
