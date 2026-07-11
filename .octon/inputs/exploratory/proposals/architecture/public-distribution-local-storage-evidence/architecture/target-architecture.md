# Target Architecture

## Boundary

Storage class describes where information resides and how it is protected; it does not change architectural authority. Hosted receipts can support claims but never substitute for required raw evidence when policy demands retention.

## Proposed Components

- A repository-surface Git-posture matrix and validator (`validate-local-storage-policy.sh`).
- Truthful local-private evidence records with real SHA-256 content digests (`local-private-evidence-v1.schema.json`).
- One dependency-closed storage-class contract spanning the active retention,
  replay, evidence-store, disclosure, policy-interface, shell-runtime, and Rust
  authority-engine surfaces. `external-immutable` remains valid only when a
  real external object, durable locator, and actual content digest exist;
  first-release local custody uses `local-private` and otherwise fails closed.
- Retention classes and backup verification runbook.
- Publishable compact receipt schema with disclosure classification.
- Machine-readable Git-posture defaults consumed by downstream initialization (`repository-git-posture-v1.yml`).
- Input-subtype classification and explicit hosting exceptions.
- Hosted-repository footprint guidance describing the bounded hosted surface (`hosted-repository-footprint.md`).

## File-Level Work Areas

- `.octon/octon.yml` — existing manifest; revise generated/effective and cognition commit defaults toward local-first posture.
- `.octon/framework/cognition/_meta/architecture/contract-registry.yml` — add
  the local-private storage class to the active retention binding.
- `.octon/framework/constitution/contracts/retention/README.md`
- `.octon/framework/constitution/contracts/retention/family.yml`
- `.octon/framework/constitution/contracts/retention/replay-storage-class-v1.schema.json`
- `.octon/framework/constitution/contracts/retention/evidence-classification-v1.schema.json`
- `.octon/framework/constitution/contracts/retention/run-evidence-classification-v2.schema.json`
- `.octon/framework/constitution/contracts/retention/evidence-store-v1.schema.json`
- `.octon/framework/constitution/contracts/retention/evidence-disclosure-tiers-v1.yml`

  These existing files form the active retention and disclosure contract
  closure and must change atomically.
- `.octon/framework/constitution/contracts/retention/local-private-evidence-v1.schema.json` — new deliverable; truthful local-private evidence record schema with real content-digest semantics.
- `.octon/framework/constitution/contracts/retention/repository-git-posture-v1.yml` — new deliverable; machine-readable class-root and input-subtype Git-posture defaults.
- `.octon/framework/engine/runtime/spec/evidence-store-v1.md`
- `.octon/framework/engine/runtime/spec/policy-interface-v1.md`

  These specifications define local-private custody and fail-closed external
  storage behavior without weakening evidence completeness.
- `.octon/framework/lab/runtime/README.md` and `.octon/framework/lab/runtime/contracts/replay-manifest-v1.schema.json` — align replay documentation and schema with truthful local custody.
- `.octon/framework/engine/runtime/crates/authority_engine/src/implementation/execution.rs`
- `.octon/framework/engine/runtime/crates/authority_engine/src/implementation/runtime_state.rs`
- `.octon/framework/engine/runtime/crates/authority_engine/src/implementation/tests.rs`

  These Rust paths stop synthesizing external indices and verify local-private
  or real external records in the authority-engine execution path.
- `.octon/framework/orchestration/runtime/_ops/scripts/write-run.sh` — existing writer; replace synthetic external-immutable locators and run-id-shaped digests.
- `.octon/framework/orchestration/runtime/_ops/tests/test-shared-runtime-primitives.sh` — replace synthetic-pointer expectations with real-object and local-private positive and negative cases.
- `.octon/framework/cognition/_meta/architecture/hosted-repository-footprint.md` — new deliverable; architecture guidance for the bounded hosted repository footprint.
- `.octon/framework/assurance/runtime/_ops/scripts/validate-local-storage-policy.sh` — new deliverable; deterministic validator for storage-class claims, Git posture, and tracked local-only roots.
- `.octon/framework/assurance/runtime/_ops/tests/test-local-storage-policy.sh` and `.octon/framework/assurance/runtime/_ops/fixtures/local-storage-policy/` — checked-in positive, negative, producer, consumer, and tracked-path fixtures.
- `.octon/framework/assurance/runtime/_ops/scripts/validate-evidence-disclosure-tiers.sh` and `.octon/framework/assurance/runtime/_ops/tests/test-validate-evidence-disclosure-tiers.sh` — preserve publishable-receipt validation while making local-private custody explicit.
- `.octon/state/evidence/validation/proposals/public-distribution-local-storage-evidence/` — child evidence root for retained validation receipts.

## Ownership

- Projects own retention and hosting choices within the normative safety floor.
- Deterministic tooling owns hashes, classification validation, and expiration candidate lists.
- The maintainer owns deletion, disclosure exceptions, and backup-key custody.
- AI may summarize only after receiving bounded redacted input.

## Security And Publication Implications

- Raw evidence, reports, logs, proposals, and ideation can contain sensitive material regardless of authority.
- Backups require encryption, restore testing, and separate key custody.
- Receipts must minimize paths and descriptions that could reveal sensitive project facts.
- Generated outputs inherit source sensitivity and cannot be presumed safe.

## Automation Allocation

### Deterministic Automation

- Compute real content hashes before writing evidence references.
- Validate storage-class claims against actual object existence and locator policy.
- Cross-check every active schema, producer, consumer, validator, and test in
  the declared storage-class closure so no writer can emit a class that a
  reader rejects or misinterprets.
- Classify Git posture and detect newly tracked local-only roots.
- Identify retention candidates without deleting them.

### AI-Assisted Review

- Draft compact summaries from bounded redacted evidence.
- Flag likely sensitive or publication-restricted material for maintainer review.

AI output remains review input and cannot clear provenance, accept exposure,
authorize deletion, approve publication, or waive a failed deterministic gate.

### Maintainer-Only Authority

- Authorize evidence deletion and disclosure.
- Maintain encryption and recovery-key custody.
- Approve hosted exceptions for inputs, reports, evidence, or generated artifacts.

## Negative Controls

- No external-immutable claim exists without a real object, durable locator, and real content digest.
- No shell or Rust producer fabricates an external index from a local manifest,
  trace pointer, run identifier, or locator-shaped string.
- No contract migration leaves an old reader accepting fabricated external
  evidence or rejecting valid local-private evidence.
- No generated, state, evidence, or host root becomes hosted-required by default.
- No raw input becomes authority or publication-safe by classification.
- No retention automation deletes evidence autonomously.
- No high-value local evidence has only one machine-local copy.

## Deferred Work And Triggers

- Scheduled compaction activates after evidence volume creates measurable burden.
- Hosted immutable storage activates after collaboration, regulation, or recovery requirements exceed local encrypted backup.
- Automated retention deletion activates only after mature classification and explicit maintainer policy.

## Residual Risks

- Local custody concentrates operational responsibility on one maintainer.
- Encrypted backups can still be lost if restore tests or key custody fail.
- Over-minimized receipts may be insufficient for later claims.
- Existing historical receipts may require a compatibility reader; they must
  not be silently rewritten or treated as proof of a real external object.
