# Profile Selection And Compliance

Historical note: this is the creation-time governance receipt for the package.
It is retained for provenance. It is not a primary source of orchestration
runtime behavior.

## Profile Selection Receipt

- `change_profile`: `atomic`
- `release_state`: `pre-1.0`
- Release-state basis:
  - executable runtime artifacts in-repo still include `0.1.0` versions, which
    is sufficient evidence to treat the harness as pre-1.0 for profile
    selection.
- Downtime tolerance:
  - not applicable; package-local specification work only
- External consumer coordination:
  - none required
- Data migration or backfill:
  - none
- Rollback mechanism:
  - revert or replace proposal files under
    `.design-packages/orchestration-domain-design-package/`
- Blast radius and uncertainty:
  - low blast radius, documentation-only
- Compliance and policy constraints:
  - proposal must preserve Harmony's explicit authority model:
    `agent-first`, `system-governed`, human-owned policy authorship, exception
    handling, and escalation authority
- Hard gates for `transitional`:
  - none met

## Implementation Plan

1. Document the mature orchestration model and its design principles.
2. Define a canonical taxonomy and hierarchy for the proposed surfaces.
3. Describe the layered model, runtime shape, and end-to-end execution flow.
4. Write a dedicated specification document for each orchestration surface.
5. Add explicit decision evidence, queue claim, and automation overlap
   contracts where cross-surface behavior would otherwise drift.
6. Capture criticality, complexity, usefulness, and need ranking across all
   surfaces.
7. Provide a charter example and a phased adoption roadmap.

## Impact Map (code, tests, docs, contracts)

### Code

- No production code changes proposed or implemented.

### Tests

- No test changes proposed or implemented.

### Docs

- New specification package content under
  `.design-packages/orchestration-domain-design-package/`
- Scope includes model overview, taxonomy, charter, surface specifications,
  directory structures, diagrams, and adoption roadmap

### Contracts

- Adds decision evidence, queue claim, and automation overlap semantics to the
  proposal contract set
- The package defines package-local orchestration contract shapes, but does not
  alter any live authority surfaces

## Compliance Receipt

- Preserves Harmony's objective of safe, reviewable, verifiable, autonomous use
  rather than unconstrained autonomy
- Keeps governance authority explicit instead of embedding governance implicitly
  inside runtime execution surfaces
- Separates:
  - procedure definition (`workflows`)
  - multi-session intent (`missions`)
  - recurrence/triggering (`automations`)
  - observation (`watchers`)
  - intake buffering (`queue`)
  - execution evidence (`runs`)
  - exception handling (`incidents`)
  - portfolio coordination (`campaigns`)
- Favors minimal sufficient complexity by treating only `workflows`,
  `missions`, and `runs` as mature-core surfaces, with the others layered in
  only when operating load justifies them

## Exceptions/Escalations

- No exceptions requested
- No profile tie-break ambiguity encountered
- No direct governance contract changes proposed
- Decision evidence expands into a dedicated continuity target, but only at the
  proposal level in this package
