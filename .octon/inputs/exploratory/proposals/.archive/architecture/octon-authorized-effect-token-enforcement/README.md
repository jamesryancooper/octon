# Octon Authorized Effect Token Enforcement and Boundary Coverage

## Purpose

This packet defines the implementation-ready architecture proposal for the next highest-leverage Octon hardening step after the canonical append-only Run Journal:

> Implement **Authorized Effect Token** enforcement across every material path family, then prove coverage with negative bypass tests.

The proposal is intentionally narrow. It does not redesign Octon’s Constitutional Engineering Harness, does not admit new support targets, does not create a rival Control Plane, and does not introduce a new top-level authority model. It converts Octon’s existing engine-owned authorization doctrine into a mechanically enforceable runtime invariant: **no material side effect can occur unless the callee receives and verifies a valid, typed, in-scope, unexpired Authorized Effect Token derived from the current Run’s authority decision.**

## Current repo posture this packet assumes

The live Octon repository already has the key prerequisites:

- `/.octon/` is the authoritative super-root.
- `framework/**` and `instance/**` are authored authority.
- `state/control/**` carries mutable execution/control truth.
- `state/evidence/**` carries retained evidence and validation receipts.
- `generated/**` remains derived-only and never mints authority.
- `inputs/**`, including this proposal, remains non-authoritative.
- material execution is already declared subordinate to `authorize_execution(request: ExecutionRequest) -> GrantBundle`.
- the runtime already has an `authorized_effects` crate and an `authorized-effect-token-v1.md` contract, but those surfaces are not yet complete enough to prove enforcement across every material path family.

## Executive triage

This packet is high leverage because Octon already has strong governance contracts, but the remaining risk is the gap between **authorization as a documented boundary** and **authorization as the only consumable runtime object that side-effect APIs will accept**.

The packet closes that gap by requiring:

1. typed token minting only from the Governed Agent Runtime’s authorization boundary or an engine-owned projection of a successful grant;
2. token lifecycle materialization in canonical run control/evidence roots and the canonical Run Journal;
3. side-effect APIs hardened so material actions require verified typed tokens rather than raw paths, ambient grants, or caller assertions;
4. material path family inventory and negative bypass tests proving direct calls fail closed;
5. validator and assurance proof coverage before closure.

## In scope

- Authorized Effect Token model hardening.
- Token lifecycle events and receipts.
- Runtime API signature hardening for material side-effect APIs.
- Material path inventory completion.
- Negative bypass tests and validators.
- Repo-shell and CI-control-plane support-target alignment where already live.
- Evidence and Run Journal integration for token minting, verification, consumption, denial, revocation, expiry, and rejection.

## Out of scope

- New browser/API/frontier support target admission.
- New multi-agent orchestration.
- New memory subsystem.
- Replacing `authorize_execution`.
- A new Control Plane.
- Treating generated/read-model artifacts as authority.
- Making this proposal packet itself a runtime dependency.
- Editing `.github/**` as a promotion target. If CI does not auto-discover the new validators, a linked repo-local change should wire them into CI because the active proposal standard forbids mixed `.octon/**` and non-`.octon/**` promotion targets in one active packet.

## Recommended reading order

1. `navigation/source-of-truth-map.md`
2. `resources/architectural-evaluation.md`
3. `resources/implementation-gap-analysis.md`
4. `resources/repository-baseline-audit.md`
5. `architecture/current-state-gap-map.md`
6. `architecture/target-architecture.md`
7. `architecture/file-change-map.md`
8. `architecture/implementation-plan.md`
9. `architecture/validation-plan.md`
10. `architecture/acceptance-criteria.md`
11. `architecture/closure-certification-plan.md`

## Non-authority notice

This packet lives under `/.octon/inputs/exploratory/proposals/**`. It is temporary proposal material and is never canonical runtime, governance, policy, control, evidence, or generated authority. Promotion targets must stand alone after implementation and must not depend on this proposal path.
