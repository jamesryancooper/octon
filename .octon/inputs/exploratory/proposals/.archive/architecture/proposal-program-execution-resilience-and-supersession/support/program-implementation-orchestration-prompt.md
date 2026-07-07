# Program Implementation Orchestration Prompt

schema_version: program-implementation-orchestration-prompt-v1
verdict: pass
generated_at: 2026-07-07T14:30:00Z
generator: octon-proposal-lifecycle-generate-program-orchestration-prompt
parent_program: .octon/inputs/exploratory/proposals/architecture/proposal-program-execution-resilience-and-supersession
child_registry: .octon/inputs/exploratory/proposals/architecture/proposal-program-execution-resilience-and-supersession/resources/child-packet-index.yml
child_registry_digest: sha256:f201df1e3e9d5a65b06faa98684594ff8354647daa7715bb1187b65b45e607a5
implementation_mode: child-owned-reconciliation
child_authority_preserved: yes
parent_summary_not_child_evidence: true

## Objective

Reconcile the accepted parent program against already-landed child-owned behavior, then record parent-local orchestration evidence only after every required child packet is terminal through its own lifecycle receipts.

The program objective is to make proposal-program execution resilient enough that a run either operates inside a provably owned or explicitly leased surface, stops repeated recovery when blocker evidence is unchanged, or freezes and supersedes a polluted run without losing child-owned receipt evidence.

## Child Sequence

Run the sequence as reconciliation, not blind reimplementation:

1. `proposal-program-loop-breaker`
   - Required gate: terminal.
   - Current target state: archived implemented child packet.
   - Reconcile loop-control behavior, repeated blocker fingerprint handling, cleanup terminality, publication freshness priority, and attempt or token cap evidence through the child-owned archived receipts.

2. `proposal-program-ownership-baseline-and-leases`
   - Required gate: terminal after `proposal-program-loop-breaker`.
   - Current target state: archived implemented child packet.
   - Reconcile start baseline, route write leases, isolated dirty-start handling, and owned or foreign worktree classification through the child-owned archived receipts.

3. `proposal-program-supersession-rescue-path`
   - Required gate: terminal after `proposal-program-ownership-baseline-and-leases`.
   - Current target state: archived implemented child packet.
   - Reconcile polluted-run freeze evidence, deliverable partitioning, successor-run requirements, and preservation of child receipt references through the child-owned archived receipts.

4. `closeout-worktree-autonomous-partition-evidence`
   - Required gate: terminal after `proposal-program-supersession-rescue-path`.
   - Current target state: archived implemented child packet.
   - Reconcile non-mutating closeout-worktree partition reports, include and exclude path evidence, lifecycle return validation, and no cleanup or terminal overclaim through the child-owned archived receipts.

## Required Parent Output

After reconciliation, write parent-local `support/program-implementation-orchestration-run.md` with at least:

- `verdict`
- `implemented_at`
- `promotion_evidence_count`
- `child_authority_preserved`
- `required_child_count`
- `terminal_child_count`
- `child_receipt_summary_count`
- `parent_summary_not_child_evidence`
- `child_receipts_remain_child_owned`
- `archive_authority_granted`
- `cleanup_authority_granted`
- `git_mutation_authority_granted`
- `child_receipt_refs`

Use `verdict: pass` and `child_authority_preserved: yes` only when all four required children remain terminal through child-owned manifests, closeout receipts, terminal closeout receipts, implementation receipts, conformance receipts, drift receipts, validation receipts, and archive metadata.

## Validation Floor

Before parent promotion or closeout, retain passing evidence for:

- `validate-proposal-review-gate.sh --package <parent> --require-implementation-authorization`
- `validate-proposal-program-child-readiness.sh --package <parent>`
- `validate-proposal-program-structure.sh --package <parent>`
- `validate-architecture-proposal.sh --package <parent>`
- `validate-proposal-program-readiness-projection.sh --package <parent>`
- targeted proposal lifecycle terminal freshness for the parent after generated indexes are refreshed

Child receipts, child validation verdicts, child promotion targets, and child archive metadata remain child-owned. This prompt does not authorize cleanup, archive, Git mutation, durable promotion, or parent substitution for child evidence.
