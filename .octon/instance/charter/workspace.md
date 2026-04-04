---
schema_version: "objective-brief-v1"
objective_id: "octon-governed-harness"
intent_id: "intent://octon/octon-governed-harness"
intent_version: "1.1.0"
owner: "Octon governance"
approved_by: "Octon governance"
generated_at: "2026-03-28T00:00:00Z"
objective_layer: "workspace-charter-pair"
constitutional_role: "workspace-charter-narrative"
constitutional_objective_ref: ".octon/framework/constitution/contracts/objective/workspace-charter-pair.yml"
release_state: "pre-1.0"
change_profile: "atomic"
profile_selection_receipt_ref: ".octon/instance/cognition/context/shared/migrations/2026-04-03-uec-clean-break-packet-implementation/plan.md"
---

# Workspace Charter: Octon Governed Harness

## Workspace Goal

Octon is an authored harness core designed for profile-driven portability and
replaceable adapters across repositories. Use Octon in `octon` to evolve the
harness itself with safe, reviewable, and verifiable changes.

The currently proved live consequential envelope in this repository is the
retained `MT-B / WT-2 / LT-REF / LOC-EN` tuple using the `repo-shell` host
adapter and the `repo-local-governed` model adapter. Broader portability or
adapter coverage remains architectural intent until support targets and
retained disclosure proof promote it into a live claim.

## Constitutional Role

This workspace charter is the narrative side of Octon's canonical
instance-owned workspace-charter pair. Every consequential run must bind this
workspace charter together with the machine charter and a per-run contract
under `/.octon/state/control/execution/runs/<run-id>/run-contract.yml`.
Mission authority remains the continuity container and long-horizon autonomy
surface, but it no longer substitutes for the bound run contract as the atomic
execution unit.

## What Octon Should Optimize For

- correctness and coherence of the harness runtime, governance, and bootstrap model
- profile-driven portability and self-containment intent without claiming live
  support beyond retained disclosure proof
- deterministic validation, safe autonomy boundaries, and clear operational evidence
- constitutional objective binding that keeps mission continuity distinct from
  per-run execution authority

## In Scope

- `.octon/` runtime, governance, practices, and scaffolding surfaces in this repository
- harness tooling, validation, docs, workflows, and bootstrap behavior
- repo-local changes that materially improve Octon's reliability, portability
  intent, or operator clarity

## Out of Scope

- unrelated product work outside the managed repository
- silent weakening of governance, assurance, or fail-closed behavior
- destructive or externally effectful actions without the required approval path

## Success Signals

- bootstrap and execution surfaces remain self-contained, discoverable, and
  internally consistent within the proved repo-local governed envelope
- active docs, validators, and runtime behavior agree on the same authority model
- changes ship with enough evidence and verification to trust autonomous use of the harness

## Initial Focus

- keep authored governance surfaces canonical and generated ingress surfaces deterministic
- tighten validation whenever architecture or bootstrap paths change materially
- prefer the target-state-correct refactor that removes authority drift and
  preserves portability intent without widening live support claims
