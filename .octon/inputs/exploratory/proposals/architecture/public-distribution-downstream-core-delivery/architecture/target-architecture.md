# Target Architecture

## Boundary

The delivery tool owns .octon/core.lock.yml, the materialized core tree, cache, and update journal. The target repository owns instance, inputs, state, evidence, generated outputs, host projections, and all unrelated files.

## Proposed Components

- Exact, machine-validated core-lock schema with version, release identity,
  source commit, artifact digest, manifest digest, provenance identity, and
  compatibility declaration.
- Verified resolver and content-addressed local cache.
- Cross-platform install, verify, update, recover, and rollback commands.
- Neutral initialization contract for absent project-owned roots.
- Ownership inventory and pre/post project-path hash proof.
- Tier 1 packaging and fault-injection test harness.

## File-Level Work Areas

- `.octon/framework/engine/runtime/spec/downstream-core-delivery-v1.md` — new delivery contract: lock schema, ownership inventory, compatibility, journal, cache, and command contracts.
- `.octon/framework/engine/runtime/spec/core-lock-v1.schema.json` — new
  machine-readable schema for the committed `.octon/core.lock.yml`, including
  canonical serialization and unknown-field rejection.
- `.octon/framework/engine/runtime/crates/core_delivery/` — new Rust crate implementing install, verify, update, recover, and rollback.
- `.octon/framework/scaffolding/runtime/templates/octon/` — existing neutral template tree, modified so first initialization creates only absent project-owned surfaces.
- `.octon/framework/scaffolding/runtime/_ops/scripts/init-project.sh` — existing bootstrap script, modified (not created) to stop writing project configuration into framework-owned paths and to delegate to the delivery contract.
- `.octon/framework/assurance/runtime/_ops/scripts/validate-downstream-core-delivery.sh` — new deterministic validator for the delivery contract and negative cases.
- `.octon/framework/assurance/runtime/_ops/tests/test-downstream-core-delivery.sh` — new test harness covering Tier 1 install, update, interruption, recovery, rollback, and the PD-025 exclusion fixture; runtime-generated test data may live inside this test scope.
- `.octon/state/evidence/validation/proposals/public-distribution-downstream-core-delivery/` — child evidence root for retained validation receipts.

## Ownership

- Core delivery owns .octon/core.lock.yml and materialized core-owned files.
- The project owns all instance and operational roots.
- The maintainer chooses a requested version and confirms destructive conflict resolution.
- The self-hosting workspace remains source-owned and outside resolver replacement.

## Security And Publication Implications

- Artifact bytes must match SHA-256 and manifest before extraction.
- Attestation identity and source commit must match release policy when online evidence is available.
- Archive extraction rejects traversal, unsafe links, case collisions, and reserved Windows names.
- Compatibility is checked before any replacement.

## Automation Allocation

### Deterministic Automation

- Resolve exact versions and cache by digest.
- Verify checksums, manifest parity, provenance policy, and compatibility.
- Stage updates, journal states, swap core-owned trees, and verify project-owned hash invariance.
- Recover or roll back deterministically after injected interruption points.

### AI-Assisted Review

- Explain compatibility failures and summarize dry-run diffs.
- Suggest migration guidance without changing ownership or accepting conflicts.

AI output remains review input and cannot clear provenance, accept exposure,
authorize deletion, approve publication, or waive a failed deterministic gate.

### Maintainer-Only Authority

- Select upgrade versions and authorize conflict overrides.
- Approve first initialization inputs that create project authority.
- Choose rollback or forward recovery when both are safe.

## Negative Controls

- No core operation writes under instance, inputs, state, evidence, generated, or host roots except explicit first-init creation of absent neutral project surfaces.
- No unverified bytes are materialized.
- No lock is advanced before the new core is active and verified.
- No parser accepts a lock that fails `core-lock-v1.schema.json`, contains an
  unknown field, or omits a release, source, digest, provenance, or
  compatibility binding.
- No update operates on the self-hosting workspace as a downstream consumer.
- No automatic commit, push, or remote mutation occurs.

## Deferred Work And Triggers

- Committed vendoring activates for an adopter with a verified offline or policy requirement.
- Internal mirrors activate for repeated constrained-network adoption.
- Automatic instance migrations activate only with a versioned instance schema transition.
- Tier 2 gating activates after install, update, interruption, and rollback reliability is demonstrated.

## Residual Risks

- Filesystem atomicity differs across platforms and mount points.
- Local caches can be lost and require artifact reacquisition.
- Manual project edits inside core-owned paths create conflicts that need explicit handling.
