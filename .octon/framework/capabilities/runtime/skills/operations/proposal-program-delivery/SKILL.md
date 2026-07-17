---
name: proposal-program-delivery
description: Coordinate contained program implementation or archive readiness without publication effects.
license: MIT
compatibility: Octon proposal lifecycle.
metadata:
  author: Octon Framework
  created: "2026-05-21"
  updated: "2026-07-14"
skill_sets: [executor, integrator, guardian]
capabilities: [safety-bounded, self-validating]
allowed-tools: Read Glob Grep Write(/.octon/state/evidence/runs/skills/proposal-program-delivery/*) Write(/.octon/state/evidence/validation/analysis/*)
---

# Proposal Program Delivery

Use the canonical command or its additive alias:

```text
/proposal-program-delivery target=<proposal-program-path> outcome=implemented|archive-ready route=stage-only profile=<profile-path> run-id=<id>
/octon-proposal-run-program-delivery target=<proposal-program-path> outcome=implemented|archive-ready route=stage-only profile=<profile-path> run-id=<id>
```

The alias delegates to `proposal-program-delivery` and does not create an independent lifecycle contract.
Bind required `profile_path` and
`delivery_run_id`, retain the child-before-parent order, and keep every child
receipt target-owned.

Reject direct-main, hosted branch-no-PR, landing, sync, cleanup,
landed/synced/cleaned, and omitted/default effectful requests before dispatch
with `RP00_CONTAINMENT_PUBLICATION_DISABLED`. Preserve exact parent and child
work. Do not delegate Git/GitHub, provider, Change closeout, closeout-worktree,
archive relocation, final sync, cleanup, branch deletion, or publication.
