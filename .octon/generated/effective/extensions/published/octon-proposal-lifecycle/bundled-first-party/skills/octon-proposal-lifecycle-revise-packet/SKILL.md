---
name: octon-proposal-lifecycle-revise-packet
description: Run the revise-packet bundle.
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

# Packet - Revise

Apply packet-local revisions for review findings and write
`support/revisions/<revision-id>.md`.

The revision receipt records `revision_id`, `source_review_id`, changed packet
files, addressed finding ids, remaining blocking count, post-revision digest,
validators rerun, and catalog/checksum/registry refresh confirmation. Keep or
return `proposal.yml#status` to `in-review`; acceptance requires a later
`review-packet` pass.

Do not attempt to repair stale or blocked terminal closeout evidence in this
route. Treat terminal closeout residue as nonblocking route context unless the
current review names it as a packet-local finding with a concrete edit inside
the packet. Revision work is limited to remaining review findings.

Use the exact field name `post_revision_digest`. Do not emit
`post_revision_packet_digest`, `pending`, or placeholder digest state.
Compatibility guard: Do not emit `post_revision_packet_digest`, `pending`, or placeholder digest state.
