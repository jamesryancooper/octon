# Target Architecture

## Target State: SI-04 Supervised Broker with One Scratch Effect

One signed/pinned local broker executable runs as the root-installed launchd
Mach service `com.octon.local-broker.v1`, under a dedicated non-login `_octon`
runtime identity outside the candidate sandbox. Root-owned installed files and
mutual XPC code-signing requirements protect the service boundary from same-UID
replacement. The broker owns System Keychain credential access, the sole normal
RP-03 database write connection, and a closed effect-adapter registry. The
minimum vertical contains only a disposable scratch adapter; no remote worker
or production publication exists.

## Process and Identity Boundary

`resources/broker-ipc-keychain-design-and-dependency-receipt.yml` selects the
exact macOS 26.5.2 mechanism:

- root-owned LaunchDaemon, dedicated `_octon` identity, launchd MachServices
  endpoint, and single-instance lifecycle;
- both peers apply `xpc_connection_set_peer_code_signing_requirement` before
  activation, binding identifiers, installation Team ID, and enrolled cdhash;
- setup derives signing facts through Security.framework and stores only their
  digests/requirements in root-owned configuration;
- endpoint ownership/mode as defense in depth, never the sole check;
- mutual protocol version and challenge/nonce binding, bounded request size,
  monotonic expiry, and connection/request replay defense;
- exact allowed trusted client identity; RP-02 candidates and arbitrary
  same-user processes are excluded; and
- fail-closed behavior when code identity, signing, time, endpoint, or service
  state is unverifiable.

Same UID, endpoint reachability, or executing an untrusted copy is never
sufficient. Unsigned/ad-hoc binaries, wrong requirements, an unsupported host,
or missing signing identity block setup. The candidate cannot satisfy the
trusted kernel-client requirement or the RP-01/RP-03 operation binding.

## Authority and Operation Flow

1. A trusted client obtains RP-01's exact current authority/guard envelope and
   prepares an immutable operation intent.
2. The client connects over authenticated IPC and sends only the versioned
   envelope, operation identity, target digest, and bounded request metadata.
3. The broker authenticates the peer, calls RP-01's frozen validation/consume
   API for scope, expiry, and revocation, and rejects caller-provided widening
   fields. It never reads or evaluates authority policy or canonical authority
   state directly.
4. Through RP-03 T1, the broker consumes the exact guard, reserves terminal
   capacity, creates the operation/attempt and outbox state, and commits
   `ATTEMPTING` before external dispatch.
5. T1 creates a random/MAC-bound broker-internal operation handle containing
   only immutable operation, attempt, epoch, adapter, scope digest, client
   identity, expiry, and single-use state. The handle never leaves the broker,
   cannot create authority, and is consumed immediately before adapter call.
6. The closed adapter performs the exact effect. The broker records its direct
   observation through RP-03 T2 as bounded result or `UNKNOWN`.
7. The broker returns an authenticated receipt. It does not author an
   independent verification verdict or decide provider-specific reconciliation.

An operation handle is a replay barrier and dispatch binding, not a grant. It
is impossible to create a usable handle without an already-valid RP-01 guard
and committed RP-03 row, and it cannot outlive or widen either.

For the later publication vertical, RP-04 accepts only the sealed tuple already
authenticated by the RP-06-owned pre-T1 verdict/route gate, then validates
structural equality of the single canonical complete T1 tuple and digest defined by RP-03's
`brokered_no_pr_compatibility.t1_opaque_bindings`, plus the selected closed
effect's exact precondition. The internal handle binds that canonical digest;
it cannot substitute, omit, or reinterpret any field. RP-01 separately proves
the consumed guard remains valid for expiry and revocation. RP-04 does not
depend directly on RP-06, authenticate or evaluate route/verdict semantics,
mint `V`, or understand PR semantics. RP-03 transports opaque RP-06-owned references without creating a
dependency cycle, and RP-05 receives the already-frozen effect request through
the closed adapter interface.

## Credential Custody and Enrollment

- Durable provider credentials are non-synchronizing generic-password items in
  the macOS System Keychain under a SecAccess ACL restricted to the exact
  installed signed broker. The dedicated `_octon` identity and root-owned
  installation prevent candidate or same-user replacement/access. The pinned
  SecAccess mechanism is re-opened for design review if macOS removes or changes
  its observed behavior.
- Setup receives secret material through a root-owned no-echo inherited pipe,
  never argv, environment, repository file, SQLite field, log, error, receipt,
  crash report, or retained test artifact.
- The store keeps only credential identifier/class/provider/project, access
  policy digest, creation/rotation status, and non-secret health metadata.
- Broker memory holds the minimum value for the minimum duration and applies
  zeroization/locked-memory behavior when the selected mechanism supports it;
  limitations are disclosed rather than overstated.
- Candidate, untrusted same-user process, wrong broker identity, old broker,
  backup, projection, doctor, and uninstall canaries cannot read/export the
  secret.

ED-001 remains independent: the RP-02 primary-provider model session does not
depend on this effect broker. RP-04 consumes that proved boundary to complete
UE-003 and does not create a dependency cycle.

## Supervision, Restart, and Repair

- The launch service owns auto-start and one process instance. Store writer
  identity plus endpoint ownership provide independent split-brain denial.
- Startup verifies executable/config/protocol/dependency/store schema/epoch,
  Keychain binding, socket identity, and adapter registry before becoming ready.
- Restart scans `ATTEMPTING`, `UNKNOWN`, and pending outbox rows. It may resume
  deterministic internal delivery but never resends an uncertain external
  effect or applies provider-specific classification.
- Healthy restart targets five seconds and zero manual steps on the admitted
  tuple; proof, not the proposal, establishes the claim.
- `status` is read-only and compact. `doctor` diagnoses. `repair` performs only
  typed safe repairs backed by RP-03 certification. `upgrade` preserves the
  same identity/protocol/store boundary. `uninstall` refuses pending work and
  handles credential deletion through an explicit safe disposition.

## Roles and Non-Goals

The broker is one FD-015 physical component hosting logical credential-custody,
store-writer, and effect-adapter roles through authenticated internal
interfaces. Consolidation reduces deployed services; it does not merge
authority or verifier roles. The broker:

- never calls an authority-mint path, approves itself, renews a grant, widens a
  scope, changes policy, or treats health as authorization;
- never signs or publishes an independent verifier verdict about its own
  effect; and
- never delegates to a remote worker in SI-04.

## Availability and Solo Experience

Broker absence blocks only the affected consequence, preserves candidate work,
and leaves the selected route frozen. Safe isolated work remains possible where
already admitted. An `ATTEMPTING` or `UNKNOWN` no-PR operation cannot switch to
PR; a later PR requires a fresh RP-06 pre-effect policy decision and fresh
authority after reconciliation. There is no ambient credential/direct-effect
fallback. One setup command and quiet supervision replace persistent operator
ceremony.
