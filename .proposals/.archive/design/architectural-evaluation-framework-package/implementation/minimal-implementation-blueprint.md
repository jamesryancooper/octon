# Minimal Implementation Blueprint

## Goal

Deliver the smallest robust Octon implementation of the architectural
evaluation framework without forcing it onto unsupported domain profiles.

## Minimum Live Slice

### 1. Durable Methodology Docs

Create:

- `/.octon/cognition/practices/methodology/architecture-readiness/README.md`
- `/.octon/cognition/practices/methodology/architecture-readiness/framework.md`

Purpose:

- define supported targets
- define applicability boundaries
- define scorecard dimensions, failure-mode expectations, and remediation rules

### 2. Primary Runtime Capability

Create:

- `/.octon/capabilities/runtime/skills/audit/audit-architecture-readiness/`

Required behavior:

- accept `target_path` and classify the target
- allow only `/.octon/` whole-harness mode and bounded-surface top-level
  domain mode
- emit weighted score summary, hard-gate failures, critical/high gaps,
  failure-mode assessment, and file-level remediation guidance
- treat unsupported targets as `not-applicable` rather than forced failures

### 3. Optional Supplemental Evidence

Reuse without semantic takeover:

- `audit-cross-subsystem-coherence` for whole-harness evidence
- `audit-domain-architecture` for bounded-domain supplemental evidence

The new capability should own the final readiness verdict. Existing audits stay
specialized inputs, not replacements.

### 4. Whole-Harness Orchestration

Create after the skill:

- `/.octon/orchestration/runtime/workflows/audit/audit-architecture-readiness/`

Workflow role:

- dispatch the primary skill
- optionally run supplemental audits
- merge evidence into one report and bundle

### 5. ADR Pattern

Promote:

- `adr-acceptance-matrix.md` into
  `/.octon/scaffolding/governance/patterns/adr-architecture-readiness-matrix.md`

## Explicit Non-Goals

- do not retrofit the framework onto `continuity`, `ideation`, or `output`
- do not turn `/.design-packages/` into a live dependency
- do not change `audit-domain-architecture` to become Octon-doctrine-first

## Minimal Acceptance Gate

The first live version is acceptable when:

1. target classification prevents unsupported scopes from being force-fit
2. the skill can audit `/.octon/`
3. the skill can audit one bounded-surface domain such as
   `/.octon/capabilities/`
4. the output report follows the framework scorecard and remediation structure
5. no canonical artifact retains a dependency on this package
