# Supervised Local Broker and Credential Custody

This is the in-review RP-04 architecture proposal for Octon's one unattended local
privilege boundary. A supervised macOS broker validates RP-01 authority,
operates outside the RP-02 candidate boundary, holds durable credentials in
Keychain, is the sole normal RP-03 store writer and effect-adapter host, and
recovers without routine operator intervention.

Packet creation is planning only. It does not install a service, access
Keychain, create IPC, hold a credential, open the runtime database, consume an
operation, or perform an effect.

## Intended Outcome

- One launch-service-supervised broker process and one authenticated local IPC
  protocol; no remote worker in the minimum vertical.
- Client and broker identity verification stronger than filesystem ownership
  or same UID alone, plus nonce, expiry, epoch, and replay protection.
- Broker-exclusive Keychain credential custody and enrollment with no secret in
  argv, environment, logs, receipts, SQLite, project Git, or candidate state.
- One-shot internal operation handles bound to an already-authorized RP-01
  guard and committed RP-03 operation/attempt; the broker cannot widen them.
- Auto-start, single-instance, bounded restart scan, status, doctor, repair,
  upgrade, and safe uninstall under one quiet `octon broker` command concept.
- One exact disposable scratch effect proving the boundary without production
  Git/provider mutation or a verifier role.

## Packet Status

- proposal status: `in-review`
- release state: `pre-1.0`
- change profile: `atomic`
- parent program: `octon-architecture-migration-program`
- dependencies:
  - `octon-architecture-migration-canonical-authority`
  - `octon-architecture-migration-candidate-isolation`
  - `octon-architecture-migration-transactional-runtime-store`

The packet is ready for operator reading, not implementation. ED-002's exact
IPC/application-identity, launch service, Keychain access-control, code-signing,
and dependency choices require a passing Design and Dependency Receipt. ED-001
useful isolation and the three child dependencies must be proved; ED-007's
visible-surface audit, proposal acceptance, and independent review must pass.

## Normal Solo-Builder Experience

Setup is one guided command that installs the local service, enrolls credentials
without exposing them to the candidate, and confirms health. After that the
broker starts and restarts automatically and stays silent when healthy.
`octon broker status` gives a compact answer; `doctor` and `repair` appear only
when needed. There is no approval prompt per effect and no daemon babysitting.

## Ownership Boundary

RP-01 mints authority and exact guards; RP-04 only validates and consumes them.
RP-02 owns candidate isolation and its independent provider session. RP-03
owns the transactional schema/API; RP-04 is the sole normal deployed writer.
RP-05 and later packets own real privileged adapters. RP-06 owns verifier
verdicts. RP-08 owns provider-specific reconciliation and complete degraded
operation. RP-04 records generic observations and outage substrate only.

The existing `policy-grant-broker.sh` is explicitly not this broker. It is an
ephemeral policy-grant helper that writes grant files; repurposing it would
create ambiguous authority, no process identity, no Keychain custody, no sole
store writer, and no supervised effect boundary.

## Exit Shape

After accepted implementation and direct proof, RP-04 may close only when
PO-FD-006 passes PG-04-CREDENTIAL-BOUNDARY, UE-003's shared evidence is
complete, only the broker holds durable credentials and a DB write connection,
the full IPC/replay/same-UID attack matrix denies, scratch-effect restart and
repair pass, and conformance plus drift reviews pass.
