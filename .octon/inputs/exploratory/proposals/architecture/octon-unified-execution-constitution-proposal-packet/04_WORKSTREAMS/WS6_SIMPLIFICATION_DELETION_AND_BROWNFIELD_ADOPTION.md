# WS6 — Simplification, deletion, retirement, and brownfield adoption

## Purpose

Finish the build-to-delete program by retiring obsolete shims, demoting migration-era evidence, simplifying agency and bootstrap surfaces, and adding explicit retrofit guidance for older repositories.

## Audit findings addressed

F-15, F-16, F-17, F-19, F-21

## Exact repo paths / subsystems to change

- `.octon/framework/agency/**`
- `.octon/instance/bootstrap/OBJECTIVE.md`
- `.octon/instance/cognition/context/shared/intent.contract.yml`
- `.octon/instance/bootstrap/**`
- `.octon/state/evidence/migration/**`
- `.octon/instance/governance/contracts/**`
- `.octon/instance/governance/disclosure/**`
- `.octon/state/evidence/lab/harness-cards/**`
- `.octon/instance/governance/adoption/**`

## Deliverables

- Explicit retirement decisions for every compatibility shim and migration-era surface still on the primary path.
- Demotion of historical wave/certification artifacts to lineage/reference status once ordinary runtime proof exists.
- Final simplification of agency to a single accountable orchestrator plus justified specialized roles only.
- Brownfield retrofit/adoption playbooks for non-greenfield repositories.

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

- [ ] Every transitional surface has owner + review date + removal trigger or is removed.
- [ ] No compatibility shim remains load-bearing without explicit justification.
- [ ] Historical wave artifacts no longer carry the burden of proving current live behavior.
- [ ] A brownfield adoption checklist exists and is executable by a real repository owner.

## Dependencies

- `WS5`

## Claim criteria unlocked by this workstream

- Build-to-delete / low-entropy claim
- Brownfield adoption claim

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
