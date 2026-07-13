# Target Architecture

## Decision

Octon will use one local, bounded evidence plane that authenticates direct
broker and verifier observations, chains them into signed range and terminal
checkpoints, advances a candidate-inaccessible monotonic latest head, reserves
terminal evidence capacity physically and logically, and compacts raw evidence
only after a verified checkpoint and anchor commit.

This decision implements FD-013 and FD-014 and the evidence-availability part
of FD-016. It does not create authority: an authenticated observation proves
who signed exactly which canonical bytes, not that the signer was authorized or
that a desired state was caused by a particular attempt unless the payload and
provider evidence truthfully establish that fact.

## Threat And Failure Model

The design must detect or safely contain:

- a candidate rewriting, deleting, rechaining, or fabricating evidence;
- a producer signing facts it did not directly observe;
- wrong, expired, revoked, rotated, or duplicated signer identity;
- restoration of an older database plus an older but valid signed checkpoint;
- rollback, fork, or loss of the latest-head anchor;
- normal-volume exhaustion, `ENOSPC`, reserve depletion, partial write, or
  crash during terminal recording;
- crash before or after outbox drain, checkpoint creation, anchor advance, pin
  application, compaction copy, or raw deletion;
- a missing signer, verifier, broker, anchor, or evidence store; and
- false completeness, success, publication, or support claims when required
  evidence is missing.

The initial support envelope is one solo operator on an admitted local
platform with a protected credential store and local filesystem. Distributed
transparency, federation, multi-operator quorum, remote key service, and
hardware-monotonic support on every platform are outside this packet.

## Components

### 1. Canonical Signed Evidence Envelope

`signed-evidence-envelope-v1` uses canonical schema-validated bytes. The signed
payload includes at least:

- schema/version and record type;
- repository, project, run, operation/attempt, and evidence identities;
- producer role (`broker` or `verifier`), stable producer identity, signer key
  id, algorithm id, and key epoch;
- observation type and only the facts directly observed by that producer;
- provider operation/reference identity when actually observed;
- subject/source/target/policy/Harness/verdict digests applicable to the
  observation;
- outcome classification, observation time, sequence, and prior signed-head
  digest;
- payload digest and detached signature; and
- classification/locality fields that control retention and publication.

Verification reconstructs the canonical payload, resolves the exact admitted
public key and epoch, checks revocation and role binding, verifies the detached
signature, and rejects unknown fields, algorithm downgrade, duplicate identity,
role mismatch, or non-canonical bytes. An unkeyed digest, capability-layer hash,
Git commit, or presence-counted `signature` string does not satisfy this
contract.

### 2. Producer-Direct Observation Rules

The broker signs only its own direct observations: request binding, authorized
attempt identity, provider request/reference actually sent or received,
response class, and timing. It cannot sign verifier conclusions or claim
provider causation after an unobservable lost response.

The verifier signs only its own direct observations: exact repository/provider
state, source/target/precondition/policy/Harness binding, evidence inputs,
verdict, expiry, and timing. It cannot publish or sign that the broker caused a
state unless direct provider attribution supports that statement.

Broker and verifier producer-signing identities are distinct,
candidate-inaccessible, role-bound, and non-exported by normal operation. The
checkpoint signer is a separately attributable signing role. Candidate access
and silent identity aliasing across producer or checkpoint roles are forbidden;
this does not confuse the producer's role-bound key with the checkpoint signer.

### 3. Signed Range And Terminal Checkpoints

A range checkpoint binds:

- ordered first/last sequence and observation identities;
- digest of the complete canonical observation manifest;
- previous accepted checkpoint/head digest;
- producer signature set and key epochs;
- active pin set and retained/raw locality references;
- completeness classification and excluded/missing evidence; and
- checkpoint signer, canonical payload digest, signature, and creation time.

A terminal checkpoint additionally binds operation/run terminal class,
denial/failure/revocation/rollback/closeout evidence identities, final
authorization/verdict refs, reserve consumption/replenishment state, and the
honest completeness result. Missing a required terminal class yields a signed
incomplete/blocked checkpoint, never success.

Checkpoints may cover ranges rather than sign every event. Each directly
material observation remains producer-signed; mechanically derived local
indexes need only digest-bind to a signed range.

### 4. Candidate-Inaccessible Monotonic Latest Head

The `LatestHead` interface is outside the candidate repository and outside the
rollback unit of RP-03's database. It exposes a narrow authenticated operation:

`compare_and_advance(scope, expected_sequence, expected_digest,
new_sequence, new_checkpoint_digest, signer_epoch) -> anchor_receipt`.

It rejects decreases, equal-sequence digest changes, forks, stale expected
heads, revoked signer epochs, and rollback attempts. The returned receipt binds
old/new head, scope, anchor identity, monotonic sequence, checkpoint digest,
time, and result. A DB-local row or Git history alone is insufficient. The
Engineering selects a platform-feasible local mechanism with mechanism-specific
proof, constrained by narrowed ROD-001 recovery and risk tolerances, while
preserving this interface and threat boundary.

### 5. Logical And Physical Terminal Capacity

RP-03 owns a frozen transactional API that reserves a bounded terminal-record
class in the same T1 transaction that admits/reserves an operation, emits an
outbox item, and later consumes/releases the logical reservation. RP-07 owns
policy for size classes, required terminal types, quotas, reserve thresholds,
and the evidence-writer implementation that consumes that API.

Physical capacity is real allocated headroom, not a free-space estimate or SQL
row. The selected mechanism must:

- preallocate non-sparse, evidence-writer-exclusive terminal slots or a proven
  equivalent before admitting consequential work;
- bound the maximum canonical terminal payload per class;
- atomically consume a slot for denial, failure, revocation, rollback, or
  closeout even when ordinary writes return `ENOSPC`;
- fsync/atomically publish the terminal record and reserve ledger; and
- replenish and verify the reserve before admitting the next consequential
  operation.

When logical or physical headroom falls below policy, new dependent operations
deny before effect. Existing candidate work remains available. There is no
standalone capacity lease, daemon, or second lifecycle.

### 6. Bounded Local Retention, Quotas, And Pins

The active policy declares byte/inode/count quotas by project, run, evidence
class, and age; terminal reserve is excluded from ordinary quota consumption.
Pins protect active operations, unresolved/unknown outcomes, required rollback
material, latest trusted checkpoints, and explicit operator retention.

Raw provider output, prompts, model transcripts, logs, and bulky fixtures stay
in the bounded local evidence store outside project Git without exception. Only
sanitized signed checkpoints, compact manifests, or opaque pointers may become
project-Git evidence after classification. A pointer cannot elevate absent raw
proof or become authority.

### 7. Verify-Checkpoint-Anchor-Delete Compaction

Compaction is one state machine:

1. select only unpinned closed ranges under policy;
2. verify all producer signatures, ordering, completeness, and current head;
3. build and sign a compact range checkpoint plus retained manifest;
4. verify the new checkpoint independently;
5. compare-and-advance the candidate-inaccessible head;
6. durably record the anchor and compaction receipt; and
7. delete raw range data only after steps 1-6 are durable.

A crash before step 7 leaves duplicate raw data, which is safe. A crash during
or after deletion must restart from the durable receipt and prove every deleted
item is covered. Failed verification, active pins, unavailable signer/anchor,
or reserve pressure blocks deletion. Compaction never rewrites a signed
checkpoint as though it were the original raw range.

### 8. Minimal Signed Projections

Project-Git projections contain only the minimal signed terminal/range
checkpoint, anchor receipt reference, classification, and opaque local/external
evidence pointer needed for review. They include source digests and freshness
metadata, are generated/retained evidence rather than authority, and fail
closed when their source or signature cannot be verified.

## Dependency And Shared-File Contract

- RP-03 freezes `reserve_terminal_capacity`, outbox claim/acknowledge, and
  operation/checkpoint reference fields. RP-07 does not add SQL tables,
  transitions, or a second journal.
- RP-04 supplies broker observations to the RP-07 encoder/signer through
  `local_broker/src/evidence.rs`; all effect behavior stays RP-04-owned.
- RP-06 supplies verifier observations through
  `verification_publication/src/evidence.rs`; verdict/predicate/publication
  semantics stay RP-06-owned.
- Registry and workspace changes are exact-entry edits. Integration is
  serialized with any concurrent packet touching the same entry/module.
- RP-08 consumes verified observations/checkpoints for recovery and may end in
  honest manual intervention; it cannot retry or publish by weakening RP-07.

## Safe Degraded State

If signer, anchor, reserve, evidence store, checkpoint verification, or
compaction is unavailable:

- no dependent autonomous success or publication claim is emitted;
- no unsigned fallback, Git-only substitution, or stale head is accepted;
- new consequential admissions deny when terminal evidence cannot be reserved;
- candidate work, authorization context, raw evidence, pins, and last trusted
  signed head remain preserved;
- completed safe local work may continue only when its required evidence class
  is unaffected; and
- the operator sees one concise state, cause, preserved assets, and repair
  action rather than a routine decision prompt.

## Simplicity Constraints

The target adds one library plus exact broker/verifier adapters, not a service.
It reuses RP-03 transactions/outbox, platform credential protection, existing
retention contracts, and existing assurance roots. It signs direct material
observations and checkpoints rather than every event. Retention automation must
keep routine evidence administration within the program's monthly solo-builder
budget and avoid raw-file growth in project Git.

## Git Publication Evidence Profile

For `O` (expected target), `S` (candidate), `V` (verdict), and protected-PR
squash `Q`, the signed terminal chain binds:

- grant reference, issuer, repository/source/target scope, expiry and revocation;
- route decision, route-policy digest, consequence, and history shape;
- `V`, authenticated producer, verifier version/deployment, harness, validation
  inputs/results, and evidence head;
- RP-03 operation/attempt/idempotency/T1 and terminal-reserve identities;
- RP-04 broker request plus RP-05/RP-06 direct provider observation;
- immediate landed `S` or `Q`, historical `O -> S` or PR transition, and an
  independent non-broker post-land observation;
- RP-08 outcome/reconciliation class, preserved-work proof, local-main mirror,
  cleanup authorization/result, and terminal checkpoint/monotonic anchor.

Producer-direct signatures never manufacture authorization, route validity,
effect causation, or cleanup eligibility. Candidate and broker cannot
self-certify the same change. `landed/cleanup-deferred` is signed honestly;
`cleaned` requires the conditional expected-tip result. Raw/detail operational
evidence remains outside project Git.
