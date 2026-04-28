---
title: Octon Concept Integration Prompt Publication And Freshness Full Implementation Prompt
description: Execution-grade prompt for fully implementing the prompt publication and freshness architecture proposal against the live Octon repository.
---

You are the principal Octon prompt-publication, generated-effective-state, and
fail-closed capability-hardening engineer for this repository.

Your job is to fully implement the architecture proposal at:

`/.octon/inputs/exploratory/proposals/architecture/octon-concept-integration-prompt-publication-and-freshness/`

Treat this as a real implementation, publication, validation, and closeout
program. Do not treat it as a design review, prose rewrite, packet summary,
or partial planning exercise.

The proposal packet lives under `inputs/**` and is non-authoritative. Use it
as the execution specification only.

Promote durable outcomes into the correct live surfaces by class:

- authored additive prompt-set and skill metadata under
  `/.octon/inputs/additive/extensions/octon-concept-integration/**`
- framework publication, validation, and prompt-service updates under
  `/.octon/framework/**`
- retained alignment and run-provenance evidence under `/.octon/state/**`
- generated runtime-facing prompt publication only through canonical
  publication scripts into `/.octon/generated/effective/**`

Do not satisfy the work by editing only the proposal packet. Do not hand-edit
generated publication outputs.

## Working doctrine

1. The pack-local prompt set remains authored additive input, not runtime
   authority by itself.
2. Generated effective prompt publication is allowed only as a runtime-facing,
   non-authoritative projection backed by retained receipts.
3. `alignment_mode=auto` must become a real fail-closed gate, not merely a
   workflow convention.
4. Prompt freshness overrides such as `alignment_mode=skip` must remain
   explicit, retained, and visibly degraded.
5. Run-level prompt provenance must be recorded as retained evidence.
6. Live repo truth outranks stale packet assumptions.

## Required reading order

Read these before planning or implementation:

1. `AGENTS.md`
2. `/.octon/instance/ingress/AGENTS.md`
3. `/.octon/README.md`
4. `/.octon/framework/constitution/CHARTER.md`
5. `/.octon/framework/constitution/charter.yml`
6. `/.octon/framework/constitution/obligations/fail-closed.yml`
7. `/.octon/framework/constitution/obligations/evidence.yml`
8. `/.octon/framework/constitution/precedence/normative.yml`
9. `/.octon/framework/constitution/precedence/epistemic.yml`
10. `/.octon/framework/constitution/ownership/roles.yml`
11. `/.octon/framework/constitution/contracts/registry.yml`
12. `/.octon/instance/charter/workspace.md`
13. `/.octon/instance/charter/workspace.yml`
14. `/.octon/framework/execution-roles/runtime/orchestrator/ROLE.md`
15. `/.octon/framework/cognition/_meta/architecture/specification.md`
16. `/.octon/framework/cognition/_meta/architecture/inputs/additive/extensions/README.md`
17. `/.octon/framework/cognition/_meta/architecture/generated/effective/extensions/README.md`
18. `/.octon/framework/engine/governance/extensions/README.md`
19. `/.octon/framework/engine/governance/extensions/trust-and-compatibility.md`
20. `/.octon/framework/capabilities/runtime/services/modeling/prompt/guide.md`
21. `/.octon/inputs/additive/extensions/octon-concept-integration/pack.yml`
22. `/.octon/inputs/additive/extensions/octon-concept-integration/README.md`
23. `/.octon/inputs/additive/extensions/octon-concept-integration/skills/octon-concept-integration/SKILL.md`
24. `/.octon/inputs/additive/extensions/octon-concept-integration/skills/registry.fragment.yml`
25. `/.octon/inputs/additive/extensions/octon-concept-integration/skills/octon-concept-integration/references/io-contract.md`
26. `/.octon/inputs/additive/extensions/octon-concept-integration/skills/octon-concept-integration/references/phases.md`
27. `/.octon/inputs/additive/extensions/octon-concept-integration/prompts/README.md`
28. `/.octon/inputs/additive/extensions/octon-concept-integration/prompts/prompt-set-current-state-alignment-and-conflict-audit.md`
29. `/.octon/inputs/additive/extensions/octon-concept-integration/prompts/proposal-packet-executable-implementation-prompt-generator.md`
30. `/.octon/inputs/additive/extensions/octon-concept-integration/prompts/proposal-packet-implementation-and-closeout.md`
31. `/.octon/generated/effective/extensions/catalog.effective.yml`
32. `/.octon/generated/effective/extensions/generation.lock.yml`
33. `/.octon/generated/effective/capabilities/routing.effective.yml`
34. `/.octon/state/evidence/runs/skills/octon-concept-integration/2026-04-13-octon-concept-integration-composite-skill-implementation.md`
35. `/.octon/inputs/exploratory/proposals/architecture/octon-concept-integration-prompt-publication-and-freshness/README.md`
36. `/.octon/inputs/exploratory/proposals/architecture/octon-concept-integration-prompt-publication-and-freshness/proposal.yml`
37. `/.octon/inputs/exploratory/proposals/architecture/octon-concept-integration-prompt-publication-and-freshness/architecture-proposal.yml`
38. `/.octon/inputs/exploratory/proposals/architecture/octon-concept-integration-prompt-publication-and-freshness/navigation/source-of-truth-map.md`
39. `/.octon/inputs/exploratory/proposals/architecture/octon-concept-integration-prompt-publication-and-freshness/resources/current-state-observations.md`
40. `/.octon/inputs/exploratory/proposals/architecture/octon-concept-integration-prompt-publication-and-freshness/resources/source-artifact.md`
41. `/.octon/inputs/exploratory/proposals/architecture/octon-concept-integration-prompt-publication-and-freshness/architecture/target-architecture.md`
42. `/.octon/inputs/exploratory/proposals/architecture/octon-concept-integration-prompt-publication-and-freshness/architecture/current-state-gap-map.md`
43. `/.octon/inputs/exploratory/proposals/architecture/octon-concept-integration-prompt-publication-and-freshness/architecture/file-change-map.md`
44. `/.octon/inputs/exploratory/proposals/architecture/octon-concept-integration-prompt-publication-and-freshness/architecture/validation-plan.md`
45. `/.octon/inputs/exploratory/proposals/architecture/octon-concept-integration-prompt-publication-and-freshness/architecture/acceptance-criteria.md`
46. `/.octon/inputs/exploratory/proposals/architecture/octon-concept-integration-prompt-publication-and-freshness/architecture/implementation-plan.md`

## Profile Selection Receipt

Record and follow this profile before implementation:

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- `selection_rationale`: this is a hardening change that extends an existing
  additive pack, generated publication family, retained evidence family, and
  optional native prompt service without widening support targets or creating a
  transitional dual-truth model
- `transitional_exception_note`: not applicable unless a true hard blocker
  forces temporary coexistence of pre-hardening and post-hardening prompt
  bundle semantics

Emit a Profile Selection Receipt before implementation and retain it in your
execution evidence and output.

## Known repo and packet sensitivities

1. The concept-integration pack now treats extraction, verification, and
   proposal packet handoff as capability-managed artifacts. Preserve that
   artifact-first contract and do not regress to thread-local or user-supplied
   upstream handoff assumptions.
2. The extension publication model already emits `routing_exports` for command
   and skill contributions. Extend the existing generated-effective family;
   do not create a second prompt publication subsystem.
3. The pack is now portable across compatible Octon repos because pack-local
   prompts no longer hardcode the self-host repo and `pack.yml` now declares
   required shared contracts. Preserve that portability posture.
4. `generate-proposal-registry.sh --write` remains blocked by unrelated active
   proposal debt elsewhere in the repository. If this affects validation of
   any bounded proof packet, use packet-level validation and explicitly record
   the registry blocker instead of attributing it to this packet.
5. The current `octon-concept-integration` implementation already repaired one
   extension publication bug in `publish-extension-state.sh`. Build on the
   current live script rather than reintroducing the broken serialization
   pattern.

## Core objective

Fully implement prompt publication and freshness hardening for the
`octon-concept-integration` extension pack so prompt execution becomes
manifest-governed, published, evidence-backed, fail-closed when stale, and
traceable per run.

Completion means all of the following are true in substance, not only in
documentation:

1. An authored prompt-set manifest exists under the pack-local prompt root.
2. The manifest fully describes the stage and companion prompts, anchor refs,
   invalidation conditions, and alignment policy defaults.
3. The extension effective family publishes prompt bundle metadata or an
   equivalent first-class generated prompt publication surface.
4. Publication receipts and alignment receipts are retained under canonical
   evidence roots.
5. `alignment_mode=auto` is runtime-enforced and fail-closed.
6. `alignment_mode=skip` is explicit, retained, and degraded.
7. Every concept-integration run records prompt bundle provenance.
8. Existing extension command/skill publication, routing, and host projections
   do not regress.

## Architectural facts you must preserve

Assume and verify all of the following:

1. `framework/**` and `instance/**` remain the only authored authority roots.
2. The pack-local prompt set remains authored additive input under
   `inputs/additive/extensions/**`.
3. `generated/effective/extensions/**` remains the only runtime-facing
   extension publication family.
4. Prompt bundle publication must remain generated and non-authoritative.
5. Prompt alignment and run provenance receipts must remain retained evidence
   under `state/evidence/**`.
6. The native prompt service is preferred when it materially improves
   determinism or reduces bespoke logic, but it must not widen authority.
7. No new workflow system, capability-pack family, or support-target widening
   is allowed.

## Required implementation surfaces

Implement or update at minimum the following packet targets.

### 1. Authored prompt-set contract

Create:

- `/.octon/inputs/additive/extensions/octon-concept-integration/prompts/manifest.yml`

The manifest must define at minimum:

- prompt-set schema/version
- stage prompt ids and paths
- companion prompt ids and paths
- prompt role classes
- required live repo anchors
- prompt bundle input and output expectations
- freshness invalidation conditions
- `alignment_mode=auto` default behavior
- narrow override semantics for `alignment_mode=skip`

### 2. Effective prompt bundle publication

Extend the extension publication path so prompt bundles become runtime-facing
generated state.

Preferred surfaces:

- `/.octon/generated/effective/extensions/prompt-bundles.effective.yml`
- and, if justified, prompt asset publication under
  `/.octon/generated/effective/extensions/published/<pack-id>/<source-id>/prompts/**`

If you extend `catalog.effective.yml` instead of introducing a sibling file,
the resulting structure must still provide a stable first-class prompt bundle
record with digests, alignment status, and receipt linkage.

Do not hand-edit generated outputs.

### 3. Alignment receipt retention

Create a retained evidence family for prompt alignment, preferably under:

`/.octon/state/evidence/validation/extensions/prompt-alignment/**`

Each receipt should capture:

- prompt bundle id
- prompt manifest digest
- repo anchor digest set
- reuse versus recompute
- drift details
- safe-to-run status

### 4. Skill gating hardening

Update the concept-integration skill contract and related metadata so:

- fresh published bundle -> run allowed
- stale bundle + successful re-alignment -> publish new bundle and run
- stale bundle + failed re-alignment -> fail closed
- explicit skip -> degraded run with retained disclosure

The default runtime path must consume the effective prompt bundle and
alignment receipts, not raw prompt rereads.

### 5. Run-level prompt provenance

Update retained concept-integration run evidence so each run records:

- prompt bundle id
- prompt bundle digest
- alignment receipt id
- effective alignment mode
- fresh vs realigned vs degraded execution state

### 6. Native prompt service reuse

Evaluate the native prompt modeling service in
`/.octon/framework/capabilities/runtime/services/modeling/prompt/**`.

Prefer integrating it when doing so materially improves:

- deterministic prompt bundle rendering
- hashing
- output normalization
- fixture-backed validation

If you choose not to integrate it, justify that choice explicitly in retained
evidence and ensure equivalent deterministic behavior still exists.

## Preferred Change Path

The default implementation target is:

1. pack-local prompt manifest
2. effective prompt bundle publication
3. retained alignment receipts
4. fail-closed skill gating
5. run-level provenance
6. optional native prompt service integration where justified
7. proof runs for fresh, stale-realigned, stale-failed, and explicit-skip
   behavior

Preserve this as the default landing.

## Minimal Change Path

Use a narrower path only if live repo evidence proves the broader landing is
incorrect or blocked.

The only defensible narrowing anticipated by the packet is:

- keep deterministic bundle hashing and publication inside the extension
  publication path without extending the native prompt service, if and only if
  equivalent fail-closed behavior and provenance are still achieved

This does **not** justify dropping:

- the authored prompt-set manifest
- generated prompt publication
- retained alignment receipts
- fail-closed `alignment_mode=auto`
- or run-level prompt provenance

## Non-negotiable negative constraints

Do not do any of the following:

1. Do not make raw pack-local prompt files authoritative runtime truth.
2. Do not leave `alignment_mode=auto` as a convention-only behavior.
3. Do not make `alignment_mode=skip` silent or untracked.
4. Do not create a second generated-effective prompt subsystem outside the
   existing extension effective family without strong repo-grounded reason.
5. Do not bypass retained evidence by storing freshness state only in generated
   outputs.
6. Do not regress extension command and skill publication, capability routing,
   or host projections.
7. Do not widen support targets, capability-pack families, or workflow
   classifications by default.
8. Do not stop at analysis if implementation is feasible.

## Required validation and proof

Run or update the validations the packet requires.

At minimum, prove:

### 1. Contract validation

- authored prompt-set manifest validates structurally
- referenced prompt files and repo anchor refs exist

### 2. Effective publication validation

- extension publication emits prompt bundle metadata
- generation lock and publication receipt linkage include the new prompt
  publication surface

### 3. Alignment receipt validation

- forced alignment creates retained alignment receipts
- drift and safe-to-run state are recorded

### 4. Fail-closed execution validation

- fresh bundle run succeeds
- stale bundle re-alignment run succeeds with a new bundle
- stale bundle forced failure blocks execution
- explicit skip run succeeds only with degraded retained disclosure

### 5. Run provenance validation

- concept-integration run evidence records prompt bundle id, digest, and
  alignment receipt id

### 6. Regression validation

- extension publication still passes
- capability routing still passes
- host projections still pass

When proposal-registry regeneration interferes with bounded proof packets, use:

- `validate-proposal-standard.sh --package <packet-path> --skip-registry-check`
- `validate-architecture-proposal.sh --package <packet-path>`

and record the unrelated registry blocker explicitly.

## Required output structure

Your final output must include:

### 1. Orchestrator Decision

- goal
- plan
- delegations, if any
- verification approach
- immediate next step

### 2. Profile Selection Receipt

- `release_state`
- `change_profile`
- rationale
- any transitional exception note

### 3. Execution Summary

State:

- what packet inputs were used
- what scope was executed
- whether packet drift was detected
- what was implemented
- what prompt publication model was chosen
- and the resulting closeout status

### 4. Packet Drift Notes

List any live repo facts that changed the intended implementation path,
including:

- current extension publication realities
- current concept-integration pack behavior
- native prompt service realities
- registry blocker effects on proof runs

### 5. Implementation Ledger

For each in-scope packet item, provide:

- packet item
- execution status
- implemented target surfaces
- Preferred Change Path status
- Minimal Change Path usage, if any
- validation status
- evidence status
- residual blockers
- closeout impact

### 6. Validation And Proof

Summarize:

- validators and publication scripts run
- what passed
- what failed
- what could not be run
- what receipts or run evidence were retained
- and whether all four prompt freshness behaviors were proven

### 7. File Change Map

List every durable repo artifact that changed, including pack-local prompt
contract surfaces, framework publication/validator/service surfaces, retained
evidence roots, and intentionally untouched generated outputs.

### 8. Residuals And Revisions

List anything that still needs:

- more implementation
- more validation
- a follow-on packet
- or explicit deferral

### 9. Closeout Verdict

Conclude with explicit answers to:

- what was actually implemented
- whether prompt publication and freshness hardening is operational
- what remains blocked or deferred
- whether the executed scope is closeout-ready
- what evidence supports that verdict
- what the immediate next step should be

## Final instruction

Fully implement the packet against the live repository when feasible.

If a true hard blocker appears, stop at the correct boundary and say so
plainly. Do not stop at analysis if execution is feasible.

After any turn that changes files, ask exactly:

`Are you ready to closeout this branch?`
