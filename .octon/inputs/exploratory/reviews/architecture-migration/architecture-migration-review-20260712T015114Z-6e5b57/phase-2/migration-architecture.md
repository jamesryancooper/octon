# Migration Architecture

## Target components

### Canonical kernel and authority engine

The kernel owns semantic request construction. authority_engine remains the
sole normal authority issuer. It authorizes exact operations and exact launch
descriptors, not generic string scopes. Descriptors bind operation ID,
project, candidate, run, child identity, executable identity, argv digest,
harness digest, route, resource, expiry, revocation generation, rollback, and
evidence reservation.

### Transactional store

One SQLite database in WAL mode is the authoritative runtime state. A single
writer owns:

- projects and immutable run snapshots;
- decisions, grants, revocation generations, and exact operations;
- launch/effect reservations and one-shot consumption;
- attempts, idempotency keys, provider request identities, unknown outcomes,
  reconciliation observations, terminal results, and rollback;
- evidence-capacity reservations and outbox rows;
- signed checkpoint metadata and retention pins;
- broker/verifier/activator version identity and health.

Legacy JSON/YAML/NDJSON files become generated read models and export evidence.
There is no dual-write compatibility period.

### Isolated launcher

The launcher consumes a launch reservation immediately before spawn. On macOS
it creates a disposable native isolation envelope with:

- fresh HOME and tool configuration;
- environment allowlist and closed inherited file descriptors;
- explicit filesystem, process, and network policy;
- independent candidate Git object database, refs, index, config, hooks root,
  and work directory;
- no GitHub, Git, keychain, SSH, signing, deploy, broker, or verifier keys;
- operation-ID cleanup and crash recovery.

Codex, Claude, workflow leaves, pipelines, and child agents use this same
structural API. Provider-native orchestration is acceptable if it implements
the same contract.

### Local broker

One least-privileged deterministic process owns durable credentials and direct
effect adapters. It accepts only authenticated, exact operation IDs over a
local narrow IPC. It revalidates reservation, source, target, expiry,
revocation, harness, policy, and evidence capacity; atomically transitions to
attempting; performs the effect; and commits result or unknown.

The first adapter is sanitized Git publication. The broker runs Git with an
empty/allowlisted environment, isolated configuration, disabled executable
extensions, explicit transport and URL policy, exact source SHA, exact target
pre-SHA compare-and-swap, and fast-forward-only update.

### Independent verifier

The verifier never performs the effect. It observes provider state and
required checks for the exact candidate SHA and target transition using
immutable code selected independently of the candidate. It signs repository,
source SHA, target pre/post SHA, policy/verifier version, observation time,
expiry, and result. Provider-required check names alone are insufficient.

### Evidence and recovery

Broker and verifier sign only direct observations. The outbox is committed
with state transitions. A projector emits human-readable receipts and
hash-linked journals. Signed terminal checkpoints allow raw event compaction.
Low-space state prevents new privileged operations while preserving space for
denial, failure, revocation, rollback, and closeout.

### Projects, harnesses, extensions, agents

Workspace Project supplies stable non-authoritative identity and boundaries.
Project Profile is inferred descriptive input. Harness Factory deterministically
compiles project, profile, context, route, extension generation, effect policy,
and verifier policy into a digest-bound manifest. Extensions enter through a
private signed pinned catalog. Child agents inherit a narrowed mission
snapshot, never authority or credentials.

### Trust-root activation

Trust-root candidates are immutable inert versions. The installed previous
version verifies the candidate with an independent exact digest and accepted
proof, then a preauthorized activator stages the exact version, observes a
bounded health window, commits the active pointer, or automatically restores
the previous version. Candidate changes to verifier, activation, rollback,
signer, or authority-expansion rules are not evaluated by candidate code.

## Core effect state machine

requested → authorized → reserved → attempting → succeeded

attempting may transition to unknown, then reconciling, then succeeded,
failed, denied, revoked, or rolled_back. Retry creates a new attempt under the
same idempotency key only after observation proves no completed effect. No
state transition restores consumed or revoked authority.

## Authority boundaries

- Project, profile, harness, extension, evidence, and provider projections
  never mint authority.
- Broker performs but does not authorize.
- Verifier attests but does not perform or authorize.
- Activator activates only an independently verified exact version under a
  preauthorized envelope.
- GitHub may be an effect worker but never the canonical ledger, broker, or
  authority source.

