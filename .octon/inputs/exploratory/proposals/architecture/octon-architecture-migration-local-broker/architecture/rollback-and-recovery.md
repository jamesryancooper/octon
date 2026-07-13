# Rollback and Recovery

## Principle

Rollback disables the broker effect route, preserves candidate output, and
uses manual/protected PR. It never restores ambient credentials, candidate
effect access, a second DB writer, direct provider helpers, the ephemeral policy
grant helper as broker, a remote worker, or broker self-verification.

## Prepared Handles

- exact broker/client/config/protocol/dependency/code-identity digests;
- prior certified broker binary and service template satisfying the same
  identity, IPC, Keychain, store, and no-verdict boundary;
- launch-service stop/disable and endpoint revocation procedure;
- Keychain access-policy and non-secret enrollment/rotation/revocation metadata;
- RP-03 certified backup/repair and writer-identity controls;
- operation/attempt/internal-handle/outbox/UNKNOWN inventory;
- candidate commit preservation and protected-PR route; and
- deterministic status, doctor, repair, upgrade, uninstall, and evidence
  commands.

## Recovery by Failure Class

| Failure | Recovery |
| --- | --- |
| Service fails to install/start or identity cannot verify | Keep dispatch/store writes disabled, remove the unusable endpoint safely, preserve diagnostics, repair signing/config/service state, and re-run admission. |
| IPC forgery/replay/same-UID probe succeeds | Treat the tuple as compromised, stop the service, revoke endpoint/client identity and pending handles, retain redacted forensic proof, and block all credentials/effects until redesigned. |
| Credential exposure canary succeeds | Stop broker, revoke/rotate the sentinel or affected credential through its owner, quarantine logs/state, prove deletion/non-retention, and reject the mechanism. |
| Keychain locked, missing, revoked, or access denied | Deny the affected operation, preserve attempt/candidate state, report one recovery action, and never copy the credential to environment/file/SQLite. |
| Duplicate instance or second DB writer appears | Quiesce all writers/effects, preserve RP-03 state, revoke the conflicting service/connection, rerun single-instance/writer proof, and reactivate atomically. |
| Crash before committed T1 | No effect is eligible; restart may accept a fresh authorized request if authority remains current. |
| Crash after T1 or external outcome uncertainty | Preserve ATTEMPTING/UNKNOWN, do not resend, expose status, and hand provider classification to RP-08 when available. |
| T2/receipt/response delivery fails | Recover from canonical operation/attempt/outbox identity; response replay cannot repeat the effect. |
| Doctor or repair cannot certify safe state | Keep effects disabled, preserve evidence and candidate work, and use RP-03 offline recovery or prior certified broker. |
| Upgrade fails | Drain before dispatch, keep pending state visible, and restore only a prior certified broker accepted by the same signer/identity/protocol/Keychain/store boundary. |
| Uninstall interrupted | Keep dispatch disabled, retain pending-state and credential-disposition status, and resume the typed uninstall; never orphan an accessible credential or delete uncertainty. |

## Prior Broker Restore

A previous broker may be restored only if its code identity, protocol,
operation-handle, Keychain access policy, RP-03 schema/epoch, and adapter set
remain accepted and it cannot downgrade replay or same-user resistance. Restore
does not retry ATTEMPTING/UNKNOWN work and cannot re-enable a retired effect
adapter without fresh admission.

## Rollback Drill

Drill stop/disable, endpoint revocation, candidate preservation, protected PR,
prior-broker restore, credential rotation/revocation, store writer transfer,
pending attempt preservation, and safe uninstall at every crash point. Any
identity, secret, writer, outcome, or pending-state uncertainty leaves broker
effects disabled.
