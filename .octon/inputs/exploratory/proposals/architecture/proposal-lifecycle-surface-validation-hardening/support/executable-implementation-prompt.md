# Executable Implementation Prompt

packet: `.octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-surface-validation-hardening`
route: `run-packet-implementation`

Implement only the accepted validation hardening for this child packet. Keep
`proposal.yml#status` as `accepted`; the promote route owns the later
implemented-status rewrite.

## Prerequisite Gates

Run these from the repository root before durable edits:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-surface-validation-hardening --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-surface-validation-hardening/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-surface-validation-hardening --mode pre-integration-architecture-review --require-pass
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-surface-validation-hardening --skip-registry-check --skip-promotion-target-checks
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-surface-validation-hardening
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-surface-validation-hardening
```

Refuse implementation if the accepted review digest is stale, the strict
architecture receipt is missing or failing, the implementation-grade
completeness review does not pass, or implementation authorization is absent.

## Durable Promotion Targets

Edit only these durable target families when implementation requires changes:

- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/bundle-matrix.md`
- `.octon/framework/product/features/catalog.yml`

Packet-local support evidence may be written under:

- `.octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-surface-validation-hardening/support/`

Do not edit `.codex/**`, `.claude/**`, `.cursor/**`, `.octon/generated/**`,
`.octon/state/control/**`, archive locations, parent program receipts, sibling
child receipts, Git branch state, cleanup state, or host projection files. Host
projections and generated outputs may be inspected as non-authoritative mirrors
only.

## Target End State

The implemented state must provide regression validation that detects drift
across the accepted proposal packet and proposal program lifecycle surfaces:

- packet and program delivery required inputs agree across commands, skills,
  workflow contracts, manifests, lifecycle contracts, bundle matrix entries,
  profile or receipt schemas, validators, and tests;
- `octon-proposal-run-program-delivery` remains an additive operator alias
  that delegates to canonical `proposal-program-delivery`, and no native alias
  command, native alias workflow, native alias lifecycle mode, or alias-owned
  authority surface is admitted;
- program review and revision remain the existing `program-review-revision`
  parent-local loop, with the intentional absence of a standalone
  review-and-revise wrapper documented and tested;
- product catalog entries for `governed-proposal-delivery`,
  `proposal-packet-delivery`, and `proposal-packet-terminal-closeout` do not
  outstate available host projection surfaces or canonical command, skill,
  workflow, schema, validator, and feature-document references;
- parent program summaries, aggregate receipts, delivery evidence indexes,
  generated outputs, host projection mirrors, dashboards, chat, model memory,
  and proposal-local support files cannot satisfy child-owned implementation,
  conformance, drift/churn, closeout, archive, cleanup, or terminal proof
  evidence.

## Workstreams

1. Reconstruct the accepted surface matrix from repository state.
   - Use implemented or terminal predecessor child evidence as lineage:
     `proposal-delivery-input-contract-alignment`,
     `proposal-program-delivery-operator-alias`,
     `proposal-program-delivery-host-projections`, and
     `proposal-program-review-loop-documentation`.
   - Prefer existing validator sources as the matrix home:
     `validate-proposal-packet-delivery-workflow.sh`,
     `validate-proposal-program-delivery-workflow.sh`,
     `test-validate-proposal-packet-delivery.sh`,
     `test-validate-proposal-program-delivery.sh`,
     `test-proposal-program-delivery-guardrails.sh`,
     `test-validate-lifecycle-contracts.sh`, and
     `test-validate-product-feature-catalog.sh`.
   - Add a new focused validator or fixture only if extending the existing
     surfaces would make the checks less clear.

2. Harden required input coherence checks.
   - Assert `profile_path` or `profile`, `delivery_run_id` or `run-id`,
     target path, `outcome=cleaned`, and packet `route=branch-no-pr` appear
     consistently where accepted surfaces require them.
   - Add negative controls for optional markers such as `[profile=<...>]` or
     `[run-id=<...>]` on delivery admission surfaces.
   - Ensure missing delivery inputs fail closed before mutation, and resume
     evidence remains limited to fresh target-bound workflow evidence.

3. Harden alias and program review asymmetry checks.
   - Assert the additive alias delegates to `proposal-program-delivery` and
     names the canonical workflow.
   - Assert no native alias command file, command manifest entry, workflow
     id, registry entry, or lifecycle delivery mode exists for the alias.
   - Assert `program-review-revision`, `review-program`, and `revise-program`
     remain parent-local and do not edit child manifests, child receipts,
     child validation verdicts, child archive metadata, or child terminal
     outcomes.

4. Harden product catalog and host projection coherence checks.
   - Verify catalog references for proposal delivery and terminal closeout
     match canonical source surfaces and do not claim unavailable host
     projections.
   - Inspect `.codex` projection availability and source references as
     non-authoritative mirror evidence only.
   - When catalog prose outstates current source or projection availability,
     correct `.octon/framework/product/features/catalog.yml` within this
     packet's promotion target instead of editing host projections.

5. Add refusal and boundary negative controls.
   - Parent closeout must reject non-terminal child outcomes or missing
     child-owned evidence.
   - Archive handoff must reject parent summaries or aggregate receipts as
     substitutes for child archive metadata and child receipts.
   - Cleanup disposition must reject deletion or cleanup claims without the
     owning cleanup route and retained cleanup authorization.
   - Terminal proof must reject generated, proposal-local, host projection,
     dashboard, chat, or model-memory mirrors as authority.
   - Generated-output freshness checks must require canonical publication or
     freshness evidence and reject direct generated-output edits.

6. Record child-owned implementation evidence.
   - Create or update `support/implementation-run.md` after durable changes
     land. It must include at least `verdict`, `implemented_at`, and
     `promotion_evidence_count`, plus the exact changed files and validation
     commands.
   - Create or update `support/validation.md` with command, cwd, start/end
     time or run order, exit code, bounded output summary, evidence class, and
     known gaps.
   - Create or update `support/implementation-conformance-review.md` with
     `verdict: pass` only after conformance validation passes.
   - Create or update `support/post-implementation-drift-churn-review.md` with
     `verdict: pass` only after post-implementation drift validation passes.

## Required Validators

Run the relevant changed-surface tests and the full packet gates from the
repository root:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-delivery-workflow.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-workflow.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-packet-delivery.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-program-delivery.sh
bash .octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/test-proposal-program-delivery-guardrails.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-lifecycle-contracts.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-product-feature-catalog.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-product-feature-catalog.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-surface-validation-hardening --skip-registry-check --skip-promotion-target-checks
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-surface-validation-hardening
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-surface-validation-hardening
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-surface-validation-hardening --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-surface-validation-hardening/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-surface-validation-hardening --mode pre-integration-architecture-review --require-pass
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-surface-validation-hardening
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-surface-validation-hardening
```

If implementation adds a new validator or test, add that command to
`support/validation.md` and run it before the conformance and drift gates.

## Evidence Classes

Classify validation evidence explicitly:

- behavior proof for accepted delivery command, skill, workflow, and lifecycle
  behavior;
- boundary proof for alias non-authority, parent-summary refusal, child-owned
  receipt refusal, archive handoff refusal, cleanup refusal, and terminal
  proof refusal;
- catalog/projection coherence proof for product catalog claims and `.codex`
  mirror availability;
- generated-output freshness proof for any generated projection inspected by
  validation;
- proposal/input non-authority proof showing proposal-local files and raw
  inputs remain lineage only.

## Rollback

Rollback is a governed follow-up revert or supersession of only this child
packet's durable edits and packet-local support evidence. Rollback must not
delete sibling child evidence, parent program evidence, retained run evidence,
generated publication receipts, host projections, archive records, cleanup
records, Git state, branch state, or unrelated dirty worktree changes.

## Terminal Criteria

Implementation is complete for this route only when:

- durable edits stay inside the declared promotion targets;
- `support/implementation-run.md` records `verdict: pass`,
  `implemented_at`, and `promotion_evidence_count`;
- lifecycle surface validation catches required input drift, alias authority
  widening, missing intentional asymmetry documentation, catalog overclaims,
  parent-as-child evidence substitution, archive handoff substitution, cleanup
  without route authority, terminal proof authority drift, and generated-output
  freshness bypasses;
- `support/implementation-conformance-review.md` passes and
  `validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-surface-validation-hardening`
  exits successfully;
- `support/post-implementation-drift-churn-review.md` passes and
  `validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-lifecycle-surface-validation-hardening`
  exits successfully.

Refuse implemented, closeout, archive-ready, cleaned, parent-program-complete,
branch-cleanup, or terminal-current-state claims while either
post-implementation receipt is missing, failing, unresolved, blocked, stale, or
not validated by its corresponding script.
