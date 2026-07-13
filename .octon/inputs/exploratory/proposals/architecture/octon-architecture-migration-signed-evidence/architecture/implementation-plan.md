# Implementation Plan

This plan is advisory until the packet is accepted, accepted ROD-001 invariants
are bound and the separate engineering-default record is complete, the strict
architecture-review gate passes, and RP-03/RP-04/RP-06 exit interfaces are
frozen.

## Workstream 1 — Design-Exit Disposition And Interface Freeze

1. Bind accepted ROD-001 bounded-local-raw, longer-lived-signed-reference,
   terminal-reserve, no-unsigned-fallback, and deny/preserve-work invariants.
   Separately select signer algorithm/provider, monotonic-anchor mechanism,
   reserve implementation and provisional size, quotas, retention windows, and
   backup generations through conservative reversible engineering defaults and
   mechanism-specific proof.
2. Bind exact dependency digests for RP-03 outbox/logical-reserve API, RP-04
   broker observation interface, and RP-06 verifier observation interface.
3. Inventory every current evidence/checkpoint/retention writer and every use
   of `sign`, `signature`, and `attestation`; classify as cryptographic,
   digest-only, projection, or misleading.
4. Assign exact shared registry entries and Cargo/module integration symbols;
   serialize overlapping changes.

## Workstream 2 — Contracts And Policy

1. Define strict canonical `signed-evidence-envelope-v1` and
   `signed-evidence-checkpoint-v1` schemas.
2. Extend checkpoint-v2 and retention/evidence-store contracts for signature,
   key epoch, prior head, range, pins, completeness, anchor receipt, physical
   reserve, quota, and compaction receipt fields.
3. Publish `evidence-capacity-retention-v1.md` with logical/physical boundary,
   bounded terminal classes, verify-checkpoint-anchor-delete ordering, and
   degraded behavior.
4. Publish active instance policies for admitted signer identities/epochs,
   anchor, reserve thresholds, quotas, pins, retention, raw locality, and
   publishable minimal projections.
5. Register only exact new contract identities; generated instances remain
   evidence/projections.

## Workstream 3 — Evidence Attestation Library

1. Add `evidence_attestation` with canonical serialization, strict parsing,
   signing, key resolution, signature verification, revocation/epoch checks,
   producer-role binding, checkpoint construction/verification, head
   compare-and-advance client, reserve manager, pin evaluation, and compaction
   state machine.
2. Keep private-key operations behind a narrow protected-credential interface;
   never serialize private material into repo, candidate, logs, or receipts.
3. Make verification usable independently of the signing process and reject
   unknown algorithms, downgraded schemas, non-canonical bytes, and duplicate
   producer identities.
4. Use the RP-03 outbox and capacity API; do not introduce SQL schema or a
   second journal/store.

## Workstream 4 — Broker And Verifier Direct Observations

1. In RP-04's exact `local_broker/src/evidence.rs` adapter, map only broker
   direct facts to canonical payloads and sign them with the broker identity.
2. In RP-06's exact `verification_publication/src/evidence.rs` adapter, map only
   verifier direct facts to canonical payloads and sign them with the verifier
   identity.
3. Reject identity alias, candidate key access, role substitution, missing
   provider operation reference where a claim requires it, and lost-response
   causation claims.
4. Drain outbox items idempotently; duplicate drains return the existing signed
   record identity rather than creating divergent observations.

## Workstream 5 — Capacity, Checkpoint, Head, And Retention

1. Preallocate and verify non-sparse terminal slots or the selected equivalent;
   bind each T1 logical reservation to a physical size class.
2. Produce signed range and terminal checkpoints from verified observations,
   bind active pins/completeness, and independently reverify them.
3. Advance the candidate-inaccessible head atomically with old/new sequence and
   checkpoint digest; durably retain anchor receipts.
4. Enforce project/run/class byte, inode, count, and age quotas while excluding
   terminal reserve from ordinary consumption.
5. Run verify-checkpoint-anchor-delete compaction with crash-resumable receipts;
   preserve raw data on any uncertainty.

## Workstream 6 — Minimal Projection And Claim Correction

1. Emit only classified signed checkpoints, compact manifests, anchor receipt
   references, and opaque evidence pointers to project-Git-eligible surfaces.
2. Keep raw logs, prompts, provider payloads, and bulky fixtures local and
   bounded.
3. Replace or reject every misleading digest-only `signature`/attestation claim
   in RP-07-owned targets; cross-report broader claim inventory to RP-00/RP-14.
4. Ensure evidence pointers cannot be consumed as authority or treated as proof
   when source/signature freshness fails.

## Workstream 7 — Fault Proof, Cutover, And Handoff

1. Execute wrong/revoked key, producer forgery, rechain, non-canonical bytes,
   old snapshot, anchor rollback/fork, `ENOSPC`, reserve exhaustion, outbox
   duplicate, pin deletion, compaction crash, and projection-locality tests.
2. Rehearse signer/anchor/storage unavailable states and key rotation/loss under
   the selected ROD-001 posture.
3. Shadow-sign and no-delete compact while autonomous publication stays
   disabled; compare against current evidence without accepting it as live.
4. Atomically activate signature verification, current head, reserve, and
   retention gates; retire unsigned success and duplicate canonical journals.
5. Retain exact proof and provide the frozen verified-evidence interface to
   RP-08 and independent reproduction inputs to RP-14.

## Change Discipline

- Each workstream records exact before/after contracts and retained evidence.
- No implementation work begins from this draft.
- Any need to change RP-03 schema/transitions, RP-04 effect semantics, or RP-06
  verdict semantics routes back to the owning packet before proceeding.
- A failure to prove the selected anchor or physical reserve blocks activation;
  it never justifies unsigned or Git-only fallback.

Extend the signed envelope/checkpoint, broker observation adapter, verifier
observation adapter, and minimal operator projection with the Git publication
profile. RP-01 retains grant semantics, RP-06 retains `V`/route/`S -> Q`, and
RP-08 retains outcome/recovery/cleanup state. Shadow-sign the complete lifecycle
with deletion disabled before any Class B publication can enable.
