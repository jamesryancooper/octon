# NC-05 — Authority-language non-authority review

- proposal_id: `architectural-review-suite-integration`
- control: NC-05 (feature note + mechanism additions introduce no new gate, mode,
  or review-output authority)
- verdict: **PASS — no new authority introduced**

## Method

Reviewed the navigation-family additions against the mechanism's declared
non-authority boundary. The additions are descriptive/navigation text; each one
explicitly disclaims authority and adds no gate, routed mode, evidence root, or
review-output authority.

## Reviewed surfaces and disclaimers found

- `.octon/framework/product/features/architectural-review-mechanism.md`
  (Method Layer + Per-Occasion Method Advisory sections):
  - "navigation-only; it authorizes nothing"
  - "grants that record no lifecycle, acceptance, promotion, or closeout authority"
  - "No new stage, gate, evidence root, or review-output authority is introduced."
  - "Lifecycle prompts consult this advisory by reference; it changes no gate."

- `.octon/framework/cognition/_meta/architecture/governed-cross-surface-mechanisms/mechanisms/architectural-review-mechanism.md`
  (Method Layer (Navigation) section):
  - "descriptive run evidence only: it introduces no new stage, gate, evidence
    root, or review-output authority"
  - "the lifecycle-gating support receipt stays
    `architectural-review-support-receipt-v1` and method-free"
  - "Method selection creates no lifecycle gate and grants no review output any
    authority."

- `.octon/framework/cognition/_meta/architecture/governed-cross-surface-mechanisms/index.yml`:
  additions are reference entries only (schema refs, methodology refs, validator
  refs); no `lifecycle_authority` / `closeout_authority` value was added or
  changed.

- Four workflow configure/review stages: each method-selection block states
  "Method selection creates no lifecycle gate and grants the review output no
  authority; the v1 support receipt stays method-free." Readiness audit adds
  "leaves the readiness verdict semantics and done-gate unchanged."

## Corroborating validators (see ../sweep-1, ../sweep-2)

- `validate-architectural-review-lifecycle-gates.sh` errors=0 — the only
  lifecycle-gating review artifact remains the v1 support receipt; no new gate.
- `validate-product-feature-catalog.sh` +
  `validate-feature-catalog-drift-closeout.sh` errors=0 — feature note stays
  catalog-coherent with no authority drift.
- `validate-architectural-review-workflows.sh` asserts the support-receipt
  artifact stays method-free per occasion (no review-output authority added).
