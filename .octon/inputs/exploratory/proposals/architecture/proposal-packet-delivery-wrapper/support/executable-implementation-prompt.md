# Executable Implementation Prompt

proposal_id: proposal-packet-delivery-wrapper
generated_at: 2026-06-16T22:59:09Z
generator: octon-orchestrator
review_receipt_ref: support/proposal-review.md
pre_integration_architecture_review_ref: support/pre-integration-architecture-review.yml
implementation_authorization_gate: validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-packet-delivery-wrapper --require-implementation-authorization

## Objective

Implement the accepted `proposal-packet-delivery-wrapper` packet as a durable
Octon-internal aggregate packet delivery route. The route must coordinate
existing lifecycle owners and emit an aggregate receipt without replacing source
receipts or widening authority.

## Required Promotion Targets

Implement only these durable targets:

- `.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-delivery/`
- `.octon/framework/orchestration/runtime/workflows/manifest.yml`
- `.octon/framework/orchestration/runtime/workflows/registry.yml`
- `.octon/framework/capabilities/runtime/commands/proposal-packet-delivery.md`
- `.octon/framework/capabilities/runtime/skills/operations/proposal-packet-delivery/SKILL.md`
- `.octon/framework/product/contracts/proposal-packet-delivery-profile-v1.schema.json`
- `.octon/framework/product/contracts/proposal-packet-delivery-receipt-v1.schema.json`
- `.octon/framework/product/features/proposal-packet-delivery.md`
- `.octon/framework/product/features/catalog.yml`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-delivery-workflow.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-delivery-profile.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-delivery-receipt.sh`
- `.octon/framework/assurance/runtime/_ops/tests/`
- `.octon/framework/capabilities/runtime/commands/manifest.yml`
- `.octon/framework/capabilities/runtime/skills/manifest.yml`
- `.octon/framework/capabilities/runtime/skills/registry.yml`
- `.octon/framework/capabilities/runtime/skills/capabilities.yml`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/bundle-matrix.md`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycle.contract.yml`

## Implementation Workstreams

1. Add `proposal-packet-delivery` workflow assets under
   `.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-delivery/`.
   Mirror the aggregate posture of `proposal-program-delivery`, but target one
   packet. Declare aggregate-receipt-only authority, existing owner routes
   including `promote-proposal` and `closeout-packet`, and fail-closed terminal
   claim rules.
2. Add command and operation skill surfaces for:

   ```text
   /proposal-packet-delivery target=<proposal-packet-path> outcome=cleaned route=branch-no-pr [profile=<profile-path>] [run-id=<id>]
   ```

   The command and skill must state that the wrapper does not implement packets,
   archive packets directly, mutate Git directly, delete residue, publish
   generated outputs by hand, or replace source receipts.
3. Add profile and receipt schemas. The profile must reject PR fallback,
   direct generated edits, cleanup-by-classification, aggregate-replaces-source
   behavior, and proposal-local/generated authority. The receipt must bind
   implementation, conformance, drift/churn, promote-proposal, closeout-packet,
   terminal closeout, archive, generated publication freshness, Change
   closeout, hosted branch-no-pr authorization, cleanup authorization, final
   sync, terminal current-state proof, and clean-worktree proof.
4. Add validators for workflow, profile, and receipt. Validators must include
   negative controls for stale/missing source receipts, missing implementation
   authorization, missing promote-proposal receipt or implemented manifest
   status proof, missing closeout-packet receipt or archive authorization, PR
   fallback, generated authority overclaims, proposal-local authority
   overclaims, missing branch landing authorization, missing cleanup
   authorization, missing final sync proof, dirty-worktree cleaned overclaim,
   and aggregate receipt replacement of target-owned evidence.
5. Add focused shell tests under `.octon/framework/assurance/runtime/_ops/tests/`.
6. Register workflow, product feature, lifecycle context, command, and skill
   metadata through authored source manifests/registries and owning publication
   scripts only. Do not hand-edit `.codex/commands/**`, `.codex/skills/**`, or
   generated/effective outputs.

## Evidence Requirements

Retain or refresh:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- promote-proposal receipt and implemented manifest status proof
- `support/proposal-closeout.md`
- `support/validation.md`
- generated proposal registry and artifact freshness evidence
- capability publication validation evidence
- validator and test logs
- rollback posture
- terminal closeout, archive, Change closeout, landing, cleanup, final sync,
  terminal proof, and clean-worktree evidence during final delivery

## Required Validation

Run at minimum:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-packet-delivery-wrapper
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-packet-delivery-wrapper
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-packet-delivery-wrapper --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-packet-delivery-wrapper
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/proposal-packet-delivery-wrapper/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/proposal-packet-delivery-wrapper --mode pre-integration-architecture-review --require-pass
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-delivery-workflow.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-delivery-profile.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-delivery-receipt.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-packet-delivery.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-packet-delivery-wrapper
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-packet-delivery-wrapper
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-packet-delivery-wrapper
git diff --check
```

## Rollback

Rollback is a normal git revert of authored workflow, command, skill, schema,
validator, fixture, workflow publication, product feature, lifecycle context,
and capability publication metadata changes, followed by regeneration of
derived projections through owning scripts. Retain delivery, branch, cleanup,
archive, validation, and terminal proof evidence for auditability.

## Boundaries

- Do not introduce new proposal statuses.
- Do not widen accepted promotion targets.
- Refuse closeout and archive claims until `support/implementation-conformance-review.md`
  and `support/post-implementation-drift-churn-review.md` both pass their
  validators with zero unresolved items.
- Refuse terminal closeout, archive, or cleaned claims until
  `promote-proposal` has produced implemented status and retained promotion
  evidence.
- Refuse terminal closeout, archive, or cleaned claims until `closeout-packet`
  has produced `support/proposal-closeout.md` with `verdict: pass` and
  `archive_authorized: yes`.
- Do not use this newly implemented wrapper to authorize its own
  implementation unless all wrapper validators pass and lifecycle policy
  permits that use.
- Do not treat proposal-local files, generated outputs, generated prompts,
  dashboards, host state, chat, or model memory as durable authority.
- Do not claim `cleaned` without local `main`, `origin/main`, and `landed_ref`
  equality plus empty `git status --short`.
