# Implementation Plan

This plan describes later implementation. It does not authorize it.

## Workstream 0 — Bind Accepted Policy and Freeze Interfaces

1. Load the exact conservative ROD-005 limits and enforcement-or-disabled rules
   from `resources/mission-child-design-and-dependency-receipt.yml`; do not
   substitute wider or measurement-only values for declared hard bounds.
2. Verify exact RP-02/RP-08/RP-11 implemented interfaces before source edits;
   ED-001 dynamic proof gates live mapping completion/use rather than proposal
   authorization or the existence of the exact implementation.
3. Inventory ProgramChild scheduler, generic adapter, cancellation/process,
   token ledger, mission status, and recovery interfaces.
4. Assign exact shared symbols; keep all mission child launch disabled.

Exit: no unsupported hard limit or foreign semantic owner.

## Workstream 1 — Contracts, Policy, and Registries

1. Add strict MissionChildRun, child budget, provider mapping, and terminal
   retirement contracts and mirrors.
2. Extend Agent Node/Harness/Run Lifecycle/Token Ledger child references only
   through explicit narrowing fields.
3. Publish the child policy with the accepted depth-one boundary,
   engineering-owned role templates, accepted ROD-005 provisional ceilings, proof-derived
   enforcement classes, disabled features, and conformance-backed mapping
   references.
4. Register exact runtime/adapter contract entries.

Exit: unknown fields reject and no contract grants authority or persistence.

## Workstream 2 — Scope, Budget, and Guard Admission

1. Implement typed strict intersection over parent/mission/project/Harness/
   role/isolation/provider/budget inputs.
2. Reject missing, ambiguous, incomparable, stale, or widening values.
3. Produce one child budget enforcement plan distinguishing hard, measured, and
   unsupported dimensions.
4. Bind child contract/intersection/budget/candidate/session/mapping to the
   existing one-shot guard and pre-spawn revalidation.
5. Test dry-run admission with no provider or guard consumption.

Exit: complete scope/budget and guard attack matrices pass.

## Workstream 3 — Scheduler Mapping and Isolated Setup

1. Expose/reuse only existing lifecycle-program batch/lock/counter/retry/
   timeout/cancel/terminal hooks.
2. Map temporary MissionChildRun jobs without importing ProgramChild packet or
   closeout semantics.
3. Create fresh independent candidate repository and credentialless
   short-lived/non-exportable session through dependency interfaces.
4. Remove credentials, canonical Git/sibling access, external effect routes,
   and every spawn/recruit/delegate surface.

Exit: useful-positive/credential-negative isolation and no-new-scheduler proof
pass.

## Workstream 4 — Child Provider Mapping

1. Implement `child.rs` over RP-11 generic operations with exact child identity
   and outcome validation.
2. Implement fake success/failure/timeout/unknown/cancel/usage/retire mappings.
3. Implement a separate primary-provider child mapping without editing RP-11's
   trait/registry/generic provider semantics.
4. Admit the primary mapping only when current conformance and its existing
   proof and promotion gates pass; otherwise keep child launch unsupported.

Exit: RP-13 component contribution to PO-FD-023 passes with bypass absent.

## Workstream 5 — Limits, Cancel, and Unknown Reconciliation

1. Enforce concurrency/steps/attempts/retries/timeout in scheduler/supervisor.
2. Enforce provider-supported token/cost/evidence hard ceilings or deny
   admission; record measurement-only usage honestly.
3. Map every cancel/revoke/timeout/budget trigger to exact provider task,
   cancellation token, and process group.
4. Route lost/unknown outcomes to RP-08 and prevent blind retry/replacement/
   deletion/reuse until reconciled.

Exit: every limit/cancel/unknown fault case converges safely.

## Workstream 6 — Output Reconciliation and Retirement

1. Confine output to child candidate/evidence roots.
2. Validate output schema, scope diff, conflicts, and evidence; hand candidate
   to parent reconciler without child mutation of canonical state.
3. Preserve required output/evidence, then revoke/release guard, session,
   provider task, process, locks, and candidate ownership.
4. Write a tombstone and deny identity/session/guard/task/candidate reuse.
5. Test replacement only with wholly new resources after predecessor
   reconciliation/retirement.

Exit: terminal and every interrupted retirement/reuse test pass.

## Workstream 7 — UX, Atomic Cutover, and Evidence

1. Integrate compact child progress/block/cancel/unknown/retirement into existing
   mission status/inbox and maintain zero routine prompts after proof-driven
   admission under the accepted configuration.
2. Exercise contract-only, dry-admission, fake-mapping, and live-disabled safe
   stages.
3. Rehearse disable/cancel/reconcile/retire and single-agent continuation.
4. Activate admitted primary mapping atomically with exact guard/scope/budget/
   retirement gates; retire unsafe claim language.
5. Retain UE-013/component evidence and run conformance/drift reviews.

## Stop Conditions

Stop and revise the proposal if implementation requires any authority/store/
recovery semantic change, generic adapter change, new scheduler/queue/worker,
credential/canonical-Git access, depth above one, self-recruitment, persistent
identity, direct durable effect, unsupported hard-budget claim, or ProgramChild
conversion into an agent.
