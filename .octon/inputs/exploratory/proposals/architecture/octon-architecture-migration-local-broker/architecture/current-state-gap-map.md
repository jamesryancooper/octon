# Current-State Gap Map

## Baseline

The fixed reconciliation baseline is
`c5b1f5760c78ff521cca6b054e4e8fef5300505b`. Creation reinspection uses
`d78ee8b42cb3a39557bbe39b66cb5d156946172a`; no RP-04 broker process, IPC,
Keychain integration, launch service, or accepted scratch-effect proof exists.

## Material Gaps

| Gap | Current evidence | Required RP-04 correction | Adjacent owner |
| --- | --- | --- | --- |
| No accepted broker boundary | Runtime crates contain no local-broker executable or service owning credentials, store writes, and effect adapters. | Add one supervised deterministic broker process that consumes authority and hosts the sole normal write/effect boundary. | RF-005 primary. |
| Existing helper is not the broker | `policy-grant-broker.sh` evaluates policy and writes ephemeral grant JSON; it has no process identity, IPC, Keychain custody, sole DB writer, adapter host, or restart recovery. | Explicitly reject repurposing; build RP-04 against frozen RP-01/RP-03 interfaces. | RP-01 owns authority; ED-007 audits visible surfaces. |
| No authenticated local IPC | Current repository has no admitted broker socket/XPC protocol or peer application-identity check. | Apply ED-002 using a reviewed macOS mechanism stronger than same UID, with mutual identity, nonce/expiry, replay denial, and exact request schemas. | RP-04 primary. |
| No durable credential custody boundary | No repo-native broker Keychain enrollment/access contract proves that candidate or other same-user processes cannot read/export secrets. | Store durable credentials only through broker-bound Keychain access control; retain metadata/receipts without secret material. | RP-02 proves candidate-side denial; RP-04 owns custody. |
| No store-bound one-shot dispatch handle | Current authorized-effect tokens exist, but there is no broker-internal handle bound to one committed RP-03 operation/attempt and authenticated client. | Derive and atomically consume a non-widening internal handle immediately before adapter dispatch. | RP-01 authority and RP-03 T1 remain prerequisites. |
| Publication tuple compatibility is implicit | The broker packet predates the exact `O`/`S`/grant/route/`V` publication tuple and could otherwise appear free to interpret downstream policy. | Bind the complete RP-03-committed tuple digest to the one-shot handle, validate only structural equality, and prohibit route/verdict interpretation or PR selection. | RP-03 commits opaque references; RP-06 owns policy and verdict; RP-05 owns Git primitives. |
| No sole deployed store writer | Current state is file-oriented and no broker process owns a unique database write identity. | Consume RP-03's one store API as the only normal deployed connection owner; deny all other writers. | RP-03 owns schema/API. |
| No supervision or restart scan | No local launch service, single-instance enforcement, bounded restart, or attempt scan/dispatch exists. | Install one supervised service; on restart scan committed states, never repeat UNKNOWN, and return healthy within the proved budget. | RP-08 later owns provider reconciliation policy. |
| Broker lifecycle UX is absent | Kernel has general doctor/status surfaces but no setup/enrollment/status/doctor/repair/upgrade/uninstall broker path. | Add one `octon broker` command concept with quiet healthy behavior and actionable failure output. | ED-007 audit prevents surface proliferation. |
| No safe real-boundary effect proof | Existing effects do not prove the new broker IPC/custody/store boundary and production effects are forbidden before later packets. | Use an exact reversible disposable scratch adapter and target only. | RP-05 owns real Git effect. |

## Preserved Primitives

- RP-01 canonical grants, typed authorized effects, exact one-shot guards,
  revocation, scope, expiry, and denial reasons;
- RP-02 isolated candidate, independent repository, credential canaries, and
  useful provider-native session independent of the broker;
- RP-03 schema, T1/T2/UNKNOWN/outbox, epoch, capacity, backup, and repair APIs;
- existing process-safe receipt, lifecycle, material-effect inventory, and
  host-adapter validation concepts;
- candidate preservation and a separately preclassified protected-PR route;
  broker failure never converts the frozen operation into PR.

## Removed or Demoted Behavior

- ambient environment, CLI credential store, candidate Keychain access, or
  repository credential file as durable credential custody;
- same UID or socket filesystem mode as sufficient client identity;
- caller-supplied fields, IPC request, operation handle, or broker process as
  authority;
- multiple effect processes or store writers in the minimum local vertical;
- candidate/direct provider effects, remote worker, broker self-verification,
  production Git/GitHub scratch proof, or ambient fallback;
- routine daemon babysitting and repeated setup/approval prompts.

## Unresolved Engineering Inputs

ED-002 fixes the default direction but not the exact macOS IPC/audit-token/code-
identity, launch-service/socket activation, Keychain access-control/enrollment,
code-signing, protocol-crypto, or Rust/FFI dependency mechanisms. Those require
a future Broker IPC/Keychain Design and Dependency Receipt. This is an
engineering gate, not a new operator decision.
