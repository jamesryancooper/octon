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
- each delegated unit was one coherent Change;
- each delegated unit routed through `closeout-change`;
- the selected candidate has explicit include and exclude path boundaries;
- multiple observed change sets are represented as multiple candidates rather
  than batched into one Change receipt;
- multiple observed change sets did not stop orchestration by themselves when
  the selected candidate was safely separable;
- inventory and classification were repeated after each delegated closeout;
- each delegated or closed candidate has an orchestration iteration with
  pre-inventory, pre-classification, singular `closeout-change`, post-inventory,
  post-classification, and next-selection evidence;
- every candidate has exactly one final disposition under
  `final_candidate_dispositions`;
- each closed candidate cites the singular `closeout-change` receipt JSON used
  for that iteration, that ref resolves under
  `.octon/state/evidence/runs/skills/closeout-change/`, and the receipt records
  `closeout_outcome: completed`;
- branch-based closed candidates prove source-branch integration into
  `origin/main`, governed landing authorization for hosted no-PR landing,
  post-landing fetch, local `main` sync to `origin/main`, landed-ref
  containment in both refs, and cleanup completed with governed cleanup
  authorization or deferred with blocker evidence through the singular receipt;
- no direct wrapper stage, commit, push, PR, landing, merge, reset, restore,
  overwrite, delete, or branch cleanup action occurred;
- ambiguous, foreign, user-owned, generated, evidence, host-projection,
  release, input-surface, or local ignored residue was retained or escalated
  rather than silently cleaned;
- ignored residue reported by the final classifier summary is covered by a
  retained or foreign candidate with candidate-keyed evidence;
- any prior wrapper partition referenced by the report is reconciled so prior
  candidates are either still present or explicitly folded, retained, blocked,
  escalated, deferred, or foreign;
- final reporting distinguishes closed Changes from retained or blocked
  worktree residue.

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
- A wrapper report with a synthetic or non-resolving `closeout-change`
  reference for a delegated or closed candidate fails.
- A wrapper report that references a prior wrapper report but omits a prior
  candidate without reconciliation fails.
- A wrapper report whose final residue summary reports ignored residue but
  lacks ignored/local retained or foreign evidence fails.
- A wrapper report with a safely separable selected candidate blocked only
  because multiple candidates exist fails.
- A wrapper report whose final dispositions omit any candidate fails.
- A wrapper report with a `retained`, `deferred`, or `foreign` candidate but no
  matching candidate-keyed retained-residue evidence fails.
- A wrapper report with a `blocked`, `escalated`, or `ambiguous` candidate but
  no matching candidate-keyed blocker evidence fails.
- A wrapper report that carries unresolved candidates while claiming terminal
  `next_route_condition: none` fails.
- A wrapper report that claims terminal completion while any candidate lacks a
  terminal final disposition fails.
- A wrapper report that claims cleanup from detection-only evidence fails.
- A wrapper report that introduces `Closeout Changes` as a canonical model
  fails.

Run
`.octon/framework/assurance/runtime/_ops/scripts/validate-closeout-worktree-wrapper.sh --report <path>`
against retained wrapper evidence before claiming worktree closeout.
