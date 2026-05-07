---
name: octon-proposal-packet-lifecycle-revise
description: Run the revise-proposal-packet bundle.
license: MIT
compatibility: Octon proposal packet lifecycle extension.
metadata:
  author: Octon Framework
  created: "2026-05-06"
  updated: "2026-05-06"
skill_sets: [executor, specialist]
capabilities: [self-validating]
allowed-tools: Read Glob Grep Write(/.octon/inputs/exploratory/proposals/*)
---

# Proposal Packet Lifecycle Revise

Apply packet-local revisions for review findings and write
`support/revisions/<revision-id>.md`.

The revision receipt records `revision_id`, `source_review_id`, changed packet
files, addressed finding ids, remaining blocking count, post-revision digest,
validators rerun, and catalog/checksum/registry refresh confirmation. Keep or
return `proposal.yml#status` to `in-review`; acceptance requires a later
`review-proposal-packet` pass.
