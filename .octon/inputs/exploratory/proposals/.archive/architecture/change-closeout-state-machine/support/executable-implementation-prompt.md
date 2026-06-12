# Executable Implementation Prompt

implementation_prompt_id: change-closeout-state-machine-implementation-prompt-2026-05-21
proposal_path: .octon/inputs/exploratory/proposals/architecture/change-closeout-state-machine
route_id: run-packet-implementation
status: operational-aid
generated_at: 2026-05-21T00:45:18Z
refreshed_at: 2026-06-12T16:05:47Z
delivery_guidance_ref: .octon/inputs/exploratory/proposals/architecture/proposal-program-delivery
delivery_prompt_mode: standalone-packet-implementation-and-delivery-orchestration

This prompt is an operational implementation aid for the accepted proposal
packet. It does not approve execution, widen scope, create authority, replace
the default work-unit policy, replace proposal manifests, or substitute for
retained evidence.

Durable authority may land only in the approved promotion targets outside the
proposal path. Proposal-local files, support receipts, generated proposal
registry entries, raw inputs, generated projections, host state, GitHub state,
chat history, model memory, and tool availability are implementation input or
derived context only. They are not runtime, policy, control, retained-evidence,
publication, or closeout authority.

## Mandatory Preflight

Before editing durable targets, re-read:

- repository ingress and the constitutional kernel;
- proposal workspace rules and the architecture proposal standard;
- `proposal.yml` and `architecture-proposal.yml`;
- `navigation/source-of-truth-map.md`;
- `architecture/target-architecture.md`;
- `architecture/implementation-plan.md`;
- `architecture/acceptance-criteria.md`;
- `validation-plan.md`;
- `RISK-REGISTER.md`;
- `NON-GOALS.md`;
- `support/implementation-grade-completeness-review.md`;
- `support/proposal-review.md`;
- live default work-unit policy, Change receipt schema, closeout workflow,
  closeout skills, git/worktree autonomy contract, closeout lifecycle
  validator, hosted no-PR validator, branch cleanup helpers, and existing
  closeout tests that this packet touches.

Then run these gates from the repository root:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/change-closeout-state-machine
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/change-closeout-state-machine --require-implementation-authorization
```

Refuse implementation unless both commands pass, `proposal.yml#status` is
`accepted`, the review verdict is `accepted`,
`implementation_prompt_authorized: yes`, `open_blocking_findings_count: 0`, and
the reviewed packet digest is fresh.

Use this profile selection:

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- atomic posture: one coherent Change closeout state-machine implementation
  across the approved target families, with no partial live closeout authority
  and with post-implementation validation before any success claim
- transitional exception: not authorized by this packet

## Current Repository Baseline

The live repository already contains:

- `default-work-unit.yml` and `default-work-unit.md` with the existing
  `direct-main`, `branch-no-pr`, `branch-pr`, and `stage-only-escalate` route
  set, target lifecycle outcomes, actual lifecycle outcomes, hosted no-PR
  landing requirements, and cleanup/sync evidence gates;
- `change-receipt-v1.schema.json` with route, target outcome, actual outcome,
  landing, hosted landing, cleanup, main-alignment, validation, durable-history,
  rollback, and closeout outcome fields;
- closeout workflow contract files under
  `.octon/framework/orchestration/runtime/workflows/meta/closeout/`;
- route-neutral `closeout-change` and PR-backed `closeout-pr` skills with
  reference material;
- `git-worktree-autonomy-contract.yml` with route guards, helper posture,
  cleanup safety, and PR-backed review policy;
- `validate-change-closeout-lifecycle-alignment.sh` and
  `test-change-closeout-lifecycle-alignment.sh` as the existing closeout
  alignment validator and test spine.

The durable state-machine contract files
`.octon/framework/product/contracts/change-closeout-state-machine.yml` and
`.octon/framework/product/contracts/change-closeout-state-machine.md` do not
exist yet. Creating them is part of this implementation.

## Target End State

The implemented end state is a durable Change Closeout State Machine product
contract that operationalizes, but does not replace, the canonical
Change-first default work-unit policy.

The durable implementation must establish all of these facts:

- the route set remains exactly `direct-main`, `branch-no-pr`, `branch-pr`,
  and `stage-only-escalate`;
- route selection, target lifecycle outcome, and actual lifecycle outcome stay
  distinct and machine-checkable;
- hosted no-PR landing remains a `branch-no-pr` lifecycle path, not a new
  top-level route;
- PR-backed closeout remains delegated only after selected route `branch-pr`;
- the state machine defines inventory, residue classification, route and target
  resolution, safe cleanup, change-set preparation, validation, hosted no-PR
  landing, PR-backed delegation, branch cleanup, receipt/evidence, final
  verification, and final report phases;
- each loop phase has re-entry conditions, backward transitions, exit evidence,
  and stop or escalation conditions;
- destructive cleanup requires direct evidence such as containment in
  `origin/main`, patch equivalence, tracked replacement, explicit ignored or
  local-residue status, or validator proof;
- completed or cleaned closeout claims require state-machine evidence;
- `published-branch`, `published`, and `ready` cannot satisfy completed
  closeout;
- force-push, ambiguous deletion, reset, restoration, overwrite, and deletion
  of user-owned work are denied or fail closed;
- `.octon/inputs/**`, proposal-local files, generated outputs, host state,
  GitHub state, chat, model memory, and tool availability remain
  non-authoritative for closeout;
- validators prove the positive and negative cases needed to prevent route,
  lifecycle, cleanup, publication, and authority overclaims.

This packet does not authorize extension activation, generated/effective
publication, host projection regeneration, PR creation, branch cleanup,
force-push, destructive cleanup, or status promotion by itself.

## In Scope

Durable edits may touch only these approved promotion target families:

- `.octon/framework/product/contracts/change-closeout-state-machine.yml`
- `.octon/framework/product/contracts/change-closeout-state-machine.md`
- `.octon/framework/product/contracts/default-work-unit.yml`
- `.octon/framework/product/contracts/default-work-unit.md`
- `.octon/framework/product/contracts/change-receipt-v1.schema.json`
- `.octon/framework/orchestration/runtime/workflows/meta/closeout/`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-pr/`
- `.octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml`
- `.octon/framework/assurance/runtime/_ops/scripts/`
- `.octon/framework/assurance/runtime/_ops/tests/`

Expected durable outputs may include the smallest coherent set of files in
those families, such as:

- a machine-readable `change-closeout-state-machine-v1` contract;
- a human-readable state-machine contract that explains phases, loops,
  outcomes, evidence gates, and non-authority boundaries;
- references from the default work-unit policy and documentation to the state
  machine without weakening or duplicating route authority;
- `stateful_closeout` evidence fields and conditional receipt-schema rules for
  completed or cleaned claims;
- closeout workflow updates that distinguish read-only analysis from mutating
  route phases and point at the state machine;
- `closeout-change` updates that execute state-machine phases rather than a
  linear checklist;
- a `closeout-worktree` wrapper that decomposes dirty worktree residue into
  singular `closeout-change` runs, records explicit include/exclude boundaries,
  retained residue, blockers, delegated closeout refs, and next-route
  conditions, and never creates a `Closeout Changes` model;
- `closeout-pr` wording updates that use `Closeout PR-Backed Change` as the
  human-facing name while preserving the command id and subflow role;
- git/worktree autonomy updates for residue classification, safe cleanup,
  branch cleanup, and final sync evidence;
- validator and test coverage for state-machine evidence, residue
  classification, cleanup safety, hosted no-PR landing, branch cleanup,
  direct-main final sync, PR-backed delegation, and non-authority boundaries.

After durable edits land, packet-local receipts are required:

- `.octon/inputs/exploratory/proposals/architecture/change-closeout-state-machine/support/implementation-run.md`
- `.octon/inputs/exploratory/proposals/architecture/change-closeout-state-machine/support/implementation-conformance-review.md`
- `.octon/inputs/exploratory/proposals/architecture/change-closeout-state-machine/support/post-implementation-drift-churn-review.md`

Retained validation and promotion evidence must live outside `inputs/**`,
preferably under:

- `.octon/state/evidence/validation/proposals/change-closeout-state-machine/<timestamp>/`
- `.octon/state/evidence/runs/workflows/<run-id>/` when a lifecycle runner
  creates run evidence

## Out Of Scope

Do not edit these surfaces for this packet:

- `.octon/instance/**`, except through separately authorized retained evidence
  if a lifecycle runner records its own run evidence;
- `.octon/state/control/**`;
- `.octon/generated/effective/**`;
- `.octon/generated/cognition/**`;
- `.octon/generated/proposals/registry.yml`, except through normal proposal
  registry generation if a later lifecycle route explicitly requires it;
- root `README.md`, root `AGENTS.md`, `CLAUDE.md`, or repo-local projection
  adapters;
- extension activation manifests, capability publication state, locality
  publication state, host projections, connector admissions, or generated
  effective runtime publication;
- GitHub PRs, PR templates, branch protection settings, or provider rulesets
  unless the selected Change route independently authorizes them.

The current implementation plan mentions receipt examples. The accepted
promotion target list does not independently authorize
`.octon/framework/product/contracts/examples/change-receipts/**`. Prefer
temporary validator fixtures or tests inside the approved assurance targets. If
durable example edits become necessary, stop and report `needs-packet-revision`
or provide explicit evidence that the file is covered by an approved target
before editing it.

Do not change `proposal.yml#status`; leave it as `accepted`. The later
promotion or closeout lifecycle route owns any implemented-status or archive
rewrite.

If implementation requires any out-of-scope file, new authority class,
generated/effective publication, host projection regeneration, extension
activation, PR creation, destructive cleanup, branch deletion, or target-family
widening, stop and report `needs-packet-revision` with evidence.

## Ordered Workstreams

### 0. Preflight And Evidence Directory

1. Record current worktree state and preserve unrelated existing edits.
2. Run the mandatory implementation-readiness and strict review gates.
3. Create a retained evidence directory under
   `.octon/state/evidence/validation/proposals/change-closeout-state-machine/<timestamp>/`.
4. Record the Profile Selection Receipt there and in
   `support/implementation-run.md`: `release_state=pre-1.0`,
   `change_profile=atomic`, `transitional_exception_note=not authorized`.
5. Capture baseline searches for existing closeout state-machine, route,
   receipt, cleanup, hosted landing, branch cleanup, worktree residue,
   generated authority, proposal-path authority, and validator surfaces.

### 1. Product Contract

Create `.octon/framework/product/contracts/change-closeout-state-machine.yml`
and `.octon/framework/product/contracts/change-closeout-state-machine.md`.

The contract must define:

- `change-closeout-state-machine-v1` identity and status;
- applicable default work unit: Change;
- relationship to `default-work-unit.yml`, with default-work-unit route
  authority preserved;
- phase list with mode, route applicability, re-entry triggers, backward
  transitions, exit evidence, and stop or escalation conditions;
- allowed routes and lifecycle outcomes without adding `branch-land-no-pr`,
  `Closeout Changes`, or a peer `Publish Changes` workflow;
- evidence gates for `landed`, `cleaned`, `blocked`, `preserved`, and
  `escalated`;
- mandatory separation of selected route, target lifecycle outcome, and actual
  lifecycle outcome;
- destructive cleanup safety classes and denied cleanup classes;
- hosted no-PR landing evidence;
- branch cleanup containment, no-open-PR, rollback/discard, local cleanup, and
  remote cleanup evidence;
- direct-main push, fetch/sync, rollback, validation, and final alignment
  evidence;
- stage-only or escalated outcome limits;
- non-authority boundaries for proposal-local paths, raw inputs, generated
  outputs, host state, GitHub state, chat, model memory, and tool availability.

Update `default-work-unit.yml` and `default-work-unit.md` only enough to point
at the new state machine and bind its evidence gates. Do not redefine route
selection in a competing place, do not weaken the existing route distinctions,
and do not remove the existing route lifecycle requirements.

### 2. Workflow And Skill Integration

Update the closeout workflow contract under
`.octon/framework/orchestration/runtime/workflows/meta/closeout/` so it
references the state-machine contract and distinguishes read-only context
analysis from mutating closeout phases.

Update `closeout-change` so the core workflow follows the state-machine phase
loop:

- read-in and constraints;
- inventory;
- residue classification;
- route and target lifecycle resolution;
- safe cleanup;
- change-set preparation;
- validation;
- hosted no-PR checks and landing when selected;
- PR-backed delegation when selected;
- branch cleanup;
- receipt and evidence;
- final verification;
- final report.

Keep `Closeout Change` singular and route-neutral. Keep `closeout-pr` as the
command id, but update human-facing wording to `Closeout PR-Backed Change`
where that clarifies the delegated subflow. Do not make `closeout-pr`
discoverable as the default route-neutral closeout executor.

Add or update `closeout-worktree` as the optional dirty-worktree wrapper. It
must inventory and classify residue, partition multiple coherent candidate
Changes, select one safely separable candidate at a time, delegate each selected
candidate to `closeout-change` with explicit include/exclude boundaries, retain
or escalate the rest, record wrapper evidence, and refuse a `Closeout Changes`
model.

### 3. Receipt Schema

Extend `.octon/framework/product/contracts/change-receipt-v1.schema.json` with
a structured `stateful_closeout` evidence object containing, at minimum:

- state machine version;
- initial inventory reference;
- residue classification reference;
- selected phase exit references;
- cleanup decision references;
- safe cleanup evidence class for destructive cleanup;
- hosted landing references when applicable;
- branch cleanup references when applicable;
- final verification reference;
- escalation references when applicable.

Add conditional schema rules that require `stateful_closeout` evidence for
completed or cleaned closeout claims. Schema or validator logic must reject:

- `published-branch`, `published`, or `ready` used as completed closeout;
- branch-no-pr receipts containing PR metadata;
- hosted no-PR landing without pushed source branch, provider permission,
  exact source-SHA checks, fast-forward/update proof, `origin/main` equality,
  rollback handle, or final local sync evidence;
- branch cleanup without origin/main containment, no-open-PR status,
  rollback/discard posture, and local/remote cleanup status;
- direct-main closeout without clean-main, validation, push, rollback,
  fetch/sync, or final alignment evidence;
- stage-only or escalated outcomes claiming landed, cleaned, or completed
  state;
- force-push, ambiguous deletion, restoration, reset, or overwrite represented
  as allowed closeout behavior.

Keep schema churn narrow. Avoid introducing broad optional fields that are not
validated by corresponding scripts or tests.

### 4. Validators And Residue Classifier

Extend or supplement
`.octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh`
so completed and cleaned claims fail without state-machine evidence.

Add a focused read-only worktree residue classifier or validator under
`.octon/framework/assurance/runtime/_ops/scripts/`. The classifier must cover:

- staged changes;
- unstaged tracked changes;
- untracked files;
- ignored residue;
- local and remote branches;
- generated/effective outputs;
- host projections;
- retained evidence;
- state/control records;
- release/version files;
- `.octon/inputs/**` surfaces.

The classifier must never authorize deletion by detection alone. Deletion
authority must require explicit evidence-backed safety from the state-machine
contract and selected Change route.

Add or update tests under `.octon/framework/assurance/runtime/_ops/tests/` for
all positive and negative controls. Prefer temporary fixtures created by test
scripts. Do not add durable fixture roots outside the approved target families
unless the packet is revised.

### 5. Boundary And Drift Scans

Run and retain searches proving that durable targets do not depend on the
proposal path or treat generated/raw inputs as authority:

```sh
rg -n "change-closeout-state-machine|inputs/exploratory/proposals" .octon/framework/product/contracts .octon/framework/orchestration/runtime/workflows/meta/closeout .octon/framework/capabilities/runtime/skills/remediation/closeout-change .octon/framework/capabilities/runtime/skills/remediation/closeout-pr .octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml .octon/framework/assurance/runtime/_ops/scripts .octon/framework/assurance/runtime/_ops/tests
rg -n -i "generated.*authority|proposal.*authority|inputs.*authority|github.*authority|host.*authority|tool.*availability.*authority|force-push|reset|restore|overwrite|delete" .octon/framework/product/contracts .octon/framework/orchestration/runtime/workflows/meta/closeout .octon/framework/capabilities/runtime/skills/remediation/closeout-change .octon/framework/capabilities/runtime/skills/remediation/closeout-pr .octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml .octon/framework/assurance/runtime/_ops/scripts .octon/framework/assurance/runtime/_ops/tests
```

The first scan may find the durable contract name in durable targets. It must
not find durable active dependencies on this proposal path. The second scan may
return denied behavior, negative controls, or non-authority boundary text only
when surrounding text or test logic clearly rejects the claim.

### 6. Required Validation

Run these proposal gates:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/change-closeout-state-machine
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/change-closeout-state-machine
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/change-closeout-state-machine
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/change-closeout-state-machine --require-implementation-authorization
```

Run these target-family validators and tests:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-default-work-unit-alignment.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-git-github-workflow-alignment.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-hosted-no-pr-landing.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-input-non-authority.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-raw-input-dependency-ban.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-generated-non-authority.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-no-raw-generated-effective-runtime-reads.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-change-closeout-lifecycle-alignment.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-default-work-unit-alignment.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-git-github-workflow-alignment.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-hosted-no-pr-landing.sh
```

Run the new state-machine or residue-classifier validator and test added by
this implementation. If named differently, record the exact command in
retained evidence:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-state-machine.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-closeout-worktree-wrapper.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-change-closeout-state-machine.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-closeout-worktree-wrapper.sh
```

Run formatting and diff hygiene:

```sh
git diff --check
```

If a required validator fails because an implementation detail makes the
existing validator obsolete, update the validator and tests inside the approved
assurance targets and rerun the full floor. If a validator fails because the
packet's reviewed artifacts must change, stop and route to packet revision
rather than editing reviewed packet artifacts and staling the accepted review.

### 7. Retained Evidence And Implementation Run Receipt

Create a retained evidence note under the evidence directory with:

- implementation timestamp;
- files changed;
- exact validation commands and exit statuses;
- search output or summaries with paths;
- diff summary by promotion target family;
- receipt schema delta;
- fixture and negative-control evidence;
- residue classifier evidence;
- hosted no-PR landing and branch cleanup evidence;
- generated/input non-authority proof;
- explicit exclusions preserved;
- rollback posture;
- remaining blockers or `none`.

Then create or update `support/implementation-run.md` with at least:

```markdown
# Implementation Run Receipt

verdict: pass|fail
implemented_at: <UTC timestamp>
promotion_evidence_count: <number>

## Profile Selection Receipt

release_state: pre-1.0
change_profile: atomic
transitional_exception_note: not authorized

## Durable Changes

...

## Retained Evidence

- <retained evidence path>

## Validators Run

...

## Rollback Posture

...

## Blockers

...
```

Use `verdict: pass` only when durable promotion work has landed in the declared
target families, retained evidence exists outside `inputs/**`, and required
validation passed or has explicitly non-blocking warnings. Otherwise use
`verdict: fail` and report a blocked route outcome.

### 8. Post-Implementation Gate Receipts

After durable changes and `support/implementation-run.md`, create or update
`support/implementation-conformance-review.md` with:

- `verdict: pass|fail`
- `unresolved_items_count`
- sections named `Blockers`, `Checked Evidence`, `Promotion Target Coverage`,
  `Implementation Map Coverage`, `Validator Coverage`, `Generated Output
  Coverage`, `Rollback Coverage`, `Downstream Reference Coverage`,
  `Exclusions`, and `Final Closeout Recommendation`

Then run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/change-closeout-state-machine
```

Create or update `support/post-implementation-drift-churn-review.md` with:

- `verdict: pass|fail`
- `unresolved_items_count`
- sections named `Blockers`, `Checked Evidence`, `Backreference Scan`,
  `Naming Drift`, `Generated Projection Freshness`, `Manifest And Schema
  Validity`, `Repo-Local Projection Boundaries`, `Target Family Boundaries`,
  `Churn Review`, `Validators Run`, `Exclusions`, and
  `Final Closeout Recommendation`

Then run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/change-closeout-state-machine
```

Refuse implemented, closeout, or archive-ready claims while either
post-implementation receipt is missing, failing, unresolved, stale, blocked, or
unvalidated.

## Packet Delivery Orchestration Overlay

Use this section when the operator asks to deliver the standalone
`change-closeout-state-machine` packet using the delivery posture described by
`proposal-program-delivery`. This overlay is not a parent proposal program and
does not create a new delivery authority. It adapts the delivery packet's
cross-lifecycle discipline to one standalone packet:

- bind a delivery profile before work begins;
- execute only target-owned lifecycles;
- validate target-owned receipts instead of summarizing over them;
- replan after material state changes;
- cite evidence in a delivery run receipt without replacing packet, Change,
  cleanup, branch, publication, or terminal-proof receipts.

### Delivery Gate Snapshot

This refresh was prepared after these gates passed for the target packet:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/change-closeout-state-machine --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/change-closeout-state-machine
```

The review gate may emit the existing legacy support-inventory warning; that is
not a delivery blocker while the command exits successfully. Re-run both gates
at execution time and stop if either fails, if the review digest is stale, if
implementation authorization is missing, or if clarification is required.

The source context used for this overlay included these digests:

```text
sha256:00b1a089883e19853a939a6fff5e227c1b0d1567f4553b26cb15b68d56682a22  change-closeout-state-machine/proposal.yml
sha256:13a82562b2215f4b8c0fbbfef0a6e1d57c7b0874f3de09fc86468e7f69d32b8e  change-closeout-state-machine/architecture-proposal.yml
sha256:62a1a1261694f7d0bda7a52283cd9842010fa1d240adcd0a7ff118902b022c85  change-closeout-state-machine/architecture/implementation-plan.md
sha256:911663b7c073d466798ad4b0c8ec017bed6f4814f1297626dfad06de763275ef  change-closeout-state-machine/architecture/acceptance-criteria.md
sha256:9c872b8ef35da20b7551c04e613910b7fe382e0121616b6b83cf17f57a033e04  proposal-program-delivery/proposal.yml
sha256:3a25642ba788cc104fd012dfba33091584d633a5e42b9278a798d94c2de92b5c  proposal-program-delivery/architecture/target-architecture.md
```

Refresh these digests during execution if any referenced source file changed.

### Delivery Profile

Before implementation, record a packet-local delivery profile in
`support/implementation-run.md` or a retained run evidence file. Use at least:

```yaml
schema_version: standalone-packet-delivery-profile-v0
target_packet_path: .octon/inputs/exploratory/proposals/architecture/change-closeout-state-machine
target_outcome: cleaned
route_preference: branch-no-pr
pr_policy: do-not-create-pr-block-if-branch-no-pr-impossible
stash_policy: forbidden
child_execution_mode: none-standalone-packet
required_packet_validators:
  - validate-proposal-review-gate.sh --require-implementation-authorization
  - validate-proposal-implementation-readiness.sh
  - validate-proposal-standard.sh
  - validate-architecture-proposal.sh
required_implementation_validators:
  - validate-change-closeout-lifecycle-alignment.sh
  - validate-proposal-implementation-conformance.sh
  - validate-proposal-post-implementation-drift.sh
required_closeout_validators:
  - closeout-change route selected by current worktree state
  - closeout-worktree only when multiple coherent residue candidates exist
terminal_proof_required: true
final_sync_required: true
generated_publication_policy: validate-or-refresh-through-owning-publishers-only
governed_mechanism_integration_policy: run-if-durable-validator-exists-otherwise-record-not-applicable-rationale
```

Profile binding proves delivery intent and guardrails only. It does not
authorize durable edits, Git mutation, branch landing, branch deletion,
generated publication, proposal status mutation, repo hygiene cleanup, or
archive.

### Delivery Sequence

Run delivery as a state-driven sequence, not a fixed success script:

1. Bind the delivery profile, target packet path, route preference, target
   outcome, and non-authority boundaries.
2. Re-run the proposal review gate and implementation readiness gate.
3. Re-read the target packet manifests, implementation plan, acceptance
   criteria, validation plan, risk register, non-goals, and current durable
   promotion targets.
4. Inspect current durable repository state before editing. If the target
   implementation already appears partially present, classify it as baseline,
   prior implementation evidence, or drift before changing it.
5. Execute the implementation workstreams in this prompt, limited to approved
   promotion targets.
6. Write or refresh `support/implementation-run.md`; cite retained evidence
   outside `inputs/**`.
7. Run the packet-owned implementation conformance validator and write or
   refresh `support/implementation-conformance-review.md`.
8. Run the packet-owned post-implementation drift/churn validator and write or
   refresh `support/post-implementation-drift-churn-review.md`.
9. Validate generated proposal registry and any generated publication
   freshness through the owning publisher or validator. Do not hand-edit
   generated outputs as source truth.
10. If durable governed-mechanism integration verification exists, run it for
    this packet because Change closeout state-machine work changes a governed
    cross-surface mechanism. If it does not exist yet, record a
    `not-applicable-yet` rationale and the validator absence as a delivery
    limitation rather than inventing a receipt.
11. Resolve lifecycle residue only through the proposal lifecycle and
    repo-hygiene cleanup owner. Deletion requires a valid cleanup authorization
    receipt and immediate path revalidation.
12. Hand the coherent Change candidate to `closeout-change`, or to
    `closeout-worktree` first when the worktree contains multiple coherent
    residue groups. The wrapper may partition and delegate; it must not become
    a second closeout authority.
13. For `branch-no-pr`, validate branch landing authorization before any hosted
    mutation. If branch-no-pr is impossible and the profile forbids PR
    fallback, stop with a blocked delivery outcome.
14. Validate branch cleanup authorization before deleting any local or remote
    source ref.
15. Fetch, sync local `main`, and prove local `main`, `origin/main`, and the
    landed ref are equal when landing occurred.
16. Emit terminal current-state proof after the final mutation.
17. Validate final worktree hygiene before claiming `cleaned`.

At every step, missing, stale, ambiguous, or overclaiming receipt evidence
blocks delivery or lowers the outcome. Do not use a packet summary, generated
prompt, chat transcript, host state, GitHub dashboard, tool availability, or
model memory as a substitute for a target-owned receipt.

### Target-Owned Receipt Requirements

For delivery to claim `implemented`, the packet must have fresh passing target
receipts:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- validation evidence for the closeout state-machine contract, Change receipt
  schema, closeout workflow, closeout skills, residue classifier, hosted no-PR
  landing, branch cleanup, direct-main final sync, and negative controls
- retained evidence outside `inputs/**` for every material validator or
  lifecycle run cited by the implementation

For delivery to claim `cleaned`, add target-owned closeout and terminal proof:

- a Change receipt or closeout evidence selected by the default work-unit
  policy;
- branch-no-PR landing authorization evidence when that route is used;
- branch cleanup authorization evidence before source ref deletion;
- repo-hygiene cleanup authorization before deleting eligible residue;
- terminal current-state proof after the final mutation;
- final local `main == origin/main == landed_ref` proof when applicable;
- final worktree hygiene evidence.

The delivery run may aggregate these facts, but it cannot satisfy them.

### Delivery Run Receipt

After execution, write a packet-local delivery run receipt only as operational
evidence, not authority. Use
`support/implementation-run.md` when the run is an implementation run; if a
separate delivery note is needed, place it under an excluded conventional
support route only after confirming validator digest rules.

The delivery receipt content must include at least:

```yaml
delivery_verdict: pass|blocked|lowered-outcome|fail
delivered_at: <UTC timestamp>
target_packet_path: .octon/inputs/exploratory/proposals/architecture/change-closeout-state-machine
target_outcome_requested: cleaned
target_outcome_actual: implemented|cleaned|blocked|preserved|escalated
route_preference: branch-no-pr
pr_policy: do-not-create-pr-block-if-branch-no-pr-impossible
child_authority_preserved: yes
target_owned_receipts_validated: yes|no
implementation_conformance_passed: yes|no
post_implementation_drift_churn_passed: yes|no
generated_publication_fresh: yes|no|not-applicable
governed_mechanism_integration: pass|blocked|not-applicable-yet
change_closeout_receipt_ref: <path-or-none>
branch_landing_authorization_ref: <path-or-none>
branch_cleanup_authorization_ref: <path-or-none>
repo_hygiene_cleanup_authorization_ref: <path-or-none>
terminal_current_state_proof_ref: <path-or-none>
final_sync_proof_ref: <path-or-none>
final_worktree_hygiene_ref: <path-or-none>
blockers:
  - <blocker-or-none>
```

Use `delivery_verdict: pass` only when target-owned receipts, closeout evidence,
terminal proof, final sync, and worktree hygiene support the actual outcome.
Use `lowered-outcome` when implementation is valid but `cleaned` cannot be
proved. Use `blocked` when a required target-owned lifecycle cannot proceed.

### Delivery Hard Gates

The delivery orchestrator must hard-gate on all of these:

- proposal review authorization and implementation readiness are fresh;
- implementation conformance passes;
- post-implementation drift/churn passes;
- generated proposal registry and relevant generated projections are fresh or
  explicitly not applicable;
- governed mechanism integration verification passes when the durable verifier
  exists and applies;
- lifecycle residue is resolved or explicitly blocked;
- branch-no-PR authorization validates before hosted mutation;
- branch cleanup authorization validates before branch deletion;
- repo-hygiene cleanup authorization validates before deletion;
- terminal current-state proof exists after the final mutation;
- local `main` is synced to `origin/main`;
- the worktree is clean before claiming `cleaned`;
- no generated output, proposal-local file, generated prompt, host state,
  dashboard, chat, model memory, or tool availability is treated as authority.

### Delivery Stop Conditions

Stop and record a blocker instead of continuing when:

- a needed edit falls outside the approved promotion targets;
- the implementation would require a new route, new authority class, PR
  fallback despite no-PR policy, host projection regeneration, generated
  effective publication, extension activation, branch deletion, force-push,
  ambiguous cleanup, or proposal status mutation;
- any validator fails without a narrow non-blocking rationale;
- conformance or drift/churn receipts are missing, stale, failing, or
  unresolved;
- terminal proof or final worktree hygiene cannot be produced for a `cleaned`
  claim;
- prior implementation evidence conflicts with current durable state and cannot
  be reconciled without packet revision.

The correct response to these conditions is a blocked or lowered delivery
outcome, not a broader implementation.

## Rollback Posture

Rollback is removal or reversion of the state-machine contract, default
work-unit references, Change receipt schema changes, workflow/skill changes,
git/worktree autonomy changes, validators, tests, and retained evidence notes
made by this packet.

Before claiming success, verify that rollback would restore the prior
Change-first closeout posture without leaving:

- a competing closeout route authority;
- partial state-machine schema without validators;
- validators without corresponding contract surfaces;
- stale receipt fields that make completed or cleaned claims unverifiable;
- workflow stages that point at missing contracts;
- closeout skills that mention deleted or unregistered phases;
- generated or input surfaces used as authority;
- proposal-path dependencies in durable targets;
- unsafe cleanup or force-push allowances.

If rollback cannot be cleanly bounded to this packet's durable targets, stop
and report `blocked-unsafe` or `needs-packet-revision`.

## Delegation

Delegation is optional. If used, split work by disjoint write scope and keep
one integration owner accountable for final validation and receipts.

Suggested disjoint scopes:

- product contracts and default work-unit references;
- receipt schema and schema-oriented fixtures;
- closeout workflow and closeout skills;
- git/worktree autonomy and residue classifier;
- validators and tests;
- integration owner for retained evidence, receipts, final validation, and
  status discipline.

No subagent, worker, script, or delegated tool may widen promotion targets,
approve execution, mutate `proposal.yml#status`, create a PR without a
selected `branch-pr` route, delete ambiguous work, publish generated/effective
state, regenerate host projections, or treat proposal-local files as
implementation proof.

## Terminal Criteria

The implementation route may report success only when all of these are true:

- durable changes are limited to the approved promotion targets;
- required retained evidence exists outside `inputs/**`;
- `change-closeout-state-machine-v1` exists as durable product contract YAML
  and Markdown;
- the default work-unit policy references the state machine without weakening
  route distinctions;
- `Closeout Change` remains the singular route-neutral executor;
- `Closeout PR-Backed Change` remains delegated only after `branch-pr`
  selection;
- Change receipts can record state-machine inventory, classification, cleanup,
  phase-exit, final verification, and escalation evidence;
- validators fail completed or cleaned claims that lack required
  state-machine evidence;
- validators fail destructive cleanup without evidence-backed safety;
- validators fail `published-branch`, `published`, or `ready` overclaims;
- validators fail force-push and ambiguous deletion, reset, restoration, or
  overwrite claims;
- hosted no-PR landing, direct-main final sync, branch cleanup, and stage-only
  negative controls are covered;
- `.octon/inputs/**`, proposal-local files, generated outputs, host state,
  GitHub state, chat, model memory, and tool availability remain
  non-authoritative;
- `support/implementation-run.md` exists with `verdict: pass`,
  `implemented_at`, and `promotion_evidence_count`;
- `support/implementation-conformance-review.md` exists with `verdict: pass`
  and `unresolved_items_count: 0`;
- `validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/change-closeout-state-machine`
  passes;
- `support/post-implementation-drift-churn-review.md` exists with
  `verdict: pass` and `unresolved_items_count: 0`;
- `validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/change-closeout-state-machine`
  passes;
- `git diff --check` passes;
- no explicit exclusion has been implemented or implied as live support;
- `proposal.yml#status` remains `accepted`.

The next canonical lifecycle route after this prompt is
`run-packet-implementation`.
