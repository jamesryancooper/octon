# Acceptance Criteria

## AC-01 — Method-id recorded in review run evidence

Each of the four architectural review occasions (`pre-integration`,
`post-integration`, `current-state-mechanism`, `architecture-readiness-audit`)
records the selected review method id and the lens profile actually applied in
run evidence through the existing `architectural-review-routing-decision-v2`
or `architectural-review-report-v2` artifact, inside the existing run-evidence
root `.octon/state/evidence/runs/workflows/{run_id}/architectural-review/<mode>/`.
No new stage, gate, artifact family, or evidence root is introduced.

## AC-02 — Support receipt unchanged and method-free

The `architectural-review-support-receipt-v1` schema and the pre-integration
gate semantics are unchanged. No support receipt carries a `method` or
`lenses_applied` field; the existing receipt drift guard (`receipt_schema_drift`)
still fires against any that does.

## AC-03 — Default method behavior preserved

Balanced Architecture Review is the recorded default when no method is
selected. Unknown-method and missing-method-record conditions remain
fail-closed per routing v2; this child neither adds nor relaxes them.

## AC-04 — Navigation-only feature and mechanism descriptions

`product/features/architectural-review-mechanism.md`, the governed mechanism
entry `mechanisms/architectural-review-mechanism.md`, and `index.yml` describe
the method layer (method catalog, lens bank, v2 schemas, method-selection
mechanics) and reference `validate-architectural-review-lens-references.sh`.
The additions contain no new gate, mode, or review-output authority.

## AC-05 — Per-occasion method advisory (gates unchanged)

The feature note, mechanism entry, and workflow configure stages state the
per-occasion method advisory (Balanced default; companion methods on named
escalation conditions). Lifecycle prompts consult this by reference; no prompt
source is edited and no lifecycle gate changes. Any required prompt-source edit
is escalated as a parent registry revision, not implemented in place.

## AC-06 — Workflows validator asserts method recording

`validate-architectural-review-workflows.sh` is extended to assert method-id
recording per occasion and support-receipt method-freeness, retains all prior
checks, and ships a negative-control fixture that fails on a missing method
record.

## AC-07 — Derived-only projection refresh with evidence

Every affected generated projection is refreshed only through its canonical
publisher, with retained evidence of the refresh run; no change lands under
`.octon/generated/**` except as publisher output; the product-feature-catalog
drift validator passes.

## AC-08 — Green closing validator sweep

The full architectural-review validator suite plus the proposal-standard,
architecture-subtype, and product-feature-catalog validators pass on the exact
reviewed implementation revision, with all negative controls in
`validation-plan.md` firing as specified.

## Aggregate Gate

All criteria above must pass on the exact reviewed implementation revision,
with two consecutive clean sweeps and no new findings. Evidence must identify
the behavior, boundary, negative case, and retained receipt for each criterion;
a general statement that validators pass is insufficient. Write-scope
discipline holds throughout: no change lands outside this child's four declared
write scopes (plus the declared child evidence root) without a parent registry
revision.
