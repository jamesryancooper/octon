---
title: Closeout Worktree I/O Contract
---

# I/O Contract

Inputs:

- Optional `worktree_id`
- Optional `target_lifecycle_outcome`; omitted means `cleaned` for generic
  worktree closeout requests
- Optional `candidate_limit`
- Optional `include_paths`
- Optional `exclude_paths`
- Optional `receipt_refs`
- Optional `stop_after_first`
- Optional `lifecycle_interaction_request_ref`; advisory context only

Outputs:

- Worktree closeout report under
  `/.octon/state/evidence/validation/analysis/{{date}}-closeout-worktree-{{run_id}}.md`
- Skill execution log under
  `/.octon/state/evidence/runs/skills/closeout-worktree/{{run_id}}.md`
- Optional wrapper index under
  `/.octon/state/evidence/runs/skills/closeout-worktree/index.yml`
- Optional `lifecycle-interaction-return-v1` evidence that cites the
  target-owned wrapper report, delegated Change receipt, retained-residue
  evidence, or blocker evidence without transferring cleanup, Git,
  hosted-provider, promotion, archive, rollback, or scope authority

The report must list each candidate Change, disposition, delegated
`closeout-change` run or handoff reference, orchestration iteration, retained
residue, blocker, final disposition, `residue_routing_class`, and next route
condition.

When candidate boundaries come from a `lifecycle-interaction-request-v1`, the
request may inform classification and partitioning only. The wrapper must still
perform its own inventory, classification, partitioning, delegation, report
validation, and target-owned gates before recording any worktree outcome.

The wrapper does not emit a replacement Change receipt. Each completed,
continued, blocked, escalated, or denied candidate must rely on the singular
Change receipt or blocker evidence produced by `closeout-change`.
When a delegated candidate lands through hosted `branch-no-pr`, that singular
receipt must carry the governed landing authorization reference required by
`closeout-change`; the wrapper report may cite it only through the singular
receipt and must not authorize hosted mutation itself.
When a delegated candidate cleans up a local or remote source branch, that
singular receipt must carry the governed cleanup authorization reference
required by `closeout-change`; the wrapper report may cite it only through the
singular receipt and must not authorize branch deletion itself.

Repo-hygiene cleanup is a delegated subroute, not a wrapper action. The wrapper
may cite `repo_hygiene_cleanup_ref`,
`repo_hygiene_cleanup_authorization_ref`, and
`repo_hygiene_cleanup_outcome`, but
`repo_hygiene_cleanup_actions_performed` must remain `false`. A terminal
worktree hygiene claim is allowed only when the final repo-hygiene
classification reports no unresolved cleanup candidates, protected referenced
paths, or manual-review paths, or when a blocker or next-route condition
records why the residue remains.

If the operator does not explicitly request a narrower worktree or candidate
target such as `published-branch`, `branch-local-complete`, `landed`,
`preserved`, or `blocked`, and does not explicitly request the
`stage-only-escalate` route, the wrapper must pass
`target_lifecycle_outcome: cleaned` to each safely separable `closeout-change`
delegation. Explicit `stage-only-escalate` route requests must be paired with a
route-compatible target such as `preserved`, `blocked`, or `escalated`. The
report may still record a lower final candidate disposition when the singular
receipt proves only a lower outcome. Wrapper-level `cleaned` targets
`worktree_terminal_state: git_clean_terminal` when policy allows; singular
`closeout-change` `cleaned` remains route-bound.

## Report Schema

Wrapper reports use `schema_version: closeout-worktree-report-v1` and must
include:

- `wrapper_id: closeout-worktree`
- `default_work_unit: Change`
- `observed_change_set_count`
- `read_only_classification: true`
- `detection_is_deletion_authority: false`
- `direct_material_actions_performed: false`
- `initial_inventory_ref`
- `residue_classification_ref`
- `selected_candidate_id`
- `candidates`
- `iterations`
- `final_candidate_dispositions`
- `retained_residue`
- `blockers`
- `final_inventory_ref`
- `final_residue_classes`
- `worktree_terminal_state`
- optional `repo_hygiene_classification_ref`
- optional `repo_hygiene_cleanup_ref`
- optional `repo_hygiene_cleanup_authorization_ref`
- optional `repo_hygiene_cleanup_outcome`
- optional `repo_hygiene_next_route_condition`
- `next_route_condition`

`worktree_terminal_state` must be one of:

- `git_clean_terminal`: no non-ignored staged, unstaged, untracked,
  retained-evidence, generated-effective, host-projection, state-control,
  release-version, or input-surface residue remains; ignored local residue may
  remain only with foreign or retained evidence. Closed branch candidates must
  prove local `main` equals `origin/main` equals `landed_ref`, and source
  branch cleanup is completed with governed cleanup authorization.
- `disposition_complete_with_retained_residue`: every candidate is `closed`,
  `retained`, or `foreign` with authority-backed evidence, but Git-clean is not
  claimed.
- `nonterminal`: blocked, deferred, escalated, ambiguous, or unresolved
  delegated residue remains. `nonterminal` requires a genuinely unresolved
  candidate, repo-hygiene summary, blocker, deferred state, escalation, unsafe
  residue, deferred branch cleanup, or ambiguity.

Each candidate record must include `candidate_id`, `disposition`,
`residue_routing_class`, `ownership`, `route_hint`,
`target_lifecycle_outcome`, `rollback_or_discard_posture`, and
`boundaries.include_paths` plus `boundaries.exclude_paths`.
`residue_routing_class` must be one of `publishable_change`,
`publishable_closeout_evidence`, `local_private_retained`,
`foreign_manual_review`, `unsafe`, or `ambiguous`. Delegated and closed
candidates must be `publishable_change` or `publishable_closeout_evidence` and
must include `closeout_change_ref` pointing to the singular `closeout-change`
run, receipt, or blocker handoff. `local_private_retained` and
`foreign_manual_review` may support retained-residue completion only with
candidate-keyed retained evidence. `unsafe` and `ambiguous` force
`worktree_terminal_state: nonterminal` with candidate-keyed blocker evidence.
A selected candidate may stop before delegation only when candidate-keyed
blocker evidence explains why the selected candidate itself cannot safely run
through `closeout-change`.

`iterations` is required for every new report and must be non-empty when any
candidate is delegated or closed. Each iteration must include:

- `iteration_id`
- `pre_inventory_ref`
- `pre_classification_ref`
- `selected_candidate_id`
- `include_paths`
- `exclude_paths`
- `closeout_change_ref`
- `closeout_change_outcome`
- `post_inventory_ref`
- `post_classification_ref`
- `next_selection_reason`

`final_candidate_dispositions` must be keyed by candidate id and must include
exactly one final state for every candidate: `closed`, `retained`, `blocked`,
`escalated`, `deferred`, or `foreign`. A `closed` final disposition must cite
the singular `closeout-change` receipt JSON that appears in the corresponding
orchestration iteration, resolves under
`/.octon/state/evidence/runs/skills/closeout-change/`, and records
`closeout_outcome: completed`. A branch receipt with `branch-local-complete` or
`published-branch` is a continued handoff, not closed wrapper disposition.
For branch-no-pr `landed` or `cleaned` receipts, the singular receipt must
prove `landing_authorization_ref`, hosted landing evidence, exact source-SHA
required check refs, source-branch integration, local `main` sync,
`origin/main` fetch evidence, and equality of local `main`, `origin/main`, and
`landed_ref`.
When the receipt claims completed source branch cleanup, it must also cite a
validating `branch-cleanup-authorization-v1` receipt. A cleanup-deferred landed
receipt may be closed as landed only when it is not reported as cleaned and
retains blocker evidence for cleanup deferral.
Delegated candidates may cite retained closeout-change evidence, but synthetic
route labels do not prove delegation.

`final_residue_classes` must include an `ignored` count from the final
classification or final inventory summary. When `ignored` is greater than zero,
the report must include a retained or foreign candidate with candidate-keyed
ignored/local residue evidence.

Unresolved candidates must carry candidate-keyed evidence:

- `retained`, `deferred`, and `foreign` candidates require
  `retained_residue` entries with matching `candidate_id`, repo-relative
  `path`, and `disposition`; the retained residue paths must cover the
  candidate's included boundary paths.
- `blocked`, `escalated`, and `ambiguous` candidates require `blockers`
  entries with matching `candidate_id` and `blocker` or `reason` text.
- `deferred` candidates may also cite a non-terminal `closeout-change` receipt
  that records `continued`, `blocked`, `stage_only`, `escalated`, or `denied`
  closeout instead of pretending a handoff is closed.
- Reports with any unresolved candidate must use a non-terminal
  `next_route_condition` that names the remaining route, blocker, or operator
  resolution condition.
- Reports with `worktree_terminal_state: git_clean_terminal` must not have
  untracked retained evidence or other non-ignored residue in
  `final_residue_classes`; if fresh repo-local closeout evidence remains after
  the final delegated candidate, use
  `disposition_complete_with_retained_residue`.
- Reports with `worktree_terminal_state:
  disposition_complete_with_retained_residue` may retain only
  `local_private_retained` or `foreign_manual_review` residue with
  candidate-keyed evidence; ordinary untracked/source, generated, control,
  input, raw/private state, or host-projection residue cannot satisfy terminal
  completion.
- Recursive final-branch operational evidence is local-private retained
  evidence; it must not be routed as another publishable closeout-evidence
  candidate. `closeout-worktree` skill run logs under
  `.octon/state/evidence/runs/skills/closeout-worktree/**` are operational
  evidence, not publishable closeout-evidence candidates.
- A report must not mark a safely separable selected candidate as blocked only
  because other candidates exist; multiple candidates trigger wrapper
  orchestration, not partition-only completion.
- A report must not claim the wrapper performed repo-hygiene deletion. If
  repo-hygiene cleanup occurred, cite the delegated `repo-hygiene-cleanup`
  evidence and keep `repo_hygiene_cleanup_actions_performed: false`.

When a report continues or supersedes a previous wrapper partition, include
`prior_candidate_reconciliation.prior_report_ref` and a reconciliation record
for every prior candidate that is not still present. Each record must name the
prior candidate, the current candidate it maps to, one disposition of `folded`,
`retained`, `blocked`, `escalated`, `deferred`, or `foreign`, and a rationale.
