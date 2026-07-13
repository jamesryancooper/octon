# Proposal Reading and Precedence Map

## Authority Boundary

Current constitutional, product, runtime, and instance governance outrank this
packet. The intake, reconciliation, parent program, Revision 2 proposal, this
packet, launchd state, Keychain state, IPC sessions, status views, generated
projections, and retained evidence are non-authoritative.

## Proposal-Local Precedence

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `resources/packet-contract.yml`
4. `architecture/target-architecture.md`
5. `architecture/acceptance-criteria.md`
6. `architecture/implementation-plan.md`
7. supporting architecture and resource documents
8. `navigation/artifact-catalog.md`
9. `.octon/generated/proposals/registry.yml`
10. `README.md`

## Durable Ownership Split

| Concern | Planned owner | Boundary |
| --- | --- | --- |
| Authority evaluation, exact guard minting, scope, expiry, revocation, and canonical launch API | RP-01 | Broker verifies/consumes frozen authority and cannot mint, widen, renew, or reinterpret it. |
| Candidate environment, provider-native model session, and denial of broker IPC/credentials | RP-02 | Candidate never becomes an IPC client or credential custodian. |
| SQLite schema, T1/T2/UNKNOWN/outbox substrate, epoch, backup, and repair primitives | RP-03 | Broker is the normal deployed writer and consumes the frozen store API. |
| Authenticated IPC, Keychain custody, internal operation handle, supervision, broker lifecycle UX, and effect host | RP-04 | One process and one protocol; no remote worker or verifier. |
| Sanitized privileged Git adapter | RP-05 | RP-04 hosts it later but does not define Git commands or CAS semantics. |
| Independent exact-SHA verifier and verdict | RP-06 | Broker observations are never sole verification verdicts. |
| Provider-specific outcome classification, reconciliation/retry, and full degraded mode | RP-08 | RP-04 scans and preserves generic attempt state but cannot infer provider truth. |

For the publication vertical, RP-04 owns only structural equality between the
complete tuple committed at RP-03 T1 and the tuple digest bound into its
internal one-shot handle. RP-03 carries route and verdict references opaquely;
RP-06 owns their semantics, so RP-04 gains no RP-06 dependency or policy role.

## Broker Non-Authority Rules

- An IPC request, authenticated peer, Keychain item, launchd label, process ID,
  operation handle, broker receipt, or status view cannot authorize an effect.
- A broker operation handle is a derivative one-shot dispatch reference to an
  already-valid RP-01 authority record and committed RP-03 operation/attempt.
  It contains no widening fields and is unusable outside the broker.
- The broker may record the observation it directly made. It cannot author an
  independent verifier verdict or claim state satisfaction beyond that fact.
- `.octon/generated/proposals/registry.yml` remains discovery-only and is not
  edited by this delegated child-authoring task.

## Existing Helper Disposition

`.octon/framework/capabilities/_ops/scripts/policy-grant-broker.sh` remains an
existing ephemeral policy-grant helper subject to its current owner. It is not
an RP-04 promotion target, broker implementation seed, compatibility bridge,
credential store, IPC endpoint, or effect host. ED-007 audits its visible name
and placement without granting RP-04 authority to repurpose it.

## Conflict and Failure Rules

- Missing RP-01 guard, RP-02 isolation, RP-03 store, ED-001 proof, or ED-002
  mechanism blocks implementation or dispatch.
- Same UID, socket possession, or a valid-looking request alone never
  authenticates a client.
- Missing/stale/revoked/replayed/wrong-identity operation state denies before
  credential access or external send.
- Broker outage blocks the affected consequence, preserves candidate work, and
  never falls back to ambient credentials, file authority, or direct effects.
- Broker outage, `ATTEMPTING`, or `UNKNOWN` also preserves the selected route;
  none can expose or select PR. A later PR requires fresh RP-06 classification
  and authority after reconciliation.
