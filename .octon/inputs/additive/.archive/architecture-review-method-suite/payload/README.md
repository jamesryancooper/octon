# Architecture Review Method Suite Intake

This payload is an architect handoff for creating a proposal program around
Octon's Architecture Review Method Suite.

## Purpose

Create a coherent architecture-review methodology suite that keeps Balanced
Architecture Review as the default general method, adds focused companion
methods, and introduces a shared architecture lens bank so reviews can be deep
without becoming unbounded or duplicative.

The complete conversation-derived source notes are retained in
`conversation-source-notes.md`. Use this README as the architect handoff
summary and the source notes as the completeness backstop.

## Existing Context To Read

- `.octon/framework/cognition/practices/methodology/architectural-review/balanced-architecture-review-method.md`
- `.octon/framework/cognition/practices/methodology/architectural-review/README.md`
- `.octon/framework/cognition/practices/methodology/architectural-review/review-routing.yml`
- `.octon/framework/cognition/practices/methodology/architectural-review/naming.yml`
- `.octon/framework/cognition/practices/methodology/architecture-readiness/README.md`
- `.octon/framework/cognition/practices/methodology/architecture-readiness/framework.md`
- `.octon/framework/cognition/practices/methodology/audits/surface-architecture.md`
- `.octon/framework/product/features/architectural-review-mechanism.md`

## Current Doctrine To Preserve

Balanced Architecture Review remains the default general-purpose architecture
review method. It frames the decision, identifies the system job, maps current
reality, steelmans the current design, applies Chesterton's Fence, separates
essential from accidental complexity, uses clean-sheet comparison, and produces
a realistic target architecture with authority, evidence, validation, rollback,
and revisit triggers.

Clean-sheet and greenfield are related but not identical:

- Clean-sheet is an idealized comparison lens inside a broader review.
- Greenfield is a practical starting-state method for new systems, new
  subsystems, or major replacement candidates.

## Proposed Suite Name

Architecture Review Method Suite

## Core Design Rule

Methods own the question, scope, routing, and output contract. Lenses are
reusable analysis tools selected by methods.

## Proposed Methods

### Balanced Architecture Review

Default general review. Use when evaluating existing architecture change and
comparing current state against clean-sheet and realistic targets.

### Greenfield Reference Architecture Review

Use for new systems, new subsystems, or major replacement candidates. It
defines what should be built from zero, including initial architecture,
sequencing, evidence model, governance posture, risks, and what not to build
yet. Output is reference architecture, not implementation authority.

### Architecture Tradeoff Review

Use for explicit option comparison. It should capture candidate designs,
quality attributes, tradeoffs, risks, reversibility, decision recommendation,
and ADR guidance.

### Failure-Mode Architecture Review

Use for runtime-critical or governance-critical surfaces. It reviews how the
system fails, drifts, gets bypassed, partially executes, loses evidence, fails
rollback, or confuses operators.

### Evolution/Fitness Architecture Review

Use for long-lived mechanisms. It defines architectural fitness functions,
drift triggers, retirement triggers, compatibility posture, validator needs,
and revisit cadence.

### Boundary/Authority Architecture Review

Octon-specific. It reviews where authority actually lives and prevents prose,
generated outputs, raw inputs, chat, host state, dashboards, or model memory
from becoming accidental control surfaces.

### Shared Architecture Lens Bank

Reusable lens catalog used by the methods above. The suite should use one
shared lens bank rather than separate large lens banks per method.

## Candidate Lens Bank

- System job and mission framing
- Domain model, bounded contexts, and capability map
- C4 and 4+1 architecture views
- Quality attribute scenarios
- Tradeoff analysis and ADR implications
- Threat modeling and trust boundaries
- Privacy and data risk
- Data ownership, source of truth, lineage, migration, backup, and recovery
- API and integration contracts, versioning, idempotency, and compatibility
- Resilience: timeouts, retries, circuit breakers, bulkheads, backpressure,
  and graceful degradation
- SRE readiness: SLIs, SLOs, alerting, runbooks, incidents, and postmortems
- Observability: logs, metrics, traces, events, correlation ids, audit trails,
  and retained evidence
- Operational readiness: deployability, rollback, environments, configuration,
  and support ownership
- Platform and infrastructure-as-code boundaries
- Supply-chain security, dependency posture, provenance, signing, and release
  integrity
- Cost and scaling assumptions
- Team ownership, Conway pressure, and cognitive load
- Modularity, coupling, cohesion, extension points, replaceability, and
  dependency direction
- Build-vs-buy and explicit deferral
- Evolutionary architecture and fitness functions
- Premortem and assumption/risk register
- MVP or thin-slice sequencing
- Migration, strangler, coexistence, cutover, rollback, and decommissioning
- Governance and authority model
- Octon authored/generated split, evidence roots, run contracts, support
  claims, and fail-closed behavior
- Validator and test strategy, including schemas, fixtures, negative controls,
  integration tests, replay tests, and architecture fitness checks
- Non-goals and deletion list

## Relationship Between Methods

Greenfield may use the broadest lens set, but it should not absorb all
companion methods. Balanced and Greenfield can route into Tradeoff,
Failure-Mode, Evolution/Fitness, or Boundary/Authority review when the question
narrows.

## Important Constraints

- Avoid methodology sprawl.
- Do not duplicate architecture-readiness or surface-architecture audit
  doctrine.
- Keep generated outputs derived-only.
- Keep raw inputs, chat, host state, dashboards, and model memory
  non-authoritative.
- Authored authority belongs under `framework/**` and `instance/**`.
- Review outputs are evidence or proposal input unless a separate lifecycle
  contract gives them gate authority.

## Likely Proposal Program Shape

Potential child packets:

1. Method taxonomy and routing update.
2. Shared lens bank definition.
3. Greenfield Reference Architecture Review method.
4. Tradeoff, Failure-Mode, Evolution/Fitness, and Boundary/Authority companion
   methods.
5. Schema and output-contract updates.
6. Workflow, command, and skill integration.
7. Validator and generated projection updates.
8. Documentation and proposal lifecycle integration.

## Expected Impact Map

- Methodology docs under
  `.octon/framework/cognition/practices/methodology/architectural-review/`
- Architectural review naming and routing models.
- Architecture review schemas and support receipts.
- Workflow contracts for any new callable review modes.
- Command and skill facades for operator/agent invocation, if admitted.
- Product feature catalog and navigation-only feature notes.
- Validators and negative-control fixtures.
- Generated capability and host projections through canonical publishers.
- Proposal lifecycle integration points and evidence boundaries.

## Acceptance Criteria For The Proposal Program

- Exact method names, slugs, and use cases are defined.
- Each method has non-goals, required inputs, outputs, escalation rules, and
  authority boundaries.
- The shared lens bank is defined once and method profiles select from it.
- Greenfield is distinguished from clean-sheet.
- The suite composes with, but does not duplicate, architecture-readiness and
  surface-architecture audit doctrine.
- The proposal identifies required docs, schemas, workflows, commands, skills,
  validators, tests, generated projections, and lifecycle integration changes.
- The proposal includes validation expectations and retained evidence
  expectations.
- The proposal clearly separates proposal-only direction from later
  implementation authorization.

## Open Questions For The Architect

- Should all companion methods become first-class routed workflow modes, or
  should some remain methodology-only lenses invoked from Balanced or
  Greenfield reviews?
- Should Greenfield Review produce a schema-backed receipt immediately, or
  should receipt/schema work be a separate child packet?
- Which methods need command and skill facades in the first implementation
  wave?
- Should Boundary/Authority Review be Octon-only, or should it have a generic
  mode for adopted repositories?
- Which generated projections must be refreshed after the suite lands?

## Non-Authority Notice

This intake is source material only. It does not authorize implementation,
proposal creation, lifecycle mutation, generated publication, support-claim
widening, or runtime/control truth changes.
