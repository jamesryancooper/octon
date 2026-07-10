# Source Context

This packet is the phase-3 integration child of the **Architecture Review
Method Suite Program**. The bound creation envelope and the child-relevant
source slice are preserved here verbatim; the **full source remains retained**
at its canonical path and is cited as lineage only, never as authority. Every
claim is re-grounded against the live repository (see
`architecture/current-state-gap-map.md`).

## Bound Creation Envelope

- `run_id`: `20260709-arms-program-clean-delivery-04-architectural-review-suite-integration`
- `lifecycle_id`: `proposal-packet`
- `route_id`: `create-packet`
- `program_run_id`: `20260709-arms-program-clean-delivery-04`
- `child_id`: `architectural-review-suite-integration`
- `proposal_path` / `target`: `.octon/inputs/exploratory/proposals/architecture/architectural-review-suite-integration`
- `source`: `.octon/inputs/exploratory/proposals/architecture/architecture-review-method-suite-program/`

## Full Source (retained by reference)

- Parent program packet:
  `.octon/inputs/exploratory/proposals/architecture/architecture-review-method-suite-program/`
  (design docs: `architecture/method-taxonomy.md`,
  `architecture/lens-bank-design.md`,
  `architecture/integration-and-disposition.md`,
  `architecture/packet-sequence.md`,
  `architecture/child-packet-contract.md`,
  `resources/child-packet-index.yml`).
- Non-authoritative intake lineage:
  `.octon/inputs/additive/.incoming/architecture-review-method-suite/`
  (`intake.yml`, `README.md`, `payload/`) — conversation-derived direction to
  keep Balanced as default, add companion methods, and add a shared lens bank.

## Child Charter (verbatim from `architecture/child-packet-contract.md`)

> `architectural-review-suite-integration`: extend existing review workflow
> contracts to record the selected method id in run evidence (no new steps,
> gates, or evidence roots); extend the product feature note and governed
> cross-surface mechanism entry (navigation-only); add lifecycle advisory text
> so lifecycle prompts can recommend a method per review occasion (gates
> unchanged); enumerate and refresh affected generated projections through
> canonical publication scripts; run the full architectural-review validator
> suite plus proposal/feature-catalog validators as the closing sweep.

## Registry Facts (from `resources/child-packet-index.yml`)

- `phase_id`: `phase-3`; `group_id`: `integration`; `required`: true;
  `deferred`: false; `rollback_posture`: `manual`.
- `dependencies`: `greenfield-reference-architecture-review-method`,
  `companion-architecture-review-methods`,
  `architectural-review-schema-extensions`; `dependency_gate`: `verification`.
- `write_scopes`:
  `.octon/framework/orchestration/runtime/workflows/audit/`,
  `.octon/framework/product/features/`,
  `.octon/framework/cognition/_meta/architecture/governed-cross-surface-mechanisms/`,
  `.octon/framework/assurance/runtime/_ops/scripts/`.
- `generated_refresh_note`: "Generated projections touched by this child are
  refreshed only through canonical publication scripts; generated paths are
  never direct write scopes."

## Integration Disposition Rows For This Child (from `architecture/integration-and-disposition.md`)

- Workflow contracts (pre/post-integration, current-state-mechanism, readiness
  audit) → **extend (minimal)** → suite-integration: record selected method id
  in run evidence; no new steps, gates, or evidence roots.
- Product feature note `product/features/architectural-review-mechanism.md` →
  **extend** → suite-integration: navigation-only suite section; authorizes
  nothing.
- Governed mechanism detail
  (`cognition/_meta/architecture/governed-cross-surface-mechanisms/`) →
  **extend** → suite-integration: mechanism entry notes the method layer.
- Generated projections → **extend (derived-only)** → suite-integration:
  refreshed only through canonical publication scripts after children land.
- Proposal lifecycle integration (pre-integration gate, lifecycle prompts) →
  **extend (advisory only)** → suite-integration: lifecycle prompts may
  recommend a method for a review occasion; gates unchanged.

## Per-Child Validation Floor (from `architecture/implementation-plan.md`)

> suite-integration | Full architectural-review validator suite green (naming,
> routing, receipts, workflows, lifecycle gates, extension split,
> skills-commands) plus product-feature-catalog validator; projection refresh
> performed only by canonical publishers with evidence of the refresh run.

## Source Claims Narrowed Or Deferred (with rationale)

- **"Lifecycle advisory text so lifecycle prompts can recommend a method"** —
  narrowed to authoring the advisory in in-scope surfaces (feature note,
  mechanism entry, workflow configure stages) that prompts consult by
  reference, because the proposal-lifecycle prompt sources are outside this
  child's declared write scopes. A prompt-source edit, if strictly required, is
  escalated as a parent registry revision. Tracked in
  `resources/traceability-map.md` (T-05) and `architecture/implementation-plan.md`.
- **Command/skill facades** — not in scope; owned by the conditional
  `architecture-review-command-facades` sibling.
- **Support receipt method field** — deliberately excluded; the schema-extensions
  child kept the support receipt v1 and method-free, and this child preserves
  that boundary.
