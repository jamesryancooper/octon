---
title: Bounded Surfaces Contract
description: Contract for separating runtime artifacts, governance contracts, and operating practices into explicit subsystem surfaces.
status: Active
---

# Bounded Surfaces Contract

## Purpose

Define a reusable repository-level contract for separating three concerns in each applicable subsystem:

- runtime artifacts (what executes),
- governance contracts (what constrains behavior),
- operating practices (how work is performed).

This reduces semantic ambiguity and makes contract enforcement deterministic for both humans and AI agents.

## Contract Rules

For subsystems that define executable actors or runtime-routing artifacts:

1. Runtime artifacts MUST live under a dedicated `runtime/` surface.
2. Governance contracts MUST live under `governance/` and remain the only normative policy source for that subsystem.
3. Operating standards MUST live under `practices/`.
4. `_meta/` MUST remain non-structural architecture/reference documentation only.
5. A subsystem MUST NOT keep dual active locations for the same contract class (no old and new paths in parallel).
6. Discovery metadata (manifest/registry) MUST resolve only to canonical surfaces.
7. CI validation MUST fail when deprecated legacy paths reappear.
8. `runtime/` vs `_ops/` artifact placement MUST follow the
   [Runtime vs Ops Surface Contract](./runtime-vs-ops-contract.md).

## Agency Application (First Migration)

Agency is the first subsystem applying this contract:

- runtime artifacts: `/.octon/agency/runtime/`
- governance contracts: `/.octon/agency/governance/`
- operating standards: `/.octon/agency/practices/`

Legacy root-level actor and governance paths are removed as part of the clean-break migration.

## Orchestration Application (Second Migration)

Orchestration applies the same contract:

- runtime artifacts: `/.octon/orchestration/runtime/`
- governance contracts: `/.octon/orchestration/governance/`
- operating standards: `/.octon/orchestration/practices/`

Legacy root-level runtime and governance paths (`workflows/`, `missions/`, root incident docs) are removed as part of the clean-break migration.

## Capabilities Application (Third Migration)

Capabilities applies the same contract:

- runtime artifacts: `/.octon/capabilities/runtime/`
- governance contracts: `/.octon/capabilities/governance/`
- operating standards: `/.octon/capabilities/practices/`

Legacy root-level capability runtime and governance paths (`commands/`, `skills/`, `tools/`, `services/`, `_ops/policy/`) are removed as part of the clean-break migration.

## Assurance Application (Fourth Migration)

Assurance applies the same contract:

- runtime artifacts: `/.octon/assurance/runtime/`
- governance contracts: `/.octon/assurance/governance/`
- operating standards: `/.octon/assurance/practices/`

Legacy root-level assurance contracts and runtime surfaces (`CHARTER.md`,
`DOCTRINE.md`, `CHANGELOG.md`, `complete.md`, `session-exit.md`,
`standards/`, `trust/`, `_ops/scripts/`, `_ops/state/`) are removed as part
of the clean-break migration.

## Scaffolding Application (Fifth Migration)

Scaffolding applies the same contract:

- runtime artifacts: `/.octon/scaffolding/runtime/`
- governance contracts: `/.octon/scaffolding/governance/`
- operating standards: `/.octon/scaffolding/practices/`

Legacy root-level scaffolding surfaces (`templates/`, `prompts/`, `examples/`,
`patterns/`, `_ops/scripts/`) are removed as part of the clean-break migration.

## Engine Application (Sixth Migration)

Engine applies the same contract:

- runtime artifacts: `/.octon/engine/runtime/`
- governance contracts: `/.octon/engine/governance/`
- operating standards: `/.octon/engine/practices/`

Legacy top-level runtime domain path (`/.octon/runtime/`) is removed as part
of the clean-break migration.

## Cognition Application (Seventh Migration)

Cognition applies the same contract:

- runtime artifacts: `/.octon/cognition/runtime/`
- governance contracts: `/.octon/cognition/governance/`
- operating standards: `/.octon/cognition/practices/`

Legacy root-level cognition surfaces (`context/`, `decisions/`, `analyses/`,
`knowledge-plane/`, `principles/`, `pillars/`, `purpose/`, `methodology/`) are
removed as part of the clean-break migration.

## Domain Profile Registry

Top-level domain profile classification is governed by:

- `/.octon/cognition/governance/domain-profiles.yml`

Profiles are explicit and validator-enforced:

- `bounded-surfaces`: domain must expose `runtime/`, `governance/`, and
  `practices/`.
- `state-tracking`: domain is continuity/state storage, not a bounded-surface
  triad.
- `human-led`: domain is explicitly human-led and must not be force-fit into
  autonomous runtime/governance/practices surfaces.
- `artifact-sink`: domain is an output sink and must not be force-fit into
  runtime/governance/practices surfaces.

## Applicability Boundary (Current State)

As of 2026-02-21, the remaining top-level domains are intentionally **not**
migrated to `runtime/governance/practices` because they do not naturally carry
all three concern classes:

- `/.octon/continuity/`: state-tracking domain; no distinct runtime/governance
  split.
- `/.octon/ideation/`: human-led workspace; no runtime/governance/practices
  triad.
- `/.octon/output/`: artifact sink; no runtime/governance/practices triad.

Rule: apply bounded surfaces only when all three surfaces are materially
present and independently owned; otherwise do not force-fit the domain.

## Benefits

| Benefit | Why It Matters |
|---|---|
| Boundary clarity | Eliminates mixed-purpose roots and ambiguous ownership. |
| Stronger correctness | Routing and contract checks target a single canonical location. |
| Better governance | Policy contracts become explicit and auditable as a dedicated surface. |
| Lower regression risk | CI can ban reintroduction of deprecated paths precisely. |
| Better agent behavior | AI execution is less error-prone with clear structural semantics. |

## Risks and Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| Over-normalization across domains | Imposes structure where it adds no value | Apply the contract only where runtime/governance/practice boundaries are meaningful. |
| Migration drift | Partial updates break references and validation | Use clean-break migrations with one-shot path replacement and CI gate updates in the same change set. |
| Documentation lag | Users follow outdated paths | Update START/README/spec/docs indexes in the same migration and fail on stale references. |
| Tooling mismatch | Scripts/CI still expect legacy paths | Update validators and discovery checks before merge. |
| Historical artifact confusion | Old ADR/log references appear inconsistent | Preserve append-only history; scope enforcement to active contract surfaces. |

## Rollout Guidance

1. Establish subsystem-local migration plan and banlist entries.
2. Migrate one subsystem at a time as a clean-break.
3. Enforce via CI before propagating to the next subsystem.
