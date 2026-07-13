# Proposal Reading and Precedence Map

## Authority Boundary

Current canonical repository authority outranks this proposal. The intake
controls accepted operator-intent lineage while remaining non-authoritative
pending promotion; the specified reconciliation controls RP-07 packet scope,
engineering refinement, and proof sequencing without reopening accepted intent.
Signed evidence authenticates observations and detects rewriting; it does not
grant authority, authorize an effect, or convert a provider observation into
policy.

## External Sources

| Concern | Source | Role |
| --- | --- | --- |
| Constitutional authority | `.octon/framework/constitution/**` and `.octon/instance/**` | Governs authority, evidence, ownership, topology, and policy. |
| Proposal lifecycle | `.octon/inputs/exploratory/proposals/README.md` and proposal standards | Governs packet shape and lifecycle. |
| Reconciled packet boundary | Reconciliation `reconciled-proposal-packet-map.yml` RP-07 | Controls purpose, scope, dependencies, proof, and exclusions. |
| Reconciled requirements | FD-013, FD-014, evidence portion of FD-016, RF-012/013/017/022/027/029, PO-FD-013/014, UE-008, ROD-001 | Controls traceability and future gates. |
| Current implementation facts | Retention contracts, `evidence-store-v1.md`, checkpoint-v2, runtime evidence writers, `runtime_bus`, and `replay_store` | Establishes the repository-grounded starting point. |

## Proposal-Local Precedence

1. `proposal.yml`
2. `architecture-proposal.yml`
3. `resources/packet-contract.yml`
4. `resources/traceability.yml`
5. `architecture/target-architecture.md`
6. `architecture/acceptance-criteria.md`
7. `architecture/implementation-plan.md`
8. remaining architecture and navigation documents
9. `README.md`

## Planned Durable Ownership

| Concern | Planned owner | Boundary |
| --- | --- | --- |
| SQLite/WAL schema, operation state transitions, outbox, and logical capacity transaction | RP-03 | RP-07 consumes the frozen outbox/capacity API and may not redefine schema, transitions, or writer authority. |
| Broker effect execution and operation observation | RP-04 | RP-07 owns only `local_broker/src/evidence.rs`, which signs a canonical direct observation supplied by broker-owned code. |
| Exact verdict and publication verification | RP-06 | RP-07 owns only `verification_publication/src/evidence.rs`, which signs a canonical verifier observation; RP-06 retains verdict semantics. |
| Signed envelope/checkpoint schemas, key epochs, verifier, and evidence-attestation library | RP-07 | Authenticates producer-bound canonical bytes without minting authority. |
| Candidate-inaccessible monotonic latest-head interface and receipts | RP-07 | Compare-and-advance state lives outside the candidate and outside the rollback unit of the runtime DB. |
| Physical terminal reserve and evidence capacity/retention policy | RP-07 | Logical reservation remains RP-03-owned; no lease service is created. |
| Quotas, pins, compaction, locality, and minimal projection rules | RP-07 | Raw payloads stay local/outside Git; signed pointers are non-authoritative evidence. |
| Unknown-outcome reconciliation and Class B end-to-end behavior | RP-08 | Consumes signed evidence; may not weaken or reinterpret it. |
| Publication grant/verdict/operation/provider/landed/reconciliation evidence chain | RP-07 | Authenticates references and direct observations; never issues grant, selects route, executes effect, classifies `UNKNOWN`, or authorizes cleanup. |

## Direct-Observation Signature Boundary

The broker signs only facts it directly observes about the attempted material
effect. The verifier signs only facts it directly observes about exact
repository/provider state and the verdict input/output. Neither signer may sign
the other's claimed facts, the candidate cannot access either private identity,
and a signature never proves more than the canonical payload states.

## Derived and Operational Surfaces

- raw observations, local indexes, compaction work files, and capacity metrics
  are operational evidence, not authority;
- signed range/terminal checkpoints and publishable pointers are retained
  evidence and may be projected only after verification and classification;
- the latest-head anchor is candidate-inaccessible control/evidence state, not
  a proposal or generated projection;
- `.octon/generated/proposals/registry.yml` remains a discovery projection and
  is intentionally not edited by this child assignment; and
- retained packet proof belongs at
  `.octon/state/evidence/validation/proposals/octon-architecture-migration-signed-evidence/`.

## Conflict Rule

Wrong, revoked, missing, duplicate, forked, stale, or unverifiable signatures;
anchor mismatch; exhausted terminal reserve; incomplete pinned ranges; or a
failed compaction checkpoint blocks the dependent success/publication
transition. Candidate work and raw evidence are preserved. No unsigned,
Git-only, or stale-snapshot route may select a broader outcome.
