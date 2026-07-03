# Executable Implementation Prompt

implementation_prompt_id: run-program-clean-delivery-cleanup-disposition-implementation-prompt-2026-07-03
proposal_path: .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-cleanup-disposition
route_id: run-packet-implementation
status: operational-aid

This prompt is an implementation aid for the accepted proposal packet. It does
not approve execution, widen promotion scope, create authority, replace packet
manifests, close out the packet, archive the packet, mutate Git refs, delete
residue, publish generated outputs, or claim clean delivery.

## Generation Basis

- `release_state`: `pre-1.0`
- `change_profile`: `atomic`
- packet review verdict: `accepted`
- implementation prompt authorization: `yes`
- reviewed packet digest:
  `sha256:7299754b15b98ad89a3daa870dbb496d8fc06023da2df4be74608ca8085a73c1`
- prompt bundle:
  `sha256:b2fc27e8e75f5e52971887e5bc440f17335fc4fe4303a630afa7148eea53efa6`

The implementation route must re-run the mandatory preflight gates before any
durable edit. Treat proposal-local files, generated prompts, generated
outputs, dashboards, host/tool/chat state, model memory, and parent summaries
as non-authoritative.

## Mandatory Preflight

Before editing durable targets, re-read the repository ingress, constitutional
kernel, proposal manifests, source-of-truth map, target architecture,
implementation plan, acceptance criteria, validation plan, implementation-grade
completeness review, proposal review, and strict pre-integration architecture
review.

Run from the repository root:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-cleanup-disposition --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-cleanup-disposition
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-cleanup-disposition
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-cleanup-disposition --require-implementation-authorization --print-digest
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-cleanup-disposition/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-cleanup-disposition --mode pre-integration-architecture-review --require-pass
```

Refuse implementation unless all gates pass, the packet status remains
`accepted`, the accepted review digest is fresh, `verdict: pass` remains on
the implementation-grade completeness review, and
`open_blocking_findings_count: 0`.

## Approved Promotion Targets

Edit only these durable targets when edits are required:

- `.octon/framework/capabilities/runtime/skills/remediation/closeout-worktree/`
- `.octon/framework/assurance/runtime/_ops/scripts/classify-proposal-worktree-hygiene.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh`
- `.octon/framework/assurance/runtime/_ops/scripts/validate-closeout-worktree-wrapper.sh`
- `.octon/framework/assurance/runtime/_ops/tests/`

After durable edits land, create or update only these packet-local
implementation receipts:

- `support/implementation-run.md`
- `support/implementation-conformance-review.md`
- `support/post-implementation-drift-churn-review.md`
- `support/validation.md`

Retained validation evidence must live outside `inputs/**`, preferably under:

- `.octon/state/evidence/validation/proposals/run-program-clean-delivery-cleanup-disposition/`

## Out Of Scope

Do not edit proposal status, archive state, closeout state, generated/effective
outputs, support-target declarations, branch state, hosted refs, parent program
delivery state, sibling packets, sibling packet receipts, delivery receipt
completion logic, Change closeout reconciliation logic, architecture-review
freshness logic, validator chain hardening, or test hermeticity work outside
the cleanup-disposition envelope.

Do not edit `.octon/framework/assurance/runtime/_ops/scripts/validate-run-program-clean-delivery.sh`
unless this packet is revised to add that script as an approved promotion
target. If implementation cannot satisfy an acceptance criterion without
changing an unapproved durable file, stop and report `needs-packet-revision`.

Do not change `proposal.yml#status`; leave it as `accepted`. The later
promotion lifecycle route owns any implemented-status rewrite.

## Current Repository Starting Points

The live repository already contains most of the cleanup-disposition skeleton.
Before changing any target, inspect current diffs under the approved target
paths and preserve user or earlier-agent work.

Reuse these existing surfaces before adding new fields, helpers, validators,
or routes:

- `closeout-worktree/SKILL.md` already consumes proposal lifecycle classifier
  partitions: `publishable_changes`, `publishable_closeout_evidence`,
  `cleanup_safe_local_residue`, `protected_retained_evidence`,
  `protected_active_control_state`, and
  `manual_review_foreign_ambiguous_unsafe_or_user_owned`.
- `closeout-worktree/SKILL.md` already states that these partitions are
  routing evidence only and do not authorize deletion, cleanup, publication,
  promotion, archive, closeout, branch cleanup, Git mutation, or `cleaned`
  claims.
- `closeout-worktree/SKILL.md` already documents
  `proposal_program_handoff_authorization`,
  `proposal_program_parent_handoff_authorization`,
  `repo_hygiene_cleanup_actions_performed: false`,
  `worktree_terminal_state`, `residue_routing_class`, and
  `disposition_complete_with_retained_residue`.
- `classify-proposal-worktree-hygiene.sh` already emits
  `worktree_hygiene_foreign_fingerprint`,
  `worktree_hygiene_partition_authority`,
  `worktree_hygiene_handoff_required`,
  `worktree_hygiene_required_return_evidence`, and the classifier partition
  lists.
- `cleanup-local-run-artifacts.sh` already defaults to dry-run, protects
  tracked and referenced files, separates cleanup candidates from protected and
  manual-review residue, and requires `--confirm` or a validating
  `repo-hygiene-cleanup-authorization-v1` receipt before deletion.
- `validate-closeout-worktree-wrapper.sh` already validates
  `closeout-worktree-report-v1` structure, residue routing classes,
  repo-hygiene delegation, retained residue, terminal states, handoff
  authorization digests, foreign fingerprints, exact path-set matching, and
  detection-only cleanup denial.
- Existing tests include `test-classify-proposal-worktree-hygiene.sh`,
  `test-cleanup-local-run-artifacts.sh`,
  `test-closeout-worktree-wrapper.sh`, and
  `test-proposal-lifecycle-residue-fingerprint.sh`.

If a target already satisfies an acceptance criterion, preserve it and record
that coverage in `support/implementation-run.md` and `support/validation.md`
instead of duplicating logic.

## Target End State

Clean-delivery cleanup starts with classified worktree residue. Cleanup,
preservation, and terminal claims are allowed only after the exact residue has
an authority-backed disposition and a validating receipt or return report.

The durable surfaces must make these claims machine-checkable:

- worktree residue is classified before cleanup, preservation, archive,
  closeout, or clean-terminal claims;
- classifier output exposes whether each residue group requires disposition,
  can route to repo-hygiene cleanup, must be preserved, is protected, or is
  foreign/manual-review;
- closeout-worktree reports bind to the classifier output ref, classifier
  digest, foreign fingerprint, exact authorized path set, and non-mutating
  disposition before preservation can unblock lifecycle closeout;
- cleanup-safe local residue routes to `repo-hygiene-cleanup` or the cleanup
  helper with explicit authorization, never to wrapper-owned deletion;
- protected retained evidence and active control state are never deleted by
  detection-only cleanup and never satisfy `git_clean_terminal`;
- repeated cleanup preflight blockers stop blind retry loops and surface the
  exact blocker evidence, classifier ref, fingerprint, path set, and next
  canonical route;
- generated outputs, proposal-local inputs, host state, chat, dashboards,
  model memory, parent summaries, and tool availability never authorize
  cleanup, preservation, archive, publication, closeout, or `cleaned` claims.

## Ordered Workstreams

1. Inventory cleanup-disposition surfaces.

   Run targeted reconnaissance:

   ```sh
   rg -n "worktree_hygiene_|publishable_changes|cleanup_safe_local_residue|protected_retained_evidence|protected_active_control_state|manual_review_foreign|foreign_fingerprint|proposal_program_handoff_authorization|proposal_program_parent_handoff_authorization|repo_hygiene_cleanup_actions_performed|cleanup_authorization|disposition_complete_with_retained_residue|detection_is_deletion_authority|worktree_terminal_state|residue_routing_class" .octon/framework/capabilities/runtime/skills/remediation/closeout-worktree .octon/framework/assurance/runtime/_ops/scripts/classify-proposal-worktree-hygiene.sh .octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh .octon/framework/assurance/runtime/_ops/scripts/validate-closeout-worktree-wrapper.sh .octon/framework/assurance/runtime/_ops/tests
   ```

   Record which acceptance criteria are already satisfied by current code and
   tests. Reuse existing report fields and validator helpers.

2. Complete classifier disposition semantics.

   Extend `classify-proposal-worktree-hygiene.sh` only where current output is
   insufficient. The classifier must keep read-only behavior and continue to
   emit `octon-proposal-worktree-hygiene-v1`.

   The classifier output must make these facts explicit enough for callers and
   validators to consume:

   - exact partition counts and path lists for owned, in-scope, publishable,
     cleanup-safe, protected retained evidence, protected active control state,
     manual-review, foreign, ambiguous, unsafe, and user-owned residue;
   - `worktree_hygiene_foreign_fingerprint` computed from the blocker path
     set used by closeout-worktree handoff authorization;
   - `worktree_hygiene_handoff_required`, `worktree_hygiene_handoff_route`,
     `worktree_hygiene_required_return_evidence`, and `next_route_condition`
     when residue blocks lifecycle progress;
   - a clear partition authority statement that detection does not authorize
     deletion, cleanup, publication, promotion, archive, closeout, branch
     cleanup, Git mutation, or `cleaned` claims.

   If new field names are required, keep them additive and update tests and
   wrapper validation in the same change.

3. Bind closeout-worktree return reports to classifier evidence.

   Update `closeout-worktree` docs and `validate-closeout-worktree-wrapper.sh`
   only where gaps remain so a cleanup-disposition return report must prove:

   - `residue_classification_ref` and classifier output digest resolve to the
     retained classifier evidence;
   - `authorized_foreign_fingerprint` matches the classifier output;
   - `authorized_paths` exactly match the selected candidate
     `boundaries.include_paths`;
   - non-mutating preservation uses
     `preserve-and-exclude-from-child-closeout-blocking` or
     `preserve-and-exclude-from-lifecycle-closeout-blocking` as appropriate;
   - `child_closeout_authority_preserved: true`,
     parent summary or parent evidence does not replace child evidence, and
     all forbidden actions are false;
   - reports that retain residue use
     `worktree_terminal_state: disposition_complete_with_retained_residue`
     when appropriate and never claim `git_clean_terminal` while protected,
     generated, input, control, or unresolved residue remains.

4. Make cleanup authorization explicit.

   Tighten `cleanup-local-run-artifacts.sh` and its tests only where gaps
   remain:

   - dry-run remains the default;
   - cleanup candidates, protected referenced paths, active run state,
     retained evidence, generated authority, generated run-health projection,
     proposal inputs, terminal local evidence, and manual-review residue stay
     separately reported;
   - `--authorize` emits a `repo-hygiene-cleanup-authorization-v1` receipt only
     for the exact current cleanup-safe candidate set;
   - `--authorization` rejects stale, mismatched, denied, protected,
     referenced, generated-authority, input-surface, terminal-local-evidence,
     build-to-delete, or manual-review paths;
   - `--cleanup-path` limits cleanup to authorized candidates and cannot widen
     cleanup beyond the validated path set.

5. Stop blind cleanup retry loops.

   Add or adjust the smallest durable surface in the approved targets so a
   repeated cleanup preflight blocker with the same classifier fingerprint does
   not keep cycling through cleanup. The implementation must surface the exact
   blocker evidence, classifier ref, fingerprint, candidate path set, and next
   canonical route, normally `closeout-worktree` or `repo-hygiene-cleanup`
   depending on the classifier partition.

   If the only place to enforce this loop break is an unapproved validator or
   lifecycle runner, stop and report `needs-packet-revision` with the required
   target path.

6. Add positive and negative controls.

   Extend existing shell tests under
   `.octon/framework/assurance/runtime/_ops/tests/`.

   Required positive controls:

   - `.DS_Store` or equivalent local filesystem metadata is classified as
     cleanup-safe local residue and remains deletion-blocked without
     authorization;
   - generated health/read-model files route to generator-owned or
     manual-review handling, not blind deletion;
   - protected state/control residue and retained evidence are protected or
     manual-review, never cleanup-safe;
   - foreign tracked and untracked changes block lifecycle progress and carry
     a stable fingerprint;
   - closeout-worktree report validation accepts a matching classifier ref,
     digest, foreign fingerprint, exact authorized path set, and non-mutating
     preserve/exclude disposition;
   - authorized disposable local artifacts can be removed only through
     `--confirm` or a validating cleanup authorization receipt.

   Required negative controls:

   - detection-only classifier output cannot authorize deletion;
   - protected state/control/evidence residue is not deleted by cleanup
     helpers;
   - proposal input files, generated authority, terminal local evidence,
     build-to-delete evidence, and referenced evidence cannot be authorized by
     generic cleanup;
   - foreign tracked changes route to preservation, closeout-worktree, or
     escalation and cannot be hidden under a clean-terminal claim;
   - closeout-worktree report validation rejects stale classifier digests,
     mismatched foreign fingerprints, path-set drift, missing non-mutating
     flags, child-authority substitution, parent-summary substitution, and any
     forbidden action marked true;
   - repeated cleanup preflight blockers do not cycle blindly and must expose
     blocker evidence plus the next canonical route.

7. Record retained evidence and packet-local receipts.

   Create retained validation evidence under
   `.octon/state/evidence/validation/proposals/run-program-clean-delivery-cleanup-disposition/`
   with command logs or compact validation records that include command, cwd,
   start time, end time, exit code, and bounded output excerpts.

   Create or update:

   - `support/implementation-run.md`
   - `support/validation.md`
   - `support/implementation-conformance-review.md`
   - `support/post-implementation-drift-churn-review.md`

   `support/implementation-run.md` must summarize durable edits, list touched
   promotion targets, state which acceptance criteria were already satisfied,
   cite validators run, and confirm no unapproved target was edited.

   `support/implementation-conformance-review.md` must include the sections
   required by `validate-proposal-implementation-conformance.sh`: Blockers,
   Checked Evidence, Promotion Target Coverage, Implementation Map Coverage,
   Validator Coverage, Generated Output Coverage, Governed Mechanism
   Integration Coverage, Rollback Coverage, Downstream Reference Coverage,
   Exclusions, and Final Closeout Recommendation. It must conclude with
   `verdict: pass` and `unresolved_items_count: 0` before implementation can
   be considered complete.

   `support/post-implementation-drift-churn-review.md` must include the
   sections required by `validate-proposal-post-implementation-drift.sh`:
   Blockers, Checked Evidence, Backreference Scan, Naming Drift, Generated
   Projection Freshness, Governed Mechanism Integration Coverage, Manifest And
   Schema Validity, Repo-Local Projection Boundaries, Target Family Boundaries,
   Churn Review, Validators Run, Exclusions, and Final Closeout
   Recommendation. It must conclude with `verdict: pass` and
   `unresolved_items_count: 0` before closeout or archive can be considered.

## Validation

Run from the repository root and retain outputs in `support/validation.md` or
the retained evidence root:

```sh
bash .octon/framework/assurance/runtime/_ops/tests/test-classify-proposal-worktree-hygiene.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-cleanup-local-run-artifacts.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-closeout-worktree-wrapper.sh
bash .octon/framework/assurance/runtime/_ops/tests/test-proposal-lifecycle-residue-fingerprint.sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-closeout-worktree-wrapper.sh
bash .octon/framework/assurance/runtime/_ops/scripts/cleanup-local-run-artifacts.sh --dry-run
bash .octon/framework/assurance/runtime/_ops/scripts/classify-proposal-worktree-hygiene.sh --target .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-cleanup-disposition --lifecycle proposal-packet
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-standard.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-cleanup-disposition --skip-registry-check
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architecture-proposal.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-cleanup-disposition
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-readiness.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-cleanup-disposition
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-review-gate.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-cleanup-disposition --require-implementation-authorization --print-digest
bash .octon/framework/assurance/runtime/_ops/scripts/validate-architectural-review-receipts.sh --receipt .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-cleanup-disposition/support/pre-integration-architecture-review.yml --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-cleanup-disposition --mode pre-integration-architecture-review --require-pass
```

After implementation, create the required post-implementation receipts and run:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-implementation-conformance.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-cleanup-disposition
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-post-implementation-drift.sh --package .octon/inputs/exploratory/proposals/architecture/run-program-clean-delivery-cleanup-disposition
```

If a listed test already covers a required positive or negative control, cite
the exact test case in `support/validation.md`. If a named command is stale,
run the closest existing validator that proves the same claim and record the
exact command and rationale.

## Delegation Boundaries

No delegation is required. If the implementation runner explicitly delegates,
use disjoint write scopes only:

- closeout-worktree documentation and report contract;
- classifier and cleanup helper scripts;
- wrapper validator and shell fixtures;
- packet-local implementation receipts.

The orchestrator remains responsible for final integration and must not let a
delegated worker widen scope, edit sibling packets, mutate generated outputs
as authority, or delete unrelated state/control/evidence artifacts.

## Rollback

Rollback is limited to durable edits made under the declared promotion targets.
Revert classifier, cleanup helper, wrapper validator, closeout-worktree docs,
or test changes through a governed follow-up route, then rerun the proposal
review gate and both post-implementation validators. Packet-local evidence
should be superseded by a correction or rollback receipt, not silently
deleted.

Cleanup authorization receipts, closeout-worktree reports, retained validation
evidence, and local cleanup artifacts are evidence or residue, not rollback
authority. Clean, delete, preserve, or archive them only through the owning
governed route.

## Closeout Refusal Criteria

Refuse closeout, archive, cleanup, parent delivery completion, branch cleanup,
or `git_clean_terminal` claims from this implementation route. Also refuse
implementation completion if any prerequisite proposal review, strict
pre-integration architecture review, implementation-grade completeness review,
implementation conformance review, or post-implementation drift/churn review is
missing, stale, failing, or still requires clarification.
