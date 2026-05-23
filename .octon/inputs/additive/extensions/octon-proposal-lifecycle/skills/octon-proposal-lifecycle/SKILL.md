---
name: octon-proposal-lifecycle
description: Composite extension-pack skill that routes to the appropriate proposal lifecycle bundle for packet or program targets.
license: MIT
compatibility: Designed for Octon extension-pack publication and host projection.
metadata:
  author: Octon Framework
  created: "2026-04-30"
  updated: "2026-04-30"
skill_sets: [executor, integrator, specialist]
capabilities: [self-validating]
allowed-tools: Read Glob Grep Write(/.octon/inputs/exploratory/proposals/*) Write(/.octon/state/control/skills/checkpoints/*) Write(/.octon/state/evidence/runs/skills/*)
---

# Octon Proposal Lifecycle

Resolve `bundle` or `lifecycle_action` through
`context/routing.contract.yml`, then dispatch to the matching leaf bundle.

## Boundaries

- Keep proposal packets temporary and non-canonical.
- Retain source lineage under packet `resources/**`.
- Retain generated operational prompts under packet `support/**`.
- Use generated effective extension and capability outputs after publication.
- Never treat prompts, proposal packets, generated registries, GitHub, CI,
  chat, browser state, tool availability, or model memory as authority.

## Lifecycle Gates

- Proposal lifecycle owns completeness; users should not need to ask whether a
  packet includes everything.
- Do not present a proposal packet as final or implementation-ready unless
  `support/implementation-grade-completeness-review.md` exists with
  `verdict: pass`, `unresolved_questions_count: 0`, and
  `clarification_required: no`.
- Review is receipt-only. Use `support/proposal-review.md` for
  `accepted`, `revision-required`, or `rejected` review outcomes; do not add
  new proposal statuses. Use `support/revisions/<revision-id>.md` for
  packet-local revision passes and route back to review.
- Packet `phase_loop` phases are lifecycle context, not manifest statuses.
  `current_phase`, phase counts, and phase transition events help explain and
  resume a run but do not authorize implementation, promotion, closeout, or
  archive.
- Program review and revision are parent coordination only. Parent review may
  write parent-local `support/proposal-review.md` and update only the parent
  manifest status to `accepted`, `rejected`, or `in-review`; parent revision
  may write only parent-local coordination changes and
  `support/revisions/<revision-id>.md`. Parent receipts never satisfy child
  receipts.
- Do not generate implementation prompts, run implementation, or promote a
  proposal unless `validate-proposal-review-gate.sh --package <proposal_path>
  --require-implementation-authorization` passes with a fresh accepted review
  receipt.
- Implementation-grade completeness runs before implementation. After
  implementation, closeout must also prove `support/implementation-conformance-review.md`
  and `support/post-implementation-drift-churn-review.md` pass with
  `verdict: pass` and `unresolved_items_count: 0`.
- Use `run-packet-implementation` as the lifecycle bridge after
  `generate-packet-implementation-prompt` and before verification or closeout. It may
  promote durable targets only from an accepted packet with a fresh accepted
  proposal review receipt that authorizes implementation.
  It must not archive the packet or treat proposal-local material as runtime,
  policy, support, or closure authority.
- Use the shared `octon lifecycle` runner when the operator asks for a single
  end-to-end lifecycle orchestration surface. The runner owns planning, gates,
  stale-receipt detection, phase context, loop limits, evidence, and resume.
  Dispatch follows the published `execution_strategy`: `route-progression` for
  packet routes and `orchestrated-replan-loop` for program orchestration. Leaf
  proposal skills continue to own packet-specific semantics and edits.
- Use `/octon-proposal-run-program-lifecycle` for shared
  `proposal-program` orchestration. It wraps `octon lifecycle run --lifecycle
  proposal-program --target <program-packet-path>` and has no dispatcher route
  or prompt bundle. By default this is a planned `program-route-handoff`; add
  `--execute-routes` with bounded execution options when the operator asks for
  the plan-execute-replan loop rather than handoff evidence only. One program
  step is one parent-route dispatch or one runnable child-batch dispatch.
- Use `octon lifecycle cancel --run-id <run> --reason <text>` for durable
  packet or program cancellation. Program child approval pauses should route
  through `octon lifecycle program approve` before retry/resume unless the
  operator explicitly chooses an unattended override.
- Ask clarifying questions only when the missing answer changes product
  semantics, promotion scope, irreversible churn, or authority ownership.
  Proceed with recorded assumptions when missing details are discoverable or
  safely inferable.
- Packet-finalizing responses must include `implementation_grade_complete`,
  `implementation_conformant`, `post_implementation_drift_clean`, receipt
  paths, validators run, unresolved counts, known exclusions, and next
  canonical route.
