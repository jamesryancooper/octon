---
name: octon-proposal-packet-lifecycle-generate-program-implementation-prompt
description: Run the generate-program-implementation-prompt bundle.
license: MIT
compatibility: Octon proposal packet lifecycle extension.
metadata:
  author: Octon Framework
  created: "2026-04-30"
  updated: "2026-04-30"
skill_sets: [executor, specialist]
capabilities: [self-validating]
allowed-tools: Read Glob Grep Write(/.octon/inputs/exploratory/proposals/*)
---

# Proposal Packet Lifecycle Generate Program Implementation Prompt

Generate a program implementation prompt only after the program child-readiness
gate passes:

```sh
bash .octon/framework/assurance/runtime/_ops/scripts/validate-proposal-program-child-readiness.sh --package <program-packet-path>
```

For every required, non-deferred child packet, the gate requires the child
manifest metadata including `change_profile`, a passing
`support/implementation-grade-completeness-review.md`, and an accepted fresh
`support/proposal-review.md` digest. Refuse prompt generation when
clarification, blockers, unresolved questions, stale child reviews, missing
packet-specific requirements, or incoherent predecessor/cutover constraints
remain.

Generate aggregate implementation guidance that respects each child packet's
own manifests, validators, acceptance criteria, and promotion targets while
keeping parent coordination distinct from child authority.

Proposal readiness authorizes implementation prompt generation only. It is not
evidence that implementation has completed, and the program prompt must not
require durable contracts, schemas, validators, fixtures, implementation
receipts, or promoted runtime support to already exist unless a child packet
claims they already exist.

The program prompt must require each implemented child packet to produce and
pass `support/implementation-conformance-review.md` and
`support/post-implementation-drift-churn-review.md` before child closeout or
implemented archival.
