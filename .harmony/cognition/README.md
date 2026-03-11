# Cognition

The cognition domain is split into bounded surfaces so runtime artifacts,
governance contracts, and operating methodology remain explicit.
Enable reliable agent execution that is deterministic enough to trust, observable enough to debug, and flexible enough to evolve.

## Surface Map

| Surface | Purpose | Canonical Index |
|---|---|---|
| `./` | Cognition domain root discovery and routing map | `index.yml` |
| `runtime/` | Authoritative cognition artifacts (`context/`, `decisions/`, `analyses/`, `knowledge/`, `migrations/`, `evidence/`, `evaluations/`, `projections/`) | `runtime/index.yml` |
| `governance/` | Normative principles, controls, pillars, purpose, and exception contracts | `governance/index.yml` |
| `practices/` | Operating methodology and execution runbooks | `practices/index.yml`, `practices/methodology/index.yml`, `practices/operations/index.yml` |
| `_ops/` | Mutable scripts/state for cognition guardrails | `_ops/overview.md` |
| `_meta/` | Non-structural architecture/reference docs and discovery maps | `_meta/architecture/index.yml`, `_meta/docs/index.yml` |

## Convention Authority

- Domain-local naming, authoring, and operating conventions belong in `practices/`.
- `_meta/architecture/` is reference architecture, not the canonical conventions surface.
- Cross-domain baseline conventions come from `/.harmony/conventions.md`.

## Interaction Model

Use runtime context as operational reference material and governance principles
as normative policy constraints.

### Key Runtime Context Files

| File | When to Read |
|---|---|
| `runtime/context/constraints.md` | Before any work - know hard limits |
| `runtime/context/decisions.md` | Before making decisions that might duplicate past choices |
| `runtime/context/memory-map.md` | Before adding memory artifacts or changing memory placement |
| `runtime/context/lessons.md` | Before proposing approaches (check anti-patterns) |
| `runtime/context/glossary.md` | When encountering harness-specific terms |
| `runtime/context/glossary-repo.md` | When encountering repo-wide terms |
| `runtime/context/primitives.md` | When deciding what type of artifact to create |
| `runtime/index.yml` | When discovering runtime surfaces and their canonical indexes |
| `runtime/decisions/index.yml` | When discovering canonical ADR records |
| `runtime/migrations/index.yml` | When discovering canonical migration plan records |
| `runtime/evidence/index.yml` | When resolving evidence bundles linked to runtime records |
| `runtime/evaluations/index.yml` | When reviewing periodic scorecard digests and evaluation history |

### Mutability

- `runtime/context/decisions.md` is generated from ADR metadata. Do not edit manually.
- All files in `runtime/decisions/` are append-only (full ADRs).
- Other runtime context files are mutable.
