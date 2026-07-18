# Candidate Isolation Architecture Audit

- run_id: `architecture-migration-candidate-isolation-20260718T144600Z`
- target_mode: `observed`
- domain_path: `.octon/inputs/exploratory/proposals/architecture/octon-architecture-migration-candidate-isolation`
- evidence_depth: `deep`
- severity_threshold: `medium`
- post_remediation: `false`
- reviewed_commit: `85e0afe0ff3af8574d5ea82ad5f1f38d6abd6dc8`
- reviewed_packet_digest: `sha256:e697d8725340af95058f08f8f287c9a3632f52c34cbe89e3088f3a8df42d8a43`

## Outcome

RP-02 requires revision. Its authority, ownership, failure, rollback, and
negative-test boundaries are directionally strong, and its 17-target scope
exactly matches the parent. It does not yet select an implementable ED-001
mechanism and it circularly requires dynamic UE-003 proof before authorizing
the implementation that must produce it. No implementation evidence is
claimed.

## Current Surface Map

| Surface | Responsibility | Evidence |
| --- | --- | --- |
| Candidate preparation | Fresh HOME/env, closed descriptors, independent repository | `architecture/target-architecture.md`, `architecture/implementation-plan.md` |
| Native enforcement | Filesystem, process, IPC, executable, and network deny/allow boundary | `architecture/validation-plan.md` |
| Provider session | Useful primary-provider session without durable candidate-readable credentials | `resources/packet-contract.yml` |
| Export boundary | Exact commit transfer without candidate-controlled execution | `architecture/target-architecture.md` |
| Lifecycle recovery | Cancellation, retirement, quarantine, and non-reuse | `architecture/rollback-and-recovery.md` |
| Parent coordination | Exact target equality, source ownership, shared-file serialization | Parent registry, ownership map, and collision ledger |

## External Criteria Evaluation

| Criterion | Result | Assessment |
| --- | --- | --- |
| Modularity | pass with blocker | RP-02's boundary is distinct, but ED-001 lacks an exact internal split between preparation, enforcement, session attachment, and retirement. |
| Discoverability | fail | Readers cannot find the exact supported tuple, profile schema, session protocol, or owning symbols because they are not selected. |
| Coupling | pass | RP-01, RP-04, RP-06, and RP-11 exclusions are explicit and parent serialization covers shared files. |
| Operability | fail | The deny behavior is clear, but the route cannot determine whether a host/provider tuple is admitted without an exact mechanism. |
| Change safety | fail | No exact profile/client/session identity can be digest-bound or invalidated on drift. |
| Testability | fail at authorization order | The matrix is extensive, but UE-003 is circularly required before its test subject may exist. |

## Critical Gaps

1. `RP02-ED001-MECHANISM-001` (high): select exact, repo-verifiable ED-001
   enforcement and session mechanics without claiming unobserved provider
   capability.
2. `RP02-IMPLEMENTATION-EVIDENCE-CYCLE-002` (high): authorize the complete
   exact design before dynamic proof while preserving all proof gates before
   conformance, completion, cutover, or promotion.

## Recommended Changes

| Priority | Recommendation | Benefit | Tradeoff |
| --- | --- | --- | --- |
| P1 | Pin a closed default support envelope and exact fail-closed session adapter contract. | Makes ED-001 implementable without widening support. | Unsupported tuples deny until separately admitted. |
| P1 | Assign preparation, policy application, provider attachment, export, retirement, and negative checks to exact symbols/tests. | Makes dominance and cleanup structurally inspectable. | Adds detailed packet maintenance. |
| P1 | Move UE-003 and dependency implementation receipts to implementation-entry/completion gates, not proposal-design authorization. | Removes circularity without weakening proof. | Acceptance remains distinct from operational readiness. |

## Keep As-Is Decisions

- Keep RP-01 guard ownership, RP-04 effect credentials, RP-06 publication
  routing, and RP-11 generic adapter semantics outside RP-02.
- Keep linked worktrees, ambient credentials, canonical Git, broad egress, and
  candidate-controlled export execution prohibited.
- Keep uncertain state quarantined and never reused.
- Keep all proposal and retained evidence non-authoritative.

## Open Questions / Unknowns

- The repository does not prove a usable provider-native short-lived or
  non-exportable session capability. The revision must define a fail-closed
  adapter boundary and must not represent provider feasibility as established.
- RP-00 implementation/verification and UE-003 remain future dynamic gates.

These unknowns do not require a new product decision unless the accepted
engineering default later proves infeasible; they do require an exact design
and truthful evidence ordering now.

## Self-Challenge

- Challenged whether current `workspace-write` is sufficient; it is not because
  the workspace is canonical and the host/session boundary is unproved.
- Challenged whether a linked worktree is independent; it shares Git common
  state and remains prohibited.
- Challenged whether a provider credential can be hidden only by environment
  scrubbing; it cannot, so the adapter must prove candidate unreadability or
  bounded ephemerality.
- Challenged ownership takeover; neighboring semantic owners remain explicit.

## Done Gate

Three controlled passes converge on two high blockers. Done gate:
`fail-qualified-local`; canonical route: `revise-packet`.
