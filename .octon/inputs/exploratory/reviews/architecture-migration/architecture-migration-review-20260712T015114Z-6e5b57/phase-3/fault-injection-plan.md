# Fault-Injection Plan

## Transactional store

Inject process kill, power-loss simulation, I/O error, full disk, database
busy, corrupted page, truncated WAL, stale backup, and concurrent writers at:

1. request insertion;
2. grant and revocation generation read;
3. operation reservation;
4. evidence capacity reservation;
5. one-shot launch/effect consume;
6. attempt creation;
7. outbox insertion;
8. transaction commit;
9. projection cursor update;
10. checkpoint and compaction.

Expected: one canonical recoverable state; no authority resurrection; reserved
terminal evidence remains writable.

## Launch

Kill before guard consume, after consume before spawn, during sandbox creation,
after spawn before PID receipt, during cancellation, and during cleanup.
Repeat two concurrent consumers. Expected: at most one child, explicit unknown
or failed state, no host/Git residue, and safe recovery by operation ID.

## Broker and Git

Inject before network send, during authentication, after provider acceptance
before local result commit, client timeout, target advance, provider delay,
transport reset, duplicate request, stale verifier verdict, revocation after
reservation, and broker restart.

Expected: no automatic retry while unknown; exact observation reconciles;
target movement denies; duplicate idempotency key never repeats the effect.

## Verifier

Supply wrong repository/SHA/target/policy/version/event, expired signature,
revoked verifier key, duplicate/conflicting context, candidate-modified
workflow, missing checks, delayed checks, and provider API ambiguity.

Expected: no accepted verdict. Availability failure blocks only the
consequential transition and preserves candidate work.

## Evidence

Rewrite/rechain events, restore an older valid snapshot, alter manifest count,
delete a terminal record, forge signer, rotate/revoke key, interrupt projection,
interrupt compaction, pin evidence during compaction, and exhaust disk/inodes.

Expected: checkpoint verification detects history attacks; missing direct
result prevents success; raw evidence is deleted only after verified checkpoint
and retention decision.

## Trust activation

Kill at inert install, candidate verification, activation reservation, staged
start, health sampling, active-pointer update, old-version retirement, and
receipt commit. Modify the candidate's verifier, activation rule, rollback
rule, trust inventory, expected digest, signer key, and authority expansion
classification.

Expected terminal state is exactly old healthy version, exact new healthy
version, or verified automatic rollback. Candidate self-widening always fails.

## Product and recovery

Simulate offline provider, unavailable model, unavailable broker, locked
keychain, moved project root, stale harness, revoked extension, expired proof,
and interrupted overnight mission. Expected: concise inbox item, preserved
work, automatic safe recovery where possible, and no internal lifecycle
mechanics exposed unless actionable.

