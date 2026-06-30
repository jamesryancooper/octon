# Example Run Program To Clean Delivery Prompt

Read and follow `AGENTS.md` first.

Use this prompt as an execution-grade example of the future
`run-program-to-clean-delivery` capability. It manually orchestrates the
existing governed routes that the implemented capability should eventually
select, sequence, retry, and validate by default.

## Execution Persona

Act as the accountable Octon lifecycle orchestrator. Be conservative,
evidence-driven, and route-owned: dispatch the existing lifecycle, workflow,
Change closeout, worktree closeout, repo hygiene, archive, and terminal proof
routes in order. Do not turn this prompt into a new authority surface.
Default to governed autonomous progress: when a blocker has a declared owning
route and current policy allows remediation, invoke that route, retain its
evidence, revalidate, and continue without asking the operator.

## Target

Parent proposal program:

`.octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery`

Target outcome:

`git_clean_terminal`

## Goal

Run the parent proposal program from draft proposal state through governed
program review, child packet review/readiness, child packet implementation,
verification/correction, child closeout, parent closeout, Proposal Program
Delivery, child and parent archive handoff through `archive-proposal`, Change
delivery, branch landing, branch cleanup, terminal evidence, evidence
disclosure validation, delivery evidence indexing, and final
`git_clean_terminal` validation with the minimum operator intervention allowed
by current policy.

Treat this as lifecycle orchestration. Do not bypass proposal authority,
child-owned receipts, implementation authorization, validation gates, delivery
policy, branch cleanup authorization, evidence disclosure boundaries, or
terminal proof validation.

The goal is not merely to produce an implementation checkpoint. The goal is to
reach a validated clean terminal state: all required parent and child lifecycle
routes complete or report accepted terminal dispositions, delivery evidence is
retained and validated, Change delivery is landed and cleaned through its
owning route, terminal proof is fresh after the last mutation, and the final
worktree state validates as `git_clean_terminal`.

## Non-Negotiable Authority Boundaries

- Parent program evidence is coordination lineage only.
- Parent evidence cannot satisfy child packet review receipts, child
  implementation receipts, child validation verdicts, child closeout evidence,
  child promotion targets, child archive metadata, Change delivery receipts, or
  terminal outcomes.
- Each child packet must use its own manifest, scope, promotion targets,
  validators, acceptance criteria, authority notes, and support receipts.
- Generated outputs are derived and non-authoritative. Refresh them only
  through canonical generators and validate the resulting freshness.
- Raw inputs, proposal-local support files, host UI state, chat/model memory,
  dashboards, and tool availability are non-authority unless backed by authored
  runtime/spec/validator evidence and retained route receipts.
- Branch-no-pr delivery is valid only when the default work-unit policy permits
  it, no PR predicate applies, hosted no-PR preflight passes, and governed
  landing authorization validates.
- Hosted/shared closeout receipts must not depend directly on local/private
  evidence refs under `.octon/state/evidence/local/**`. Local/private terminal
  evidence may be cited only through digest-backed, retained-evidence-only
  references allowed by the Change receipt and disclosure-tier contracts.
- Classification is routing evidence only. It never authorizes deletion,
  branch cleanup, archive relocation, delivery, or a cleaned claim.

## Governed Autonomous Blocker Handling

Handle blockers autonomously when all of these are true:

- the blocker has a clear owning route;
- the owning route is already declared by the lifecycle, workflow, Change
  closeout, worktree closeout, repo hygiene, archive, or validation contract;
- the route can act within the current write scope, policy, and authority
  envelope;
- the action is reversible or has required rollback posture;
- current retained evidence can be refreshed or produced by the owning route;
- no external approval, unresolved ownership, unsafe mutation, PR predicate, or
  explicit operator override is required.

Use these default blocker routes:

- stale parent review, structure, or readiness evidence -> run
  `review-program`, `revise-program`, then revalidate parent gates;
- stale child review or readiness evidence -> run `review-packet`,
  `revise-packet`, then revalidate child gates;
- missing or stale implementation authorization -> run the owning review or
  promotion/readiness route; stop if authorization is denied or unavailable;
- failed child implementation validation -> run the owning child
  verification/correction route, apply the smallest route-authorized change,
  then rerun implementation conformance and drift/churn validators;
- stale route-owned receipts or digest-bound receipts -> refresh through the
  owning lifecycle route; never hand-edit receipt digests;
- generated proposal registry, artifact index, spine, or handoff capsule drift
  -> run the owning generator, then validate generated freshness;
- child closeout hygiene blocker with exact foreign path set -> route through
  `closeout-worktree` and validate the returned wrapper/interaction evidence;
- eligible local Octon run/artifact residue -> route through
  `repo-hygiene-cleanup`; delete only with explicit confirmation or a valid
  cleanup authorization receipt;
- dirty or stale source posture before delivery -> require route-owned clean
  worktree selection and include-path classification before staging, commit,
  push, landing, cleanup, or `cleaned` claims;
- missing delivery profile -> materialize a retained
  `proposal-program-delivery-profile-v1`, validate it, and continue;
- Change closeout blocker -> route through `closeout-change` or
  `closeout-worktree` as selected by the default work-unit policy;
- stale landing or cleanup authorization -> refresh through the owning
  `closeout-change` helper route; stop if authorization is denied or stale;
- git index/ref/remote/sandbox/host/provider mutation denial -> record the
  owning diagnostic evidence and use the governed rerun path for the same
  operation when available; do not bypass platform controls;
- terminal proof or disclosure-tier failure -> regenerate terminal evidence
  only with concrete route-owned inputs, validate the manifest, then validate
  disclosure tiers against the actual Change receipt.

After every autonomous blocker-handling action:

1. record the route invoked and evidence path;
2. rerun the failed validator or gate;
3. replan from current repository state;
4. continue to the next owning route only when the blocker is resolved;
5. downgrade the actual outcome and report the next owning route when the
   blocker remains unresolved.

## Stop Conditions

Stop only after the governed autonomous blocker-handling rules above cannot
resolve the blocker, or when any of these occur. Report the exact blocker,
owning route, evidence path, and next legal action:

- missing or denied implementation authorization;
- child packet authority conflict or parent evidence substitution;
- failed validator without an owning correction route;
- missing, stale, or malformed target-owned child receipt;
- unresolved foreign, ambiguous, unsafe, protected, or user-owned worktree
  ownership;
- unsafe mutation, deletion, branch cleanup, archive action, or generated state
  hand edit;
- required external approval, provider rule requiring PR, or concrete PR
  predicate;
- stale or denied landing or cleanup authorization that cannot be route
  refreshed;
- git index, ref, remote, sandbox, host, or provider mutation boundary that the
  owning route cannot resolve through its governed rerun path;
- terminal proof cannot establish `HEAD`, `main`, `origin/main`, and
  `landed_ref` alignment after final sync;
- publishable, foreign, ambiguous, staged, unstaged, untracked, generated,
  retained-evidence, state-control, release, or input-surface residue remains
  after route-owned cleanup;
- hosted/shared receipts reference local/private terminal evidence directly;
- explicit operator override is required by policy.

## Child Packet Sequence

Run child packets in this order, preserving child authority at each step:

1. `.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-architecture`
2. `.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-runner-routing`
3. `.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-workflow-handoff`
4. `.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-evidence-metadata`
5. `.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-validators`
6. `.octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-operator-surface`

## Phase 0: Bind Run Context And Preflight

1. Record a run id for the orchestration, for example
   `<timestamp>-run-program-to-clean-delivery`.
2. Bind `release_state: pre-1.0` and `change_profile: atomic`.
3. Inspect `git status --short`, current branch, `HEAD`, `main`, and
   `origin/main`.
4. If the lifecycle runner will use a nested executor, preflight executor
   runtime access. If the sandbox cannot write the required runtime state,
   rerun through the approved escalated execution path before dispatching child
   routes.
5. Confirm that the target parent and all six child directories exist. If any
   child is missing, stop before review.

## Phase 1: Parent Review And Revision

Run the proposal-program review/revise loop until the parent has no required
corrections or blockers.

Required gates:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery
```

Route behavior:

1. Run `review-program` for the parent.
2. If corrections are required, run `revise-program`.
3. Apply only parent-local revisions required by the review route.
4. Rerun the three parent gates above.
5. Repeat until parent review passes or a blocker is reported.

## Phase 2: Child Review, Revision, And Readiness

For each child in sequence:

1. Run `review-packet`.
2. If blockers or required corrections are reported, run `revise-packet`.
3. Apply only child-local revisions required by the review route.
4. Rerun `review-packet`.
5. Continue until the child has accepted review/readiness evidence.

Required child gates:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package <child> --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package <child>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package <child>
```

Before implementation prompt generation or implementation execution, also run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package <child> --require-implementation-authorization
```

After all children pass review/readiness, run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery
```

## Phase 3: Program Lifecycle Runner

Use the shared proposal-program lifecycle runner to drive route selection and
bounded child execution from current parent/child state:

```sh
octon lifecycle run --lifecycle proposal-program --target .octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery --execute-routes --invocation-authority unattended --max-steps <bounded-step-count> --max-child-concurrency 1
```

If `octon` is not installed or does not expose `lifecycle`, use:

```sh
.octon/framework/engine/runtime/run lifecycle run --lifecycle proposal-program --target .octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery --execute-routes --invocation-authority unattended --max-steps <bounded-step-count> --max-child-concurrency 1
```

Runner requirements:

- Replan after every material route result.
- Dispatch only one selected parent route or one runnable child batch per
  iteration.
- Treat `planned`, `program-route-handoff`, and `route-ready` as non-terminal.
- Stop before archive, push, landing, cleanup deletion, branch deletion, PR
  creation/merge, external publication, or any `cleaned` claim. Those belong to
  later owning routes.
- Treat approval pauses as blocked until a valid program approval route records
  approval, then retry or resume.

If the runner cannot complete a required child implementation route, continue
manually through Phase 4 only for children whose implementation authorization
is valid.

## Phase 4: Child Implementation

For each child not already implemented by the runner:

1. Run the owning `run-packet-implementation` route for that child.
2. Use only that child's manifest, promotion targets, implementation plan,
   validators, acceptance criteria, authority notes, and support receipts.
3. Do not mutate sibling packets unless the child packet explicitly requires a
   child-local consistency update.
4. Produce child-owned implementation evidence.
5. Produce and pass these child-owned support receipts:
   - `support/implementation-grade-completeness-review.md`
   - `support/implementation-conformance-review.md`
   - `support/post-implementation-drift-churn-review.md`
6. Run the child validators selected by the child validation plan.

Before any implemented or implementation-ready claim, run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package <child>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package <child>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package <child>
```

After child implementation, create or refresh parent-local orchestration
evidence only as an aggregate summary:

`.octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery/support/program-implementation-orchestration-run.md`

Minimum required fields:

- `verdict`
- `implemented_at`
- `promotion_evidence_count`
- `child_authority_preserved`
- child evidence refs by path and digest
- explicit statement that parent evidence does not satisfy child receipts

## Phase 5: Program Verification And Correction

Run the program verification-and-correction loop:

`run-program-verification-and-correction-loop`

If the program loop reports child-specific corrections, run the owning child
correction route, usually:

`run-packet-verification-and-correction-loop`

For each implemented child, rerun at minimum:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package <child>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package <child>
```

The verification loop may refresh stale route-owned receipts at stable digest
boundaries, but it must not manually patch receipt digests or use parent
evidence as child evidence. On aggregate pass, parent-local
`support/program-implementation-orchestration-conformance-review.md` and
`support/program-post-implementation-orchestration-drift-churn-review.md` must
record `verdict: pass` and `child_authority_preserved: yes`.

## Phase 6: Child Closeout

For each child in sequence:

1. If implementation evidence is valid but manifest/status is stale, run the
   owning promote/status-correction route for that child only.
2. Run `closeout-packet`.
3. If stale review or pre-integration architecture receipts block closeout,
   refresh them through the owning routes.
4. If hygiene blocks closeout, resolve it only through route-owned
   `closeout-worktree` with explicit operator scope or a valid lifecycle
   handoff for the exact foreign path set.
5. Stop if the blocker requires product implementation, validator
   implementation, external approval, unresolved foreign ownership, or unsafe
   mutation.

Required closeout gates:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package <child>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package <child>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package <child>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package <child>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package <child>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package <child>
bash .octon/framework/assurance/runtime/_ops/scripts/classify-proposal-worktree-hygiene.sh --target <child> --lifecycle proposal-packet --format yaml
```

Do not use `validate-proposal-review-gate.sh --require-implementation-authorization`
as a generic closeout/archive gate; that strict gate is for implementation
prompt generation, implementation execution, and promotion.

Each child must have a child-owned closeout receipt:

`<child>/support/proposal-closeout.md`

The receipt must report `verdict: pass` and `archive_authorized: yes` before
any archive route is run for that child.

## Phase 7: Child Archive Handoff

This phase defines the child archive handoff contract. Do not pre-archive
children before Proposal Program Delivery unless the owning lifecycle or
delivery stage explicitly delegates `archive-proposal` and records how the
active and archived paths remain reconciled. In the normal clean-delivery path,
Proposal Program Delivery reaches this handoff during its closeout/archive
stage. When the owning route delegates child archive relocation, run
`archive-proposal` for each child only after that child's closeout receipt
authorizes archive readiness:

```text
/archive-proposal proposal_path=<child> disposition=implemented promotion_evidence=<comma-separated-child-owned-promotion-evidence-paths>
```

Archive route requirements:

- Use `disposition=implemented` only when child-owned implementation-grade,
  conformance, and drift/churn receipts pass.
- Supply non-empty, repo-relative `promotion_evidence` for implemented or
  superseded archival.
- Do not use archive routes to repair missing closeout evidence.
- Do not treat child archive metadata as parent archive metadata.
- After each archive mutation, validate terminal freshness for the archived
  path when required by the archive workflow:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-lifecycle-terminal-freshness.sh --proposal <archived_child_path> --run-registry-check
```

## Phase 8: Parent Closeout

After all children have valid child-owned closeout receipts and archive
metadata, run `closeout-program` for the parent.

Before parent closeout, rerun:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-structure.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery
bash .octon/framework/assurance/runtime/_ops/scripts/classify-proposal-worktree-hygiene.sh --target .octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery --lifecycle proposal-program --format yaml
```

During closeout, refresh route-owned derived metadata with canonical
generators/checks only:

- parent and child `navigation/artifact-catalog.md`
- `.octon/generated/proposals/registry.yml`
- `.octon/generated/proposals/artifacts/**` indexes, spines, and handoff
  capsules

Generated metadata remains derived-only and cannot substitute for proposal
authority or child receipts.

Parent closeout receipt:

`.octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery/support/proposal-closeout.md`

It must report `verdict: pass`, `archive_authorized: yes`, aggregate child
refs by path/digest, and `child_authority_preserved: yes`.

## Phase 9: Parent Archive Handoff

This phase defines the parent archive handoff contract. Do not pre-archive the
active parent before Proposal Program Delivery preflight. In the normal
clean-delivery path, Proposal Program Delivery reaches this handoff after
parent closeout and child archive state are valid. When the owning lifecycle or
delivery stage delegates parent archive relocation, archive the parent only
after all child archive outcomes are valid and parent closeout authorizes
archive readiness:

```text
/archive-proposal proposal_path=.octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery disposition=implemented promotion_evidence=<comma-separated-parent-and-child-owned-evidence-paths>
```

Use the archived parent path returned by the archive route for later
archive-specific validation. Continue to use the active target path for
Proposal Program Delivery preflight unless the delivery route itself returns a
different canonical target path. Do not claim delivery if parent archive
metadata is missing, stale, inconsistent, or not produced by the owning route.

## Phase 10: Proposal Program Delivery

Run the canonical Proposal Program Delivery route with target outcome
`cleaned`. Bind a delivery run id and a valid
`proposal-program-delivery-profile-v1` profile before mutating delivery state.

If the command/runtime auto-materializes a valid profile, capture its path and
validate it. If not, create a retained profile under the delivery evidence
bundle and validate it before invoking delivery:

```yaml
schema_version: proposal-program-delivery-profile-v1
profile_id: run-program-to-clean-delivery-cleaned
created_at: <iso-8601-timestamp>
target_program_path: .octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery
target_outcome: cleaned
execution_order_policy:
  canonical_order_required: true
  canonical_order_ref: child-before-parent-delivery
  operator_requested_alternative_order: false
  requested_order_ref: child-before-parent-delivery
  override_required_when_order_differs: true
  override_receipt_ref: ""
route_preference:
  work_unit_route: branch-no-pr
  landing_route: branch-no-pr
  pr_creation_allowed: false
pr_policy:
  mode: forbid-pr
  allow_pr_creation: false
  fallback_to_pr: false
stash_policy:
  mode: forbidden
  preserve_unrelated_work: true
child_execution:
  replan_after_material_changes: true
  target_owned_receipts_required: true
  parent_summary_satisfies_child_receipts: false
required_proposal_validators:
  - validate-proposal-standard.sh
  - validate-architecture-proposal.sh
  - validate-proposal-program-structure.sh
  - validate-proposal-program-child-readiness.sh
required_implementation_validators:
  - validate-proposal-implementation-readiness.sh
  - validate-proposal-implementation-conformance.sh
  - validate-proposal-post-implementation-drift.sh
publication_checks:
  owning_publishers_only: true
  generated_outputs_are_non_authority: true
  freshness_validator: validate-proposal-artifact-index-spine.sh
  direct_generated_output_edits_allowed: false
mechanism_integration_checks:
  required_when_applicable: true
  receipt_required_when_required: true
closeout_requirements:
  packet_closeout_required: true
  archive_lifecycle_required: true
  change_closeout_required: true
  delegate_git_mutation_to_change_closeout: true
hygiene_requirements:
  cleanup_authorization_required: true
  classification_alone_authorizes_deletion: false
terminal_proof_requirements:
  terminal_current_state_proof_required: true
  worktree_hygiene_required: true
final_sync_requirements:
  main_origin_landed_ref_equality_required: true
non_authority_boundaries:
  proposal_local_files: non-authority
  generated_prompts: non-authority
  generated_outputs: derived-only-non-authority
  dashboards: non-authority
  chat_or_model_memory: non-authority
```

Validate the profile:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-profile.sh --profile <delivery_profile>
```

Then run:

```text
/proposal-program-delivery target=.octon/inputs/exploratory/proposals/architecture/run-program-to-clean-delivery outcome=cleaned profile=<delivery_profile> run-id=<delivery_run_id>
```

The delivery route must:

- consume parent and child closeout/archive evidence without replacing it;
- run retained delivery-readiness preflight before child continuation, parent
  delivery, Git mutation, publication checks, landing, sync, cleanup, or branch
  deletion;
- validate target-owned child receipts directly;
- refresh delivery readiness projections through canonical checks;
- route packet closeout and archive handoff through their owning lifecycles;
- route Change closeout, hosted mutation, branch landing, final sync, and
  branch cleanup through `closeout-change` or `closeout-worktree`;
- route dirty-worktree partitioning through `closeout-worktree` when needed;
- route eligible local run/artifact residue through `repo-hygiene-cleanup`;
- select `branch-no-pr` only when policy allows and no PR predicate applies;
- retain publishable landing evidence before local terminal proof;
- retain branch cleanup authorization and cleanup evidence before terminal
  proof;
- refuse `cleaned` if publishable, foreign, ambiguous, staged, unstaged,
  untracked, generated, retained-evidence, state-control, release, or
  input-surface residue remains.

## Phase 11: Change Closeout And Worktree/Hygiene Subroutes

When Proposal Program Delivery delegates Change closeout, ensure the owning
route records the actual Change receipt path, selected route, target outcome,
actual outcome, landing authorization, cleanup authorization, rollback handle,
landed ref, source branch, and blockers.

For the Change receipt, run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-state-machine.sh --receipt <change_receipt>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-change-closeout-lifecycle-alignment.sh --receipt <change_receipt> --verify-live-refs
```

If `branch-no-pr` was selected, also run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-hosted-no-pr-landing.sh --receipt <change_receipt> --require-live-remote
```

Use `--skip-live-remote` only when the route records why live remote proof is
unavailable and the actual outcome is downgraded or blocked accordingly.

If `closeout-worktree` is invoked, validate its wrapper report:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-closeout-worktree-wrapper.sh --report <closeout_worktree_report>
```

If `repo-hygiene-cleanup` is invoked, use its classify-first route. Do not
delete anything unless the route has explicit operator confirmation or a valid
`repo-hygiene-cleanup-authorization-v1` receipt. Terminal closeout sink files
under `.octon/state/evidence/local/terminal-closeout/<change-id>/` are
protected from generic cleanup.

## Phase 12: Terminal Evidence

Terminal evidence is retained evidence only and must be written after landing,
final sync, branch cleanup authorization, cleanup disposition, rollback
posture, and route-owned validation evidence exist.

Prefer the terminal proof produced by `closeout-change` or Proposal Program
Delivery. If a separate terminal local evidence sink must be synthesized, do
not run the writer without arguments. Use one of these forms with real values
from the Change receipt and route evidence.

Snapshot an existing proof and receipt:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/write-terminal-closeout-local-evidence.sh \
  --change-id <change_id> \
  --proof <terminal_current_state_proof.yml> \
  --receipt <change_receipt.json> \
  --landed-ref <landed_ref> \
  --landing-authorization <landing_authorization.json> \
  --cleanup-authorization <branch_cleanup_authorization.json> \
  --source-branch <source_branch>
```

Or synthesize from current state after final mutation:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/write-terminal-closeout-local-evidence.sh \
  --change-id <change_id> \
  --selected-route <selected_route> \
  --target-lifecycle-outcome cleaned \
  --lifecycle-outcome cleaned \
  --landed-ref <landed_ref> \
  --source-branch <source_branch> \
  --landing-authorization <landing_authorization.json> \
  --cleanup-authorization <branch_cleanup_authorization.json> \
  --rollback-handle <rollback_handle>
```

Validate the terminal local evidence manifest:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-terminal-closeout-local-evidence.sh --manifest .octon/state/evidence/local/terminal-closeout/<change_id>/manifest.json --change-id <change_id> --landed-ref <landed_ref>
```

Then validate disclosure boundaries against the actual Change receipt:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-evidence-disclosure-tiers.sh --change-receipt <change_receipt>
```

Do not cite `.octon/state/evidence/local/**` directly as hosted/shared proof.
If the Change receipt cites terminal local evidence, it must include the
required digest, retained-evidence-only classification, and non-authority
boundaries.

## Phase 13: Delivery Receipt And Evidence Index

Capture the Proposal Program Delivery aggregate receipt path. Validate the
actual receipt, not the package path:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-receipt.sh --receipt <proposal_program_delivery_receipt>
```

Generate and validate the retained evidence index:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-program-delivery-evidence-index.sh --receipt <proposal_program_delivery_receipt> --run-id <delivery_run_id> --write --index <proposal_program_delivery_evidence_index>
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-evidence-index.sh --index <proposal_program_delivery_evidence_index>
```

Also run static workflow/profile checks if they were not already run in this
delivery run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-workflow.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-delivery-profile.sh --profile <delivery_profile>
```

The evidence index is compact retained evidence only. It does not authorize
delivery, archive, landing, cleanup, child receipts, or lifecycle outcomes.

## Phase 14: Final Git Clean Terminal Validation

After the last mutation and after terminal evidence/disclosure validation,
prove:

- `HEAD`, `main`, `origin/main`, and `landed_ref` identify the same commit;
- no staged files;
- no unstaged tracked modifications;
- no untracked files other than ignored, validated local-private terminal sink
  files allowed by the terminal evidence contract;
- no publishable residue;
- no foreign or ambiguous residue;
- no unresolved repo-hygiene cleanup candidates;
- no protected active control state or retained evidence is being claimed as
  cleaned;
- valid hosted/shared landing and cleanup evidence exists;
- valid local/private terminal proof exists and is digest-bound;
- hosted/shared receipts do not reference local/private evidence directly;
- Proposal Program Delivery receipt validates with `actual_outcome: cleaned`;
- final lifecycle state is `git_clean_terminal`.

If any condition fails, report the lower actual outcome and the next owning
route instead of claiming `git_clean_terminal`.

## Final Response Contract

Return:

- parent program route outcomes;
- child packet outcome by packet;
- parent and child review, readiness, implementation, verification, closeout,
  archive, delivery, cleanup, and terminal receipt paths;
- validators run and pass/fail results;
- Proposal Program Delivery profile, receipt, and evidence index paths;
- Change delivery route selected and why;
- Change receipt path;
- branch landing authorization and landing evidence paths;
- branch cleanup authorization and cleanup evidence paths;
- terminal local evidence manifest path;
- final `git_clean_terminal` verdict;
- files changed by route;
- blockers or non-blocking warnings;
- exact next owning route, if any.

## Self-Critique Before Final Answer

Before reporting success, check:

- Did every child packet retain target-owned receipts and archive metadata?
- Did parent evidence only summarize child outcomes by path/digest?
- Were all strict implementation gates used before implementation rather than
  as generic closeout/archive substitutes?
- Were delivery receipt validators run against concrete receipt paths?
- Was terminal evidence written with concrete arguments and then validated by
  manifest?
- Did hosted/shared evidence stay separate from local/private terminal
  evidence?
- Did any generated output get edited by hand?
- Is the claimed final outcome supported by current git refs and clean
  worktree state after the last mutation?
