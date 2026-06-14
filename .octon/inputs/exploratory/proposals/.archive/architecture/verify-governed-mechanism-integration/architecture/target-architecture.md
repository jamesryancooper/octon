# Target Architecture

## Decision

Add `verify-governed-mechanism-integration` as a native workflow-backed
proposal closeout verification gate for proposals that add or materially change
a governed cross-surface mechanism.

The gate composes existing checks and evidence:

- implementation conformance proves the proposal was implemented.
- post-implementation drift/churn proves naming, references, scope, and
  generated state stayed clean.
- generated publication checks prove projections were regenerated through
  canonical scripts.
- current-state mechanism architecture review proves architecture, authority,
  evidence, and ownership boundaries are coherent.
- lifecycle postmortem remains optional evidence after the run and is not a
  gate.

## Trigger Model

Run the verification in four lifecycle positions:

1. Proposal review: require a schema-backed mechanism integration profile when
   a proposal declares a new or materially changed governed mechanism.
2. After implementation and before closeout: run the workflow as a hard gate for
   mechanism proposals.
3. Before archive: require the support receipt to be current, passing, and tied
   to the implemented packet digest.
4. After merge or terminal cleaned outcome: run scoped terminal freshness proof
   on main to prove generated projections, registries, child spines, and
   mechanism docs are fresh after landing.

Periodic runs may use current-state mechanism architecture review as advisory
evidence only until Octon defines a separate recertification policy.

## Mechanism Integration Profile

Add `governed-mechanism-integration-profile-v1` as a schema-backed profile for
new or materially changed mechanisms.

Proposal-local profile drafts may live under proposal support while the packet
is in planning. After implementation, durable profiles live near the governed
mechanism index, under a profile path such as:

`.octon/framework/cognition/_meta/architecture/governed-cross-surface-mechanisms/profiles/`

Each profile must declare:

- mechanism id and display name
- owners
- product feature refs
- doctrine and documentation refs
- workflows
- skills
- commands
- schemas
- validators
- generated projections
- evidence roots
- lifecycle hooks
- extension boundaries
- authority and non-authority boundaries
- `not_applicable` decisions with rationale

The profile validator must fail closed when a required surface class is omitted
without a `not_applicable` rationale.

## Integration Support Receipt

Add `governed-mechanism-integration-receipt-v1` as the strict support receipt
schema. The workflow should write:

`support/governed-mechanism-integration-evaluation.yml`

The retained evidence root is:

`.octon/state/evidence/runs/workflows/<run-id>/governed-mechanism-integration/<mechanism-id>/`

The receipt must include:

- `schema_version`
- `mechanism_id`
- `proposal_path`
- `verdict`
- `unresolved_items_count`
- `blockers`
- `mechanism_profile_ref`
- `current_state_architecture_review_ref`
- `implementation_conformance_ref`
- `post_implementation_drift_ref`
- `generated_publication_refs`
- `validator_refs`
- `evidence_refs`
- `authority_boundary_verdict`
- `surface_coverage`
- `non_authority_classification`
- `mode_specific_coverage`
- implemented packet digest binding
- terminal freshness proof refs when closeout or archive claims require them

Allowed receipt verdicts are `pass`, `fail`, `blocked`, `deferred`, and
`not_applicable`.

Findings and dispositions must use existing `review-finding-v1` and
`review-disposition-v1` records. The implementation must not add a parallel
finding model.

## Hard Gates

Hard-gate deterministic integration facts:

- mechanism appears in the governed mechanism index when required
- product feature catalog entry or feature note exists, or records explicit
  `not_applicable` rationale
- workflows are registered
- skills and commands are thin projections or explicitly out of scope
- schemas are registered and validate fixtures
- validators exist, are executable, and pass
- generated projections are regenerated through canonical publication scripts
- lifecycle hooks exist when the mechanism participates in lifecycle gates
- evidence roots are declared and used
- extension boundaries are explicit
- raw inputs, generated outputs, proposal packets, chat or model memory, host
  state, and dashboards are classified as non-authority
- stale aliases, stale proposal backrefs, placeholder-marker receipts, stale
  digests, and omitted validators are rejected

## Advisory Findings

Keep these advisory unless a later policy promotes them:

- design quality observations
- operator usability suggestions
- documentation polish
- future workflow candidates
- optional post-integration architecture findings

## Authority Boundary

The workflow orchestrates existing validators, receipts, publication checks,
and architecture review evidence. Authority remains with existing lifecycle
contracts and validators.

Current-state mechanism architecture review is evidence-only. Lifecycle
postmortem is evidence-only. Product feature catalog entries are
navigation-only. Generated projections, raw inputs, proposal packets, host
state, dashboards, chat, and model memory are never authority.
