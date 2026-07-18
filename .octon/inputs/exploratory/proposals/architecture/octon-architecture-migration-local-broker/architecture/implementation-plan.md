# Implementation Plan

This plan becomes executable only after proposal acceptance and all entry
gates. It does not authorize service installation, credential enrollment, or
an effect.

## Workstream 0 — Freeze Dependencies and Mechanisms

1. Bind the accepted RP-01, RP-02, and RP-03 designs; their exact implementation
   verification remains a future implementation-entry gate.
2. Bind the selected ED-002 macOS 26.5.2 mechanism from
   `resources/broker-ipc-keychain-design-and-dependency-receipt.yml`.
3. Enforce the closed ED-007 census in
   `resources/workflow-visible-surface-census.yml`; preserve
   `policy-grant-broker.sh` under RP-01 and expose exactly one `octon broker`
   normal command concept.
4. Use only sentinel credentials and disposable scratch targets.

## Broker IPC/Keychain Design and Dependency Gate

Before code changes, revalidate the selected Design and Dependency Receipt:

- root-owned LaunchDaemon/dedicated account and XPC MachServices activation;
- mutual XPC peer code-signing requirements, installed identifiers/Team ID/
  cdhash, downgrade/replay/time behavior, and same-user threat limits;
- Keychain item/access-control/enrollment/rotation/revocation mechanism and
  proof that candidate/wrong binaries cannot export the credential;
- operation-handle nonce/MAC/randomness, key custody, lifetime, binding,
  zeroization, and RP-03 atomic consume behavior;
- exact crates/frameworks/FFI, versions, sources, checksums, licenses,
  transitive/native dependencies, compile/link flags, toolchain/macOS support,
  signing/notarization implications, advisories, maintenance/update cadence,
  binary impact, and rollback/removal path;
- protocol schema, message limits, socket/config paths, install/uninstall
  ownership, and compatibility policy; and
- prototypes for wrong/same-UID identity, Keychain canaries, launch restart,
  single instance, store writer, and scratch effect.

The design selects explicit libxpc/Security/CoreFoundation FFI plus pinned
`libc`, `hmac`, `sha2`, and `zeroize` dependencies. Exact Cargo resolution,
framework symbols, signing identity, System Keychain ACL behavior, root-owned
installation, and attack preflight gate source implementation. A failing gate
returns to engineering design; it does not silently select a socket, peer-UID,
ambient-credential, or direct-effect fallback.

## Workstream 1 — Broker Core and Protocol

1. Add one local_broker library/binary with strict config, versioned schemas,
   bounded framing, typed errors, redacted receipts, and closed adapters.
2. Implement broker/client mutual identity and request replay protection before
   any store or Keychain access.
3. Validate RP-01 envelope and use RP-03 T1 to create/consume the internal
   operation handle immediately before dispatch.
4. For publication operations, compare every opaque RP-03-committed tuple field
   and bind the complete tuple digest to the handle without importing RP-06
   route/verdict interpretation into the broker.
5. Ensure no authority-mint, verifier, route-selection, remote-worker,
   arbitrary command, shell,
   or dynamic plugin entry point is linked/reachable.

## Workstream 2 — Keychain Custody and Enrollment

1. Implement secure one-command enrollment with no secret-bearing argv,
   environment, file, SQLite, log, or receipt.
2. Bind credential access to broker/application identity, provider/project/
   account, exact adapter, and selected Keychain policy.
3. Add rotation/revocation/locked-Keychain handling and redacted health checks.
4. Run candidate, trusted-client, same-user, old-binary, child/debug, backup,
   and direct-API canaries.

## Workstream 3 — Store Writer and Scratch Adapter

1. Make the broker the sole normal RP-03 write-connection owner; verify
   schema/epoch/high-water and split-brain exclusion at startup.
2. Host only a reversible disposable scratch adapter in RP-04; real Git/provider
   adapters remain absent.
3. Record T1, handle consume, direct observation, T2 result-or-UNKNOWN, outbox,
   receipt, and cleanup without a verifier verdict.
4. Update FD-015 physical role and authorization coverage inventories through
   their owners and reject unknown writers/effect hosts.

## Workstream 4 — Supervision and Operator Lifecycle

1. Add one launch-service template and exact config/host-adapter declaration.
2. Implement auto-start, single-instance, restart scan, readiness, graceful
   drain, and bounded shutdown with no blind external retry.
3. Add `octon broker setup|status|doctor|repair|upgrade|uninstall` under one
   top-level concept; keep healthy output quiet and repair safe/typed.
4. Instrument setup time, prompts, restart time, recovery steps, and monthly
   maintenance without claiming final integrated burden proof.

## Workstream 5 — Proof and Handoff

1. Run forged/replayed/same-UID IPC, credential canary, single-instance/writer,
   T1/handle/effect/T2 crash, service restart, fresh setup, doctor/repair,
   upgrade/uninstall, rollback, and scratch-effect suites.
2. Retain PO-FD-006/PG-04-CREDENTIAL-BOUNDARY and the RP-04 portion of UE-003.
3. Complete conformance, drift/churn, dependency, surface audit, and rollback
   receipts.
4. Hand a closed effect-host interface to RP-05 and generic outage/attempt state
   to RP-08 without transferring authority, credentials, or verdict ownership.
5. Prove that broker outage or a wrong `O`, `S`, grant, verdict, route-policy,
   source, target, harness, or scope binding denies and preserves the frozen
   operation instead of exposing or selecting PR.

## Parallelization Constraints

- RP-04 starts only after RP-01/RP-02/RP-03 exit and their integration
  interfaces are frozen.
- No production Git/provider effect or real production credential is used in
  tests; fixtures use sentinel credentials and disposable targets only.
- Broker code cannot author authority grants, policy, or verifier verdicts.
- IPC/identity implementer, Keychain implementer, adversarial tester, and final
  trusted integrator are distinct trust-sensitive roles where feasible.
- No RP-05 adapter or RP-08 provider reconciliation semantics enter this child.

## Dependency Discipline

Only the selected macOS IPC/identity, Keychain, cryptographic-handle, and
already-approved RP-03 store dependencies may enter. Any extra daemon,
database, remote worker, credential helper, generic plugin host, network
service, or workflow requires packet revision and completeness review. The
broker must remain one local process with a small closed dependency surface.
