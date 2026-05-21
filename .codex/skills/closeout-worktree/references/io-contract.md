---
title: Closeout Worktree I/O Contract
---

# I/O Contract

Inputs:

- Optional `worktree_id`
- Optional `target_lifecycle_outcome`
- Optional `candidate_limit`
- Optional `include_paths`
- Optional `exclude_paths`
- Optional `receipt_refs`
- Optional `stop_after_first`

Outputs:

- Worktree closeout report under
  `/.octon/state/evidence/validation/analysis/{{date}}-closeout-worktree-{{run_id}}.md`
- Skill execution log under
  `/.octon/state/evidence/runs/skills/closeout-worktree/{{run_id}}.md`
- Optional wrapper index under
  `/.octon/state/evidence/runs/skills/closeout-worktree/index.yml`

The report must list each candidate Change, disposition, delegated
`closeout-change` run or handoff reference, orchestration iteration, retained
residue, blocker, final disposition, and next route condition.

The wrapper does not emit a replacement Change receipt. Each completed,
continued, blocked, escalated, or denied candidate must rely on the singular
Change receipt or blocker evidence produced by `closeout-change`.

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
- `next_route_condition`

Each candidate record must include `candidate_id`, `disposition`, `ownership`,
`route_hint`, `target_lifecycle_outcome`, `rollback_or_discard_posture`, and
`boundaries.include_paths` plus `boundaries.exclude_paths`. Delegated and
closed candidates must include `closeout_change_ref` pointing to the singular
`closeout-change` run, receipt, or blocker handoff. A selected candidate may
stop before delegation only when candidate-keyed blocker evidence explains why
the selected candidate itself cannot safely run through `closeout-change`.

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
the singular `closeout-change` receipt, log, or evidence reference that appears
in the corresponding orchestration iteration. Delegated and closed candidates
must cite a retained evidence file under
`/.octon/state/evidence/runs/skills/closeout-change/`; synthetic route labels
do not prove delegation.

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
- Reports with any unresolved candidate must use a non-terminal
  `next_route_condition` that names the remaining route, blocker, or operator
  resolution condition.
- A report must not mark a safely separable selected candidate as blocked only
  because other candidates exist; multiple candidates trigger wrapper
  orchestration, not partition-only completion.

When a report continues or supersedes a previous wrapper partition, include
`prior_candidate_reconciliation.prior_report_ref` and a reconciliation record
for every prior candidate that is not still present. Each record must name the
prior candidate, the current candidate it maps to, one disposition of `folded`,
`retained`, `blocked`, `escalated`, `deferred`, or `foreign`, and a rationale.
