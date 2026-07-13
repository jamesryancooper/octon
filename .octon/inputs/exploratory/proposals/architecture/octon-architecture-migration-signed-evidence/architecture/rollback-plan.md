# Rollback And Recovery Plan

## Principle

Rollback may reduce autonomy, stop publication, preserve raw data, and restore
only a prior certified implementation behind the same signature/head/reserve
boundary. It may never restore unsigned success, candidate-accessible keys,
Git-as-signature, dual canonical journals, delete-before-anchor compaction, or
logical-only capacity claims.

## Stage Rollbacks

| Stage | Safe rollback |
| --- | --- |
| Inert contracts | Remove unactivated contract/policy entries; no live behavior or evidence is reinterpreted. |
| Shadow signing | Disable shadow producer adapters, retain shadow records as clearly non-live diagnostics, preserve current live route. |
| Checkpoint no-delete | Stop checkpoint/head workers, retain all raw observations and last verified shadow head, diagnose forward. |
| Reserve deny-only | Disable new consequential admission, preserve candidate work and allocated reserve; do not bypass the reserve. |
| Compaction rehearsal | Discard copied compact output, retain source raw data and pins; no live deletion occurred. |
| Activated | Disable autonomous success/publication, stop new consequential admission if evidence cannot be guaranteed, preserve candidates/raw/pins/head, and restore only the prior certified RP-07 implementation behind the same external interfaces. |

## Fault Recovery

- **Signer unavailable:** block dependent checkpoint/success, retain outbox/raw
  data and candidate, restore/rotate under ROD-001, then sign only after exact
  producer and key-epoch validation. Never accept unsigned records.
- **Key compromise/revocation:** revoke epoch, stop dependent transitions,
  preserve last trusted head, rotate distinct identity, and require a signed
  recovery checkpoint that explicitly links the old trusted head and new epoch.
- **Key loss:** follow declared recovery tolerance; if authenticity cannot be
  re-established, preserve evidence and report the range unverifiable rather
  than manufacturing a continuity claim.
- **Anchor unavailable/mismatch:** stop head-dependent success and compaction,
  preserve raw evidence/pins, compare last trusted receipts, and repair or
  restore the anchor without decreasing/forking its accepted sequence.
- **`ENOSPC` or reserve depletion:** deny new effects, consume only allocated
  terminal slots for required terminal records, preserve candidates, reclaim
  only verified unpinned ranges, then replenish/verify reserve before resume.
- **Compaction crash:** resume from durable checkpoint/anchor/receipt. If delete
  coverage is uncertain, retain remaining raw data and fail closed.
- **Projection failure:** retain canonical local signed evidence, block any
  claim requiring the projection, regenerate from verified sources; projection
  state never overrides the signed source.

## Recovery Invariants

- candidate work and last trusted signed head are never sacrificed to make a
  status appear complete;
- raw evidence is retained whenever compaction/delete outcome is uncertain;
- no retry or publication occurs from an older valid snapshot without current
  anchor agreement;
- terminal evidence uses reserved capacity before any discretionary diagnostic
  output;
- recovery actions are signed/receipted and cannot rewrite historical producer
  observations; and
- a permanent inability to re-establish proof yields honest blocked/manual
  intervention, not false success or failure.

## Rehearsal Gate

Before activation, inject failure at every signer, outbox, write/fsync/rename,
checkpoint, anchor, pin, compaction, delete, and reserve boundary. Demonstrate
that the recovery result is a verified prior head plus preserved data or a
verified new head plus covered deletion, never a silent gap.
