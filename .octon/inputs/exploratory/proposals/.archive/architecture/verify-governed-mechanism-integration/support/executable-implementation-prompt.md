# Executable Implementation Prompt

implementation_prompt_id: verify-governed-mechanism-integration-implementation-prompt-20260613T210223Z
proposal_path: .octon/inputs/exploratory/proposals/architecture/verify-governed-mechanism-integration
route_id: run-packet-implementation
status: operational-aid
generated_at: 2026-06-13T21:02:23Z
delivery_prompt_mode: standalone-packet-implementation-and-terminal-closeout-orchestration

This prompt is an operational implementation aid for the accepted proposal
packet. It does not approve execution, create mechanism authority, replace
proposal manifests, replace implementation conformance, replace drift/churn,
replace generated publication, replace terminal freshness, or substitute for
retained evidence.

Durable authority may land only in approved promotion targets outside the
proposal path. Proposal-local files, support receipts, generated proposal
registry entries, raw inputs, generated projections, generated prompts, host
state, dashboards, chat history, model memory, and tool availability are
implementation input or derived context only. They are not runtime, policy,
support, retained-evidence, publication, closeout, cleanup, terminal, or
archive authority.

## Prompt Generation Gate Receipt

This prompt was generated only after the accepted proposal review and
implementation readiness gates passed:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/verify-governed-mechanism-integration --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/verify-governed-mechanism-integration
```

Observed result at prompt-generation time: `errors=0 warnings=0`.

The accepted review and pre-integration architecture review were bound to:

```text
sha256:3f27c0e2940a178bc07c023fc48ede4cf2841781aec3fe4254bb8edb86310814
```

Re-run both gates before durable edits. Stop if either gate fails, if the
review digest is stale, if implementation authorization is missing, or if
clarification is required.

## Profile Selection Receipt

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- atomic posture: implement one coherent governed mechanism integration
  verification gate across workflow, schemas, validators, tests, lifecycle
  hooks, publication freshness, terminal freshness, product guidance, and
  governed mechanism index guidance
- transitional exception: not authorized

## Mandatory Preflight

Before editing durable targets, re-read:

- repository ingress and mandatory constitutional/kernel files;
- `proposal.yml` and `architecture-proposal.yml`;
- `navigation/source-of-truth-map.md`;
- `architecture/target-architecture.md`;
- `architecture/implementation-plan.md`;
- `architecture/acceptance-criteria.md`;
- `support/implementation-grade-completeness-review.md`;
- `support/proposal-review.md`;
- `support/pre-integration-architecture-review.yml`;
- existing proposal lifecycle contracts and lifecycle prompts;
- existing implementation conformance and post-implementation drift/churn
  validators;
- current governed cross-surface mechanism index and validator;
- current product feature catalog and validator;
- current generated publication and terminal freshness validators;
- current proposal packet terminal closeout workflow, profile, receipt, and
  validator surfaces if present.

Then run these gates from the repository root:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/verify-governed-mechanism-integration
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/verify-governed-mechanism-integration
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/verify-governed-mechanism-integration --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/verify-governed-mechanism-integration
```

Refuse implementation unless all commands pass, `proposal.yml#status` is
`accepted`, the review verdict is `accepted`,
`implementation_prompt_authorized: yes`, `open_blocking_findings_count: 0`, and
the reviewed packet digest is fresh.

## Current Repository Baseline

The repository already has separate owners for the evidence this packet must
compose:

- implementation conformance review and validation;
- post-implementation drift/churn review and validation;
- generated proposal registry and publication freshness;
- current-state and post-integration architecture review support receipts;
- proposal lifecycle implementation, closeout, archive, and terminal routes;
- Change closeout state-machine routes, Change receipts, and Git/GitHub route
  evidence;
- repo-hygiene cleanup authorization and cleanup helper revalidation;
- proposal packet terminal closeout as the aggregate packet terminalization
  route when its durable workflow is available.

This packet must not replace any of those owners. It adds a governed mechanism
integration verification gate that cites those target-owned receipts and fails
closed when required mechanism surfaces, validators, freshness proofs, or
`not_applicable` rationales are missing.

## Target End State

The implemented end state is a durable native workflow named
`verify-governed-mechanism-integration` plus strict profile and receipt
contracts.

The implementation must establish all of these facts:

- mechanism proposals declare a schema-backed mechanism integration profile;
- each required mechanism surface class is declared or has an explicit
  `not_applicable` rationale;
- the workflow writes
  `support/governed-mechanism-integration-evaluation.yml` for the target
  packet and retained run evidence under state/evidence;
- the support receipt validates against
  `governed-mechanism-integration-receipt-v1`;
- the receipt cites implementation conformance, post-implementation drift,
  generated publication, current-state architecture review, validators,
  evidence refs, authority boundary verdicts, surface coverage, non-authority
  classification, and implemented packet digest binding;
- lifecycle postmortem stays optional and evidence-only;
- current-state mechanism architecture review stays an evidence lens and never
  becomes the whole gate;
- product feature catalog and governed mechanism index entries remain
  navigation or architecture guidance only;
- generated projections, raw inputs, proposal-local files, chat, model memory,
  host state, dashboards, and tool state remain non-authority;
- mechanism proposal closeout and archive readiness require a current passing
  governed mechanism integration receipt tied to the implemented packet digest;
- merged or cleaned terminal outcomes require scoped terminal freshness proof
  on main for generated projections, proposal registry, child spines, and
  mechanism docs touched by the mechanism proposal.

This packet is self-referential: it implements the gate that later packets will
use. Do not claim the gate exists until the durable workflow, schemas,
validators, tests, and lifecycle hooks have landed and passed validation. After
durable implementation, run the new gate against this packet where applicable
before terminal closeout or archive readiness is claimed.

## In Scope

Durable edits may touch only these approved promotion target families:

- `.octon/framework/orchestration/runtime/workflows/meta/verify-governed-mechanism-integration/`
- `.octon/framework/orchestration/runtime/workflows/registry.yml`
- `.octon/framework/orchestration/runtime/workflows/manifest.yml`
- `.octon/framework/product/contracts/governed-mechanism-integration-profile-v1.schema.json`
- `.octon/framework/product/contracts/governed-mechanism-integration-receipt-v1.schema.json`
- `.octon/framework/product/features/catalog.yml`
- `.octon/framework/product/features/governed-mechanism-integration-verification.md`
- `.octon/framework/product/features/README.md`
- `.octon/framework/cognition/_meta/architecture/governed-cross-surface-mechanisms/`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-governed-mechanism-integration-profile.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-governed-mechanism-integration-receipt.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-validate-governed-mechanism-integration.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-governed-cross-surface-mechanisms.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-product-feature-catalog.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-lifecycle-terminal-freshness.sh`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/`

After durable edits land, packet-local receipts are required:

- `.octon/inputs/exploratory/proposals/architecture/verify-governed-mechanism-integration/support/implementation-run.md`
- `.octon/inputs/exploratory/proposals/architecture/verify-governed-mechanism-integration/support/implementation-conformance-review.md`
- `.octon/inputs/exploratory/proposals/architecture/verify-governed-mechanism-integration/support/post-implementation-drift-churn-review.md`

The workflow may also write:

- `.octon/inputs/exploratory/proposals/architecture/verify-governed-mechanism-integration/support/governed-mechanism-integration-evaluation.yml`

Retained validation evidence must live outside `inputs/**`, preferably under:

- `.octon/state/evidence/validation/proposals/verify-governed-mechanism-integration/<timestamp>/`
- `.octon/state/evidence/runs/workflows/<run-id>/governed-mechanism-integration/<mechanism-id>/`

## Out Of Scope

Do not edit these surfaces for this packet unless a separately authorized route
requires retained evidence output:

- `.octon/state/control/**`;
- `.octon/generated/**` by hand;
- `.octon/instance/**` governance policy or support-target files;
- `.github/**`, provider settings, branch protection settings, or connector
  admissions;
- root adapters or host projections outside canonical publication scripts.

Do not add a new mechanism-level control plane. Do not add a parallel finding,
disposition, conformance, drift, publication, architecture review, lifecycle
postmortem, closeout, cleanup, branch, PR, GitHub, or archive authority model.
Do not mutate `proposal.yml#status`; leave it `accepted`. Later lifecycle
routes own implemented, terminal, and archived status changes.

If implementation requires out-of-scope files, generated-output hand edits,
host projection regeneration outside owning publishers, branch deletion, PR
creation, cleanup, or target-family widening, stop and report
`needs-packet-revision` with evidence.

## Ordered Workstreams

### 0. Preflight And Evidence Directory

1. Record current worktree state and preserve unrelated existing edits.
2. Run the mandatory proposal standard, architecture, review, and readiness
   gates.
3. Create a retained evidence directory under
   `.octon/state/evidence/validation/proposals/verify-governed-mechanism-integration/<timestamp>/`.
4. Record the Profile Selection Receipt there and in
   `support/implementation-run.md`.
5. Capture baseline searches for governed mechanism index, product feature
   catalog, workflow registry, proposal lifecycle hooks, generated publication
   validators, terminal freshness validators, implementation conformance,
   drift/churn, current-state architecture review, and lifecycle postmortem
   surfaces.

### 1. Workflow Contract

Add `.octon/framework/orchestration/runtime/workflows/meta/verify-governed-mechanism-integration/`.

The workflow contract and stages must:

- bind `proposal_path`, `mechanism_id`, `mechanism_profile_ref`, and mode;
- validate the mechanism integration profile;
- collect implementation conformance, drift/churn, generated publication, and
  current-state architecture review refs;
- run deterministic profile and receipt validators;
- write `support/governed-mechanism-integration-evaluation.yml`;
- retain workflow evidence under
  `.octon/state/evidence/runs/workflows/<run-id>/governed-mechanism-integration/<mechanism-id>/`;
- stop on missing, stale, omitted, or authority-overclaiming evidence;
- keep side effects limited to proposal-local support writes, retained workflow
  evidence, and deterministic validation output.

Register the workflow in `.octon/framework/orchestration/runtime/workflows/registry.yml`
and `.octon/framework/orchestration/runtime/workflows/manifest.yml`.

### 2. Profile And Receipt Schemas

Add:

- `.octon/framework/product/contracts/governed-mechanism-integration-profile-v1.schema.json`
- `.octon/framework/product/contracts/governed-mechanism-integration-receipt-v1.schema.json`

The profile schema must fail closed unless all required surface classes are
declared or carry an explicit `not_applicable` rationale:

- mechanism id and display name;
- owners;
- product feature refs;
- doctrine and documentation refs;
- workflows;
- skills;
- commands;
- schemas;
- validators;
- generated projections;
- evidence roots;
- lifecycle hooks;
- extension boundaries;
- authority and non-authority boundaries.

The receipt schema must require verdict, unresolved-item count, blockers,
profile ref, architecture review ref, conformance ref, drift ref, publication
refs, validator refs, evidence refs, authority boundary verdict, surface
coverage, non-authority classification, mode-specific coverage, implemented
packet digest binding, and terminal freshness refs when closeout or archive
claims require them.

### 3. Validators And Tests

Add:

- `.octon/framework/assurance/runtime/_ops/scripts/validate-governed-mechanism-integration-profile.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-governed-mechanism-integration-receipt.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-validate-governed-mechanism-integration.sh`

Tests must include positive fixtures and negative controls for:

- omitted required surface class without `not_applicable`;
- missing validator refs;
- stale digest binding;
- stale aliases;
- stale proposal backrefs;
- placeholder-marker receipts;
- generated output used as authority;
- proposal-local file used as authority;
- lifecycle postmortem used as gate authority;
- current-state architecture review used as the whole gate;
- missing implementation conformance ref;
- missing post-implementation drift ref;
- missing generated publication refs;
- missing terminal freshness refs when required.

Extend existing validators where needed:

- `validate-governed-cross-surface-mechanisms.sh`;
- `validate-product-feature-catalog.sh`;
- `validate-proposal-implementation-conformance.sh`;
- `validate-proposal-post-implementation-drift.sh`;
- `validate-proposal-lifecycle-terminal-freshness.sh`.

### 4. Proposal Lifecycle Hooks

Update `.octon/inputs/additive/extensions/octon-proposal-lifecycle/` only
enough to expose the mechanism integration verification requirement.

Lifecycle hooks must:

- require a proposed mechanism integration profile at proposal review when a
  packet declares a new or materially changed governed mechanism;
- require a current passing
  `support/governed-mechanism-integration-evaluation.yml` before implemented
  closeout or archive readiness for mechanism proposals;
- allow non-mechanism packets to record `not_applicable` with rationale;
- preserve proposal lifecycle ownership of implementation, closeout, archive,
  and terminal transitions.

### 5. Generated Publication And Terminal Freshness

The workflow must cite publication receipts from canonical publisher or
validator routes. Do not hand-edit generated output as freshness repair.

Candidate publisher and freshness surfaces include:

- `.octon/framework/capabilities/_ops/scripts/publish-capability-routing.sh`
- `.octon/framework/capabilities/_ops/scripts/publish-host-projections.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/generate-proposal-registry.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/publish-runtime-route-bundle.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/publish-pack-routes.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-lifecycle-terminal-freshness.sh`

After merge or terminal cleaned outcome, require scoped terminal freshness proof
on main for generated projections, proposal registry, child spines, and
mechanism docs touched by the mechanism proposal.

### 6. Documentation And Navigation

Update governed mechanism index guidance under
`.octon/framework/cognition/_meta/architecture/governed-cross-surface-mechanisms/`.

Add or update product feature navigation:

- `.octon/framework/product/features/governed-mechanism-integration-verification.md`
- `.octon/framework/product/features/catalog.yml`
- `.octon/framework/product/features/README.md`

The feature note and catalog entry must classify themselves as navigation-only
and point to durable workflow, schema, validator, evidence, generated, and
documentation surfaces without becoming authority.

### 7. Implementation Evidence

After durable changes, write or refresh `support/implementation-run.md` with at
least:

```yaml
verdict: pass|fail
implemented_at: <UTC timestamp>
promotion_evidence_count: <number>
profile_selection:
  release_state: pre-1.0
  change_profile: atomic
  transitional_exception_note: not authorized
retained_evidence_refs:
  - <path>
blockers:
  - <blocker-or-none>
```

Then write or refresh `support/implementation-conformance-review.md` and
`support/post-implementation-drift-churn-review.md`. Each must have
`verdict: pass|fail`, `unresolved_items_count`, checked evidence, validator
coverage, promotion target coverage, exclusions, and final closeout
recommendation.

Refuse implemented, closeout, terminal, or archive-ready claims while either
receipt is missing, failing, stale, unresolved, or unvalidated.

## Packet Delivery And Terminal Closeout Orchestration

Use this section to drive the packet from implementation into terminal lifecycle
readiness. It composes the completed Change closeout, repo-hygiene cleanup
authorization, and packet terminal closeout routes when they are available.

This orchestration does not create archive, Git, cleanup, publication,
terminal, or closeout authority. It validates target-owned receipts and cites
them in a packet-local terminal receipt or terminal-readiness map.

### Terminal Profile

Before terminalization, record a terminal profile in `support/implementation-run.md`
or retained run evidence:

```yaml
schema_version: standalone-packet-terminal-closeout-profile-v0
target_packet_path: .octon/inputs/exploratory/proposals/architecture/verify-governed-mechanism-integration
target_outcome: archive-ready
route_preference: branch-no-pr
pr_policy: do-not-create-pr-block-if-branch-no-pr-impossible
publication_freshness_policy: validate-or-refresh-through-owning-publishers-only
hygiene_policy: classify-first-authorize-before-delete
governed_mechanism_integration_policy: self-host-after-durable-workflow-exists
post_integration_architecture_review_policy: evidence-only-after-conformance-and-drift
packet_terminal_evaluator_policy: required-if-blocked-nonterminal-cancelled-rollback-or-repeated-retry
archive_movement_policy: archive-proposal-only
required_packet_receipts:
  - support/implementation-run.md
  - support/implementation-conformance-review.md
  - support/post-implementation-drift-churn-review.md
  - support/governed-mechanism-integration-evaluation.yml
terminal_receipt_policy: aggregate-only-does-not-replace-target-owned-receipts
```

Profile binding proves terminal intent and guardrails only. It does not
authorize durable edits, Git mutation, branch landing, branch deletion,
generated publication, cleanup, proposal status mutation, or archive movement.

### Terminal Sequence

Run terminalization as a resumable state machine:

1. Bind the terminal profile, target packet path, target outcome, route
   preference, PR policy, publication policy, hygiene policy, mechanism policy,
   and non-authority boundaries.
2. Verify durable implementation state for every approved promotion target.
3. Require current `support/implementation-conformance-review.md` and run
   `validate-proposal-implementation-conformance.sh`.
4. Require current `support/post-implementation-drift-churn-review.md` and run
   `validate-proposal-post-implementation-drift.sh`.
5. Run the newly durable `verify-governed-mechanism-integration` workflow
   against this packet when applicable. If the durable workflow or schemas are
   not yet available, terminalization must be blocked or limited to
   `terminal-readiness-map-only`.
6. Validate
   `support/governed-mechanism-integration-evaluation.yml` with
   `validate-governed-mechanism-integration-receipt.sh`.
7. Validate publication freshness for touched workflow, lifecycle, feature,
   mechanism index, registry, generated projection, and capability surfaces.
   Repair failed freshness only through canonical publishers.
8. Validate generated/input non-authority, run-health, capability publication,
   and extension publication coverage required by touched targets.
9. Classify repo-hygiene residue. Delete only through repo-hygiene cleanup
   authorization and helper revalidation.
10. Classify worktree hygiene. If non-packet residue or ambiguous residue
    blocks hygiene, stop with exact next route, usually `closeout-worktree` or
    `closeout-change`.
11. Run post-integration architecture review only after conformance and drift
    pass. Treat its receipt as evidence-only.
12. Run packet terminal evaluator or lifecycle-postmortem only as evidence when
    required by the terminal profile.
13. If Git mutation is required, delegate route selection and effects to the
    default work-unit and Change closeout state machine. For branch-no-PR,
    require exact source-SHA checks, governed landing authorization, branch
    cleanup authorization, fetch/sync, and local `main`/`origin/main`/landed-ref
    equality proof through existing Git/GitHub routes.
14. Emit packet terminal closeout receipt or terminal-readiness map. Verdict is
    `archive-ready` only when all gates pass and hygiene is not blocked.
15. Do not move the packet into `.archive`; run `archive-proposal` only after a
    separate archive route validates archive movement.

### Terminal Receipt Content

When a terminal receipt or terminal-readiness map is written, include at least:

```yaml
terminal_verdict: archive-ready|blocked|terminal-readiness-map-only
terminalized_at: <UTC timestamp>
target_packet_path: .octon/inputs/exploratory/proposals/architecture/verify-governed-mechanism-integration
target_outcome_requested: archive-ready
target_outcome_actual: archive-ready|blocked|implemented
implementation_conformance_receipt_ref: .octon/inputs/exploratory/proposals/architecture/verify-governed-mechanism-integration/support/implementation-conformance-review.md
post_implementation_drift_churn_receipt_ref: .octon/inputs/exploratory/proposals/architecture/verify-governed-mechanism-integration/support/post-implementation-drift-churn-review.md
governed_mechanism_integration_receipt_ref: .octon/inputs/exploratory/proposals/architecture/verify-governed-mechanism-integration/support/governed-mechanism-integration-evaluation.yml
publication_freshness_refs:
  - <path-or-not-applicable>
generated_input_non_authority_refs:
  - <path-or-not-applicable>
run_health_refs:
  - <path-or-not-applicable>
capability_publication_refs:
  - <path-or-not-applicable>
repo_hygiene_classification_ref: <path-or-not-applicable>
repo_hygiene_cleanup_authorization_ref: <path-or-none>
worktree_hygiene_ref: <path-or-not-applicable>
post_integration_architecture_review_ref: <path-or-not-applicable>
packet_terminal_evaluator_ref: <path-or-not-applicable>
git_github_route_ref: <path-or-not-applicable>
exact_sha_check_refs:
  - <path-or-not-applicable>
archive_movement_owner: archive-proposal
archive_movement_performed: false
blocker_class: none|missing-mechanism-gate|missing-evidence|stale-evidence|hygiene-blocked|git-route-blocked|validator-failed|scope-overrun
blocker_detail: <detail-or-none>
next_canonical_route: archive-proposal|proposal-packet-terminal-closeout|verify-governed-mechanism-integration|closeout-worktree|closeout-change|run-packet-implementation|blocked
non_authority_declarations:
  proposal_inputs: non-authority
  generated_outputs: derived-only
  generated_prompts: non-authority
  host_state: non-authority
  dashboards: non-authority
  chat: non-authority
  tool_state: non-authority
  model_memory: non-authority
```

The aggregate receipt may cite target-owned evidence but cannot satisfy it.

### Terminal Hard Gates

Do not claim `archive-ready` unless all applicable gates pass:

- implementation conformance receipt exists, is current, and validates;
- post-implementation drift/churn receipt exists, is current, and validates;
- governed mechanism integration receipt exists, is current, and validates;
- generated publication and terminal freshness validators pass;
- governed cross-surface mechanism validator passes;
- product feature catalog validator passes;
- generated/input non-authority validation passes;
- repo hygiene and worktree hygiene are not blocked;
- post-integration architecture review output remains evidence-only;
- lifecycle-postmortem or packet terminal evaluator output remains
  evidence-only;
- Git/GitHub hosted checks, branch landing authorization, branch cleanup
  authorization, and final sync proof exist when Git mutation is required;
- archive movement is not performed by the terminal receipt.

### Terminal Stop Conditions

Stop and record a blocked terminal outcome when:

- the mechanism integration workflow/schema/validators are not durable enough
  to self-host the terminal gate;
- a needed edit or terminal check falls outside approved promotion targets;
- a validator fails without a narrow non-blocking rationale;
- conformance, drift/churn, mechanism integration, publication freshness, or
  terminal freshness receipts are missing, stale, failing, or unresolved;
- publication freshness requires direct generated-output edits;
- residue remains that cannot be classified as expected retained evidence;
- Git/GitHub route evidence is missing for a required mutation;
- any surface attempts to use lifecycle-postmortem, current-state architecture
  review, proposal inputs, generated outputs, generated prompts, host state,
  chat, tool state, or model memory as authority;
- archive relocation is attempted outside `archive-proposal`.

The correct outcome for these conditions is `blocked` with the exact blocker
and next canonical route, not an archive-ready overclaim.

## Required Validation

Run these proposal lifecycle validators:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/verify-governed-mechanism-integration
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/verify-governed-mechanism-integration
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/verify-governed-mechanism-integration --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/verify-governed-mechanism-integration
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/verify-governed-mechanism-integration
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/verify-governed-mechanism-integration
```

Run implementation validators and tests:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-governed-mechanism-integration-profile.sh --help
bash .octon/framework/assurance/runtime/_ops/scripts/validate-governed-mechanism-integration-receipt.sh --help
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-governed-mechanism-integration.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-governed-cross-surface-mechanisms.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-product-feature-catalog.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-lifecycle-terminal-freshness.sh --help
git diff --check
```

Replace `--help` smoke checks with concrete fixture or package invocations
when the implementation adds validator arguments and fixtures. Also run any
workflow, schema, lifecycle contract, generated publication, shell syntax, or
fixture tests introduced or touched by the implementation.

## Rollback And Closeout Refusal

Rollback is removal or reversion of the workflow, registry and manifest
entries, profile schema, receipt schema, validators, tests, lifecycle hook
updates, product feature entry, product feature catalog/README updates, and
governed mechanism index guidance from this packet. Retain emitted validation
or workflow run evidence under `.octon/state/evidence/**` for auditability.

Refuse closeout, terminal, archive, or implemented-status claims if:

- `support/implementation-conformance-review.md` is missing or failing;
- `support/post-implementation-drift-churn-review.md` is missing or failing;
- `support/governed-mechanism-integration-evaluation.yml` is missing, failing,
  stale, unresolved, or not tied to the implemented packet digest when the gate
  applies;
- `validate-proposal-implementation-conformance.sh` fails;
- `validate-proposal-post-implementation-drift.sh` fails;
- governed mechanism profile or receipt validators fail;
- generated publication or terminal freshness validators fail;
- current-state mechanism architecture review is treated as the whole gate;
- lifecycle postmortem is treated as authority;
- product feature catalog or governed mechanism index docs are treated as
  authority;
- generated outputs, raw inputs, proposal-local files, generated prompts, host
  state, dashboards, chat, model memory, or tool availability are treated as
  authority;
- the implementation adds a parallel finding model or mechanism control plane;
- archive movement is attempted outside `archive-proposal`.

The next lifecycle route after this prompt is `run-packet-implementation`.
