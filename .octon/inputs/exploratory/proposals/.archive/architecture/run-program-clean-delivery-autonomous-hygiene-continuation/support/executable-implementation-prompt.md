# Executable Implementation Prompt

implementation_prompt_id: run-program-clean-delivery-autonomous-hygiene-continuation-implementation-prompt-2026-07-03
proposal_path: .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomous-hygiene-continuation
route_id: run-packet-implementation
status: operational-aid

This prompt is an implementation aid for the accepted child proposal packet. It
does not approve execution, widen promotion scope, create authority, replace
packet manifests, close out the packet, archive the packet, mutate Git refs,
delete residue, publish generated outputs, or claim clean delivery.

## Generation Basis

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- packet review verdict: `accepted`
- implementation prompt authorization: `yes`
- reviewed packet digest:
  `sha256:ae41f461c0c5493da6747a6132f64ffa269bb7c10e64b24dac1120a9a8e50d52`
- prompt bundle:
  `sha256:b2fc27e8e75f5e52971887e5bc440f17335fc4fe4303a630afa7148eea53efa6`

The implementation route must re-run the mandatory preflight gates before any
durable edit. Treat proposal-local files, generated prompts, generated
outputs, dashboards, host/tool/chat state, model memory, parent summaries, and
aggregate delivery receipts as non-authoritative.

## Mandatory Preflight

Before editing durable targets, re-read the repository ingress, constitutional
kernel, proposal manifests, source-of-truth map, target architecture,
implementation plan, acceptance criteria, validation plan, implementation-grade
completeness review, proposal review, and strict pre-integration architecture
review.

Run from the repository root:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomous-hygiene-continuation --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomous-hygiene-continuation
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomous-hygiene-continuation
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomous-hygiene-continuation --require-implementation-authorization --print-digest
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomous-hygiene-continuation/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomous-hygiene-continuation --mode pre-integration-architecture-review --require-pass
```

Refuse implementation unless all gates pass, the packet status remains
`accepted`, the accepted review digest is fresh, `verdict: pass` remains on
the implementation-grade completeness review, and
`open_blocking_findings_count: 0`.

## Approved Promotion Targets

Edit only these durable targets when edits are required:

- `.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/`
- `.octon/framework/capabilities/runtime/skills/operations/proposal-program-delivery/`
- `.octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs`
- `.octon/framework/assurance/runtime/_ops/scripts/classify-proposal-worktree-hygiene.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-closeout-worktree-wrapper.sh`
- `.octon/framework/assurance/runtime/_ops/tests/`

After durable edits land, create or update only these packet-local
implementation receipts:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md`

Retained validation evidence must live outside `inputs/**`, preferably under:

- `.octon/state/evidence/validation/proposals/run-program-clean-delivery-autonomous-hygiene-continuation/`

## Out Of Scope

Do not edit proposal status, archive state, closeout state, generated/effective
outputs, support-target declarations, branch state, hosted refs, parent program
delivery state, sibling packets, sibling packet receipts, unrelated generated
run-health projections, delivery receipt completion logic, Change closeout
reconciliation logic, proposal-program workflow metadata, profile schemas, or
validators outside the approved target list.

Do not edit `.octon/framework/assurance/runtime/_ops/scripts/validate-run-program-clean-delivery.sh`,
`.octon/framework/orchestration/runtime/workflows/meta/proposal-program-delivery/`,
or `.octon/framework/product/contracts/proposal-program-delivery-profile-v1.schema.json`
unless this packet is revised to add those paths as approved promotion targets.
If implementation cannot satisfy an acceptance criterion without changing an
unapproved durable file, stop and report `needs-packet-revision`.

Do not change `proposal.yml#status`; leave it as `accepted`. The later
promotion lifecycle route owns any implemented-status rewrite.

## Current Repository Starting Points

Before changing any target, inspect current diffs under the approved target
paths and preserve user or earlier-agent work. Reuse existing surfaces before
adding new fields, helpers, validators, or routes.

Known existing surfaces:

- `closeout-worktree/SKILL.md` already consumes proposal lifecycle classifier
  partitions and records that classification is routing evidence only.
- `closeout-worktree/SKILL.md` already documents
  `proposal_program_handoff_authorization`,
  `proposal_program_parent_handoff_authorization`,
  `repo_hygiene_cleanup_actions_performed: false`,
  `worktree_terminal_state`, `residue_routing_class`, and
  `disposition_complete_with_retained_residue`.
- `classify-proposal-worktree-hygiene.sh` already emits
  `worktree_hygiene_verdict`, blocker class, owned/in-scope/foreign counts,
  cleanup-safe count, protected retained-evidence count, protected control
  count, manual-review count, `worktree_hygiene_foreign_fingerprint`,
  handoff route, required return evidence, and classifier partitions.
- `validate-closeout-worktree-wrapper.sh` already validates proposal-program
  handoff and parent handoff authorizations, classifier output refs and
  digests, authorized fingerprints, exact authorized path sets, non-mutating
  preserve/exclude dispositions, child authority preservation, parent-summary
  non-substitution, and forbidden action falsehood.
- `lifecycle_program.rs` already has program blocker, interaction return,
  worktree hygiene, recovery budget, and repeated blocker logic plus fixture
  tests around closeout-worktree returns and cleanup-residue continuation.

If a target already satisfies an acceptance criterion, preserve it and record
that coverage in `support/implementation-run.md` and `support/validation.md`
instead of duplicating logic.

## Target End State

Recoverable closeout hygiene and ownership blockers route through a
target-owned recovery path before the program pauses for a human. The explicit
continuation case is:

- cleanup-safe count is `0`;
- no deletion, reset, staging, commit, push, branch cleanup, archive,
  publication, or ref mutation is required;
- a non-mutating preserve/exclude report binds the current classifier output,
  current residue fingerprint, exact authorized path set, child authority
  preservation, parent-summary non-substitution, and forbidden action falsehood;
- the blocked child or parent gate is rerun after recovery evidence is emitted;
- lifecycle execution continues automatically only after that rerun gate passes.

Human review remains required for destructive cleanup, protected refs,
external credentials, unpreservable foreign residue, ambiguous residue, unsafe
residue, stale recovery evidence, and conflicting operator instructions.

## Ordered Workstreams

1. Inventory current coverage.

   Run targeted reconnaissance across the approved targets:

   ```sh
   rg -n "worktree_hygiene_|cleanup_safe|foreign_fingerprint|proposal_program_handoff_authorization|proposal_program_parent_handoff_authorization|preserve-and-exclude|artifact-ownership-unclear|worktree-hygiene-blocked|parent-worktree-disposition-required|lifecycle-residue-cleanup-needed|lifecycle_interaction_return|rerun|gate|resume|continue" .octon/framework/capabilities/runtime/skills/remediation/closeout-worktree .octon/framework/capabilities/runtime/skills/operations/proposal-program-delivery .octon/framework/engine/runtime/crates/kernel/src/lifecycle_program.rs .octon/framework/assurance/runtime/_ops/scripts/classify-proposal-worktree-hygiene.sh .octon/framework/assurance/runtime/_ops/scripts/validate-closeout-worktree-wrapper.sh .octon/framework/assurance/runtime/_ops/tests
   ```

   Record which acceptance criteria are already satisfied by current code and
   tests. Reuse existing report fields and validator helpers.

2. Complete recoverable blocker taxonomy.

   Ensure `artifact-ownership-unclear`, `worktree-hygiene-blocked`,
   stale-fingerprint closeout blockers, `parent-worktree-disposition-required`,
   `lifecycle-residue-cleanup-needed`, and equivalent closeout ambiguity route
   to a target-owned recovery path only when the classifier and current
   receipts prove the case is recoverable.

   The routing decision must distinguish recoverable non-mutating
   preserve/exclude cases from human-required cases:

   - recoverable: cleanup-safe count `0`, exact current fingerprint bound,
     exact authorized path set, no deletion required, and a valid
     closeout-worktree return can preserve/exclude from the named blocker;
   - human-required: destructive cleanup, protected refs, external
     credentials, stale recovery evidence, unpreservable foreign residue,
     ambiguous residue, unsafe residue, unresolved ownership, or conflicting
     instructions.

3. Bind recovery evidence to current classifier output.

   Extend `classify-proposal-worktree-hygiene.sh`,
   `closeout-worktree/SKILL.md`, and
   `validate-closeout-worktree-wrapper.sh` only where current behavior is
   insufficient. The recovery evidence must prove:

   - classifier output ref and digest resolve to retained classifier evidence;
   - current residue fingerprint matches the classifier output;
   - cleanup-safe count is explicitly recorded and can be `0`;
   - residue classes cover owned, in-scope, retained evidence,
     generated/publication residue, foreign, ambiguous, unsafe, and
     manual-review classes;
   - authorized paths exactly match the candidate boundary path set;
   - disposition is one of the accepted non-mutating preserve/exclude
     dispositions for the child or lifecycle blocker;
   - `child_closeout_authority_preserved: true`;
   - parent summaries or aggregate receipts do not replace child-owned
     receipts;
   - all forbidden mutation, cleanup, archive, publication, branch cleanup,
     ref mutation, and `cleaned` claims are false.

4. Rerun the blocked gate before continuation.

   Update `lifecycle_program.rs` and, if needed, the proposal-program delivery
   skill guidance so recoverable closeout hygiene returns do not merely suppress
   a blocker. After recovery evidence is emitted, the owning child or parent
   gate that produced the blocker must be rerun from current repository state.

   Required behavior:

   - a matching, fresh closeout-worktree return may clear the blocker only when
     the rerun gate passes;
   - the rerun-gate command, target, result, evidence ref, classifier ref,
     classifier digest, current fingerprint, and return ref are retained in
     child-owned or program-owned evidence;
   - stale fingerprints, mismatched path sets, stale returns, missing gate
     reruns, or failed gate reruns keep the lifecycle blocked with the owning
     next route;
   - parent summaries, compact blocker-remediation summaries, delivery
     readiness projections, or aggregate receipts cannot satisfy the rerun
     gate or child-owned receipts;
   - after a passing rerun gate, sequential lifecycle execution continues to
     the next runnable child or parent route without a chat stop.

5. Stop unsafe retries.

   Ensure repeated blockers do not loop through cleanup or rerun routes without
   fresh evidence. Repeated blocker handling must surface the blocker class,
   current fingerprint, previous fingerprint, route evidence, candidate path
   set, and next owning route. Do not continue when the repeated blocker is
   destructive, ambiguous, unsafe, protected, stale, or unclassified.

6. Add positive and negative controls.

   Extend the smallest relevant existing tests under
   `.octon/framework/assurance/runtime/_ops/tests/` and Rust tests in
   `lifecycle_program.rs`.

   Required positive controls:

   - cleanup-safe-count-zero non-mutating preserve/exclude fixture continues
     automatically after the rerun gate passes;
   - closeout-worktree return binds current classifier output, digest,
     fingerprint, authorized paths, and forbidden action falsehood;
   - rerun-gate continuation fixture proves the blocked child or parent gate
     passed before downstream lifecycle execution resumes;
   - foreign residue that is preservable and explicitly authorized routes
     preserve-only without deletion.

   Required negative controls:

   - stale fingerprint preserve/exclude return fails;
   - stale recovery evidence fails;
   - missing rerun-gate proof fails;
   - failed rerun gate fails;
   - destructive cleanup without authority fails;
   - protected refs or protected active control state fail;
   - external credentials fail;
   - unpreservable foreign residue, ambiguous residue, unsafe residue, and
     conflicting instructions require human review;
   - parent summary, aggregate receipt, compact blocker-remediation receipt, or
     generated output substitution fails when used as child-owned evidence.

7. Write implementation receipts.

   Create `support/implementation-run.md` describing:

   - exact durable files changed;
   - acceptance criteria satisfied by existing code versus new edits;
   - validators and tests run;
   - retained evidence refs;
   - authority-boundary checks;
   - why no unapproved promotion target was edited, or `needs-packet-revision`
     if one was required.

   Create `support/implementation-conformance-review.md` and
   `support/post-implementation-drift-churn-review.md` after implementation.
   Both receipts must refuse closeout/archive claims until their validators
   pass.

## Validators

Run the focused implementation checks from the repository root:

```sh
bash .octon/framework/assurance/runtime/_ops/tests/test-classify-proposal-worktree-hygiene.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-closeout-worktree-wrapper.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-program-delivery.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-validate-proposal-program-delivery-workflow.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-run-program-clean-delivery-validator.sh
cargo test --manifest-path .octon/framework/engine/runtime/crates/Cargo.toml -p octon_kernel lifecycle_program
```

Then run packet and post-implementation gates:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomous-hygiene-continuation --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomous-hygiene-continuation
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomous-hygiene-continuation
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomous-hygiene-continuation --require-implementation-authorization
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomous-hygiene-continuation/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomous-hygiene-continuation --mode pre-integration-architecture-review --require-pass
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomous-hygiene-continuation
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-autonomous-hygiene-continuation
```

If broad tests are too expensive, run the focused checks above first and record
the omitted checks, rationale, and residual risk in `support/validation.md`.

## Retained Evidence

Record implementation evidence in:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md`

Retain validator logs, fixture outputs, and any current-fingerprint
preserve/exclude proof under:

- `.octon/state/evidence/validation/proposals/run-program-clean-delivery-autonomous-hygiene-continuation/`

Evidence must distinguish behavior proof, boundary proof, architecture or
placement proof, runtime authorization proof, generated-output freshness proof
when applicable, and compact validator-log proof. Compact logs must record
command, cwd, start time, end time, exit code, bounded excerpts, and retained
full-log digest when available.

## Rollback

Rollback reverts or supersedes only this child packet's durable promotion
targets through a governed follow-up route. Any newly written retained evidence
is evidence-only and must be superseded or cleaned only through an explicit
governed cleanup route. Do not delete retained evidence, generated outputs,
control state, branch refs, or proposal packet lineage as rollback from this
implementation route.

## Closeout Refusal Criteria

Refuse closeout and archive claims from this route. Do not claim parent
promotion, program delivery completion, generated publication freshness, Change
closeout, branch cleanup, final sync, terminal proof, `cleaned`, or packet
archive.

Refuse implementation or stop with `needs-packet-revision` when:

- any mandatory preflight gate fails;
- a required implementation edit falls outside the approved promotion targets;
- recovery would require deletion, reset, staging, commit, push, branch
  cleanup, archive, publication, ref mutation, external credentials, or
  protected-state mutation;
- rerun-gate proof cannot be retained;
- conformance or post-implementation drift/churn validators fail.
