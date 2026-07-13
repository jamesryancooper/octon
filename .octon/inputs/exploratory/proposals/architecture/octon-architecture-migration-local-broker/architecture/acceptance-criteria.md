# Acceptance Criteria

These are future implementation gates. Packet creation satisfies none of the
broker, IPC, Keychain, store-writer, scratch-effect, or recovery proof.

## Entry and Design

- **AC-00:** The three canonical dependencies exit: RP-01 authority/guard
  semantics are frozen, RP-02 useful credentialless isolation passes, and
  RP-03 one-store/writer APIs and recovery primitives pass.
- **AC-01:** ED-001 evidence is bound and ED-002 resolves to exact pinned macOS,
  launch-service, IPC/application-identity, Keychain, code-signing, protocol,
  and dependency mechanisms.
- **AC-02:** A Broker IPC/Keychain Design and Dependency Receipt passes and the
  ED-007 audit proves one `octon broker` concept with no redundant normal-path
  workflow or command surface.

## Identity, IPC, and Authority

- **AC-03:** Broker and client mutually authenticate through OS/application
  identity stronger than same UID; filesystem mode, PID, UID, caller fields,
  or socket possession alone never pass.
- **AC-04:** Wrong binary/signature/designated requirement, candidate process,
  arbitrary same-UID process, stale client, symlink/replaced socket, version
  downgrade, oversized/malformed message, nonce reuse, clock skew, and forged
  identity all deny before credential/store/effect access.
- **AC-05:** Replayed, duplicated, expired, revoked, wrong-epoch, wrong-store,
  wrong-client, wrong-adapter, wrong-scope, replaced-target, and already-used
  operation handles deny and leave no send-eligible second attempt.
- **AC-06:** Static/dynamic call-graph proof finds no authority mint/renew/widen
  or policy evaluation path reachable from broker request handling.
- **AC-07:** Broker receipts and observations are explicitly non-verdict; no
  broker identity can satisfy RP-06 verifier gates.
- **AC-07A:** For the later publication vertical, the broker structurally
  validates equality of every field in RP-03's one canonical complete T1 tuple
  plus the selected closed effect's exact precondition, and binds the canonical
  tuple digest to the internal handle. Missing or mismatched fields deny before
  credential access or adapter invocation; RP-01 independently validates guard
  expiry and revocation.
- **AC-07B:** The broker cannot interpret the route predicate, mint or replace
  `V`, select PR, change `O` or `S`, or turn broker outage, invalid authority,
  collision, `ATTEMPTING`, or `UNKNOWN` into another route.

## Credential Boundary

- **AC-08:** Setup enrolls a sentinel credential in the selected Keychain class
  without exposing it in argv, environment, files, SQLite/WAL, IPC logs,
  receipts, status/doctor, crash output, retained evidence, or project Git.
- **AC-09:** Candidate, trusted client, arbitrary same-user process, old/wrong
  broker binary, backup/restore, projection, debugger/child process, helper,
  and direct Keychain/API probes cannot read or export the credential.
- **AC-10:** Only the admitted broker can request the exact credential for the
  exact adapter/project/account binding; rotation/revocation/locked-Keychain
  failure denies without an ambient fallback.

## Store, Effect, and Supervision

- **AC-11:** Exactly one service instance, IPC endpoint owner, and RP-03 write
  connection exist; split-brain, duplicate launch, stale process, and direct
  writer attempts fail closed.
- **AC-12:** The scratch adapter receives only a consumed internal handle and
  the minimum non-exportable credential capability; it cannot read arbitrary
  Keychain entries, mint authority, open a second store, or invoke another
  adapter.
- **AC-13:** One exact reversible disposable scratch effect completes with T1,
  internal handle consumption, external attempt, T2, receipt, and cleanup; no
  production Git/provider target is touched.
- **AC-14:** Kill before/after IPC auth, T1, handle creation/consumption,
  credential access, external send, T2, receipt, and response leaves one
  explicit state and never repeats an uncertain effect.
- **AC-15:** Launch service auto-starts, rejects duplicate instances, returns a
  healthy admitted instance within the proved recovery budget, and scans
  pending state without provider-specific inference.

## Operations and Recovery

- **AC-16:** Fresh-machine `setup` installs/enrolls/starts/verifies in one guided
  command; subsequent healthy runs require no prompt or babysitting.
- **AC-17:** `status`, `doctor`, and `repair` distinguish endpoint, identity,
  Keychain, store, pending-attempt, adapter, configuration, and version faults;
  repair cannot bypass RP-03 certification or delete uncertainty.
- **AC-18:** Upgrade rejects identity/protocol/store incompatibility and safe
  uninstall refuses pending work, preserves evidence, and disposes credentials
  only through an explicit protected route.
- **AC-19:** Disabling the broker preserves candidate output and frozen route
  state; restoring a prior certified broker preserves the same IPC/store/
  credential boundary and cannot downgrade identity. Any later PR is a fresh
  RP-06 pre-effect decision, never recovery of the failed broker effect.

## Proof and Closeout

- **AC-20:** PO-FD-006 passes PG-04-CREDENTIAL-BOUNDARY and UE-003 joins RP-02's
  useful positive evidence with all RP-04 credential/IPC negatives.
- **AC-21:** RP-04's FD-015 broker-role inventory and FD-016 restart/outage
  substrate are directly evidenced without claiming RP-00 inventory closure or
  RP-08 complete degraded-operation closure.
- **AC-22:** RF-005 and RF-025 resolve for RP-04; RF-004 remains correctly
  cross-referenced to RP-02's candidate boundary contribution.
- **AC-23:** Implementation conformance and post-implementation drift/churn
  receipts pass before `implemented` or implemented archival is claimed.
