---
title: Closeout Change Validation
---

# Validation

Successful closeout proves one route, one target lifecycle outcome, and one
actual lifecycle outcome:

- an omitted target lifecycle outcome for a generic closeout request was
  resolved to `cleaned` before route mutation;
- `direct-main`: commit on current clean `main`, local validation evidence,
  Change receipt, landed ref, cleanup status, and rollback handle exist without
  PR metadata.
- `branch-no-pr`: branch or worktree state, no-PR rationale, lifecycle outcome,
  validation or blocker, durable history, integration/publication/cleanup
  status, receipt, and rollback or discard plan exist. Hosted `landed` requires
  provider ruleset evidence showing route-neutral fast-forward updates are
  allowed, governed landing authorization evidence recorded in
  `landing_authorization_ref`, a pushed source branch, exact source SHA
  required checks, freshness against `origin/main`, a fast-forward-only hosted
  update, landed ref, rollback handle, and post-push proof that `origin/main`
  equals `landed_ref`.
  `published-branch` is valid only as a continued handoff or blocker outcome,
  not as completed closeout. If the target was `landed` or `cleaned`, the
  receipt must include landing evaluation evidence, `not_landed_reason`, and
  `landing_stop_reason` when actual outcome is lower.
- `branch-pr`: Change identity, PR metadata, hosted checks when required,
  review evidence, lifecycle outcome, receipt, and rollback handle exist.
  Full closeout requires merge evidence or a precise external blocker.
- `stage-only-escalate`: preserved state and blockers are recorded without
  claiming completion.

For any landed or cleaned branch outcome, validation must include final
alignment evidence for local `main`, `origin/main`, and `landed_ref`. A
  branch-based completed closeout must additionally prove source-branch
integration into `origin/main`, post-landing `git fetch` evidence, local
`main` synchronization to `origin/main`, and landed-ref containment in both
local `main` and `origin/main`. For cleaned targets, validation must include
source-branch cleanup evidence backed by `branch-cleanup-authorization-v1`.
Deferred cleanup must downgrade the actual outcome and include
`not_cleaned_reason` plus `cleanup_stop_reason`; it must not validate as
`lifecycle_outcome: cleaned`.

For branch-no-pr terminal proof, validation must treat terminal current-state
proof as route-owned retained evidence, not as a post-landing source-branch
commit requirement. A terminal proof claim is valid only when the receipt cites
landing evidence, final sync proof, cleanup authorization, cleanup disposition,
rollback posture, and route-owned validation evidence; distinguishes
`landed_ref` from the terminal proof sink path or receipt path; and records
`terminal_current_state_proof_ref`, `terminal_current_state_proof_digest`, and
`non_authority_classification: retained-evidence-only` when a local terminal
sink is used. Missing prerequisites, a sink path that substitutes for
`landed_ref`, or any terminal proof write that mutates `origin/main`, local
`main`, the landed ref, or the source branch must downgrade the actual outcome
and block terminal success or `cleaned`.

For permission-sensitive git mutation blockers, validation must prove that
diagnostics identify the operation class, current and target refs when known,
expected authorization gate, likely sandbox, host, provider, remote, or
ref-write blocker, and owning rerun route for fetch, checkout, branch-local
commit, branch publication, hosted landing, final sync, branch cleanup, and
local or remote branch deletion or pruning. The diagnostic must appear only as
retained routing evidence or schema-allowed blocker evidence. A receipt that
uses diagnostics to authorize mutation, omit governed landing or cleanup
authorization, skip helper validation, skip post-fetch/final-sync proof, or
claim `landed` or `cleaned` while the mutation outcome is lower fails.

Completed or cleaned closeout also requires `stateful_closeout` evidence from
the Change Closeout State Machine. That evidence must cite the initial
inventory, residue classification, phase exits, cleanup decisions, cleanup
safety class, final verification, and hosted landing or branch cleanup refs
when applicable.

Concise closeout reporting also proves:

- `structured-receipt.yml`, `closeout-projection.yml`, optional
  `publication-summary.yml`, and `expanded-report-request.yml` cite canonical
  receipts and retained evidence by source refs and source digests;
- `closeout-projection.yml` declares `model_visible_token_estimate <= 4000`;
- compact artifacts validate with
  `.octon/framework/assurance/runtime/_ops/scripts/validate-structured-receipt-artifacts.sh`;
- missing, stale, digest-mismatched, or authority-conflicting compact artifacts
  fail closed instead of replacing the Change receipt or raw evidence;
- expanded reports are reconstructed on demand from
  `expanded-report-request.yml` after digest validation; and
- proposal inputs and generated/read-model outputs are not treated as
  runtime, policy, support, closure, rollback, or authorization authority.
