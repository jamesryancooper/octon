# Validation Plan

## Evidence Posture

All proof described here is planned. Future receipts bind exact commit, macOS
build/hardware, broker/client binaries and code identities, launch-service and
config digests, IPC/dependency/protocol versions, Keychain item class and
access-policy digest without secret, store schema/epoch/high-water, operation/
attempt/handle identities, scratch target, commands, times, exits, retained
redacted logs/digests, and evidence classification.

Proposal acceptance authorizes creation of only the accepted exact design.
Before source changes, implementation entry must prove RP-01/RP-02/RP-03
verification, ED-001, exact Cargo resolution, SDK symbols, signing identity,
root-owned installation, dedicated account, System Keychain ACL, and disposable
fixture preflights. All matrices below run against the exact implementation and
gate conformance, completion, cutover, support, or promotion; none gates the
proposal's permission to create its test subject.

## Structural Proposal Validation

- `validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-local-broker`
- `validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-local-broker`
- `validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-local-broker`
- architecture review and strict review-gate validators after real review

## IPC and Identity Attack Matrix

- correct client/broker identity positive handshake and bounded request;
- candidate process, unrelated same-UID process, wrong UID, copied/old/unsigned
  client, wrong/old broker, replaced binary/config/plist/socket, PID reuse, and
  caller-forged identity;
- filesystem-mode-only, socket-possession-only, peer-UID-only, environment,
  symlink, inherited FD, proxy/relay, and child-process attacks;
- malformed/truncated/oversized/unknown-field/version-downgrade frames,
  connection/request floods, slow client, response substitution, and timeout;
- nonce/challenge replay, duplicate request, expired request, clock skew,
  reordered response, reconnect, and captured authenticated transcript;
- every negative denies before Keychain read, DB mutation, handle creation, or
  external adapter call.

## Authority and Handle Matrix

- missing/deny/stale/expired/revoked RP-01 authority; wrong scope, target,
  adapter, project, operation, attempt, client, store, epoch, or high-water;
- for the later publication vertical, omit or mismatch each field in RP-03's
  canonical complete T1 tuple/digest and each closed effect precondition in
  turn; every case denies before credential access or adapter call, while
  expired or revoked RP-01 guard cases deny through the guard validator;
- random/forged/captured/replayed/duplicate/expired/already-consumed handle;
- handle used after grant revocation, process restart, config upgrade, store
  restore, target replacement, or client identity change;
- concurrent N-way same operation and same handle; exactly one can reach the
  adapter and all others retain deterministic denial receipts;
- static/dynamic call census proves request paths cannot reach authority mint,
  route selection, PR selection, policy mutation, verifier verdict, arbitrary
  command, or remote dispatch;
- broker outage, `ATTEMPTING`, and `UNKNOWN` preserve the frozen route and
  candidate; no test can make the broker expose, select, or authorize PR.

## Credential Canary Matrix

Place unique sentinels in Keychain and all prohibited channels, then probe from
candidate, trusted client, arbitrary same-user process, wrong broker binary,
old version, child process, debugger/tool where supported, environment, argv,
files, SQLite/WAL, IPC/log/status/doctor/receipt/crash output, backup,
projection, and project Git. Only the exact admitted broker/adapter binding may
use the needed credential; no test retains or prints its value.

Exercise enrollment, duplicate enrollment, locked Keychain, denied access,
rotation, revocation, stale metadata, missing item, wrong access policy, and
uninstall. Failure never copies a secret to an ambient fallback.

## Store, Instance, and Scratch-Effect Matrix

- duplicate launch, concurrent startup, stale PID/socket, socket activation
  race, old/new version overlap, crash loop, writer lock loss, wrong store,
  schema/epoch mismatch, and repaired/restored store;
- verify one launch label, process, endpoint owner, write connection, and
  adapter host; other direct writers/effect hosts deny;
- exact reversible scratch effect success with T1, handle consume, credential
  capability, direct observation, T2, response, and cleanup;
- wrong scratch target, replaced target, wrong precondition, adapter injection,
  arbitrary command, production-like target, second adapter, and network
  escape deny.

## Crash and Recovery Matrix

Kill before/during/after IPC authentication, authority validation, T1, handle
creation, handle consume, Keychain access, adapter send, observation, T2,
outbox/receipt, response, credential cleanup, graceful drain, service upgrade,
repair, and uninstall. Restart scans committed state, never repeats `UNKNOWN`,
preserves terminal capacity, and records generic status without claiming
provider-specific truth.

Measure cold setup, enrollment prompts, healthy output, auto-start, restart to
ready, doctor diagnosis, safe repair, upgrade, uninstall, protected-PR
rollback, and recurring maintenance. A healthy installed tuple targets restart
within five seconds and zero manual steps; direct measurements control claims.

## Required Evidence

Future evidence under
`.octon/state/evidence/validation/proposals/octon-architecture-migration-local-broker/`
includes ED-001 binding, ED-002 Design and Dependency Receipt, ED-007 audit,
install/enrollment receipts without secrets, IPC/handle/credential attack
results, single-instance/writer census, scratch effect and all crash/restart/
repair results, setup/burden metrics, rollback drill, PO-FD-006/UE-003
dispositions, conformance, and drift/churn review.
