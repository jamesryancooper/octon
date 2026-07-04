---
name: closeout-worktree
description: >
  Dirty-worktree closeout wrapper. Inventories and partitions multiple local
  change sets, then routes each coherent candidate through singular
  closeout-change execution without replacing the Change default work unit.
license: MIT
compatibility: Designed for Claude Code and similar AI coding assistants.
metadata:
  author: Octon Framework
  created: "2026-05-21"
  updated: "2026-05-21"
skill_sets: [executor, collaborator, guardian, integrator]
capabilities: [external-dependent, stateful, safety-bounded, self-validating]
allowed-tools: Read Glob Grep Bash(git status *) Bash(git diff *) Bash(git rev-parse *) Bash(git branch *) Bash(git ls-files *) Bash(bash .octon/framework/assurance/runtime/_ops/scripts/classify-change-closeout-residue.sh *) Bash(bash .octon/framework/assurance/runtime/_ops/scripts/validate-closeout-worktree-wrapper.sh *) Write(/.octon/state/evidence/validation/analysis/*) Write(/.octon/state/evidence/runs/skills/*)
---

# Closeout Worktree

Dirty-worktree wrapper for decomposing multiple local change sets into
singular `closeout-change` runs.

## When to Use

Use this skill when the operator asks to close out a worktree, close out all
local changes, or resolve a dirty repository state that may contain more than
one coherent Change.

Use `closeout-change` directly when the current scope is already one coherent
Change. Use `closeout-pr` only after a singular Change route resolves to
`branch-pr`.

## Core Workflow

1. **Bind Constraints** — Load the default work unit policy, Change Closeout
   State Machine, Git/worktree autonomy contract, and `closeout-change`
   contract.
2. **Inventory Worktree** — Capture branch, HEAD, `main`, `origin/main`,
   staged, unstaged, untracked, ignored, branch, and remote state.
3. **Classify Residue** — Run the read-only residue classifier and classify
   staged, unstaged, untracked, ignored, generated, host-projection, evidence,
   release, input-surface, repo-hygiene cleanup candidates, protected
   referenced paths, manual-review paths, and branch residue. For proposal
   packet or proposal program closeout, consume
   `classify-proposal-worktree-hygiene.sh` partitions explicitly:
   `publishable_changes`, `publishable_closeout_evidence`,
   `cleanup_safe_local_residue`, `protected_retained_evidence`,
   `protected_active_control_state`, and
   `manual_review_foreign_ambiguous_unsafe_or_user_owned`. These partitions
   are routing evidence only; they do not authorize deletion, cleanup,
   publication, promotion, archive, closeout, branch deletion, or a `cleaned`
   claim.
   When invoked from a proposal-program
   `lifecycle-interaction-request-v1`, treat the request, its basis receipt,
   classifier output ref and digest, foreign fingerprint, include/exclude
   paths, and required return evidence as non-authorizing handoff context.
   The wrapper may route a coherent candidate to `closeout-change`, but the
   request never replaces child closeout receipts, child validation,
   archive authorization, or child lifecycle outcomes.
   When all blocker paths are proven outside the child/route write scope or
   covered by an explicit handoff authorization, the wrapper may return a
   non-mutating `closeout-worktree-report-v1` plus
   `lifecycle-interaction-return-v1` that records
   `proposal_program_handoff_authorization`. When a parent
   `cleanup-lifecycle-residue` handoff has explicit operator authorization,
   the wrapper may instead record
   `proposal_program_parent_handoff_authorization` proving the cleanup receipt
   digest, any cleanup helper digests recorded by that cleanup receipt,
   classifier digest, foreign fingerprint, exact authorized path set, and
   non-mutating disposition
   `preserve-and-exclude-from-lifecycle-closeout-blocking`. These reports may
   preserve and exclude foreign paths from the named lifecycle blocker only;
   they must not stage, delete, reset, commit, publish, archive, branch-clean,
   or claim `cleaned` for those paths.
4. **Partition Candidate Changes** — Group residue into candidate Change
   scopes by intent, touched paths, branch identity, receipt references,
   validation requirements, and operator instructions. When grouping is
   unambiguous, partition autonomously; do not ask the operator to name the
   first candidate merely because multiple candidates exist. Assign every
   candidate a `residue_routing_class`: `publishable_change`,
   `publishable_closeout_evidence`, `local_private_retained`,
   `foreign_manual_review`, `unsafe`, or `ambiguous`.
5. **Resolve Ambiguity** — Ask or stop when ownership, grouping, target
   outcome, route, validation floor, cleanup authority, or destructive action
   would be ambiguous.
6. **Select One Candidate** — Choose exactly one coherent candidate Change for
   the next closeout attempt. Multiple candidates alone is not a blocker;
   stop before delegation only when the selected candidate has a
   candidate-keyed blocker.
7. **Delegate Singular Closeout** — Route the selected candidate through
   `closeout-change` with explicit include/exclude paths, route hints, target
   outcome, and receipt refs when known. If the operator only asked to close out
   the worktree and did not explicitly request a narrower outcome, pass
   `target_lifecycle_outcome: cleaned` to each safely separable candidate. For
   wrapper-level closeout this targets `git_clean_terminal` when policy allows;
   singular `closeout-change` `cleaned` remains route-bound.
   For branch-no-pr landing, the delegated `closeout-change` run must own
   hosted preflight, governed landing authorization, hosted mutation, and
   rollback evidence, including the governed helper rerun path when sandbox,
   provider, host, remote, fetch, push, or ref-write controls block mutation.
   For branch cleanup, the delegated `closeout-change` run must own governed
   cleanup authorization and any local or remote branch deletion. Terminal
   proof remains owned by the delegated `closeout-change` receipt: the wrapper
   may cite or summarize `terminal_current_state_proof_ref` only after that
   receipt proves landing evidence, final sync proof, cleanup authorization,
   cleanup disposition, rollback posture, and validation evidence, and only
   when the proof sink or receipt path is distinct from `landed_ref`.
   When the delegated run records git mutation permission diagnostics for
   fetch, checkout, branch-local commit, branch publication, hosted landing,
   final sync, branch cleanup, or local or remote branch deletion or pruning,
   the wrapper may summarize those diagnostics as routing evidence only. The
   delegated `closeout-change` run remains the owning rerun route and mutation
   authority boundary.
8. **Delegate Repo-Hygiene Residue** — When classification identifies eligible
   local Octon run/artifact residue, delegate it to `repo-hygiene-cleanup`
   using that feature's classify-first, receipt-backed helper route. The
   wrapper may record the classification, delegated run, authorization ref, and
   next-route condition, but `repo_hygiene_cleanup_actions_performed` must
   remain false because this wrapper did not delete anything.
9. **Delegate Fixture Retention Residue** — When classification identifies a
   temporary proposal fixture candidate from manifest-derived fields, delegate
   classification to `fixture-retention-closeout`. The wrapper may record the
   delegated retention receipt ref and treat the exact covered residue as
   `local_private_retained` only when
   `validate-fixture-retention-closeout-receipt.sh` validates the receipt,
   path-set digest, current git status digest, purpose, owner scope, freshness,
   and non-authority boundaries. The wrapper does not delete, archive, status
   mutate, publish, stage, commit, push, or clean fixture residue itself.
10. **Re-inventory** — After each delegated closeout attempt or delegated
   repo-hygiene cleanup, re-run inventory and classification before selecting
   another candidate. When the generic target is `cleaned` and the only new
   non-ignored residue is unambiguous closeout evidence under retained evidence
   roots, create the next candidate with `route_hint: closeout-change`,
   `target_lifecycle_outcome: cleaned`,
   `residue_routing_class: publishable_closeout_evidence`, and explicit
   include/exclude paths. Recursive final-branch operational evidence created
   by closeout itself must be written through
   `write-terminal-closeout-local-evidence.sh` under
   `.octon/state/evidence/local/terminal-closeout/<change-id>/` as
   digest-backed local-private terminal evidence and must not create another
   publishable closeout-evidence loop. Do not classify
   `closeout-worktree` skill run logs under
   `.octon/state/evidence/runs/skills/closeout-worktree/**` as publishable
   closeout evidence.
11. **Repeat Or Stop** — Continue selecting and delegating one candidate at a
   time while coherent candidates remain. Stop only when every candidate is
   closed, retained, blocked, escalated, deferred, or foreign with evidence and
   the wrapper can truthfully report a `worktree_terminal_state`, or when the
   next selected candidate has a candidate-keyed blocker.
12. **Wrapper Report** — Record the final worktree disposition: closed
    Changes, retained candidates, blocked or escalated items, evidence refs,
    repo-hygiene classification refs, delegated repo-hygiene cleanup refs,
    repo-hygiene cleanup authorization refs when available, detached worktree
    cleanup safety proof when applicable, `retained_state_report`,
    `worktree_terminal_state`, and next route condition. Also retain compact
    wrapper views when source evidence is available: `structured-receipt.yml`,
    `closeout-projection.yml`, optional `publication-summary.yml`, and
    `expanded-report-request.yml`. These views must cite the wrapper report,
    delegated `closeout-change` receipts, and retained evidence by digest. They
    do not replace candidate-owned Change receipts or wrapper validation
    evidence.

## Wrapper Evidence

Write wrapper reports as `schema_version: closeout-worktree-report-v1`. The
report must record the initial inventory, read-only residue classification,
observed candidate count, selected candidate, candidate boundaries,
orchestration iterations, delegated `closeout-change` evidence, retained
residue, `retained_state_report`, blockers, final candidate dispositions, final
inventory, `worktree_terminal_state`, and next-route condition.

`retained_state_report` must use the same row vocabulary as Change receipts:
delivered branch, route-owned delivery branch, dirty-anchor branches, retained
local branches, retained worktrees, retained required evidence, local-private
evidence, generated diagnostics, deleted residue, excluded residue,
manual-review residue, remote mutation status, archive authorization, and final
current-state proof. The wrapper may summarize only current target-owned
evidence or record `none`; the report does not authorize cleanup, branch
deletion, archive movement, generated publication, or terminal hygiene.

Every candidate must include `residue_routing_class` with exactly one of:
`publishable_change`, `publishable_closeout_evidence`,
`local_private_retained`, `foreign_manual_review`, `unsafe`, or `ambiguous`.
Only `publishable_change` and `publishable_closeout_evidence` may be delegated
to `closeout-change`. Only `local_private_retained` and
`foreign_manual_review` may support
`disposition_complete_with_retained_residue`, and only with candidate-keyed
retained evidence. `unsafe` and `ambiguous` always force
`worktree_terminal_state: nonterminal` with candidate-keyed blocker evidence.
Raw/private Octon paths normally cannot be reported as
`foreign_manual_review`. The only exception is a proposal-program handoff
candidate with `proposal_program_handoff_authorization` or
`proposal_program_parent_handoff_authorization` proving the exact classifier
output ref and digest, cleanup helper digest echoes when the parent cleanup
receipt records them, foreign fingerprint, authorized path set, non-mutating
preserved/excluded disposition, parent-summary non-substitution, child
authority preservation, and no forbidden mutation, archive, publication,
branch-cleanup, git-ref, or cleaned claim.

When a delegated candidate is blocked by a permission-sensitive git mutation,
the wrapper report may summarize the delegated diagnostic evidence, including
operation class, current and target refs when known, expected authorization
gate, likely sandbox, host, provider, remote, or ref-write blocker, and owning
rerun route. The summary does not authorize fetch, checkout, commit, push,
hosted landing, final sync, branch cleanup, local or remote branch deletion or
pruning, publication, closeout, or `cleaned`; the wrapper must report the
delegated lower actual outcome, blocker, deferred state, or next-route
condition.

Proposal-program handoff reports must include the delivery caller context that
caused the wrapper route: include paths, exclude paths, route hints, target
lifecycle outcome, validation floor, rollback posture, profile constraints,
source receipt refs and digests, readiness receipt ref and digest, classifier
output ref and digest when present, foreign fingerprint when present, and
required return evidence. The report may return candidate disposition,
delegated `closeout-change` refs, repo-hygiene routing refs, blockers, and
next-route conditions, but it must not satisfy child packet receipts, Change
receipts, archive authorization, generated-publication freshness, cleanup
authorization, branch cleanup, final sync, terminal proof, or `cleaned` claims.

Completed proposal-program lifecycle closeout may classify lifecycle-owned
input/archive moves, generated effective publication outputs, proposal
registry artifacts, publication evidence, and tracked extension control files
as `publishable_change` only when the candidate records
`lifecycle_closeout_authority` with completed-program proof refs,
`child_authority_preserved: true`,
`parent_summary_not_child_receipt: true`, and
`local_run_state_excluded: true`. This exception does not make proposal inputs
authoritative, does not transfer child-owned lifecycle receipt authority, and
does not permit raw execution state under
`.octon/state/control/execution/**`, `.octon/state/continuity/**`, or
local workflow evidence to be published as material Change content.

`worktree_terminal_state` must be one of:

- `git_clean_terminal`: no non-ignored staged, unstaged, untracked,
  retained-evidence, generated-effective, host-projection, state-control,
  release-version, or input-surface residue remains. Ignored local residue may
  remain only with foreign or retained evidence. Closed branch candidates must
  prove local `main` equals `origin/main` equals `landed_ref`, and source
  branch cleanup is completed with governed cleanup authorization.
  Proposal-program, generated-publication, archive, or correction-branch
  terminal claims must cite `terminal_current_state_proof_ref` evidence from the
  delegated singular Change. That evidence is retained proof only: it may
  remain in the local terminal sink after landing, final sync, cleanup
  authorization, cleanup disposition, rollback posture, and validation proof
  exist, but it does not replace the delegated Change receipt or authorize
  hosted mutation, branch cleanup, publication, archive, or `cleaned`. If
  post-primary branch-no-pr correction branches occurred, the delegated Change
  must also cite
  `correction_branch_aggregate_receipt_ref`. Ignored terminal sink residue
  under `.octon/state/evidence/local/terminal-closeout/<change-id>/` may remain
  only when its `terminal-closeout-local-evidence-v1` manifest validates by
  exact path, schema version, SHA-256 digest, `retained-evidence-only`
  non-authority classification, and live ref alignment.
- `disposition_complete_with_retained_residue`: every candidate is `closed`,
  `retained`, or `foreign` with authority-backed evidence, retained/foreign
  residue is classified as `local_private_retained` or
  `foreign_manual_review`, and Git-clean is not claimed. Ordinary untracked,
  source, generated, control, input, raw/private state, or host-projection
  residue cannot satisfy this terminal state.
- `nonterminal`: blocked, deferred, escalated, ambiguous, or unresolved
  delegated residue remains. A report must not claim `nonterminal` unless at
  least one candidate, repo-hygiene summary, blocker, deferred state,
  escalation, unsafe residue, deferred branch cleanup, or ambiguity is
  genuinely unresolved.

When repo-hygiene residue is present, the report should include
`repo_hygiene_classification_ref`,
`repo_hygiene_cleanup_ref`,
`repo_hygiene_cleanup_authorization_ref`,
`repo_hygiene_cleanup_outcome`,
`repo_hygiene_summary.cleanup_candidates`,
`repo_hygiene_summary.protected_referenced`,
`repo_hygiene_summary.manual_review`,
`repo_hygiene_cleanup_actions_performed: false`, and
`repo_hygiene_next_route_condition`. `repo_hygiene_cleanup_actions_performed`
must remain false; route actual cleanup to `repo-hygiene-cleanup` or a
singular route with its own cleanup authority.

For proposal packet closeout, map classifier partitions to wrapper candidates
without inventing a new route or status:

- `publishable_changes` may become a `publishable_change` candidate only when
  the paths are declared promotion targets for the scoped packet or program.
- `publishable_closeout_evidence` may become
  `publishable_closeout_evidence` only for child-owned support evidence in the
  scoped packet; parent program evidence, aggregate evidence, proposal-local
  notes, generated outputs, host state, chat, model memory, and tool
  availability do not satisfy child cleanup, worktree partitioning, or
  deletion authority.
- `cleanup_safe_local_residue` routes to `repo-hygiene-cleanup`; this wrapper
  records the route and must not delete it directly.
- `protected_retained_evidence` and `protected_active_control_state` route to
  retained or blocked disposition with candidate-keyed evidence and cannot be
  branch-cleaned or generic-cleaned from classifier output.
- `manual_review_foreign_ambiguous_unsafe_or_user_owned` forces
  `worktree_terminal_state: nonterminal` unless a later singular route records
  an authority-backed disposition for the exact candidate.

When stale detached Git worktrees are observed, the report must either retain
them with rationale or cite explicit worktree cleanup safety proof: detached
HEAD, clean worktree, no active branch, no open PR or branch ownership claim,
not the current worktree, and removal through Git worktree cleanup policy.

When the current dirty worktree is attached to a stale local branch candidate,
the wrapper may classify the branch as `source-dirty-anchor` and delegate a
singular `closeout-change` local-worktree retirement candidate. The wrapper
must inventory residue, classify include/exclude boundaries, and preserve or
route required evidence before any switch is attempted. It must not delete or
mark the branch `retired-stale`; only the delegated `closeout-change` receipt
may do that after no-unique-commit proof, blocker checks, branch-retirement
authorization, post-delete verification, and rollback notes exist.

Compact wrapper reporting uses the same structured artifact contract as
`closeout-change`. `closeout-projection.yml` is the default model-visible
wrapper view and must declare `model_visible_token_estimate <= 4000`. The
wrapper may cite compact delegated projections, but each closed candidate still
requires its singular completed `closeout-change` receipt. Missing, stale,
digest-mismatched, or authority-conflicting compact views fail closed and
require canonical wrapper report or delegated receipt inspection before a
concise worktree closeout claim is made. Validate compact view shape and
digests with
`.octon/framework/assurance/runtime/_ops/scripts/validate-structured-receipt-artifacts.sh`.

For every selected or delegated candidate, include explicit
`boundaries.include_paths` and `boundaries.exclude_paths`. Multiple observed
change sets must be represented as multiple candidate records, not batched into
one Change receipt or used as a reason to block a safely separable selected
candidate.

Each new report must include an `iterations` list. Every delegated or closed
candidate must have an iteration that records pre-inventory, pre-classification,
selected candidate id, include/exclude paths, singular `closeout-change`
reference, `closeout-change` outcome, post-inventory, post-classification, and
the next selection reason. Every report must include
`final_candidate_dispositions` keyed by candidate id with final state `closed`,
`retained`, `blocked`, `escalated`, `deferred`, or `foreign`; closed
candidates must cite a singular `closeout-change` receipt under
`.octon/state/evidence/runs/skills/closeout-change/` whose
`closeout_outcome` is `completed`. A `published-branch` or
`branch-local-complete` receipt is a continued handoff and must not be reported
as `closed`; use `deferred`, `blocked`, or retained evidence instead.
For branch-no-pr `landed` or `cleaned` receipts, the singular receipt must
also prove governed `landing_authorization_ref`, hosted landing evidence,
exact source-SHA required check refs, source-branch integration, and local
`main`/`origin/main`/`landed_ref` alignment.
When a closed branch candidate claims completed source branch cleanup, the
singular receipt must cite a validating `branch-cleanup-authorization-v1`
receipt; cleanup-deferred landed branches must not be reported as cleaned.
Synthetic route labels are not sufficient closeout evidence.

Candidates with `retained`, `deferred`, or `foreign` disposition must have
candidate-keyed `retained_residue` entries covering their included boundary
paths. Candidates with `blocked`, `escalated`, or `ambiguous` disposition must
have candidate-keyed blocker evidence. Reports that use
`git_clean_terminal` must have no untracked retained evidence or other
non-ignored residue, and reports that cannot avoid emitting fresh repo-local
closeout evidence after the final delegated candidate must use
`disposition_complete_with_retained_residue` instead. Reports that supersede or
continue an earlier wrapper partition must reconcile every prior candidate as
still present, folded, retained, blocked, escalated, deferred, or foreign.
Reports whose final classifier summary shows ignored residue must include
retained or foreign ignored-residue evidence. Validate the report with
`.octon/framework/assurance/runtime/_ops/scripts/validate-closeout-worktree-wrapper.sh --report <path>`
before claiming worktree closeout.

Temporary proposal fixture candidates are not retained by wrapper judgment
alone. A candidate may use `residue_routing_class: local_private_retained` for
fixture residue only when it carries `fixture_retention_receipt_ref` pointing
to a validating `fixture-retention-closeout-receipt-v1` receipt. The receipt
must cover the exact included path set, must be current by retained path-set
digest and git status digest, must derive fixture identity from the fixture
manifest, must mark generated artifact refs as derived-only non-authority, and
must state that it does not authorize archive-ready or cleaned claims. Missing,
stale, digest-mismatched, owner-scope-mismatched, or overclaiming fixture
retention evidence fails closed.

## Boundaries

- Do not replace the default work unit; the unit remains one Change.
- Do not create a `Closeout Changes` model, command, or competing closeout
  route.
- Do not stage, commit, push, open a PR, land, merge, delete, restore, reset,
  or overwrite directly from this wrapper. Those material actions belong to a
  selected singular `closeout-change` route.
- Do not close unrelated residue under one receipt.
- Do not treat detection as deletion authority.
- Do not perform repo-hygiene cleanup from the wrapper. Global local artifact
  hygiene routes to `repo-hygiene-cleanup`, and unresolved cleanup candidates,
  protected referenced paths, or manual-review paths must prevent
  `git_clean_terminal`.
- Do not remove stale detached Git worktrees from detection alone. Removal
  requires explicit detached, clean, unreferenced, non-active worktree proof and
  must be recorded separately from branch cleanup and repo-hygiene cleanup.
- Do not use `.octon/inputs/**`, proposal-local files, generated outputs, host
  state, GitHub state, chat, model memory, or tool availability as closeout
  authority.
- Treat `lifecycle-interaction-request-v1` receipts as advisory context only.
  They may help classify a candidate boundary or next-route condition, but this
  wrapper still must inventory, classify, partition, delegate, and validate
  through its own report contract and target-owned gates before recording a
  worktree outcome.
- Do not continue when a candidate cannot be separated without touching
  ambiguous or user-owned work.
- Do not claim full worktree closeout while any retained, blocked, ambiguous,
  or foreign candidate remains undocumented.
- Do not claim `git_clean_terminal` while untracked retained evidence or other
  non-ignored residue remains. Ignored terminal local evidence sink files may
  remain for `git_clean_terminal` only when validated by
  `validate-terminal-closeout-local-evidence.sh`; otherwise use
  `disposition_complete_with_retained_residue` when all remaining residue is
  authority-backed and intentionally retained.
- Do not treat compact wrapper views (`closeout-projection.yml`,
  `publication-summary.yml`, `structured-receipt.yml`, or
  `expanded-report-request.yml`) as cleanup, Git, hosted-provider, rollback,
  authorization, support, policy, or closure authority.

## References

- [Phases](references/phases.md)
- [Decisions](references/decisions.md)
- [Checkpoints](references/checkpoints.md)
- [I/O contract](references/io-contract.md)
- [Safety](references/safety.md)
- [Validation](references/validation.md)
- [Dependencies](references/dependencies.md)
