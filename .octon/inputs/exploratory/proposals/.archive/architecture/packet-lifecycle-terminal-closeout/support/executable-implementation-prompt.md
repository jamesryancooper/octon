# Executable Implementation Prompt

implementation_prompt_id: packet-lifecycle-terminal-closeout-implementation-prompt-20260612T221323Z
proposal_path: .octon/inputs/exploratory/proposals/architecture/packet-lifecycle-terminal-closeout
route_id: run-packet-implementation
status: operational-aid
generated_at: 2026-06-12T22:13:23Z

This prompt is an operational implementation aid for the accepted proposal
packet. It does not approve execution by itself, authorize promotion, authorize
archive movement, replace proposal manifests, create Git/GitHub authority, or
substitute for retained implementation evidence.

Durable authority may land only in approved promotion targets outside the
proposal path. Proposal-local files, support receipts, generated proposal
registry entries, raw inputs, generated projections, generated prompts, host
state, provider metadata, dashboards, chat history, model memory, ignored
files, and tool availability are implementation input or derived context only.
They are not runtime, policy, cleanup, control, retained-evidence,
publication, closeout, terminalization, or archive authority.

## Prompt Generation Gate Receipt

This prompt was generated only after the accepted review, strict
pre-integration architecture review, and implementation-readiness gates passed:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/packet-lifecycle-terminal-closeout
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/packet-lifecycle-terminal-closeout --require-implementation-authorization
```

Observed result at prompt-generation time: `errors=0 warnings=0`.
Reviewed packet digest: `sha256:76f734f10d4d01c0453d839e8c8d3c9e7f8b42baaa2b02293e45b6ebad3e7aa5`.

## Profile Selection Receipt

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- atomic posture: implement one coherent packet terminalization change across
  workflow, profile schema, receipt schema, validators, tests, evaluator
  guidance, product feature documentation, command, skill, proposal lifecycle
  hooks, and generated publication refreshes
- transitional exception: not authorized by this prompt

## Mandatory Preflight

Before editing durable targets, re-read:

- `AGENTS.md`;
- `.octon/instance/ingress/AGENTS.md`;
- mandatory constitutional/kernel files listed by ingress;
- `.octon/framework/execution-roles/runtime/orchestrator/ROLE.md`;
- this proposal packet's `proposal.yml`, `architecture-proposal.yml`,
  `navigation/source-of-truth-map.md`, `navigation/artifact-catalog.md`,
  `architecture/target-architecture.md`, `architecture/implementation-plan.md`,
  `architecture/acceptance-criteria.md`,
  `support/implementation-grade-completeness-review.md`,
  `support/proposal-review.md`,
  `support/pre-integration-architecture-review.yml`, and this prompt;
- `.codex/skills/octon-proposal-lifecycle-run-packet-implementation/SKILL.md`;
- `.codex/skills/octon-proposal-lifecycle-closeout-packet/SKILL.md`;
- `.codex/skills/octon-proposal-lifecycle-closeout-program/SKILL.md`;
- `.octon/framework/product/contracts/default-work-unit.yml`;
- `.octon/framework/product/contracts/change-closeout-state-machine.yml`;
- `.octon/framework/execution-roles/practices/standards/git-worktree-autonomy-contract.yml`;
- `.octon/framework/orchestration/runtime/workflows/meta/archive-proposal/workflow.yml`;
- `.octon/framework/orchestration/runtime/workflows/audit/post-integration-architecture-review/workflow.yml`;
- `.octon/framework/orchestration/runtime/workflows/meta/lifecycle-postmortem/workflow.yml`;
- `.octon/framework/assurance/evaluators/lifecycle-postmortem/README.md`;
- current workflow registry and manifest files;
- current product feature catalog and README files;
- current command and skill manifests, registries, and capability catalog;
- current proposal lifecycle extension source under
  `.octon/inputs/additive/extensions/octon-proposal-lifecycle/`;
- existing proposal standard, architecture, review gate, implementation
  conformance, post-implementation drift, publication freshness,
  generated/input non-authority, run-health, capability publication, extension
  publication, closeout, and Git/GitHub validators that are adjacent to this
  change.

Then run these gates from the repository root:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/packet-lifecycle-terminal-closeout --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/packet-lifecycle-terminal-closeout
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/packet-lifecycle-terminal-closeout --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/packet-lifecycle-terminal-closeout
```

Refuse implementation unless all commands pass, `proposal.yml#status` is
`accepted`, the review verdict is `accepted`,
`implementation_prompt_authorized: yes`, `open_blocking_findings_count: 0`, the
strict pre-integration architecture review receipt has `verdict: pass`, and
the reviewed packet digest is fresh.

## Current Repository Baseline

The live repository already contains:

- proposal packet closeout, proposal program closeout, and packet
  implementation lifecycle skills;
- implementation conformance and post-implementation drift/churn validators;
- proposal review gate validation with strict pre-integration architecture
  review support receipts;
- closeout-worktree and closeout-change contracts that own dirty worktree
  decomposition, route selection, hosted exact-SHA checks, branch landing,
  branch cleanup, rollback posture, final sync, and stateful closeout;
- archive-proposal workflow that owns archive relocation, archive metadata,
  and proposal registry regeneration after readiness is proven;
- post-integration architecture review and lifecycle-postmortem workflows that
  are read-only/evidence-only;
- workflow registries, product feature catalogs, command manifests, skill
  manifests, skill registries, and capability catalogs that must be updated
  when durable surfaces are added.

The live repository does not yet contain these core new targets:

- `.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-terminal-closeout/`;
- `.octon/framework/product/contracts/proposal-packet-terminal-closeout-profile-v1.schema.json`;
- `.octon/framework/product/contracts/proposal-packet-terminal-closeout-receipt-v1.schema.json`;
- `.octon/framework/product/features/proposal-packet-terminal-closeout.md`;
- `.octon/framework/capabilities/runtime/commands/proposal-packet-terminal-closeout.md`;
- `.octon/framework/capabilities/runtime/skills/operations/proposal-packet-terminal-closeout/SKILL.md`;
- `.octon/framework/assurance/evaluators/proposal-packet-terminal-closeout/README.md`;
- `.octon/framework/assurance/evaluators/templates/proposal-packet-terminal-closeout-template.md`;
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-terminal-closeout-profile.sh`;
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-terminal-closeout-receipt.sh`;
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-terminal-closeout-workflow.sh`;
- `.octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-packet-terminal-closeout.sh`.

Creating those surfaces and updating the existing registries, manifests,
feature catalogs, command catalogs, skill catalogs, capability catalogs, and
proposal lifecycle extension source is part of this implementation.

## Target End State

Implemented proposal packets have a canonical
`proposal-packet-terminal-closeout` workflow that verifies implementation
state, post-implementation gates, publication freshness, non-authority
boundaries, run health, capability and extension publication, repo hygiene,
worktree hygiene, evidence-only review hooks, and Git/GitHub route evidence,
then emits a packet-local aggregate terminal receipt with either
`archive-ready` or `blocked`.

The terminal workflow may sequence, validate, delegate, cite, aggregate, and
authorize an archive-ready verdict. It must not:

- archive or relocate a packet;
- publish generated outputs directly;
- edit generated outputs as source truth;
- delete local residue;
- stage, commit, push, land, merge, reset, restore, or delete branches;
- replace Change receipts, implementation conformance receipts,
  post-implementation drift/churn receipts, publisher receipts, repo-hygiene
  receipts, Git/GitHub receipts, architecture review receipts,
  lifecycle-postmortem outputs, or archive-proposal evidence;
- make proposal inputs, generated outputs, host state, dashboards, chat state,
  tool availability, or model memory authoritative.

Archive relocation remains owned by `archive-proposal`. Git/GitHub mutation and
branch cleanup remain owned by closeout routes and Git/GitHub contracts.
Publication freshness repair remains owned by canonical publishers. Evidence
only reviews remain evidence-only.

## Challenge Constraints

Carry these constraints from the pre-implementation challenge memo into the
implementation:

- The terminal receipt schema must include a per-state ledger, not only
  aggregate refs. Each state entry must record `state_id`, input refs,
  validator command refs, output evidence refs, state verdict, retry count, and
  resume cursor or re-entry condition.
- The workflow must delegate Git/GitHub mutation and hosted check triggering to
  closeout-owned routes or helpers, then validate returned evidence. Do not
  implement direct Git/GitHub mutation inside packet terminal closeout.
- The profile or workflow contract must contain a target-family-to-validator
  map so validator selection is deterministic rather than ad hoc.
- The atomic implementation may use internal checkpoints, but do not claim
  implementation complete until workflow, schemas, validators, tests,
  evaluator guidance, feature docs, command, skill, lifecycle hooks, and
  publication refreshes all validate together.

## In Scope

Durable edits may touch only these approved promotion targets:

- `.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-terminal-closeout/`
- `.octon/framework/orchestration/runtime/workflows/registry.yml`
- `.octon/framework/orchestration/runtime/workflows/manifest.yml`
- `.octon/framework/product/contracts/proposal-packet-terminal-closeout-profile-v1.schema.json`
- `.octon/framework/product/contracts/proposal-packet-terminal-closeout-receipt-v1.schema.json`
- `.octon/framework/product/features/proposal-packet-terminal-closeout.md`
- `.octon/framework/product/features/catalog.yml`
- `.octon/framework/product/features/README.md`
- `.octon/framework/capabilities/runtime/commands/proposal-packet-terminal-closeout.md`
- `.octon/framework/capabilities/runtime/commands/manifest.yml`
- `.octon/framework/capabilities/runtime/skills/operations/proposal-packet-terminal-closeout/SKILL.md`
- `.octon/framework/capabilities/runtime/skills/manifest.yml`
- `.octon/framework/capabilities/runtime/skills/registry.yml`
- `.octon/framework/capabilities/runtime/skills/capabilities.yml`
- `.octon/framework/assurance/evaluators/proposal-packet-terminal-closeout/README.md`
- `.octon/framework/assurance/evaluators/templates/proposal-packet-terminal-closeout-template.md`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-terminal-closeout-profile.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-terminal-closeout-receipt.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-terminal-closeout-workflow.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-packet-terminal-closeout.sh`
- `.octon/inputs/additive/extensions/octon-proposal-lifecycle/`

Packet-local implementation evidence may touch:

- `.octon/inputs/exploratory/proposals/architecture/packet-lifecycle-terminal-closeout/support/implementation-run.md`
- `.octon/inputs/exploratory/proposals/architecture/packet-lifecycle-terminal-closeout/support/implementation-conformance-review.md`
- `.octon/inputs/exploratory/proposals/architecture/packet-lifecycle-terminal-closeout/support/post-implementation-drift-churn-review.md`
- `.octon/inputs/exploratory/proposals/architecture/packet-lifecycle-terminal-closeout/support/validation.md`
- `.octon/inputs/exploratory/proposals/architecture/packet-lifecycle-terminal-closeout/support/SHA256SUMS.txt`, only if this packet starts maintaining checksums

Retained validation evidence should live outside `inputs/**`, preferably under:

- `.octon/state/evidence/validation/proposals/packet-lifecycle-terminal-closeout/<timestamp>/`
- `.octon/state/evidence/runs/workflows/<run-id>/` when a workflow run is
  exercised
- `.octon/state/evidence/runs/skills/proposal-packet-terminal-closeout/<run-id>/`
  when the new skill records run evidence

## Out Of Scope

Do not edit these surfaces for this packet unless a packet revision or linked
proposal explicitly widens scope:

- `.github/**`;
- root adapters and root docs;
- `.octon/instance/**`;
- `.octon/state/control/**`;
- `.octon/generated/**`, except through owning canonical publishers when
  generated projection refresh is required by implementation validation;
- `.octon/inputs/**` outside this proposal packet's support receipts and the
  proposal lifecycle extension source explicitly listed as a promotion target;
- host projections, provider settings, branch protection settings, connector
  admissions, or external workflow dashboards.

Do not change `proposal.yml#status`. Leave it as `accepted`. The
`run-packet-implementation` route writes implementation evidence that enables
the separate `promote-proposal` lifecycle route to rewrite status to
`implemented`.

If implementation requires a target-family widening, a new authority class,
generated/effective publication outside canonical publishers, direct archive
movement, direct Git/GitHub mutation from terminal closeout, destructive
cleanup of current residue, branch deletion, PR creation, or generated output
authority, stop and report `needs-packet-revision` with evidence.

## Ordered Workstreams

### 0. Preflight And Evidence Directory

1. Record current branch, current HEAD, and scoped worktree state. Preserve
   unrelated existing edits.
2. Run the mandatory preflight validators above.
3. Create a timestamped retained evidence directory under
   `.octon/state/evidence/validation/proposals/packet-lifecycle-terminal-closeout/`.
4. Record command outputs or concise receipts for preflight, implementation,
   and final validation.

### 1. Product Contracts

Add
`.octon/framework/product/contracts/proposal-packet-terminal-closeout-profile-v1.schema.json`.
The profile schema must validate:

- packet path and proposal id;
- target outcome, at minimum `archive-ready` and `blocked`;
- route preference and PR policy;
- publication freshness policy;
- hygiene policy;
- expected retained evidence set;
- required validators by target family;
- post-integration architecture review policy;
- packet terminal evaluator or lifecycle-postmortem policy;
- Git/GitHub hosted check policy;
- blocker class and next-route reporting requirements;
- forbidden authority requests.

Add
`.octon/framework/product/contracts/proposal-packet-terminal-closeout-receipt-v1.schema.json`.
The receipt schema must validate:

- schema version and terminal run id;
- packet id, packet path, proposal kind, and packet status;
- target outcome and actual verdict;
- profile digest and profile validation evidence;
- per-state ledger entries for every workflow state;
- durable implementation state evidence refs;
- implementation conformance receipt and validator refs;
- post-implementation drift/churn receipt and validator refs;
- publication freshness validators, publisher refresh receipts, and rerun refs;
- generated/input non-authority validation refs;
- run-health and capability or extension publication validation refs;
- repo-hygiene classification and cleanup authorization refs when applicable;
- worktree hygiene classification refs;
- post-integration architecture review support receipt refs;
- packet terminal evaluator or lifecycle-postmortem refs when applicable;
- Git/GitHub route refs, exact-SHA check refs, landing authorization refs, and
  branch cleanup authorization refs when applicable;
- final `archive-ready` or `blocked` verdict;
- blocked result fields: blocker class, blocker detail, failing evidence ref,
  and next canonical route;
- retained evidence inventory;
- expected-no-new-evidence-loop declaration;
- explicit non-authority declarations for proposal inputs, generated outputs,
  generated prompts, host state, dashboards, chat, tool state, and model
  memory.

The aggregate receipt must cite target-owned evidence. It must not satisfy or
replace target-owned receipts.

### 2. Workflow

Add
`.octon/framework/orchestration/runtime/workflows/meta/proposal-packet-terminal-closeout/`
with a workflow contract and stage assets for:

1. `bind-profile`
2. `verify-durable-implementation-state`
3. `verify-implementation-conformance`
4. `verify-post-implementation-drift`
5. `validate-publication-freshness`
6. `classify-repo-hygiene`
7. `classify-worktree-hygiene`
8. `run-evidence-only-reviews`
9. `resolve-git-github-route`
10. `emit-terminal-receipt`

Each stage must declare consumed evidence, produced evidence, side-effect
class, re-entry condition, stop condition, and receipt fields it contributes.

Workflow constraints:

- read-only validators may run directly;
- canonical publishers may be invoked only when a freshness validator fails
  and the owning publisher is known;
- after publisher refresh, rerun the failed freshness validator and adjacent
  projection validators;
- repo-hygiene cleanup may only be delegated to authorized repo-hygiene cleanup
  routes;
- worktree closeout residue may only be delegated to closeout-worktree or
  closeout-change;
- Git/GitHub hosted check triggering, hosted landing, branch cleanup, and final
  sync may only be delegated to existing closeout/GitHub routes;
- post-integration architecture review and lifecycle-postmortem outputs remain
  evidence-only;
- archive movement is never performed by this workflow.

Register the workflow in the workflow manifest and registry.

### 3. Validators And Tests

Add validators:

- `validate-proposal-packet-terminal-closeout-profile.sh`
- `validate-proposal-packet-terminal-closeout-receipt.sh`
- `validate-proposal-packet-terminal-closeout-workflow.sh`

Add tests:

- `test-validate-proposal-packet-terminal-closeout.sh`

Required positive coverage:

- valid profile passes;
- valid `archive-ready` receipt passes;
- valid `blocked` receipt with exact blocker and next route passes;
- workflow contract shape passes;
- receipt cites target-owned evidence without replacing it.

Required negative controls:

- missing implementation conformance receipt fails;
- stale implementation conformance receipt fails;
- missing post-implementation drift/churn receipt fails;
- stale publication freshness evidence fails;
- direct generated output edit used as freshness repair fails;
- missing generated/input non-authority validation fails;
- missing run-health validation fails;
- missing capability or extension publication validation fails;
- repo-hygiene deletion without authorization fails;
- worktree hygiene blocked by foreign residue fails archive-ready;
- post-integration architecture review output used as closeout authority fails;
- lifecycle-postmortem output used as archive authority fails;
- branch-no-pr hosted landing without exact-SHA checks fails;
- branch-no-pr hosted landing without landing authorization fails;
- branch cleanup without cleanup authorization fails;
- terminal receipt overclaims archive-ready while residue remains;
- terminal receipt attempts archive relocation.

### 4. Evaluator Hook

Add packet terminal evaluator guidance and template:

- `.octon/framework/assurance/evaluators/proposal-packet-terminal-closeout/README.md`
- `.octon/framework/assurance/evaluators/templates/proposal-packet-terminal-closeout-template.md`

The evaluator consumes terminal run evidence and emits structured lifecycle
improvement findings. It is required for blocked, nonterminal, cancelled,
rollback, or repeated-retry terminal runs and optional for clean
archive-ready runs.

The evaluator output is retained evidence only. It cannot authorize terminal
verdicts, archive relocation, publication refresh, cleanup, branch mutation,
promotion, or closeout.

### 5. Capability And Lifecycle Entry Points

Add a thin command:

- `.octon/framework/capabilities/runtime/commands/proposal-packet-terminal-closeout.md`

Add a thin skill:

- `.octon/framework/capabilities/runtime/skills/operations/proposal-packet-terminal-closeout/SKILL.md`

Update command and skill manifests, registries, and capability catalogs.

The command/skill must normalize operator arguments into a workflow profile and
invoke the workflow. The entrypoints do not mint independent authority.

Update `.octon/inputs/additive/extensions/octon-proposal-lifecycle/` so packet
terminal closeout is exposed as a post-implementation packet lifecycle route.
Preserve proposal input non-authority and generated projection derived-only
status.

### 6. Product Feature Documentation

Add product feature documentation at:

- `.octon/framework/product/features/proposal-packet-terminal-closeout.md`

Update:

- `.octon/framework/product/features/catalog.yml`
- `.octon/framework/product/features/README.md`

The feature documentation must explain:

- when packet terminal closeout runs;
- how it differs from closeout-packet, closeout-change, closeout-worktree,
  archive-proposal, lifecycle-postmortem, and post-integration architecture
  review;
- what evidence it retains;
- how publication freshness repair works;
- how hygiene loops terminate;
- how Git/GitHub exact-SHA checks are delegated or reported as blockers;
- how archive-ready differs from archive relocation.

### 7. Publication Refresh

Refresh generated projections only through canonical publishers. Do not edit
generated outputs directly.

At minimum, identify whether these publication families require refresh:

- workflow manifest/registry projections;
- command and skill publication projections;
- capability publication projections;
- proposal lifecycle extension generated/effective projections;
- product feature catalogs;
- proposal registry projection if proposal-local support receipts changed.

If a publication freshness validator fails, invoke only the owning canonical
publisher, then rerun the failed validator and adjacent projection validators.

### 8. Packet Support Receipts

After durable implementation, update packet-local support material:

- `support/implementation-run.md` with implementation summary, changed target
  map, validation commands, generated publication refreshes, evidence refs,
  rollback posture, and explicit non-authority declarations;
- `support/implementation-conformance-review.md` with a current conformance
  verdict, zero unresolved items when complete, and promotion target coverage;
- `support/post-implementation-drift-churn-review.md` with current drift/churn
  verdict, zero unresolved items when complete, and residual-risk notes;
- `support/validation.md` with final validation run log.

Do not claim implementation complete unless both post-implementation receipts
are current and pass their validators.

## Required Validation

Run the packet's declared validation plus implementation-specific validators.
The minimum validation floor is:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/packet-lifecycle-terminal-closeout
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/packet-lifecycle-terminal-closeout
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/packet-lifecycle-terminal-closeout --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/packet-lifecycle-terminal-closeout
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-terminal-closeout-profile.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-terminal-closeout-receipt.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-packet-terminal-closeout-workflow.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-packet-terminal-closeout.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/packet-lifecycle-terminal-closeout
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/packet-lifecycle-terminal-closeout
```

Also run adjacent validators required by the surfaces actually touched,
including workflow registry/manifest, product feature catalog, command
manifest, skill manifest, skill registry, capability catalog, proposal
lifecycle extension publication, generated/input non-authority, run-health,
capability publication, extension publication, closeout-worktree alignment,
default-work-unit alignment, change-closeout state-machine alignment,
Git/GitHub exact-SHA route validation, hosted-no-PR validation, lifecycle
postmortem validation, post-integration architecture review support receipt
validation, and `git diff --check`.

When validators reveal publication freshness drift, refresh only through the
owning canonical publisher, then rerun the failed validator and adjacent
projection validators.

## Evidence Requirements

Retain or cite evidence for:

- preflight validator results;
- schema validator results and tests;
- workflow validator results;
- command, skill, feature, manifest, registry, and catalog validation;
- generated publication refresh commands and receipts;
- implementation conformance review and validator output;
- post-implementation drift/churn review and validator output;
- generated/input non-authority validation;
- run-health and capability/extension publication validation;
- Git/GitHub route validator results;
- closeout-worktree/default-work-unit/change-closeout alignment validators;
- post-integration architecture review evidence-only boundary validation;
- lifecycle-postmortem or packet terminal evaluator evidence-only boundary
  validation;
- final scoped worktree status and `git diff --check`.

## Rollback Posture

Rollback is atomic. Remove the workflow, profile schema, receipt schema,
validators, tests, evaluator guidance, product feature documentation, command,
skill, lifecycle hook updates, and generated publication outputs introduced by
this implementation. Restore updated registries, manifests, catalogs, and
publication projections to their prior state through normal version-control
rollback or canonical publishers as applicable.

Retain emitted validation and implementation evidence under `state/evidence`
for auditability. Do not delete retained evidence unless a separate retention
or repo-hygiene route authorizes it.

## Terminal Criteria

The implementation route may report success only when:

- all approved durable targets are implemented or have explicit
  not-applicable rationale;
- no out-of-scope target was changed without packet revision;
- generated outputs were refreshed only through canonical publishers;
- packet support receipts are current;
- implementation conformance validation passes;
- post-implementation drift/churn validation passes;
- all required validators pass or every failure is recorded as a blocker with
  next canonical route;
- proposal inputs and generated outputs remain non-authority;
- archive movement has not occurred;
- `proposal.yml#status` remains `accepted`.

After successful implementation, route to `promote-proposal`. Do not claim
archive readiness until promotion, terminal closeout, post-implementation gates,
worktree hygiene, publication freshness, and archive-proposal readiness are
separately validated by their owning routes.
