# Conversation Source Notes: Architecture Review Method Suite

These notes preserve the pertinent conversation-derived direction that should
inform an Octon architect while creating a proposal program. This file is
non-authoritative raw intake only.

## Suite Name And Description

Recommended name:

**Architecture Review Method Suite**

Brief description:

A structured Octon methodology suite for architecture review that keeps
Balanced Architecture Review as the default method, adds focused companion
reviews for greenfield design, tradeoffs, failure modes, evolution/fitness, and
authority boundaries, and uses a shared lens bank so reviews stay comprehensive
without becoming unbounded or duplicative.

## Specialized Companions

Add specialized companions, not competing defaults. Balanced Architecture
Review should stay the default general review method.

### Architecture Tradeoff Review

Purpose: explicit option comparison.

Framing question:

> Given 3 possible designs, which tradeoffs are we accepting?

This is an Octon-local ATAM-style method. Output should include options,
quality attributes, tradeoffs, risks, reversibility, and ADR recommendation.

### Failure-Mode Architecture Review

Purpose: review runtime-critical and governance-critical surfaces.

Framing question:

> How does this fail, recover, get bypassed, or drift?

It should cover authority inflation, stale evidence, generated-output misuse,
rollback gaps, partial execution, zombie runs, and operator confusion.

### Evolution/Fitness Review

Purpose: review long-lived mechanisms.

Framing question:

> Will this architecture remain healthy as the system changes?

Output should include architectural fitness checks, drift triggers, retirement
triggers, validator needs, and revisit cadence.

### Boundary/Authority Review

Purpose: Octon-specific authority critique.

Framing question:

> Where is the real authority, and are prose, generated files, inputs, or host
> state accidentally becoming control surfaces?

This is useful for workflows, capabilities, proposals, generated projections,
and adapters.

### Companion Scope Guardrail

Do not add a large catalog of generic methods. The repo already has
architecture-readiness and surface-architecture audit doctrine. The gap is
mostly specialized review lenses that Balanced Review can route into when the
question is specifically about tradeoffs, failure modes, evolution, or
authority boundaries.

## Greenfield Review

Greenfield Architecture Review is worth adding, but should be defined narrowly.

Recommended slug:

`greenfield-reference-architecture-review`

Core job:

> If we were designing this from nothing today, what architecture would we
> choose, before current constraints pull us back?

Greenfield differs from Balanced Architecture Review because Balanced Review
compares clean-sheet thinking against current reality. Greenfield Review should
temporarily suspend current implementation inertia and focus on:

- the fundamental job the system must do
- ideal domain boundaries and ownership
- minimum necessary authority/control surfaces
- simplest runtime and state model
- observability and evidence model from day one
- failure and recovery model
- extension points that are truly needed
- what should explicitly not exist yet

Guardrail: greenfield output should be reference architecture only, not
implementation authority. It should feed Balanced Review, Architecture Tradeoff
Review, or proposal drafting. Otherwise it can become a fantasy architecture
that ignores migration, evidence, compatibility, and existing governance.

Plain rule:

> Use it when the question is "What would the clean design be?" not "What
> should we change next?"

## Clean-Sheet Versus Greenfield

Greenfield and clean-sheet are similar, but should not mean the same thing.

Clean-sheet is a comparison tool inside a broader review. It asks:

> What would the ideal design look like if we ignored current implementation
> shape for a moment?

In Balanced Architecture Review, clean-sheet is used to expose gaps,
accidental complexity, and better structure, then it gets compared back against
current reality.

Greenfield is a broader starting-state review. It asks:

> If this system or subsystem did not exist yet, what should we build first?

It should include sequencing, minimum viable architecture, initial contracts,
evidence model, risks, and what not to build yet.

Complementarity:

- Clean-sheet is usually an ideal reference design.
- Greenfield is a practical initial-build architecture.
- Clean-sheet can be intentionally unconstrained.
- Greenfield still has real constraints: Octon governance, support claims,
  validation, operability, and first implementation scope.

For Octon: clean-sheet is a lens within Balanced Review; greenfield is a
separate methodology for new systems, new subsystems, or major replacement
candidates before implementation begins.

## Comprehensive Greenfield Lens Bank Candidates

Treat a comprehensive greenfield architecture review as a lens-bank-driven
review: one core review flow with optional lenses depending on risk, domain,
and maturity.

Strong candidates to roll in:

- Jobs-to-be-Done / mission framing: define the system's real job before
  drawing architecture.
- Domain-Driven Design: bounded contexts, aggregates, ubiquitous language,
  context maps.
- Event storming: discover domain events, commands, policies, handoffs,
  failure points.
- Wardley mapping: separate commodity, custom, emerging, and strategic parts
  of the system.
- Capability mapping: identify business/system capabilities before choosing
  services or modules.
- C4 model: context, container, component, and code-level architecture views.
- 4+1 architecture views: logical, process, development, physical, and
  scenario views.
- arc42-style architecture documentation: structured architecture decision and
  constraint capture.
- Quality Attribute Scenarios: define testable needs for latency,
  reliability, security, operability, maintainability, etc.
- ATAM / tradeoff analysis: compare architecture options against quality
  attributes and risks.
- ADR discipline: capture major decisions, rejected alternatives,
  consequences, and revisit triggers.
- Threat modeling: STRIDE, abuse cases, attack trees, trust boundaries,
  secrets, identity, supply chain.
- Privacy/data risk review: data classification, retention, deletion,
  consent, residency, audit access.
- Data architecture review: ownership, source of truth, schemas, lineage,
  migration, replay, backup, recovery.
- API and integration design: OpenAPI/AsyncAPI/gRPC contracts, versioning,
  compatibility, idempotency.
- Resilience engineering: timeouts, retries, circuit breakers, bulkheads,
  backpressure, graceful degradation.
- SRE readiness: SLIs, SLOs, error budgets, alerting, runbooks, incident
  response, postmortems.
- Observability design: logs, metrics, traces, events, correlation IDs, audit
  trails, evidence retention.
- Operational readiness review: deployability, rollback, configuration,
  environments, support ownership.
- Platform/IaC review: infrastructure boundaries, provisioning, secrets,
  CI/CD, environment parity.
- Supply-chain security: dependency policy, SBOMs, provenance, signing, build
  isolation, release integrity.
- Cost / FinOps modeling: cost drivers, scaling cost, waste controls,
  capacity assumptions.
- Team Topologies / Conway review: ensure architecture fits team ownership and
  cognitive load.
- Modularity review: coupling, cohesion, extension points, replaceability,
  dependency direction.
- Build-vs-buy assessment: what should be custom, commodity, outsourced, or
  explicitly deferred.
- Evolutionary architecture / fitness functions: define ongoing checks that
  keep architecture healthy.
- Premortem analysis: assume the architecture failed and identify likely
  causes.
- Assumption and risk register: record unknowns, validation plans, and
  decision expiry dates.
- MVP / thin-slice sequencing: define the smallest architecture that proves
  the hardest assumptions.
- Migration/strangler planning: if replacing something, define coexistence,
  cutover, rollback, and decommissioning.
- Governance and authority review: who can change what, what is authoritative,
  what is advisory.
- Octon-specific authority boundary review: authored vs generated surfaces,
  evidence roots, run contracts, fail-closed behavior.
- Octon support-claim review: what can be claimed live, what is stage-only,
  and what evidence proves it.
- Validator/test strategy: schemas, fixtures, negative controls, integration
  tests, replay tests, architecture fitness checks.
- Non-goals and deletion list: explicitly name what should not be built yet.

For Octon, the strongest Greenfield Review should include five required
sections:

1. domain/job model
2. reference architecture
3. quality/security/ops model
4. authority/evidence model
5. evolution plan

Everything else plugs into those sections as needed.

## Relationship Between Greenfield And Specialized Companions

The specialized companions should be separate review methods, but they should
also be usable as sub-lenses inside Greenfield Review.

Framing:

- Greenfield Review: What should we build from zero?
- Tradeoff Review: Which option should we choose, and what are we accepting?
- Failure-Mode Review: How does this break, get bypassed, or fail to recover?
- Evolution/Fitness Review: Will this stay healthy over time?
- Boundary/Authority Review: Where is authority, and what must never become
  authority?

They are distinct. Greenfield can call them, but should not absorb them
completely.

Do not create four big independent lens banks. That creates method sprawl.
Better structure:

1. One shared architecture lens bank.
   Common reusable lenses: domain model, quality attributes, security, ops,
   evidence, data, ownership, cost, evolution, failure, validation.
2. One profile per review method.
   Each method selects a subset of the shared lenses and adds a few
   method-specific ones.

Example:

| Review method | Uses shared lens bank? | Has extra focused lenses? |
| --- | --- | --- |
| Greenfield Review | Yes, broadest set | MVP architecture, initial-build sequence, what-not-to-build |
| Tradeoff Review | Yes, narrow set | option matrix, quality attributes, reversibility, ADR recommendation |
| Failure-Mode Review | Yes, risk-heavy set | FMEA, threat modeling, recovery, bypass, stale evidence, rollback |
| Evolution/Fitness Review | Yes, change-heavy set | fitness functions, drift triggers, retirement, compatibility, revisit cadence |
| Boundary/Authority Review | Yes, Octon-specific set | authored/generated split, evidence roots, control-plane boundaries, support claims |

Key design rule:

> Methods own the question and output contract; lenses are reusable analysis
> tools.

Candidate files:

- `greenfield-reference-architecture-review.md`
- `architecture-tradeoff-review.md`
- `failure-mode-architecture-review.md`
- `evolution-fitness-architecture-review.md`
- `boundary-authority-architecture-review.md`
- `architecture-lens-bank.md`

Each method should say: required lenses, optional lenses, outputs, and when to
escalate to another method. This keeps Greenfield comprehensive without
turning every review into an unbounded mega-audit.
