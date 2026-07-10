# Validation Plan

The closing sweep is the child's validation floor from the parent contract:
the **full architectural-review validator suite** plus the **proposal and
product-feature-catalog validators**, with the workflows validator extended to
assert method-id recording, and **projection refresh performed only by
canonical publishers with evidence of the refresh run**.

## Validator Commands (deterministic)

Run from the repo root. Each must exit `0` on the reviewed implementation
revision; failures block acceptance and closeout.

- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-naming.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-routing.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-workflows.sh` (extended: method-id recording + receipt method-freeness)
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-lifecycle-gates.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-extension-split.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-skills-commands.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-lens-references.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-product-feature-catalog.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-feature-catalog-drift-closeout.sh`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/architectural-review-suite-integration`
- `bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/architectural-review-suite-integration`
- `bash .octon/framework/assurance/runtime/_ops/tests/test-architectural-review-validators.sh`

## Positive Checks

- Each of the four review-occasion workflows records the selected method id
  (and lens profile) in its v2 routing-decision/report run evidence.
- Balanced Architecture Review is the recorded default when no method is
  selected.
- The feature note, mechanism entry, and `index.yml` reference the v2 schemas,
  `lens-bank.yml`, the method catalog, and the lens-references validator, and
  carry the per-occasion advisory.
- Each affected generated projection matches its canonical publisher's fresh
  output (publisher `--check` mode is clean after the refresh run).

## Negative Controls

- **NC-01 (missing method record):** a review-occasion workflow fixture that
  omits the method-id recording fails
  `validate-architectural-review-workflows.sh` (`missing_method_record`).
- **NC-02 (receipt method drift):** a support-receipt fixture carrying a
  `method` or `lenses_applied` field fails the existing receipt drift guard
  (`receipt_schema_drift`); the integration must not weaken it.
- **NC-03 (unknown method):** a recorded method id outside `naming.yml`'s
  catalog is fail-closed (`unknown_method`) — behavior inherited from routing
  v2 and re-confirmed, not modified.
- **NC-04 (generated write attempt):** no change appears under
  `.octon/generated/**` except as the output of a canonical publisher run;
  a direct edit would be caught by the projection freshness/`--check` gate.
- **NC-05 (authority language):** the feature note and mechanism additions
  introduce no new gate, mode, or review-output authority (reviewed against
  the mechanism's non-authority boundary).

## Evidence Retention

- Validator receipts and publisher refresh-run evidence are retained under
  `.octon/state/evidence/validation/proposals/architectural-review-suite-integration/`.
- Generated projection refreshes are evidenced by the canonical publisher run
  output; the generated files themselves are not evidence and are not
  authority.

## Proof Threshold

Two consecutive clean passes of the full sweep on the same reviewed revision,
with all negative controls firing as specified and no new findings, before
closeout. A general "tests pass" statement is insufficient; evidence must
identify the behavior, boundary, negative case, and retained receipt.
