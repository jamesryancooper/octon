# Validation Plan

## Draft Packet Checks

Run the repository proposal validators read-only against this packet:

- `validate-proposal-standard.sh`
- `validate-architecture-proposal.sh`
- `validate-proposal-implementation-readiness.sh`
- `validate-proposal-review-gate.sh`
- `validate-architectural-review-receipts.sh`

The draft is expected to pass structural checks while implementation readiness,
strict review authorization, conformance, and closeout remain blocked.

## Future Contract And Static Checks

- validate signed envelope/checkpoint schemas, retention/checkpoint contract
  registry entries, instance signing/retention policies, and exact Cargo/module
  membership;
- prove every promotion target is under `.octon/**` and raw project-Git payload
  targets are absent;
- scan for duplicate canonical journal/checkpoint/signature formats and direct
  signing bypasses;
- inventory every `sign`, `signed`, `signature`, and `attestation` claim and
  require verified cryptographic semantics or accurate digest-only wording;
- scan candidates/logs/receipts for private-key material and candidate access;
  and
- verify exact shared ownership: no RP-07 SQL schema/transition/`runtime_bus`,
  broker effect, or verifier verdict semantics.

## PO-FD-013 / PG-07-EVIDENCE-CAPACITY

Run an adversarial capacity matrix:

1. reserve logical and physical terminal classes during T1;
2. race duplicate/concurrent admissions and prove one reservation;
3. fill a constrained volume until ordinary writes return `ENOSPC`;
4. inject denial, failure, revocation, rollback, and closeout terminal paths;
5. kill before/after record write, fsync, atomic publication, reserve consume,
   and replenish; and
6. restart and verify every terminal class is complete, canonical, signed, and
   untruncated.

Also prove reserve depletion denies new consequential admission before effect,
does not consume raw/pinned evidence incorrectly, and does not instantiate a
capacity lease service.

## PO-FD-014 / PG-07-SIGNED-EVIDENCE

Run signature and producer-binding fixtures for:

- correct broker and verifier observations with distinct keys;
- payload-byte mutation, field reordering/non-canonical bytes, unknown field,
  wrong role, wrong key, revoked key, stale epoch, algorithm downgrade,
  duplicate identity, and same-key alias;
- producer forgery: candidate fabricates broker/verifier records and one
  producer attempts to sign the other's facts;
- full log rewrite and public-hash rechain under the original signed
  checkpoint;
- old valid DB/checkpoint restore, equal-sequence fork, lower-sequence head,
  and anchor rollback;
- missing terminal evidence, false completeness, and lost-response causation
  overclaim; and
- Git-only checkpoint/hash with no valid producer/checkpoint signature.

Every invalid fixture must deny. Verification must run in a process that does
not possess the producer private key.

## UE-008 Compaction And Low-Space Matrix

- pin active, unknown, rollback-required, latest-trusted, and operator-retained
  ranges; attempted deletion denies;
- compact an eligible range and inject crash before/after selection,
  verification, checkpoint sign, independent verify, anchor advance, receipt,
  each deletion, and completion;
- prove restart preserves raw data or a complete checkpoint-covered deletion,
  never an uncovered gap;
- mutate compacted-range evidence and prove checkpoint verification fails;
- run compaction while normal capacity is exhausted but terminal reserve is
  intact; and
- measure bytes, inodes, file count, pinned volume, raw age, project-Git raw
  payload count, and retained signed projection count across a representative
  30-day workload.

## Degraded And Recovery Matrix

Independently remove or fail broker signer, verifier signer, key lookup,
monotonic anchor, ordinary evidence storage, terminal reserve, outbox drain,
checkpoint verification, and compaction. Each case must:

- block only the dependent transition;
- preserve candidate work, raw evidence, pins, and last trusted head;
- expose one concise reason and repair route;
- emit no success/publication claim requiring missing evidence; and
- offer no unsigned, Git-only, or stale-head fallback.

Key rotation/loss and anchor/storage backup/restore tests follow accepted
ROD-001 invariants and the engineering-default record and must show recovery
behavior honestly without inventing unsupported fixed values.

## Projection And UX Checks

- assert raw provider/model payloads, logs, and transcripts are absent from
  project Git by default;
- verify each signed pointer binds source digest, classification, signature,
  anchor receipt, and freshness and fails closed when source is unavailable;
- assert generated/retained evidence cannot be consumed as authority;
- snapshot one-screen status for healthy, nearing quota, reserve depleted,
  signer unavailable, anchor mismatch, pinned compaction, and recovery states;
  and
- measure that routine healthy operation asks no confirmation and evidence
  administration remains within the selected solo-builder budget.

## Retained Evidence

Retain exact commit, configuration, support tuple, signer/key-epoch public
metadata, anchor identity, reserve policy, quota/pin policy, fixtures, commands,
exit codes, canonical payloads/signatures, negative results, fault points,
capacity measurements, compaction receipts, status snapshots, and scope
limitations under the packet evidence root. No private key or raw sensitive
payload enters retained project Git evidence.

Publication negatives substitute wrong `O/S/V/Q`, grant, issuer, route,
history range, harness/policy, producer/deployment, operation/attempt, or landed
observation; replay duplicate contexts; claim causation from state equality;
claim `cleaned` without conditional result; delete closed-unmerged work; or add
raw logs to Git. Positive proof requires immediate landed observation by a
non-broker identity and distinguishes immediate landing from later containment.
