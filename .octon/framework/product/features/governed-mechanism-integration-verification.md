# Governed Mechanism Integration Verification

This feature note is navigation-only. It describes where agents verify that a governed cross-surface mechanism has complete implementation evidence before proposal closeout or archive readiness.

The workflow composes existing implementation conformance, post-implementation drift/churn, generated publication freshness, terminal freshness, current-state architecture review evidence, and governed mechanism profile coverage into `support/governed-mechanism-integration-evaluation.yml`.

## Boundaries

- It does not create a mechanism-level control plane.
- Current-state mechanism architecture review remains evidence-only.
- Lifecycle postmortem remains evidence-only.
- Generated outputs remain derived-only and must be refreshed through canonical generators or publishers.
- Proposal-local receipts remain evidence only.
- Chat, tool state, host state, dashboards, and model memory remain non-authority.

## Main Surfaces

- Workflow: `.octon/framework/orchestration/runtime/workflows/meta/verify-governed-mechanism-integration/workflow.yml`
- Profile schema: `.octon/framework/product/contracts/governed-mechanism-integration-profile-v1.schema.json`
- Receipt schema: `.octon/framework/product/contracts/governed-mechanism-integration-receipt-v1.schema.json`
- Mechanism profile index: `.octon/framework/cognition/_meta/architecture/governed-cross-surface-mechanisms/profiles/`
- Support receipt: `<proposal-path>/support/governed-mechanism-integration-evaluation.yml`

## Validation

Run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-governed-mechanism-integration-profile.sh --profile <profile>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-governed-mechanism-integration-receipt.sh --receipt <proposal-path>/support/governed-mechanism-integration-evaluation.yml --package <proposal-path>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-governed-cross-surface-mechanisms.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-product-feature-catalog.sh
```
