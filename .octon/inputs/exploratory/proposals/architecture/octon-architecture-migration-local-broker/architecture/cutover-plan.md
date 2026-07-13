# Cutover Plan

## Preconditions

- RP-01, RP-02, and RP-03 exit with fresh evidence and frozen integration APIs.
- ED-001 useful primary-provider isolation and candidate credential/IPC
  negatives pass.
- ED-002 exact macOS IPC/application-identity, launch service, Keychain,
  operation-handle, signing, protocol, and dependency mechanisms pass the
  Design and Dependency Gate.
- ED-007 audit approves one visible `octon broker` command concept and records
  the non-repurposing disposition of existing helper surfaces.
- Proposal acceptance, implementation-grade completeness, and independent
  architecture review pass.
- Sentinel credentials, disposable scratch target, prior certified broker
  rollback artifact, protected-PR path, and exact repo/store baselines exist.

## Default-Disabled Preparation

1. Build/sign/pin the broker and client tuple; validate config, schemas,
   launch-service template, dependencies, and host adapter.
2. Install the service and endpoint in diagnostic-only mode with effect
   dispatch and store writes disabled.
3. Prove mutual identity, candidate/same-UID denial, single instance, redacted
   status/doctor, and launch restart.
4. Enroll only a sentinel scratch credential through the secure path and run
   the full credential-access/exposure canary matrix.
5. Open a disposable RP-03 store as sole writer and execute every crash/restart/
   repair case without an external production target.

## Atomic Broker Transition

1. Quiesce all store/effect paths and verify no other live write connection or
   credentialed effect host exists.
2. Activate the broker identity as the sole normal RP-03 writer and revoke all
   former normal write routes; there is no dual-writer interval.
3. Enable only the compiled disposable scratch adapter and one exact operation
   class; all Git/provider/remote adapters remain absent/denied.
4. Execute one authorized scratch operation through IPC, T1, internal handle,
   credential capability, adapter, T2, receipt, and cleanup.
5. Kill/restart at every boundary; verify UNKNOWN is never resent, pending
   state is visible, and the service returns healthy within measured budget.
6. Verify one-command fresh setup, quiet healthy status, doctor/repair,
   compatible upgrade, safe uninstall refusal, and rollback to protected PR.
7. Publish ED-002/ED-007, role inventory, PO-FD-006/UE-003, scratch-effect,
   rollback, conformance, and drift receipts.

## Safe Resting State

At SI-04, one supervised broker holds sentinel/non-production credential
custody, is the sole store writer/effect host, and can perform one disposable
scratch effect. Production Class B publication, Git effects, remote workers,
and broker-authored verdicts remain prohibited. The system can pause here with
candidate work preserved and protected PR available.

## Handoff

- RP-05 receives the closed adapter interface, internal handle/attempt binding,
  and scratch proof; it supplies sanitized Git semantics separately.
- RP-07 receives direct broker observation/outbox facts but owns signing,
  checkpoints, retention, and final capacity policy.
- RP-08 receives restart scan and generic ATTEMPTING/UNKNOWN/outage state but
  owns provider classification, retry, manual intervention, and full FD-016.
- RP-06 receives no broker credential or self-verdict; verifier identity stays
  separate.

Handoffs cite retained redacted evidence by digest and never transfer
credentials, authority-mint ability, store ownership, or verifier identity.
