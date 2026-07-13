# Acceptance Criteria

RP-07 may exit only when every criterion is proven at an exact implementation
commit by retained evidence under the declared packet evidence root.

## Architecture And Ownership

- **RP07-AC-001 — Single evidence truth path.** One canonical operation model,
  one signed envelope/checkpoint family, and one monotonic head are live; no
  duplicate canonical journal, signature format, or evidence control plane
  remains.
- **RP07-AC-002 — Frozen dependency use.** RP-03 owns SQL schema/transitions,
  `runtime_bus`, outbox, and logical reservation; RP-04 owns broker effects;
  RP-06 owns verdict/publication semantics. RP-07 changes only the declared
  APIs, exact evidence modules, and exact registry/workspace entries.

## Authenticity And Anti-Rollback

- **RP07-AC-003 — Producer-direct signatures.** Broker and verifier use
  distinct candidate-inaccessible role-bound keys to sign canonical direct
  observations, and independent verification rejects payload mutation,
  non-canonical bytes, producer-role substitution, duplicate identity, wrong
  key, revoked key, expired epoch, and algorithm downgrade.
- **RP07-AC-004 — Signed checkpoints.** Range and terminal checkpoints bind
  sequence/range, observation manifest, prior head, keys, pins, completeness,
  terminal state, and detached signature. Rewriting and rechaining any covered
  observation fails verification.
- **RP07-AC-005 — Monotonic latest head.** Restoring an older DB and valid old
  checkpoint, forking an equal sequence, decreasing sequence, or rolling back
  the anchor is rejected by a candidate-inaccessible compare-and-advance
  mechanism.
- **RP07-AC-006 — Honest claim boundary.** A signature proves only the exact
  direct observation. Lost responses or state convergence without provider
  attribution cannot be labeled attempt-performed; Git history alone never
  satisfies signature verification.

## Capacity And Durability

- **RP07-AC-007 — Same-transaction logical reserve.** Each consequential T1
  admission reserves an RP-07 terminal size class with the operation/outbox;
  duplicate/concurrent admission cannot double-spend the reservation.
- **RP07-AC-008 — Physical terminal reserve.** On a constrained filesystem,
  complete bounded denial, failure, revocation, rollback, and closeout records
  remain atomically writable and verifiable after ordinary writes return
  `ENOSPC`; no canonical record is truncated.
- **RP07-AC-009 — Admission fail closed.** Missing or depleted logical/physical
  reserve denies new dependent consequential work before effect and preserves
  candidate work without a standalone lease service.

## Retention And Compaction

- **RP07-AC-010 — Enforced bounds and pins.** Byte/inode/count/age quotas apply
  by project, run, and evidence class; active, unknown, rollback-required,
  latest-trusted, and explicit pins cannot be deleted.
- **RP07-AC-011 — Safe compaction.** Compaction verifies, signs a range
  checkpoint, advances the head, records a durable receipt, and only then
  deletes raw items. Crashes at every boundary converge to preserved raw data
  or a fully covered compact range; pin deletion and partial coverage deny.
- **RP07-AC-012 — Bounded raw locality.** Raw logs/payloads remain local and
  outside project Git without exception; tracked projections contain only classified
  minimal signed checkpoints/pointers and their freshness/source digests.

## Degraded Operation And Solo UX

- **RP07-AC-013 — No unsafe fallback.** Missing signer, anchor, storage,
  checkpoint, or compaction proof blocks only the dependent success/publication
  transition, preserves candidate/raw work, and never accepts unsigned or
  Git-only evidence.
- **RP07-AC-014 — One-screen status.** Operator status reports signer/epoch,
  head, reserve, quota, pins, compaction, block reason, preserved work, and one
  actionable repair route without routine confirmation prompts.
- **RP07-AC-015 — Maintenance burden.** A representative 30-day run set stays
  within selected quotas, creates no unbounded tracked-file growth, and keeps
  routine evidence administration inside the program's monthly solo-operator
  budget.

## Lifecycle Gates

- **RP07-AC-016 — ROD, engineering, and UE closure.** Accepted ROD-001
  invariants are bound; a separate engineering record
  fixes the signer, anchor, reserve, backup mechanisms and provisional values;
  UE-008 adversarial evidence passes.
- **RP07-AC-017 — Proposal closeout gates.** Accepted review and strict
  architecture-review receipts precede implementation; implementation-grade,
  conformance, and drift/churn receipts pass before implemented closeout.
- **RP07-AC-018 — Exact publication chain.** The signed chain binds every
  grant/route/`O/S/V/Q`/history/operation/provider/landed/reconciliation/mirror/
  cleanup field and the responsible role without omission or substitution.
- **RP07-AC-019 — Role separation and epistemic limit.** Candidate, verifier,
  broker, provider observer, and reconciler remain attributable. Broker and
  verifier observations use their own distinct role-bound producer-signing
  identities, while the checkpoint signer is separately attributable; no
  candidate access or silent role aliasing is permitted, and no signature
  converts state equality into causal proof or mints authority.
- **RP07-AC-020 — Preservation and cleanup truth.** Every denial/collision/
  outage/failed/unknown/cleanup-deferred result retains a signed preserved-work
  fact; `cleaned` requires conditional proof and raw operational detail in
  project Git remains zero.
