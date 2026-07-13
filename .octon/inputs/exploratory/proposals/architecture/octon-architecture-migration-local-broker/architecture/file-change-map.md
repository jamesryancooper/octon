# File Change Map

All entries are planned, not implemented. RP-04 owns the broker process,
protocol, custody, operation-handle, supervision, lifecycle UX, and scratch
adapter. Shared authority, store, inventory, policy, and adapter contracts may
change only at allocated integration symbols after their owners approve.

| Durable promotion target | Current assumption | Required RP-04 change | Ownership and rationale |
| --- | --- | --- | --- |
| `.octon/framework/engine/runtime/crates/Cargo.toml` | Workspace has no local_broker member or reviewed macOS IPC/Keychain dependencies. | Register the crate and only dependencies accepted by the future Design and Dependency Receipt. | RP-04 dependency gate; no remote service stack. |
| `.octon/framework/engine/runtime/crates/Cargo.lock` | No broker dependency graph is locked. | Lock exact accepted transitive/native inputs and verify review identity. | Derived durable lock. |
| `.octon/framework/engine/runtime/crates/local_broker/Cargo.toml` | Broker crate is absent. | Define one library/binary, closed features, RP-01/RP-03 clients, and test-only scratch support. | Planned new RP-04 crate. |
| `.octon/framework/engine/runtime/crates/local_broker/src/main.rs` | No broker executable entrypoint exists. | Start only after config/identity/store/Keychain/adapter readiness and run the bounded service loop. | RP-04 process owner. |
| `.octon/framework/engine/runtime/crates/local_broker/src/lib.rs` | No broker library surface exists. | Expose only reviewed client/service/types and keep authority-mint/verifier APIs unreachable. | RP-04 module boundary. |
| `.octon/framework/engine/runtime/crates/local_broker/src/config.rs` | No strict broker config loader exists. | Validate paths, identities, protocol, signing, store, Keychain, service, adapters, and fail-closed defaults. | Planned new module. |
| `.octon/framework/engine/runtime/crates/local_broker/src/ipc.rs` | No bounded authenticated broker protocol exists. | Implement framing, mutual handshake, challenge/nonce, expiry, replay cache, limits, and typed responses. | Planned new module. |
| `.octon/framework/engine/runtime/crates/local_broker/src/identity.rs` | Same-user-resistant application identity is absent. | Bind OS peer/audit identity, code requirement, broker/client identity, and downgrade/replacement denial. | Planned new module; exact mechanism gated. |
| `.octon/framework/engine/runtime/crates/local_broker/src/keychain.rs` | No broker-exclusive Keychain custody/enrollment exists. | Add secure enroll/access/rotate/revoke/delete with redaction and wrong-identity denial. | Planned new module; no secret persistence elsewhere. |
| `.octon/framework/engine/runtime/crates/local_broker/src/operation.rs` | No broker-internal one-shot dispatch handle exists. | Create/validate/consume a non-widening handle bound to RP-01 guard and the complete RP-03-committed operation/attempt/epoch/client/effect-tuple digest, including opaque route and verdict references. | Planned new module; handle is not authority and cannot interpret RP-06 policy. |
| `.octon/framework/engine/runtime/crates/local_broker/src/store.rs` | No broker owns the sole normal RP-03 write connection. | Open/verify the canonical store as the admitted writer and wrap only frozen T1/T2/outbox/health APIs. | Planned integration module; schema remains RP-03-owned. |
| `.octon/framework/engine/runtime/crates/local_broker/src/effects.rs` | No closed local adapter host or scratch effect exists. | Host only explicitly compiled/admitted adapters; implement one reversible disposable scratch adapter for proof. | Planned new module; RP-05 owns Git later. |
| `.octon/framework/engine/runtime/crates/local_broker/src/supervision.rs` | No launch-service lifecycle or single-instance readiness exists. | Bind launch-service activation, endpoint ownership, one instance, readiness, drain, and shutdown. | Planned new module. |
| `.octon/framework/engine/runtime/crates/local_broker/src/recovery.rs` | No restart scan/dispatch or safe repair exists. | Scan RP-03 state, resume deterministic internal work, preserve UNKNOWN, and expose typed repair without provider inference. | Planned new module; RP-08 owns classification. |
| `.octon/framework/engine/runtime/crates/local_broker/src/health.rs` | No redacted broker health model exists. | Diagnose binary/config/protocol/identity/Keychain/store/adapter/pending-state health without leaking secrets or authorizing. | Planned new module. |
| `.octon/framework/engine/runtime/crates/local_broker/src/receipts.rs` | No broker-local redacted receipt writer exists. | Emit schema-bound install, enrollment, lifecycle, IPC denial, operation, restart, repair, and uninstall facts. | Planned new module; receipts are evidence, not verdicts. |
| `.octon/framework/engine/runtime/crates/local_broker/tests/broker.rs` | No integrated service boundary tests exist. | Add hermetic IPC/identity/credential/store/scratch/restart/repair tests on disposable state. | Planned new integration suite. |
| `.octon/framework/engine/runtime/crates/kernel/Cargo.toml` | Kernel has no broker client dependency. | Add the local_broker client library only; it receives no credential or store write access. | RP-04 operator/client seam. |
| `.octon/framework/engine/runtime/crates/kernel/src/main.rs` | No `octon broker` command group exists. | Add one top-level broker lifecycle concept with bounded subcommands. | RP-04 UX; ED-007 audited. |
| `.octon/framework/engine/runtime/crates/kernel/src/commands/mod.rs` | Dispatch has no broker lifecycle route. | Route broker commands to the typed client/admin implementation without in-process credential/effect fallback. | Shared CLI integration. |
| `.octon/framework/engine/runtime/crates/kernel/src/commands/broker.rs` | No broker CLI implementation exists. | Add setup/enrollment, status, doctor, repair, upgrade, and uninstall client/admin flows. | Planned new RP-04 command module. |
| `.octon/framework/engine/runtime/config/local-broker.yml` | No repo-owned broker config exists. | Declare protocol/service/client identities, store class, Keychain policy refs, closed adapter list, health/restart, and receipt roots. | Planned new durable config; no secret or host path authority. |
| `.octon/framework/engine/runtime/config/macos/com.octon.local-broker.plist` | No launch-service template exists. | Add the pinned LaunchAgent/service template with minimal environment, endpoint activation, restart, logging, and resource posture. | Planned host template; installed state is external. |
| `.octon/framework/engine/runtime/adapters/host/macos-local-broker.yml` | No broker host adapter declaration exists. | Declare admitted macOS identity, IPC, Keychain, supervision, store, and unsupported capabilities. | Planned host binding; not an authority source. |
| `.octon/framework/engine/runtime/spec/execution-authorization-v1.md` | Defines typed effects but not the broker consumer/handle boundary. | Document broker consumption, derivative-handle non-authority, and no mint/verdict rules without changing RP-01 semantics. | RP-01 contract owner with RP-04 integration text. |
| `.octon/framework/engine/runtime/spec/material-side-effect-inventory.yml` | No implemented broker/store-writer/scratch-host identities exist. | Register one physical broker and its authenticated logical roles/interfaces after implementation. | RP-00 inventory owner; RP-04 supplies exact role facts. |
| `.octon/framework/engine/runtime/spec/authorization-boundary-coverage.yml` | Broker IPC/handle/adapter launch surfaces are absent. | Register client entry, authority verifier, T1/handle/dispatch/T2, denial receipts, and prohibited bypasses. | Coverage owner with RP-04 surface facts. |
| `.octon/framework/engine/runtime/spec/local-broker-v1.md` | No canonical broker contract exists. | Define process, identity, IPC, custody, handle, store, adapter, supervision, lifecycle UX, outage, and non-authority rules. | Planned new RP-04 contract. |
| `.octon/framework/engine/runtime/spec/local-broker-config-v1.schema.json` | No config schema exists. | Validate exact identities, refs, protocol, paths/classes, Keychain policy, store, adapters, and service posture. | Planned new runtime schema. |
| `.octon/framework/engine/runtime/spec/local-broker-ipc-request-v1.schema.json` | No typed request envelope exists. | Validate bounded authority/operation refs, complete effect-tuple digest, target digest, client/challenge/nonce/expiry, and no secret/widening fields. | Planned new runtime schema; downstream policy/verdict refs remain opaque. |
| `.octon/framework/engine/runtime/spec/local-broker-ipc-response-v1.schema.json` | No typed authenticated response exists. | Validate disposition, operation/attempt/receipt refs, generic observation, denial, retry prohibition, and redaction. | Planned new runtime schema. |
| `.octon/framework/engine/runtime/spec/broker-operation-handle-v1.schema.json` | No derivative dispatch-handle schema exists. | Validate immutable bindings, single-use/expiry, store epoch, client/adapter/scope digests, and explicit non-authority. | Planned new runtime schema. |
| `.octon/framework/engine/runtime/spec/broker-credential-enrollment-receipt-v1.schema.json` | No safe enrollment receipt exists. | Record non-secret identity/class/policy/result/rotation metadata and forbid credential value fields. | Planned new runtime schema. |
| `.octon/framework/engine/runtime/spec/broker-lifecycle-receipt-v1.schema.json` | No setup/start/restart/doctor/repair/upgrade/uninstall receipt exists. | Validate lifecycle fact, versions/identities, pending-state disposition, evidence refs, and non-authority. | Planned new runtime schema. |
| `.octon/framework/constitution/contracts/runtime/family.yml` | Runtime catalog has no broker schema family. | Register governed schemas and ownership/relationship metadata. | Constitutional owner. |
| `.octon/framework/constitution/contracts/runtime/local-broker-config-v1.schema.json` | Constitutional config mirror is absent. | Add governed mirror and parity validation. | Contract owner. |
| `.octon/framework/constitution/contracts/runtime/local-broker-ipc-request-v1.schema.json` | Constitutional request mirror is absent. | Add governed mirror. | Contract owner. |
| `.octon/framework/constitution/contracts/runtime/local-broker-ipc-response-v1.schema.json` | Constitutional response mirror is absent. | Add governed mirror. | Contract owner. |
| `.octon/framework/constitution/contracts/runtime/broker-operation-handle-v1.schema.json` | Constitutional handle mirror is absent. | Add governed mirror preserving explicit non-authority. | Contract owner. |
| `.octon/framework/constitution/contracts/runtime/broker-credential-enrollment-receipt-v1.schema.json` | Constitutional enrollment mirror is absent. | Add governed secret-excluding mirror. | Contract owner. |
| `.octon/framework/constitution/contracts/runtime/broker-lifecycle-receipt-v1.schema.json` | Constitutional lifecycle mirror is absent. | Add governed mirror. | Contract owner. |
| `.octon/framework/constitution/contracts/adapters/host-adapter-v1.schema.json` | Host schema cannot validate broker native-service capabilities. | Add minimal IPC/identity/Keychain/supervision/store-writer declarations and fail privilege widening. | Adapter contract owner. |
| `.octon/instance/governance/policies/mission-autonomy.yml` | General outage/safing posture does not bind the proved broker failure route. | Add the narrow FD-016 broker-outage substrate: block affected consequence, preserve work, auto-restart, never ambient fallback. | Instance policy owner; RP-08 retains complete degraded mode. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-material-side-effect-inventory.sh` | Cannot validate future broker role topology. | Require one registered broker/store-writer/effect-host and reject unknown/duplicate roles. | Existing owner with RP-04 facts. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-authorization-boundary-coverage.sh` | Cannot check broker IPC/handle dispatch coverage. | Enforce all new physical entry/dispatch points and negative bypass fixtures. | Existing owner with RP-04 facts. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-authorized-effect-token-enforcement.sh` | Validates in-process consumers, not the broker boundary. | Prove broker consumes current exact authority and its handle cannot replace or widen it. | RP-01 validator owner with RP-04 consumer proof. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-execution-governance.sh` | Does not prove broker-only credentials/effects/store writing or outage fallback. | Add role, fallback, helper non-repurposing, and no broker-verdict checks. | Shared governance validation. |
| `.octon/framework/assurance/runtime/_ops/scripts/validate-local-broker.sh` | No broker structure/evidence validator exists. | Add deterministic config/schema/identity/receipt/writer/credential/attack/restart/scratch checks. | Planned new RP-04 validator. |
| `.octon/framework/assurance/runtime/_ops/tests/test-local-broker.sh` | No full boundary driver exists. | Run IPC, Keychain canary, single-instance/writer, crash/restart, lifecycle UX, rollback, and scratch-effect suites. | Planned new RP-04 test driver. |
| `.octon/framework/assurance/runtime/_ops/fixtures/local-broker/` | No malicious client/credential/service/store/scratch fixtures exist. | Add forged/replay/same-UID clients, sentinel Keychain, replaced endpoint, crash points, and disposable effect target. | Planned new fixtures; no production secret/effect. |
| `.octon/state/evidence/validation/proposals/octon-architecture-migration-local-broker/` | No RP-04 implementation evidence exists at creation. | Retain design/dependency, install/enrollment, attack, credential, writer, effect, restart/repair, UX, rollback, conformance, and drift receipts. | Evidence-only; never credential or authority. |

## Affected but Excluded Surfaces

- Installed LaunchAgent/service state, sockets, audit tokens, code-signing/
  notarization state, Keychain items, process state, store connections, and
  credential values are deployment-local and never promotion targets.
- RP-03 database/WAL/schema is consumed, not modified by RP-04.
- RP-02 candidate/session state, RP-05 Git adapter, RP-06 verifier, RP-08
  provider reconciliation, and any remote worker remain excluded.
- `policy-grant-broker.sh` and its overview are existing helper-owned surfaces;
  RP-04 audits and explicitly rejects repurposing rather than editing them into
  the broker.

## Collision Rule

Shared RP-01 authority, RP-00 inventory, RP-03 store, host adapter, or instance
policy files require exact symbol/section allocation and owner review. If that
cannot be achieved, implementation stops and this packet is revised.
