# Child Packet Index

| Logical | Workgroup | Child proposal | Fixed dependencies |
| --- | --- | --- | --- |
| RP-00 | RWG-00 | `octon-architecture-migration-containment` | none |
| RP-01 | RWG-01 | `octon-architecture-migration-canonical-authority` | RP-00 |
| RP-02 | RWG-02 | `octon-architecture-migration-candidate-isolation` | RP-00 |
| RP-03 | RWG-03 | `octon-architecture-migration-transactional-runtime-store` | RP-01 |
| RP-04 | RWG-04 | `octon-architecture-migration-local-broker` | RP-01, RP-02, RP-03 |
| RP-05 | RWG-05 | `octon-architecture-migration-sanitized-git` | RP-04 |
| RP-06 | RWG-06 | `octon-architecture-migration-verification-publication` | RP-01, RP-03, RP-05 |
| RP-07 | RWG-07 | `octon-architecture-migration-signed-evidence` | RP-03, RP-04, RP-06 |
| RP-08 | RWG-08 | `octon-architecture-migration-recovery-class-b` | RP-06, RP-07 |
| RP-09 | RWG-09 | `octon-architecture-migration-self-development-trust-activation` | RP-06, RP-07, RP-08 |
| RP-10 | RWG-10 | `octon-architecture-migration-workspace-projects` | RP-01 |
| RP-11 | RWG-11 | `octon-architecture-migration-harness-factory` | RP-01, RP-02, RP-10 |
| RP-12 | RWG-12 | `octon-architecture-migration-extension-supply-chain` | RP-07, RP-11 |
| RP-13 | RWG-12 | `octon-architecture-migration-bounded-child-agents` | RP-08, RP-11 |
| RP-14 | RWG-13 | `octon-architecture-migration-solo-dogfood-promotion` | core: RP-08, RP-09, RP-10, RP-11; program closeout: RP-12, RP-13 |

All children are required sibling proposals. Their statuses advance only
through their own lifecycle actions; the parent does not own child receipts,
targets, statuses, archives, or terminal outcomes.

## Brokered Publication Revision Overlay

The fixed fifteen-packet graph and every dependency edge remain unchanged.
Brokered publication semantics fit the existing boundaries: RP-00 temporarily
disables unsafe current Git routes; RP-01 supplies the complete grant; RP-03
commits the frozen effect tuple; RP-04 validates its structural equality and
hosts the sole broker; RP-05 owns closed Git/ref primitives; RP-06 owns route,
verdict, history, PR, and mirror policy; RP-07 owns signed evidence; RP-08 owns
provider-result classification, reconciliation, recovery, and cleanup; and
RP-14 owns equal-floor Solo Local proof. RP-02 and RP-09 through RP-13 retain
their existing scopes.

The RP-03 design review census adds
`authority_engine/src/implementation/policy.rs` only for post-decision calls
into the transactional persistence adapter. RP-01 retains policy meaning and
integrates first; RP-03 follows through its existing RP-01 verification gate.

The registry write scopes now include the containment helpers in RP-00,
conditional cleanup primitive in RP-05, and canonical default-work-unit policy
sources in RP-06. These are future promotion targets only; the proposal revision
does not edit or authorize them.

## RP-01 Launch-Dominance Scope Overlay

RP-01 additionally owns only the exact final guard invocation and bypass-removal
slice at the four candidate-launch seams named by its reviewed census, plus the
three exact fitness-test targets. The DAG is unchanged. The sole new physical
collision is `lifecycle_executor/src/codex.rs`, serialized RP-01, RP-02, then
RP-11 without transferring isolation or Harness/adapter semantics.

The RP-11 design review closes the generic adapter boundary over all four
accepted RP-01 candidate-launch seams. RP-11 therefore adds only
`kernel/src/pipeline.rs`, `kernel/src/workflow.rs`, and
`lifecycle_executor/src/workflow_leaf.rs` to its write scope for exact
registry-resolved prepared-handle/model-or-host-adapter integration. RP-01
retains final guard ownership at each seam and integrates first; the 15-child
DAG and dependency edges are unchanged.
