---
name: octon-proposal-lifecycle-review-packet
description: Run the review-packet bundle.
license: MIT
compatibility: Octon proposal lifecycle extension.
metadata:
  author: Octon Framework
  created: "2026-05-06"
  updated: "2026-05-06"
skill_sets: [executor, specialist]
capabilities: [self-validating]
allowed-tools: Read Glob Grep Write(/.octon/inputs/exploratory/proposals/*)
---

# Packet - Review

Review one proposal packet and write `support/proposal-review.md` as the
proposal-local review receipt.

The review receipt records `review_id`, `reviewed_at`, `reviewer`, `verdict`,
`implementation_prompt_authorized`, `reviewed_packet_digest`, approved targets,
exclusions, blocking findings, nonblocking findings, and final route. The only
allowed verdicts are `accepted`, `revision-required`, and `rejected`.

Set `proposal.yml#status` to `accepted` only for an accepted verdict, set it to
`rejected` only for a rejected verdict, and leave it `in-review` for
`revision-required`. Do not implement or promote durable targets.
