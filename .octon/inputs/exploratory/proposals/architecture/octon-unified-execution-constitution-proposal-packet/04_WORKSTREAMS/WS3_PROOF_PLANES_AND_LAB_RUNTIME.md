# WS3 — Universal proof planes, evaluator independence, and live lab runtime

## Purpose

Make structural, functional, behavioral, governance, recovery, and maintainability proof universal and promotion-gating; deepen lab from authored structure into exercised substrate.

## Audit findings addressed

F-08, F-09, F-10, F-21, F-22

## Exact repo paths / subsystems to change

- `.github/workflows/**`
- `.octon/framework/assurance/**`
- `.octon/framework/lab/**`
- `.octon/framework/observability/**`
- `.octon/state/evidence/lab/**`
- `.octon/state/evidence/validation/**`

## Deliverables

- Explicit required gate or equivalent enforced suite for each proof plane.
- Hidden/held-out evaluator sets and anti-overfitting separation between harness-tuning data and claim data.
- Operational lab scenario, replay, shadow, fault, and adversarial packs tied to promotion.
- Intervention disclosure and evaluator independence receipts in lab and release evidence.

## Implementation sequence

1. **Stabilize the current path**
   - confirm the exact live behavior on the listed subsystems
   - write a red/green acceptance matrix before editing
2. **Implement the cutover in runtime terms**
   - make the new target-state surface real in code and emitted artifacts
   - keep compatibility only where the packet explicitly allows it
3. **Backfill evidence**
   - update run evidence, proof, disclosure, and governance overlays so the new truth path is inspectable
4. **Delete or demote obsolete scaffolding**
   - remove what is no longer load-bearing
   - where removal is unsafe in the same step, register a named retirement trigger and owner

## Acceptance criteria

- [ ] Supported live consequential envelope cannot promote if any mandatory proof plane is absent or red.
- [ ] Lab scenarios and replay/shadow/fault packs run routinely and produce retained evidence.
- [ ] Evaluator independence is visible in artifact boundaries and test set separation.
- [ ] Behavioral and recovery claims are supported by lab evidence, not only closure bundles.

## Dependencies

- `WS2`

## Claim criteria unlocked by this workstream

- Complete proof-plane claim
- Lab-in-substance claim

## Required evidence before calling this workstream complete

- code diff showing the new live path
- updated contract/artifact examples where applicable
- routine run evidence from the supported consequential envelope
- validator or workflow output proving the new gate/path is enforced
- explicit deletion or retirement note for any legacy surface touched

## Anti-patterns to avoid

- leaving the old surface on the critical path while calling the new one canonical
- proving the workstream only with a special closure or migration run
- treating new schema files as sufficient evidence of runtime completion
- widening support or claims during the workstream before proof/disclosure catch up
