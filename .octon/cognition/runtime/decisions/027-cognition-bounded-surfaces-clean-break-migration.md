# ADR 027: Cognition Bounded Surfaces Clean-Break Migration

- Date: 2026-02-20
- Status: Accepted
- Deciders: Octon maintainers
- Supersedes: legacy cognition root surface layout in active docs/contracts/validators

## Context

Cognition previously mixed runtime artifacts, governance contracts, and operating methodology in root-level directories (`context/`, `decisions/`, `analyses/`, `knowledge-plane/`, `principles/`, `pillars/`, `purpose/`, `methodology/`).

This layout created ambiguous ownership boundaries and made automated policy enforcement harder because active and historical path semantics were not clearly separated.

The repository already adopted bounded surfaces in other domains. Cognition now materially carries all three concern classes and should be normalized to the same clean-break contract.

## Decision

Adopt bounded cognition surfaces and enforce them as canonical:

- `/.octon/cognition/runtime/` for runtime cognition artifacts
- `/.octon/cognition/governance/` for normative cognition contracts
- `/.octon/cognition/practices/` for operating methodology
- `/.octon/cognition/_ops/` for mutable cognition operational scripts/state
- `/.octon/cognition/_meta/` for non-structural architecture/reference documentation

Remove legacy root cognition surfaces in the same migration and update validators/guardrails to fail on reintroduction.

## Consequences

### Benefits

- Architectural clarity: one canonical surface per concern class.
- Correctness: deterministic path resolution in docs, scripts, and validators.
- Stronger governance: principles/pillars/purpose are isolated as explicit normative contracts.
- Better agent behavior: reduced ambiguity for routing, path discovery, and enforcement.

### Risks

- Broad reference churn can leave stale paths.
- Guard scripts and fixtures can drift during large path replacement.
- Historical append-only artifacts still mention legacy paths.

### Mitigations

- One-shot clean-break replacement of active call-sites, validators, and contracts.
- Enforce deprecated cognition-path checks in harness validation.
- Keep historical append-only records unchanged and scope enforcement to active surfaces.
- Record migration evidence and banlist updates in the same change set.
