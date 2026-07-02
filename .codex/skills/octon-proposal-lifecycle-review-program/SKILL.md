---
name: octon-proposal-lifecycle-review-program
description: Run the review-program bundle.
license: MIT
compatibility: Octon proposal lifecycle extension.
metadata:
  author: Octon Framework
  created: "2026-05-12"
  updated: "2026-05-12"
skill_sets: [executor, specialist]
capabilities: [self-validating]
allowed-tools: Read Glob Grep Write(/.octon/inputs/exploratory/proposals/*)
---

# Program - Review

Review one parent proposal program and write the parent-local
`support/proposal-review.md` review receipt.

Review is parent coordination only. Inspect the parent `proposal.yml`, child
registry and index, sequence, child contract, validation plan, closeout plan,
and parent support artifacts. The review receipt uses the existing proposal
review fields: `review_id`, `reviewed_at`, `reviewer`, `verdict`,
`implementation_prompt_authorized`, `reviewed_packet_digest`, approved targets,
exclusions, blocking findings, nonblocking findings, and final route. The only
allowed verdicts are `accepted`, `revision-required`, and `rejected`.

Set only the parent `proposal.yml#status`: `accepted` for an accepted verdict,
`rejected` for a rejected verdict, and `in-review` for
`revision-required`. Do not edit child manifests, child receipts, child
promotion targets, child validation verdicts, child archive metadata, runtime
truth, or generated effective authority. Parent review receipts never satisfy
child receipts.

This route is the review side of the existing `program-review-revision` loop.
Do not introduce or depend on a standalone program review-and-revise wrapper
unless a later accepted packet admits that surface.
