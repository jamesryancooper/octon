# Executable Implementation Prompt

implementation_prompt_id: repo-hygiene-cleanup-authorization-receipts-implementation-prompt-2026-05-21
proposal_path: .octon/inputs/exploratory/proposals/architecture/repo-hygiene-cleanup-authorization-receipts
route_id: run-packet-implementation
status: operational-aid
generated_at: 2026-05-21T23:05:32Z
refreshed_at: 2026-06-13T00:17:41Z
terminal_closeout_guidance_ref: .octon/inputs/exploratory/proposals/architecture/packet-lifecycle-terminal-closeout
delivery_prompt_mode: standalone-packet-implementation-and-terminal-closeout-orchestration

This prompt is an operational implementation aid for the accepted proposal
packet. It does not approve execution, authorize deletion, widen scope, create
cleanup authority, replace proposal manifests, or substitute for retained
evidence.

Durable authority may land only in approved promotion targets outside the
proposal path. Proposal-local files, support receipts, generated proposal
registry entries, raw inputs, generated projections, host state, provider
metadata, chat history, model memory, ignored files, and tool availability are
implementation input or derived context only. They are not runtime, policy,
cleanup, control, retained-evidence, publication, or closeout authority.

## Prompt Generation Gate Receipt

The prompt was generated only after the accepted review and implementation
readiness gates passed:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/repo-hygiene-cleanup-authorization-receipts --require-implementation-authorization --print-digest
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/repo-hygiene-cleanup-authorization-receipts
```

Observed result at prompt-generation time: `errors=0 warnings=0`; reviewed
packet digest `sha256:26d6686299f3327e5bd1cb8df36b9f6060660671df11eae888532d054235ea45`.

## Profile Selection Receipt

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- atomic posture: implement one coherent repo-hygiene cleanup authorization
  change across the receipt schema, helper, validators, tests, docs, closeout
  boundary text, and narrow remediation skill
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
- live repo-hygiene policy, local-run cleanup helper and tests,
  repo-hygiene governance validator, repo-hygiene command README, branch
  cleanup authorization schema, run-health generator and validator, closeout
  worktree skill and validator, closeout-change skill, skill manifest,
  registry, and capabilities group files.

Then run these gates from the repository root:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/repo-hygiene-cleanup-authorization-receipts --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/repo-hygiene-cleanup-authorization-receipts
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/repo-hygiene-cleanup-authorization-receipts --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/repo-hygiene-cleanup-authorization-receipts
```

Refuse implementation unless all commands pass, `proposal.yml#status` is
`accepted`, the review verdict is `accepted`,
`implementation_prompt_authorized: yes`, `open_blocking_findings_count: 0`, and
the reviewed packet digest is fresh.

## Current Repository Baseline

The live repository already contains:

- `.octon/instance/governance/policies/repo-hygiene.yml` with local artifact
  hygiene policy that defaults cleanup to dry-run and requires explicit
  `--confirm` for deletion;
- `.octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh`
  with dry-run, `--summary-only`, `--fail-on-manual`, and manual `--confirm`
  cleanup behavior;
- `.octon/framework/assurance/runtime/_ops/tests/test-cleanup-local-run-artifacts.sh`
  covering the current helper posture;
- `.octon/framework/assurance/runtime/_ops/scripts/validate-repo-hygiene-governance.sh`
  validating repo-hygiene policy, docs, helper, and command references;
- `.octon/instance/capabilities/runtime/commands/repo-hygiene/README.md` as
  the existing operator-facing repo-hygiene command documentation;
- branch cleanup authorization precedent in
  `.octon/framework/product/contracts/branch-cleanup-authorization-v1.schema.json`;
- generated run-health pruning in
  `.octon/framework/assurance/runtime/_ops/scripts/generate-run-health-read-model.sh`
  with `pruned_paths` recorded by the generator;
- `closeout-worktree` as a non-mutating wrapper and `closeout-change` as the
  singular Change closeout skill.

The durable cleanup authorization schema and the narrow `repo-hygiene-cleanup`
remediation skill do not exist yet. Creating them is part of this
implementation.

## Target End State

The implemented end state is a retained, machine-checkable
`repo-hygiene-cleanup-authorization-v1` receipt plus hardened helper behavior.
Agents may delete eligible post-closeout residue without repeated ad hoc
Octon-level confirmation only when repo hygiene emits a validating receipt and
the cleanup helper immediately revalidates the exact path set before deletion.

The implementation must establish all of these facts:

- detection alone never authorizes deletion;
- dry-run remains the default and manual `--confirm` remains available as a
  fallback;
- receipt-backed cleanup is an alternative to manual `--confirm` only for
  exact, current, revalidated cleanup candidates;
- every authorized path is untracked, unreferenced by tracked files,
  non-authoritative, inside an allowed cleanup pattern, not an input surface,
  not durable evidence, not active control state, not generated authority, and
  not ignored or user-owned residue;
- tracked, referenced, protected, manual-review, ignored, input-surface,
  active-control, durable-evidence, generated-authority, and generated
  run-health candidates fail closed;
- generated run-health pruning remains generator-owned through
  `generate-run-health-read-model.sh --all-runs` and `pruned_paths`;
- `Closeout Worktree` inventories, classifies, routes, and reports repo
  hygiene residue only; it must not delete residue or become cleanup authority;
- `Closeout Change` cleaned outcomes remain selected-route-bound and cannot
  imply global worktree hygiene;
- runtime/platform approvals remain outside the receipt boundary and can still
  block deletion.

This packet does not authorize current worktree cleanup, generated run-health
pruning, branch cleanup, archive mutation, staging, committing, pushing, or
status promotion by itself.

## In Scope

Durable edits may touch only these approved promotion target families:

- `.octon/instance/governance/policies/repo-hygiene.yml`
- `.octon/framework/product/contracts/repo-hygiene-cleanup-authorization-v1.schema.json`
- `.octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh`
- `.octon/framework/assurance/runtime/_ops/tests/test-cleanup-local-run-artifacts.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-repo-hygiene-governance.sh`
- `.octon/instance/capabilities/runtime/commands/repo-hygiene/README.md`
- `.octon/framework/capabilities/runtime/skills/remediation/repo-hygiene-cleanup/SKILL.md`
- `.octon/framework/capabilities/runtime/skills/manifest.yml`
- `.octon/framework/capabilities/runtime/skills/registry.yml`
- `.octon/framework/capabilities/runtime/skills/capabilities.yml`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/SKILL.md`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-closeout-worktree-wrapper.sh`
- `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/SKILL.md`

Expected durable outputs include:

- strict JSON schema for `repo-hygiene-cleanup-authorization-v1`;
- repo-hygiene policy update allowing receipt-backed cleanup as a fail-closed
  alternative to manual `--confirm`;
- helper support for `--authorize <out.json>` and
  `--authorization <receipt.json>`;
- deterministic helper classification/digest logic and immediate revalidation
  before deletion;
- helper tests for receipt-backed success and fail-closed negative cases;
- repo-hygiene governance validator coverage for the schema, helper flags,
  policy text, docs, tests, and skill registration;
- narrow `repo-hygiene-cleanup` remediation skill registration;
- closeout-worktree reporting/validator fields for repo-hygiene routing, with
  `repo_hygiene_cleanup_actions_performed: false`;
- closeout-change documentation stating that `cleaned` is route-bound and does
  not imply global worktree hygiene.

After durable edits land, packet-local receipts are required:

- `.octon/inputs/exploratory/proposals/architecture/repo-hygiene-cleanup-authorization-receipts/support/implementation-run.md`
- `.octon/inputs/exploratory/proposals/architecture/repo-hygiene-cleanup-authorization-receipts/support/implementation-conformance-review.md`
- `.octon/inputs/exploratory/proposals/architecture/repo-hygiene-cleanup-authorization-receipts/support/post-implementation-drift-churn-review.md`

Retained validation evidence must live outside `inputs/**`, preferably under:

- `.octon/state/evidence/validation/proposals/repo-hygiene-cleanup-authorization-receipts/<timestamp>/`
- `.octon/state/evidence/runs/skills/repo-hygiene-cleanup/<run-id>/` when the
  new skill records run evidence

## Out Of Scope

Do not edit these surfaces for this packet:

- `.octon/generated/cognition/**`, except through the existing run-health
  generator if a later implementation validation explicitly requires
  generator-owned pruning and retained evidence;
- `.octon/generated/effective/**`;
- `.octon/state/control/**`;
- `.octon/state/evidence/**`, except retained validation/run evidence created
  by this implementation route;
- `.octon/inputs/**` outside this proposal packet's support receipts;
- `.github/**`, root docs, root adapters, host projections, provider settings,
  branch protection settings, or connector admissions.

Do not add `Closeout Changes`, do not add a new broad repo-hygiene command, do
not move cleanup authority into `Closeout Worktree`, do not expand
`Closeout Change` into global worktree cleanup, and do not route generated
run-health projections through the generic local-run cleanup helper.

Do not change `proposal.yml#status`; leave it as `accepted`. The later
promotion or closeout lifecycle route owns any implemented-status or archive
rewrite.

If implementation requires any out-of-scope file, new authority class,
generated/effective publication, host projection regeneration, destructive
cleanup of current residue, branch deletion, PR creation, or target-family
widening, stop and report `needs-packet-revision` with evidence.

## Ordered Workstreams

### 0. Preflight And Evidence Directory

1. Record current worktree state and preserve unrelated existing edits.
2. Run the mandatory proposal standard, architecture, review, and readiness
   gates.
3. Create a retained evidence directory under
   `.octon/state/evidence/validation/proposals/repo-hygiene-cleanup-authorization-receipts/<timestamp>/`.
4. Record the Profile Selection Receipt there and in
   `support/implementation-run.md`: `release_state=pre-1.0`,
   `change_profile=atomic`, `transitional_exception_note=not authorized`.
5. Capture baseline searches for repo-hygiene policy, cleanup helper,
   cleanup tests, branch cleanup authorization, generated run-health pruning,
   closeout-worktree reporting, closeout-change cleaned language, and skill
   registration surfaces.

### 1. Receipt Contract

Add `.octon/framework/product/contracts/repo-hygiene-cleanup-authorization-v1.schema.json`.

The schema must be strict, use required fields, and reject unexpected top-level
and path-entry properties unless a local schema pattern requires otherwise.
Model the revalidation posture after branch cleanup authorization, but make the
scope path-based rather than ref-based.

Required receipt fields must include:

- `schema_version`
- `authorization_id`
- `authorization_result`
- `created_at`
- `expires_at` or `valid_until_status_changes`
- `policy_ref`
- `helper_ref`
- `repo_root_ref`
- `head_ref`
- `main_ref`
- `origin_main_ref`
- `git_status_digest`
- `classification_ref`
- `classification_digest`
- `cleanup_path_set_digest`
- `authorized_paths`
- `protected_paths_digest`
- `manual_review_paths_digest`
- `discard_or_rollback_posture`
- `runtime_safety_boundary`

Each `authorized_paths` item must require:

- `path`
- `class`
- `pattern_id`
- `proofs.untracked`
- `proofs.unreferenced_by_tracked_files`
- `proofs.non_authoritative`
- `proofs.allowed_cleanup_pattern`
- `proofs.not_input_surface`
- `proofs.not_durable_evidence`
- `proofs.not_active_control_state`
- `proofs.not_generated_authority`
- `proofs.not_ignored_or_user_owned_residue`

The schema must allow only `approved` or `denied` authorization results. Denied
receipts must be retained evidence and must not authorize deletion.

### 2. Repo Hygiene Policy

Update `.octon/instance/governance/policies/repo-hygiene.yml` so
`local_artifact_hygiene.deletion_requires` and related text allow two non-dry-run
paths:

- manual `--confirm`, retained as the existing fallback;
- receipt-backed `--authorization <receipt.json>` only when the receipt
  validates and the helper revalidates the exact current cleanup path set.

Keep the existing invariants intact:

- detection never authorizes deletion;
- ambiguous findings default to non-destructive retention or escalation;
- referenced evidence, active control state, build-to-delete or claim-adjacent
  evidence, generated authority, input surfaces, ignored files, and
  user-owned residue are retained or manual-review.

### 3. Helper Hardening

Extend `.octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh`.

Keep current behavior:

- dry-run remains default;
- `--summary-only` remains non-mutating;
- `--confirm` remains the manual fallback;
- protected and manual-review files are retained.

Add:

- `--authorize <out.json>`: classify current residue and write an approved or
  denied authorization receipt.
- `--authorization <receipt.json>`: validate schema, recompute current
  classification, recompute tracked-file reference scans, recompute git refs
  and status digest, verify classification/path-set/protected/manual digests,
  verify every authorized path proof, then delete only the exact authorized
  cleanup path set without requiring ad hoc `--confirm`.

The helper must fail closed when:

- receipt is missing, unreadable, malformed, denied, stale, expired, or
  schema-invalid;
- `head_ref`, `main_ref`, `origin_main_ref`, git status digest, classification
  digest, path-set digest, protected digest, or manual-review digest differs;
- any authorized path is no longer untracked;
- any authorized path is referenced by tracked files;
- any authorized path is outside the allowed cleanup patterns;
- any authorized path is protected, manual-review, ignored, input-surface,
  active-control, durable-evidence, generated-authority, generated run-health,
  or user-owned residue;
- runtime filesystem, sandbox, host, or platform permissions deny deletion.

The helper must use deterministic ordering for rows and digests. It must record
removed paths or denial reasons in command output, and deletion must never touch
paths outside the authorized path set.

### 4. Generated Run-Health Boundary

Keep generated run-health pruning owned by
`.octon/framework/assurance/runtime/_ops/scripts/generate-run-health-read-model.sh`.

The generic helper must reject generated run-health projection paths such as
`.octon/generated/cognition/projections/materialized/runs/**/health.yml` and
route them to the generator-owned pruning path. Do not delete or claim those
paths through generic local-run cleanup. Validate that generator pruning remains
evidenced through `pruned_paths`.

### 5. Repo Hygiene Cleanup Skill

Add `.octon/framework/capabilities/runtime/skills/remediation/repo-hygiene-cleanup/SKILL.md`.

Register the skill in:

- `.octon/framework/capabilities/runtime/skills/manifest.yml`
- `.octon/framework/capabilities/runtime/skills/registry.yml`
- `.octon/framework/capabilities/runtime/skills/capabilities.yml`

The skill must:

- inventory local residue;
- run the hardened helper classification;
- emit or consume cleanup authorization receipts;
- invoke cleanup only with a validating receipt or explicit manual fallback;
- record retained/protected/manual-review residue;
- record run evidence under `.octon/state/evidence/runs/skills/`;
- remain a narrow remediation skill, not a broad repo-hygiene command.

The skill must not use proposal-local files, generated projections, ignored
files, host metadata, provider metadata, chat state, or tool availability as
cleanup authority.

### 6. Closeout Boundary Updates

Update `.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/SKILL.md`
and `.octon/framework/assurance/runtime/_ops/scripts/validate-closeout-worktree-wrapper.sh`.

Wrapper reports should be able to record:

- `repo_hygiene_classification_ref`
- `repo_hygiene_cleanup_authorization_ref`
- `repo_hygiene_summary.cleanup_candidates`
- `repo_hygiene_summary.protected_referenced`
- `repo_hygiene_summary.manual_review`
- `repo_hygiene_cleanup_actions_performed: false`
- `repo_hygiene_next_route_condition`

The validator must reject reports that claim wrapper cleanup authority or
terminal global cleanliness while repo-hygiene candidates, protected residue,
manual-review residue, ignored local residue, or foreign residue remain
unresolved.

Update `.octon/framework/capabilities/runtime/skills/remediation/closeout-change/SKILL.md`
so `cleaned` means selected route cleanup only: source branch cleanup when
applicable, local-main synchronization when claimed, and route-bound residue
disposition. It must not imply global worktree hygiene.

### 7. Validators And Tests

Extend `.octon/framework/assurance/runtime/_ops/scripts/validate-repo-hygiene-governance.sh`
to require:

- the new schema file and schema version;
- policy references to receipt-backed cleanup and fail-closed revalidation;
- helper flags `--authorize` and `--authorization`;
- repo-hygiene docs mention the receipt-backed path and runtime/platform
  boundary;
- cleanup helper tests cover receipt behavior and negative controls;
- skill registration for `repo-hygiene-cleanup`;
- closeout-worktree and closeout-change boundary text.

Extend `.octon/framework/assurance/runtime/_ops/tests/test-cleanup-local-run-artifacts.sh`
with cases proving:

- valid receipt permits cleanup without `--confirm`;
- missing receipt fails closed;
- malformed receipt fails closed;
- denied receipt fails closed;
- stale git refs/status/classification/path-set digests fail closed;
- path-mismatched receipt fails closed;
- tracked paths fail closed;
- referenced untracked paths fail closed;
- protected/manual-review paths fail closed;
- ignored or user-owned residue fails closed;
- input-surface paths fail closed;
- durable evidence paths fail closed;
- active control state paths fail closed;
- generated authority paths fail closed;
- generated run-health paths are rejected by the generic helper.

Add fixture files only under approved assurance test paths.

## Required Evidence And Receipts

After implementation, update proposal support receipts:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`

Retain evidence under:

```text
.octon/state/evidence/validation/proposals/repo-hygiene-cleanup-authorization-receipts/<timestamp>/
```

Retain at least:

- preflight gate output;
- profile selection receipt;
- baseline inventory and search notes;
- schema validation output;
- helper test output;
- repo-hygiene governance validator output;
- closeout-worktree wrapper validator output;
- skill registration validation output;
- generated run-health boundary validation output;
- rollback posture for every durable target family touched.

## Validation

Run these proposal lifecycle validators:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/repo-hygiene-cleanup-authorization-receipts
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/repo-hygiene-cleanup-authorization-receipts
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/repo-hygiene-cleanup-authorization-receipts --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/repo-hygiene-cleanup-authorization-receipts
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/repo-hygiene-cleanup-authorization-receipts
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/repo-hygiene-cleanup-authorization-receipts
```

Run implementation validators and tests:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-repo-hygiene-governance.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-cleanup-local-run-artifacts.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-closeout-worktree-wrapper.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-run-health-read-model.sh
git diff --check
```

Also run any skill registry, schema, shell syntax, or fixture tests introduced
or touched by the implementation.

## Packet Terminal Closeout Orchestration Overlay

Use this section to drive the packet from implementation into terminal lifecycle
readiness using the posture described by `packet-lifecycle-terminal-closeout`.
This overlay does not create archive, cleanup, Git, publication, or closeout
authority. It adapts the terminal-closeout packet's state-driven aggregate
receipt model to this standalone packet so the lifecycle can complete
end-to-end once the required target-owned receipts exist.

The terminalization owner must validate target-owned receipts and cite them.
It must not replace implementation receipts, closeout receipts, cleanup
authorization receipts, publication freshness receipts, branch authorization
receipts, post-integration architecture review receipts, or archive movement.
`archive-proposal` remains the only archive relocation owner.

### Terminal Closeout Gate Snapshot

This refresh was prepared after these target packet gates passed:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/repo-hygiene-cleanup-authorization-receipts --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/repo-hygiene-cleanup-authorization-receipts
```

Observed result at refresh time: `errors=0 warnings=0` for both top-level
gates. Re-run both gates at execution time and stop if either fails, if the
review digest is stale, if implementation authorization is missing, or if
clarification is required.

The source context used for this overlay included these digests:

```text
sha256:5b7a86325057eb43381be883304573f256d2f75049761fdfc89a8907e19c6dc4  repo-hygiene-cleanup-authorization-receipts/proposal.yml
sha256:0dc5f9d631bee10e0c07955ef9359dae16b9d0e11d434f0ce0337fd9787e2468  repo-hygiene-cleanup-authorization-receipts/architecture-proposal.yml
sha256:d47b98cb027cf3d3eb98017f3152316c1c351f3870310f64ee0728e9f263e521  repo-hygiene-cleanup-authorization-receipts/architecture/implementation-plan.md
sha256:ee54520ccf229cbe84907998ec18cbeb3118189b9befdd1406a656b5382e3848  repo-hygiene-cleanup-authorization-receipts/architecture/acceptance-criteria.md
sha256:e307e714b8e0ead12df1cbdd35e189c94f4912f4c7612fa7a1f70cf3156d03bc  packet-lifecycle-terminal-closeout/proposal.yml
sha256:bcc6d1690cee08b7de504798e46590b54db13a0ae99e3810e19d83a8fe3f3b87  packet-lifecycle-terminal-closeout/architecture/target-architecture.md
```

Refresh these digests during execution if any referenced source file changed.

### Terminal Profile

Before terminalization, record a terminal profile in `support/implementation-run.md`
or retained run evidence. Use at least:

```yaml
schema_version: standalone-packet-terminal-closeout-profile-v0
target_packet_path: .octon/inputs/exploratory/proposals/architecture/repo-hygiene-cleanup-authorization-receipts
target_outcome: archive-ready
route_preference: branch-no-pr
pr_policy: do-not-create-pr-block-if-branch-no-pr-impossible
publication_freshness_policy: validate-or-refresh-through-owning-publishers-only
hygiene_policy: classify-first-authorize-before-delete
post_integration_architecture_review_policy: evidence-only-after-conformance-and-drift
packet_terminal_evaluator_policy: required-if-blocked-nonterminal-cancelled-rollback-or-repeated-retry
archive_movement_policy: archive-proposal-only
required_packet_receipts:
  - support/implementation-run.md
  - support/implementation-conformance-review.md
  - support/post-implementation-drift-churn-review.md
required_validators:
  - validate-proposal-implementation-conformance.sh
  - validate-proposal-post-implementation-drift.sh
  - validate-repo-hygiene-governance.sh
  - test-cleanup-local-run-artifacts.sh
  - validate-closeout-worktree-wrapper.sh
  - validate-run-health-read-model.sh
terminal_receipt_policy: aggregate-only-does-not-replace-target-owned-receipts
```

Profile binding proves terminal intent and guardrails only. It does not
authorize durable edits, cleanup, Git mutation, branch landing, branch
deletion, generated publication, proposal status mutation, or archive movement.

### Terminal Sequence

Run terminalization as a resumable state machine:

1. Bind the terminal profile, target packet path, target outcome, route
   preference, PR policy, publication policy, hygiene policy, and non-authority
   boundaries.
2. Verify the packet is implemented or implementation-ready-to-complete before
   terminal claims. If durable implementation has not completed, continue only
   through `run-packet-implementation`; do not claim `archive-ready`.
3. Verify durable implementation state for every approved promotion target:
   repo-hygiene policy, cleanup authorization schema, cleanup helper, helper
   tests, repo-hygiene governance validator, command README, remediation skill,
   skill manifest, skill registry, capabilities map, closeout-worktree
   boundary, closeout-worktree validator, and closeout-change boundary.
4. Require current `support/implementation-conformance-review.md` and run
   `validate-proposal-implementation-conformance.sh`.
5. Require current `support/post-implementation-drift-churn-review.md` and run
   `validate-proposal-post-implementation-drift.sh`.
6. Validate publication freshness for touched capability, skill, command,
   proposal registry, and generated projection families. Repair failed
   freshness only through the owning canonical publisher, then rerun the
   failed and adjacent validators.
7. Validate generated/input non-authority. Direct generated edits, proposal
   support files, generated prompts, host state, dashboards, chat, tool state,
   and model memory cannot authorize cleanup or terminal status.
8. Validate run-health, capability publication, and extension publication
   coverage required by touched targets.
9. Classify repo-hygiene residue. Delete only through repo-hygiene cleanup
   authorization and helper revalidation. If implementation evidence creates
   expected retained residue, classify it as expected evidence rather than
   deleting it.
10. Classify worktree hygiene. If non-packet residue or ambiguous residue
    blocks hygiene, stop with the exact next route, usually `closeout-worktree`
    or `closeout-change`.
11. Run post-integration architecture review only after conformance and drift
    pass. Treat the support receipt as evidence-only.
12. Run a packet terminal evaluator or lifecycle-postmortem hook when the run
    is blocked, nonterminal, cancelled, rollback, or repeated-retry. Treat that
    output as evidence-only.
13. If Git mutation is required, delegate route selection and effects to the
    default work-unit and Change closeout state machine. For branch-no-PR,
    require exact source-SHA checks, governed landing authorization, branch
    cleanup authorization, fetch/sync, and local `main`/`origin/main`/landed-ref
    equality proof through the existing Git/GitHub route.
14. Emit a packet-local aggregate terminal receipt or terminal-readiness map.
    Verdict is `archive-ready` only when every required gate passed, expected
    retained evidence is current, and hygiene is not blocked. Verdict is
    `blocked` with exact blocker and next canonical route otherwise.
15. Do not move the packet into `.archive`; run `archive-proposal` only after a
    separate archive route validates archive movement.

If the durable `proposal-packet-terminal-closeout` workflow and receipt schema
do not exist yet, record `blocked-terminal-closeout-workflow-missing` or
`terminal-readiness-map-only` rather than inventing an archive-ready receipt.
The implementation may still pass, but terminal lifecycle completion remains
blocked until the terminal-closeout route exists or another authorized route
provides equivalent evidence.

### Terminal Receipt Content

When a terminal receipt or terminal-readiness map is written, include at least:

```yaml
terminal_verdict: archive-ready|blocked|terminal-readiness-map-only
terminalized_at: <UTC timestamp>
target_packet_path: .octon/inputs/exploratory/proposals/architecture/repo-hygiene-cleanup-authorization-receipts
target_outcome_requested: archive-ready
target_outcome_actual: archive-ready|blocked|implemented
profile_digest: <sha256-or-not-applicable>
durable_implementation_state_refs:
  - <path>
implementation_conformance_receipt_ref: .octon/inputs/exploratory/proposals/architecture/repo-hygiene-cleanup-authorization-receipts/support/implementation-conformance-review.md
post_implementation_drift_churn_receipt_ref: .octon/inputs/exploratory/proposals/architecture/repo-hygiene-cleanup-authorization-receipts/support/post-implementation-drift-churn-review.md
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
branch_authorization_refs:
  - <path-or-not-applicable>
archive_movement_owner: archive-proposal
archive_movement_performed: false
blocker_class: none|missing-terminal-workflow|missing-evidence|stale-evidence|hygiene-blocked|git-route-blocked|validator-failed|scope-overrun
blocker_detail: <detail-or-none>
next_canonical_route: archive-proposal|proposal-packet-terminal-closeout|closeout-worktree|closeout-change|run-packet-implementation|blocked
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
- repo-hygiene governance validator passes;
- cleanup helper tests pass, including receipt-backed positive and negative
  controls;
- closeout-worktree wrapper validator passes;
- generated/input non-authority validation passes;
- run-health validation passes or is explicitly not applicable;
- capability and skill publication validators pass or are explicitly not
  applicable;
- repo-hygiene cleanup, if any, used a valid cleanup authorization receipt and
  immediate helper revalidation;
- worktree hygiene is not blocked by foreign, ambiguous, ignored, protected, or
  manual-review residue;
- post-integration architecture review output is evidence-only;
- lifecycle-postmortem or packet terminal evaluator output is evidence-only;
- Git/GitHub hosted checks, branch landing authorization, branch cleanup
  authorization, and final sync proof exist when Git mutation is required;
- archive movement is not performed by the terminal receipt.

### Terminal Stop Conditions

Stop and record a blocked terminal outcome when:

- the terminal-closeout workflow/schema is not durable and no authorized
  equivalent terminal receipt route exists;
- a needed edit or terminal check falls outside approved promotion targets;
- a validator fails without a narrow non-blocking rationale;
- conformance or drift/churn receipts are missing, stale, failing, or
  unresolved;
- publication freshness requires direct generated-output edits;
- cleanup would proceed without a validating receipt and immediate helper
  revalidation;
- residue remains that cannot be classified as expected retained evidence;
- Git/GitHub route evidence is missing for a required mutation;
- any surface attempts to use lifecycle-postmortem, post-integration
  architecture review, proposal inputs, generated outputs, host state, chat,
  tool state, or model memory as authority;
- archive relocation is attempted outside `archive-proposal`.

The correct outcome for these conditions is `blocked` with the exact blocker
and next canonical route, not an archive-ready overclaim.

## Rollback And Closeout Refusal

Rollback is revert of the new schema, helper flags and revalidation logic,
policy text, repo-hygiene docs, tests, validators, skill registration, and
closeout boundary updates from this packet. Retain any emitted cleanup
authorization, denied-cleanup, implementation, or validation evidence under
`.octon/state/evidence/**` for auditability.

Refuse closeout, archive, or implemented-status claims if:

- `support/implementation-conformance-review.md` is missing or failing;
- `support/post-implementation-drift-churn-review.md` is missing or failing;
- `validate-proposal-implementation-conformance.sh` fails;
- `validate-proposal-post-implementation-drift.sh` fails;
- receipt-backed cleanup can delete without immediate helper revalidation;
- helper `--authorization` can delete paths outside the exact receipt path set;
- any required negative control is missing;
- generated run-health pruning is handled by generic cleanup;
- `Closeout Worktree` can perform cleanup directly;
- `Closeout Change` overclaims global worktree hygiene;
- runtime/platform approval boundaries are omitted or bypassed.

The next lifecycle route after this prompt is `run-packet-implementation`.
