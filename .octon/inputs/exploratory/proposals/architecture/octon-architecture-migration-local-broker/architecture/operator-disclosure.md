# Operator Disclosure

## What Changes After Future RP-04 Implementation

- One local supervised broker becomes the only normal process that holds
  durable effect credentials and writes the runtime store.
- Trusted Octon runtime clients request exact already-authorized operations over
  authenticated IPC; candidates and arbitrary same-user processes cannot.
- Broker restart, pending-state scan, status, doctor, and safe repair become
  local runtime behavior rather than manual file or credential handling.
- The first admitted effect is reversible and disposable only. Production Git
  or publication remains unavailable until later packets pass.

## One-Command Quiet Experience

`octon broker setup` performs one guided install and secure enrollment, starts
the service, and verifies health. Secret entry may require one explicit secure
enrollment interaction; it is never passed on a command line. Healthy operation
then requires zero routine prompts, service restarts, or manual reconciliation.

`octon broker status` is short and read-only. `doctor` explains endpoint,
identity, Keychain, store, pending-operation, adapter, config, and version
health. `repair`, `upgrade`, and `uninstall` are advanced lifecycle actions
under the same command concept, not new everyday workflows. ED-007 rejects
surface duplication and keeps raw diagnostics out of the normal path.

## Failure Experience

If the broker is unavailable or unsafe, Octon blocks only the affected
consequence, preserves candidate work, and offers manual/protected PR. It does
not reveal credentials, start another writer, invoke direct helpers, blindly
retry an unknown effect, or ask the operator to babysit a daemon. Restart aims
to recover automatically on proved tuples; irreducible uncertainty is shown
once with one safe action.

## Support Claim

RP-04 can support only the exact macOS broker/client/service/IPC/Keychain/
store/scratch-adapter tuple that passes every identity, credential, writer,
crash, setup, and repair proof. A healthy-process check alone is insufficient.
No production effect, remote worker, universal exactly-once, or verifier claim
follows from SI-04.

## Existing Helper

`policy-grant-broker.sh` remains an ephemeral deny-by-default grant helper. It
is not the supervised credential broker and is not repurposed. Similar naming
does not imply shared authority, IPC, custody, store, effect, or support status.

## What This Packet Does Not Provide

RP-04 does not mint authority, classify policy, provide the candidate model
session, define SQLite transactions, implement sanitized Git, verify exact SHA,
sign final evidence, classify provider outcomes, provide a remote worker, or
complete Class B publication/degraded operation. It creates no new operator
policy decision and no second control plane.
