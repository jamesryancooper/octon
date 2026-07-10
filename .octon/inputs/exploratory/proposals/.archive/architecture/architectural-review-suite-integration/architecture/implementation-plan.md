# Implementation Plan

## Dependencies

Implementation may not begin until all three phase-2 dependencies pass their
own `verification` gate (parent registry `dependency_gate: verification`):

- `greenfield-reference-architecture-review-method`
- `companion-architecture-review-methods`
- `architectural-review-schema-extensions`

All three are present in the live working tree at creation time; verification
receipts are child-owned and are re-confirmed at implementation start. Parent
program evidence never satisfies this gate.

## Phases

1. **Re-ground against the live suite.** Confirm the landed method catalog
   (`naming.yml` v2), `method_selection` (`review-routing.yml` v2), lens bank
   (`lens-bank.yml`), and the v2 report/routing-decision schemas match this
   packet's assumptions. Where the live tree disagrees, stop and trigger a
   parent registry/design revision instead of implementing a stale claim.
2. **Method-id run evidence in workflow contracts.** For each review occasion
   (`pre-integration`, `post-integration`, `current-state-mechanism`,
   `architecture-readiness-audit`), extend the review stage of the existing
   `workflow.yml` / stage docs so the run emits the selected method id and lens
   profile into the existing `architectural-review-routing-decision-v2` or
   `-report-v2` artifact, inside the existing run-evidence root. Add no new
   stage, gate, artifact family, or evidence root. Leave the receipt stage and
   the v1 support receipt unchanged.
3. **Feature note extension (navigation-only).** Add a method-layer section to
   `product/features/architectural-review-mechanism.md`: method catalog, lens
   bank, v2 schemas, method-selection mechanics, and the per-occasion advisory.
   No authority language.
4. **Governed mechanism entry + index extension.** Add the v2 schemas,
   `lens-bank.yml`, the method catalog, `method_selection`, and
   `validate-architectural-review-lens-references.sh` to the mechanism entry and
   `index.yml`; document the method-selection mechanics as navigation.
5. **Per-occasion advisory text.** Author the advisory (Balanced default;
   companion methods on named escalation conditions) in the feature note, the
   mechanism entry, and the workflow configure stages. Gates unchanged.
6. **Workflows validator extension.** Extend
   `validate-architectural-review-workflows.sh` and its fixtures to assert
   method-id recording and support-receipt method-freeness, with a negative
   control for a missing method record. Keep existing checks intact.
7. **Projection refresh.** Enumerate the affected generated projections and
   refresh each only through its canonical publisher; retain the refresh-run
   evidence.
8. **Closing validator sweep.** Run the full architectural-review validator
   suite plus proposal-standard, architecture-subtype, and
   product-feature-catalog validators; retain receipts.

## Cutover Posture

This is an additive, in-place extension of existing surfaces, not a
clean-break migration. There is no intermediate live state: each promotion
target family lands as one revertible promotion commit, and the closing
validator sweep gates the cutover. See `cutover-checklist.md`.

## Write-Scope Discipline

Implementation stays inside this child's registry-declared write scopes:

- `.octon/framework/orchestration/runtime/workflows/audit/`
- `.octon/framework/product/features/`
- `.octon/framework/cognition/_meta/architecture/governed-cross-surface-mechanisms/`
- `.octon/framework/assurance/runtime/_ops/scripts/`

Generated projections are refreshed only through canonical publishers;
`.octon/generated/**` is never a direct write scope.

## Open Item — Lifecycle Advisory Placement (must resolve at implementation)

The charter asks for "lifecycle advisory text so lifecycle prompts can
recommend a method per review occasion." The proposal-lifecycle prompt sources
(`.octon/inputs/additive/extensions/**`) are **not** in this child's write
scopes. Design decision recorded here: the advisory is authored in in-scope
surfaces (feature note, mechanism entry, workflow configure stages) that
lifecycle prompts consult **by reference**; no prompt source is edited and no
gate changes. If implementation determines that a prompt-source edit is
strictly required, that is a write-scope expansion and must go through a
**parent registry revision**, not silent expansion. This item is tracked as an
assumption in `resources/traceability-map.md` and as a blocker candidate in
the implementation-grade completeness review generated at review time.

## Evidence

Retain compact, non-sensitive receipts for each acceptance criterion and each
projection refresh run under the child evidence root
`.octon/state/evidence/validation/proposals/architectural-review-suite-integration/`.
Raw traces remain local-private unless the maintainer classifies a publishable
derivative.

## Closeout Condition

Closeout is blocked until every acceptance criterion has direct evidence, the
full validator sweep is green (including the extended workflows validator and
its negative control), the projection refresh evidence exists, no support
receipt carries a method field, and no external effect is misrepresented as
completed.
