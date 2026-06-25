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

Set `proposal.yml#status` to `accepted` only for an accepted verdict unless the
packet is already `implemented`; for an already implemented packet, preserve
`implemented` and refresh the review receipt/digest for closeout or archive
recovery. Set status to `rejected` only for a rejected verdict, and leave it
`in-review` for `revision-required`. Do not implement or promote durable
targets.

Accepted review completion is receipt-atomic. If the route changes or observes
`proposal.yml#status: accepted` for an accepted verdict, it must refresh
`support/proposal-review.md` to the accepted-state packet digest, and refresh
the strict pre-integration architecture receipt to that same digest when it is
present or required, before reporting completion. A status-only accepted
mutation is incomplete route work.

While the packet is `in-review`, treat any earlier
`support/proposal-terminal-closeout.yml` as child-owned historical route
evidence, not as an open review blocker. Terminal freshness and archive-ready
evidence are required only by closeout, terminal closeout, archive, delivery, or
cleaned-claim routes that are legally selectable in the current lifecycle
posture.
