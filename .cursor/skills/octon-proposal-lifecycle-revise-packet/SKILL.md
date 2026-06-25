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

Do not use revision authority to repair or require stale terminal closeout
evidence while the packet is `in-review`. Record earlier
`support/proposal-terminal-closeout.yml` evidence as nonblocking route context,
use the exact `post_revision_digest` field with a computed digest, and fail
closed instead of writing `pending` placeholders for validators or refreshes.
