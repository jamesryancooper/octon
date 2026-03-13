# Runtime Architecture

## Purpose

Describe the durable Octon surfaces and interactions required to implement the
architecture-readiness framework.

## Components

### Methodology Surface

- location:
  `/.octon/cognition/practices/methodology/architecture-readiness/`
- responsibility:
  - explain target applicability
  - explain dimensions and hard gates
  - explain how the framework interacts with other audits

### Primary Audit Skill

- location:
  `/.octon/capabilities/runtime/skills/audit/audit-architecture-readiness/`
- responsibility:
  - classify the target
  - collect evidence
  - score dimensions
  - analyze failure modes
  - emit remediation guidance and final verdict

### Orchestration Workflow

- location:
  `/.octon/orchestration/runtime/workflows/audit/audit-architecture-readiness/`
- responsibility:
  - coordinate larger-scope runs
  - invoke optional supplemental audits
  - merge evidence into one deterministic bundle

### ADR Pattern

- location:
  `/.octon/scaffolding/governance/patterns/adr-architecture-readiness-matrix.md`
- responsibility:
  - provide a reusable architecture-readiness gate for ADR review

## Interaction Model

1. Methodology docs define the live interpretation of the framework.
2. The skill implements the primary audit logic.
3. The workflow orchestrates multi-pass or supplemental runs when needed.
4. Existing audits may provide evidence:
   - `audit-cross-subsystem-coherence` for whole-harness alignment
   - `audit-domain-architecture` for bounded-domain external critique
5. The ADR pattern reuses the same conceptual gates for design-review decisions.

## Integration Decision

Use **new** live surfaces for the framework. Reuse existing audits by
composition only.

Do not:

- repurpose `evaluate-harness`
- repurpose `evaluate-workflow`
- overwrite `audit-domain-architecture` semantics
- turn the release-readiness workflow into an architecture-readiness framework
