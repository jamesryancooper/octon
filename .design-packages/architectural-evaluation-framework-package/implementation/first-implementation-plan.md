# First Implementation Plan

## Phase 1: Durable Methodology

Create:

- `/.harmony/cognition/practices/methodology/architecture-readiness/README.md`
- `/.harmony/cognition/practices/methodology/architecture-readiness/framework.md`

Acceptance criteria:

- supported targets are explicit
- unsupported domain profiles are explicit
- live docs do not reference `/.design-packages/`

## Phase 2: Audit Skill

Create:

- `/.harmony/capabilities/runtime/skills/audit/audit-architecture-readiness/SKILL.md`
- required references, registry entries, manifest entries, and output contract

Acceptance criteria:

- target classification is deterministic
- whole-harness and bounded-domain modes are supported
- unsupported profiles return `not-applicable` or equivalent refusal outcome
- scorecard, failure-mode analysis, and remediation plan are emitted

## Phase 3: Audit Workflow

Create:

- `/.harmony/orchestration/runtime/workflows/audit/audit-architecture-readiness/workflow.yml`
- generated `README.md`
- stage assets for configure, classify, evaluate, optional supplemental audits,
  merge, report, and verify

Acceptance criteria:

- whole-harness mode can optionally call coherence audit
- bounded-domain mode can optionally call domain architecture audit
- output bundle is deterministic and self-describing

## Phase 4: ADR Pattern Promotion

Create:

- `/.harmony/scaffolding/governance/patterns/adr-architecture-readiness-matrix.md`

Acceptance criteria:

- matrix is reusable without the package
- pattern references live methodology, not this package

## Phase 5: Assurance Hooks

Update as needed:

- skill/workflow manifests and registries
- package-specific or live-surface validation scripts
- any test fixtures needed for the new skill/workflow

Acceptance criteria:

- live validation passes
- package can be archived without breaking live surfaces
