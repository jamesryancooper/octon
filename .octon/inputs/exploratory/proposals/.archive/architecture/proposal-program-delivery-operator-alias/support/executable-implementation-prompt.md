# Executable Implementation Prompt

implementation_prompt_id: proposal-program-delivery-operator-alias-implementation-20260630T230002Z
proposal_path: .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-operator-alias
route_id: run-packet-implementation
status: operational-aid
generated_at: 2026-06-30T23:00:02Z
implementation_authorized: yes
authorized_review_digest: sha256:069852117cd9667b75ccac9f104128ffa19c1377c87a203c05ce0e18ce19d1aa

This prompt is an operational implementation aid for the accepted proposal
packet. It does not authorize execution by itself, create lifecycle authority,
replace proposal manifests, replace target-owned receipts, replace
implementation conformance, replace post-implementation drift/churn review,
replace generated publication freshness, replace branch authorization, replace
repo hygiene cleanup, or substitute for retained evidence.

Proposal-local files, generated prompts, generated outputs, host projections,
dashboards, chat history, model memory, and tool state are non-authoritative
implementation input only. Durable authority may land only in approved
promotion targets outside the proposal packet.

## Prompt Generation Gate Receipt

This prompt was generated only after these gates passed from the repository
root:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-operator-alias --require-implementation-authorization
```

Observed result at prompt-generation time: `errors=0 warnings=0`.

The accepted review and strict pre-integration architecture review were bound
to packet digest:

```text
sha256:069852117cd9667b75ccac9f104128ffa19c1377c87a203c05ce0e18ce19d1aa
```

Before durable edits, re-run the review gate and implementation readiness gate.
Stop if either gate fails, if the review digest is stale, if implementation
authorization is missing, or if clarification is required.

## Profile Selection Receipt

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- atomic posture: add one coherent optional operator alias for proposal program
  delivery and validation proving it delegates to the canonical
  `proposal-program-delivery` wrapper
- transitional exception: not authorized

## Mandatory Preflight

Before editing durable targets, re-read:

- repository ingress and mandatory constitutional/kernel files;
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-operator-alias/proposal.yml`;
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-operator-alias/architecture-proposal.yml`;
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-operator-alias/architecture/target-architecture.md`;
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-operator-alias/architecture/implementation-plan.md`;
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-operator-alias/architecture/acceptance-criteria.md`;
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-operator-alias/validation-plan.md`;
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-operator-alias/support/implementation-grade-completeness-review.md`;
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-operator-alias/support/proposal-review.md`;
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-operator-alias/support/pre-integration-architecture-review.yml`;
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/commands/manifest.fragment.yml`;
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/bundle-matrix.md`;
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/lifecycles/proposal-program.contract.yml`;
- `.octon/framework/capabilities/runtime/commands/manifest.yml`;
- `.octon/framework/capabilities/runtime/commands/proposal-program-delivery.md`;
- `.octon/framework/capabilities/runtime/skills/operations/proposal-program-delivery/SKILL.md`;
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-workflow.sh`;
- `.octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-program-delivery.sh`;
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/test-proposal-program-delivery-guardrails.sh`.

Then run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-operator-alias --skip-registry-check --skip-promotion-target-checks
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-operator-alias
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-operator-alias --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-operator-alias/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-operator-alias --mode pre-integration-architecture-review --require-pass
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-operator-alias
```

Refuse implementation unless all commands pass, `proposal.yml#status` is
`accepted`, the proposal review verdict is `accepted`,
`implementation_prompt_authorized: yes`, `open_blocking_findings_count: 0`,
and the reviewed packet digest remains fresh.

## Current Repository Baseline

The repository already has the canonical program delivery wrapper:

- workflow-backed route id: `proposal-program-delivery`;
- command surface: `/proposal-program-delivery target=<proposal-program-path> outcome=cleaned profile=<profile-path> run-id=<id>`;
- operations skill: `proposal-program-delivery`;
- lifecycle contract delivery mode: `proposal-program-delivery`;
- validators and tests for delivery admission inputs, child-owned evidence,
  non-authority boundaries, and delivery receipt integrity.

The repository also has packet-delivery alias precedent through
`octon-proposal-run-packet-delivery`. There is no current
`octon-proposal-run-program-delivery` alias surface in the canonical proposal
lifecycle commands.

At prompt generation time, the worktree already had unrelated dirty changes in
some delivery surfaces. Preserve existing user or prior-route edits. Do not
revert, overwrite, or broad-format unrelated changes while adding the alias.

## Goal

Add the optional operator-facing command alias
`octon-proposal-run-program-delivery` with display label
`Run Program to Clean Delivery`.

The alias must delegate to the canonical `proposal-program-delivery` wrapper.
It must use the same required inputs, validation gates, evidence requirements,
and refusal criteria as canonical proposal program delivery. It must not create
a new lifecycle contract, workflow id, skill authority, closeout rule, archive
rule, cleanup rule, generated publication rule, Git mutation rule, branch
cleanup rule, or terminal proof rule.

## Promotion Targets

Durable edits may touch only these approved promotion target families:

- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/commands/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/bundle-matrix.md`
- `.octon/framework/capabilities/runtime/commands/`
- `.octon/framework/capabilities/runtime/skills/operations/proposal-program-delivery/`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/`

Do not edit host projection files such as `.claude/commands/**`,
`.codex/commands/**`, or `.cursor/commands/**` in this packet. Host projection
publication is explicitly owned by a separate child packet.

Do not hand-edit `.octon/generated/**`, `.octon/state/control/**`, or unrelated
proposal packets. Do not mutate `proposal.yml#status`; later lifecycle routes
own implemented, terminal, archived, or cleaned status changes.

## Workstreams

1. Add the additive lifecycle command alias.

   - Add a command document for
     `.octon/inputs/additive/extensions/octon-proposal-lifecycle/commands/octon-proposal-run-program-delivery.md`.
   - Add `octon-proposal-run-program-delivery` to
     `.octon/inputs/additive/extensions/octon-proposal-lifecycle/commands/manifest.fragment.yml`.
   - Use display name `Run Program to Clean Delivery`.
   - Use the same required argument contract as canonical program delivery:
     `target=<proposal-program-path> outcome=cleaned profile=<profile-path> run-id=<id>`.
   - State that the alias delegates to `proposal-program-delivery` and
     `.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/workflow.yml`.
   - State that missing `profile` or `run-id` fails closed before mutation
     unless satisfied by fresh, target-bound workflow evidence allowed by the
     canonical delivery contract.

2. Update discovery surfaces without creating a second route.

   - Update
     `.octon/inputs/additive/extensions/octon-proposal-lifecycle/context/bundle-matrix.md`
     so program delivery discovery shows the operator alias while preserving
     `proposal-program-delivery` as the workflow and skill.
   - Update `.octon/framework/capabilities/runtime/commands/manifest.yml` and
     command documentation only as needed to expose the alias in command
     discovery.
   - If a framework command alias file is needed, keep it as a thin alias
     document that points to `/proposal-program-delivery`; do not duplicate
     workflow semantics.
   - Update
     `.octon/framework/capabilities/runtime/skills/operations/proposal-program-delivery/SKILL.md`
     only to mention that the alias is an accepted operator vocabulary for the
     same canonical wrapper.

3. Preserve delivery authority boundaries.

   - Do not add a workflow under
     `.octon/framework/orchestration/runtime/workflows/meta/` for the alias.
   - Do not add a lifecycle contract `delivery_modes` entry for the alias.
   - Do not add new receipt schemas, profile schemas, closeout semantics,
     archive semantics, cleanup semantics, branch semantics, or terminal proof
     semantics.
   - Do not let parent program summaries, aggregate delivery receipts,
     delivery evidence indexes, generated outputs, host state, chat, model
     memory, dashboards, or proposal-local support files satisfy child-owned
     evidence or delivery admission inputs.

4. Add boundary validation and negative controls.

   - Extend
     `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-workflow.sh`
     or a narrower existing validator so it proves:
     - the alias command surface exists;
     - the alias display label is `Run Program to Clean Delivery`;
     - the alias delegates to `proposal-program-delivery`;
     - the alias retains required `target`, `outcome`, `profile`, and
       `run-id` admission inputs;
     - the alias does not introduce an independent workflow, lifecycle mode,
       receipt schema, closeout rule, archive rule, cleanup rule, Git mutation
       rule, branch cleanup rule, generated publication rule, or terminal proof
       rule.
   - Extend `.octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-program-delivery.sh`
     with positive and negative controls for alias delegation and required
     inputs.
   - Extend
     `.octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/test-proposal-program-delivery-guardrails.sh`
     with extension-level assertions for alias discoverability and no authority
     widening.

5. Record implementation evidence.

   - Produce
     `.octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-operator-alias/support/implementation-run.md`
     after durable edits.
   - Produce
     `.octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-operator-alias/support/validation.md`
     with command, cwd, start/end time, exit code, and compact result for each
     validator.
   - Produce
     `.octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-operator-alias/support/implementation-conformance-review.md`.
   - Produce
     `.octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-operator-alias/support/post-implementation-drift-churn-review.md`.

## Required Validation

Run these commands from the repository root after implementation:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-operator-alias --skip-registry-check --skip-promotion-target-checks
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-operator-alias
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-operator-alias --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-operator-alias/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-operator-alias --mode pre-integration-architecture-review --require-pass
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-operator-alias
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-workflow.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-program-delivery.sh
bash .octon/inputs/additive/extensions/octon-proposal-lifecycle/validation/tests/test-proposal-program-delivery-guardrails.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-operator-alias
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery-operator-alias
git diff --check
```

If the implementation changes broader command registry behavior, run the
smallest additional existing validator that owns that behavior and record why
it was necessary in `support/validation.md`.

## Retained Evidence Expectations

`support/implementation-run.md` must record:

- implementation start and end time;
- files changed;
- how the alias delegates to `proposal-program-delivery`;
- no-new-workflow, no-new-lifecycle-mode, and no-new-authority checks;
- validation commands run and outcomes;
- any blockers or skipped checks with owning next route.

`support/implementation-conformance-review.md` must pass and cover:

- every promotion target listed in this prompt;
- the exact alias id `octon-proposal-run-program-delivery`;
- display label `Run Program to Clean Delivery`;
- delegation to `proposal-program-delivery`;
- required input preservation;
- generated output exclusion;
- rollback coverage;
- closeout and archive refusal criteria.

`support/post-implementation-drift-churn-review.md` must pass and cover:

- active proposal-path backreference scan;
- naming drift review;
- no duplicate workflow, lifecycle mode, schema, closeout, archive, cleanup,
  Git, branch cleanup, generated publication, or terminal proof surface;
- generated projection freshness or explicit generated-output exclusion;
- manifest and validator coherence;
- unrelated dirty worktree changes excluded from this packet.

Retained validation evidence should stay proposal-local unless a validator
requires a canonical evidence root. If retained evidence outside `inputs/**` is
created, place it under the appropriate `.octon/state/evidence/validation/**`
or `.octon/state/evidence/runs/**` root and classify it as evidence-only.

## Delegation Boundary

Implementation may use bounded helpers or subagents only for disjoint file
groups inside the approved promotion targets. Delegation must not authorize
execution, approve closeout, mutate lifecycle status, publish generated
outputs, or replace final integration review. The orchestrator remains
responsible for final integration and validation.

## Rollback

Rollback removes only the alias surface and its validation additions:

- remove `octon-proposal-run-program-delivery` from additive lifecycle command
  discovery;
- remove the alias command document;
- remove bundle-matrix alias references while preserving
  `proposal-program-delivery`;
- remove framework command discovery alias additions, if any;
- remove skill alias wording while preserving canonical
  `proposal-program-delivery`;
- remove alias-specific validator and test assertions.

Rollback must not remove or weaken the canonical `proposal-program-delivery`
workflow, command, skill, lifecycle contract, profile schema, receipt schema,
delivery evidence index, delivery preflight, child-owned evidence checks, or
delivery validators.

## Closeout Refusal Criteria

Refuse closeout, archive, terminal, or cleaned claims when:

- any prerequisite review, architecture review, or implementation readiness
  gate is stale or failing;
- the alias does not exist in command discovery;
- the alias omits required `target`, `outcome`, `profile`, or `run-id` inputs;
- the alias does not delegate to `proposal-program-delivery`;
- the alias introduces independent lifecycle, workflow, closeout, archive,
  cleanup, generated publication, Git mutation, branch cleanup, or terminal
  proof semantics;
- validation fails or is not recorded;
- `support/implementation-conformance-review.md` is missing or not passing;
- `support/post-implementation-drift-churn-review.md` is missing or not
  passing;
- implementation tries to use parent program evidence, aggregate delivery
  receipts, generated outputs, host state, dashboards, chat, model memory,
  tool state, or proposal-local support files as a substitute for target-owned
  delivery evidence.

After this prompt is implemented and both post-implementation receipts pass,
the next lifecycle route is packet verification and correction, followed by
packet closeout only through the owning lifecycle route.
