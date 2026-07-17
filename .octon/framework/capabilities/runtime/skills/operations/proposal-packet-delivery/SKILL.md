---
name: proposal-packet-delivery
description: Coordinate contained packet implementation or archive readiness without publication effects.
license: MIT
compatibility: Octon proposal lifecycle.
metadata:
  author: Octon Framework
  created: "2026-05-21"
  updated: "2026-07-14"
skill_sets: [executor, integrator, guardian]
capabilities: [safety-bounded, self-validating]
allowed-tools: Read Glob Grep Write(/.octon/state/evidence/runs/skills/proposal-packet-delivery/*) Write(/.octon/state/evidence/validation/analysis/*)
---

# Proposal Packet Delivery

Use only this current invocation shape:

```text
/proposal-packet-delivery target=<proposal-packet-path> outcome=implemented|archive-ready route=stage-only profile=<profile-path> run-id=<id>
```

Bind required `profile_path` and `delivery_run_id`, validate the profile, keep
target-owned receipts authoritative, and coordinate only implementation or
archive-readiness evidence. The pre-archive and already-archived states remain
preserved and no archive relocation is performed.

Fail with `RP00_CONTAINMENT_PUBLICATION_DISABLED` before dispatch for direct-
main, hosted branch-no-PR, landing, sync, cleanup, landed/synced/cleaned, or
omitted/default effectful requests. Preserve exact refs, branches, worktrees,
rollback handles, retained evidence, and unrelated work. Do not delegate to
Change closeout, closeout-worktree, Git/GitHub, provider, cleanup, branch
deletion, or publication routes. Historical receipt parsers are non-authorizing.
