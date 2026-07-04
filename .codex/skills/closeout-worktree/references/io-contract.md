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
- Compact wrapper views under
  `/.octon/state/evidence/runs/skills/closeout-worktree/{{run_id}}/` when
  source evidence exists:
  - `structured-receipt.yml`
  - `closeout-projection.yml`
  - optional `publication-summary.yml`
  - `expanded-report-request.yml`
- Optional `lifecycle-interaction-return-v1` evidence that cites the
  target-owned wrapper report, delegated Change receipt, retained-residue
  evidence, or blocker evidence without transferring cleanup, Git,
  hosted-provider, promotion, archive, rollback, or scope authority

The report must list each candidate Change, disposition, delegated
`closeout-change` run or handoff reference, orchestration iteration, retained
residue, `retained_state_report`, blocker, final disposition,
`residue_routing_class`, and next route condition.

`retained_state_report` uses the Change receipt row vocabulary for delivered
branch, route-owned delivery branch, dirty-anchor branches, retained local
branches, retained worktrees, retained required evidence, local-private
evidence, generated diagnostics, deleted residue, excluded residue,
manual-review residue, remote mutation status, archive authorization, and final
current-state proof. The wrapper may cite target-owned evidence or explicitly
record `none`, but it must not authorize cleanup, branch deletion, archive
movement, generated publication, remote mutation, or terminal hygiene.

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
When a delegated branch-no-pr candidate emits terminal current-state proof, the
wrapper report may summarize only the delegated singular receipt's
`terminal_current_state_proof_ref` and digest-backed sink metadata. The wrapper
must not replace that target-owned proof, must keep `landed_ref` distinct from
the proof sink or receipt path, and must not claim terminal success unless the
singular receipt proves landing evidence, final sync proof, cleanup
authorization, cleanup disposition, rollback posture, and validation evidence.
When a delegated candidate records permission diagnostics for a blocked fetch,
checkout, branch-local commit, branch publication, hosted landing, final sync,
branch cleanup, or local or remote branch deletion or pruning, the wrapper
report may cite or summarize those diagnostics only from the delegated
`closeout-change` evidence. The summary must preserve operation class, current
and target refs when known, expected authorization gate, likely sandbox, host,
provider, remote, or ref-write blocker, and owning rerun route, and must not
perform or authorize the mutation.

When a dirty checked-out stale local branch is observed, the wrapper report may
record it as a local-worktree retirement candidate with branch role
`source-dirty-anchor`, residue classification, include/exclude boundaries, and
delegated `closeout-change` handoff. The wrapper must not claim
`retired-stale`, branch deletion, remote pruning, or safe switch completion
unless the delegated `closeout-change` receipt proves those facts with
branch-retirement authorization, post-delete verification, and rollback
evidence.

Compact wrapper outputs must source the canonical wrapper report, delegated
Change receipts, and retained evidence by `source_refs` and `source_digests`.
`closeout-projection.yml` is the default model-visible wrapper view and must
declare `model_visible_token_estimate <= 4000`. Raw/full wrapper reports and
delegated receipts are dereferenced only for stale or missing compact views,
digest mismatch, candidate ambiguity, authorization ambiguity, rollback gaps,
support-proof conflict, replay audit, or equivalent escalation.
`expanded-report-request.yml` enables on-demand narrative reconstruction after
digest validation and remains non-authoritative. Validate compact view shape and
digests with
`.octon/framework/assurance/runtime/_ops/scripts/validate-structured-receipt-artifacts.sh`.

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
- optional `fixture_retention_receipt_refs`
- `next_route_condition`

`worktree_terminal_state` must be one of:

- `git_clean_terminal`: no non-ignored staged, unstaged, untracked,
  retained-evidence, generated-effective, host-projection, state-control,
  release-version, or input-surface residue remains; ignored local residue may
  remain only with foreign evidence or with retained terminal local evidence
  under `.octon/state/evidence/local/terminal-closeout/<change-id>/` whose
  `terminal-closeout-local-evidence-v1` manifest validates exact path,
  digest, non-authority classification, schema version, and final ref
  alignment. Closed branch candidates must prove local `main` equals
  `origin/main` equals `landed_ref`, and source branch cleanup is completed
  with governed cleanup authorization.
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

When a proposal-program `lifecycle-interaction-request-v1` asks for
`closeout-worktree` handoff of `artifact-ownership-unclear` closeout residue,
a `foreign_manual_review` candidate may include raw/private Octon paths only
when it records `proposal_program_handoff_authorization` with:

- `authorization_grant` or `outside_child_route_write_scope: true`
- `child_id`, `route_id`, `interaction_request_ref`
- `classifier_output_ref` and matching `classifier_output_digest`
- `authorized_foreign_fingerprint` matching the classifier output
- `authorized_paths` exactly matching `boundaries.include_paths`
- `disposition: preserve-and-exclude-from-child-closeout-blocking`
- `non_mutating: true`
- `preserve_and_exclude_from_child_closeout_blocking: true`
- `parent_summary_not_child_closeout_receipt: true`
- `child_closeout_authority_preserved: true`
- `forbidden_actions` with every mutation, publication, archive, cleanup, and
  `cleaned` claim value set to `false`

This authorization supports retained/foreign disposition evidence only. It
does not authorize deletion, reset, staging, commit, publication, branch
cleanup, archive, promotion, child receipt replacement, child validation
replacement, archive authorization replacement, or child lifecycle outcome
replacement.

When a parent `cleanup-lifecycle-residue` handoff has route-specific operator
authorization to preserve and exclude parent residue from lifecycle closeout
blocking, a `foreign_manual_review` candidate may instead include
`proposal_program_parent_handoff_authorization` with:

- `authorization_grant`, `program_run_id`, and
  `parent_route_id: cleanup-lifecycle-residue`
- `cleanup_receipt_ref` and matching `cleanup_receipt_digest`
- `repo_hygiene_cleanup_receipt_digest`, `cleanup_authorization_digest`, and
  `post_cleanup_summary_digest` when the cleanup receipt records the matching
  helper digest fields
- `classifier_output_ref` and matching `classifier_output_digest`
- `authorized_foreign_fingerprint` matching the classifier output
- `authorized_paths` exactly matching `boundaries.include_paths`
- `disposition: preserve-and-exclude-from-lifecycle-closeout-blocking`
- `outside_child_owned_closeout_authority: true` or
  `separately_partitioned_for_later_legal_closeout: true`
- `non_mutating: true`
- `preserve_and_exclude_from_lifecycle_closeout_blocking: true`
- `parent_summary_not_child_closeout_receipt: true`
- `child_closeout_authority_preserved: true`
- `parent_evidence_replaces_child_evidence: false`
- `forbidden_actions` with deletion, reset, staging, commit, push,
  publication, archive, branch cleanup, git ref mutation, and `cleaned` claim
  values all set to `false`

This parent authorization supports preserved/foreign disposition for the named
lifecycle blocker only. It does not authorize archive, publication, cleanup,
branch cleanup, git mutation, a `cleaned` claim, or replacement of child-owned
receipts, child validation, archive authorization, or child lifecycle outcomes.

A fixture residue candidate may use `residue_routing_class:
local_private_retained` only when it includes
`fixture_retention_receipt_ref` pointing to a validating
`fixture-retention-closeout-receipt-v1` receipt. The wrapper consumes that
receipt but does not own fixture-retention authority. The receipt must prove
exact retained path-set match, current status digest, current schema/route
version, matching purpose and owner scope, freshness, and no archive-ready,
cleaned, deletion, Git, publication, status-mutation, or target packet evidence
authority.

When a `publishable_change` candidate includes lifecycle-owned proposal input
surfaces, archived proposal inputs, generated effective publication outputs,
proposal registry artifacts, publication evidence, or tracked extension control
files produced by a completed proposal-program lifecycle run, the candidate
must include `lifecycle_closeout_authority` with
`completed_program_run_id`, `program_target`,
`completed_program_summary_ref`, non-empty `proof_refs`,
`child_authority_preserved: true`,
`parent_summary_not_child_receipt: true`, and
`local_run_state_excluded: true`. This record authorizes only wrapper-safe
closeout classification; it does not make proposal inputs authoritative and
does not authorize publishing local execution run state.

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
`landed_ref`. For terminal proof after cleanup, the same singular receipt must
also cite terminal proof as retained evidence only, not as source-branch
post-landing commit evidence or as a mutation of `origin/main`, local `main`,
the landed ref, or the source branch.
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
For ignored terminal local evidence, the retained candidate must use
`residue_routing_class: local_private_retained`, its include path and
retained-residue path must stay under
`.octon/state/evidence/local/terminal-closeout/<change-id>/`, and the sibling
`manifest.json` must validate copied-file SHA-256 digests and
`non_authority_classification: retained-evidence-only`. This retained evidence
does not authorize landing, cleanup, archive, packet status, generated
publication freshness, hosted checks, or shared closeout claims.

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
