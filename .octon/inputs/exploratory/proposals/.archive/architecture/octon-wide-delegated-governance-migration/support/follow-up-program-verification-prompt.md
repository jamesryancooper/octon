# Program Verification Prompt

program_verification_prompt_id: octon-wide-delegated-governance-migration-program-verification-prompt-2026-06-10
proposal_path: .octon/inputs/exploratory/proposals/architecture/octon-wide-delegated-governance-migration
route_id: generate-program-verification-prompt
lifecycle_id: proposal-program
program_run_id: lifecycle-proposal-program-1781073115145-fe49ec37
status: operational-aid
generated_at: 2026-06-10T13:55:34Z

This prompt is an operational aid for the parent program verification and
correction loop. It does not approve execution, widen scope, create authority,
replace run contracts, replace proposal manifests, replace child-owned
receipts, or substitute for retained validation evidence.

Use this prompt to run aggregate parent verification after the program
implementation orchestration run. The verification loop must write both
parent-local receipts:

- `support/program-implementation-orchestration-conformance-review.md`
- `support/program-post-implementation-orchestration-drift-churn-review.md`

Both receipts may summarize child state, but they must not satisfy child
receipts, child validation verdicts, child promotion targets, child archive
metadata, rollback handles, or child terminal outcomes.

## Prompt Generation Basis

The prompt bundle was consumed through a compact capsule with fresh alignment
evidence:

- prompt set: `octon-proposal-lifecycle-generate-program-verification-prompt`
- bundle digest: `sha256:448d78168c4caefbe7757ab19c6430a47008a33132e2534f5754c104d9365bb6`
- alignment receipt:
  `.octon/state/evidence/validation/extensions/prompt-alignment/2026-06-10T13-13-19Z-octon-proposal-lifecycle-octon-proposal-lifecycle-generate-program-verification-prompt.yml`
- route run: `lifecycle-proposal-program-1781073115145-fe49ec37`

Generation-time digest checks for the required repo anchors and prompt assets
matched the compact capsule.

## Profile Selection Receipt

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- atomic posture: verify one implemented parent program from retained
  aggregate evidence while preserving child-owned authority boundaries
- transitional exception: not authorized

## Mandatory Reads

Before writing either receipt, read the current parent packet and retained run
evidence:

- `proposal.yml`
- `architecture-proposal.yml`
- `navigation/source-of-truth-map.md`
- `navigation/artifact-catalog.md`
- `resources/child-packet-index.yml`
- `architecture/child-packet-contract.md`
- `architecture/packet-sequence.md`
- `architecture/target-architecture.md`
- `architecture/implementation-plan.md`
- `architecture/acceptance-criteria.md`
- `validation-plan.md`
- `RISK-REGISTER.md`
- `support/implementation-grade-completeness-review.md`
- `support/proposal-review.md`
- `support/program-implementation-orchestration-prompt.md`
- `support/program-implementation-orchestration-run.md`
- `.octon/state/evidence/runs/workflows/lifecycle-proposal-program-1781073115145-fe49ec37/parent/aggregate-child-outcomes-20260610T133510Z.yml`
- `.octon/state/control/execution/runs/lifecycle-proposal-program-1781073115145-fe49ec37/program-lifecycle-checkpoint.yml`
- `.octon/state/evidence/runs/workflows/lifecycle-proposal-program-1781073115145-fe49ec37/aggregate-terminal-blockers.yml`
- `.octon/state/evidence/runs/workflows/lifecycle-proposal-program-1781073115145-fe49ec37/program-events.ndjson`
- `.octon/state/evidence/runs/workflows/lifecycle-proposal-program-1781073115145-fe49ec37/parent/delegated-promotion-parent-promote-proposal.yml`

Then read each child archive path named by the aggregate child outcome evidence
and inspect the child-owned receipts listed there:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/proposal-closeout.md`

## Required Verification Commands

Run the parent validators:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/octon-wide-delegated-governance-migration
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/octon-wide-delegated-governance-migration
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/octon-wide-delegated-governance-migration
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/octon-wide-delegated-governance-migration
```

Run proposal validators for each archived child packet listed in the aggregate
evidence:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package <child-archive-path>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package <child-archive-path>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package <child-archive-path>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package <child-archive-path>
```

If a validator is unavailable or blocked, record the exact command, exit
status, stderr/stdout location if retained, and why the missing evidence blocks
or limits the receipt verdict. Do not convert a blocked command into a passing
manual assertion.

## Conformance Receipt Requirements

Write
`support/program-implementation-orchestration-conformance-review.md` with at
least these top-level fields:

```text
verdict: pass|fail
unresolved_items_count: <integer>
child_receipt_summary_count: <integer>
child_authority_preserved: yes|no
```

Use `verdict: pass` and `child_authority_preserved: yes` only when all of the
following are true:

- `proposal.yml#status` is `implemented`.
- The parent `support/program-implementation-orchestration-run.md` reports
  `verdict: pass`, `child_authority_preserved: yes`,
  `required_child_count: 9`, `terminal_child_count: 9`,
  `archived_child_count: 9`, `blocked_required_child_count: 0`, and
  `child_receipt_summary_count: 36`, or the receipt explains a current,
  evidence-backed count change.
- Aggregate child outcome evidence reports `verdict: pass`,
  `child_authority_preserved: yes`, all required children terminal and
  archived, zero blocked required children, and retained parent evidence under
  `.octon/state/evidence/runs/workflows/lifecycle-proposal-program-1781073115145-fe49ec37/**`.
- The checkpoint records every required child with `current_state: archived`,
  `final_verdict: completed`, and terminal, verification, and closeout gates
  true.
- The aggregate terminal blocker evidence reports
  `blocked_required_child_count: 0`.
- Each required child archive exists and carries passing child-owned
  implementation-run, implementation-conformance, post-implementation
  drift/churn, and closeout receipts.
- Child dependency gates match `resources/child-packet-index.yml` and
  `architecture/packet-sequence.md`.
- Parent promotion targets are covered by child-owned implementation evidence
  or explicit no-op evidence; the parent does not claim to have implemented
  runtime behavior directly.
- Durable evidence outside proposal-local inputs supports aggregate program
  completion and promotion.
- Generated projections and read models remain derived-only and are not used
  as authority, permission, support, promotion, or closeout truth.
- The parent receipt does not rewrite, edit, satisfy, or replace child
  manifests, subtype manifests, child receipts, child validators, child
  promotion targets, child archive metadata, rollback handles, or terminal
  outcomes.

Include sections for blockers, checked evidence, child receipt summary,
promotion target coverage, validator coverage, generated output coverage,
rollback coverage, downstream reference coverage, exclusions, and final route
recommendation.

## Drift And Churn Receipt Requirements

Write
`support/program-post-implementation-orchestration-drift-churn-review.md` with
at least these top-level fields:

```text
verdict: pass|fail
unresolved_items_count: <integer>
child_receipt_summary_count: <integer>
child_authority_preserved: yes|no
```

Use `verdict: pass` and `child_authority_preserved: yes` only when all of the
following are true:

- The conformance receipt exists and reports `verdict: pass`,
  `unresolved_items_count: 0`, and `child_authority_preserved: yes`.
- No active child packet directories remain for children that the aggregate
  evidence reports as archived.
- Archived child packets preserve implemented archive metadata and child-owned
  receipts without moving child authority into the parent packet.
- Durable framework, instance, state, and generated targets do not acquire new
  active proposal-path dependencies except retained evidence or historical
  provenance references.
- Generated proposal registry and generated effective projections remain
  derived-only; if they are refreshed, retained publication/freshness evidence
  is cited.
- Naming and policy vocabulary do not reintroduce generic approval defaults in
  delegated-governance domains without typed exception or negative-control
  context.
- Parent and child promotion target families remain inside their declared
  `octon-internal` scope; no repo-local or host projection target is silently
  mixed into the parent.
- Churn is limited to lifecycle support, retained evidence, generated
  projections with publication receipts, and declared child promotion targets.
- The route does not mutate runtime behavior, connector permissions, generated
  projections, or state/control truth while claiming to perform verification
  only.

Include sections for blockers, checked evidence, active proposal-path
backreference scan, naming drift review, generated projection freshness,
manifest and schema validity, repo-local projection boundary review,
target-family boundary review, churn review, validators run, exclusions, and
final closeout recommendation.

## Pass And Failure Semantics

If any required command fails, any required receipt is missing or stale, any
child archive is missing, any child-owned receipt is failing, or the parent
would need to own child truth to pass, write failing receipts with concrete
blockers. Do not omit the receipts because verification failed.

If both aggregate receipts pass, the final route recommendation should be:

`Proceed to generate-program-closeout-prompt.`

If either aggregate receipt fails, the final route recommendation should name
the smallest correction route or human escalation needed before program
closeout can continue.

## Authority Boundary

The parent program may coordinate sequence, dependency gates, aggregate
verification, evidence references, and closeout refusal criteria. It may not
create, revise, satisfy, or replace child-owned authority, child receipts,
child validation verdicts, child promotion targets, child archive metadata,
rollback handles, or child terminal outcomes.

Proposal-local files and generated prompts remain temporary non-authority
support. Durable authority, control truth, retained evidence, and generated
projection publication must remain in their declared repository classes.
