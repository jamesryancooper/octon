---
title: Closeout Worktree Validation
---

# Validation

Successful wrapper execution proves:

- the worktree was inventoried before candidate selection;
- any omitted worktree-level closeout target was resolved to `cleaned` before
  candidate delegation;
- residue classification was read-only and retained or summarized;
- every observed item has exactly one disposition;
- every candidate declares exactly one `residue_routing_class`;
- each delegated unit was one coherent Change;
- each delegated unit routed through `closeout-change`;
- the selected candidate has explicit include and exclude path boundaries;
- multiple observed change sets are represented as multiple candidates rather
  than batched into one Change receipt;
- multiple observed change sets did not stop orchestration by themselves when
  the selected candidate was safely separable;
- unambiguous partitions can proceed without an operator partition prompt;
- inventory and classification were repeated after each delegated closeout;
- each delegated or closed candidate has an orchestration iteration with
  pre-inventory, pre-classification, singular `closeout-change`, post-inventory,
  post-classification, and next-selection evidence;
- every candidate has exactly one final disposition under
  `final_candidate_dispositions`;
- `worktree_terminal_state` distinguishes `git_clean_terminal`,
  `disposition_complete_with_retained_residue`, and `nonterminal`;
- `nonterminal` is reported only when at least one candidate, repo-hygiene
  summary, blocker, deferred state, escalation, unsafe residue, or ambiguity is
  genuinely unresolved;
- terminal wrapper states are rejected while any closed branch receipt still
  defers source branch cleanup;
- `disposition_complete_with_retained_residue` is supported only by
  `local_private_retained` or `foreign_manual_review` candidates with
  candidate-keyed retained evidence;
- `publishable_change` and `publishable_closeout_evidence` are the only
  routing classes delegated to `closeout-change`;
- lifecycle-owned proposal input, generated effective, publication evidence,
  or tracked extension control surfaces are accepted as `publishable_change`
  only when the candidate records completed proposal-program proof,
  child-authority preservation, parent-summary non-substitution, and local
  run-state exclusion in `lifecycle_closeout_authority`;
- `unsafe` and `ambiguous` routing classes force `nonterminal` with
  candidate-keyed blocker evidence;
- each closed candidate cites the singular `closeout-change` receipt JSON used
  for that iteration, that ref resolves under
  `.octon/state/evidence/runs/skills/closeout-change/`, and the receipt records
  `closeout_outcome: completed`;
- branch-based closed candidates prove source-branch integration into
  `origin/main`, governed landing authorization for hosted no-PR landing,
  hosted landing evidence, exact source-SHA required check refs, post-landing
  fetch, local `main` sync to `origin/main`, landed-ref containment in both
  refs, local `main`/`origin/main`/`landed_ref` alignment, and cleanup
  completed with governed cleanup authorization when the singular receipt
  reports `cleaned`;
- no direct wrapper stage, commit, push, PR, landing, merge, reset, restore,
  overwrite, delete, or branch cleanup action occurred;
- repo-hygiene cleanup, when needed, was delegated to the
  `repo-hygiene-cleanup` route and not performed by the wrapper;
- ambiguous, foreign, user-owned, generated, evidence, host-projection,
  release, input-surface, or local ignored residue was retained or escalated
  rather than silently cleaned;
- ignored residue reported by the final classifier summary is covered by a
  retained or foreign candidate with candidate-keyed evidence;
- ignored terminal local evidence under
  `.octon/state/evidence/local/terminal-closeout/<change-id>/` is accepted for
  `git_clean_terminal` only when the retained candidate is
  `local_private_retained` and the sibling
  `terminal-closeout-local-evidence-v1` manifest proves exact path containment,
  SHA-256 copied-file digests, `retained-evidence-only` non-authority
  classification, and live-ref alignment;
- any prior wrapper partition referenced by the report is reconciled so prior
  candidates are either still present or explicitly folded, retained, blocked,
  escalated, deferred, or foreign;
- final reporting distinguishes closed Changes from retained or blocked
  worktree residue.
- terminal reporting distinguishes a truly Git-clean worktree from a fully
  dispositioned worktree that still retains evidence residue.
- compact wrapper artifacts cite the wrapper report, delegated
  `closeout-change` receipts, and retained evidence by source refs and source
  digests;
- `closeout-projection.yml` declares `model_visible_token_estimate <= 4000`
  and validates with
  `.octon/framework/assurance/runtime/_ops/scripts/validate-structured-receipt-artifacts.sh`;
- missing, stale, digest-mismatched, or authority-conflicting compact wrapper
  artifacts fail closed instead of replacing wrapper reports, delegated
  receipts, raw evidence, rollback, authorization, support, or closure proof;
- expanded wrapper reports are reconstructed on demand from
  `expanded-report-request.yml` after digest validation.

Negative controls:

- A wrapper report that batches unrelated path groups into one Change fails.
- A wrapper report whose selected candidate lacks explicit include/exclude
  boundaries fails.
- A wrapper report whose selected candidate lacks `closeout-change` delegation
  evidence and also lacks a candidate-specific blocker fails.
- A wrapper report with a delegated or closed candidate but no orchestration
  iteration fails.
- A wrapper report with an iteration missing post-inventory or
  post-classification evidence fails.
- A wrapper report with a closed final disposition but no singular
  completed `closeout-change` receipt fails.
- A wrapper report that marks a `published-branch` or `branch-local-complete`
  continued handoff receipt as `closed` fails.
- A wrapper report whose closed branch receipt claims completed cleanup without
  `branch-cleanup-authorization-v1` evidence fails.
- A wrapper report whose closed branch-no-pr receipt lacks
  `landing_authorization_ref` fails.
- A wrapper report whose closed branch-no-pr receipt lacks exact source-SHA
  hosted check refs fails.
- A wrapper report with a synthetic or non-resolving `closeout-change`
  reference for a delegated or closed candidate fails.
- A wrapper report that references a prior wrapper report but omits a prior
  candidate without reconciliation fails.
- A wrapper report whose final residue summary reports ignored residue but
  lacks ignored/local retained or foreign evidence fails.
- A wrapper report that claims `git_clean_terminal` with ignored terminal local
  evidence whose manifest is missing, stale, digest-mismatched, outside
  `.octon/state/evidence/local/terminal-closeout/<change-id>/`, or authority
  overclaiming fails.
- A wrapper report with a safely separable selected candidate blocked only
  because multiple candidates exist fails.
- A wrapper report with `repo_hygiene_cleanup_actions_performed: true` fails.
- A wrapper report that cites repo-hygiene cleanup with a non-resolving
  `repo_hygiene_cleanup_ref` fails.
- A wrapper report that leaves repo-hygiene cleanup candidates, protected
  referenced paths, or manual-review paths unresolved while claiming terminal
  `next_route_condition: none` fails.
- A wrapper report whose final dispositions omit any candidate fails.
- A wrapper report with a `retained`, `deferred`, or `foreign` candidate but no
  matching candidate-keyed retained-residue evidence fails.
- A wrapper report with a `blocked`, `escalated`, or `ambiguous` candidate but
  no matching candidate-keyed blocker evidence fails.
- A wrapper report that carries unresolved candidates while claiming terminal
  `next_route_condition: none` fails.
- A wrapper report with `worktree_terminal_state: nonterminal` but no
  unresolved candidate, repo-hygiene residue, blocker, deferred state,
  escalation, unsafe residue, or ambiguity fails.
- A wrapper report that claims `worktree_terminal_state: git_clean_terminal`
  while untracked retained evidence or other non-ignored residue remains fails.
- A wrapper report that claims terminal retained-residue disposition without
  `worktree_terminal_state: disposition_complete_with_retained_residue` fails.
- A wrapper report that claims terminal retained-residue disposition for
  ordinary untracked/source, generated, control, input, raw/private state, or
  host-projection residue fails.
- A wrapper report that counts broad raw/private state, `.octon/engine/**`,
  generated authority, transcripts, or input surfaces as publishable closeout
  evidence fails.
- A wrapper report that classifies lifecycle-owned proposal input/generated
  publication/control surfaces as `publishable_change` without
  `lifecycle_closeout_authority` proof fails.
- A wrapper report that routes recursive final-branch operational evidence as
  another publishable closeout-evidence publication fails; it must be retained
  locally or reported as nonterminal with blocker evidence.
- A wrapper report that classifies `closeout-worktree` skill run logs under
  `.octon/state/evidence/runs/skills/closeout-worktree/**` as publishable
  closeout evidence fails.
- A wrapper report that claims terminal completion while any candidate lacks a
  terminal final disposition fails.
- A wrapper report that claims cleanup from detection-only evidence fails.
- A wrapper report that introduces `Closeout Changes` as a canonical model
  fails.
- A compact wrapper view that claims authority, omits source digests, exceeds
  the closeout projection token ceiling, or points to proposal-local inputs as
  evidence fails.

Run
`.octon/framework/assurance/runtime/_ops/scripts/validate-closeout-worktree-wrapper.sh --report <path>`
against retained wrapper evidence before claiming worktree closeout.
