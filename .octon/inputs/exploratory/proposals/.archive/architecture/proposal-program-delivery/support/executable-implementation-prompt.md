# Executable Implementation Prompt

implementation_prompt_id: proposal-program-delivery-implementation-prompt-20260614T025542Z
proposal_path: .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery
route_id: run-packet-implementation
status: operational-aid
generated_at: 2026-06-14T02:55:42Z
delivery_prompt_mode: standalone-packet-implementation-and-terminal-closeout-orchestration

This prompt is an operational implementation aid for the accepted proposal
packet. It does not approve execution, create delivery authority, replace
proposal manifests, replace target-owned lifecycles, replace implementation
conformance, replace drift/churn, replace generated publication, replace branch
authorization, replace repo hygiene, replace terminal freshness, or substitute
for retained evidence.

Durable authority may land only in approved promotion targets outside the
proposal path. Proposal-local files, generated implementation prompts, support
receipts, generated proposal registry entries, raw inputs, generated
projections, host state, dashboards, chat history, model memory, and tool
availability are implementation input or derived context only. They are not
runtime, policy, support, retained-evidence, delivery, publication, closeout,
cleanup, branch, terminal, or archive authority.

## Prompt Generation Gate Receipt

This prompt was generated only after implementation readiness passed and a
fresh accepted proposal review authorized implementation prompt generation:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery
```

Observed result at prompt-generation time: `errors=0 warnings=0`.

The accepted review and pre-integration architecture review were bound to:

```text
sha256:c91ded08da06586535981c2cddb49d7ff9f6d4527e58958ff8a709de721add4c
```

Re-run both gates before durable edits. Stop if either gate fails, if the
review digest is stale, if implementation authorization is missing, or if
clarification is required.

## Profile Selection Receipt

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- atomic posture: implement one coherent Governed Proposal Delivery surface
  across workflow, profile schema, receipt schema, validators, tests, lifecycle
  hooks, command entrypoint, skill entrypoint, product feature documentation,
  generated publication integration, and terminal-proof integration
- transitional exception: not authorized

## Mandatory Preflight

Before editing durable targets, re-read:

- repository ingress and mandatory constitutional/kernel files;
- `proposal.yml` and `architecture-proposal.yml`;
- `navigation/source-of-truth-map.md`;
- `architecture/target-architecture.md`;
- `architecture/implementation-plan.md`;
- `architecture/acceptance-criteria.md`;
- `validation-plan.md`;
- `NON-GOALS.md`;
- `RISK-REGISTER.md`;
- `support/implementation-grade-completeness-review.md`;
- `support/proposal-review.md`;
- `support/pre-integration-architecture-review.yml`;
- default work-unit policy and Change closeout contracts;
- existing proposal-program and proposal-packet lifecycle contracts;
- existing implementation conformance and post-implementation drift/churn
  validators;
- existing generated publication freshness validators;
- existing governed mechanism integration workflow, profile, receipt, and
  validators;
- existing proposal-packet terminal closeout workflow, profile, receipt, and
  validators;
- existing repo-hygiene cleanup authorization receipt and cleanup helper
  contracts;
- existing branch landing and branch cleanup authorization contracts and
  scripts.

Then run these gates from the repository root:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery
```

Refuse implementation unless all commands pass, `proposal.yml#status` is
`accepted`, the review verdict is `accepted`,
`implementation_prompt_authorized: yes`, `open_blocking_findings_count: 0`, and
the reviewed packet digest is fresh.

## Current Repository Baseline

The repository already has separate owners for the lifecycles that Governed
Proposal Delivery must coordinate:

- proposal-program lifecycle structure and child readiness;
- proposal-packet review, implementation, closeout, terminal closeout, and
  archive readiness;
- implementation conformance review and validation;
- post-implementation drift/churn review and validation;
- generated proposal registry and generated publication freshness;
- governed mechanism integration verification when a child changes a governed
  cross-surface mechanism;
- Change closeout state machine, Change receipts, branch route evidence, and
  Git/GitHub route proof;
- repo-hygiene cleanup authorization and cleanup helper validation;
- branch landing authorization and branch cleanup authorization;
- lifecycle terminal freshness and terminal current-state proof;
- closeout-worktree as the route-neutral dirty-worktree wrapper.

This packet must not replace any of those owners. It adds a delivery workflow
that selects the next target-owned lifecycle, passes scoped non-authorizing
context, validates returned receipts, replans from current repository state,
and aggregates evidence into a strict delivery receipt.

## Target End State

The implemented end state is a native Governed Proposal Delivery process with
the first concrete mode named `proposal-program-delivery`.

The implementation must establish all of these facts:

- a schema-backed delivery profile declares the target proposal program,
  target outcome, route preference, no-PR policy, stash policy, child execution
  strategy, validator expectations, publication expectations, mechanism checks,
  closeout requirements, terminal proof, and final sync requirements;
- a schema-backed delivery receipt aggregates target-owned evidence without
  replacing any child, proposal, closeout, cleanup, publication, branch, or
  terminal receipt;
- a native workflow at
  `.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/`
  binds the profile, validates parent and child state, runs or resumes existing
  lifecycles, validates receipts, replans after material mutations, emits a
  delivery receipt, and fails closed on stale or missing proof;
- `/proposal-program-delivery` exists only as a thin command and skill
  entrypoint that normalizes operator arguments into a profile and dispatches
  the workflow;
- the workflow blocks when `branch-no-pr` is impossible and the profile forbids
  PR creation;
- parent proposal-program evidence cannot substitute for child-owned review,
  implementation, conformance, drift/churn, closeout, archive, or terminal
  receipts;
- branch-no-pr landing requires landing authorization, exact SHA validation,
  hosted landing evidence, final sync proof, and terminal current-state proof;
- branch cleanup requires governed branch cleanup authorization before local or
  remote source refs are deleted;
- repo-hygiene deletion requires cleanup authorization; classification alone
  never authorizes deletion;
- generated projections are refreshed only through owning publishers and are
  treated as derived-only;
- the final `cleaned` outcome requires terminal current-state proof after the
  last mutation plus final worktree hygiene and `main == origin/main ==
  landed_ref` proof when landing occurred.

## In Scope

Durable edits may touch only these approved promotion target families:

- `.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/`
- `.octon/framework/orchestration/runtime/workflows/registry.yml`
- `.octon/framework/orchestration/runtime/workflows/manifest.yml`
- `.octon/framework/product/contracts/proposal-program-delivery-profile-v1.schema.json`
- `.octon/framework/product/contracts/proposal-program-delivery-receipt-v1.schema.json`
- `.octon/framework/product/features/governed-proposal-delivery.md`
- `.octon/framework/product/features/catalog.yml`
- `.octon/framework/product/features/README.md`
- `.octon/framework/capabilities/runtime/commands/proposal-program-delivery.md`
- `.octon/framework/capabilities/runtime/commands/manifest.yml`
- `.octon/framework/capabilities/runtime/skills/operations/proposal-program-delivery/SKILL.md`
- `.octon/framework/capabilities/runtime/skills/manifest.yml`
- `.octon/framework/capabilities/runtime/skills/registry.yml`
- `.octon/framework/capabilities/runtime/skills/capabilities.yml`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-profile.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-receipt.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-workflow.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-program-delivery.sh`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/`

After durable edits land, packet-local receipts are required:

- `.octon/inputs/exploratory/proposals/architecture/proposal-program-delivery/support/implementation-run.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-delivery/support/implementation-conformance-review.md`
- `.octon/inputs/exploratory/proposals/architecture/proposal-program-delivery/support/post-implementation-drift-churn-review.md`

The workflow implementation may also define example or fixture delivery
profiles and receipts under validator fixture roots when needed for tests.
Retained validation evidence should live outside `inputs/**`, preferably under:

- `.octon/state/evidence/validation/proposals/proposal-program-delivery/<timestamp>/`
- `.octon/state/evidence/runs/workflows/<run-id>/proposal-program-delivery/<target-program-id>/`

## Out Of Scope

Do not edit these surfaces for this packet unless a separately authorized route
requires retained evidence output:

- `.octon/state/control/**`;
- `.octon/generated/**` by hand;
- `.octon/instance/**` governance policy or support-target files;
- `.github/**`, provider settings, branch protection settings, or connector
  admissions;
- root adapters or host projections outside canonical publication scripts.

Do not add a second control plane for proposal programs, Git, branch cleanup,
repo hygiene, publication, archive, Change closeout, branch landing, or
terminal proof. Do not mutate `proposal.yml#status`; leave it `accepted`.
Later lifecycle routes own implemented, terminal, and archived status changes.

If implementation requires out-of-scope files, generated-output hand edits,
host projection regeneration outside owning publishers, provider rule changes,
branch deletion, PR creation, cleanup, or target-family widening, stop and
report `needs-packet-revision` with evidence.

## Ordered Workstreams

### 0. Preflight And Evidence Directory

1. Record current worktree state and preserve unrelated existing edits.
2. Run the mandatory proposal standard, architecture, review, and readiness
   gates.
3. Create a retained evidence directory under
   `.octon/state/evidence/validation/proposals/proposal-program-delivery/<timestamp>/`.
4. Record the Profile Selection Receipt there and in
   `support/implementation-run.md`.
5. Capture baseline searches for delivery workflow surfaces, proposal-program
   lifecycle contracts, proposal-packet terminal closeout, governed mechanism
   integration, generated publication freshness, Change closeout, branch
   authorization, repo hygiene cleanup, lifecycle terminal freshness, command
   manifests, skill manifests, and product feature catalog entries.

### 1. Profile Contract

Add
`.octon/framework/product/contracts/proposal-program-delivery-profile-v1.schema.json`.

The profile schema must require:

- `schema_version`;
- `profile_id`;
- `target_program_path`;
- `target_outcome`;
- `route_preference`;
- `pr_policy`;
- `stash_policy`;
- `child_execution`;
- `required_proposal_validators`;
- `required_implementation_validators`;
- `publication_checks`;
- `mechanism_integration_checks`;
- `closeout_requirements`;
- `hygiene_requirements`;
- `terminal_proof_requirements`;
- `final_sync_requirements`;
- `non_authority_boundaries`.

It must fail closed when a required surface is omitted without an explicit
`out_of_scope` or `not_applicable` rationale. It must reject PR fallback when
`pr_policy.mode` forbids PR creation. It must default or validate
`stash_policy` as `forbidden` unless a separate evidence-backed route permits a
stash.

### 2. Receipt Contract

Add
`.octon/framework/product/contracts/proposal-program-delivery-receipt-v1.schema.json`.

The receipt schema must require:

- profile ref and digest;
- target program ref and digest;
- target outcome and actual outcome;
- parent proposal-program lifecycle receipt refs;
- child packet registry and child receipt coverage;
- child-owned review, implementation, conformance, drift/churn, closeout,
  archive, and terminal receipt refs when applicable;
- generated registry and publication freshness evidence refs;
- governed mechanism integration receipt refs when applicable;
- lifecycle residue and repo-hygiene cleanup evidence refs;
- Change receipt and closeout route evidence refs;
- branch landing authorization and branch cleanup authorization refs when
  branch-no-pr landing or deletion occurred;
- final sync proof for local `main`, `origin/main`, and `landed_ref`;
- terminal current-state proof emitted after the last mutation;
- final worktree hygiene result;
- explicit blockers and downgrade reason when `cleaned` cannot be proven;
- non-authority classification for proposal-local files, generated prompts,
  generated outputs, raw inputs, host state, dashboards, chat, model memory, and
  tool availability.

Negative controls must reject parent-summary substitution, stale child
receipts, missing conformance, missing drift/churn, stale generated
publication, missing governed mechanism integration receipt, branch-no-pr
landing without authorization, branch cleanup without authorization, missing
terminal proof, dirty-worktree cleaned overclaim, final main/origin mismatch,
generated prompt authority overclaim, and proposal-local authority overclaim.

### 3. Workflow Contract

Add
`.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/`.

The workflow contract and stages must cover:

1. bind profile, target program, route preference, target outcome, and
   non-authority rules;
2. validate the delivery profile;
3. validate parent proposal-program structure, freshness, and child registry;
4. run or resume the existing proposal-program lifecycle without taking
   ownership of child transitions;
5. validate every child-owned lifecycle receipt required by the profile;
6. validate implementation conformance and post-implementation drift/churn
   receipts;
7. validate generated proposal registry and generated publication freshness
   through owning publishers;
8. run governed mechanism integration verification when a delivered child
   changes a governed mechanism;
9. classify lifecycle residue and route cleanup through proposal lifecycle or
   repo-hygiene cleanup owners;
10. hand off the coherent Change candidate to `closeout-worktree` or
    `closeout-change`;
11. validate branch-no-pr landing authorization before hosted mutation;
12. validate branch cleanup authorization before deleting local or remote
    source refs;
13. fetch, sync local `main`, and prove local `main`, `origin/main`, and
    `landed_ref` equality when landing occurred;
14. emit terminal current-state proof after the last mutation;
15. validate final worktree hygiene before claiming `cleaned`;
16. emit the delivery receipt and retained run evidence.

Register the workflow in:

- `.octon/framework/orchestration/runtime/workflows/registry.yml`
- `.octon/framework/orchestration/runtime/workflows/manifest.yml`

The workflow must be state-driven. It may replan after every material state
change, but it must stop on missing, stale, ambiguous, or authority-overclaiming
evidence.

### 4. Validators And Tests

Add:

- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-profile.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-receipt.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-workflow.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-program-delivery.sh`

Use existing shell validator patterns and local JSON/YAML tooling already used
by neighboring validators. Do not add new dependencies unless a Dependency
Receipt proves the need.

The test suite must include positive fixtures and negative controls for:

- valid minimal branch-no-pr cleaned profile;
- valid blocked or downgraded delivery receipt;
- missing profile gate declarations;
- forbidden PR fallback;
- stash policy omitted or widened without evidence;
- parent summary used in place of child receipts;
- stale child receipts;
- missing implementation conformance;
- missing drift/churn receipt;
- stale generated publication evidence;
- governed mechanism change without mechanism integration receipt;
- branch-no-pr mutation without landing authorization;
- branch deletion without cleanup authorization;
- repo-hygiene deletion without cleanup authorization;
- missing terminal current-state proof;
- dirty worktree with `cleaned` overclaim;
- local `main` and `origin/main` mismatch;
- generated prompt or proposal-local file used as authority.

### 5. Lifecycle Hooks

Update `.octon/inputs/additive/extensions/octon-proposal-lifecycle/` only enough
to expose delivery as a cross-lifecycle runner and support receipt interaction.

The lifecycle hook changes must:

- keep proposal-program and proposal-packet transitions target-owned;
- pass scoped non-authorizing context to target lifecycles;
- require lifecycle-interaction return evidence before a step is considered
  resolved;
- preserve child-owned receipt requirements;
- prevent parent summaries from satisfying child receipts;
- surface blocked, downgraded, or needs-revision outcomes without mutating
  child authority.

Do not move Git, branch cleanup, repo hygiene, publication, terminal proof, or
Change closeout authority into `proposal-program`.

### 6. Command And Skill Entry Points

Add the thin command:

- `.octon/framework/capabilities/runtime/commands/proposal-program-delivery.md`

Add the thin skill:

- `.octon/framework/capabilities/runtime/skills/operations/proposal-program-delivery/SKILL.md`

Update manifests and registries:

- `.octon/framework/capabilities/runtime/commands/manifest.yml`
- `.octon/framework/capabilities/runtime/skills/manifest.yml`
- `.octon/framework/capabilities/runtime/skills/registry.yml`
- `.octon/framework/capabilities/runtime/skills/capabilities.yml`

The operator-facing invocation is:

```text
/proposal-program-delivery target=<program-path> route=branch-no-pr outcome=cleaned
```

The command and skill must normalize arguments into a delivery profile and
dispatch the workflow. They must not authorize delivery, proposal transitions,
closeout, cleanup, publication, branch landing, branch deletion, terminal proof,
or archive.

### 7. Product Feature Documentation

Add:

- `.octon/framework/product/features/governed-proposal-delivery.md`

Update:

- `.octon/framework/product/features/catalog.yml`
- `.octon/framework/product/features/README.md`

Documentation must explain:

- Governed Proposal Delivery as a cross-lifecycle coordinator;
- Proposal Program Delivery as the first mode;
- profile, receipt, workflow, command, and skill surfaces;
- hard gates;
- target-owned lifecycle boundaries;
- no-PR policy behavior;
- branch-no-pr authorization requirements;
- cleanup authorization requirements;
- terminal proof and final sync requirements;
- advisory-only evidence classes;
- generated, raw input, proposal-local, host, dashboard, chat, model memory, and
  tool state non-authority boundaries.

### 8. Generated Publication

Do not edit `.octon/generated/**` by hand. If implementation changes capability
publication, proposal registry, workflow publication, product catalog
publication, or generated effective views, refresh them only through the owning
publisher scripts.

Record publication commands and retained evidence under the implementation
evidence directory. If a generated publisher is unavailable or blocked, record
the blocker and refuse final closeout/archive claims.

### 9. Implementation Evidence

After durable edits land, write:

- `support/implementation-run.md`;
- a fresh passing `support/implementation-conformance-review.md`;
- a fresh passing `support/post-implementation-drift-churn-review.md`.

The conformance receipt must map implemented files back to every approved
promotion target and explain any target with no direct file addition. The
drift/churn receipt must compare intended packet scope to actual durable
changes, generated publication effects, lifecycle hook effects, and
non-authority boundaries.

## Packet Delivery And Terminal Closeout Orchestration

This packet is not complete when durable files compile or validators pass. It is
complete only when the packet lifecycle can proceed end-to-end without
authority overclaim.

### Terminal Profile

After implementation conformance and drift/churn pass, run or emulate the
proposal-packet terminal closeout profile for this packet with:

- target outcome: `archive-ready`;
- delivery mode: `packet implementation terminalization`;
- required checks: implementation conformance, post-implementation drift/churn,
  generated publication freshness, product feature catalog, workflow registry,
  command/skill manifests, governed mechanism integration when applicable,
  lifecycle terminal freshness, final worktree hygiene, and route evidence;
- non-authority classification: proposal-local files, generated prompts, raw
  inputs, generated outputs, host state, dashboards, chat, model memory, and
  tool availability remain non-authority.

### Terminal Sequence

1. Validate implementation conformance.
2. Validate post-implementation drift/churn.
3. Validate delivery profile, receipt, and workflow validators.
4. Validate proposal lifecycle hooks and child-readiness interaction behavior.
5. Validate generated proposal registry and publication freshness after all
   authored changes.
6. Validate governed cross-surface mechanism index and product feature catalog.
7. If this implementation changes a governed mechanism, run
   `verify-governed-mechanism-integration` and validate its receipt.
8. Classify lifecycle residue and repo hygiene residue.
9. Route cleanup only through authorized repo-hygiene or closeout workflows.
10. Resolve Change closeout through `closeout-worktree` or `closeout-change`.
11. For branch-no-pr, validate landing authorization before hosted mutation.
12. Validate branch cleanup authorization before branch deletion.
13. Fetch, sync local `main`, and prove `main == origin/main == landed_ref`
    after landing.
14. Emit terminal current-state proof after the final mutation.
15. Validate final worktree hygiene.
16. Only then claim packet terminal readiness or archive readiness.

### Terminal Receipt Content

The terminal receipt for this packet must cite:

- implemented durable target refs and digests;
- implementation conformance receipt;
- post-implementation drift/churn receipt;
- proposal-program-delivery profile validator evidence;
- proposal-program-delivery receipt validator evidence;
- proposal-program-delivery workflow validator evidence;
- test suite evidence;
- generated publication evidence;
- product feature catalog evidence;
- governed mechanism integration evidence when applicable;
- Change closeout route evidence;
- repo hygiene cleanup evidence when applicable;
- branch landing authorization and branch cleanup authorization when applicable;
- terminal current-state proof;
- final sync proof;
- final worktree hygiene result;
- rollback handle.

### Hard Refusal Conditions

Refuse implemented, terminal, cleaned, or archive-ready claims when any of
these are true:

- proposal review gate or implementation-readiness gate fails;
- durable edits exceed approved promotion targets;
- delivery profile schema is missing or weak;
- delivery receipt schema allows evidence substitution;
- workflow lacks hard gates for child receipts, generated publication, branch
  authorization, cleanup authorization, terminal proof, or final sync;
- validators lack negative controls for authority overclaims;
- command or skill can create a PR despite a no-PR profile;
- branch-no-pr can land without landing authorization;
- branch cleanup can delete refs without cleanup authorization;
- repo hygiene can delete from classification alone;
- generated outputs are hand-edited;
- implementation conformance or drift/churn receipts fail or remain scaffolded;
- generated publication freshness cannot be proven;
- terminal current-state proof is missing after the final mutation;
- worktree hygiene is dirty while claiming `cleaned`;
- local `main`, `origin/main`, and `landed_ref` are not equal after landing.

## Required Validation

Run the packet lifecycle validators:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery
```

After implementation, run or add concrete equivalents for:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-profile.sh --profile <delivery-profile.yml>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-receipt.sh --receipt <delivery-receipt.yml>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-workflow.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-program-delivery.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package <program-path>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --program <program-path>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-readiness-projection.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-lifecycle-terminal-freshness.sh --package .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-terminal-closeout-workflow.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-governed-mechanism-integration-profile.sh --profile <mechanism-profile.yml>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-governed-mechanism-integration-receipt.sh --receipt <mechanism-receipt.yml>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-governed-cross-surface-mechanisms.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-product-feature-catalog.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-capability-publication-state.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-state-machine.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-closeout-worktree-wrapper.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-repo-hygiene-governance.sh
git diff --check
```

Replace placeholder profile, receipt, and program paths with concrete retained
evidence refs emitted by the implementation run. Do not count a `--help`
invocation as validation evidence.

## Rollback

Rollback is atomic:

- remove the delivery workflow;
- remove the profile and receipt schemas;
- remove validators, fixtures, and tests;
- remove command and skill entrypoints plus manifest and registry entries;
- remove lifecycle hook changes;
- remove product feature documentation and catalog entries;
- regenerate any derived outputs through owning publishers from reverted
  authored state;
- retain validation and run evidence under `state/evidence` for auditability.

Rollback must not delete retained evidence, active control state, unrelated
user changes, or generated outputs by hand.

## Final Instruction

Implement the packet through durable promotion targets only, produce the
required conformance and drift/churn receipts, validate publication and terminal
freshness, and refuse closeout or archive claims until the packet lifecycle can
complete end-to-end with target-owned evidence.

The next lifecycle route after this prompt is `run-packet-implementation`.
