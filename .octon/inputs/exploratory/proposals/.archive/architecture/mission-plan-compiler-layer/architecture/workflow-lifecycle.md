# Workflow Lifecycle

## States

```text
No Plan
-> Plan Candidate
-> Mission-Bound Plan
-> Partially Decomposed Plan
-> Readiness-Checked Plan
-> Work-Package Candidates
-> Compiled Run Contracts
-> Authorized Runs
-> Evidence-Updated Plan Revision
-> Closed | Superseded | Retired
```

## Stage 1: Bind To Mission Authority

Planning may start only from:

- an existing `octon-mission-v2` mission
- an approved mission candidate promoted through the mission workflow
- an accepted proposal whose promotion work requires mission-scoped execution

It may not start from chat, generated summaries, raw proposal notes, or
`inputs/**` as runtime authority.

## Stage 2: Draft MissionPlan Candidate

The first pass records only mission objective, strategic outcomes, major
workstreams, constraints, risks, dependencies, decisions, planning budget,
decomposition depth budget, and rolling-wave window.

## Stage 3: Critic And Readiness Review

Before deeper decomposition, the workflow checks:

- mission binding and digest freshness
- scope preservation
- success-criteria coverage
- risk ceiling
- required approvals
- generated/input/proposal authority misuse
- duplicate branches
- dependencies separated from hierarchy

## Stage 4: Selective Decomposition

Decompose a branch only when it blocks near-term execution, carries material
risk, is needed for run-contract compilation, has unresolved dependencies,
requires a human decision, affects rollback, or affects support-target
admission or support claims.

## Stage 5: Compile Leaves

Ready leaves compile only to:

- action-slice candidates
- run-contract drafts
- context-pack requests
- authorization requests
- rollback-plan references
- evidence requirements

They do not execute.

## Stage 6: Authorize And Execute Through Existing Runtime

Material execution proceeds only through run-contract binding, context pack
evidence, `authorize_execution`, typed authorized effects, retained run
evidence, and Run Journal coverage.

## Stage 7: Update From Evidence

After execution, the plan updates from run journal events, lifecycle state,
authorization receipts, effect receipts, evidence-store records, rollback
posture, interventions, and validation results. Intention alone never updates
execution truth.
