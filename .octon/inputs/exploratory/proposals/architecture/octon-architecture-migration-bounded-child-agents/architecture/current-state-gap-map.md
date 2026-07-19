# Current-State Gap Map

## Repository Baseline

The reconciliation inspected commit
`c5b1f5760c78ff521cca6b054e4e8fef5300505b`. Later proposal authoring has not
accepted or dynamically proved RP-13.

| Current surface | Reusable strength | Gap owned by RP-13 |
| --- | --- | --- |
| Kernel lifecycle-program controller | ProgramChild dependency scheduling, bounded batch concurrency, locks, retries/recovery, cancellation, terminal evidence, and cleanup | ProgramChild is proposal/program identity; no temporary mission child contract, depth, strict scope/budget intersection, or retirement semantics. |
| Lifecycle executor request/primary provider | Optional child ID, cancellation token, timeout, process-group setup/kill, terminal observations | No exact one-shot mission-child binding, provider-child task mapping, credentialless session proof, or reuse prevention. |
| Token Budget Ledger | Child/stage/source/model estimates and provider usage provenance | Measurement is not hard enforcement; no per-dimension enforce/measured/unsupported admission contract. |
| Agent Node v1 | Bounded model activity bound to run/Harness/context with explicit non-authority | No parent mission/project/child lineage, depth-one, isolated candidate/session, child cancellation, or retirement fields. |
| Task-Specific Harness | Reusable exact per-run input/adapter contract, strengthened by RP-11 | No child-specific strict intersection and exact child guard/budget/provider mapping binding. |
| Mission status/resume | Canonical mission status and concise next actions | No compact child progress/cancel/unknown/retirement summary integrated into existing UX. |
| RP-08 recovery target | Planned lost-response reconciliation and candidate preservation | RP-13 must consume, not duplicate, unknown/cancel/terminal recovery. |

## Primary Finding

RF-031 credits current concurrency, steps, retries, timeouts, locks, process
kill, terminal evidence, and token measurement. It rejects the claims that
measurement is hard budget enforcement or process exit proves identity
retirement. RP-13 preserves those primitives and closes only the exact child
guard/scope/isolation/depth/limit/provider-mapping/retirement gap.

## Cross-Referenced Findings

- RF-004: shared HOME/environment/Keychain/canonical Git exposure requires the
  already-proved isolation/session dependency; RP-13 cannot repair it locally.
- RF-016: RP-13 closes bounded-child/provider-mapping specialization only;
  extension and generic adapter work remain RP-12/RP-11.
- RF-025: useful credentialless provider work is unproved until the ED-001
  dependency premise passes dynamically; failure disables children.
- RF-027: ROD-005 accepts the lowest useful concurrency and conservative,
  adjustable Solo Local limits. The design receipt selects exact
  enforcement-or-disabled values; implementation must encode and prove them,
  then may widen one dimension only when dogfood proves benefit.
  Provider-child admission is proof-driven and remains disabled until the
  configuration, conformance, and existing proof gates pass.

## Gap-to-Owner Map

| Gap | Owner | Not owned here |
| --- | --- | --- |
| MissionChildRun identity/scope/budget/depth/retirement | RP-13 | ProgramChild identity, mission authority, runtime store |
| Scheduler mechanics | Existing lifecycle-program controller reused by RP-13 | New scheduler/queue/worker |
| Exact Harness/guard/generic adapter | RP-11 consumed by RP-13 | Trait/registry/authorization semantics |
| Credentialless isolated session/repository | Dependency chain/ED-001 premise | RP-13 sandbox, key, broker, or HOME redesign |
| Unknown reconciliation/candidate preservation | RP-08 consumed by RP-13 | Recovery/store semantics |
| Child provider mapping | RP-13 | Generic provider adapter and integrated support proof |

## Evidence Honesty

Current facts are statically inspected. No accepted credential/Git/sibling,
scope/depth/recruitment, hard-limit, cancel/unknown, terminal retirement, or
identity/session/guard reuse test has run for MissionChildRun. UE-013 remains
open.
