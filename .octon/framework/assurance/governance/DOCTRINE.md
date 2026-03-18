# Assurance Doctrine

## Why This Change Happened

Octon previously centralized legitimacy concerns under `quality/`. That name
captured standards and gates, but it underrepresented governance authority and
trust evidence. The migration to `assurance/` formalizes legitimacy as a first-
class domain.

## Architectural Rationale

Assurance is the subsystem that binds:

- quality: what is measured and how well it performs against target attributes
- governance: who can change policy and under what precedence/override rules
- trust: what evidence, attestations, and audits prove outcomes are legitimate

This aligns with Octon's priority lens:

`Assurance > Productivity > Integration`

## Domain Relationships

Assurance connects and constrains adjacent domains:

- Agency: sets autonomy boundaries and validates approval/checkpoint contracts.
- Capabilities: verifies command, skill, and service changes against policy.
- Orchestration: enforces workflow-level gates before promotion or release.
- Runtime: validates executable behavior and policy resolver determinism.
- Continuity: records decisions, traceability, and operational evidence over time.

## Operational Model

Assurance operates through four layered surfaces:

1. Standards: score and weight definitions for measurable attributes.
2. Governance: precedence model, subsystem classes, and deviation controls.
3. Enforcement: local/CI resolver and gate execution scripts.
4. Trust Evidence: attestations, audit artifacts, and generated reports.

## Binding Statement

Quality is a dimension.  
Governance is a mechanism.  
Trust is an outcome.  
Assurance is the system that binds them.

## Umbrella Contract

Assurance applies umbrella rollups while preserving attribute-level source of
truth:

- **Assurance umbrella**: confidence, safety, correctness, explainability
- **Productivity umbrella**: throughput, low friction, bounded autonomy
- **Integration umbrella**: cross-repo/environment/tool compatibility

Rollups are used for deterministic ordering and reporting. Attribute-level
scores and evidence remain canonical for scoring and gates.
