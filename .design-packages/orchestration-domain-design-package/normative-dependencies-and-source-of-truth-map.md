# Normative Dependencies And Source Of Truth Map

## Purpose

This document identifies which orchestration rules are defined inside this
package, which are inherited from canonical Harmony doctrine outside the
package, and which file is authoritative for each major rule category.

The goal is to eliminate ambiguity for implementers. A future implementer
should not have to ask:

`Which file is actually authoritative for this rule?`

## Why This Map Is Needed

The orchestration package is intentionally layered:

- top-level architecture and framing docs explain the model
- contracts define object and interface behavior
- control documents define execution, lifecycle, evidence, and assurance rules
- surface specs define responsibilities and boundaries
- ADRs preserve rationale

That layering is correct, but it also creates the risk of overlap if authority
is not mapped explicitly.

## Global Harmony Precedence

This package does not override repository-level or canonical Harmony authority.

When conflicts exist, the higher-precedence Harmony authority wins:

1. repository ingress and agent governance authorities (`AGENTS.md`,
   `CONSTITUTION.md`, delegation/memory overlays, active objective/intent)
2. live canonical `.harmony/` authority surfaces
3. this proposal package

This package is a design-and-control package, not a runtime authority surface.

## Package-Local Normative Documents

These documents are normative inside the package:

### Control Documents

- `lifecycle-and-state-machine-spec.md`
- `routing-authority-and-execution-control.md`
- `evidence-observability-and-retention-spec.md`
- `assurance-and-acceptance-matrix.md`
- `operator-and-authoring-runbook.md`

### Contracts

- all files under `contracts/`

### Promotion Planning

- `canonicalization-target-map.md`
- `implementation-readiness.md`

## Package-Local Reference Documents

These documents are explanatory or planning-oriented, not the final source of
behavioral truth when a more specific normative document exists:

- `mature-harmony-orchestration-model.md`
- `layered-model.md`
- `runtime-shape-and-directory-structure.md`
- `canonical-surface-taxonomy.md`
- `end-to-end-flow.md`
- `alignment-with-harmony-goal.md`
- `surface-criticality-and-ranking.md`
- `surface-shape-architectural-review.md`
- `example-orchestration-charter.md`
- `adoption-roadmap.md`
- `reference-examples.md`
- all files under `surfaces/`
- all files under `adr/`

Surface specs remain authoritative for surface purpose and non-goals unless a
more specific contract or control document defines stricter behavior.

## Externally Inherited Harmony Authorities

This package depends on the following canonical Harmony authorities outside the
package:

| External Authority | Why It Matters |
|---|---|
| `AGENTS.md` and governing overlays | global process, safety, and precedence rules |
| `.harmony/OBJECTIVE.md` and active intent contract | objective-bound execution and authorized scope |
| `.harmony/orchestration/_meta/architecture/specification.md` | canonical workflow model and progressive disclosure rules |
| `.harmony/orchestration/practices/workflow-authoring-standards.md` | existing workflow authoring constraints |
| `.harmony/orchestration/practices/mission-lifecycle-standards.md` | existing mission lifecycle discipline |
| `.harmony/orchestration/governance/incidents.md` | incident-response governance baseline |
| `.harmony/orchestration/governance/production-incident-runbook.md` | product-specific operational response guide; not the governance source of truth |
| `.harmony/continuity/_meta/architecture/continuity-plane.md` | canonical continuity boundary and evidence separation |
| `.harmony/continuity/decisions/README.md` and decisions retention docs | durable decision evidence ownership |
| `.harmony/continuity/runs/README.md` and retention policy | durable run evidence ownership |

## Source Of Truth Matrix

| Rule Category | Primary Authority In Package | External Dependency | Notes |
|---|---|---|---|
| taxonomy | `canonical-surface-taxonomy.md` | Harmony objective and orchestration framing docs | explains classes and ownership |
| lifecycle | `lifecycle-and-state-machine-spec.md` | live mission/workflow baseline docs | control doc overrides weaker prose summaries in surface specs |
| routing / authority | `routing-authority-and-execution-control.md` | AGENTS/governance/intent authorities | defines `allow`, `escalate`, `block` behavior |
| decision evidence | `contracts/decision-record-contract.md` and `evidence-observability-and-retention-spec.md` | continuity plane architecture plus live `continuity/decisions/` authority | canonical `decision_id` and decision evidence ownership |
| evidence | `evidence-observability-and-retention-spec.md` | continuity evidence authorities | runtime projections may not outrank continuity evidence |
| runtime shape | `runtime-shape-and-directory-structure.md` | canonicalization target map | structural reference |
| discovery metadata | `contracts/discovery-and-authority-layer-contract.md` | workflow progressive disclosure spec | authoritative for promoted-surface discovery layering |
| contract behavior | relevant file under `contracts/` | higher-precedence Harmony authorities only | contracts outrank surface specs for behavioral rules |
| promotion criteria | `assurance-and-acceptance-matrix.md` and `implementation-readiness.md` | canonicalization target map | rollout readiness still requires live implementation |

## What This Package Intentionally Does Not Redefine

This package does not redefine:

- repository-wide governance precedence
- live workflow spec semantics already defined in `.harmony/orchestration`
- live mission lifecycle semantics already defined in `.harmony/orchestration`
- continuity as the owner of append-oriented durable evidence
- human authority over policy authorship, exception handling, and escalation

## Conflict Resolution Inside The Package

When two package docs appear to overlap, use this order:

1. specific contract docs in `contracts/`
2. control docs
3. implementation-readiness and canonicalization planning docs
4. surface specs
5. architecture/reference docs
6. ADRs and examples

### Examples

- If `surfaces/queue.md` and `contracts/queue-item-and-lease-contract.md`
  differ on queue behavior, the contract wins.
- If `layered-model.md` and
  `routing-authority-and-execution-control.md` differ on who may launch work,
  the routing/authority doc wins.
- If `reference-examples.md` contradicts a contract, the contract wins and the
  example is wrong.

## Promotion Guidance

When promoting package rules into live `.harmony` authority surfaces:

1. preserve the same subject ownership
2. move behavioral rules into runtime/governance/practices surfaces, not into
   examples or ADRs
3. do not promote reference docs as if they were canonical control documents
4. keep continuity evidence ownership outside runtime state

### Promotion Mapping

- contracts become live contract/spec or runtime validation artifacts
- control docs become live governance/practices/assurance documents
- reference docs remain design context unless explicitly superseded

## Implementation Guidance

If an implementer needs to answer a concrete question, use this shortcut:

| Question | Start Here |
|---|---|
| What state transition is allowed? | `lifecycle-and-state-machine-spec.md` |
| Can this action proceed? | `routing-authority-and-execution-control.md` |
| Where is routing decision evidence stored? | `contracts/decision-record-contract.md` |
| What evidence is required? | `evidence-observability-and-retention-spec.md` |
| What must pass before promotion? | `assurance-and-acceptance-matrix.md` |
| Which contract governs this surface? | `contracts/README.md` |
| How do I operate or author it safely? | `operator-and-authoring-runbook.md` |
| How are schemas and fixtures validated? | `contracts/README.md` and `/.harmony/assurance/runtime/_ops/scripts/validate-orchestration-design-package.sh` |
