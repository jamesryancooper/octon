---
schema_version: "objective-brief-v1"
objective_id: "octon-governed-harness"
intent_id: "intent://octon/octon-governed-harness"
intent_version: "1.1.0"
owner: "Octon governance"
approved_by: "Octon governance"
generated_at: "2026-03-26T00:00:00Z"
objective_layer: "workspace-charter-pair"
constitutional_role: "workspace-charter-narrative"
constitutional_objective_ref: ".octon/framework/constitution/contracts/objective/workspace-charter-pair.yml"
release_state: "pre-1.0"
change_profile: "atomic"
profile_selection_receipt_ref: ".octon/instance/cognition/context/shared/migrations/2026-03-28-unified-execution-constitution-phase2-objective-authority-cutover/plan.md"
shim_status: "compatibility-shim"
canonical_ref: ".octon/instance/charter/workspace.md"
---

# Objective Shim: Octon Governed Harness

> Shim status: This file is a compatibility projection of the canonical
> workspace charter at `/.octon/instance/charter/workspace.md`. Runtime and
> constitutional bindings now resolve through the canonical `instance/charter`
> pair, not this bootstrap shim.

## Workspace Goal

Octon is a portable harness that turns any repository into a governed autonomous engineering environment.
Use Octon in `octon` to evolve the harness itself with safe, reviewable, and
verifiable changes.

## Constitutional Role

This file is the bootstrap-path shim for the narrative side of Octon's
workspace-charter pair. Consequential runs bind the canonical instance charter
under `/.octon/instance/charter/workspace.md` together with the machine charter
and a per-run contract under
`/.octon/state/control/execution/runs/<run-id>/run-contract.yml`.

## What Octon Should Optimize For

- correctness and coherence of the harness runtime, governance, and bootstrap model
- portability and self-containment across repositories and agent environments
- deterministic validation, safe autonomy boundaries, and clear operational evidence
- constitutional objective binding that keeps mission continuity distinct from
  per-run execution authority

## In Scope

- `.octon/` runtime, governance, practices, and scaffolding surfaces in this repository
- harness tooling, validation, docs, workflows, and bootstrap behavior
- repo-local changes that materially improve Octon's reliability, portability, or operator clarity

## Out of Scope

- unrelated product work outside the managed repository
- silent weakening of governance, assurance, or fail-closed behavior
- destructive or externally effectful actions without the required approval path

## Success Signals

- bootstrap and execution surfaces remain self-contained, discoverable, and internally consistent
- active docs, validators, and runtime behavior agree on the same authority model
- changes ship with enough evidence and verification to trust autonomous use of the harness

## Initial Focus

- keep authored governance surfaces canonical and generated ingress surfaces deterministic
- tighten validation whenever architecture or bootstrap paths change materially
- prefer the smallest robust refactor that reduces drift and preserves portability
