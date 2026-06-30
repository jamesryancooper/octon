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

Do not treat stale or blocked terminal closeout evidence as an open review
blocker for an `in-review` packet. `support/proposal-terminal-closeout.yml`
may be read only as child-owned historical evidence or child-owned historical
route context, and must not force revision-required by itself.
Compatibility guard: stale or blocked terminal closeout evidence as an open review blocker is forbidden; child-owned historical evidence and child-owned historical route context do not drive an in-review blocker.

Set `proposal.yml#status` to `accepted` only for an accepted verdict unless the
packet is already `implemented`; for an already implemented packet, preserve
`implemented` and refresh the review receipt/digest for closeout or archive
recovery. Set status to `rejected` only for a rejected verdict, and leave it
`in-review` for `revision-required`. Do not implement or promote durable
targets.

Accepted review completion is receipt-atomic. Do not perform a status-only
accepted mutation or leave an incomplete route result: accepted completion must
include the accepted-state packet digest in `reviewed_packet_digest`, a fresh
review receipt, any required strict pre-integration architecture receipt, and
the registry/checksum/catalog refresh evidence required by the packet.
Compatibility guard: accepted-state packet digest, status-only accepted mutation, incomplete route result, and strict pre-integration architecture receipt are checked together.
