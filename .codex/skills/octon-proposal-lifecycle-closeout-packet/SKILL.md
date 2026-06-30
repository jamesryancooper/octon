---
name: octon-proposal-lifecycle-closeout-packet
description: Run the closeout-packet bundle.
license: MIT
compatibility: Octon proposal lifecycle extension.
metadata:
  author: Octon Framework
  created: "2026-04-30"
  updated: "2026-04-30"
skill_sets: [executor, specialist]
capabilities: [self-validating]
allowed-tools: Read Glob Grep Bash(git status) Bash(git diff) Bash(gh pr) Bash(.octon/framework/assurance/runtime/_ops/scripts/classify-proposal-worktree-hygiene.sh *) Bash(.octon/framework/assurance/runtime/_ops/scripts/validate-closeout-worktree-wrapper.sh *) Bash(.octon/framework/assurance/runtime/_ops/scripts/validate-lifecycle-interaction-receipts.sh *) Write(/.octon/inputs/exploratory/proposals/*) Write(/.octon/state/evidence/runs/skills/*)
---

# Packet - Closeout

Execute gated closeout for one proposal packet. Refuse closeout when required
packet receipts, evidence, archive state, final hygiene, or route-required
staging, review, check, PR, merge, branch-cleanup, or sync gates fail. Red
route-required checks require remediation, not status-only waiting.

Closeout must refuse final, accepted, implemented, archive-ready, or
implementation-ready claims unless `support/implementation-grade-completeness-review.md`
passes and the implementation-readiness validator succeeds. For implemented
closeout or implemented archival, also refuse unless
`support/implementation-conformance-review.md` and
`support/post-implementation-drift-churn-review.md` pass their validators with
no unresolved items, or the packet records an explicit blocked/deferred report
outcome or a rejected/superseded/historical archive disposition instead of a
successful closeout.

For packets that declare governed mechanism integration gates, also refuse
implemented closeout or implemented archival unless
`support/governed-mechanism-integration-evaluation.yml` passes
`validate-governed-mechanism-integration-receipt.sh --package <proposal_path>`.
Do not treat current-state mechanism architecture review, lifecycle postmortem,
generated outputs, host state, chat, tool state, dashboards, or model memory as
authority.

For already implemented packets, verify review preservation with the baseline
review gate. Do not require
`validate-proposal-review-gate.sh --require-implementation-authorization`
during closeout or archive readiness; that strict gate is reserved for
implementation prompt generation, implementation execution, and promotion.

Before claiming archive readiness, run the read-only worktree hygiene
classifier. For ordinary packet closeout, classify the target packet as a
proposal-packet:

```sh
.octon/framework/assurance/runtime/_ops/scripts/classify-proposal-worktree-hygiene.sh --target <packet-path> --lifecycle proposal-packet --format yaml
```

Pass the packet lifecycle run id with `--run-id <run-id>` when available. For a
program-child closeout route, the route prompt includes `Program Context` with
`program_run_id`; classify with `--lifecycle proposal-program --run-id
<program_run_id>` instead. Do not use the child route run id as the classifier
run id for program-child hygiene classification. This preserves child authority:
closeout receipts, archive authorization, validation verdicts, and terminal
lifecycle outcome remain child-owned.

For a program-child closeout route, the controller may bind retained
`lifecycle_interaction_return_refs`,
`program_child_closeout_worktree_report_ref`,
`program_child_worktree_hygiene_classifier_ref`, and
`program_child_worktree_hygiene_foreign_fingerprint` inputs. When present,
validate each bound route-scoped return receipt with
`validate-lifecycle-interaction-receipts.sh --return <return-ref>`. Do not
require unrelated historical return receipts from the same program run. Validate
the closeout-worktree report with
`validate-closeout-worktree-wrapper.sh --report <report-ref>`. The report must
cite the bound classifier evidence, match the bound foreign fingerprint, use a
non-mutating preserve/exclude disposition for this child route, and preserve
child-owned closeout authority. If those checks pass, the cited
foreign-or-ambiguous paths are preserved and excluded from child closeout
blocking only. Treat a valid bound return/report as a
`resolved-by-validated-closeout-worktree-return` hygiene disposition for this
child closeout route: it may allow `support/proposal-closeout.md` to record
`verdict: pass`, `archive_authorized: yes`, `target_outcome: archive-ready`,
`lifecycle_outcome: archive-ready`, and `worktree_hygiene_verdict:
preserved-by-closeout-worktree` when every other child-owned gate passes. The
receipt must cite the classifier, return receipt, closeout-worktree report, and
foreign fingerprint, and must state that the preserved paths remain outside
this child route's material authority. They are not cleaned, staged, committed,
archived, published, or used as parent/program substitutes for child receipts.
If validation fails, evidence is stale, or any other child-owned gate fails,
write a blocked child closeout receipt.

For closeout/archive-readiness, tolerate classifier snapshot ref churn and
path-only classifier snapshot churn by comparing the stable bound fingerprint
from `program_child_worktree_hygiene_foreign_fingerprint` against the validated
closeout-worktree report. If no validated program-child closeout-worktree
report has been accepted for the current fingerprint, the closeout receipt must
remain blocked. When the report is accepted, the closeout receipt may record
`verdict: pass`, `archive_authorized: yes`, and `lifecycle_outcome:
archive-ready` without claiming that preserved residue was cleaned or moved.
Compatibility guard: If no validated program-child closeout-worktree report has been accepted for the current fingerprint, the closeout receipt must remain blocked.
Compatibility guard: closeout receipt may record `verdict: pass`, `archive_authorized: yes`, and `lifecycle_outcome: archive-ready` only after accepted preservation evidence.

If the classifier reports any `foreign-or-ambiguous` paths and there is no
valid bound program-child closeout-worktree return/report covering the current
classifier evidence and foreign fingerprint, write or refresh
`support/proposal-closeout.md` with `verdict: blocked`, `archive_authorized:
no`, `selected_git_route: stage-only-escalate`, `worktree_hygiene_verdict:
blocked`, `worktree_hygiene_blocker_class: worktree-hygiene-blocked`, the
three hygiene path counts, a `worktree_hygiene_evidence` reference to the
classifier output, and `next_route_condition: closeout-change or operator
scope resolution`. Do not stage, commit, push, delete, reset, archive, or
otherwise clean worktree paths from this route.

Successful closeout writes or refreshes `support/proposal-closeout.md` with at
least `verdict`, `closed_at`, and `archive_authorized`. Use `verdict: pass` and
`archive_authorized: yes` only when the packet is ready for the separate
`archive-proposal` lifecycle route. When `archive_authorized: yes`, record
`promotion_evidence` as durable repo-relative evidence paths outside the
proposal packet only. For `archive_disposition: superseded`, those paths must
name successor packet/program evidence or retained successor closeout evidence
outside the superseded packet. Validation commands belong in the validation
summary and must not be listed as promotion evidence. Closeout must not archive
the packet directly.

After the route writes the closeout receipt, refresh generated proposal indexes
and terminal freshness before claiming archive readiness:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/generate-proposal-artifact-index.sh --proposal <proposal_path> --write
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-lifecycle-terminal-freshness.sh --proposal <proposal_path> --targeted
```

For a targeted dependency proposal or parent program, reuse only fresh
child-owned closeout evidence and post-write freshness validation passes. If
post-write targeted freshness validation fails, write or keep a blocked
disposition instead of claiming archive readiness.
Compatibility guard: targeted dependency proposal or parent program reuse requires fresh child-owned closeout evidence and post-write freshness validation passes.
Compatibility guard: post-write targeted freshness validation passes before archive readiness; otherwise write a blocked disposition.
Compatibility guard: after the route writes the closeout receipt, post-write targeted freshness validation passes before archive readiness.

When closeout is blocked because follow-on work is owned by another lifecycle,
emit a typed `lifecycle-interaction-request-v1` receipt only as dependency
context. Use the `handoff` profile with `interaction_kind:
follow_on_work_required`, bind the source run, phase, target, include/exclude
scope, evidence refs, required forbidden authority-transfer entries, stop
conditions, and expected return evidence. The request must not authorize Change
Closeout, Worktree Closeout, Repo Hygiene, Git/ref mutation, hosted-provider
actions, promotion, cleanup, or archive. The source packet cannot claim the
dependency is resolved until a validating `lifecycle-interaction-return-v1`
receipt cites fresh target-owned return evidence.
