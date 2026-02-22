# Cognition

The cognition domain is split into bounded surfaces so runtime artifacts,
governance contracts, and operating methodology remain explicit.

## Surface Map

| Surface | Purpose | Canonical Index |
|---|---|---|
| `runtime/` | Authoritative cognition artifacts (`context/`, `decisions/`, `analyses/`, `knowledge-plane/`, `migrations/`, `evidence/`, `evaluations/`, `projections/`) | `runtime/index.yml` |
| `governance/` | Normative principles, controls, pillars, purpose, and exception contracts | `governance/index.yml` |
| `practices/` | Operating methodology and execution runbooks | `practices/index.yml`, `practices/methodology/index.yml`, `practices/operations/index.yml` |
| `_ops/` | Mutable scripts/state for cognition guardrails | `_ops/README.md` |
| `_meta/` | Non-structural architecture/reference docs | `_meta/architecture/index.yml` |

## Interaction Model

Use runtime context as operational reference material and governance principles
as normative policy constraints.

### Key Runtime Context Files

| File | When to Read |
|---|---|
| `runtime/context/constraints.md` | Before any work - know hard limits |
| `runtime/context/decisions.md` | Before making decisions that might duplicate past choices |
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

- `runtime/context/decisions.md` is append-only. Never modify existing entries.
- All files in `runtime/decisions/` are append-only (full ADRs).
- Other runtime context files are mutable.
