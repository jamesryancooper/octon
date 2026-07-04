# Executable Implementation Prompt

packet: `.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-run-health-localization`
route: `run-packet-implementation`
run_id: `lifecycle-proposal-program-1783094500385-fbec6b8f-run-program-clean-delivery-run-health-localization`

Implement only the accepted child packet for run-health generated read-model
localization. Proposal inputs and this prompt are implementation aids, not
authority. Preserve the accepted packet scope: generated run-health projections
remain diagnostic by default and become durable evidence only through an
owning route promotion receipt that names path, digest, source refs, freshness,
owning route, allowed consumers, and non-authority classification.

## Durable Promotion Targets

- `.octon/framework/assurance/runtime/_ops/scripts/generate-run-health-read-model.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-evidence-disclosure-tiers.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-run-program-clean-delivery.sh`
- `.octon/framework/assurance/runtime/_ops/tests/`
- `.octon/generated/cognition/projections/materialized/runs/`

Do not edit parent program lifecycle state, unrelated child packets, archive
state, closeout state, branch cleanup state, generated proposal registries, or
durable authority surfaces outside the accepted targets. If implementation
requires changes outside the declared promotion targets, stop and revise the
packet rather than widening scope from this route.

## Workstreams

1. Localize speculative run-health generation.
   - Change `generate-run-health-read-model.sh` so ordinary `--run-id`,
     `--all-runs`, and fixture generation no longer write speculative health
     projections into tracked `.octon/generated/cognition/projections/materialized/runs/**`
     by default.
   - Use scratch or local-private retained state for ordinary diagnostics.
     The default output must be disposable or regenerable and must not become
     policy, runtime, support, closure, archive, or lifecycle-control input.
   - Preserve operator-visible diagnostics and compact summaries without
     relying on tracked generated churn.

2. Add explicit durable publication mode.
   - Add an explicit publish path for route-owned generated run-health output.
   - Require publication inputs to include or derive: path, sha256 digest,
     source refs, freshness status, owning route, allowed consumers, forbidden
     consumers, and non-authority classification.
   - Emit a route-owned promotion or generation receipt before any durable
     generated run-health path is treated as publishable evidence.
   - Keep generated run-health output derived-only and forbidden for direct
     authority, policy, runtime, support-claim, closeout, archive, or state
     reconstruction consumers.

3. Harden validator boundaries.
   - Update `validate-evidence-disclosure-tiers.sh` and
     `validate-run-program-clean-delivery.sh` so closure, delivery, archive,
     cleanup, or terminal claims fail when they rely on unpromoted generated
     run-health projections.
   - Ensure generic cleanup still refuses to delete generated run-health
     projection paths directly and routes any retained generated-run-health
     disposition through the owning generator and its receipt.
   - Preserve existing compact blocker-remediation, delivery-receipt, and
     evidence-tier semantics.

4. Add focused tests.
   - Positive control: ordinary generator and validator reruns leave tracked
     `.octon/generated/cognition/projections/materialized/runs/**` status
     unchanged.
   - Positive control: explicit publish mode writes the selected durable
     generated run-health path and emits the required receipt fields.
   - Negative control: a closeout, archive, delivery, or cleanup claim that
     cites an unpromoted generated run-health projection fails.
   - Negative control: a generated run-health artifact that widens authority
     or omits digest/freshness/owner metadata fails.
   - Regression coverage: existing run-health read-model tests continue to
     pass for fixture and explicit publish cases.

## Validators

Run from the repository root:

```sh
bash .octon/framework/assurance/runtime/_ops/tests/test-run-health-read-model.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-run-program-clean-delivery-validator.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-run-health-read-model.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-evidence-disclosure-tiers.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-run-program-clean-delivery.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-run-health-localization --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-run-health-localization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-run-health-localization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-run-health-localization --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-run-health-localization/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-run-health-localization --mode pre-integration-architecture-review --require-pass
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-run-health-localization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-run-health-localization
```

For the clean generated-state proof, record the before and after output of:

```sh
git status --short -- .octon/generated/cognition/projections/materialized/runs
```

The before and after status for ordinary validation reruns must match, except
for explicitly selected publish-mode paths covered by current promotion
receipts.

## Retained Evidence

After implementation, produce these packet-local support artifacts:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md`

The implementation run receipt must state the exact files changed, the
promotion targets used, the clean generated-run-health status proof, and any
explicit publish-mode receipt refs. The conformance review must verify that
the implementation matches the accepted target architecture and acceptance
criteria. The drift/churn review must verify that ordinary validation does not
dirty tracked generated run-health files and that no generated read model has
become authority.

## Rollback

Rollback restores the prior run-health generator behavior and removes any new
validator/test logic through this child packet's governed rollback route. Any
published generated run-health outputs or receipts created by explicit publish
mode are evidence artifacts; supersede or clean them only through a governed
cleanup or rollback route with current path-and-digest evidence.

## Closeout Refusal Criteria

Refuse closeout, archive, delivery, or parent-cleaned claims until all of the
following are true:

- `support/implementation-conformance-review.md` exists and records pass.
- `support/post-implementation-drift-churn-review.md` exists and records pass.
- `validate-proposal-implementation-conformance.sh --package <packet>` passes.
- `validate-proposal-post-implementation-drift.sh --package <packet>` passes.
- Ordinary validator reruns leave tracked generated run-health status clean or
  unchanged.
- Any durable generated run-health path is covered by a current route-owned
  promotion receipt with digest, freshness, owner, allowed consumers, and
  non-authority classification.
