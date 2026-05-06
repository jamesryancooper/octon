---
name: octon-proposal-packet-lifecycle
description: Composite extension-pack skill that routes to the appropriate proposal packet lifecycle bundle.
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

# Octon Proposal Packet Lifecycle

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
- Implementation-grade completeness runs before implementation. After
  implementation, closeout must also prove `support/implementation-conformance-review.md`
  and `support/post-implementation-drift-churn-review.md` pass with
  `verdict: pass` and `unresolved_items_count: 0`.
- Use `run-implementation` as the lifecycle bridge after
  `generate-implementation-prompt` and before verification or closeout. It may
  promote durable targets only from an accepted packet or from an explicit
  operator invocation recorded as implementation acceptance for that packet.
  It must not archive the packet or treat proposal-local material as runtime,
  policy, support, or closure authority.
- Ask clarifying questions only when the missing answer changes product
  semantics, promotion scope, irreversible churn, or authority ownership.
  Proceed with recorded assumptions when missing details are discoverable or
  safely inferable.
- Packet-finalizing responses must include `implementation_grade_complete`,
  `implementation_conformant`, `post_implementation_drift_clean`, receipt
  paths, validators run, unresolved counts, known exclusions, and next
  canonical route.
